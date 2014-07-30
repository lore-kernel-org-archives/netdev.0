From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] rcar_can: support all input clocks
Date: Wed, 30 Jul 2014 09:32:14 +0200
Message-ID: <53D89F7E.3020204@pengutronix.de>
References: <201407300145.34797.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XQaiERijwWQOKa7U750hwJpR4W2EOvswA"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <201407300145.34797.sergei.shtylyov@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XQaiERijwWQOKa7U750hwJpR4W2EOvswA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/29/2014 11:45 PM, Sergei Shtylyov wrote:
> When writing the driver, I didn't give enough attention to the possible=
 sources
> of the CAN clock: although the value of the CLKR register was specified=
 by  the
> platform data, the driver only handled one case, that is CAN clock bein=
g sourced
> from the clkp1 clock, the same that clocks the whole CAN module. In ord=
er to fix
> that overlook, we'll have to handle the CAN clock separately from the p=
eripheral
> clock (however, clkp1 will be specified for a CAN device only once)...
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Looks good, nitpick inline:
>=20
> ---
> The patch is against the 'linux-can-next.git' repo, however it's a fix,=
 not a
> cleanup.
>=20
>  drivers/net/can/rcar_can.c |   39 ++++++++++++++++++++++++++++++++++--=
---
>  1 file changed, 34 insertions(+), 5 deletions(-)
>=20
> Index: linux-can-next/drivers/net/can/rcar_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/rcar_can.c
> +++ linux-can-next/drivers/net/can/rcar_can.c
> @@ -87,6 +87,7 @@ struct rcar_can_priv {
>  	struct napi_struct napi;
>  	struct rcar_can_regs __iomem *regs;
>  	struct clk *clk;
> +	struct clk *can_clk;
>  	u8 tx_dlc[RCAR_CAN_FIFO_DEPTH];
>  	u32 tx_head;
>  	u32 tx_tail;
> @@ -505,14 +506,20 @@ static int rcar_can_open(struct net_devi
> =20
>  	err =3D clk_prepare_enable(priv->clk);
>  	if (err) {
> -		netdev_err(ndev, "clk_prepare_enable() failed, error %d\n",
> +		netdev_err(ndev, "failed to enable periperal clock, error %d\n",
>  			   err);
>  		goto out;
>  	}
> +	err =3D clk_prepare_enable(priv->can_clk);
> +	if (err) {
> +		netdev_err(ndev, "failed to enable CAN clock, error %d\n",
> +			   err);
> +		goto out_clock;
> +	}
>  	err =3D open_candev(ndev);
>  	if (err) {
>  		netdev_err(ndev, "open_candev() failed, error %d\n", err);
> -		goto out_clock;
> +		goto out_can_clock;
>  	}
>  	napi_enable(&priv->napi);
>  	err =3D request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, nde=
v);
> @@ -527,6 +534,8 @@ static int rcar_can_open(struct net_devi
>  out_close:
>  	napi_disable(&priv->napi);
>  	close_candev(ndev);
> +out_can_clock:
> +	clk_disable_unprepare(priv->can_clk);
>  out_clock:
>  	clk_disable_unprepare(priv->clk);
>  out:
> @@ -565,6 +574,7 @@ static int rcar_can_close(struct net_dev
>  	rcar_can_stop(ndev);
>  	free_irq(ndev->irq, ndev);
>  	napi_disable(&priv->napi);
> +	clk_disable_unprepare(priv->can_clk);
>  	clk_disable_unprepare(priv->clk);
>  	close_candev(ndev);
>  	can_led_event(ndev, CAN_LED_EVENT_STOP);
> @@ -715,6 +725,12 @@ static int rcar_can_get_berr_counter(con
>  	return 0;
>  }
> =20
> +static const char * const clock_names[] =3D {
> +	[CLKR_CLKP1]	=3D "clkp1",
> +	[CLKR_CLKP2]	=3D "clkp2",
> +	[CLKR_CLKEXT]	=3D "can_clk",
> +};
> +
>  static int rcar_can_probe(struct platform_device *pdev)
>  {
>  	struct rcar_can_platform_data *pdata;
> @@ -753,10 +769,23 @@ static int rcar_can_probe(struct platfor
> =20
>  	priv =3D netdev_priv(ndev);
> =20
> -	priv->clk =3D devm_clk_get(&pdev->dev, NULL);
> +	priv->clk =3D devm_clk_get(&pdev->dev, "clkp1");
>  	if (IS_ERR(priv->clk)) {
>  		err =3D PTR_ERR(priv->clk);
> -		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
> +		dev_err(&pdev->dev, "cannot get peripheral clock: %d\n", err);
> +		goto fail_clk;
> +	}
> +
> +	if (pdata->clock_select > CLKR_CLKEXT) {

Please use ARRAY_SIZE instead of CLKR_CLKEXT.

> +		err =3D -EINVAL;
> +		dev_err(&pdev->dev, "invalid CAN clock selected\n");
> +		goto fail_clk;
> +	}
> +	priv->can_clk =3D devm_clk_get(&pdev->dev,
> +				     clock_names[pdata->clock_select]);
> +	if (IS_ERR(priv->can_clk)) {
> +		err =3D PTR_ERR(priv->can_clk);
> +		dev_err(&pdev->dev, "cannot get CAN clock: %d\n", err);
>  		goto fail_clk;
>  	}
> =20
> @@ -766,7 +795,7 @@ static int rcar_can_probe(struct platfor
>  	priv->ndev =3D ndev;
>  	priv->regs =3D addr;
>  	priv->clock_select =3D pdata->clock_select;
> -	priv->can.clock.freq =3D clk_get_rate(priv->clk);
> +	priv->can.clock.freq =3D clk_get_rate(priv->can_clk);
>  	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
>  	priv->can.do_set_mode =3D rcar_can_do_set_mode;
>  	priv->can.do_get_berr_counter =3D rcar_can_get_berr_counter;
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--XQaiERijwWQOKa7U750hwJpR4W2EOvswA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlPYn34ACgkQjTAFq1RaXHPPVwCgmN7VYtORYKKQcGmIq+vVDA3s
O9UAn0AUEON6GeEJb3h9y6t1BVrKw12Y
=S9BB
-----END PGP SIGNATURE-----

--XQaiERijwWQOKa7U750hwJpR4W2EOvswA--
