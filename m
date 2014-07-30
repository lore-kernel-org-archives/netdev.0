From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/2] rcar_can: add device tree support
Date: Wed, 30 Jul 2014 09:38:23 +0200
Message-ID: <53D8A0EF.7060903@pengutronix.de>
References: <201407300253.42491.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="rq23u4nhKIUkTlQfnOCHkcb6cqd8jb3dr"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, robh+dt@kernel.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201407300253.42491.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rq23u4nhKIUkTlQfnOCHkcb6cqd8jb3dr
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/30/2014 12:53 AM, Sergei Shtylyov wrote:
> Add support of the device tree probing for the Renesas R-Car CAN contro=
llers.
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against the 'linux-can-next.git' repo plus the CAN clock h=
andling
> patch I've just posted.
>=20
> Changes in version 2:
> - split the device tree bindings document into a separate patch;
> - replaced 0 with CLKR_CLKP1 in the 'clock_select' variable intializer
> - reversed the condition in the *if* stetement handling the reading of =
the
>   CAN clock selector from the device tree or the paltfrom data;
> - renamed the "clock-select" property to "renesas,can-clock-select";
> - rebased the patch on top of the CAN clock handling fix.
>=20
>  drivers/net/can/rcar_can.c |   33 +++++++++++++++++++++++++--------
>  1 file changed, 25 insertions(+), 8 deletions(-)
>=20
> Index: linux-can-next/drivers/net/can/rcar_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/rcar_can.c
> +++ linux-can-next/drivers/net/can/rcar_can.c
> @@ -20,6 +20,7 @@
>  #include <linux/can/dev.h>
>  #include <linux/clk.h>
>  #include <linux/can/platform/rcar_can.h>
> +#include <linux/of.h>
> =20
>  #define RCAR_CAN_DRV_NAME	"rcar_can"
> =20
> @@ -738,13 +739,20 @@ static int rcar_can_probe(struct platfor
>  	struct net_device *ndev;
>  	struct resource *mem;
>  	void __iomem *addr;
> +	u32 clock_select =3D CLKR_CLKP1;

If you introduce the variable clock_select in the patch "rcar_can:
support all input clocks", this diff would be smaller.

>  	int err =3D -ENODEV;
>  	int irq;
> =20
> -	pdata =3D dev_get_platdata(&pdev->dev);
> -	if (!pdata) {
> -		dev_err(&pdev->dev, "No platform data provided!\n");
> -		goto fail;
> +	if (pdev->dev.of_node) {
> +		of_property_read_u32(pdev->dev.of_node,
> +				     "renesas,can-clock-select", &clock_select);
> +	} else {
> +		pdata =3D dev_get_platdata(&pdev->dev);
> +		if (!pdata) {
> +			dev_err(&pdev->dev, "No platform data provided!\n");
> +			goto fail;
> +		}
> +		clock_select =3D pdata->clock_select;
>  	}
> =20
>  	irq =3D platform_get_irq(pdev, 0);
> @@ -776,13 +784,12 @@ static int rcar_can_probe(struct platfor
>  		goto fail_clk;
>  	}
> =20
> -	if (pdata->clock_select > CLKR_CLKEXT) {
> +	if (clock_select > CLKR_CLKEXT) {
>  		err =3D -EINVAL;
>  		dev_err(&pdev->dev, "invalid CAN clock selected\n");
>  		goto fail_clk;
>  	}
> -	priv->can_clk =3D devm_clk_get(&pdev->dev,
> -				     clock_names[pdata->clock_select]);
> +	priv->can_clk =3D devm_clk_get(&pdev->dev, clock_names[clock_select])=
;
>  	if (IS_ERR(priv->can_clk)) {
>  		err =3D PTR_ERR(priv->can_clk);
>  		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
> @@ -794,7 +801,7 @@ static int rcar_can_probe(struct platfor
>  	ndev->flags |=3D IFF_ECHO;
>  	priv->ndev =3D ndev;
>  	priv->regs =3D addr;
> -	priv->clock_select =3D pdata->clock_select;
> +	priv->clock_select =3D clock_select;
>  	priv->can.clock.freq =3D clk_get_rate(priv->can_clk);
>  	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
>  	priv->can.do_set_mode =3D rcar_can_do_set_mode;
> @@ -887,10 +894,20 @@ static int __maybe_unused rcar_can_resum
> =20
>  static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_r=
esume);
> =20
> +static const struct of_device_id rcar_can_of_table[] __maybe_unused =3D=
 {
> +	{ .compatible =3D "renesas,can-r8a7778" },
> +	{ .compatible =3D "renesas,can-r8a7779" },
> +	{ .compatible =3D "renesas,can-r8a7790" },
> +	{ .compatible =3D "renesas,can-r8a7791" },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, rcar_can_of_table);
> +
>  static struct platform_driver rcar_can_driver =3D {
>  	.driver =3D {
>  		.name =3D RCAR_CAN_DRV_NAME,
>  		.owner =3D THIS_MODULE,
> +		.of_match_table =3D of_match_ptr(rcar_can_of_table),
>  		.pm =3D &rcar_can_pm_ops,
>  	},
>  	.probe =3D rcar_can_probe,
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--rq23u4nhKIUkTlQfnOCHkcb6cqd8jb3dr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPYoO8ACgkQjTAFq1RaXHM54QCePaaURomLxae22K2+GbVixfCE
oYMAni1pOSPt2heG8siViLQUyakTkRwx
=vs5x
-----END PGP SIGNATURE-----

--rq23u4nhKIUkTlQfnOCHkcb6cqd8jb3dr--
