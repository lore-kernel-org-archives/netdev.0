From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 15/16] flexcard: can: Configure CAN loopback packages
 (TXACK)
Date: Mon, 09 Sep 2013 12:29:57 +0200
Message-ID: <522DA325.2050806@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-16-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Skm1GKDUuBxvpSAHoUppDWDO8dc1ThKG9"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-16-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Skm1GKDUuBxvpSAHoUppDWDO8dc1ThKG9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> Signed-off-by: Holger Dengler <dengler@linutronix.de>

I'm missing your S-o-b and a patch description. I'm finding some
uncommon use of frame->can_dlc.

Marc

> ---
>  drivers/net/can/c_can/c_can.c | 23 ++++++++++++++++-------
>  1 file changed, 16 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 670a6b1..92c1444 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -358,11 +358,13 @@ static inline void c_can_object_put(struct net_de=
vice *dev,
>  }
> =20
>  static void c_can_write_msg_object(struct net_device *dev,
> -			int iface, struct can_frame *frame, int objno)
> +			int iface, struct can_frame *frame, int objno,
> +			int txie_off)
>  {
>  	u32 flags =3D IF_ARB_MSGVAL;
>  	unsigned int id;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u32 int_en;
> =20
>  	if (!(frame->can_id & CAN_RTR_FLAG))
>  		flags |=3D IF_ARB_TRANSMIT;
> @@ -388,9 +390,10 @@ static void c_can_write_msg_object(struct net_devi=
ce *dev,
>  			 frame->data[4] | frame->data[5] << 8);
> =20
>  	/* enable interrupt for this message object */
> -	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface),
> -			IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
> -			frame->can_dlc);
> +	int_en =3D frame->can_dlc;
> +	if (!txie_off)
> +		int_en |=3D IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB;
> +	priv->write_reg(priv, C_CAN_IFACE(MSGCTRL_REG, iface), int_en);
>  	c_can_object_put(dev, iface, objno, IF_COMM_ALL);
>  }
> =20
> @@ -616,16 +619,17 @@ static netdev_tx_t c_can_start_xmit(struct sk_buf=
f *skb,
>  	u32 msg_obj_no;
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	struct can_frame *frame =3D (struct can_frame *)skb->data;
> -	int tx_fifo;
> +	int tx_fifo, txie_off;
> =20
>  	if (can_dropped_invalid_skb(dev, skb))
>  		return NETDEV_TX_OK;
> =20
>  	tx_fifo =3D frame->can_dlc & FC_TXFIFO_FLAG;
> +	txie_off =3D frame->can_dlc & FC_TXACKOFF_FLAG;
>  	frame->can_dlc &=3D FC_TXFIFO_DLC_MASK;
> =20
>  	if (tx_fifo) {
> -		u32 id, *data, ctrl;
> +		u32 id, *data, ctrl, conf;
> =20
>  		if (readl(priv->base + FC_TXFIFO_STAT) &
>  				FC_TXFIFO_STAT_FULL) {
> @@ -652,6 +656,11 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff=
 *skb,
>  			writel(data[1], priv->base + FC_TXFIFO_MSGDB);
>  		}
> =20
> +		conf =3D readl(priv->base + FC_TXFIFO_CONF);
> +		conf &=3D ~FC_TXFIFO_CONF_TXACK;
> +		conf |=3D (txie_off ? 0 : FC_TXFIFO_CONF_TXACK);
> +		writel(conf, priv->base + FC_TXFIFO_CONF);
> +
>  		ctrl =3D readl(priv->base + FC_TXFIFO_CTRL);
>  		ctrl |=3D FC_TXFIFO_CTRL_REQ;
>  		writel(ctrl, priv->base + FC_TXFIFO_CTRL);
> @@ -660,7 +669,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff =
*skb,
>  		msg_obj_no =3D get_tx_next_msg_obj(priv);
> =20
>  		/* prepare message object for transmission */
> -		c_can_write_msg_object(dev, 0, frame, msg_obj_no);
> +		c_can_write_msg_object(dev, 0, frame, msg_obj_no, txie_off);
>  		priv->tx_next++;
> =20
>  		can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Skm1GKDUuBxvpSAHoUppDWDO8dc1ThKG9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItoyUACgkQjTAFq1RaXHPoDACeJhWrpbziTE959E9DpdDKjAU+
XeAAn0EajoXpf3hOhAI0G8Gz3nBLTBbR
=iM2z
-----END PGP SIGNATURE-----

--Skm1GKDUuBxvpSAHoUppDWDO8dc1ThKG9--
