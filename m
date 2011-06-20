From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 4/5] xen: convert to 64 bit stats
	interface
Date: Mon, 20 Jun 2011 13:35:10 -0700
Message-ID: <20110620203602.929964665@vyatta.com>
References: <20110620203506.363818794@vyatta.com>
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com
To: davem@davemloft.net, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline; filename=xen-stats64.patch
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Convert xen driver to 64 bit statistics interface.
Use stats_sync to ensure that 64 bit update is read atomically
on 32 bit platform. Put hot statistics into per-cpu table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - add stats_sync and per-cpu

--- a/drivers/net/xen-netfront.c	2011-06-20 13:34:56.383992463 -0700
+++ b/drivers/net/xen-netfront.c	2011-06-20 13:41:47.207992232 -0700
@@ -70,6 +70,14 @@ struct netfront_cb {
 #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
 #define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
 
+struct netfront_stats {
+	u64			rx_packets;
+	u64			tx_packets;
+	u64			rx_bytes;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
 struct netfront_info {
 	struct list_head list;
 	struct net_device *netdev;
@@ -122,6 +130,8 @@ struct netfront_info {
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 
 	/* Statistics */
+	struct netfront_stats __percpu *stats;
+
 	unsigned long rx_gso_checksum_fixup;
 };
 
@@ -468,6 +478,7 @@ static int xennet_start_xmit(struct sk_b
 {
 	unsigned short id;
 	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_stats *stats = this_cpu_ptr(np->stats);
 	struct xen_netif_tx_request *tx;
 	struct xen_netif_extra_info *extra;
 	char *data = skb->data;
@@ -552,8 +563,10 @@ static int xennet_start_xmit(struct sk_b
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	u64_stats_update_end(&stats->syncp);
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
@@ -847,6 +860,8 @@ out:
 static int handle_incoming_queue(struct net_device *dev,
 				 struct sk_buff_head *rxq)
 {
+	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_stats *stats = this_cpu_ptr(np->stats);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -867,12 +882,13 @@ static int handle_incoming_queue(struct
 		if (checksum_setup(dev, skb)) {
 			kfree_skb(skb);
 			packets_dropped++;
-			dev->stats.rx_errors++;
 			continue;
 		}
 
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += skb->len;
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_packets++;
+		stats->rx_bytes += skb->len;
+		u64_stats_update_end(&stats->syncp);
 
 		/* Pass it up. */
 		netif_receive_skb(skb);
@@ -1034,6 +1050,38 @@ static int xennet_change_mtu(struct net_
 	return 0;
 }
 
+static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
+						    struct rtnl_link_stats64 *tot)
+{
+	struct netfront_info *np = netdev_priv(dev);
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct netfront_stats *stats = per_cpu_ptr(np->stats, cpu);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+
+			rx_packets = stats->rx_packets;
+			tx_packets = stats->tx_packets;
+			rx_bytes = stats->rx_bytes;
+			tx_bytes = stats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->rx_errors  = dev->stats.rx_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+
+	return tot;
+}
+
 static void xennet_release_tx_bufs(struct netfront_info *np)
 {
 	struct sk_buff *skb;
@@ -1182,6 +1230,7 @@ static const struct net_device_ops xenne
 	.ndo_stop            = xennet_close,
 	.ndo_start_xmit      = xennet_start_xmit,
 	.ndo_change_mtu	     = xennet_change_mtu,
+	.ndo_get_stats64     = xennet_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_fix_features    = xennet_fix_features,
@@ -1216,6 +1265,11 @@ static struct net_device * __devinit xen
 	np->rx_refill_timer.data = (unsigned long)netdev;
 	np->rx_refill_timer.function = rx_refill_timeout;
 
+	err = -ENOMEM;
+	np->stats = alloc_percpu(struct netfront_stats);
+	if (np->stats == NULL)
+		goto exit;
+
 	/* Initialise tx_skbs as a free chain containing every entry. */
 	np->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
@@ -1234,7 +1288,7 @@ static struct net_device * __devinit xen
 					  &np->gref_tx_head) < 0) {
 		printk(KERN_ALERT "#### netfront can't alloc tx grant refs\n");
 		err = -ENOMEM;
-		goto exit;
+		goto exit_free_stats;
 	}
 	/* A grant for every rx ring slot */
 	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
@@ -1270,6 +1324,8 @@ static struct net_device * __devinit xen
 
  exit_free_tx:
 	gnttab_free_grant_references(np->gref_tx_head);
+ exit_free_stats:
+	free_percpu(np->stats);
  exit:
 	free_netdev(netdev);
 	return ERR_PTR(err);
@@ -1869,6 +1925,8 @@ static int __devexit xennet_remove(struc
 
 	xennet_sysfs_delif(info->netdev);
 
+	free_percpu(info->stats);
+
 	free_netdev(info->netdev);
 
 	return 0;
>From shemminger@vyatta.com Mon Jun 20 13:36:03 2011
Message-Id: <20110620203603.019928129@vyatta.com>
User-Agent: quilt/0.48-1
Date: Mon, 20 Jun 2011 13:35:11 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Cc: netdev@vger.kernel.org
Subject: [PATCH net-next 5/5] ifb: convert to 64 bit stats
References: <20110620203506.363818794@vyatta.com>
Content-Disposition: inline; filename=ifb-stats64.patch

Convert input functional block device to use 64 bit stats.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - add stats_sync


--- a/drivers/net/ifb.c	2011-06-09 14:39:25.000000000 -0700
+++ b/drivers/net/ifb.c	2011-06-20 13:30:30.135992612 -0700
@@ -41,8 +41,18 @@
 struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
+
 	struct sk_buff_head     rq;
+	u64 rx_packets;
+	u64 rx_bytes;
+	unsigned long rx_dropped;
+
 	struct sk_buff_head     tq;
+	u64 tx_packets;
+	u64 tx_bytes;
+	unsigned long tx_dropped;
+
+	struct u64_stats_sync	stats_sync;
 };
 
 static int numifbs = 2;
@@ -57,7 +67,6 @@ static void ri_tasklet(unsigned long dev
 
 	struct net_device *_dev = (struct net_device *)dev;
 	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
 	struct netdev_queue *txq;
 	struct sk_buff *skb;
 
@@ -77,15 +86,18 @@ static void ri_tasklet(unsigned long dev
 
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
-		stats->tx_packets++;
-		stats->tx_bytes +=skb->len;
+
+		u64_stats_update_begin(&dp->stats_sync);
+		dp->tx_packets++;
+		dp->tx_bytes += skb->len;
+		u64_stats_update_end(&dp->stats_sync);
 
 		rcu_read_lock();
 		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
-			stats->tx_dropped++;
+			dp->tx_dropped++;
 			if (skb_queue_len(&dp->tq) != 0)
 				goto resched;
 			break;
@@ -120,9 +132,33 @@ resched:
 
 }
 
+static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
+					     struct rtnl_link_stats64 *stats)
+{
+	struct ifb_private *dp = netdev_priv(dev);
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin_bh(&dp->stats_sync);
+
+		stats->rx_packets = dp->rx_packets;
+		stats->rx_bytes = dp->rx_bytes;
+		stats->tx_packets = dp->tx_packets;
+		stats->tx_bytes = dp->tx_bytes;
+
+	} while (u64_stats_fetch_retry_bh(&dp->stats_sync, start));
+
+	stats->rx_dropped = dp->rx_dropped;
+	stats->tx_dropped = dp->tx_dropped;
+
+	return stats;
+}
+
+
 static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_open	= ifb_open,
 	.ndo_stop	= ifb_close,
+	.ndo_get_stats64 = ifb_stats64,
 	.ndo_start_xmit	= ifb_xmit,
 	.ndo_validate_addr = eth_validate_addr,
 };
@@ -153,15 +189,16 @@ static void ifb_setup(struct net_device
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
-	stats->rx_packets++;
-	stats->rx_bytes+=skb->len;
+	u64_stats_update_begin(&dp->stats_sync);
+	dp->rx_packets++;
+	dp->rx_bytes += skb->len;
+	u64_stats_update_end(&dp->stats_sync);
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
-		stats->rx_dropped++;
+		dp->rx_dropped++;
 		return NETDEV_TX_OK;
 	}
