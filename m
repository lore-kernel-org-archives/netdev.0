From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3 2/2] sfc: Implement 64-bit net device statistics on
 all architectures
Date: Mon, 05 Jul 2010 20:16:20 +0200
Message-ID: <1278353780.2877.620.camel@edumazet-laptop>
References: <1276017594.2185.11.camel@achroite.uk.solarflarecom.com>
	 <1276017672.2185.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61841 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab0GESQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:16:28 -0400
Received: by wyf23 with SMTP id 23so2526399wyf.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 11:16:26 -0700 (PDT)
In-Reply-To: <1276017672.2185.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 18:21 +0100, Ben Hutchings a =C3=A9crit :
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This is unchanged from v1.
>=20
> Ben.
>=20
>  drivers/net/sfc/efx.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 26b0cc2..8ad476a 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -1492,11 +1492,11 @@ static int efx_net_stop(struct net_device *ne=
t_dev)
>  }
> =20
>  /* Context: process, dev_base_lock or RTNL held, non-blocking. */
> -static struct net_device_stats *efx_net_stats(struct net_device *net=
_dev)
> +static struct rtnl_link_stats64 *efx_net_stats(struct net_device *ne=
t_dev)
>  {
>  	struct efx_nic *efx =3D netdev_priv(net_dev);
>  	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
> -	struct net_device_stats *stats =3D &net_dev->stats;
> +	struct rtnl_link_stats64 *stats =3D &net_dev->stats64;
> =20
>  	spin_lock_bh(&efx->stats_lock);
>  	efx->type->update_stats(efx);
> @@ -1630,7 +1630,7 @@ static void efx_set_multicast_list(struct net_d=
evice *net_dev)
>  static const struct net_device_ops efx_netdev_ops =3D {
>  	.ndo_open		=3D efx_net_open,
>  	.ndo_stop		=3D efx_net_stop,
> -	.ndo_get_stats		=3D efx_net_stats,
> +	.ndo_get_stats64	=3D efx_net_stats,
>  	.ndo_tx_timeout		=3D efx_watchdog,
>  	.ndo_start_xmit		=3D efx_hard_start_xmit,
>  	.ndo_validate_addr	=3D eth_validate_addr,
> --=20
> 1.6.2.5
>=20

Ben, David

I believe following patch is needed after our recent commits.
Not sure a seqlock is really needed, maybe a spinlock would be enough.

Thanks

[PATCH net-next-2.6] net: fix 64 bit counters on 32 bit arches

There is a small possibility that a reader gets incorrect values on 32
bit arches. SNMP applications could catch incorrect counters when a
32bit high part is changed.

I believe we need to add some synchronisation to avoid this.

A driver that provides 64bit stats on a 32bit arches should make sure i=
t
gets the seqlock before updating them. Other drivers can stay unchanged=
,
since upper 32bits are not updated.

This new seqlock should be acquired in slow path only in process contex=
t
(no BH protection for instance).

Drivers should not use it in their rx/tx path. (They better stay with
32bit counters on 32bit arches)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/loopback.c    |    4 ++
 drivers/net/macvlan.c     |    2 +
 drivers/net/sfc/efx.c     |    2 +
 include/linux/netdevice.h |   43 +++++++++++++++++++++++
 net/8021q/vlan_dev.c      |    2 +
 net/core/dev.c            |   38 ++++++++++++--------
 net/core/rtnetlink.c      |   66 +++++++++++++++++++-----------------
 7 files changed, 112 insertions(+), 45 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 4dd0510..5e82e4a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -123,12 +123,16 @@ static struct rtnl_link_stats64 *loopback_get_sta=
ts64(struct net_device *dev)
 		bytes   +=3D tbytes;
 		packets +=3D tpackets;
 	}
+
+	netdev_stats_update_begin(dev);
 	stats->rx_packets =3D packets;
 	stats->tx_packets =3D packets;
 	stats->rx_dropped =3D drops;
 	stats->rx_errors  =3D drops;
 	stats->rx_bytes   =3D bytes;
 	stats->tx_bytes   =3D bytes;
+	netdev_stats_update_end(dev);
+
 	return stats;
 }
=20
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e6d626e..c39a90a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -458,11 +458,13 @@ static struct rtnl_link_stats64 *macvlan_dev_get_=
stats64(struct net_device *dev)
 			/* rx_errors is an ulong, updated without syncp protection */
 			accum.rx_errors		+=3D p->rx_errors;
 		}
+		netdev_stats_update_begin(dev);
 		stats->rx_packets =3D accum.rx_packets;
 		stats->rx_bytes   =3D accum.rx_bytes;
 		stats->rx_errors  =3D accum.rx_errors;
 		stats->rx_dropped =3D accum.rx_errors;
 		stats->multicast  =3D accum.rx_multicast;
+		netdev_stats_update_end(dev);
 	}
 	return stats;
 }
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 35b3f29..06afff6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1543,6 +1543,7 @@ static struct rtnl_link_stats64 *efx_net_stats(st=
ruct net_device *net_dev)
 	efx->type->update_stats(efx);
 	spin_unlock_bh(&efx->stats_lock);
=20
+	netdev_stats_update_begin(net_dev);
 	stats->rx_packets =3D mac_stats->rx_packets;
 	stats->tx_packets =3D mac_stats->tx_packets;
 	stats->rx_bytes =3D mac_stats->rx_bytes;
@@ -1565,6 +1566,7 @@ static struct rtnl_link_stats64 *efx_net_stats(st=
ruct net_device *net_dev)
 	stats->tx_errors =3D (stats->tx_window_errors +
 			    mac_stats->tx_bad);
=20
+	netdev_stats_update_end(net_dev);
 	return stats;
 }
=20
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4d27368..d6726cf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -886,6 +886,9 @@ struct net_device {
 	int			ifindex;
 	int			iflink;
=20
+#if BITS_PER_LONG=3D=3D32
+	seqlock_t		stats_lock;
+#endif
 	union {
 		struct rtnl_link_stats64 stats64;
 		struct net_device_stats stats;
@@ -1080,6 +1083,46 @@ struct net_device {
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
=20
+
+static inline void netdev_stats_initlock(struct net_device *dev)
+{
+#if BITS_PER_LONG=3D=3D32
+	seqlock_init(&dev->stats_lock);
+#endif
+}
+
+static inline void netdev_stats_update_begin(struct net_device *dev)
+{
+#if BITS_PER_LONG=3D=3D32
+	write_seqlock(&dev->stats_lock);
+#endif
+}
+
+static inline void netdev_stats_update_end(struct net_device *dev)
+{
+#if BITS_PER_LONG=3D=3D32
+	write_sequnlock(&dev->stats_lock);
+#endif
+}
+
+static inline unsigned int netdev_stats_fetch_begin(const struct net_d=
evice *dev)
+{
+#if BITS_PER_LONG=3D=3D32
+	return read_seqbegin(&dev->stats_lock);
+#else
+	return 0;
+#endif
+}
+
+static bool inline netdev_stats_fetch_retry(const struct net_device *d=
ev, unsigned int start)
+{
+#if BITS_PER_LONG=3D=3D32
+	return read_seqretry(&dev->stats_lock, start);
+#else
+	return false;
+#endif
+}
+
 #define	NETDEV_ALIGN		32
=20
 static inline
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c6456cb..3d4e2f0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -830,10 +830,12 @@ static struct rtnl_link_stats64 *vlan_dev_get_sta=
ts64(struct net_device *dev)
 			/* rx_errors is an ulong, not protected by syncp */
 			accum.rx_errors  +=3D p->rx_errors;
 		}
+		netdev_stats_update_begin(dev);
 		stats->rx_packets =3D accum.rx_packets;
 		stats->rx_bytes   =3D accum.rx_bytes;
 		stats->rx_errors  =3D accum.rx_errors;
 		stats->multicast  =3D accum.rx_multicast;
+		netdev_stats_update_end(dev);
 	}
 	return stats;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 93b8929..b41c7ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3704,24 +3704,31 @@ void dev_seq_stop(struct seq_file *seq, void *v=
)
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_devi=
ce *dev)
 {
 	const struct rtnl_link_stats64 *stats =3D dev_get_stats(dev);
+	struct rtnl_link_stats64 temp;
+	unsigned int start;
+=09
+	do {
+		start =3D netdev_stats_fetch_begin(dev);
+		memcpy(&temp, stats, sizeof(temp));
+	} while (netdev_stats_fetch_retry(dev, start));
=20
 	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9ll=
u "
 		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
-		   dev->name, stats->rx_bytes, stats->rx_packets,
-		   stats->rx_errors,
-		   stats->rx_dropped + stats->rx_missed_errors,
-		   stats->rx_fifo_errors,
-		   stats->rx_length_errors + stats->rx_over_errors +
-		    stats->rx_crc_errors + stats->rx_frame_errors,
-		   stats->rx_compressed, stats->multicast,
-		   stats->tx_bytes, stats->tx_packets,
-		   stats->tx_errors, stats->tx_dropped,
-		   stats->tx_fifo_errors, stats->collisions,
-		   stats->tx_carrier_errors +
-		    stats->tx_aborted_errors +
-		    stats->tx_window_errors +
-		    stats->tx_heartbeat_errors,
-		   stats->tx_compressed);
+		   dev->name, temp.rx_bytes, temp.rx_packets,
+		   temp.rx_errors,
+		   temp.rx_dropped + temp.rx_missed_errors,
+		   temp.rx_fifo_errors,
+		   temp.rx_length_errors + temp.rx_over_errors +
+		    temp.rx_crc_errors + temp.rx_frame_errors,
+		   temp.rx_compressed, temp.multicast,
+		   temp.tx_bytes, temp.tx_packets,
+		   temp.tx_errors, temp.tx_dropped,
+		   temp.tx_fifo_errors, temp.collisions,
+		   temp.tx_carrier_errors +
+		    temp.tx_aborted_errors +
+		    temp.tx_window_errors +
+		    temp.tx_heartbeat_errors,
+		   temp.tx_compressed);
 }
=20
 /*
@@ -5386,6 +5393,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	if (dev_addr_init(dev))
 		goto free_rx;
=20
+	netdev_stats_initlock(dev);
 	dev_mc_init(dev);
 	dev_uc_init(dev);
=20
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e645778..b3a3812 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -610,37 +610,43 @@ static void copy_rtnl_link_stats(struct rtnl_link=
_stats *a,
 	a->tx_compressed =3D b->tx_compressed;
 }
=20
-static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_sta=
ts64 *b)
+static void copy_rtnl_link_stats64(void *v, const struct rtnl_link_sta=
ts64 *b,
+				   struct net_device *dev)
 {
 	struct rtnl_link_stats64 a;
-
-	a.rx_packets =3D b->rx_packets;
-	a.tx_packets =3D b->tx_packets;
-	a.rx_bytes =3D b->rx_bytes;
-	a.tx_bytes =3D b->tx_bytes;
-	a.rx_errors =3D b->rx_errors;
-	a.tx_errors =3D b->tx_errors;
-	a.rx_dropped =3D b->rx_dropped;
-	a.tx_dropped =3D b->tx_dropped;
-
-	a.multicast =3D b->multicast;
-	a.collisions =3D b->collisions;
-
-	a.rx_length_errors =3D b->rx_length_errors;
-	a.rx_over_errors =3D b->rx_over_errors;
-	a.rx_crc_errors =3D b->rx_crc_errors;
-	a.rx_frame_errors =3D b->rx_frame_errors;
-	a.rx_fifo_errors =3D b->rx_fifo_errors;
-	a.rx_missed_errors =3D b->rx_missed_errors;
-
-	a.tx_aborted_errors =3D b->tx_aborted_errors;
-	a.tx_carrier_errors =3D b->tx_carrier_errors;
-	a.tx_fifo_errors =3D b->tx_fifo_errors;
-	a.tx_heartbeat_errors =3D b->tx_heartbeat_errors;
-	a.tx_window_errors =3D b->tx_window_errors;
-
-	a.rx_compressed =3D b->rx_compressed;
-	a.tx_compressed =3D b->tx_compressed;
+	unsigned int start;
+
+	do {
+		start =3D netdev_stats_fetch_begin(dev);
+
+		a.rx_packets =3D b->rx_packets;
+		a.tx_packets =3D b->tx_packets;
+		a.rx_bytes =3D b->rx_bytes;
+		a.tx_bytes =3D b->tx_bytes;
+		a.rx_errors =3D b->rx_errors;
+		a.tx_errors =3D b->tx_errors;
+		a.rx_dropped =3D b->rx_dropped;
+		a.tx_dropped =3D b->tx_dropped;
+=09
+		a.multicast =3D b->multicast;
+		a.collisions =3D b->collisions;
+
+		a.rx_length_errors =3D b->rx_length_errors;
+		a.rx_over_errors =3D b->rx_over_errors;
+		a.rx_crc_errors =3D b->rx_crc_errors;
+		a.rx_frame_errors =3D b->rx_frame_errors;
+		a.rx_fifo_errors =3D b->rx_fifo_errors;
+		a.rx_missed_errors =3D b->rx_missed_errors;
+
+		a.tx_aborted_errors =3D b->tx_aborted_errors;
+		a.tx_carrier_errors =3D b->tx_carrier_errors;
+		a.tx_fifo_errors =3D b->tx_fifo_errors;
+		a.tx_heartbeat_errors =3D b->tx_heartbeat_errors;
+		a.tx_window_errors =3D b->tx_window_errors;
+
+		a.rx_compressed =3D b->rx_compressed;
+		a.tx_compressed =3D b->tx_compressed;
+	} while (netdev_stats_fetch_retry(dev, start));
 	memcpy(v, &a, sizeof(a));
 }
=20
@@ -854,7 +860,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, st=
ruct net_device *dev,
 			sizeof(struct rtnl_link_stats64));
 	if (attr =3D=3D NULL)
 		goto nla_put_failure;
-	copy_rtnl_link_stats64(nla_data(attr), stats);
+	copy_rtnl_link_stats64(nla_data(attr), stats, dev);
=20
 	if (dev->dev.parent)
 		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));


