From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 06/16] c_can: consider set bittiming may fail
Date: Mon, 09 Sep 2013 11:39:56 +0200
Message-ID: <522D976C.5020206@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-7-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KqQduRMbrqSO86JdtCoqjrN2OViqmu4DX"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60469 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab3IIJkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 05:40:01 -0400
In-Reply-To: <1378711513-2548-7-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KqQduRMbrqSO86JdtCoqjrN2OViqmu4DX
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> While setting the bittiming the C_CAN/D_CAN may fail. Do not bring up t=
he
> CAN interface in this case.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index b3cfb85..3fa5347 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -689,9 +689,10 @@ static void c_can_configure_msg_objects(struct net=
_device *dev)
>   * - set operating mode
>   * - configure message objects
>   */
> -static void c_can_chip_config(struct net_device *dev)
> +static int c_can_chip_config(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	int ret;
> =20
>  	/* enable automatic retransmission */
>  	priv->write_reg(priv, C_CAN_CTRL_REG,
> @@ -726,15 +727,20 @@ static void c_can_chip_config(struct net_device *=
dev)
>  	priv->write_reg(priv, C_CAN_STS_REG, LEC_UNUSED);
> =20
>  	/* set bittiming params */
> -	c_can_set_bittiming(dev);
> +	ret =3D c_can_set_bittiming(dev);
> +
> +	return ret;

Maybe just:
	return c_can_set_bittiming(dev);
>  }
> =20
> -static void c_can_start(struct net_device *dev)
> +static int c_can_start(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	int ret;
> =20
>  	/* basic c_can configuration */
> -	c_can_chip_config(dev);
> +	ret =3D c_can_chip_config(dev);
> +	if (ret)
> +		goto out;

No need for a goto here, IMHO.

> =20
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
> @@ -743,6 +749,9 @@ static void c_can_start(struct net_device *dev)
> =20
>  	/* enable status change, error and module interrupts */
>  	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
> +
> +out:
> +	return ret;
>  }
> =20
>  static void c_can_stop(struct net_device *dev)
> @@ -758,9 +767,15 @@ static void c_can_stop(struct net_device *dev)
> =20
>  static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
>  {
> +	int ret;
> +
>  	switch (mode) {
>  	case CAN_MODE_START:
> -		c_can_start(dev);
> +		ret =3D c_can_start(dev);
> +		if (ret) {
> +			c_can_stop(dev);
> +			return ret;
> +		}
>  		netif_wake_queue(dev);
>  		break;
>  	default:
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--KqQduRMbrqSO86JdtCoqjrN2OViqmu4DX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItl2wACgkQjTAFq1RaXHNrdQCfdz8ODO0AQOp300FVs92eBt27
GkUAn0p/AG3McpXNFBornWN6hphoB25+
=D0Qp
-----END PGP SIGNATURE-----

--KqQduRMbrqSO86JdtCoqjrN2OViqmu4DX--
