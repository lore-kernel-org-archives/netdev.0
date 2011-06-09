From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] ifb: convert to 64 bit stats
Date: Wed, 08 Jun 2011 17:54:00 -0700
Message-ID: <20110609005417.507470402@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572Ab1FIBQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:30 -0400
Content-Disposition: inline; filename=ifb-stats64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert input functional block device to use 64 bit stats.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ifb.c	2011-06-07 16:58:31.317079332 -0700
+++ b/drivers/net/ifb.c	2011-06-07 17:29:02.958161955 -0700
@@ -42,7 +42,14 @@ struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
 	struct sk_buff_head     rq;
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_dropped;
+
 	struct sk_buff_head     tq;
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 tx_dropped;
 };
 
 static int numifbs = 2;
@@ -57,7 +64,6 @@ static void ri_tasklet(unsigned long dev
 
 	struct net_device *_dev = (struct net_device *)dev;
 	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
 	struct netdev_queue *txq;
 	struct sk_buff *skb;
 
@@ -77,15 +83,16 @@ static void ri_tasklet(unsigned long dev
 
 		skb->tc_verd = 0;
 		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
-		stats->tx_packets++;
-		stats->tx_bytes +=skb->len;
+
+		dp->tx_packets++;
+		dp->tx_bytes +=skb->len;
 
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
@@ -120,9 +127,26 @@ resched:
 
 }
 
+static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
+					     struct rtnl_link_stats64 *stats)
+{
+	struct ifb_private *dp = netdev_priv(dev);
+
+	stats->rx_packets = dp->rx_packets;
+	stats->rx_bytes = dp->rx_bytes;
+	stats->rx_dropped = dp->rx_dropped;
+	stats->tx_packets = dp->tx_packets;
+	stats->tx_bytes = dp->tx_bytes;
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
@@ -153,15 +177,14 @@ static void ifb_setup(struct net_device
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
-	stats->rx_packets++;
-	stats->rx_bytes+=skb->len;
+	dp->rx_packets++;
+	dp->rx_bytes+=skb->len;
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
-		stats->rx_dropped++;
+		dp->rx_dropped++;
 		return NETDEV_TX_OK;
 	}
 


