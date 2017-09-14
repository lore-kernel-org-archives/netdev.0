From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] net/mlx5: fpga: avoid uninitialized return codes
Date: Thu, 14 Sep 2017 15:54:29 +0300
Message-ID: <20170914125429.GZ3405@mtr-leonro.local>
References: <20170914110628.3590833-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="IpgPcFyQO6wM49Um"
Cc: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170914110628.3590833-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IpgPcFyQO6wM49Um
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 14, 2017 at 01:06:18PM +0200, Arnd Bergmann wrote:
> calling mlx5_fpga_mem_{read,write}_i2c() with a zero length on
> older compiler version such as gcc-4.6 results in a warning that
> the return code is not initialized:
>
> drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:147:6: error: =E2=80=
=98err=E2=80=99 may be used uninitialized in this function [-Werror=3Dunini=
tialized]
> drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c:126:6: error: =E2=80=
=98err=E2=80=99 may be used uninitialized in this function [-Werror=3Dunini=
tialized]
>
> On newer compilers, the 'err' variable is optimized away in this
> code path and assumed to be zero when the loop completes, so we
> don't get this warning.
>
> I'm changing the function here to instead return -EINVAL for the
> case, under the assumption that it was never meant to be called
> with a zero length argument.

I agree with you that size can't be zero and this patch will fix the
warning, but if it is possible, I will prefer to have this check is
written explicitly and not implicitly.

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c b/drivers/n=
et/ethernet/mellanox/mlx5/core/fpga/sdk.c
index 3c11d6e2160a..0e85bebe1dad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
@@ -69,6 +69,9 @@ static int mlx5_fpga_mem_read_i2c(struct mlx5_fpga_device=
 *fdev, size_t size,
 	if (!fdev->mdev)
 		return -ENOTCONN;

+	if (!size)
+		return -EINVAL;
+
 	while (bytes_done < size) {
 		actual_size =3D min(max_size, (size - bytes_done));

Thanks

>
> Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D82203
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c b/drivers=
/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> index 3c11d6e2160a..914fb9d77a1a 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fpga/sdk.c
> @@ -64,7 +64,7 @@ static int mlx5_fpga_mem_read_i2c(struct mlx5_fpga_devi=
ce *fdev, size_t size,
>  	size_t max_size =3D MLX5_FPGA_ACCESS_REG_SIZE_MAX;
>  	size_t bytes_done =3D 0;
>  	u8 actual_size;
> -	int err;
> +	int err =3D -EINVAL;
>
>  	if (!fdev->mdev)
>  		return -ENOTCONN;
> @@ -93,7 +93,7 @@ static int mlx5_fpga_mem_write_i2c(struct mlx5_fpga_dev=
ice *fdev, size_t size,
>  	size_t max_size =3D MLX5_FPGA_ACCESS_REG_SIZE_MAX;
>  	size_t bytes_done =3D 0;
>  	u8 actual_size;
> -	int err;
> +	int err =3D -EINVAL;
>
>  	if (!fdev->mdev)
>  		return -ENOTCONN;
> --
> 2.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--IpgPcFyQO6wM49Um
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlm6fAUACgkQ5GN7iDZy
WKcggBAA0nppc0PI4rydZ7PPdpYO1q3PsVdQnP3RqW5JMeyPvQ7UHUZ7IY3jNTf7
WvkZ0hFwu0G9lCRDGW10dOiyc1I/JEq14IcvmmSLHqCJkXIHz/WF+i65WgJf5HsM
uF8LkaexcmW9RGMGpa73K+TVef+bKXWBkX2ZgnpYDDWwBj6gy2JrXoGqCeuo4U8x
Or6SwWMa0Nsrv4IIw+EZ0Y9kgGWfHKdO6T28uM75nG+KSU5x9bMF0RKW1FF+FjoA
Ux9SgULYU+p8v8vRYOPfFTn0B0XhOdeBOtaeYF5NiFGdeJCOWCTDpslabKFCd8cN
dXb8HYfRSuARkLSvfkDXp7VCvcFEyEbqN2H4KnwnefuRTzCPn842Pf9MBEzAR8xP
RR8JpiXxDvBMoP3vmw3ZYCH3LW6s4gtzpoX/FIvN/iYRz5ooxQxUY5tQLg0kNgdP
RfyqonywA615pcya1YKHFzJPElaotOy1GODZo8TOI0lnbhYqiq4m/DQPtNUi+6J6
TPMuqfY+hFz8dCnN6ID1QicTr6T1w/LcuQZHb6GTSp6XSG51s0dKvHOCazaw/T7E
T+0jvIi93Ms+bCTX4E+5Ekofk8fkeLAiVmjXsRJPCxRJD2wONPIEb4LTKa9aS2I9
Q3WNEPs5P/im5jdUwvFFN5Lxiv4pXsL9eWC9h+XxAw8oVHrDsrU=
=cgP6
-----END PGP SIGNATURE-----

--IpgPcFyQO6wM49Um--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
