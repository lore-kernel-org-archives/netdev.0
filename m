From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: cris/eth_v10: Use net_device_stats from struct net_device_stats
Date: Thu,  2 Dec 2010 18:22:05 +0100
Message-ID: <1291310525-6101-1-git-send-email-tklauser@distanz.ch>
Cc: Mikael Starvik <starvik@axis.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:57191 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757253Ab0LBRdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 12:33:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in struct net_local.

Note: This patch was not even compile tested.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/cris/eth_v10.c |   34 +++++++++++++++-------------------
 1 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 81475cc..80c2fee 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -59,7 +59,6 @@ static struct sockaddr default_mac = {
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	struct mii_if_info mii_if;
 
 	/* Tx control lock.  This protects the transmit buffer ring
@@ -1059,7 +1058,7 @@ e100_tx_timeout(struct net_device *dev)
 
 	/* remember we got an error */
 
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* reset the TX DMA in case it has hung on something */
 
@@ -1157,7 +1156,7 @@ e100rxtx_interrupt(int irq, void *dev_id)
 			 * allocate a new buffer to put a packet in.
 			 */
 			e100_rx(dev);
-			np->stats.rx_packets++;
+			dev->stats.rx_packets++;
 			/* restart/continue on the channel, for safety */
 			*R_DMA_CH1_CMD = IO_STATE(R_DMA_CH1_CMD, cmd, restart);
 			/* clear dma channel 1 eop/descr irq bits */
@@ -1173,8 +1172,8 @@ e100rxtx_interrupt(int irq, void *dev_id)
 	/* Report any packets that have been sent */
 	while (virt_to_phys(myFirstTxDesc) != *R_DMA_CH0_FIRST &&
 	       (netif_queue_stopped(dev) || myFirstTxDesc != myNextTxDesc)) {
-		np->stats.tx_bytes += myFirstTxDesc->skb->len;
-		np->stats.tx_packets++;
+		dev->stats.tx_bytes += myFirstTxDesc->skb->len;
+		dev->stats.tx_packets++;
 
 		/* dma is ready with the transmission of the data in tx_skb, so now
 		   we can release the skb memory */
@@ -1197,7 +1196,6 @@ static irqreturn_t
 e100nw_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct net_local *np = netdev_priv(dev);
 	unsigned long irqbits = *R_IRQ_MASK0_RD;
 
 	/* check for underrun irq */
@@ -1205,13 +1203,13 @@ e100nw_interrupt(int irq, void *dev_id)
 		SETS(network_tr_ctrl_shadow, R_NETWORK_TR_CTRL, clr_error, clr);
 		*R_NETWORK_TR_CTRL = network_tr_ctrl_shadow;
 		SETS(network_tr_ctrl_shadow, R_NETWORK_TR_CTRL, clr_error, nop);
-		np->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		D(printk("ethernet receiver underrun!\n"));
 	}
 
 	/* check for overrun irq */
 	if (irqbits & IO_STATE(R_IRQ_MASK0_RD, overrun, active)) {
-		update_rx_stats(&np->stats); /* this will ack the irq */
+		update_rx_stats(&dev->stats); /* this will ack the irq */
 		D(printk("ethernet receiver overrun!\n"));
 	}
 	/* check for excessive collision irq */
@@ -1219,7 +1217,7 @@ e100nw_interrupt(int irq, void *dev_id)
 		SETS(network_tr_ctrl_shadow, R_NETWORK_TR_CTRL, clr_error, clr);
 		*R_NETWORK_TR_CTRL = network_tr_ctrl_shadow;
 		SETS(network_tr_ctrl_shadow, R_NETWORK_TR_CTRL, clr_error, nop);
-		np->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		D(printk("ethernet excessive collisions!\n"));
 	}
 	return IRQ_HANDLED;
@@ -1250,7 +1248,7 @@ e100_rx(struct net_device *dev)
 	spin_unlock(&np->led_lock);
 
 	length = myNextRxDesc->descr.hw_len - 4;
-	np->stats.rx_bytes += length;
+	dev->stats.rx_bytes += length;
 
 #ifdef ETHDEBUG
 	printk("Got a packet of length %d:\n", length);
@@ -1268,7 +1266,7 @@ e100_rx(struct net_device *dev)
 		/* Small packet, copy data */
 		skb = dev_alloc_skb(length - ETHER_HEAD_LEN);
 		if (!skb) {
-			np->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 			goto update_nextrxdesc;
 		}
@@ -1294,7 +1292,7 @@ e100_rx(struct net_device *dev)
 		int align;
 		struct sk_buff *new_skb = dev_alloc_skb(MAX_MEDIA_DATA_SIZE + 2 * L1_CACHE_BYTES);
 		if (!new_skb) {
-			np->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 			goto update_nextrxdesc;
 		}
@@ -1333,8 +1331,6 @@ e100_rx(struct net_device *dev)
 static int
 e100_close(struct net_device *dev)
 {
-	struct net_local *np = netdev_priv(dev);
-
 	printk(KERN_INFO "Closing %s.\n", dev->name);
 
 	netif_stop_queue(dev);
@@ -1366,8 +1362,8 @@ e100_close(struct net_device *dev)
 
 	/* Update the statistics here. */
 
-	update_rx_stats(&np->stats);
-	update_tx_stats(&np->stats);
+	update_rx_stats(&dev->stats);
+	update_tx_stats(&dev->stats);
 
 	/* Stop speed/duplex timers */
 	del_timer(&speed_timer);
@@ -1545,11 +1541,11 @@ e100_get_stats(struct net_device *dev)
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	update_rx_stats(&lp->stats);
-	update_tx_stats(&lp->stats);
+	update_rx_stats(&dev->stats);
+	update_tx_stats(&dev->stats);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /*
-- 
1.7.0.4

