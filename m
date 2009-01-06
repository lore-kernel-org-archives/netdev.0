From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] ieee1394: use internal network device stats
Date: Tue, 6 Jan 2009 14:56:50 -0800
Message-ID: <20090106145650.5f5a47f2@extreme>
References: <20090106145456.37ecedaa@extreme>
	<20090106145554.53ef1ccc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: krh@redhat.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50036 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbZAFW44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 17:56:56 -0500
In-Reply-To: <20090106145554.53ef1ccc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the network_device_stats field in network_device.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/ieee1394/eth1394.c	2009-01-06 14:35:32.364610939 -0800
+++ b/drivers/ieee1394/eth1394.c	2009-01-06 14:41:03.060783206 -0800
@@ -245,12 +245,6 @@ static int ether1394_stop(struct net_dev
 	return 0;
 }
 
-/* Return statistics to the caller */
-static struct net_device_stats *ether1394_stats(struct net_device *dev)
-{
-	return &(((struct eth1394_priv *)netdev_priv(dev))->stats);
-}
-
 /* FIXME: What to do if we timeout? I think a host reset is probably in order,
  * so that's what we do. Should we increment the stat counters too?  */
 static void ether1394_tx_timeout(struct net_device *dev)
@@ -520,7 +514,6 @@ static const struct net_device_ops ether
 	.ndo_open	= ether1394_open,
 	.ndo_stop	= ether1394_stop,
 	.ndo_start_xmit	= ether1394_tx,
-	.ndo_get_stats	= ether1394_stats,
 	.ndo_tx_timeout	= ether1394_tx_timeout,
 	.ndo_change_mtu	= ether1394_change_mtu,
 };
@@ -1079,7 +1072,7 @@ static int ether1394_data_handler(struct
 			HPSB_PRINT(KERN_ERR, "ether1394 rx: sender nodeid "
 				   "lookup failure: " NODE_BUS_FMT,
 				   NODE_BUS_ARGS(priv->host, srcid));
-			priv->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return -1;
 		}
 		ud = node->ud;
@@ -1102,7 +1095,7 @@ static int ether1394_data_handler(struct
 		skb = dev_alloc_skb(len + dev->hard_header_len + 15);
 		if (unlikely(!skb)) {
 			ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
-			priv->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return -1;
 		}
 		skb_reserve(skb, (dev->hard_header_len + 15) & ~15);
@@ -1221,15 +1214,15 @@ static int ether1394_data_handler(struct
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!skb->protocol) {
-		priv->stats.rx_errors++;
-		priv->stats.rx_dropped++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
 	} else if (netif_rx(skb) == NET_RX_DROP) {
-		priv->stats.rx_errors++;
-		priv->stats.rx_dropped++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
 	} else {
-		priv->stats.rx_packets++;
-		priv->stats.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 	}
 
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -1513,17 +1506,18 @@ static int ether1394_send_packet(struct 
 static void ether1394_dg_complete(struct packet_task *ptask, int fail)
 {
 	struct sk_buff *skb = ptask->skb;
-	struct eth1394_priv *priv = netdev_priv(skb->dev);
+	struct net_device *dev = skb->dev;
+	struct eth1394_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Statistics */
 	spin_lock_irqsave(&priv->lock, flags);
 	if (fail) {
-		priv->stats.tx_dropped++;
-		priv->stats.tx_errors++;
+		dev->stats.tx_dropped++;
+		dev->stats.tx_errors++;
 	} else {
-		priv->stats.tx_bytes += skb->len;
-		priv->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -1700,8 +1694,8 @@ fail:
 		dev_kfree_skb(skb);
 
 	spin_lock_irqsave(&priv->lock, flags);
-	priv->stats.tx_dropped++;
-	priv->stats.tx_errors++;
+	dev->stats.tx_dropped++;
+	dev->stats.tx_errors++;
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	/*
--- a/drivers/ieee1394/eth1394.h	2009-01-06 14:36:53.776610624 -0800
+++ b/drivers/ieee1394/eth1394.h	2009-01-06 14:37:20.090568738 -0800
@@ -54,7 +54,6 @@ enum eth1394_bc_states { ETHER1394_BC_ER
 
 /* Private structure for our ethernet driver */
 struct eth1394_priv {
-	struct net_device_stats stats;	/* Device stats			 */
 	struct hpsb_host *host;		/* The card for this dev	 */
 	u16 bc_maxpayload;		/* Max broadcast payload	 */
 	u8 bc_sspd;			/* Max broadcast speed		 */
