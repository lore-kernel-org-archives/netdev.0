From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 V2] net:  fix 64 bit counters on 32 bit arches
Date: Mon, 05 Jul 2010 22:05:22 +0200
Message-ID: <1278360322.2466.90.camel@edumazet-laptop>
References: <1276017594.2185.11.camel@achroite.uk.solarflarecom.com>
	 <1276017672.2185.12.camel@achroite.uk.solarflarecom.com>
	 <1278353780.2877.620.camel@edumazet-laptop>
	 <1278354682.2877.639.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57502 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467Ab0GEUFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 16:05:34 -0400
Received: by fxm14 with SMTP id 14so4037939fxm.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 13:05:32 -0700 (PDT)
In-Reply-To: <1278354682.2877.639.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 20:31 +0200, Eric Dumazet a =C3=A9crit =
:

> One other way would be to add a rtnl_link_stats64 param to
> ndo_get_stats64() method, and ask drivers to copy their stats in this
> zone, instead of returning &dev->stats64 or something...
>=20
> And also change dev_get_stats() with this new parameter.
>=20
> Each caller would use a private copy, with no risk of concurrent
> updates.
>=20
>=20

Here is an updated patch, without added lock but temp storage.

Thanks

[PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit arches

There is a small possibility that a reader gets incorrect values on 32
bit arches. SNMP applications could catch incorrect counters when a
32bit high part is changed by another stats consumer/provider.

One way to solve this is to add a rtnl_link_stats64 param to all=20
ndo_get_stats64() methods, and also add such a parameter to
dev_get_stats().

Rule is that we are not allowed to use dev->stats64 as a temporary
storage for 64bit stats, but a caller provided area (usually on stack)

Old drivers (only providing get_stats() method) need no changes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_main.c   |   64 +++++++++++++---------------
 drivers/net/ixgbe/ixgbe_ethtool.c |    8 ++-
 drivers/net/loopback.c            |    4 -
 drivers/net/macvlan.c             |    6 +-
 drivers/net/sfc/efx.c             |    3 -
 drivers/net/sfc/ethtool.c         |    3 -
 include/linux/netdevice.h         |   12 +++--
 net/8021q/vlan_dev.c              |    6 --
 net/8021q/vlanproc.c              |    3 -
 net/bridge/br_device.c            |    4 -
 net/core/dev.c                    |   25 +++++++---
 net/core/net-sysfs.c              |    4 +
 net/core/rtnetlink.c              |    3 -
 13 files changed, 79 insertions(+), 66 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index a95a41b..9bb9bfa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3804,51 +3804,49 @@ static int bond_close(struct net_device *bond_d=
ev)
 	return 0;
 }
=20
-static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bon=
d_dev)
+static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bon=
d_dev,
+						struct rtnl_link_stats64 *stats)
 {
 	struct bonding *bond =3D netdev_priv(bond_dev);
-	struct rtnl_link_stats64 *stats =3D &bond_dev->stats64;
-	struct rtnl_link_stats64 local_stats;
+	struct rtnl_link_stats64 temp;
 	struct slave *slave;
 	int i;
=20
-	memset(&local_stats, 0, sizeof(local_stats));
+	memset(stats, 0, sizeof(*stats));
=20
 	read_lock_bh(&bond->lock);
=20
 	bond_for_each_slave(bond, slave, i) {
 		const struct rtnl_link_stats64 *sstats =3D
-			dev_get_stats(slave->dev);
-
-		local_stats.rx_packets +=3D sstats->rx_packets;
-		local_stats.rx_bytes +=3D sstats->rx_bytes;
-		local_stats.rx_errors +=3D sstats->rx_errors;
-		local_stats.rx_dropped +=3D sstats->rx_dropped;
-
-		local_stats.tx_packets +=3D sstats->tx_packets;
-		local_stats.tx_bytes +=3D sstats->tx_bytes;
-		local_stats.tx_errors +=3D sstats->tx_errors;
-		local_stats.tx_dropped +=3D sstats->tx_dropped;
-
-		local_stats.multicast +=3D sstats->multicast;
-		local_stats.collisions +=3D sstats->collisions;
-
-		local_stats.rx_length_errors +=3D sstats->rx_length_errors;
-		local_stats.rx_over_errors +=3D sstats->rx_over_errors;
-		local_stats.rx_crc_errors +=3D sstats->rx_crc_errors;
-		local_stats.rx_frame_errors +=3D sstats->rx_frame_errors;
-		local_stats.rx_fifo_errors +=3D sstats->rx_fifo_errors;
-		local_stats.rx_missed_errors +=3D sstats->rx_missed_errors;
-
-		local_stats.tx_aborted_errors +=3D sstats->tx_aborted_errors;
-		local_stats.tx_carrier_errors +=3D sstats->tx_carrier_errors;
-		local_stats.tx_fifo_errors +=3D sstats->tx_fifo_errors;
-		local_stats.tx_heartbeat_errors +=3D sstats->tx_heartbeat_errors;
-		local_stats.tx_window_errors +=3D sstats->tx_window_errors;
+			dev_get_stats(slave->dev, &temp);
+
+		stats->rx_packets +=3D sstats->rx_packets;
+		stats->rx_bytes +=3D sstats->rx_bytes;
+		stats->rx_errors +=3D sstats->rx_errors;
+		stats->rx_dropped +=3D sstats->rx_dropped;
+
+		stats->tx_packets +=3D sstats->tx_packets;
+		stats->tx_bytes +=3D sstats->tx_bytes;
+		stats->tx_errors +=3D sstats->tx_errors;
+		stats->tx_dropped +=3D sstats->tx_dropped;
+
+		stats->multicast +=3D sstats->multicast;
+		stats->collisions +=3D sstats->collisions;
+
+		stats->rx_length_errors +=3D sstats->rx_length_errors;
+		stats->rx_over_errors +=3D sstats->rx_over_errors;
+		stats->rx_crc_errors +=3D sstats->rx_crc_errors;
+		stats->rx_frame_errors +=3D sstats->rx_frame_errors;
+		stats->rx_fifo_errors +=3D sstats->rx_fifo_errors;
+		stats->rx_missed_errors +=3D sstats->rx_missed_errors;
+
+		stats->tx_aborted_errors +=3D sstats->tx_aborted_errors;
+		stats->tx_carrier_errors +=3D sstats->tx_carrier_errors;
+		stats->tx_fifo_errors +=3D sstats->tx_fifo_errors;
+		stats->tx_heartbeat_errors +=3D sstats->tx_heartbeat_errors;
+		stats->tx_window_errors +=3D sstats->tx_window_errors;
 	}
=20
-	memcpy(stats, &local_stats, sizeof(struct net_device_stats));
-
 	read_unlock_bh(&bond->lock);
=20
 	return stats;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 5275e9c..7e85e61 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -55,7 +55,7 @@ struct ixgbe_stats {
 				offsetof(struct ixgbe_adapter, m)
 #define IXGBE_NETDEV_STAT(m)	NETDEV_STATS, \
 				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+				offsetof(struct net_device, m) - offsetof(struct net_device, stats=
)
=20
 static struct ixgbe_stats ixgbe_gstrings_stats[] =3D {
 	{"rx_packets", IXGBE_NETDEV_STAT(stats.rx_packets)},
@@ -998,16 +998,18 @@ static void ixgbe_get_ethtool_stats(struct net_de=
vice *netdev,
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
 	u64 *queue_stat;
 	int stat_count =3D sizeof(struct ixgbe_queue_stats) / sizeof(u64);
+	struct rtnl_link_stats64 temp;
+	const struct rtnl_link_stats64 *net_stats;
 	int j, k;
 	int i;
 	char *p =3D NULL;
=20
 	ixgbe_update_stats(adapter);
-	dev_get_stats(netdev);
+	net_stats =3D dev_get_stats(netdev, &temp);
 	for (i =3D 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 		switch (ixgbe_gstrings_stats[i].type) {
 		case NETDEV_STATS:
-			p =3D (char *) netdev +
+			p =3D (char *) net_stats +
 					ixgbe_gstrings_stats[i].stat_offset;
 			break;
 		case IXGBE_STATS:
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 4dd0510..9a09967 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -98,10 +98,10 @@ static netdev_tx_t loopback_xmit(struct sk_buff *sk=
b,
 	return NETDEV_TX_OK;
 }
=20
-static struct rtnl_link_stats64 *loopback_get_stats64(struct net_devic=
e *dev)
+static struct rtnl_link_stats64 *loopback_get_stats64(struct net_devic=
e *dev,
+						      struct rtnl_link_stats64 *stats)
 {
 	const struct pcpu_lstats __percpu *pcpu_lstats;
-	struct rtnl_link_stats64 *stats =3D &dev->stats64;
 	u64 bytes =3D 0;
 	u64 packets =3D 0;
 	u64 drops =3D 0;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e6d626e..6112f14 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -431,12 +431,12 @@ static void macvlan_uninit(struct net_device *dev=
)
 	free_percpu(vlan->rx_stats);
 }
=20
-static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_de=
vice *dev)
+static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_de=
vice *dev,
+							 struct rtnl_link_stats64 *stats)
 {
-	struct rtnl_link_stats64 *stats =3D &dev->stats64;
 	struct macvlan_dev *vlan =3D netdev_priv(dev);
=20
-	dev_txq_stats_fold(dev, &dev->stats);
+	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
=20
 	if (vlan->rx_stats) {
 		struct macvlan_rx_stats *p, accum =3D {0};
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 35b3f29..ba674c5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1533,11 +1533,10 @@ static int efx_net_stop(struct net_device *net_=
dev)
 }
=20
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
-static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_=
dev)
+static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_=
dev, struct rtnl_link_stats64 *stats)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
-	struct rtnl_link_stats64 *stats =3D &net_dev->stats64;
=20
 	spin_lock_bh(&efx->stats_lock);
 	efx->type->update_stats(efx);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 3b8b0a0..fd19d6a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -469,12 +469,13 @@ static void efx_ethtool_get_stats(struct net_devi=
ce *net_dev,
 	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
 	struct efx_ethtool_stat *stat;
 	struct efx_channel *channel;
+	struct rtnl_link_stats64 temp;
 	int i;
=20
 	EFX_BUG_ON_PARANOID(stats->n_stats !=3D EFX_ETHTOOL_NUM_STATS);
=20
 	/* Update MAC and NIC statistics */
-	dev_get_stats(net_dev);
+	dev_get_stats(net_dev, &temp);
=20
 	/* Fill detailed statistics buffer */
 	for (i =3D 0; i < EFX_ETHTOOL_NUM_STATS; i++) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4d27368..60de653 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -666,7 +666,8 @@ struct netdev_rx_queue {
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
- * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev=
);
+ * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev
+ *                      struct rtnl_link_stats64 *storage);
  * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
  *	Called when a user wants to get the network device usage
  *	statistics. Drivers must do one of the following:
@@ -733,7 +734,8 @@ struct net_device_ops {
 						   struct neigh_parms *);
 	void			(*ndo_tx_timeout) (struct net_device *dev);
=20
-	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev);
+	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
+						     struct rtnl_link_stats64 *storage);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
=20
 	void			(*ndo_vlan_rx_register)(struct net_device *dev,
@@ -2139,8 +2141,10 @@ extern void		netdev_features_change(struct net_d=
evice *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
-extern const struct rtnl_link_stats64 *dev_get_stats(struct net_device=
 *dev);
-extern void		dev_txq_stats_fold(const struct net_device *dev, struct n=
et_device_stats *stats);
+extern const struct rtnl_link_stats64 *dev_get_stats(struct net_device=
 *dev,
+						     struct rtnl_link_stats64 *storage);
+extern void		dev_txq_stats_fold(const struct net_device *dev,
+					   struct net_device_stats *stats);
=20
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c6456cb..7865a4c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -803,11 +803,9 @@ static u32 vlan_ethtool_get_flags(struct net_devic=
e *dev)
 	return dev_ethtool_get_flags(vlan->real_dev);
 }
=20
-static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_devic=
e *dev)
+static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_devic=
e *dev, struct rtnl_link_stats64 *stats)
 {
-	struct rtnl_link_stats64 *stats =3D &dev->stats64;
-
-	dev_txq_stats_fold(dev, &dev->stats);
+	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
=20
 	if (vlan_dev_info(dev)->vlan_rx_stats) {
 		struct vlan_rx_stats *p, accum =3D {0};
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index df56f5c..80e280f 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -278,6 +278,7 @@ static int vlandev_seq_show(struct seq_file *seq, v=
oid *offset)
 {
 	struct net_device *vlandev =3D (struct net_device *) seq->private;
 	const struct vlan_dev_info *dev_info =3D vlan_dev_info(vlandev);
+	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
 	static const char fmt[] =3D "%30s %12lu\n";
 	static const char fmt64[] =3D "%30s %12llu\n";
@@ -286,7 +287,7 @@ static int vlandev_seq_show(struct seq_file *seq, v=
oid *offset)
 	if (!is_vlan_dev(vlandev))
 		return 0;
=20
-	stats =3D dev_get_stats(vlandev);
+	stats =3D dev_get_stats(vlandev, &temp);
 	seq_printf(seq,
 		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
 		   vlandev->name, dev_info->vlan_id,
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index edf639e..075c435 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -98,10 +98,10 @@ static int br_dev_stop(struct net_device *dev)
 	return 0;
 }
=20
-static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev=
)
+static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev=
,
+						struct rtnl_link_stats64 *stats)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
-	struct rtnl_link_stats64 *stats =3D &dev->stats64;
 	struct br_cpu_netstats tmp, sum =3D { 0 };
 	unsigned int cpu;
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index 93b8929..b6d570a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3703,7 +3703,8 @@ void dev_seq_stop(struct seq_file *seq, void *v)
=20
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_devi=
ce *dev)
 {
-	const struct rtnl_link_stats64 *stats =3D dev_get_stats(dev);
+	struct rtnl_link_stats64 temp;
+	const struct rtnl_link_stats64 *stats =3D dev_get_stats(dev, &temp);
=20
 	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9ll=
u "
 		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
@@ -5281,23 +5282,29 @@ EXPORT_SYMBOL(dev_txq_stats_fold);
 /**
  *	dev_get_stats	- get network device statistics
  *	@dev: device to get statistics from
+ *	@storage: place to store stats
  *
  *	Get network statistics from device. The device driver may provide
  *	its own method by setting dev->netdev_ops->get_stats64 or
  *	dev->netdev_ops->get_stats; otherwise the internal statistics
  *	structure is used.
  */
-const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev)
+const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
+					      struct rtnl_link_stats64 *storage)
 {
 	const struct net_device_ops *ops =3D dev->netdev_ops;
=20
-	if (ops->ndo_get_stats64)
-		return ops->ndo_get_stats64(dev);
-	if (ops->ndo_get_stats)
-		return (struct rtnl_link_stats64 *)ops->ndo_get_stats(dev);
-
-	dev_txq_stats_fold(dev, &dev->stats);
-	return &dev->stats64;
+	if (ops->ndo_get_stats64) {
+		memset(storage, 0, sizeof(*storage));
+		return ops->ndo_get_stats64(dev, storage);
+	}
+	if (ops->ndo_get_stats) {
+		memcpy(storage, ops->ndo_get_stats(dev), sizeof(*storage));
+		return storage;
+	}
+	memcpy(storage, &dev->stats, sizeof(*storage));
+	dev_txq_stats_fold(dev, (struct net_device_stats *)storage);
+	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
=20
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index ea3bb4c..914f42b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -330,7 +330,9 @@ static ssize_t netstat_show(const struct device *d,
=20
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
-		const struct rtnl_link_stats64 *stats =3D dev_get_stats(dev);
+		struct rtnl_link_stats64 temp;
+		const struct rtnl_link_stats64 *stats =3D dev_get_stats(dev, &temp);
+
 		ret =3D sprintf(buf, fmt_u64, *(u64 *)(((u8 *) stats) + offset));
 	}
 	read_unlock(&dev_base_lock);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e645778..5e773ea 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -791,6 +791,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, st=
ruct net_device *dev,
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
+	struct rtnl_link_stats64 temp;
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr;
=20
@@ -847,7 +848,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, st=
ruct net_device *dev,
 	if (attr =3D=3D NULL)
 		goto nla_put_failure;
=20
-	stats =3D dev_get_stats(dev);
+	stats =3D dev_get_stats(dev, &temp);
 	copy_rtnl_link_stats(nla_data(attr), stats);
=20
 	attr =3D nla_reserve(skb, IFLA_STATS64,


