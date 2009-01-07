From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 35/42] xpnet: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:51 -0800
Message-ID: <20090107003349.257844151@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60713 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754923AbZAGAyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:10 -0500
Content-Disposition: inline; filename=xpnet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/misc/sgi-xp/xpnet.c	2009-01-03 22:31:54.138766578 -0800
+++ b/drivers/misc/sgi-xp/xpnet.c	2009-01-03 22:44:08.668261847 -0800
@@ -95,11 +95,6 @@ struct xpnet_pending_msg {
 	atomic_t use_count;
 };
 
-/* driver specific structure pointed to by the device structure */
-struct xpnet_dev_private {
-	struct net_device_stats stats;
-};
-
 struct net_device *xpnet_device;
 
 /*
@@ -153,7 +148,6 @@ xpnet_receive(short partid, int channel,
 	struct sk_buff *skb;
 	void *dst;
 	enum xp_retval ret;
-	struct xpnet_dev_private *priv = netdev_priv(xpnet_device);
 
 	if (!XPNET_VALID_MSG(msg)) {
 		/*
@@ -161,7 +155,7 @@ xpnet_receive(short partid, int channel,
 		 */
 		xpc_received(partid, channel, (void *)msg);
 
-		priv->stats.rx_errors++;
+		xpnet_device->stats.rx_errors++;
 
 		return;
 	}
@@ -176,7 +170,7 @@ xpnet_receive(short partid, int channel,
 
 		xpc_received(partid, channel, (void *)msg);
 
-		priv->stats.rx_errors++;
+		xpnet_device->stats.rx_errors++;
 
 		return;
 	}
@@ -226,7 +220,7 @@ xpnet_receive(short partid, int channel,
 
 			xpc_received(partid, channel, (void *)msg);
 
-			priv->stats.rx_errors++;
+			xpnet_device->stats.rx_errors++;
 
 			return;
 		}
@@ -247,8 +241,8 @@ xpnet_receive(short partid, int channel,
 		skb_end_pointer(skb), skb->len);
 
 	xpnet_device->last_rx = jiffies;
-	priv->stats.rx_packets++;
-	priv->stats.rx_bytes += skb->len + ETH_HLEN;
+	xpnet_device->stats.rx_packets++;
+	xpnet_device->stats.rx_bytes += skb->len + ETH_HLEN;
 
 	netif_rx_ni(skb);
 	xpc_received(partid, channel, (void *)msg);
@@ -353,26 +347,6 @@ xpnet_dev_change_mtu(struct net_device *
 }
 
 /*
- * Required for the net_device structure.
- */
-static int
-xpnet_dev_set_config(struct net_device *dev, struct ifmap *new_map)
-{
-	return 0;
-}
-
-/*
- * Return statistics to the caller.
- */
-static struct net_device_stats *
-xpnet_dev_get_stats(struct net_device *dev)
-{
-	struct xpnet_dev_private *priv = netdev_priv(dev);
-
-	return &priv->stats;
-}
-
-/*
  * Notification that the other end has received the message and
  * DMA'd the skb information.  At this point, they are done with
  * our side.  When all recipients are done processing, we
@@ -453,7 +427,6 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 	struct xpnet_pending_msg *queued_msg;
 	u64 start_addr, end_addr;
 	short dest_partid;
-	struct xpnet_dev_private *priv = netdev_priv(dev);
 	u16 embedded_bytes = 0;
 
 	dev_dbg(xpnet, ">skb->head=0x%p skb->data=0x%p skb->tail=0x%p "
@@ -476,7 +449,7 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		dev_warn(xpnet, "failed to kmalloc %ld bytes; dropping "
 			 "packet\n", sizeof(struct xpnet_pending_msg));
 
-		priv->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		return -ENOMEM;
 	}
 
@@ -526,8 +499,8 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 		kfree(queued_msg);
 	}
 
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	return 0;
 }
@@ -538,12 +511,19 @@ xpnet_dev_hard_start_xmit(struct sk_buff
 static void
 xpnet_dev_tx_timeout(struct net_device *dev)
 {
-	struct xpnet_dev_private *priv = netdev_priv(dev);
-
-	priv->stats.tx_errors++;
-	return;
+	dev->stats.tx_errors++;
 }
 
+static const struct net_device_ops xpnet_netdev_ops = {
+	.ndo_open		= xpnet_dev_open,
+	.ndo_stop		= xpnet_dev_stop,
+	.ndo_start_xmit		= xpnet_dev_hard_start_xmit,
+	.ndo_change_mtu		= xpnet_dev_change_mtu,
+	.ndo_tx_timeout		= xpnet_dev_tx_timeout,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init
 xpnet_init(void)
 {
@@ -563,8 +543,7 @@ xpnet_init(void)
 	 * use ether_setup() to init the majority of our device
 	 * structure and then override the necessary pieces.
 	 */
-	xpnet_device = alloc_netdev(sizeof(struct xpnet_dev_private),
-				    XPNET_DEVICE_NAME, ether_setup);
+	xpnet_device = alloc_netdev(0, XPNET_DEVICE_NAME, ether_setup);
 	if (xpnet_device == NULL) {
 		kfree(xpnet_broadcast_partitions);
 		return -ENOMEM;
@@ -573,13 +552,6 @@ xpnet_init(void)
 	netif_carrier_off(xpnet_device);
 
 	xpnet_device->mtu = XPNET_DEF_MTU;
-	xpnet_device->change_mtu = xpnet_dev_change_mtu;
-	xpnet_device->open = xpnet_dev_open;
-	xpnet_device->get_stats = xpnet_dev_get_stats;
-	xpnet_device->stop = xpnet_dev_stop;
-	xpnet_device->hard_start_xmit = xpnet_dev_hard_start_xmit;
-	xpnet_device->tx_timeout = xpnet_dev_tx_timeout;
-	xpnet_device->set_config = xpnet_dev_set_config;
 
 	/*
 	 * Multicast assumes the LSB of the first octet is set for multicast

-- 

