-- ==========================================
-- 1. Create database
-- ==========================================

create database financial_performance;
use financial_performance;


-- ==========================================
-- 2. Create customers table
-- ==========================================

create table customers (
    customer_id varchar(20) not null,
    customer_name varchar(150) not null,
    segment varchar(50) not null,
    join_date date not null,
    region varchar(50) not null,
    status varchar(20) not null,

    constraint pk_customers
        primary key (customer_id),

    constraint ck_customers_status
        check (status in ('active', 'inactive'))
);


-- ==========================================
-- 3. Create vendors table
-- ==========================================

create table vendors (
    vendor_id varchar(20) not null,
    vendor_name varchar(150) not null,
    category varchar(50) not null,
    region varchar(50) not null,
    active char(1) not null,

    constraint pk_vendors
        primary key (vendor_id),

    constraint ck_vendors_active
        check (active in ('y', 'n'))
);


-- ==========================================
-- 4. Create headcount table
-- ==========================================

create table headcount (
    employee_id varchar(20) not null,
    employee_name varchar(150) not null,
    business_unit varchar(50) not null,
    join_date date not null,
    status varchar(20) not null,
    region varchar(50) not null,
    cost_to_company int not null,

    constraint pk_headcount
        primary key (employee_id),

    constraint ck_headcount_status
        check (status in ('active', 'inactive')),

    constraint ck_headcount_cost
        check (cost_to_company >= 0)
);


-- ==========================================
-- 5. Create budget table
-- ==========================================

create table budget (
    year int not null,
    month int not null,
    business_unit varchar(50) not null,
    budgeted_revenue int not null,
    budgeted_expense int not null,

    constraint pk_budget
        primary key (year, month, business_unit),

    constraint ck_budget_month
        check (month between 1 and 12),

    constraint ck_budget_revenue
        check (budgeted_revenue >= 0),

    constraint ck_budget_expense
        check (budgeted_expense >= 0)
);


-- ==========================================
-- 6. Create financial transactions table
-- ==========================================

create table financial_transactions (
    transaction_id varchar(20) not null,
    transaction_date date not null,
    amount decimal(18,2) not null,
    account_type varchar(20) not null,
    category varchar(50) not null,
    business_unit varchar(50) not null,
    region varchar(50) not null,
    customer_id varchar(20),
    vendor_id varchar(20),
    description varchar(500),

    constraint pk_financial_transactions
        primary key (transaction_id),

    constraint fk_transactions_customer
        foreign key (customer_id)
        references customers(customer_id),

    constraint fk_transactions_vendor
        foreign key (vendor_id)
        references vendors(vendor_id),

    constraint ck_transactions_accounttype
        check (account_type in
            ('revenue', 'expense', 'asset', 'liability', 'equity'))
);

show tables;

-- ==========================================
-- 7. Load customers data
-- ==========================================

load data local infile "E:/Capstone projects/Financial Performance Analysis/Dataset - Financial Performance Analysis/Customers.csv"
into table customers
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
	customer_id,
    customer_name,
    segment,
    join_date,
    region,
    status
);

-- ==========================================
-- 8. Load vendors data
-- ==========================================

load data local infile "E:/Capstone projects/Financial Performance Analysis/Dataset - Financial Performance Analysis/Vendors.csv"
into table vendors
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
	vendor_id,
    vendor_name,
    category,
    region,
    active
);

-- ==========================================
-- 9. Load financial transactions data
-- ==========================================

load data local infile "E:/Capstone projects/Financial Performance Analysis/Dataset - Financial Performance Analysis/Financial_Transactions.csv"
into table financial_transactions
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
    transaction_id,
    transaction_date,
    amount,
    account_type,
    category,
    business_unit,
    region,
    @customer_id,
    @vendor_id,
    description
)
set
    customer_id = nullif(@customer_id, ''),
    vendor_id = nullif(@vendor_id, '');
    
    
-- ==========================================
-- 10. Load headcount data
-- ==========================================

load data local infile "E:/Capstone projects/Financial Performance Analysis/Dataset - Financial Performance Analysis/Headcount.csv"
into table headcount
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
	employee_id,
    employee_name,
    business_unit,
    join_date,
    status,
    region,
    cost_to_company
);


-- ==========================================
-- 11. Load budget data
-- ==========================================

load data local infile "E:/Capstone projects/Financial Performance Analysis/Dataset - Financial Performance Analysis/Budget.csv"
into table budget
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(
	year,
    month,
    business_unit,
    budgeted_revenue,
    budgeted_expense
);

-- ==========================================
-- Enabling local data loading
-- ==========================================

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- ==========================================
-- 12. Check record counts
-- ==========================================

select count(*) from customers;
select count(*) from vendors;
select count(*) from headcount;
select count(*) from budget;
select count(*) from financial_transactions;


-- ==========================================
-- 13. Check duplicate customer IDs
-- ==========================================

select customer_id,count(*) as count from customers
group by customer_id having count(*)>1;


-- ==========================================
-- 14. Check duplicate vendor IDs
-- ==========================================

select vendor_id,count(*) as count from vendors
group by vendor_id having count(*)>1;


-- ==========================================
-- 15. Check duplicate employee IDs
-- ==========================================

select employee_id,count(*) as count from headcount
group by employee_id having count(*)>1;


-- ==========================================
-- 16. Check duplicate budget combinations
-- ==========================================

select year, month, business_unit,count(*) as count from budget
group by year, month, business_unit having count(*)>1;


-- ==========================================
-- 17. Check duplicate transaction IDs
-- ==========================================

select transaction_id,count(*) as count from financial_transactions
group by transaction_id having count(*)>1;


-- ==========================================
-- 18. Check for orphan customer records
-- ==========================================

select count(*) as orphan_customer_records
from financial_transactions ft
left join customers c
on ft.customer_id = c.customer_id
where ft.customer_id is not null
and c.customer_id is null;


-- ==========================================
-- 19. Check for orphan vendor records
-- ==========================================

select count(*) as orphan_vendor_records
from financial_transactions ft
left join vendors v
on ft.vendor_id = v.vendor_id
where ft.vendor_id is not null
and v.vendor_id is null;


-- ==========================================
-- 20. Preview financial transactions
-- ==========================================

select *
from financial_transactions
limit 10;