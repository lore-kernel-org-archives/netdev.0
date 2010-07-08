From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] net: Get rid of rtnl_link_stats64 /
 net_device_stats union
Date: Fri, 09 Jul 2010 00:29:21 +0100
Message-ID: <1278631762.16013.307.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25623 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758771Ab0GHX3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 19:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b "net: Enable 64-bit
net device statistics on 32-bit architectures" I redefined struct
net_device_stats so that it could be used in a union with struct
rtnl_link_stats64, avoiding the need for explicit copying or
conversion between the two.  However, this is unsafe because there is
no locking required and no lock consistently held around calls to
dev_get_stats() and use of the statistics structure it returns.

In commit 28172739f0a276eb8d6ca917b3974c2edb036da3 "net: fix 64 bit
counters on 32 bit arches" Eric Dumazet dealt with that problem by
requiring callers of dev_get_stats() to provide storage for the
result.  This means that the net_device::stats64 field and the padding
in struct net_device_stats are now redundant, so remove them.

Update the comment on net_device_ops::ndo_get_stats64 to reflect its
new usage.

Change dev_txq_stats_fold() to use struct rtnl_link_stats64, since
that is what all its callers are really using and it is no longer
going to be compatible with struct net_device_stats.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/macvlan.c     |    2 +-
 include/linux/netdevice.h |   70 ++++++++++++++++++---------------------------
 net/8021q/vlan_dev.c      |    2 +-
 net/core/dev.c            |   19 +++++++++---
 4 files changed, 44 insertions(+), 49 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6112f14..1b28aae 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -436,7 +436,7 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
+	dev_txq_stats_fold(dev, stats);
 
 	if (vlan->rx_stats) {
 		struct macvlan_rx_stats *p, accum = {0};
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8018f6b..17e95e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -162,42 +162,32 @@ static inline bool dev_xmit_complete(int rc)
 /*
  *	Old network device statistics. Fields are native words
  *	(unsigned long) so they can be read and written atomically.
- *	Each field is padded to 64 bits for compatibility with
- *	rtnl_link_stats64.
  */
 
-#if BITS_PER_LONG == 64
-#define NET_DEVICE_STATS_DEFINE(name)	unsigned long name
-#elif defined(__LITTLE_ENDIAN)
-#define NET_DEVICE_STATS_DEFINE(name)	unsigned long name, pad_ ## name
-#else
-#define NET_DEVICE_STATS_DEFINE(name)	unsigned long pad_ ## name, name
-#endif
-
 struct net_device_stats {
-	NET_DEVICE_STATS_DEFINE(rx_packets);
-	NET_DEVICE_STATS_DEFINE(tx_packets);
-	NET_DEVICE_STATS_DEFINE(rx_bytes);
-	NET_DEVICE_STATS_DEFINE(tx_bytes);
-	NET_DEVICE_STATS_DEFINE(rx_errors);
-	NET_DEVICE_STATS_DEFINE(tx_errors);
-	NET_DEVICE_STATS_DEFINE(rx_dropped);
-	NET_DEVICE_STATS_DEFINE(tx_dropped);
-	NET_DEVICE_STATS_DEFINE(multicast);
-	NET_DEVICE_STATS_DEFINE(collisions);
-	NET_DEVICE_STATS_DEFINE(rx_length_errors);
-	NET_DEVICE_STATS_DEFINE(rx_over_errors);
-	NET_DEVICE_STATS_DEFINE(rx_crc_errors);
-	NET_DEVICE_STATS_DEFINE(rx_frame_errors);
-	NET_DEVICE_STATS_DEFINE(rx_fifo_errors);
-	NET_DEVICE_STATS_DEFINE(rx_missed_errors);
-	NET_DEVICE_STATS_DEFINE(tx_aborted_errors);
-	NET_DEVICE_STATS_DEFINE(tx_carrier_errors);
-	NET_DEVICE_STATS_DEFINE(tx_fifo_errors);
-	NET_DEVICE_STATS_DEFINE(tx_heartbeat_errors);
-	NET_DEVICE_STATS_DEFINE(tx_window_errors);
-	NET_DEVICE_STATS_DEFINE(rx_compressed);
-	NET_DEVICE_STATS_DEFINE(tx_compressed);
+	unsigned long	rx_packets;
+	unsigned long	tx_packets;
+	unsigned long	rx_bytes;
+	unsigned long	tx_bytes;
+	unsigned long	rx_errors;
+	unsigned long	tx_errors;
+	unsigned long	rx_dropped;
+	unsigned long	tx_dropped;
+	unsigned long	multicast;
+	unsigned long	collisions;
+	unsigned long	rx_length_errors;
+	unsigned long	rx_over_errors;
+	unsigned long	rx_crc_errors;
+	unsigned long	rx_frame_errors;
+	unsigned long	rx_fifo_errors;
+	unsigned long	rx_missed_errors;
+	unsigned long	tx_aborted_errors;
+	unsigned long	tx_carrier_errors;
+	unsigned long	tx_fifo_errors;
+	unsigned long	tx_heartbeat_errors;
+	unsigned long	tx_window_errors;
+	unsigned long	rx_compressed;
+	unsigned long	tx_compressed;
 };
 
 #endif  /*  __KERNEL__  */
@@ -666,14 +656,13 @@ struct netdev_rx_queue {
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
- * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev
+ * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
  *                      struct rtnl_link_stats64 *storage);
  * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
  *	Called when a user wants to get the network device usage
  *	statistics. Drivers must do one of the following:
- *	1. Define @ndo_get_stats64 to update a rtnl_link_stats64 structure
- *	   (which should normally be dev->stats64) and return a ponter to
- *	   it. The structure must not be changed asynchronously.
+ *	1. Define @ndo_get_stats64 to fill in a zero-initialised
+ *	   rtnl_link_stats64 structure passed by the caller.
  *	2. Define @ndo_get_stats to update a net_device_stats structure
  *	   (which should normally be dev->stats) and return a pointer to
  *	   it. The structure may be changed asynchronously only if each
@@ -888,10 +877,7 @@ struct net_device {
 	int			ifindex;
 	int			iflink;
 
-	union {
-		struct rtnl_link_stats64 stats64;
-		struct net_device_stats stats;
-	};
+	struct net_device_stats	stats;
 
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
@@ -2147,7 +2133,7 @@ extern void		dev_mcast_init(void);
 extern const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 						     struct rtnl_link_stats64 *storage);
 extern void		dev_txq_stats_fold(const struct net_device *dev,
-					   struct net_device_stats *stats);
+					   struct rtnl_link_stats64 *stats);
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7865a4c..e66c9bf 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -805,7 +805,7 @@ static u32 vlan_ethtool_get_flags(struct net_device *dev)
 
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
-	dev_txq_stats_fold(dev, (struct net_device_stats *)stats);
+	dev_txq_stats_fold(dev, stats);
 
 	if (vlan_dev_info(dev)->vlan_rx_stats) {
 		struct vlan_rx_stats *p, accum = {0};
diff --git a/net/core/dev.c b/net/core/dev.c
index eb4201c..5ec2eec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5274,10 +5274,10 @@ void netdev_run_todo(void)
 /**
  *	dev_txq_stats_fold - fold tx_queues stats
  *	@dev: device to get statistics from
- *	@stats: struct net_device_stats to hold results
+ *	@stats: struct rtnl_link_stats64 to hold results
  */
 void dev_txq_stats_fold(const struct net_device *dev,
-			struct net_device_stats *stats)
+			struct rtnl_link_stats64 *stats)
 {
 	unsigned long tx_bytes = 0, tx_packets = 0, tx_dropped = 0;
 	unsigned int i;
@@ -5311,17 +5311,26 @@ const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					      struct rtnl_link_stats64 *storage)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	size_t i, n = sizeof(*storage) / sizeof(u64);
+	u64 *stats64 = (u64 *)storage;
+	const unsigned long *stats;
 
 	if (ops->ndo_get_stats64) {
 		memset(storage, 0, sizeof(*storage));
 		return ops->ndo_get_stats64(dev, storage);
 	}
+
 	if (ops->ndo_get_stats) {
-		memcpy(storage, ops->ndo_get_stats(dev), sizeof(*storage));
+		stats = (const unsigned long *)ops->ndo_get_stats(dev);
+		for (i = 0; i < n; i++)
+			stats64[i] = stats[i];
 		return storage;
 	}
-	memcpy(storage, &dev->stats, sizeof(*storage));
-	dev_txq_stats_fold(dev, (struct net_device_stats *)storage);
+
+	stats = (const unsigned long *)&dev->stats;
+	for (i = 0; i < n; i++)
+		stats64[i] = stats[i];
+	dev_txq_stats_fold(dev, storage);
 	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

