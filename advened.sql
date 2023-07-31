-- 1.	 Cho biết họ tên sinh viên KHÔNG học học phần nào (5đ)

select MaSV,HoTen from sinhvien where MaSV not in (select distinct MaSV from diemhp);

-- 2.	Cho biết họ tên sinh viên CHƯA học học phần nào có mã 1 (5đ)

select MaSV,HoTen from sinhvien where MaSV not in (select MaSV from diemhp where MaHP = 1);

-- 3.	Cho biết Tên học phần KHÔNG có sinh viên điểm HP <5. (5đ)

select MaHP,TenHP from dmhocphan where MaHP not in (select distinct MaHP from diemhp where diemhp < 5);

-- 4.	Cho biết Họ tên sinh viên KHÔNG có học phần điểm HP<5 (5đ)

select MaSV,HoTen from sinhvien where MaSV not in (select MaSV from diemhp where diemhp < 5);

-- •	DẠNG CẤU TRÚC LỒNG NHAU KHÔNG KẾT NỐI
-- 5.	Cho biết Tên lớp có sinh viên tên Hoa (5đ)

select lop.TenLop from dmlop lop 
join sinhvien sv on lop.MaLop = sv.MaLop
where sv.HoTen like "%Hoa";

-- 6.	Cho biết HoTen sinh viên có điểm học phần 1 là <5.

select sv.HoTen from sinhvien sv
join diemhp d on d.MaSV = sv.MaSV
where d.MaHP = 1 and d.DiemHP < 5;

-- 7.	Cho biết danh sách các học phần có số đơn vị học trình lớn hơn hoặc bằng số đơn vị học trình của học phần mã 1.

select * from dmhocphan where Sodvht >= (select Sodvht from dmhocphan where MaHP = 1);

-- •	DẠNG TRUY VẤN VỚI LƯỢNG TỪ: ALL, ANY, EXISTS
-- 8.	Cho biết HoTen sinh viên có DiemHP cao nhất. (ALL)

select sv.MaSV,sv.HoTen,d.MaHP,d.DiemHP from sinhvien sv
join diemhp d on sv.MaSV = d.MaSV 
where d.DiemHP = (select max(DiemHP) from diemhp);

-- 9.	Cho biết MaSV, HoTen sinh viên có điểm học phần mã 1 cao nhất. (ALL)

select sv.MaSV,sv.HoTen from sinhvien sv
join diemhp d on sv.MaSV = d.MaSV 
where d.DiemHP = (select max(DiemHP) from diemhp where MaHP = 1);

-- 10.	Cho biết MaSV, MaHP có điểm HP lớn hơn bất kì các điểm HP của sinh viên mã 3 (ANY).

select MaSV,MaHP from diemhp where DiemHP > any (select DiemHP from diemhp where MaSV = 3);

-- 11.	Cho biết MaSV, HoTen sinh viên ít nhất một lần học học phần nào đó. (EXISTS)

select distinct sv.MaSV,sv.HoTen from sinhvien sv
where exists (select 1 from diemhp d where d.MaSV = sv.MaSV);

-- 12.	Cho biết MaSV, HoTen sinh viên đã không học học phần nào. (EXISTS)

select MaSV,HoTen from sinhvien where MaSV not in (select distinct sv.MaSV from sinhvien sv
where exists (select 1 from diemhp d where d.MaSV = sv.MaSV));

-- •	DẠNG TRUY VẤN VỚI CẤU TRÚC TẬP HỢP: UNION
-- 13.	Cho biết MaSV đã học ít nhất một trong hai học phần có mã 1, 2. 

	select distinct sv.MaSV from sinhvien sv
    join diemhp d on sv.MaSV = d.MaSV
    where d.MaHP in (1,2);

-- 14.	Tạo thủ tục có tên KIEM_TRA_LOP cho biết HoTen sinh viên KHÔNG có điểm HP <5 ở lớp có mã chỉ định (tức là tham số truyền vào procedure là mã lớp). Phải kiểm tra MaLop chỉ định có trong danh mục hay không, nếu không thì hiển thị thông báo ‘Lớp này không có trong danh mục’. Khi lớp tồn tại thì đưa ra kết quả.
-- Ví dụ gọi thủ tục: Call KIEM_TRA_LOP(‘CT12’).

delimiter //
create procedure KIEM_TRA_LOP(lop varchar(20))
begin 
	declare malopexist varchar(20);
	select count(*) into malopexist  from dmlop where MaLop = lop;
    if malopexist = 0 then
		select 'Lớp này không có trong danh mục' as ketqua;
    else 
		select * from sinhvien where MaLop = lop and MaSV not in (select MaSV from diemhp where DiemHP < 5);
	end if;
end //
//

call KIEM_TRA_LOP('CT12');

-- 15.	Tạo một trigger để kiểm tra tính hợp lệ của dữ liệu nhập vào bảng sinhvien là MaSV không được rỗng  Nếu rỗng hiển thị thông báo ‘Mã sinh viên phải được nhập’.

set delimiter //
create trigger before_insert_sinhvien 
before insert on sinhvien for each row 
begin
	if new.MaSV is null or new.MaSV = '' then
        signal sqlstate '45000'
        set message_text = 'Mã sinh viên phải được nhập';
    end if;
end;

-- nhưng id của em là auto_increment nên nó vẫn được
insert into sinhvien values (null,"Trần Thị Hoa","CT11",1,"1994-08-09","Hoài Nhơn");

-- 16.	Tạo một TRIGGER khi thêm một sinh viên trong bảng sinhvien ở một lớp nào đó thì cột SiSo của lớp đó trong bảng dmlop (các bạn tạo thêm một cột SiSo trong bảng dmlop) tự động tăng lên 1, đảm bảo tính toàn vẹn dữ liệu khi thêm một sinh viên mới trong bảng sinhvien thì sinh viên đó phải có mã lớp trong bảng dmlop. Đảm bảo tính toàn vẹn dữ liệu khi thêm là mã lớp phải có trong bảng dmlop.

alter table dmlop add column SiSo int not null;

update dmlop l set l.SiSo = (select count(*) from sinhvien sv where sv.MaLop = l.MaLop)

set delimiter //
create trigger after_insert_sinhvien 
after insert on sinhvien for each row
begin
	update dmlop set SiSo = SiSo + 1 where MaLop = New.MaLop;
end;
insert into sinhvien values (11,"Phạm Tuấn Bình","CT11",1,"2001-09-18","Hà Nội");

-- 17.	Viết một function DOC_DIEM đọc điểm chữ số thập phân thành chữ  Sau đó ứng dụng để lấy ra MaSV, HoTen, MaHP, DiemHP, DOC_DIEM(DiemHP) để đọc điểm HP của sinh viên đó thành chữ

-- create function DOC_DIEM(diem float) returns varchar(255); 
-- begin 
-- 	declare doc_diem varchar(255);
--     declare phan_nguyen int;
--     declare phan_thap_phan float;
--     
--     set doc_diem = '';
--     set phan_nguyen = FLOOR(diem);
--     set phan_thap_phan = diem - phan_nguyen;
--     
--     if diem = 0 then return 'không';
--     if diem = 10 then return 'mười';
--     
--     case
-- 		when phan_nguyen = 0 then set doc_diem = concat(doc_diem,'Không');
-- 		when phan_nguyen = 1 then set doc_diem = concat(doc_diem,'Một');
-- 		when phan_nguyen = 2 then set doc_diem = concat(doc_diem,'Hai');
-- 		when phan_nguyen = 3 then set doc_diem = concat(doc_diem,'Ba');
-- 		when phan_nguyen = 4 then set doc_diem = concat(doc_diem,'Bốn');
-- 		when phan_nguyen = 5 then set doc_diem = concat(doc_diem,'Năm');
-- 		when phan_nguyen = 6 then set doc_diem = concat(doc_diem,'Sáu');
-- 		when phan_nguyen = 7 then set doc_diem = concat(doc_diem,'Bảy');
-- 		when phan_nguyen = 8 then set doc_diem = concat(doc_diem,'Tám');
-- 		when phan_nguyen = 9 then set doc_diem = concat(doc_diem,'Chín');
--     end;
--     set doc_diem = concat(doc_diem,' phẩy ');
--     case
-- 		when phan_thap_phan = 0.0 then set doc_diem = concat(doc_diem,'');
-- 		when phan_thap_phan = 0.1 then set doc_diem = concat(doc_diem,'Một');
-- 		when phan_thap_phan = 0.2 then set doc_diem = concat(doc_diem,'Hai');
-- 		when phan_thap_phan = 0.3 then set doc_diem = concat(doc_diem,'Ba');
-- 		when phan_thap_phan = 0.4 then set doc_diem = concat(doc_diem,'Bốn');
-- 		when phan_thap_phan = 0.5 then set doc_diem = concat(doc_diem,'Năm');
-- 		when phan_thap_phan = 0.6 then set doc_diem = concat(doc_diem,'Sáu');
-- 		when phan_thap_phan = 0.7 then set doc_diem = concat(doc_diem,'Bảy');
-- 		when phan_thap_phan = 0.8 then set doc_diem = concat(doc_diem,'Tám');
-- 		when phan_thap_phan = 0.9 then set doc_diem = concat(doc_diem,'Chín');
--     end;
--     return doc_diem;
-- end //

-- 18.	Tạo thủ tục: HIEN_THI_DIEM Hiển thị danh sách gồm MaSV, HoTen, MaLop, DiemHP, MaHP của những sinh viên có DiemHP nhỏ hơn số chỉ định, nếu không có thì hiển thị thông báo không có sinh viên nào.
-- VD: Call HIEN_THI_DIEM(5);

delimiter //
create procedure HIEN_THI_DIEM(diem float) 
begin
	declare sv int;
    select count(*) into sv from diemhp where DiemHP < diem;
    if sv = 0 then 
		select 'không có sinh viên nào' as ketqua;
    else
		select sv.MaSV,sv.HoTen,sv.MaLop,d.diemhp,d.MaHP from sinhvien sv
        join diemhp d on sv.MaSV = d.MaSV
        where d.DiemHP < diem;
    end if;
end //
//
call HIEN_THI_DIEM(5);

-- 19.	Tạo thủ tục: HIEN_THI_MAHP hiển thị HoTen sinh viên CHƯA học học phần có mã chỉ định. Kiểm tra mã học phần chỉ định có trong danh mục không. Nếu không có thì hiển thị thông báo không có học phần này.
-- Vd: Call HIEN_THI_MAHP(1);

delimiter //
create procedure HIEN_THI_MAHP(ma int)
begin
	declare checkMaHP int;
    select count(*) into checkMaHP from dmhocphan where MaHP = ma;
    if checkMaHP = 0 then
		select 'không có học phần này' as ketqua;
    else 
		select distinct sv.MaSV,sv.HoTen from sinhvien sv
        join diemhp d on sv.MaSV = d.MaSV
        where not d.MaHP = ma; 
    end if;
end //
//
call HIEN_THI_MAHP(1);

-- 20.	Tạo thủ tục: HIEN_THI_TUOI  Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh, GioiTinh, Tuoi của sinh viên có tuổi trong khoảng chỉ định. Nếu không có thì hiển thị không có sinh viên nào.
-- VD: Call HIEN_THI_TUOI (20,30);

delimiter //
create procedure HIEN_THI_TUOI(age_start int,age_end int)
begin
	declare sl int;
    select count(*) into sl from sinhvien where (year(now()) - year(NgaySinh)) between age_start and age_end;
    if sl = 0 then
		select 'không có sinh viên nào' as ketqua;
    else
		select MaSV,HoTen,MaLop,NgaySinh,GioiTinh,(year(now()) - year(NgaySinh)) age from sinhvien 
		where (year(now()) - year(NgaySinh)) between age_start and age_end;
    end if;

	
end //
//
call HIEN_THI_TUOI (20,30);
