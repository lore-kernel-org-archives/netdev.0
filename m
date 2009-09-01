From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/19] netdev: change transmit to limited range type
Date: Tue, 01 Sep 2009 09:39:47 +0200
Message-ID: <4A9CCFC3.6020006@gmail.com>
References: <20090901055039.824876937@vyatta.com> <20090901055128.466779045@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59833 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbZIAHjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 03:39:48 -0400
In-Reply-To: <20090901055128.466779045@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The transmit function should only return one of three possible values=
,
> some drivers got confused and returned errno's or other values.
> This changes the definition so that this can be caught at compile tim=
e.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> The patch will produce warnings until drivers are converted.
>=20
>=20
> ---
>  include/linux/netdevice.h |   22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
>=20
> --- a/include/linux/netdevice.h	2009-08-31 16:47:58.703591891 -0700
> +++ b/include/linux/netdevice.h	2009-08-31 22:24:53.101472780 -0700
> @@ -79,17 +79,19 @@ struct wireless_dev;
>  #define net_xmit_eval(e)	((e) =3D=3D NET_XMIT_CN? 0 : (e))
>  #define net_xmit_errno(e)	((e) !=3D NET_XMIT_CN ? -ENOBUFS : 0)
> =20
> +/* Driver transmit return codes */
> +enum netdev_tx {
> +	NETDEV_TX_OK =3D 0,	/* driver took care of packet */
> +	NETDEV_TX_BUSY,		/* driver tx path was busy*/
> +	NETDEV_TX_LOCKED =3D -1,	/* driver tx lock was already taken */
> +};
> +typedef enum netdev_tx netdev_tx_t;
> +
>  #endif
> =20
>  #define MAX_ADDR_LEN	32		/* Largest hardware address length */
> =20
> -/* Driver transmit return codes */
> -#define NETDEV_TX_OK 0		/* driver took care of packet */
> -#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
> -#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
> -
>  #ifdef  __KERNEL__
> -
>  /*
>   *	Compute the worst case header length according to the protocols
>   *	used.
> @@ -507,9 +509,11 @@ struct netdev_queue {
>   *     This function is called when network device transistions to t=
he down
>   *     state.
>   *
> - * int (*ndo_start_xmit)(struct sk_buff *skb, struct net_device *dev=
);
> + * netdev_tx_t (*ndo_start_xmit)(struct sk_buff *skb,
> + *                               struct net_device *dev);
>   *	Called when a packet needs to be transmitted.
> - *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY, or NETDEV_TX_LOCKED,
> + *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY.
> + *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
>   *	Required can not be NULL.
>   *
>   * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *s=
kb);
> @@ -580,7 +584,7 @@ struct net_device_ops {
>  	void			(*ndo_uninit)(struct net_device *dev);
>  	int			(*ndo_open)(struct net_device *dev);
>  	int			(*ndo_stop)(struct net_device *dev);
> -	int			(*ndo_start_xmit) (struct sk_buff *skb,
> +	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
>  						   struct net_device *dev);
>  	u16			(*ndo_select_queue)(struct net_device *dev,
>  						    struct sk_buff *skb);
>=20

I was wondering if we could add a third parameter to=20
ndo_start_xmit() (and pass the struct netdev_queue *txq)
in a smooth way, but could not find a solution.

Unconverted drivers would not care of this third param; but this
should be provided by callers (like dev_hard_start_xmit())

Most multiqueue drivers have to recompute it, and even monoqueue driver=
s
have to call netif_stop_queue(dev)/netif_queue_stopped(dev), all
using netdev_get_tx_queue(dev, 0) in the end...

