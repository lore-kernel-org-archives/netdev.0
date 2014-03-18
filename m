From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 01/12] can: c_can: Wait for CONTROL_INIT to be cleared
Date: Tue, 18 Mar 2014 19:11:19 +0100
Message-ID: <53288C47.5090308@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171126.593414691@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4irx6vuafGuJchm5gtKwoUuUJsCquUFqm"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140318171126.593414691@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4irx6vuafGuJchm5gtKwoUuUJsCquUFqm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/18/2014 06:19 PM, Thomas Gleixner wrote:
> According to the documentation the CPU must wait for CONTROL_INIT to
> be cleared before writing to the baudrate registers.

Thanks for the catch.

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>
> ---
>  drivers/net/can/c_can/c_can.c |   26 +++++++++++++++++++++++---
>  1 file changed, 23 insertions(+), 3 deletions(-)
>=20
> Index: linux/drivers/net/can/c_can/c_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/drivers/net/can/c_can/c_can.c
> +++ linux/drivers/net/can/c_can/c_can.c
> @@ -566,6 +566,21 @@ static netdev_tx_t c_can_start_xmit(stru
>  	return NETDEV_TX_OK;
>  }
> =20
> +static int c_can_wait_for_ctrl_init(struct net_device *dev,
> +				    struct c_can_priv *priv, u32 init)
> +{
> +	int retry =3D 0;
> +
> +	while (init !=3D (priv->read_reg(priv, C_CAN_CTRL_REG) & CONTROL_INIT=
)) {
> +		udelay(10);
> +		if (retry++ > 1000) {
> +			netdev_err(dev, "CCTRL: set CONTROL_INIT failed\n");
> +			return -EIO;
> +		}
> +	}
> +	return 0;
> +}
> +
>  static int c_can_set_bittiming(struct net_device *dev)
>  {
>  	unsigned int reg_btr, reg_brpe, ctrl_save;
> @@ -573,6 +588,7 @@ static int c_can_set_bittiming(struct ne
>  	u32 ten_bit_brp;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +	int res;
> =20
>  	/* c_can provides a 6-bit brp and 4-bit brpe fields */
>  	ten_bit_brp =3D bt->brp - 1;
> @@ -590,13 +606,17 @@ static int c_can_set_bittiming(struct ne
>  		"setting BTR=3D%04x BRPE=3D%04x\n", reg_btr, reg_brpe);
> =20
>  	ctrl_save =3D priv->read_reg(priv, C_CAN_CTRL_REG);
> -	priv->write_reg(priv, C_CAN_CTRL_REG,
> -			ctrl_save | CONTROL_CCE | CONTROL_INIT);
> +	ctrl_save &=3D ~CONTROL_INIT;
> +	priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_CCE | CONTROL_INIT);
> +	res =3D c_can_wait_for_ctrl_init(dev, priv, CONTROL_INIT);
> +	if (res)
> +		return res;
> +
>  	priv->write_reg(priv, C_CAN_BTR_REG, reg_btr);
>  	priv->write_reg(priv, C_CAN_BRPEXT_REG, reg_brpe);
>  	priv->write_reg(priv, C_CAN_CTRL_REG, ctrl_save);
> =20
> -	return 0;
> +	return c_can_wait_for_ctrl_init(dev, priv, 0);

I'll post a patch that adds return value checking of all direct and
indirect users of c_can_set_bittiming().

>  }
> =20
>  /*

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4irx6vuafGuJchm5gtKwoUuUJsCquUFqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMojEcACgkQjTAFq1RaXHMIrACdFSe+ND7y5fDZZ95e0D24fy7g
p/wAn1DCktoG3V3F6YQUc8grbdrLi4iK
=uz65
-----END PGP SIGNATURE-----

--4irx6vuafGuJchm5gtKwoUuUJsCquUFqm--
