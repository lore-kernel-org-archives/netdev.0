From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] net/mlx5: fpga: avoid uninitialized return codes
Date: Thu, 14 Sep 2017 11:39:20 -0700
Message-ID: <CALzJLG9jkmQVH-C2qCtYBns1=E0-wjVOq2mvJ76sgUiWCx=+Wg@mail.gmail.com>
References: <20170914110628.3590833-1-arnd@arndb.de> <20170914125429.GZ3405@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170914125429.GZ3405@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 5:54 AM, Leon Romanovsky <leonro@mellanox.com> wrot=
e:
> On Thu, Sep 14, 2017 at 01:06:18PM +0200, Arnd Bergmann wrote:
>> calling mlx5_fpga_mem_{read,write}_i2c() with a zero length on
>> older compiler version such as gcc-4.6 results in a warning that
>> the return code is not initialized:
>>
>> drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:147:6: error: =E2=80=
=98err=E2=80=99 may be used uninitialized in this function [-Werror=3Dunini=
tialized]
>> drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:126:6: error: =E2=80=
=98err=E2=80=99 may be used uninitialized in this function [-Werror=3Dunini=
tialized]
>>
>> On newer compilers, the 'err' variable is optimized away in this
>> code path and assumed to be zero when the loop completes, so we
>> don't get this warning.
>>
>> I'm changing the function here to instead return -EINVAL for the
>> case, under the assumption that it was never meant to be called
>> with a zero length argument.

Thanks Arnd, Looks good.

>
> I agree with you that size can't be zero and this patch will fix the
> warning, but if it is possible, I will prefer to have this check is
> written explicitly and not implicitly.
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c b/drivers=
/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> index 3c11d6e2160a..0e85bebe1dad 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> @@ -69,6 +69,9 @@ static int mlx5_fpga_mem_read_i2c(struct mlx5_fpga_devi=
ce *fdev, size_t size,
>         if (!fdev->mdev)
>                 return -ENOTCONN;
>
> +       if (!size)
> +               return -EINVAL;
> +

Or simply trust the caller :), and avoid redundant code.

>         while (bytes_done < size) {
>                 actual_size =3D min(max_size, (size - bytes_done));
>
> Thanks
>
>>
>> Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D82203
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c b/driver=
s/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
>> index 3c11d6e2160a..914fb9d77a1a 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
>> @@ -64,7 +64,7 @@ static int mlx5_fpga_mem_read_i2c(struct mlx5_fpga_dev=
ice *fdev, size_t size,
>>       size_t max_size =3D MLX5_FPGA_ACCESS_REG_SIZE_MAX;
>>       size_t bytes_done =3D 0;
>>       u8 actual_size;
>> -     int err;
>> +     int err =3D -EINVAL;
>>
>>       if (!fdev->mdev)
>>               return -ENOTCONN;
>> @@ -93,7 +93,7 @@ static int mlx5_fpga_mem_write_i2c(struct mlx5_fpga_de=
vice *fdev, size_t size,
>>       size_t max_size =3D MLX5_FPGA_ACCESS_REG_SIZE_MAX;
>>       size_t bytes_done =3D 0;
>>       u8 actual_size;
>> -     int err;
>> +     int err =3D -EINVAL;
>>
>>       if (!fdev->mdev)
>>               return -ENOTCONN;
>> --
>> 2.9.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
