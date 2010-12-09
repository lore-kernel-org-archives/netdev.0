From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/4] net: implement mechanism for HW based QOS
Date: Thu, 09 Dec 2010 21:46:31 +0100
Message-ID: <1291927591.2803.14.camel@edumazet-laptop>
References: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:38136 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756655Ab0LIUqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 15:46:37 -0500
Received: by ewy10 with SMTP id 10so2114161ewy.4
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 12:46:35 -0800 (PST)
In-Reply-To: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 d=C3=A9cembre 2010 =C3=A0 11:59 -0800, John Fastabend a =C3=
=A9crit :
> This patch provides a mechanism for lower layer devices to
> steer traffic using skb->priority to tx queues. This allows
> for hardware based QOS schemes to use the default qdisc without
> incurring the penalties related to global state and the qdisc
> lock. While reliably receiving skbs on the correct tx ring
> to avoid head of line blocking resulting from shuffling in
> the LLD. Finally, all the goodness from txq caching and xps/rps
> can still be leveraged.
>=20
> Many drivers and hardware exist with the ability to implement
> QOS schemes in the hardware but currently these drivers tend
> to rely on firmware to reroute specific traffic, a driver
> specific select_queue or the queue_mapping action in the
> qdisc.
>=20
> By using select_queue for this drivers need to be updated for
> each and every traffic type and we lose the goodness of much
> of the upstream work. Firmware solutions are inherently
> inflexible. And finally if admins are expected to build a
> qdisc and filter rules to steer traffic this requires knowledge
> of how the hardware is currently configured. The number of tx
> queues and the queue offsets may change depending on resources.
> Also this approach incurs all the overhead of a qdisc with filters.
>=20
> With the mechanism in this patch users can set skb priority using
> expected methods ie setsockopt() or the stack can set the priority
> directly. Then the skb will be steered to the correct tx queues
> aligned with hardware QOS traffic classes. In the normal case with
> a single traffic class and all queues in this class everything
> works as is until the LLD enables multiple tcs.
>=20
> To steer the skb we mask out the lower 4 bits of the priority
> and allow the hardware to configure upto 15 distinct classes
> of traffic. This is expected to be sufficient for most applications
> at any rate it is more then the 8021Q spec designates and is
> equal to the number of prio bands currently implemented in
> the default qdisc.
>=20
> This in conjunction with a userspace application such as
> lldpad can be used to implement 8021Q transmission selection
> algorithms one of these algorithms being the extended transmission
> selection algorithm currently being used for DCB.
>=20

Very nice Changelog !

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  include/linux/netdevice.h |   65 +++++++++++++++++++++++++++++++++++=
++++++++++
>  net/core/dev.c            |   39 ++++++++++++++++++++++++++-
>  2 files changed, 103 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a9ac5dc..c0d4fb1 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -646,6 +646,12 @@ struct xps_dev_maps {
>      (nr_cpu_ids * sizeof(struct xps_map *)))
>  #endif /* CONFIG_XPS */
> =20
> +/* HW offloaded queuing disciplines txq count and offset maps */
> +struct netdev_tc_txq {
> +	u16 count;
> +	u16 offset;
> +};
> +
>  /*
>   * This structure defines the management hooks for network devices.
>   * The following hooks can be defined; unless noted otherwise, they =
are
> @@ -1146,6 +1152,10 @@ struct net_device {
>  	/* Data Center Bridging netlink ops */
>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>  #endif
> +	u8 max_tc;
> +	u8 num_tc;
> +	struct netdev_tc_txq *_tc_to_txq;

Given that this is up to 16*4 bytes (64), shouldnt we embed this in
net_device struct to avoid one dereference ?


> +	u8 prio_tc_map[16];
> =20
>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>  	/* max exchange id for FCoE LRO by ddp */
> @@ -1162,6 +1172,58 @@ struct net_device {
>  #define	NETDEV_ALIGN		32
> =20
>  static inline
> +int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
> +{
> +	return dev->prio_tc_map[prio & 15];
> +}
> +
> +static inline
> +int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
> +{
> +	if (tc >=3D dev->num_tc)
> +		return -EINVAL;
> +
> +	dev->prio_tc_map[prio & 15] =3D tc & 15;
> +	return 0;
> +}
> +
> +static inline
> +int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u1=
6 offset)
> +{
> +	struct netdev_tc_txq *tcp;
> +
> +	if (tc >=3D dev->num_tc)
> +		return -EINVAL;
> +
> +	tcp =3D &dev->_tc_to_txq[tc];
> +	tcp->count =3D count;
> +	tcp->offset =3D offset;
> +	return 0;
> +}
> +
> +static inline
> +struct netdev_tc_txq *netdev_get_tc_queue(const struct net_device *d=
ev, u8 tc)
> +{
> +	return &dev->_tc_to_txq[tc];
> +}
> +
> +static inline
> +int netdev_set_num_tc(struct net_device *dev, u8 num_tc)
> +{
> +	if (num_tc > dev->max_tc)
> +		return -EINVAL;
> +
> +	dev->num_tc =3D num_tc;
> +	return 0;
> +}
> +
> +static inline
> +u8 netdev_get_num_tc(const struct net_device *dev)
> +{
> +	return dev->num_tc;
> +}
> +
> +static inline
>  struct netdev_queue *netdev_get_tx_queue(const struct net_device *de=
v,
>  					 unsigned int index)
>  {
> @@ -1386,6 +1448,9 @@ static inline void unregister_netdevice(struct =
net_device *dev)
>  	unregister_netdevice_queue(dev, NULL);
>  }
> =20
> +extern int		netdev_alloc_max_tc(struct net_device *dev, u8 tc);
> +extern void		netdev_free_tc(struct net_device *dev);
> +
>  extern int 		netdev_refcnt_read(const struct net_device *dev);
>  extern void		free_netdev(struct net_device *dev);
>  extern void		synchronize_net(void);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 55ff66f..cc00e66 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2118,6 +2118,8 @@ static u32 hashrnd __read_mostly;
>  u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *=
skb)
>  {
>  	u32 hash;
> +	u16 qoffset =3D 0;
> +	u16 qcount =3D dev->real_num_tx_queues;
> =20
>  	if (skb_rx_queue_recorded(skb)) {
>  		hash =3D skb_get_rx_queue(skb);
> @@ -2126,13 +2128,20 @@ u16 skb_tx_hash(const struct net_device *dev,=
 const struct sk_buff *skb)
>  		return hash;
>  	}
> =20
> +	if (dev->num_tc) {
> +		u8 tc =3D netdev_get_prio_tc_map(dev, skb->priority);
> +		struct netdev_tc_txq *tcp =3D netdev_get_tc_queue(dev, tc);
> +		qoffset =3D tcp->offset;
> +		qcount =3D tcp->count;
> +	}
> +
>  	if (skb->sk && skb->sk->sk_hash)
>  		hash =3D skb->sk->sk_hash;
>  	else
>  		hash =3D (__force u16) skb->protocol ^ skb->rxhash;
>  	hash =3D jhash_1word(hash, hashrnd);
> =20
> -	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
> +	return (u16) ((((u64) hash * qcount)) >> 32) + qoffset;
>  }
>  EXPORT_SYMBOL(skb_tx_hash);
> =20
> @@ -5091,6 +5100,33 @@ void netif_stacked_transfer_operstate(const st=
ruct net_device *rootdev,
>  }
>  EXPORT_SYMBOL(netif_stacked_transfer_operstate);
> =20
> +int netdev_alloc_max_tc(struct net_device *dev, u8 tcs)
> +{
> +	struct netdev_tc_txq *tcp;
> +
> +	if (tcs > 16)
> +		return -EINVAL;
> +
> +	tcp =3D kcalloc(tcs, sizeof(*tcp), GFP_KERNEL);

common risk : allocating less than one cache line, and this possibly ca=
n
have false sharing.

I would just embed the thing.


