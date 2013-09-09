From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 08/16] c_can: Add FlexCard CAN TX fifo support
Date: Mon, 09 Sep 2013 11:47:55 +0200
Message-ID: <522D994B.70908@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-9-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="QwrOUilOsHjDWL121JetPhE8U7a5WrAVS"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-9-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QwrOUilOsHjDWL121JetPhE8U7a5WrAVS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> The FlexCard DCAN implementation contains a specialized TX fifo functio=
n.
> Add the TX support for this function.

This patch looks a bit fishy. Is this compatible with existing
c_can/d_can hardware. It looks like you "use" frame->dlc to transport
some information.

> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 77 +++++++++++++++++++++++++++++++++++=
+-------
>  1 file changed, 65 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 39e2bb0..4b94f2d 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -41,6 +41,7 @@
>  #include <linux/can/error.h>
>  #include <linux/can/led.h>
> =20
> +#include <linux/flexcard.h>
>  #include "c_can.h"
> =20
>  /* Number of interface registers */
> @@ -566,24 +567,60 @@ static netdev_tx_t c_can_start_xmit(struct sk_buf=
f *skb,
>  	u32 msg_obj_no;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	struct can_frame *frame =3D (struct can_frame *)skb->data;
> +	int tx_fifo;
> =20
>  	if (can_dropped_invalid_skb(dev, skb))
>  		return NETDEV_TX_OK;
> =20
> -	msg_obj_no =3D get_tx_next_msg_obj(priv);
> +	tx_fifo =3D frame->can_dlc & FC_TXFIFO_FLAG;

Can you describe what you have encoded into to frame->can_dlc?

> +	frame->can_dlc &=3D FC_TXFIFO_DLC_MASK;
> =20
> -	/* prepare message object for transmission */
> -	c_can_write_msg_object(dev, 0, frame, msg_obj_no);
> -	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> +	if (tx_fifo) {
> +		u32 id, *data, ctrl;
> =20
> -	/*
> -	 * we have to stop the queue in case of a wrap around or
> -	 * if the next TX message object is still in use
> -	 */
> -	priv->tx_next++;
> -	if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
> -			(priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0)
> -		netif_stop_queue(dev);
> +		if (readl(priv->base + FC_TXFIFO_STAT) &
> +				FC_TXFIFO_STAT_FULL) {
> +			netif_stop_queue(dev);
> +			return NETDEV_TX_BUSY;
> +		}
> +
> +		if (frame->can_id & CAN_EFF_FLAG) {
> +			id =3D frame->can_id & CAN_EFF_MASK;
> +			id |=3D FC_TXFIFO_MSGID_EXT;
> +		} else {
> +			id =3D frame->can_id & CAN_SFF_MASK;
> +			/* StdID is left alligned */
> +			id <<=3D FC_TXFIFO_MSGID_STDID_SHIFT;
> +		}
> +
> +		writel(id, priv->base + FC_TXFIFO_MSGID);
> +		writel(frame->can_dlc, priv->base + FC_TXFIFO_MSGCTRL);
> +
> +		if (frame->can_dlc) {
> +			data =3D (u32 *) frame->data;
> +			writel(data[0], priv->base + FC_TXFIFO_MSGDA);
> +			writel(data[1], priv->base + FC_TXFIFO_MSGDB);
> +		}
> +
> +		ctrl =3D readl(priv->base + FC_TXFIFO_CTRL);
> +		ctrl |=3D FC_TXFIFO_CTRL_REQ;
> +		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
> +		kfree_skb(skb);
> +	} else {
> +		msg_obj_no =3D get_tx_next_msg_obj(priv);
> +
> +		/* prepare message object for transmission */
> +		c_can_write_msg_object(dev, 0, frame, msg_obj_no);
> +		priv->tx_next++;
> +
> +		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> +		/* we have to stop the queue in case of a wrap around or
> +		 * if the next TX message object is still in use
> +		 */
> +		if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv))
> +			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0))
> +			netif_stop_queue(dev);
> +	}
> =20
>  	return NETDEV_TX_OK;
>  }
> @@ -683,6 +720,8 @@ static void c_can_configure_msg_objects(struct net_=
device *dev, int invalidate)
>  				   IF_MASK_MDIR | IF_MASK_RES, 0,
>  				   IF_MCONT_UMASK | IF_MCONT_EOB |
>  				   IF_MCONT_RXIE | IF_MCONT_DLC_MAX);
> +
> +	c_can_inval_msg_object(dev, 0, FC_TXFIFO_MO);
>  }
> =20
>  /*
> @@ -740,8 +779,13 @@ static int c_can_chip_config(struct net_device *de=
v)
>  static int c_can_start(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u32 conf;
>  	int ret;
> =20
> +	conf =3D readl(priv->base + FC_TXFIFO_CONF);
> +	conf |=3D FC_TXFIFO_CONF_EN;
> +	writel(conf, priv->base + FC_TXFIFO_CONF);
> +
>  	/* basic c_can configuration */
>  	ret =3D c_can_chip_config(dev);
>  	if (ret)
> @@ -762,6 +806,11 @@ out:
>  static void c_can_stop(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u32 conf;
> +
> +	conf =3D readl(priv->base + FC_TXFIFO_CONF);
> +	conf &=3D ~FC_TXFIFO_CONF_EN;
> +	writel(conf, priv->base + FC_TXFIFO_CONF);
> =20
>  	/* disable all interrupts */
>  	c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> @@ -1350,6 +1399,8 @@ int register_c_can_dev(struct net_device *dev)
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	int err;
> =20
> +	writel(0, priv->base + FC_TXFIFO_CONF);
> +
>  	c_can_pm_runtime_enable(priv);
> =20
>  	dev->flags |=3D IFF_ECHO;	/* we support local echo */
> @@ -1369,6 +1420,8 @@ void unregister_c_can_dev(struct net_device *dev)=

>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
> +	writel(0, priv->base + FC_TXFIFO_CONF);
> +
>  	unregister_candev(dev);
> =20
>  	c_can_pm_runtime_disable(priv);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--QwrOUilOsHjDWL121JetPhE8U7a5WrAVS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItmUsACgkQjTAFq1RaXHNwmgCfVBttguAuvI4Xr8VdjVkaum95
rHYAnRhKHe4aXGnBzeKwYUkX/4FkpOrD
=LrrM
-----END PGP SIGNATURE-----

--QwrOUilOsHjDWL121JetPhE8U7a5WrAVS--
