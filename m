From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/33] netdev: introduce dev_get_stats()
Date: Mon, 17 Nov 2008 15:42:09 -0800
Message-ID: <20081117234354.948324675@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55038 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792AbYKQX75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:57 -0500
Content-Disposition: inline; filename=netdev-ops_stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order for the network device ops get_stats call to be immutable, the handling
of the default internal network device stats block has to be changed. Add a new
helper function which replaces the old use of internal_get_stats.

Note: change return code to make it clear that the caller should not
go changing the returned statistics.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 arch/s390/appldata/appldata_net_sum.c |    4 ++--
 drivers/net/bonding/bond_main.c       |    5 +++--
 drivers/net/sfc/ethtool.c             |    2 +-
 drivers/parisc/led.c                  |    4 ++--
 include/linux/netdevice.h             |    4 +++-
 net/core/dev.c                        |   23 ++++++++++++++++++-----
 net/core/net-sysfs.c                  |    3 +--
 net/core/rtnetlink.c                  |    6 +++---
 8 files changed, 33 insertions(+), 18 deletions(-)

--- a/arch/s390/appldata/appldata_net_sum.c	2008-11-17 14:53:08.000000000 -0800
+++ b/arch/s390/appldata/appldata_net_sum.c	2008-11-17 15:06:14.000000000 -0800
@@ -67,7 +67,6 @@ static void appldata_get_net_sum_data(vo
 	int i;
 	struct appldata_net_sum_data *net_data;
 	struct net_device *dev;
-	struct net_device_stats *stats;
 	unsigned long rx_packets, tx_packets, rx_bytes, tx_bytes, rx_errors,
 			tx_errors, rx_dropped, tx_dropped, collisions;
 
@@ -86,7 +85,8 @@ static void appldata_get_net_sum_data(vo
 	collisions = 0;
 	read_lock(&dev_base_lock);
 	for_each_netdev(&init_net, dev) {
-		stats = dev->get_stats(dev);
+		const struct net_device_stats *stats = dev_get_stats(dev);
+
 		rx_packets += stats->rx_packets;
 		tx_packets += stats->tx_packets;
 		rx_bytes   += stats->rx_bytes;
--- a/drivers/net/bonding/bond_main.c	2008-11-17 14:53:08.000000000 -0800
+++ b/drivers/net/bonding/bond_main.c	2008-11-17 15:06:14.000000000 -0800
@@ -3899,7 +3899,7 @@ static int bond_close(struct net_device 
 static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct net_device_stats *stats = &(bond->stats), *sstats;
+	struct net_device_stats *stats = &bond->stats;
 	struct net_device_stats local_stats;
 	struct slave *slave;
 	int i;
@@ -3909,7 +3909,8 @@ static struct net_device_stats *bond_get
 	read_lock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
-		sstats = slave->dev->get_stats(slave->dev);
+		const struct net_device_stats *sstats = dev_get_stats(slave->dev);
+
 		local_stats.rx_packets += sstats->rx_packets;
 		local_stats.rx_bytes += sstats->rx_bytes;
 		local_stats.rx_errors += sstats->rx_errors;
--- a/drivers/net/sfc/ethtool.c	2008-11-17 14:53:09.000000000 -0800
+++ b/drivers/net/sfc/ethtool.c	2008-11-17 15:06:14.000000000 -0800
@@ -426,7 +426,7 @@ static void efx_ethtool_get_stats(struct
 	EFX_BUG_ON_PARANOID(stats->n_stats != EFX_ETHTOOL_NUM_STATS);
 
 	/* Update MAC and NIC statistics */
-	net_dev->get_stats(net_dev);
+	dev_get_stats(net_dev);
 
 	/* Fill detailed statistics buffer */
 	for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++) {
--- a/drivers/parisc/led.c	2008-11-17 14:53:09.000000000 -0800
+++ b/drivers/parisc/led.c	2008-11-17 15:06:14.000000000 -0800
@@ -360,13 +360,13 @@ static __inline__ int led_get_net_activi
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
 	for_each_netdev(&init_net, dev) {
-	    struct net_device_stats *stats;
+	    const struct net_device_stats *stats;
 	    struct in_device *in_dev = __in_dev_get_rcu(dev);
 	    if (!in_dev || !in_dev->ifa_list)
 		continue;
 	    if (ipv4_is_loopback(in_dev->ifa_list->ifa_local))
 		continue;
-	    stats = dev->get_stats(dev);
+	    stats = dev_get_stats(dev);
 	    rx_total += stats->rx_packets;
 	    tx_total += stats->tx_packets;
 	}
--- a/include/linux/netdevice.h	2008-11-17 15:05:16.000000000 -0800
+++ b/include/linux/netdevice.h	2008-11-17 15:06:14.000000000 -0800
@@ -865,8 +865,8 @@ struct net_device
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		void                    (*poll_controller)(struct net_device *dev);
 #endif
-#endif
 	};
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -1780,6 +1780,8 @@ extern void		netdev_features_change(stru
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
+extern const struct net_device_stats *dev_get_stats(struct net_device *dev);
+
 extern int		netdev_max_backlog;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
--- a/net/core/dev.c	2008-11-17 14:53:24.000000000 -0800
+++ b/net/core/dev.c	2008-11-17 15:06:14.000000000 -0800
@@ -2620,7 +2620,7 @@ void dev_seq_stop(struct seq_file *seq, 
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
-	struct net_device_stats *stats = dev->get_stats(dev);
+	const struct net_device_stats *stats = dev_get_stats(dev);
 
 	seq_printf(seq, "%6s:%8lu %7lu %4lu %4lu %4lu %5lu %10lu %9lu "
 		   "%8lu %7lu %4lu %4lu %4lu %5lu %7lu %10lu\n",
@@ -4286,10 +4286,24 @@ void netdev_run_todo(void)
 	}
 }
 
-static struct net_device_stats *internal_stats(struct net_device *dev)
-{
-	return &dev->stats;
+/**
+ *	dev_get_stats	- get network device statistics
+ *	@dev: device to get statistics from
+ *
+ *	Get network statistics from device. The device driver may provide
+ *	its own method by setting dev->netdev_ops->get_stats; otherwise
+ *	the internal statistics structure is used.
+ */
+const struct net_device_stats *dev_get_stats(struct net_device *dev)
+ {
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (ops->get_stats)
+		return ops->get_stats(dev);
+	else
+		return &dev->stats;
 }
+EXPORT_SYMBOL(dev_get_stats);
 
 static void netdev_init_one_queue(struct net_device *dev,
 				  struct netdev_queue *queue,
@@ -4368,7 +4382,6 @@ struct net_device *alloc_netdev_mq(int s
 
 	netdev_init_queues(dev);
 
-	dev->get_stats = internal_stats;
 	netpoll_netdev_init(dev);
 	setup(dev);
 	strcpy(dev->name, name);
--- a/net/core/net-sysfs.c	2008-11-17 14:53:08.000000000 -0800
+++ b/net/core/net-sysfs.c	2008-11-17 15:06:14.000000000 -0800
@@ -270,7 +270,6 @@ static ssize_t netstat_show(const struct
 			    unsigned long offset)
 {
 	struct net_device *dev = to_net_dev(d);
-	struct net_device_stats *stats;
 	ssize_t ret = -EINVAL;
 
 	WARN_ON(offset > sizeof(struct net_device_stats) ||
@@ -278,7 +277,7 @@ static ssize_t netstat_show(const struct
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
-		stats = dev->get_stats(dev);
+		const struct net_device_stats *stats = dev_get_stats(dev);
 		ret = sprintf(buf, fmt_ulong,
 			      *(unsigned long *)(((u8 *) stats) + offset));
 	}
--- a/net/core/rtnetlink.c	2008-11-17 14:53:24.000000000 -0800
+++ b/net/core/rtnetlink.c	2008-11-17 15:06:14.000000000 -0800
@@ -551,7 +551,7 @@ static void set_operstate(struct net_dev
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
-				 struct net_device_stats *b)
+				 const struct net_device_stats *b)
 {
 	a->rx_packets = b->rx_packets;
 	a->tx_packets = b->tx_packets;
@@ -609,7 +609,7 @@ static int rtnl_fill_ifinfo(struct sk_bu
 	struct netdev_queue *txq;
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	struct net_device_stats *stats;
+	const struct net_device_stats *stats;
 	struct nlattr *attr;
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -666,7 +666,7 @@ static int rtnl_fill_ifinfo(struct sk_bu
 	if (attr == NULL)
 		goto nla_put_failure;
 
-	stats = dev->get_stats(dev);
+	stats = dev_get_stats(dev);
 	copy_rtnl_link_stats(nla_data(attr), stats);
 
 	if (dev->rtnl_link_ops) {

-- 

