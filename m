From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 11/16] c_can: stop netqueue if hardware is busy
Date: Mon, 09 Sep 2013 12:05:26 +0200
Message-ID: <522D9D66.20405@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-12-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Kl8sDh2dbrIjOPmRD6PFH0piLdv4SgltG"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378711513-2548-12-git-send-email-b.spranger@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Kl8sDh2dbrIjOPmRD6PFH0piLdv4SgltG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> Unlike other network devices the FlexCard do not support interrupts on =
TX.
> Emulate the TX interrupt by polling the MOTRX registers and restart the=

> netqueue if one or more message object is available for transtition of =
CAN
> frames.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> ---
>  drivers/net/can/c_can/c_can.c | 61 +++++++++++++++++++++++++++++++++++=
+++++---
>  drivers/net/can/c_can/c_can.h |  4 +++
>  2 files changed, 62 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 46d741d..02f7c89 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -550,18 +550,66 @@ static void c_can_inval_msg_object(struct net_dev=
ice *dev, int iface, int objno)
> =20
>  static inline int c_can_is_next_tx_obj_busy(struct c_can_priv *priv, i=
nt objno)
>  {
> -	int val =3D c_can_read_reg32(priv, C_CAN_TXRQST1_REG);
> +	int val =3D c_can_read_reg32(priv, C_CAN_TXRQST1_REG + (objno / 32) *=
 4);
> =20
>  	/*
>  	 * as transmission request register's bit n-1 corresponds to
>  	 * message object n, we need to handle the same properly.
>  	 */
> -	if (val & (1 << (objno - 1)))
> +	if (val & (1 << ((objno % 32) - 1)))
>  		return 1;
> =20
>  	return 0;
>  }
> =20
> +static void c_can_motrx_add_timer(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->timer.expires =3D round_jiffies_relative(1);
> +	add_timer(&priv->timer);
> +}
> +
> +static void c_can_motrx_poll(unsigned long data)
> +{
> +	struct net_device *dev =3D (struct net_device *)data;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u32 val, empty =3D 0;
> +	int i;
> +
> +	for (i =3D 0; i < C_CAN_MOTRX_NR; i++) {
> +		val =3D c_can_read_reg32(priv, C_CAN_TXRQST1_REG + i * 4);
> +
> +		if (val < priv->motrx[i]) {
> +			netif_wake_queue(dev);
> +			return;
> +		}
> +
> +		empty |=3D val;
> +	}
> +
> +	if (!empty) {
> +		netif_wake_queue(dev);
> +		return;
> +	}
> +
> +	c_can_motrx_add_timer(dev);
> +}
> +
> +static void c_can_motrx_monitor(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	int i;
> +
> +	if (priv->type !=3D BOSCH_D_CAN_FLEXCARD)
> +		return;
> +
> +	for (i =3D 0; i < C_CAN_MOTRX_NR; i++)
> +		priv->motrx[i] =3D c_can_read_reg32(priv,
> +				C_CAN_TXRQST1_REG + i * 4);
> +	c_can_motrx_add_timer(dev);
> +}
> +
>  static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
>  					struct net_device *dev)
>  {
> @@ -582,6 +630,7 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff =
*skb,
>  		if (readl(priv->base + FC_TXFIFO_STAT) &
>  				FC_TXFIFO_STAT_FULL) {
>  			netif_stop_queue(dev);
> +			c_can_motrx_monitor(dev);
>  			return NETDEV_TX_BUSY;
>  		}
> =20
> @@ -619,8 +668,10 @@ static netdev_tx_t c_can_start_xmit(struct sk_buff=
 *skb,
>  		 * if the next TX message object is still in use
>  		 */
>  		if (c_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv))
> -			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0))
> +			|| ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0)) {
>  			netif_stop_queue(dev);
> +			c_can_motrx_monitor(dev);
> +		}
>  	}
> =20
>  	return NETDEV_TX_OK;
> @@ -1272,6 +1323,7 @@ static int c_can_close(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
> +	del_timer_sync(&priv->timer);
>  	netif_stop_queue(dev);
>  	napi_disable(&priv->napi);
>  	c_can_stop(dev);
> @@ -1306,6 +1358,9 @@ struct net_device *alloc_c_can_dev(void)
>  					CAN_CTRLMODE_LISTENONLY |
>  					CAN_CTRLMODE_BERR_REPORTING;
>  	spin_lock_init(&priv->lock);
> +	priv->timer.function =3D c_can_motrx_poll;
> +	priv->timer.data =3D (unsigned long) dev;
> +	init_timer_deferrable(&priv->timer);
> =20
>  	return dev;
>  }
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index beea437..6d0f805 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -153,6 +153,8 @@ enum c_can_dev_id {
>  	BOSCH_D_CAN_FLEXCARD,
>  };
> =20
> +#define C_CAN_MOTRX_NR	1

Are there reasons to have C_CAN_MOTRX_NR !=3D 1? If not, please remove th=
e
array and make code more clean.

>  /* c_can private data structure */
>  struct c_can_priv {
>  	struct can_priv can;	/* must be the first member */
> @@ -176,6 +178,8 @@ struct c_can_priv {
>  	unsigned int instance;
>  	void (*raminit) (const struct c_can_priv *priv, bool enable);
>  	spinlock_t lock;
> +	struct timer_list timer;
> +	u32 motrx[C_CAN_MOTRX_NR];
>  };
> =20
>  struct net_device *alloc_c_can_dev(void);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Kl8sDh2dbrIjOPmRD6PFH0piLdv4SgltG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItnWcACgkQjTAFq1RaXHPhCACeMRq9LR7MfrGTkqbAafXoNQwW
ys0AnjPB07yXYk6pEx7E2fqTGja89c0n
=ICQk
-----END PGP SIGNATURE-----

--Kl8sDh2dbrIjOPmRD6PFH0piLdv4SgltG--
