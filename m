From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] xen: convert to 64 bit stats interface
Date: Wed, 08 Jun 2011 17:53:58 -0700
Message-ID: <20110609005417.385577995@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com
To: "David S. Miller" <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
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
This driver was already counting packet per queue in a 64 bit value so not
a huge change.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/xen-netfront.c	2011-06-07 19:34:20.752647705 +0900
+++ b/drivers/net/xen-netfront.c	2011-06-07 20:02:11.028930158 +0900
@@ -122,7 +122,14 @@ struct netfront_info {
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 
 	/* Statistics */
-	unsigned long rx_gso_checksum_fixup;
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 rx_errors;
+	u64 rx_gso_checksum_fixup;
+
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 tx_dropped;
 };
 
 struct netfront_rx_info {
@@ -552,8 +559,8 @@ static int xennet_start_xmit(struct sk_b
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
-	dev->stats.tx_bytes += skb->len;
-	dev->stats.tx_packets++;
+	np->tx_bytes += skb->len;
+	np->tx_packets++;
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
@@ -566,7 +573,7 @@ static int xennet_start_xmit(struct sk_b
 	return NETDEV_TX_OK;
 
  drop:
-	dev->stats.tx_dropped++;
+	np->tx_dropped++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -847,6 +854,7 @@ out:
 static int handle_incoming_queue(struct net_device *dev,
 				 struct sk_buff_head *rxq)
 {
+	struct netfront_info *np = netdev_priv(dev);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -867,12 +875,11 @@ static int handle_incoming_queue(struct
 		if (checksum_setup(dev, skb)) {
 			kfree_skb(skb);
 			packets_dropped++;
-			dev->stats.rx_errors++;
 			continue;
 		}
 
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += skb->len;
+		np->rx_packets++;
+		np->rx_bytes += skb->len;
 
 		/* Pass it up. */
 		netif_receive_skb(skb);
@@ -919,7 +926,7 @@ static int xennet_poll(struct napi_struc
 err:
 			while ((skb = __skb_dequeue(&tmpq)))
 				__skb_queue_tail(&errq, skb);
-			dev->stats.rx_errors++;
+			np->rx_errors++;
 			i = np->rx.rsp_cons;
 			continue;
 		}
@@ -1034,6 +1041,22 @@ static int xennet_change_mtu(struct net_
 	return 0;
 }
 
+static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
+						    struct rtnl_link_stats64 *stats)
+{
+	struct netfront_info *np = netdev_priv(dev);
+
+	stats->rx_packets = np->rx_packets;
+	stats->rx_bytes   = np->rx_bytes;
+	stats->rx_errors  = np->rx_errors;
+
+	stats->tx_packets = np->tx_packets;
+	stats->tx_bytes   = np->tx_bytes;
+	stats->tx_bytes   = np->tx_dropped;
+
+	return stats;
+}
+
 static void xennet_release_tx_bufs(struct netfront_info *np)
 {
 	struct sk_buff *skb;
@@ -1182,6 +1205,7 @@ static const struct net_device_ops xenne
 	.ndo_stop            = xennet_close,
 	.ndo_start_xmit      = xennet_start_xmit,
 	.ndo_change_mtu	     = xennet_change_mtu,
+	.ndo_get_stats64     = xennet_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_fix_features    = xennet_fix_features,
