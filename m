From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] fealnx: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:36 +0400
Message-ID: <1278332018-16490-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/fealnx.c |   68 ++++++++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 15f4f8d..d7e8f6b 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -382,8 +382,6 @@ struct netdev_private {
 
 	spinlock_t lock;
 
-	struct net_device_stats stats;
-
 	/* Media monitoring timer. */
 	struct timer_list timer;
 
@@ -1234,7 +1232,7 @@ static void fealnx_tx_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&np->lock, flags);
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	netif_wake_queue(dev); /* or .._start_.. ?? */
 }
 
@@ -1479,10 +1477,11 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 		if (intr_status & CNTOVF) {
 			/* missed pkts */
-			np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
+			dev->stats.rx_missed_errors +=
+				ioread32(ioaddr + TALLY) & 0x7fff;
 
 			/* crc error */
-			np->stats.rx_crc_errors +=
+			dev->stats.rx_crc_errors +=
 			    (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 		}
 
@@ -1513,30 +1512,30 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 			if (!(np->crvalue & CR_W_ENH)) {
 				if (tx_status & (CSL | LC | EC | UDF | HF)) {
-					np->stats.tx_errors++;
+					dev->stats.tx_errors++;
 					if (tx_status & EC)
-						np->stats.tx_aborted_errors++;
+						dev->stats.tx_aborted_errors++;
 					if (tx_status & CSL)
-						np->stats.tx_carrier_errors++;
+						dev->stats.tx_carrier_errors++;
 					if (tx_status & LC)
-						np->stats.tx_window_errors++;
+						dev->stats.tx_window_errors++;
 					if (tx_status & UDF)
-						np->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 					if ((tx_status & HF) && np->mii.full_duplex == 0)
-						np->stats.tx_heartbeat_errors++;
+						dev->stats.tx_heartbeat_errors++;
 
 				} else {
-					np->stats.tx_bytes +=
+					dev->stats.tx_bytes +=
 					    ((tx_control & PKTSMask) >> PKTSShift);
 
-					np->stats.collisions +=
+					dev->stats.collisions +=
 					    ((tx_status & NCRMask) >> NCRShift);
-					np->stats.tx_packets++;
+					dev->stats.tx_packets++;
 				}
 			} else {
-				np->stats.tx_bytes +=
+				dev->stats.tx_bytes +=
 				    ((tx_control & PKTSMask) >> PKTSShift);
-				np->stats.tx_packets++;
+				dev->stats.tx_packets++;
 			}
 
 			/* Free the original skb. */
@@ -1564,10 +1563,12 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 			long data;
 
 			data = ioread32(ioaddr + TSR);
-			np->stats.tx_errors += (data & 0xff000000) >> 24;
-			np->stats.tx_aborted_errors += (data & 0xff000000) >> 24;
-			np->stats.tx_window_errors += (data & 0x00ff0000) >> 16;
-			np->stats.collisions += (data & 0x0000ffff);
+			dev->stats.tx_errors += (data & 0xff000000) >> 24;
+			dev->stats.tx_aborted_errors +=
+				(data & 0xff000000) >> 24;
+			dev->stats.tx_window_errors +=
+				(data & 0x00ff0000) >> 16;
+			dev->stats.collisions += (data & 0x0000ffff);
 		}
 
 		if (--boguscnt < 0) {
@@ -1593,10 +1594,11 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 	/* read the tally counters */
 	/* missed pkts */
-	np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
+	dev->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
 
 	/* crc error */
-	np->stats.rx_crc_errors += (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
+	dev->stats.rx_crc_errors +=
+		(ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 
 	if (debug)
 		printk(KERN_DEBUG "%s: exiting interrupt, status=%#4.4x.\n",
@@ -1635,13 +1637,13 @@ static int netdev_rx(struct net_device *dev)
 					       "%s: Receive error, Rx status %8.8x.\n",
 					       dev->name, rx_status);
 
-				np->stats.rx_errors++;	/* end of a packet. */
+				dev->stats.rx_errors++;	/* end of a packet. */
 				if (rx_status & (LONG | RUNT))
-					np->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 				if (rx_status & RXER)
-					np->stats.rx_frame_errors++;
+					dev->stats.rx_frame_errors++;
 				if (rx_status & CRC)
-					np->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 			} else {
 				int need_to_reset = 0;
 				int desno = 0;
@@ -1667,7 +1669,7 @@ static int netdev_rx(struct net_device *dev)
 				if (need_to_reset == 0) {
 					int i;
 
-					np->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 
 					/* free all rx descriptors related this long pkt */
 					for (i = 0; i < desno; ++i) {
@@ -1733,8 +1735,8 @@ static int netdev_rx(struct net_device *dev)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			np->stats.rx_packets++;
-			np->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 
 		np->cur_rx = np->cur_rx->next_desc_logical;
@@ -1754,11 +1756,13 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 
 	/* The chip only need report frame silently dropped. */
 	if (netif_running(dev)) {
-		np->stats.rx_missed_errors += ioread32(ioaddr + TALLY) & 0x7fff;
-		np->stats.rx_crc_errors += (ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
+		dev->stats.rx_missed_errors +=
+			ioread32(ioaddr + TALLY) & 0x7fff;
+		dev->stats.rx_crc_errors +=
+			(ioread32(ioaddr + TALLY) & 0x7fff0000) >> 16;
 	}
 
-	return &np->stats;
+	return &dev->stats;
 }
 
 
-- 
1.7.0.4
