From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] cs89x0: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:15 +0400
Message-ID: <1278331997-15826-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Julia Lawall <julia@diku.dk>,
	Dongdong Deng <dongdong.deng@windriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/cs89x0.c |   66 +++++++++++++++++++++++++++----------------------
 1 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 2ccb9f1..e3a7dca 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -218,7 +218,6 @@ static unsigned int net_debug = DEBUGGING;
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	int chip_type;		/* one of: CS8900, CS8920, CS8920M */
 	char chip_revision;	/* revision letter of the chip ('A'...) */
 	int send_cmd;		/* the proper send command: TX_NOW, TX_AFTER_381, or TX_AFTER_ALL */
@@ -257,7 +256,7 @@ static void reset_chip(struct net_device *dev);
 static int get_eeprom_data(struct net_device *dev, int off, int len, int *buffer);
 static int get_eeprom_cksum(int off, int len, int *buffer);
 static int set_mac_address(struct net_device *dev, void *addr);
-static void count_rx_errors(int status, struct net_local *lp);
+static void count_rx_errors(int status, struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void net_poll_controller(struct net_device *dev);
 #endif
@@ -983,7 +982,7 @@ dma_rx(struct net_device *dev)
 			dev->name, (unsigned long)bp, status, length);
 	}
 	if ((status & RX_OK) == 0) {
-		count_rx_errors(status, lp);
+		count_rx_errors(status, dev);
 		goto skip_this_frame;
 	}
 
@@ -992,7 +991,7 @@ dma_rx(struct net_device *dev)
 	if (skb == NULL) {
 		if (net_debug)	/* I don't think we want to do this to a stressed system */
 			printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 
 		/* AKPM: advance bp to the next frame */
 skip_this_frame:
@@ -1022,8 +1021,8 @@ skip_this_frame:
 	}
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += length;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length;
 }
 
 #endif	/* ALLOW_DMA */
@@ -1552,7 +1551,7 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb,struct net_device *dev)
 	/* Write the contents of the packet */
 	writewords(dev->base_addr, TX_FRAME_PORT,skb->data,(skb->len+1) >>1);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	dev_kfree_skb (skb);
 
 	/*
@@ -1598,18 +1597,23 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 			net_rx(dev);
 			break;
 		case ISQ_TRANSMITTER_EVENT:
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			netif_wake_queue(dev);	/* Inform upper layers. */
 			if ((status & (	TX_OK |
 					TX_LOST_CRS |
 					TX_SQE_ERROR |
 					TX_LATE_COL |
 					TX_16_COL)) != TX_OK) {
-				if ((status & TX_OK) == 0) lp->stats.tx_errors++;
-				if (status & TX_LOST_CRS) lp->stats.tx_carrier_errors++;
-				if (status & TX_SQE_ERROR) lp->stats.tx_heartbeat_errors++;
-				if (status & TX_LATE_COL) lp->stats.tx_window_errors++;
-				if (status & TX_16_COL) lp->stats.tx_aborted_errors++;
+				if ((status & TX_OK) == 0)
+					dev->stats.tx_errors++;
+				if (status & TX_LOST_CRS)
+					dev->stats.tx_carrier_errors++;
+				if (status & TX_SQE_ERROR)
+					dev->stats.tx_heartbeat_errors++;
+				if (status & TX_LATE_COL)
+					dev->stats.tx_window_errors++;
+				if (status & TX_16_COL)
+					dev->stats.tx_aborted_errors++;
 			}
 			break;
 		case ISQ_BUFFER_EVENT:
@@ -1651,10 +1655,10 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 #endif
 			break;
 		case ISQ_RX_MISS_EVENT:
-			lp->stats.rx_missed_errors += (status >>6);
+			dev->stats.rx_missed_errors += (status >> 6);
 			break;
 		case ISQ_TX_COL_EVENT:
-			lp->stats.collisions += (status >>6);
+			dev->stats.collisions += (status >> 6);
 			break;
 		}
 	}
@@ -1662,22 +1666,24 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 }
 
 static void
-count_rx_errors(int status, struct net_local *lp)
+count_rx_errors(int status, struct net_device *dev)
 {
-	lp->stats.rx_errors++;
-	if (status & RX_RUNT) lp->stats.rx_length_errors++;
-	if (status & RX_EXTRA_DATA) lp->stats.rx_length_errors++;
-	if (status & RX_CRC_ERROR) if (!(status & (RX_EXTRA_DATA|RX_RUNT)))
+	dev->stats.rx_errors++;
+	if (status & RX_RUNT)
+		dev->stats.rx_length_errors++;
+	if (status & RX_EXTRA_DATA)
+		dev->stats.rx_length_errors++;
+	if ((status & RX_CRC_ERROR) && !(status & (RX_EXTRA_DATA|RX_RUNT)))
 		/* per str 172 */
-		lp->stats.rx_crc_errors++;
-	if (status & RX_DRIBBLE) lp->stats.rx_frame_errors++;
+		dev->stats.rx_crc_errors++;
+	if (status & RX_DRIBBLE)
+		dev->stats.rx_frame_errors++;
 }
 
 /* We have a good packet(s), get it/them out of the buffers. */
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
@@ -1686,7 +1692,7 @@ net_rx(struct net_device *dev)
 	length = readword(ioaddr, RX_FRAME_PORT);
 
 	if ((status & RX_OK) == 0) {
-		count_rx_errors(status, lp);
+		count_rx_errors(status, dev);
 		return;
 	}
 
@@ -1696,7 +1702,7 @@ net_rx(struct net_device *dev)
 #if 0		/* Again, this seems a cruel thing to do */
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
 #endif
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_reserve(skb, 2);	/* longword align L3 header */
@@ -1713,8 +1719,8 @@ net_rx(struct net_device *dev)
 
         skb->protocol=eth_type_trans(skb,dev);
 	netif_rx(skb);
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += length;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += length;
 }
 
 #if ALLOW_DMA
@@ -1765,11 +1771,11 @@ net_get_stats(struct net_device *dev)
 
 	spin_lock_irqsave(&lp->lock, flags);
 	/* Update the statistics from the device registers. */
-	lp->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
-	lp->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
+	dev->stats.rx_missed_errors += (readreg(dev, PP_RxMiss) >> 6);
+	dev->stats.collisions += (readreg(dev, PP_TxCol) >> 6);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 static void set_multicast_list(struct net_device *dev)
-- 
1.7.0.4
