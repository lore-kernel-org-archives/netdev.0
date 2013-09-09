From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 03/16] c_can: simplify arbitration register handling
Date: Mon, 09 Sep 2013 11:16:26 +0200
Message-ID: <522D91EA.3020302@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-4-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="GwN7friMwC0SrvunuhbIfmN4lndcGKbSh"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54641 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3IIJQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 05:16:34 -0400
In-Reply-To: <1378711513-2548-4-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GwN7friMwC0SrvunuhbIfmN4lndcGKbSh
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The IF1/2 Arbitration register of the C_CAN/D_CAN ip core is internaly
> a 32bit register. Do not use two different 16bit variables to handle
> the IF1/2 Arbitration register.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>

Looks good, nitpit inline.

Marc
> ---
>  drivers/net/can/c_can/c_can.c | 27 ++++++++++++++-------------
>  1 file changed, 14 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 081620b..bdb7bcd 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -117,9 +117,9 @@
>  				IF_COMM_DATAA | IF_COMM_DATAB)
> =20
>  /* IFx arbitration */
> -#define IF_ARB_MSGVAL		BIT(15)
> -#define IF_ARB_MSGXTD		BIT(14)
> -#define IF_ARB_TRANSMIT		BIT(13)
> +#define IF_ARB_MSGVAL		BIT(31)
> +#define IF_ARB_MSGXTD		BIT(30)
> +#define IF_ARB_TRANSMIT		BIT(29)
> =20
>  /* IFx message control */
>  #define IF_MCONT_NEWDAT		BIT(15)
> @@ -133,6 +133,7 @@
>  #define IF_MCONT_TXRQST		BIT(8)
>  #define IF_MCONT_EOB		BIT(7)
>  #define IF_MCONT_DLC_MASK	0xf
> +#define IF_MCONT_DLC_MAX	8

It's not used, is it?

> =20
>  /*
>   * IFx register masks:
> @@ -336,7 +337,7 @@ static void c_can_write_msg_object(struct net_devic=
e *dev,
>  			int iface, struct can_frame *frame, int objno)
>  {
>  	int i;
> -	u16 flags =3D 0;
> +	u32 flags =3D IF_ARB_MSGVAL;
>  	unsigned int id;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
> @@ -349,11 +350,11 @@ static void c_can_write_msg_object(struct net_dev=
ice *dev,
>  	} else
>  		id =3D ((frame->can_id & CAN_SFF_MASK) << 18);
> =20
> -	flags |=3D IF_ARB_MSGVAL;
> +	id |=3D flags;
> =20
>  	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
>  				IFX_WRITE_LOW_16BIT(id));
> -	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface), flags |
> +	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
>  				IFX_WRITE_HIGH_16BIT(id));
> =20
>  	for (i =3D 0; i < frame->can_dlc; i +=3D 2) {
> @@ -439,7 +440,7 @@ static void c_can_handle_lost_msg_obj(struct net_de=
vice *dev,
> =20
>  static int c_can_read_msg_object(struct net_device *dev, int iface, in=
t ctrl)
>  {
> -	u16 flags, data;
> +	u16 data;
>  	int i;
>  	unsigned int val;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> @@ -455,16 +456,15 @@ static int c_can_read_msg_object(struct net_devic=
e *dev, int iface, int ctrl)
> =20
>  	frame->can_dlc =3D get_can_dlc(ctrl & 0x0F);
> =20
> -	flags =3D	priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface));
> -	val =3D priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface)) |
> -		(flags << 16);
> +	val =3D (priv->read_reg(priv, C_CAN_IFACE(ARB2_REG, iface)) << 16);
> +	val |=3D priv->read_reg(priv, C_CAN_IFACE(ARB1_REG, iface));
> =20
> -	if (flags & IF_ARB_MSGXTD)
> +	if (val & IF_ARB_MSGXTD)
>  		frame->can_id =3D (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
>  	else
>  		frame->can_id =3D (val >> 18) & CAN_SFF_MASK;
> =20
> -	if (flags & IF_ARB_TRANSMIT)
> +	if (val & IF_ARB_TRANSMIT)
>  		frame->can_id |=3D CAN_RTR_FLAG;
>  	else {
>  		for (i =3D 0; i < frame->can_dlc; i +=3D 2) {
> @@ -500,10 +500,11 @@ static void c_can_setup_receive_object(struct net=
_device *dev, int iface,
>  	priv->write_reg(priv, C_CAN_IFACE(MASK2_REG, iface),
>  			IFX_WRITE_HIGH_16BIT(mask) | BIT(13));
> =20
> +	id |=3D IF_ARB_MSGVAL;
>  	priv->write_reg(priv, C_CAN_IFACE(ARB1_REG, iface),
>  			IFX_WRITE_LOW_16BIT(id));
>  	priv->write_reg(priv, C_CAN_IFACE(ARB2_REG, iface),
> -			(IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
> +			(IFX_WRITE_HIGH_16BIT(id)));
> =20
>  	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), mcont);
>  	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--GwN7friMwC0SrvunuhbIfmN4lndcGKbSh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItkeoACgkQjTAFq1RaXHN6IgCaAnWMkrSl00KUzgacs4oUSWEs
ynIAn37MK5y3Oxxr+Rggdg43Oks8KJGG
=ujb4
-----END PGP SIGNATURE-----

--GwN7friMwC0SrvunuhbIfmN4lndcGKbSh--
