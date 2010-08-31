From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 3/4] drivers/net/can/mscan/mpc5xxx_can.c: Add
	of_node_put to avoid memory leak
Date: Tue, 31 Aug 2010 18:51:53 +0200
Message-ID: <20100831165153.GB28015@pengutronix.de>
References: <1283269738-14612-1-git-send-email-julia@diku.dk>
	<1283269738-14612-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8479470578440435896=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1283269738-14612-4-git-send-email-julia-dAYI7NvHqcQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============8479470578440435896==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TRYliJ5NKNqkz5bu"
Content-Disposition: inline


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 31, 2010 at 05:48:57PM +0200, Julia Lawall wrote:
> Add a call to of_node_put in the error handling code following a call to
> of_find_matching_node.
>=20
> This patch also moves the existing call to of_node_put after the call to
> iounmap in the error handling code, to make it possible to jump to
> of_node_put without doing iounmap.  These appear to be disjoint operation=
s,
> so the ordering doesn't matter.

Hmm, the function you change returns -ENODEV if a clock cannot be found, but
the return type is u32. This should better be 0. Can you take care of this =
as
well? You could then add my

Reviewed-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

>=20
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
>=20
> // <smpl>
> @r exists@
> local idexpression x;
> expression E,E1,E2;
> statement S;
> @@
>=20
> *x =3D=20
> (of_find_node_by_path
> |of_find_node_by_name
> |of_find_node_by_phandle
> |of_get_parent
> |of_get_next_parent
> |of_get_next_child
> |of_find_compatible_node
> |of_match_node
> |of_find_node_by_type
> |of_find_node_with_property
> |of_find_matching_node
> |of_parse_phandle
> )(...);
> ...
> if (x =3D=3D NULL) S
> <... when !=3D x =3D E
> *if (...) {
>   ... when !=3D of_node_put(x)
>       when !=3D if (...) { ... of_node_put(x); ... }
> (
>   return <+...x...+>;
> |
> *  return ...;
> )
> }
> ...>
> (
> E2 =3D x;
> |
> of_node_put(x);
> )
> // </smpl>
>=20
> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
>=20
> ---
>  drivers/net/can/mscan/mpc5xxx_can.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/=
mpc5xxx_can.c
> index b1bdc90..883959c 100644
> --- a/drivers/net/can/mscan/mpc5xxx_can.c
> +++ b/drivers/net/can/mscan/mpc5xxx_can.c
> @@ -148,7 +148,7 @@ static u32 __devinit mpc512x_can_get_clock(struct pla=
tform_device *ofdev,
>  	clockctl =3D of_iomap(np_clock, 0);
>  	if (!clockctl) {
>  		dev_err(&ofdev->dev, "couldn't map clock registers\n");
> -		return 0;
> +		goto exit_put;
>  	}
> =20
>  	/* Determine the MSCAN device index from the physical address */
> @@ -233,9 +233,9 @@ static u32 __devinit mpc512x_can_get_clock(struct pla=
tform_device *ofdev,
>  		clocksrc =3D=3D 1 ? "ref_clk" : "sys_clk", clockdiv);
> =20
>  exit_unmap:
> -	of_node_put(np_clock);
>  	iounmap(clockctl);
> -
> +exit_put:
> +	of_node_put(np_clock);
>  	return freq;
>  }
>  #else /* !CONFIG_PPC_MPC512x */
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--TRYliJ5NKNqkz5bu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkx9MykACgkQD27XaX1/VRubzACfaCkhvqrY6XSE/ZDxk9k1FBpX
PEsAoK0Sb556YfxOxsTXWFk1FAU13FuK
=8Ak8
-----END PGP SIGNATURE-----

--TRYliJ5NKNqkz5bu--

--===============8479470578440435896==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============8479470578440435896==--
