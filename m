From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 5/5] ifb: convert to 64 bit stats
Date: Mon, 20 Jun 2011 14:12:53 -0700
Message-ID: <20110620141253.00249218@nehalam.ftrdhcpuser.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620.135607.2158729745388010853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60371 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab1FTVM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 17:12:56 -0400
In-Reply-To: <20110620.135607.2158729745388010853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert input functional block device to use 64 bit stats.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - add stats_sync


--- a/drivers/net/ifb.c	2011-06-20 13:38:54.271992329 -0700
+++ b/drivers/net/ifb.c	2011-06-20 14:11:30.935991232 -0700
@@ -41,8 +41,16 @@
 struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
+
+	struct u64_stats_sync	stats_sync;
+
 	struct sk_buff_head     rq;
+	u64 rx_packets;
+	u64 rx_bytes;
+
 	struct sk_buff_head     tq;
+	u64 tx_packets;
+	u64 tx_bytes;
 };
 
 static int numifbs = 2;
@@ -54,10 +62,8 @@ static int ifb_close(struct net_device *
 
 static void ri_tasklet(unsigned long dev)
 {
-
 	struct net_device *_dev = (struct net_device *)dev;
 	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
 	struct netdev_queue *txq;
 	struct sk_buff *skb;
 
@@ -77,15 +83,18 @@ static void ri_tasklet(unsigned long dev
 
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
+			_dev->stats.tx_dropped++;
 			if (skb_queue_len(&dp->tq) != 0)
 				goto resched;
 			break;
@@ -120,9 +129,33 @@ resched:
 
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
+	stats->rx_dropped = dev->stats.rx_dropped;
+	stats->tx_dropped = dev->stats.tx_dropped;
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
@@ -153,15 +186,16 @@ static void ifb_setup(struct net_device
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
+		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
 	}
 
