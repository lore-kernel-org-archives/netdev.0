From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V2 net-next] net/mlx5: Add MLX5_ARRAY_SET64 to fix
 BUILD_BUG_ON
Date: Wed, 12 Oct 2016 11:50:22 +0300
Message-ID: <20161012085022.GR9282@leon.nu>
References: <1476237430-11756-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="MGmrTRZxVujQoXMz"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1476237430-11756-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--MGmrTRZxVujQoXMz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 12, 2016 at 04:57:10AM +0300, Saeed Mahameed wrote:
> From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
>
> I am hitting this in mlx5:
>
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
> reclaim_pages_cmd.clone.0:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
> to __compiletime_assert_346 declared with attribute error:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function give_pages:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
> to __compiletime_assert_291 declared with attribute error:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64
>
> Problem is that this is doing a BUILD_BUG_ON on a non-constant
> expression because of trying to take offset of pas[i] in the
> structure.
>
> Fix is to create MLX5_ARRAY_SET64 that takes an additional argument
> that is the field index to separate between BUILD_BUG_ON on the array
> constant field and the indexed field to assign the value to.
> There are two callers of MLX5_SET64 that are trying to get a variable
> offset, change those to call MLX5_ARRAY_SET64 passing 'pas' and 'i'
> as the arguments to use in the offset check and the indexed value
> assignment.
>
> Fixes: a533ed5e179cd ("net/mlx5: Pages management commands via mlx5 ifc")
> Signed-off-by: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
>
> Hi Dave,
>
> I hope this version of this patch will make it to -rc1, I made
> some changes to the original version Tom submitted.  Following David Laight
> suggestion to separate the array index from the constant array field to have
> a more natural API.
>
> Thanks,
> Saeed.
>
>
>  drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c |  4 ++--
>  include/linux/mlx5/device.h                         | 13 +++++++++++--
>  2 files changed, 13 insertions(+), 4 deletions(-)

Hi Dave and Doug,

Any chances that this fix will be forwarded to Linus in merge window?

I don't know if you (Dave) had in mind to send additional pull request to
Linus in this merge window, but Doug is definitely planning, and it will
be awesome if it includes this fix in it.

Thanks

>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> index d458515..cc4fd61 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> @@ -287,7 +287,7 @@ retry:
>
>  			goto retry;
>  		}
> -		MLX5_SET64(manage_pages_in, in, pas[i], addr);
> +		MLX5_ARRAY_SET64(manage_pages_in, in, pas, i, addr);
>  	}
>
>  	MLX5_SET(manage_pages_in, in, opcode, MLX5_CMD_OP_MANAGE_PAGES);
> @@ -344,7 +344,7 @@ static int reclaim_pages_cmd(struct mlx5_core_dev *dev,
>  		if (fwp->func_id != func_id)
>  			continue;
>
> -		MLX5_SET64(manage_pages_out, out, pas[i], fwp->addr);
> +		MLX5_ARRAY_SET64(manage_pages_out, out, pas, i, fwp->addr);
>  		i++;
>  	}
>
> diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
> index 77c1417..5827614 100644
> --- a/include/linux/mlx5/device.h
> +++ b/include/linux/mlx5/device.h
> @@ -92,12 +92,21 @@ __mlx5_mask(typ, fld))
>  	___t; \
>  })
>
> -#define MLX5_SET64(typ, p, fld, v) do { \
> +#define __MLX5_SET64(typ, p, fld, v) do { \
>  	BUILD_BUG_ON(__mlx5_bit_sz(typ, fld) != 64); \
> -	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
>  	*((__be64 *)(p) + __mlx5_64_off(typ, fld)) = cpu_to_be64(v); \
>  } while (0)
>
> +#define MLX5_SET64(typ, p, fld, v) do { \
> +	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
> +	__MLX5_SET64(typ, p, fld, v); \
> +} while (0)
> +
> +#define MLX5_ARRAY_SET64(typ, p, fld, idx, v) do { \
> +	BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
> +	__MLX5_SET64(typ, p, fld[idx], v); \
> +} while (0)
> +
>  #define MLX5_GET64(typ, p, fld) be64_to_cpu(*((__be64 *)(p) + __mlx5_64_off(typ, fld)))
>
>  #define MLX5_GET64_PR(typ, p, fld) ({ \
> --
> 2.7.4
>

--MGmrTRZxVujQoXMz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX/flNAAoJEORje4g2clin9nAQAM3Wi9V0zuE6rnFJ5a1poGZ6
UypLXtFE7uE3EHecD6yTdxwb5a2MVJckqUGZmX2PTRhSZqy4q0YAAChpqvlkHE2D
gCDcCLY3R0cdhcq+z8oFRrkuELyg4/GPEnMngwDPXcGFKe2js1oOzMUi2WBO6zc2
NmMRggYR3VRBc4gYzZgwZmIcvyVRrmULzDcDe8dpReLoov3My8NCSCDYm7whJ2nh
nJAkiAyPdmkKKc4Du2bECkw9aXby8MZ3J1oQXTrV/13UJZU+KOO8JoI+zrHlvglZ
ViKjleny70fZIwn/pK1nPotNLcZ5IDGawGQ68Exl8dMkowmU6j572moBJc4cGxvU
AMtuDVNgV+CWTh3zzadoYAXda24Xn8AD20SHx9HF6t09e72PkCmfqVK/MjGSmqNH
q2eWi4TYOrdCi3zhQa55oMXLmO0gBSISkDTSWAZfGXFOBVL+LFEvyLJOBsDBd5MG
oPzz3DIIOa0js3UOK8zssdqY5ahXo6Ps4rbddV7As4/yt+iEAEo2JLpYwF0+Lkuo
D6DEAkXKU8C3w3wULRqouupXdZJ9DIEM2bWpunvixfQYXJr4V/XuOf16XZZw9vHR
r8GByz6HoE/qSwFOD4H2Bn5mEkljmldh9yiTdwVk/LWdHcj5O+27eKSPE1Q1H9EA
bLj0qQiDDsf0uchqxqtc
=BYzO
-----END PGP SIGNATURE-----

--MGmrTRZxVujQoXMz--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
