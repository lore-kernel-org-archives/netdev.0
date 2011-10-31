From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Mon, 31 Oct 2011 23:31:02 +0100
Message-ID: <4EAF21A6.702@pengutronix.de>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET.INT>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0915395345AD759EE5FA7D48"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Reuben Dowle <Reuben.Dowle@navico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46726 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755666Ab1JaWbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 18:31:09 -0400
In-Reply-To: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET.INT>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0915395345AD759EE5FA7D48
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/31/2011 11:18 PM, Reuben Dowle wrote:
> Currently the flexcan driver uses hardware local echo. This blindly ech=
os all transmitted frames to all receiving sockets, regardless what CAN_R=
AW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK are set to.
>=20
> This patch now submits transmitted frames to be echoed in the transmit =
complete interrupt, preserving the reference to the sending socket. This =
allows the can protocol to correctly handle the local echo.
>=20
> Signed-off-by: Reuben Dowle <reuben.dowle@navico.com>

Patch looks quite good. Can you please wrap the description to about 72
chars?

>=20
> ---
>  drivers/net/can/flexcan.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index e023379..542ada8 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -302,7 +302,7 @@ static int flexcan_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	flexcan_write(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
>  	flexcan_write(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
> =20
> -	kfree_skb(skb);
> +	can_put_echo_skb(skb, dev, 0);
> =20
>  	/* tx_packets is incremented in flexcan_irq */
>  	stats->tx_bytes +=3D cf->can_dlc;
> @@ -612,6 +612,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
>  		/* tx_bytes is incremented in flexcan_start_xmit */
>  		stats->tx_packets++;
>  		flexcan_write((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
> +		can_get_echo_skb(dev, 0);
>  		netif_wake_queue(dev);
>  	}
> =20
> @@ -670,6 +671,8 @@ static int flexcan_chip_start(struct net_device *de=
v)
>  	int err;
>  	u32 reg_mcr, reg_ctrl;
> =20
> +	can_free_echo_skb(dev, 0);

what about putting this to flexcan_chip_stop? Otherwise you risk a
memleak if you do "ifconfig down; rmmod flexcan"

> +
>  	/* enable module */
>  	flexcan_chip_enable(priv);
> =20
> @@ -697,12 +700,13 @@ static int flexcan_chip_start(struct net_device *=
dev)
>  	 * only supervisor access
>  	 * enable warning int
>  	 * choose format C
> +	 * disable local echo
>  	 *
>  	 */
>  	reg_mcr =3D flexcan_read(&regs->mcr);
>  	reg_mcr |=3D FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
>  		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
> -		FLEXCAN_MCR_IDAM_C;
> +		FLEXCAN_MCR_IDAM_C | FLEXCAN_MCR_SRX_DIS;
>  	dev_dbg(dev->dev.parent, "%s: writing mcr=3D0x%08x", __func__, reg_mc=
r);
>  	flexcan_write(reg_mcr, &regs->mcr);
> =20
> @@ -970,7 +974,7 @@ static int __devinit flexcan_probe(struct platform_=
device *pdev)
>  		goto failed_map;
>  	}
> =20
> -	dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
> +	dev =3D alloc_candev(sizeof(struct flexcan_priv), 1);
>  	if (!dev) {
>  		err =3D -ENOMEM;
>  		goto failed_alloc;
> @@ -978,7 +982,14 @@ static int __devinit flexcan_probe(struct platform=
_device *pdev)
> =20
>  	dev->netdev_ops =3D &flexcan_netdev_ops;
>  	dev->irq =3D irq;
> -	dev->flags |=3D IFF_ECHO; /* we support local echo in hardware */
> +
> +	/* Driver supports local echo.
> +	 * We support local echo in hardware, however this is not used becaus=
e
> +	 * hardware local echo loses the sending socket reference
> +	 * (thus CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK socket options
> +	 *  would not work)
> +	 */

IMHO, you can skip this comment. The patch description is good enough.

> +	dev->flags |=3D IFF_ECHO;
> =20
>  	priv =3D netdev_priv(dev);
>  	priv->can.clock.freq =3D clock_freq;
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in=

> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig0915395345AD759EE5FA7D48
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk6vIaoACgkQjTAFq1RaXHMhygCfTWB2uq4QmBadLCcFO5b6Xik4
HjIAn1EKrmyfsuGRMsa/Xl79qXb7J0by
=T6OK
-----END PGP SIGNATURE-----

--------------enig0915395345AD759EE5FA7D48--
