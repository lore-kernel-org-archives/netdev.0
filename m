From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/7][MV643XX_ETH] mp->tx_desc_count needs spinlock protection
Date: Mon, 17 Mar 2008 20:17:22 +0100
Message-ID: <20080317191722.GB17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37929 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbYCQTRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:17:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv643xx_eth_start_xmit() should check mp->tx_desc_count only
inside the mp->lock spinlock.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -1741,23 +1741,22 @@ static int mv643xx_eth_start_xmit(struct
 	BUG_ON(netif_queue_stopped(dev));
 	BUG_ON(skb == NULL);
 
+	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
+		stats->tx_dropped++;
+		printk(KERN_DEBUG "%s: failed to linearize tiny "
+				"unaligned fragment\n", dev->name);
+		return 1;
+	}
+
+	spin_lock_irqsave(&mp->lock, flags);
+
 	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
+		spin_unlock_irqrestore(&mp->lock, flags);
 		return 1;
 	}
 
-	if (has_tiny_unaligned_frags(skb)) {
-		if (__skb_linearize(skb)) {
-			stats->tx_dropped++;
-			printk(KERN_DEBUG "%s: failed to linearize tiny "
-					"unaligned fragment\n", dev->name);
-			return 1;
-		}
-	}
-
-	spin_lock_irqsave(&mp->lock, flags);
-
 	eth_tx_submit_descs_for_skb(mp, skb);
 	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
