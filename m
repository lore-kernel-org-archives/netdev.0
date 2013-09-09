From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 09/16] c_can: expicit 32bit access on D_CAN to message
 buffer data register
Date: Mon, 09 Sep 2013 13:20:35 +0200
Message-ID: <522DAF03.7020806@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-10-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="a12S2VQjkbuvq5FMXEh491WbqOWKtMnq4"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-10-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--a12S2VQjkbuvq5FMXEh491WbqOWKtMnq4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> change the 16bit access of ARB1_REG and DATA1/2_REG to a 32bit access.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 4b94f2d..c573399 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -360,7 +360,6 @@ static inline void c_can_object_put(struct net_devi=
ce *dev,
>  static void c_can_write_msg_object(struct net_device *dev,
>  			int iface, struct can_frame *frame, int objno)
>  {
> -	int i;
>  	u32 flags =3D IF_ARB_MSGVAL;
>  	unsigned int id;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> @@ -376,15 +375,17 @@ static void c_can_write_msg_object(struct net_dev=
ice *dev,
> =20
>  	id |=3D flags;
> =20
> -	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
> -				IFX_WRITE_LOW_16BIT(id));
> -	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
> -				IFX_WRITE_HIGH_16BIT(id));
> +	c_can_writereg32(priv, C_CAN_IFACE(ARB1_REG, iface),
> +			IFX_WRITE_HIGH_16BIT(id),
> +			IFX_WRITE_LOW_16BIT(id));
> +
> +	c_can_writereg32(priv, C_CAN_IFACE(DATA1_REG, iface),
> +			 frame->data[2] | frame->data[3] << 8,
> +			 frame->data[0] | frame->data[1] << 8);

You can use something like beXX_to_cpup((__be32 *)&cf->data[0]) here.

> =20
> -	for (i =3D 0; i < frame->can_dlc; i +=3D 2) {
> -		priv->write_reg(priv, C_CAN_IFACE(DATA1_REG, iface) + i / 2,
> -				frame->data[i] | (frame->data[i + 1] << 8));
> -	}
> +	c_can_writereg32(priv, C_CAN_IFACE(DATA3_REG, iface),
> +			 frame->data[6] | frame->data[7] << 8,
> +			 frame->data[4] | frame->data[5] << 8);

You write here the upper 32 bit unconditionally, the original code doesn'=
t.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--a12S2VQjkbuvq5FMXEh491WbqOWKtMnq4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItrwMACgkQjTAFq1RaXHMEFACginTgGgvLR54I+fndX0BEHXgf
QXoAn285I8yUEb6d0gFR6PHyK4eE8++C
=3iN3
-----END PGP SIGNATURE-----

--a12S2VQjkbuvq5FMXEh491WbqOWKtMnq4--
