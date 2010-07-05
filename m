From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] lance: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:14:03 +0400
Message-ID: <1278332046-17195-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/lance.c |   56 +++++++++++++++++++++++++++++---------------------
 1 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index 21f8ada..f06296b 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -248,7 +248,6 @@ struct lance_private {
 	int cur_rx, cur_tx;			/* The next free ring entry */
 	int dirty_rx, dirty_tx;		/* The ring entries to be free()ed. */
 	int dma;
-	struct net_device_stats stats;
 	unsigned char chip_version;	/* See lance_chip_type. */
 	spinlock_t devlock;
 };
@@ -925,7 +924,7 @@ static void lance_tx_timeout (struct net_device *dev)
 	printk ("%s: transmit timed out, status %4.4x, resetting.\n",
 		dev->name, inw (ioaddr + LANCE_DATA));
 	outw (0x0004, ioaddr + LANCE_DATA);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 #ifndef final_version
 	if (lance_debug > 3) {
 		int i;
@@ -989,7 +988,7 @@ static netdev_tx_t lance_start_xmit(struct sk_buff *skb,
 
 	lp->tx_ring[entry].misc = 0x0000;
 
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* If any part of this buffer is >16M we must copy it to a low-memory
 	   buffer. */
@@ -1062,13 +1061,16 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 				if (status & 0x40000000) {
 					/* There was an major error, log it. */
 					int err_status = lp->tx_ring[entry].misc;
-					lp->stats.tx_errors++;
-					if (err_status & 0x0400) lp->stats.tx_aborted_errors++;
-					if (err_status & 0x0800) lp->stats.tx_carrier_errors++;
-					if (err_status & 0x1000) lp->stats.tx_window_errors++;
+					dev->stats.tx_errors++;
+					if (err_status & 0x0400)
+						dev->stats.tx_aborted_errors++;
+					if (err_status & 0x0800)
+						dev->stats.tx_carrier_errors++;
+					if (err_status & 0x1000)
+						dev->stats.tx_window_errors++;
 					if (err_status & 0x4000) {
 						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						lp->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 						/* Remove this verbosity later! */
 						printk("%s: Tx FIFO error! Status %4.4x.\n",
 							   dev->name, csr0);
@@ -1077,8 +1079,8 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 					}
 				} else {
 					if (status & 0x18000000)
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
+						dev->stats.collisions++;
+					dev->stats.tx_packets++;
 				}
 
 				/* We must free the original skb if it's not a data-only copy
@@ -1108,8 +1110,10 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 		}
 
 		/* Log misc errors. */
-		if (csr0 & 0x4000) lp->stats.tx_errors++; /* Tx babble. */
-		if (csr0 & 0x1000) lp->stats.rx_errors++; /* Missed a Rx frame. */
+		if (csr0 & 0x4000)
+			dev->stats.tx_errors++; /* Tx babble. */
+		if (csr0 & 0x1000)
+			dev->stats.rx_errors++; /* Missed a Rx frame. */
 		if (csr0 & 0x0800) {
 			printk("%s: Bus master arbitration failure, status %4.4x.\n",
 				   dev->name, csr0);
@@ -1155,11 +1159,15 @@ lance_rx(struct net_device *dev)
 			   buffers it's possible for a jabber packet to use two
 			   buffers, with only the last correctly noting the error. */
 			if (status & 0x01)	/* Only count a general error at the */
-				lp->stats.rx_errors++; /* end of a packet.*/
-			if (status & 0x20) lp->stats.rx_frame_errors++;
-			if (status & 0x10) lp->stats.rx_over_errors++;
-			if (status & 0x08) lp->stats.rx_crc_errors++;
-			if (status & 0x04) lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++; /* end of a packet.*/
+			if (status & 0x20)
+				dev->stats.rx_frame_errors++;
+			if (status & 0x10)
+				dev->stats.rx_over_errors++;
+			if (status & 0x08)
+				dev->stats.rx_crc_errors++;
+			if (status & 0x04)
+				dev->stats.rx_fifo_errors++;
 			lp->rx_ring[entry].base &= 0x03ffffff;
 		}
 		else
@@ -1171,7 +1179,7 @@ lance_rx(struct net_device *dev)
 			if(pkt_len<60)
 			{
 				printk("%s: Runt packet!\n",dev->name);
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 			}
 			else
 			{
@@ -1185,7 +1193,7 @@ lance_rx(struct net_device *dev)
 
 					if (i > RX_RING_SIZE -2)
 					{
-						lp->stats.rx_dropped++;
+						dev->stats.rx_dropped++;
 						lp->rx_ring[entry].base |= 0x80000000;
 						lp->cur_rx++;
 					}
@@ -1198,8 +1206,8 @@ lance_rx(struct net_device *dev)
 					pkt_len);
 				skb->protocol=eth_type_trans(skb,dev);
 				netif_rx(skb);
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes+=pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 		}
 		/* The docs say that the buffer length isn't touched, but Andrew Boyd
@@ -1225,7 +1233,7 @@ lance_close(struct net_device *dev)
 
 	if (chip_table[lp->chip_version].flags & LANCE_HAS_MISSED_FRAME) {
 		outw(112, ioaddr+LANCE_ADDR);
-		lp->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
+		dev->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
 	}
 	outw(0, ioaddr+LANCE_ADDR);
 
@@ -1262,12 +1270,12 @@ static struct net_device_stats *lance_get_stats(struct net_device *dev)
 		spin_lock_irqsave(&lp->devlock, flags);
 		saved_addr = inw(ioaddr+LANCE_ADDR);
 		outw(112, ioaddr+LANCE_ADDR);
-		lp->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
+		dev->stats.rx_missed_errors = inw(ioaddr+LANCE_DATA);
 		outw(saved_addr, ioaddr+LANCE_ADDR);
 		spin_unlock_irqrestore(&lp->devlock, flags);
 	}
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
-- 
1.7.0.4
