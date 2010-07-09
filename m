From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: Get rid of rtnl_link_stats64 /
 net_device_stats union
Date: Fri, 09 Jul 2010 06:25:43 +0200
Message-ID: <1278649543.2435.105.camel@edumazet-laptop>
References: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51351 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab0GIEZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 00:25:51 -0400
Received: by wwb24 with SMTP id 24so4476802wwb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 21:25:47 -0700 (PDT)
In-Reply-To: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 juillet 2010 =C3=A0 00:29 +0100, Ben Hutchings a =C3=A9c=
rit :
> In commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b "net: Enable 64-bi=
t
> net device statistics on 32-bit architectures" I redefined struct
> net_device_stats so that it could be used in a union with struct
> rtnl_link_stats64, avoiding the need for explicit copying or
> conversion between the two.  However, this is unsafe because there is
> no locking required and no lock consistently held around calls to
> dev_get_stats() and use of the statistics structure it returns.
>=20
> In commit 28172739f0a276eb8d6ca917b3974c2edb036da3 "net: fix 64 bit
> counters on 32 bit arches" Eric Dumazet dealt with that problem by
> requiring callers of dev_get_stats() to provide storage for the
> result.  This means that the net_device::stats64 field and the paddin=
g
> in struct net_device_stats are now redundant, so remove them.
>=20
> Update the comment on net_device_ops::ndo_get_stats64 to reflect its
> new usage.
>=20
> Change dev_txq_stats_fold() to use struct rtnl_link_stats64, since
> that is what all its callers are really using and it is no longer
> going to be compatible with struct net_device_stats.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/macvlan.c     |    2 +-
>  include/linux/netdevice.h |   70 ++++++++++++++++++-----------------=
----------
>  net/8021q/vlan_dev.c      |    2 +-
>  net/core/dev.c            |   19 +++++++++---
>  4 files changed, 44 insertions(+), 49 deletions(-)
>=20
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 6112f14..1b28aae 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -436,7 +436,7 @@ static struct rtnl_link_stats64 *macvlan_dev_get_=
stats64(struct net_device *dev,
>  {
>  	struct macvlan_dev *vlan =3D netdev_priv(dev);
> =20
> -	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
> +	dev_txq_stats_fold(dev, stats);
> =20
>  	if (vlan->rx_stats) {
>  		struct macvlan_rx_stats *p, accum =3D {0};
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8018f6b..17e95e3 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -162,42 +162,32 @@ static inline bool dev_xmit_complete(int rc)
>  /*
>   *	Old network device statistics. Fields are native words
>   *	(unsigned long) so they can be read and written atomically.
> - *	Each field is padded to 64 bits for compatibility with
> - *	rtnl_link_stats64.
>   */
> =20
> -#if BITS_PER_LONG =3D=3D 64
> -#define NET_DEVICE_STATS_DEFINE(name)	unsigned long name
> -#elif defined(__LITTLE_ENDIAN)
> -#define NET_DEVICE_STATS_DEFINE(name)	unsigned long name, pad_ ## na=
me
> -#else
> -#define NET_DEVICE_STATS_DEFINE(name)	unsigned long pad_ ## name, na=
me
> -#endif
> -
>  struct net_device_stats {
> -	NET_DEVICE_STATS_DEFINE(rx_packets);
> -	NET_DEVICE_STATS_DEFINE(tx_packets);
> -	NET_DEVICE_STATS_DEFINE(rx_bytes);
> -	NET_DEVICE_STATS_DEFINE(tx_bytes);
> -	NET_DEVICE_STATS_DEFINE(rx_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_dropped);
> -	NET_DEVICE_STATS_DEFINE(tx_dropped);
> -	NET_DEVICE_STATS_DEFINE(multicast);
> -	NET_DEVICE_STATS_DEFINE(collisions);
> -	NET_DEVICE_STATS_DEFINE(rx_length_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_over_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_crc_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_frame_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_fifo_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_missed_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_aborted_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_carrier_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_fifo_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_heartbeat_errors);
> -	NET_DEVICE_STATS_DEFINE(tx_window_errors);
> -	NET_DEVICE_STATS_DEFINE(rx_compressed);
> -	NET_DEVICE_STATS_DEFINE(tx_compressed);
> +	unsigned long	rx_packets;
> +	unsigned long	tx_packets;
> +	unsigned long	rx_bytes;
> +	unsigned long	tx_bytes;
> +	unsigned long	rx_errors;
> +	unsigned long	tx_errors;
> +	unsigned long	rx_dropped;
> +	unsigned long	tx_dropped;
> +	unsigned long	multicast;
> +	unsigned long	collisions;
> +	unsigned long	rx_length_errors;
> +	unsigned long	rx_over_errors;
> +	unsigned long	rx_crc_errors;
> +	unsigned long	rx_frame_errors;
> +	unsigned long	rx_fifo_errors;
> +	unsigned long	rx_missed_errors;
> +	unsigned long	tx_aborted_errors;
> +	unsigned long	tx_carrier_errors;
> +	unsigned long	tx_fifo_errors;
> +	unsigned long	tx_heartbeat_errors;
> +	unsigned long	tx_window_errors;
> +	unsigned long	rx_compressed;
> +	unsigned long	tx_compressed;
>  };
> =20
>  #endif  /*  __KERNEL__  */
> @@ -666,14 +656,13 @@ struct netdev_rx_queue {
>   *	Callback uses when the transmitter has not made any progress
>   *	for dev->watchdog ticks.
>   *
> - * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *d=
ev
> + * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *d=
ev,
>   *                      struct rtnl_link_stats64 *storage);
>   * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev)=
;
>   *	Called when a user wants to get the network device usage
>   *	statistics. Drivers must do one of the following:
> - *	1. Define @ndo_get_stats64 to update a rtnl_link_stats64 structur=
e
> - *	   (which should normally be dev->stats64) and return a ponter to
> - *	   it. The structure must not be changed asynchronously.
> + *	1. Define @ndo_get_stats64 to fill in a zero-initialised
> + *	   rtnl_link_stats64 structure passed by the caller.
>   *	2. Define @ndo_get_stats to update a net_device_stats structure
>   *	   (which should normally be dev->stats) and return a pointer to
>   *	   it. The structure may be changed asynchronously only if each
> @@ -888,10 +877,7 @@ struct net_device {
>  	int			ifindex;
>  	int			iflink;
> =20
> -	union {
> -		struct rtnl_link_stats64 stats64;
> -		struct net_device_stats stats;
> -	};
> +	struct net_device_stats	stats;
> =20
>  #ifdef CONFIG_WIRELESS_EXT
>  	/* List of functions to handle Wireless Extensions (instead of ioct=
l).
> @@ -2147,7 +2133,7 @@ extern void		dev_mcast_init(void);
>  extern const struct rtnl_link_stats64 *dev_get_stats(struct net_devi=
ce *dev,
>  						     struct rtnl_link_stats64 *storage);
>  extern void		dev_txq_stats_fold(const struct net_device *dev,
> -					   struct net_device_stats *stats);
> +					   struct rtnl_link_stats64 *stats);
> =20
>  extern int		netdev_max_backlog;
>  extern int		netdev_tstamp_prequeue;
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 7865a4c..e66c9bf 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -805,7 +805,7 @@ static u32 vlan_ethtool_get_flags(struct net_devi=
ce *dev)
> =20
>  static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_dev=
ice *dev, struct rtnl_link_stats64 *stats)
>  {
> -	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
> +	dev_txq_stats_fold(dev, stats);
> =20
>  	if (vlan_dev_info(dev)->vlan_rx_stats) {
>  		struct vlan_rx_stats *p, accum =3D {0};
> diff --git a/net/core/dev.c b/net/core/dev.c
> index eb4201c..5ec2eec 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5274,10 +5274,10 @@ void netdev_run_todo(void)
>  /**
>   *	dev_txq_stats_fold - fold tx_queues stats
>   *	@dev: device to get statistics from
> - *	@stats: struct net_device_stats to hold results
> + *	@stats: struct rtnl_link_stats64 to hold results
>   */
>  void dev_txq_stats_fold(const struct net_device *dev,
> -			struct net_device_stats *stats)
> +			struct rtnl_link_stats64 *stats)
>  {
>  	unsigned long tx_bytes =3D 0, tx_packets =3D 0, tx_dropped =3D 0;
>  	unsigned int i;
> @@ -5311,17 +5311,26 @@ const struct rtnl_link_stats64 *dev_get_stats=
(struct net_device *dev,
>  					      struct rtnl_link_stats64 *storage)
>  {
>  	const struct net_device_ops *ops =3D dev->netdev_ops;
> +	size_t i, n =3D sizeof(*storage) / sizeof(u64);
> +	u64 *stats64 =3D (u64 *)storage;
> +	const unsigned long *stats;
> =20
>  	if (ops->ndo_get_stats64) {
>  		memset(storage, 0, sizeof(*storage));
>  		return ops->ndo_get_stats64(dev, storage);
>  	}
> +
>  	if (ops->ndo_get_stats) {
> -		memcpy(storage, ops->ndo_get_stats(dev), sizeof(*storage));
> +		stats =3D (const unsigned long *)ops->ndo_get_stats(dev);
> +		for (i =3D 0; i < n; i++)
> +			stats64[i] =3D stats[i];

This could be a small helper function, to hide the sizeof(*storage) /
sizeof(u64) magic..

static void stats_to_stats64(struct rtnl_link_stats64 *dst,
			     const net_device_stats *src)
{
#if BITS_PER_LONG =3D=3D 64
	BUILD_BUG_ON(sizeof(*dst) !=3D sizeof(*src));
	memcpy(dst, src, sizeof(*src));
#else
	size_t i, n =3D sizeof(*dst) / sizeof(u64);
	u64 *stats64 =3D (u64 *)dst;
	const unsigned long *stats =3D (const unsigned long *)src;

	BUILD_BUG_ON(sizeof(*src) !=3D n * sizeof(unsigned long));
	for (i =3D 0; i < n, i++)
		stats64[i] =3D stats[i];
#endif
 }
=20

Thanks !


