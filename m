From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] net: Enable 64-bit net device statistics on 32-bit
 architectures
Date: Thu, 03 Jun 2010 18:39:04 +0100
Message-ID: <1275586744.2106.22.camel@achroite.uk.solarflarecom.com>
References: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5023 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060Ab0FCRjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 13:39:08 -0400
In-Reply-To: <1275576667.2106.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use struct rtnl_link_stats64 as the statistics structure.

On 32-bit architectures, insert 32 bits of padding after/before each
field of struct net_device_stats to make its layout compatible with
struct rtnl_link_stats64.  Add an anonymous union in net_device; move
stats into the union and add struct rtnl_link_stats64 stats64.

Add net_device_ops::ndo_get_stats64, implementations of which will
return a pointer to struct rtnl_link_stats64.  Drivers that implement
this operation must not update the structure asynchronously.  Change
dev_get_stats() to call this operation if available, and to return a
pointer to struct rtnl_link_stats64.

Define accessor macros for reading rtnl_link_stats64 in a way that
allows for asynchronous atomic updates by drivers that do not
implement ndo_get_stats64.  Change callers of dev_get_stats() to
use these macros when reading the returned structure.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This implements step 1 of the transition I previously proposed, with the
following modifications:

- Use struct rtnl_link_stats64 directly instead of defining an
  identical struct net_device_stats64.
- Do not allow asynchronous writes to struct rtnl_link_stats64. This
  is not possible to do atomically on all architectures, so there is
  little value in allowing it.
- Assume that the padding in struct net_device_stats is cleared by
  drivers if they do not use net_device::stats. Drivers must already
  clear the fields they don't use, such as tx_compressed.

Ben.

 include/linux/if_link.h   |    3 +-
 include/linux/netdevice.h |  112 +++++++++++++++++++++++++++-------------
 net/8021q/vlanproc.c      |   18 ++++--
 net/core/dev.c            |   60 +++++++++++++---------
 net/core/net-sysfs.c      |   13 +++--
 net/core/rtnetlink.c      |  126 ++++++++++++++++++++++-----------------------
 6 files changed, 194 insertions(+), 138 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 85c812d..7fcad2e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -4,7 +4,7 @@
 #include <linux/types.h>
 #include <linux/netlink.h>
 
-/* The struct should be in sync with struct net_device_stats */
+/* This struct should be in sync with struct rtnl_link_stats64 */
 struct rtnl_link_stats {
 	__u32	rx_packets;		/* total packets received	*/
 	__u32	tx_packets;		/* total packets transmitted	*/
@@ -37,6 +37,7 @@ struct rtnl_link_stats {
 	__u32	tx_compressed;
 };
 
+/* The main device statistics structure */
 struct rtnl_link_stats64 {
 	__u64	rx_packets;		/* total packets received	*/
 	__u64	tx_packets;		/* total packets transmitted	*/
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a249161..3f2b49d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -159,45 +159,70 @@ static inline bool dev_xmit_complete(int rc)
 #define MAX_HEADER (LL_MAX_HEADER + 48)
 #endif
 
-#endif  /*  __KERNEL__  */
-
 /*
- *	Network device statistics. Akin to the 2.0 ether stats but
- *	with byte counters.
+ *	Old network device statistics. Fields are native words
+ *	(unsigned long) so they can be read and written atomically.
+ *	Each field is padded to 64 bits for compatibility with
+ *	rtnl_link_stats64.
  */
 
+#if BITS_PER_LONG == 64
+#define NET_DEVICE_STATS_DEFINE(name)	u64 name
+#define RTNL_LINK_STATS64_READ(stats, name)				\
+	ACCESS_ONCE((stats)->name)
+#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
+	ACCESS_ONCE((const u64 *)((const u8 *)(stats) + (offset)))
+#define RTNL_LINK_STATS64_READ32(stats, name)				\
+	((u32)ACCESS_ONCE((stats)->name))
+#else
+#if defined(__LITTLE_ENDIAN)
+#define NET_DEVICE_STATS_DEFINE(name)	u32 name, pad_ ## name
+#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
+	(ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset))) |	\
+	 (u64)(*(const u32 *)((const u8 *)(stats) + (offset) + 4)) << 32)
+#define RTNL_LINK_STATS64_READ32(stats, name)				\
+	(((const volatile u32 *)&(stats)->name)[0])
+#else
+#define NET_DEVICE_STATS_DEFINE(name)	u32 pad_ ## name, name
+#define RTNL_LINK_STATS64_READ_OFFSET(stats, offset)			\
+	((u64)(*(const u32 *)((const u8 *)(stats) + (offset))) << 32 |	\
+	 ACCESS_ONCE(*(const u32 *)((const u8 *)(stats) + (offset) + 4)))
+#define RTNL_LINK_STATS64_READ32(stats, name)				\
+	(((const volatile u32 *)&(stats)->name)[1])
+#endif
+#define RTNL_LINK_STATS64_READ(stats, name)				\
+	RTNL_LINK_STATS64_READ_OFFSET(					\
+		stats, offsetof(struct rtnl_link_stats64, name))
+#endif
+
 struct net_device_stats {
-	unsigned long	rx_packets;		/* total packets received	*/
-	unsigned long	tx_packets;		/* total packets transmitted	*/
-	unsigned long	rx_bytes;		/* total bytes received 	*/
-	unsigned long	tx_bytes;		/* total bytes transmitted	*/
-	unsigned long	rx_errors;		/* bad packets received		*/
-	unsigned long	tx_errors;		/* packet transmit problems	*/
-	unsigned long	rx_dropped;		/* no space in linux buffers	*/
-	unsigned long	tx_dropped;		/* no space available in linux	*/
-	unsigned long	multicast;		/* multicast packets received	*/
-	unsigned long	collisions;
-
-	/* detailed rx_errors: */
-	unsigned long	rx_length_errors;
-	unsigned long	rx_over_errors;		/* receiver ring buff overflow	*/
-	unsigned long	rx_crc_errors;		/* recved pkt with crc error	*/
-	unsigned long	rx_frame_errors;	/* recv'd frame alignment error */
-	unsigned long	rx_fifo_errors;		/* recv'r fifo overrun		*/
-	unsigned long	rx_missed_errors;	/* receiver missed packet	*/
-
-	/* detailed tx_errors */
-	unsigned long	tx_aborted_errors;
-	unsigned long	tx_carrier_errors;
-	unsigned long	tx_fifo_errors;
-	unsigned long	tx_heartbeat_errors;
-	unsigned long	tx_window_errors;
-	
-	/* for cslip etc */
-	unsigned long	rx_compressed;
-	unsigned long	tx_compressed;
+	NET_DEVICE_STATS_DEFINE(rx_packets);
+	NET_DEVICE_STATS_DEFINE(tx_packets);
+	NET_DEVICE_STATS_DEFINE(rx_bytes);
+	NET_DEVICE_STATS_DEFINE(tx_bytes);
+	NET_DEVICE_STATS_DEFINE(rx_errors);
+	NET_DEVICE_STATS_DEFINE(tx_errors);
+	NET_DEVICE_STATS_DEFINE(rx_dropped);
+	NET_DEVICE_STATS_DEFINE(tx_dropped);
+	NET_DEVICE_STATS_DEFINE(multicast);
+	NET_DEVICE_STATS_DEFINE(collisions);
+	NET_DEVICE_STATS_DEFINE(rx_length_errors);
+	NET_DEVICE_STATS_DEFINE(rx_over_errors);
+	NET_DEVICE_STATS_DEFINE(rx_crc_errors);
+	NET_DEVICE_STATS_DEFINE(rx_frame_errors);
+	NET_DEVICE_STATS_DEFINE(rx_fifo_errors);
+	NET_DEVICE_STATS_DEFINE(rx_missed_errors);
+	NET_DEVICE_STATS_DEFINE(tx_aborted_errors);
+	NET_DEVICE_STATS_DEFINE(tx_carrier_errors);
+	NET_DEVICE_STATS_DEFINE(tx_fifo_errors);
+	NET_DEVICE_STATS_DEFINE(tx_heartbeat_errors);
+	NET_DEVICE_STATS_DEFINE(tx_window_errors);
+	NET_DEVICE_STATS_DEFINE(rx_compressed);
+	NET_DEVICE_STATS_DEFINE(tx_compressed);
 };
 
+#endif  /*  __KERNEL__  */
+
 
 /* Media selection options. */
 enum {
@@ -660,10 +685,19 @@ struct netdev_rx_queue {
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
+ * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev);
  * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
  *	Called when a user wants to get the network device usage
- *	statistics. If not defined, the counters in dev->stats will
- *	be used.
+ *	statistics. Drivers must do one of the following:
+ *	1. Define @ndo_get_stats64 to update a rtnl_link_stats64 structure
+ *	   (which should normally be dev->stats64) and return a ponter to
+ *	   it. The structure must not be changed asynchronously.
+ *	2. Define @ndo_get_stats to update a net_device_stats64 structure
+ *	   (which should normally be dev->stats) and return a pointer to
+ *	   it. The structure may be changed asynchronously only if each
+ *	   field is written atomically.
+ *	3. Update dev->stats asynchronously and atomically, and define
+ *	   neither operation.
  *
  * void (*ndo_vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
  *	If device support VLAN receive accleration
@@ -718,6 +752,7 @@ struct net_device_ops {
 						   struct neigh_parms *);
 	void			(*ndo_tx_timeout) (struct net_device *dev);
 
+	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
 	void			(*ndo_vlan_rx_register)(struct net_device *dev,
@@ -867,7 +902,10 @@ struct net_device {
 	int			ifindex;
 	int			iflink;
 
-	struct net_device_stats	stats;
+	union {
+		struct rtnl_link_stats64 stats64;
+		struct net_device_stats stats;
+	};
 
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
@@ -2118,7 +2156,7 @@ extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
-extern const struct net_device_stats *dev_get_stats(struct net_device *dev);
+extern const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev);
 extern void		dev_txq_stats_fold(const struct net_device *dev, struct net_device_stats *stats);
 
 extern int		netdev_max_backlog;
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index afead35..62706f2 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -278,8 +278,9 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
 	const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
-	const struct net_device_stats *stats;
+	const struct rtnl_link_stats64 *stats;
 	static const char fmt[] = "%30s %12lu\n";
+	static const char fmt64[] = "%30s %12llu\n";
 	int i;
 
 	if (!is_vlan_dev(vlandev))
@@ -291,12 +292,17 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 		   vlandev->name, dev_info->vlan_id,
 		   (int)(dev_info->flags & 1), vlandev->priv_flags);
 
-	seq_printf(seq, fmt, "total frames received", stats->rx_packets);
-	seq_printf(seq, fmt, "total bytes received", stats->rx_bytes);
-	seq_printf(seq, fmt, "Broadcast/Multicast Rcvd", stats->multicast);
+	seq_printf(seq, fmt64, "total frames received",
+		   RTNL_LINK_STATS64_READ(stats, rx_packets));
+	seq_printf(seq, fmt64, "total bytes received",
+		   RTNL_LINK_STATS64_READ(stats, rx_bytes));
+	seq_printf(seq, fmt64, "Broadcast/Multicast Rcvd",
+		   RTNL_LINK_STATS64_READ(stats, multicast));
 	seq_puts(seq, "\n");
-	seq_printf(seq, fmt, "total frames transmitted", stats->tx_packets);
-	seq_printf(seq, fmt, "total bytes transmitted", stats->tx_bytes);
+	seq_printf(seq, fmt64, "total frames transmitted",
+		   RTNL_LINK_STATS64_READ(stats, tx_packets));
+	seq_printf(seq, fmt64, "total bytes transmitted",
+		   RTNL_LINK_STATS64_READ(stats, tx_bytes));
 	seq_printf(seq, fmt, "total headroom inc",
 		   dev_info->cnt_inc_headroom_on_tx);
 	seq_printf(seq, fmt, "total encap on xmit",
diff --git a/net/core/dev.c b/net/core/dev.c
index 983a3c1..aa48257 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3686,25 +3686,34 @@ void dev_seq_stop(struct seq_file *seq, void *v)
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
-	const struct net_device_stats *stats = dev_get_stats(dev);
-
-	seq_printf(seq, "%6s: %7lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
-		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
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
+	const struct rtnl_link_stats64 *stats = dev_get_stats(dev);
+
+	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9llu "
+		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
+		   dev->name,
+		   RTNL_LINK_STATS64_READ(stats, rx_bytes),
+		   RTNL_LINK_STATS64_READ(stats, rx_packets),
+		   RTNL_LINK_STATS64_READ(stats, rx_errors),
+		   RTNL_LINK_STATS64_READ(stats, rx_dropped) +
+		   RTNL_LINK_STATS64_READ(stats, rx_missed_errors),
+		   RTNL_LINK_STATS64_READ(stats, rx_fifo_errors),
+		   RTNL_LINK_STATS64_READ(stats, rx_length_errors) +
+		   RTNL_LINK_STATS64_READ(stats, rx_over_errors) +
+		   RTNL_LINK_STATS64_READ(stats, rx_crc_errors) +
+		   RTNL_LINK_STATS64_READ(stats, rx_frame_errors),
+		   RTNL_LINK_STATS64_READ(stats, rx_compressed),
+		   RTNL_LINK_STATS64_READ(stats, multicast),
+		   RTNL_LINK_STATS64_READ(stats, tx_bytes),
+		   RTNL_LINK_STATS64_READ(stats, tx_packets),
+		   RTNL_LINK_STATS64_READ(stats, tx_errors),
+		   RTNL_LINK_STATS64_READ(stats, tx_dropped),
+		   RTNL_LINK_STATS64_READ(stats, tx_fifo_errors),
+		   RTNL_LINK_STATS64_READ(stats, collisions),
+		   RTNL_LINK_STATS64_READ(stats, tx_carrier_errors) +
+		   RTNL_LINK_STATS64_READ(stats, tx_aborted_errors) +
+		   RTNL_LINK_STATS64_READ(stats, tx_window_errors) +
+		   RTNL_LINK_STATS64_READ(stats, tx_heartbeat_errors),
+		   RTNL_LINK_STATS64_READ(stats, tx_compressed));
 }
 
 /*
@@ -5266,18 +5275,21 @@ EXPORT_SYMBOL(dev_txq_stats_fold);
  *	@dev: device to get statistics from
  *
  *	Get network statistics from device. The device driver may provide
- *	its own method by setting dev->netdev_ops->get_stats; otherwise
- *	the internal statistics structure is used.
+ *	its own method by setting dev->netdev_ops->get_stats64 or
+ *	dev->netdev_ops->get_stats; otherwise the internal statistics
+ *	structure is used.
  */
-const struct net_device_stats *dev_get_stats(struct net_device *dev)
+const struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
+	if (ops->ndo_get_stats64)
+		return ops->ndo_get_stats64(dev);
 	if (ops->ndo_get_stats)
-		return ops->ndo_get_stats(dev);
+		return (struct rtnl_link_stats64 *)ops->ndo_get_stats(dev);
 
 	dev_txq_stats_fold(dev, &dev->stats);
-	return &dev->stats;
+	return &dev->stats64;
 }
 EXPORT_SYMBOL(dev_get_stats);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 99e7052..a8dc20d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -29,6 +29,7 @@ static const char fmt_hex[] = "%#x\n";
 static const char fmt_long_hex[] = "%#lx\n";
 static const char fmt_dec[] = "%d\n";
 static const char fmt_ulong[] = "%lu\n";
+static const char fmt_u64[] = "%llu\n";
 
 static inline int dev_isalive(const struct net_device *dev)
 {
@@ -324,14 +325,14 @@ static ssize_t netstat_show(const struct device *d,
 	struct net_device *dev = to_net_dev(d);
 	ssize_t ret = -EINVAL;
 
-	WARN_ON(offset > sizeof(struct net_device_stats) ||
-			offset % sizeof(unsigned long) != 0);
+	WARN_ON(offset > sizeof(struct rtnl_link_stats64) ||
+			offset % sizeof(u64) != 0);
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
-		const struct net_device_stats *stats = dev_get_stats(dev);
-		ret = sprintf(buf, fmt_ulong,
-			      *(unsigned long *)(((u8 *) stats) + offset));
+		const struct rtnl_link_stats64 *stats = dev_get_stats(dev);
+		ret = sprintf(buf, fmt_u64,
+			      RTNL_LINK_STATS64_READ_OFFSET(stats, offset));
 	}
 	read_unlock(&dev_base_lock);
 	return ret;
@@ -343,7 +344,7 @@ static ssize_t show_##name(struct device *d,				\
 			   struct device_attribute *attr, char *buf) 	\
 {									\
 	return netstat_show(d, attr, buf,				\
-			    offsetof(struct net_device_stats, name));	\
+			    offsetof(struct rtnl_link_stats64, name));	\
 }									\
 static DEVICE_ATTR(name, S_IRUGO, show_##name, NULL)
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1a2af24..8b131ad 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -579,69 +579,67 @@ static unsigned int rtnl_dev_combine_flags(const struct net_device *dev,
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
-				 const struct net_device_stats *b)
+				 const struct rtnl_link_stats64 *b)
 {
-	a->rx_packets = b->rx_packets;
-	a->tx_packets = b->tx_packets;
-	a->rx_bytes = b->rx_bytes;
-	a->tx_bytes = b->tx_bytes;
-	a->rx_errors = b->rx_errors;
-	a->tx_errors = b->tx_errors;
-	a->rx_dropped = b->rx_dropped;
-	a->tx_dropped = b->tx_dropped;
-
-	a->multicast = b->multicast;
-	a->collisions = b->collisions;
-
-	a->rx_length_errors = b->rx_length_errors;
-	a->rx_over_errors = b->rx_over_errors;
-	a->rx_crc_errors = b->rx_crc_errors;
-	a->rx_frame_errors = b->rx_frame_errors;
-	a->rx_fifo_errors = b->rx_fifo_errors;
-	a->rx_missed_errors = b->rx_missed_errors;
-
-	a->tx_aborted_errors = b->tx_aborted_errors;
-	a->tx_carrier_errors = b->tx_carrier_errors;
-	a->tx_fifo_errors = b->tx_fifo_errors;
-	a->tx_heartbeat_errors = b->tx_heartbeat_errors;
-	a->tx_window_errors = b->tx_window_errors;
-
-	a->rx_compressed = b->rx_compressed;
-	a->tx_compressed = b->tx_compressed;
+	a->rx_packets = RTNL_LINK_STATS64_READ32(b, rx_packets);
+	a->tx_packets = RTNL_LINK_STATS64_READ32(b, tx_packets);
+	a->rx_bytes = RTNL_LINK_STATS64_READ32(b, rx_bytes);
+	a->tx_bytes = RTNL_LINK_STATS64_READ32(b, tx_bytes);
+	a->rx_errors = RTNL_LINK_STATS64_READ32(b, rx_errors);
+	a->tx_errors = RTNL_LINK_STATS64_READ32(b, tx_errors);
+	a->rx_dropped = RTNL_LINK_STATS64_READ32(b, rx_dropped);
+	a->tx_dropped = RTNL_LINK_STATS64_READ32(b, tx_dropped);
+
+	a->multicast = RTNL_LINK_STATS64_READ32(b, multicast);
+	a->collisions = RTNL_LINK_STATS64_READ32(b, collisions);
+
+	a->rx_length_errors = RTNL_LINK_STATS64_READ32(b, rx_length_errors);
+	a->rx_over_errors = RTNL_LINK_STATS64_READ32(b, rx_over_errors);
+	a->rx_crc_errors = RTNL_LINK_STATS64_READ32(b, rx_crc_errors);
+	a->rx_frame_errors = RTNL_LINK_STATS64_READ32(b, rx_frame_errors);
+	a->rx_fifo_errors = RTNL_LINK_STATS64_READ32(b, rx_fifo_errors);
+	a->rx_missed_errors = RTNL_LINK_STATS64_READ32(b, rx_missed_errors);
+
+	a->tx_aborted_errors = RTNL_LINK_STATS64_READ32(b, tx_aborted_errors);
+	a->tx_carrier_errors = RTNL_LINK_STATS64_READ32(b, tx_carrier_errors);
+	a->tx_fifo_errors = RTNL_LINK_STATS64_READ32(b, tx_fifo_errors);
+	a->tx_heartbeat_errors = RTNL_LINK_STATS64_READ32(b, tx_heartbeat_errors);
+	a->tx_window_errors = RTNL_LINK_STATS64_READ32(b, tx_window_errors);
+
+	a->rx_compressed = RTNL_LINK_STATS64_READ32(b, rx_compressed);
+	a->tx_compressed = RTNL_LINK_STATS64_READ32(b, tx_compressed);
 }
 
-static void copy_rtnl_link_stats64(void *v, const struct net_device_stats *b)
+static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
+				   const struct rtnl_link_stats64 *b)
 {
-	struct rtnl_link_stats64 a;
-
-	a.rx_packets = b->rx_packets;
-	a.tx_packets = b->tx_packets;
-	a.rx_bytes = b->rx_bytes;
-	a.tx_bytes = b->tx_bytes;
-	a.rx_errors = b->rx_errors;
-	a.tx_errors = b->tx_errors;
-	a.rx_dropped = b->rx_dropped;
-	a.tx_dropped = b->tx_dropped;
-
-	a.multicast = b->multicast;
-	a.collisions = b->collisions;
-
-	a.rx_length_errors = b->rx_length_errors;
-	a.rx_over_errors = b->rx_over_errors;
-	a.rx_crc_errors = b->rx_crc_errors;
-	a.rx_frame_errors = b->rx_frame_errors;
-	a.rx_fifo_errors = b->rx_fifo_errors;
-	a.rx_missed_errors = b->rx_missed_errors;
-
-	a.tx_aborted_errors = b->tx_aborted_errors;
-	a.tx_carrier_errors = b->tx_carrier_errors;
-	a.tx_fifo_errors = b->tx_fifo_errors;
-	a.tx_heartbeat_errors = b->tx_heartbeat_errors;
-	a.tx_window_errors = b->tx_window_errors;
-
-	a.rx_compressed = b->rx_compressed;
-	a.tx_compressed = b->tx_compressed;
-	memcpy(v, &a, sizeof(a));
+	a->rx_packets = RTNL_LINK_STATS64_READ(b, rx_packets);
+	a->tx_packets = RTNL_LINK_STATS64_READ(b, tx_packets);
+	a->rx_bytes = RTNL_LINK_STATS64_READ(b, rx_bytes);
+	a->tx_bytes = RTNL_LINK_STATS64_READ(b, tx_bytes);
+	a->rx_errors = RTNL_LINK_STATS64_READ(b, rx_errors);
+	a->tx_errors = RTNL_LINK_STATS64_READ(b, tx_errors);
+	a->rx_dropped = RTNL_LINK_STATS64_READ(b, rx_dropped);
+	a->tx_dropped = RTNL_LINK_STATS64_READ(b, tx_dropped);
+
+	a->multicast = RTNL_LINK_STATS64_READ(b, multicast);
+	a->collisions = RTNL_LINK_STATS64_READ(b, collisions);
+
+	a->rx_length_errors = RTNL_LINK_STATS64_READ(b, rx_length_errors);
+	a->rx_over_errors = RTNL_LINK_STATS64_READ(b, rx_over_errors);
+	a->rx_crc_errors = RTNL_LINK_STATS64_READ(b, rx_crc_errors);
+	a->rx_frame_errors = RTNL_LINK_STATS64_READ(b, rx_frame_errors);
+	a->rx_fifo_errors = RTNL_LINK_STATS64_READ(b, rx_fifo_errors);
+	a->rx_missed_errors = RTNL_LINK_STATS64_READ(b, rx_missed_errors);
+
+	a->tx_aborted_errors = RTNL_LINK_STATS64_READ(b, tx_aborted_errors);
+	a->tx_carrier_errors = RTNL_LINK_STATS64_READ(b, tx_carrier_errors);
+	a->tx_fifo_errors = RTNL_LINK_STATS64_READ(b, tx_fifo_errors);
+	a->tx_heartbeat_errors = RTNL_LINK_STATS64_READ(b, tx_heartbeat_errors);
+	a->tx_window_errors = RTNL_LINK_STATS64_READ(b, tx_window_errors);
+
+	a->rx_compressed = RTNL_LINK_STATS64_READ(b, rx_compressed);
+	a->tx_compressed = RTNL_LINK_STATS64_READ(b, tx_compressed);
 }
 
 /* All VF info */
@@ -791,7 +789,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	const struct net_device_stats *stats;
+	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

