From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: can: make the number of echo skb's configurable
Date: Fri, 09 Oct 2009 10:24:28 +0200
Message-ID: <4ACEF33C.5010702@pengutronix.de>
References: <4ACEEFA6.1000904@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0834336968=="
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4ACEEFA6.1000904-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============0834336968==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5E8D87CD9F2DEBB8AB6E5C2C"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5E8D87CD9F2DEBB8AB6E5C2C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang Grandegger wrote:
> This patch allows the CAN controller driver to define the number of ech=
o
> skb's used for the local loopback (echo), as suggested by Kurt Van
> Dijck, with the function:
>=20
>   struct net_device *alloc_candev(int sizeof_priv,
>                                   unsigned int echo_skb_max);
>=20
> The CAN drivers have been adapted accordingly. For the ems_usb driver,
> as suggested by Sebastian Haas, the number of echo skb's has been
> increased to 10, which improves the transmission performance a lot.
>=20
> Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
> ---
>  drivers/net/can/at91_can.c        |    2 +-
>  drivers/net/can/dev.c             |   32 ++++++++++++++++++++++++++---=
---
>  drivers/net/can/sja1000/sja1000.c |    3 ++-
>  drivers/net/can/sja1000/sja1000.h |    2 ++
>  drivers/net/can/ti_hecc.c         |    6 +-----
>  drivers/net/can/usb/ems_usb.c     |    4 ++--
>  include/linux/can/dev.h           |   16 ++++++++--------
>  7 files changed, 42 insertions(+), 23 deletions(-)
>=20
> Index: net-next-2.6/drivers/net/can/dev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/can/dev.c
> +++ net-next-2.6/drivers/net/can/dev.c
> @@ -245,7 +245,7 @@ static void can_flush_echo_skb(struct ne
>  	struct net_device_stats *stats =3D &dev->stats;
>  	int i;
> =20
> -	for (i =3D 0; i < CAN_ECHO_SKB_MAX; i++) {
> +	for (i =3D 0; i < priv->echo_skb_max; i++) {
>  		if (priv->echo_skb[i]) {
>  			kfree_skb(priv->echo_skb[i]);
>  			priv->echo_skb[i] =3D NULL;
> @@ -262,10 +262,13 @@ static void can_flush_echo_skb(struct ne
>   * of the device driver. The driver must protect access to
>   * priv->echo_skb, if necessary.
>   */
> -void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int=
 idx)
> +void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
> +		      unsigned int idx)
>  {
>  	struct can_priv *priv =3D netdev_priv(dev);
> =20
> +	BUG_ON(idx >=3D priv->echo_skb_max);
> +
>  	/* check flag whether this packet has to be looped back */
>  	if (!(dev->flags & IFF_ECHO) || skb->pkt_type !=3D PACKET_LOOPBACK) {=

>  		kfree_skb(skb);
> @@ -311,10 +314,12 @@ EXPORT_SYMBOL_GPL(can_put_echo_skb);
>   * is handled in the device driver. The driver must protect
>   * access to priv->echo_skb, if necessary.
>   */
> -void can_get_echo_skb(struct net_device *dev, int idx)
> +void can_get_echo_skb(struct net_device *dev, unsigned int idx)
>  {
>  	struct can_priv *priv =3D netdev_priv(dev);
> =20
> +	BUG_ON(idx >=3D priv->echo_skb_max);
> +
>  	if (priv->echo_skb[idx]) {
>  		netif_rx(priv->echo_skb[idx]);
>  		priv->echo_skb[idx] =3D NULL;
> @@ -327,10 +332,12 @@ EXPORT_SYMBOL_GPL(can_get_echo_skb);
>    *
>    * The function is typically called when TX failed.
>    */
> -void can_free_echo_skb(struct net_device *dev, int idx)
> +void can_free_echo_skb(struct net_device *dev, unsigned int idx)
>  {
>  	struct can_priv *priv =3D netdev_priv(dev);
> =20
> +	BUG_ON(idx >=3D priv->echo_skb_max);
> +
>  	if (priv->echo_skb[idx]) {
>  		kfree_skb(priv->echo_skb[idx]);
>  		priv->echo_skb[idx] =3D NULL;
> @@ -445,17 +452,30 @@ static void can_setup(struct net_device=20
>  /*
>   * Allocate and setup space for the CAN network device
>   */
> -struct net_device *alloc_candev(int sizeof_priv)
> +struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb=
_max)
>  {
>  	struct net_device *dev;
>  	struct can_priv *priv;
> +	int size;
> =20
> -	dev =3D alloc_netdev(sizeof_priv, "can%d", can_setup);
> +	if (echo_skb_max)
> +		size =3D ALIGN(sizeof_priv, sizeof(struct sk_buff *)) +
> +			echo_skb_max * sizeof(struct sk_buff *);
> +	else
> +		size =3D sizeof_priv;
> +
> +	dev =3D alloc_netdev(size, "can%d", can_setup);
>  	if (!dev)
>  		return NULL;
> =20
>  	priv =3D netdev_priv(dev);
> =20
> +	if (echo_skb_max) {
> +		priv->echo_skb_max =3D echo_skb_max;
> +		priv->echo_skb =3D (void *)priv +
> +			ALIGN(sizeof_priv, sizeof(struct sk_buff *));
> +	}
> +
>  	priv->state =3D CAN_STATE_STOPPED;
> =20
>  	init_timer(&priv->restart_timer);
> Index: net-next-2.6/include/linux/can/dev.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/include/linux/can/dev.h
> +++ net-next-2.6/include/linux/can/dev.h
> @@ -29,8 +29,6 @@ enum can_mode {
>  /*
>   * CAN common private data
>   */
> -#define CAN_ECHO_SKB_MAX  4
> -
>  struct can_priv {
>  	struct can_device_stats can_stats;
> =20
> @@ -44,15 +42,16 @@ struct can_priv {
>  	int restart_ms;
>  	struct timer_list restart_timer;
> =20
> -	struct sk_buff *echo_skb[CAN_ECHO_SKB_MAX];
> -
>  	int (*do_set_bittiming)(struct net_device *dev);
>  	int (*do_set_mode)(struct net_device *dev, enum can_mode mode);
>  	int (*do_get_state)(const struct net_device *dev,
>  			    enum can_state *state);
> +
> +	unsigned int echo_skb_max;
> +	struct sk_buff **echo_skb;
>  };
> =20
> -struct net_device *alloc_candev(int sizeof_priv);
> +struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb=
_max);
>  void free_candev(struct net_device *dev);
> =20
>  int open_candev(struct net_device *dev);
> @@ -64,8 +63,9 @@ void unregister_candev(struct net_device
>  int can_restart_now(struct net_device *dev);
>  void can_bus_off(struct net_device *dev);
> =20
> -void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int=
 idx);
> -void can_get_echo_skb(struct net_device *dev, int idx);
> -void can_free_echo_skb(struct net_device *dev, int idx);
> +void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
> +		      unsigned int idx);
> +void can_get_echo_skb(struct net_device *dev, unsigned int idx);
> +void can_free_echo_skb(struct net_device *dev, unsigned int idx);
> =20
>  #endif /* CAN_DEV_H */
> Index: net-next-2.6/drivers/net/can/at91_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next-2.6.orig/drivers/net/can/at91_can.c
> +++ net-next-2.6/drivers/net/can/at91_can.c
> @@ -1087,7 +1087,7 @@ static int __init at91_can_probe(struct=20
>  		goto exit_release;
>  	}
> =20
> -	dev =3D alloc_candev(sizeof(struct at91_priv));
> +	dev =3D alloc_candev(sizeof(struct at91_priv), AT91_MB_TX_NUM);
>  	if (!dev) {
>  		err =3D -ENOMEM;
>  		goto exit_iounmap;

The at91 part looks okay.

Marc

--=20
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |


--------------enig5E8D87CD9F2DEBB8AB6E5C2C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkrO80AACgkQjTAFq1RaXHMrDgCcDczqrE6JVk0C9x3hmoEXQnYQ
szsAnRIOvD+45EyruUesiCRjbDlCAj0c
=ieVK
-----END PGP SIGNATURE-----

--------------enig5E8D87CD9F2DEBB8AB6E5C2C--

--===============0834336968==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0834336968==--
