From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH 2/2] 3c59x: use netstats in net_device structure
Date: Mon,  5 May 2008 14:01:29 +0200
Message-ID: <12099888903383-git-send-email-klassert@mathematik.tu-chemnitz.de>
References: <12099888891786-git-send-email-klassert@mathematik.tu-chemnitz.de>
Cc: netdev@vger.kernel.org,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:54892 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbYEEM3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 08:29:30 -0400
In-Reply-To: <12099888891786-git-send-email-klassert@mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/3c59x.c |   71 +++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index e93c378..2edda8c 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -600,7 +600,6 @@ struct vortex_private {
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
 	unsigned int cur_rx, cur_tx;		/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;	/* The ring entries to be free()ed. */
-	struct net_device_stats stats;		/* Generic stats */
 	struct vortex_extra_stats xstats;	/* NIC-specific extra stats */
 	struct sk_buff *tx_skb;				/* Packet being eaten by bus master ctrl.  */
 	dma_addr_t tx_skb_dma;				/* Allocated DMA address for bus master ctrl DMA.   */
@@ -1875,7 +1874,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 
 	issue_and_wait(dev, TxReset);
 
-	vp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (vp->full_bus_master_tx) {
 		printk(KERN_DEBUG "%s: Resetting the Tx ring pointer.\n", dev->name);
 		if (vp->cur_tx - vp->dirty_tx > 0  &&  ioread32(ioaddr + DownListPtr) == 0)
@@ -1887,7 +1886,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 			iowrite8(PKT_BUF_SZ>>8, ioaddr + TxFreeThreshold);
 		iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	} else {
-		vp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		netif_wake_queue(dev);
 	}
 
@@ -1928,8 +1927,8 @@ vortex_error(struct net_device *dev, int status)
 			}
 			dump_tx_ring(dev);
 		}
-		if (tx_status & 0x14)  vp->stats.tx_fifo_errors++;
-		if (tx_status & 0x38)  vp->stats.tx_aborted_errors++;
+		if (tx_status & 0x14)  dev->stats.tx_fifo_errors++;
+		if (tx_status & 0x38)  dev->stats.tx_aborted_errors++;
 		if (tx_status & 0x08)  vp->xstats.tx_max_collisions++;
 		iowrite8(0, ioaddr + TxStatus);
 		if (tx_status & 0x30) {			/* txJabber or txUnderrun */
@@ -2051,8 +2050,8 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				if (vortex_debug > 2)
 				  printk(KERN_DEBUG "%s: Tx error, status %2.2x.\n",
 						 dev->name, tx_status);
-				if (tx_status & 0x04) vp->stats.tx_fifo_errors++;
-				if (tx_status & 0x38) vp->stats.tx_aborted_errors++;
+				if (tx_status & 0x04) dev->stats.tx_fifo_errors++;
+				if (tx_status & 0x38) dev->stats.tx_aborted_errors++;
 				if (tx_status & 0x30) {
 					issue_and_wait(dev, TxReset);
 				}
@@ -2350,7 +2349,7 @@ boomerang_interrupt(int irq, void *dev_id)
 				} else {
 					printk(KERN_DEBUG "boomerang_interrupt: no skb!\n");
 				}
-				/* vp->stats.tx_packets++;  Counted below. */
+				/* dev->stats.tx_packets++;  Counted below. */
 				dirty_tx++;
 			}
 			vp->dirty_tx = dirty_tx;
@@ -2409,12 +2408,12 @@ static int vortex_rx(struct net_device *dev)
 			unsigned char rx_error = ioread8(ioaddr + RxErrors);
 			if (vortex_debug > 2)
 				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
-			vp->stats.rx_errors++;
-			if (rx_error & 0x01)  vp->stats.rx_over_errors++;
-			if (rx_error & 0x02)  vp->stats.rx_length_errors++;
-			if (rx_error & 0x04)  vp->stats.rx_frame_errors++;
-			if (rx_error & 0x08)  vp->stats.rx_crc_errors++;
-			if (rx_error & 0x10)  vp->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
+			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
+			if (rx_error & 0x04)  dev->stats.rx_frame_errors++;
+			if (rx_error & 0x08)  dev->stats.rx_crc_errors++;
+			if (rx_error & 0x10)  dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			int pkt_len = rx_status & 0x1fff;
@@ -2446,7 +2445,7 @@ static int vortex_rx(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				vp->stats.rx_packets++;
+				dev->stats.rx_packets++;
 				/* Wait a limited time to go to next packet. */
 				for (i = 200; i >= 0; i--)
 					if ( ! (ioread16(ioaddr + EL3_STATUS) & CmdInProgress))
@@ -2455,7 +2454,7 @@ static int vortex_rx(struct net_device *dev)
 			} else if (vortex_debug > 0)
 				printk(KERN_NOTICE "%s: No memory to allocate a sk_buff of "
 					   "size %d.\n", dev->name, pkt_len);
-			vp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 		issue_and_wait(dev, RxDiscard);
 	}
@@ -2482,12 +2481,12 @@ boomerang_rx(struct net_device *dev)
 			unsigned char rx_error = rx_status >> 16;
 			if (vortex_debug > 2)
 				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
-			vp->stats.rx_errors++;
-			if (rx_error & 0x01)  vp->stats.rx_over_errors++;
-			if (rx_error & 0x02)  vp->stats.rx_length_errors++;
-			if (rx_error & 0x04)  vp->stats.rx_frame_errors++;
-			if (rx_error & 0x08)  vp->stats.rx_crc_errors++;
-			if (rx_error & 0x10)  vp->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
+			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
+			if (rx_error & 0x04)  dev->stats.rx_frame_errors++;
+			if (rx_error & 0x08)  dev->stats.rx_crc_errors++;
+			if (rx_error & 0x10)  dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			int pkt_len = rx_status & 0x1fff;
@@ -2529,7 +2528,7 @@ boomerang_rx(struct net_device *dev)
 			}
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			vp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
 	}
@@ -2591,7 +2590,7 @@ vortex_down(struct net_device *dev, int final_down)
 	del_timer_sync(&vp->rx_oom_timer);
 	del_timer_sync(&vp->timer);
 
-	/* Turn off statistics ASAP.  We update vp->stats below. */
+	/* Turn off statistics ASAP.  We update dev->stats below. */
 	iowrite16(StatsDisable, ioaddr + EL3_CMD);
 
 	/* Disable the receiver and transmitter. */
@@ -2728,7 +2727,7 @@ static struct net_device_stats *vortex_get_stats(struct net_device *dev)
 		update_stats(ioaddr, dev);
 		spin_unlock_irqrestore (&vp->lock, flags);
 	}
-	return &vp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.
@@ -2748,18 +2747,18 @@ static void update_stats(void __iomem *ioaddr, struct net_device *dev)
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	vp->stats.tx_carrier_errors		+= ioread8(ioaddr + 0);
-	vp->stats.tx_heartbeat_errors		+= ioread8(ioaddr + 1);
-	vp->stats.tx_window_errors		+= ioread8(ioaddr + 4);
-	vp->stats.rx_fifo_errors		+= ioread8(ioaddr + 5);
-	vp->stats.tx_packets			+= ioread8(ioaddr + 6);
-	vp->stats.tx_packets			+= (ioread8(ioaddr + 9)&0x30) << 4;
+	dev->stats.tx_carrier_errors		+= ioread8(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors		+= ioread8(ioaddr + 1);
+	dev->stats.tx_window_errors		+= ioread8(ioaddr + 4);
+	dev->stats.rx_fifo_errors		+= ioread8(ioaddr + 5);
+	dev->stats.tx_packets			+= ioread8(ioaddr + 6);
+	dev->stats.tx_packets			+= (ioread8(ioaddr + 9)&0x30) << 4;
 	/* Rx packets	*/			ioread8(ioaddr + 7);   /* Must read to clear */
 	/* Don't bother with register 9, an extension of registers 6&7.
 	   If we do use the 6&7 values the atomic update assumption above
 	   is invalid. */
-	vp->stats.rx_bytes 			+= ioread16(ioaddr + 10);
-	vp->stats.tx_bytes 			+= ioread16(ioaddr + 12);
+	dev->stats.rx_bytes 			+= ioread16(ioaddr + 10);
+	dev->stats.tx_bytes 			+= ioread16(ioaddr + 12);
 	/* Extra stats for get_ethtool_stats() */
 	vp->xstats.tx_multiple_collisions	+= ioread8(ioaddr + 2);
 	vp->xstats.tx_single_collisions         += ioread8(ioaddr + 3);
@@ -2767,14 +2766,14 @@ static void update_stats(void __iomem *ioaddr, struct net_device *dev)
 	EL3WINDOW(4);
 	vp->xstats.rx_bad_ssd			+= ioread8(ioaddr + 12);
 
-	vp->stats.collisions = vp->xstats.tx_multiple_collisions
+	dev->stats.collisions = vp->xstats.tx_multiple_collisions
 		+ vp->xstats.tx_single_collisions
 		+ vp->xstats.tx_max_collisions;
 
 	{
 		u8 up = ioread8(ioaddr + 13);
-		vp->stats.rx_bytes += (up & 0x0f) << 16;
-		vp->stats.tx_bytes += (up & 0xf0) << 12;
+		dev->stats.rx_bytes += (up & 0x0f) << 16;
+		dev->stats.tx_bytes += (up & 0xf0) << 12;
 	}
 
 	EL3WINDOW(old_window >> 13);
-- 
1.5.3

