From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 02/16] c_can: add generic D-CAN RAM initialization support
Date: Mon, 09 Sep 2013 10:34:27 +0200
Message-ID: <522D8813.1030806@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-3-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xgPwsapLXs9ogtMxPq1CNmlnjJISbiac4"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	AnilKumar Ch <anilkumar@ti.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-3-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xgPwsapLXs9ogtMxPq1CNmlnjJISbiac4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:24 AM, Benedikt Spranger wrote:
> D-CAN provides an automatic RAM initialization. The initialization can =
be
> executed while D-CAN is in the init state.
>=20
> It should be checked if this is compatible with TI's d_can implementati=
on
> which does not have or does not use this bit which is here according to=
 the
> d_can specification.

Added AnilKumar Ch to the loop, who contributed the d_can support for
TI. Bene please collect a Tested-by for this patch.

Marc

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 38 +++++++++++++++++++++++++++++++++++=
+--
>  drivers/net/can/c_can/c_can.h |  2 ++
>  2 files changed, 38 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index a668cd4..081620b 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -68,6 +68,8 @@
>  #define TEST_SILENT		BIT(3)
>  #define TEST_BASIC		BIT(2)
> =20
> +#define FUNC_RAMINIT		BIT(3)
> +
>  /* status register */
>  #define STATUS_PDA		BIT(10)
>  #define STATUS_BOFF		BIT(7)
> @@ -573,6 +575,7 @@ static int c_can_set_bittiming(struct net_device *d=
ev)
>  	u32 ten_bit_brp;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +	int retry;
> =20
>  	/* c_can provides a 6-bit brp and 4-bit brpe fields */
>  	ten_bit_brp =3D bt->brp - 1;
> @@ -590,11 +593,42 @@ static int c_can_set_bittiming(struct net_device =
*dev)
>  		"setting BTR=3D%04x BRPE=3D%04x\n", reg_btr, reg_brpe);
> =20
>  	ctrl_save =3D priv->read_reg(priv, C_CAN_CTRL_REG);
> -	priv->write_reg(priv, C_CAN_CTRL_REG,
> -			ctrl_save | CONTROL_CCE | CONTROL_INIT);
> +	ctrl_save &=3D ~CONTROL_INIT;
> +
> +	priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_CCE | CONTROL_INIT);
> +	retry =3D 1000;
> +	while (!(priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT)) {
> +		if (!retry) {
> +			netdev_info(dev, "CCTRL: set CONTROL_INIT failed\n");
> +			return -EIO;
> +		}
> +		udelay(10);
> +		retry--;
> +	}
>  	priv->write_reg(priv, C_CAN_BTR_REG, reg_btr);
>  	priv->write_reg(priv, C_CAN_BRPEXT_REG, reg_brpe);
> +
> +	priv->write_reg(priv, C_CAN_FUNC_REG, FUNC_RAMINIT);
> +	retry =3D 1000;
> +	while (priv->read_reg(priv, C_CAN_FUNC_REG) & FUNC_RAMINIT) {
> +		if (!retry) {
> +			netdev_info(dev, "CFR: FUNC_RAMINIT failed\n");
> +			return -EIO;
> +		}
> +		udelay(10);
> +		retry--;
> +	}
> +
>  	priv->write_reg(priv, C_CAN_CTRL_REG, ctrl_save);
> +	retry =3D 1000;
> +	while (priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT) {
> +		if (!retry) {
> +			netdev_info(dev, "CCTRL: clear CONTROL_INIT failed\n");
> +			return -EIO;
> +		}
> +		udelay(10);
> +		retry--;
> +	}
> =20
>  	return 0;
>  }
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index d2e2d20..9f0eda8 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -61,6 +61,7 @@ enum reg {
>  	C_CAN_INTPND2_REG,
>  	C_CAN_MSGVAL1_REG,
>  	C_CAN_MSGVAL2_REG,
> +	C_CAN_FUNC_REG,
>  };
> =20
>  static const u16 reg_map_c_can[] =3D {
> @@ -112,6 +113,7 @@ static const u16 reg_map_d_can[] =3D {
>  	[C_CAN_BRPEXT_REG]	=3D 0x0E,
>  	[C_CAN_INT_REG]		=3D 0x10,
>  	[C_CAN_TEST_REG]	=3D 0x14,
> +	[C_CAN_FUNC_REG]	=3D 0x18,
>  	[C_CAN_TXRQST1_REG]	=3D 0x88,
>  	[C_CAN_TXRQST2_REG]	=3D 0x8A,
>  	[C_CAN_NEWDAT1_REG]	=3D 0x9C,
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xgPwsapLXs9ogtMxPq1CNmlnjJISbiac4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItiBMACgkQjTAFq1RaXHNt/ACdFKyd1YZVg6l9f51GTaWyxC0K
WC4AoJgbHgVcpVjgTyAsig6ue/wrT4JO
=a0ri
-----END PGP SIGNATURE-----

--xgPwsapLXs9ogtMxPq1CNmlnjJISbiac4--
