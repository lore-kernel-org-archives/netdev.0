From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] epic100: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:20 +0400
Message-ID: <1278332002-15860-1-git-send-email-segooon@gmail.com>
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
 drivers/net/epic100.c |   47 ++++++++++++++++++++++-------------------------
 1 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 4c27465..57c8ac0 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -278,7 +278,6 @@ struct epic_private {
 	struct pci_dev *pci_dev;			/* PCI bus location. */
 	int chip_id, chip_flags;
 
-	struct net_device_stats stats;
 	struct timer_list timer;			/* Media selection timer. */
 	int tx_threshold;
 	unsigned char mc_filter[8];
@@ -770,7 +769,6 @@ static int epic_open(struct net_device *dev)
 static void epic_pause(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = netdev_priv(dev);
 
 	netif_stop_queue (dev);
 
@@ -781,9 +779,9 @@ static void epic_pause(struct net_device *dev)
 
 	/* Update the error counts. */
 	if (inw(ioaddr + COMMAND) != 0xffff) {
-		ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		ep->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		ep->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
+		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
+		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
 	}
 
 	/* Remove the packets on the Rx queue. */
@@ -900,7 +898,7 @@ static void epic_tx_timeout(struct net_device *dev)
 		}
 	}
 	if (inw(ioaddr + TxSTAT) & 0x10) {		/* Tx FIFO underflow. */
-		ep->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		outl(RestartTx, ioaddr + COMMAND);
 	} else {
 		epic_restart(dev);
@@ -908,7 +906,7 @@ static void epic_tx_timeout(struct net_device *dev)
 	}
 
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	ep->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (!ep->tx_full)
 		netif_wake_queue(dev);
 }
@@ -1016,7 +1014,7 @@ static netdev_tx_t epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
 			  int status)
 {
-	struct net_device_stats *stats = &ep->stats;
+	struct net_device_stats *stats = &dev->stats;
 
 #ifndef final_version
 	/* There was an major error, log it. */
@@ -1053,9 +1051,9 @@ static void epic_tx(struct net_device *dev, struct epic_private *ep)
 			break;	/* It still hasn't been Txed */
 
 		if (likely(txstatus & 0x0001)) {
-			ep->stats.collisions += (txstatus >> 8) & 15;
-			ep->stats.tx_packets++;
-			ep->stats.tx_bytes += ep->tx_skbuff[entry]->len;
+			dev->stats.collisions += (txstatus >> 8) & 15;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += ep->tx_skbuff[entry]->len;
 		} else
 			epic_tx_error(dev, ep, txstatus);
 
@@ -1125,12 +1123,12 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 			goto out;
 
 		/* Always update the error counts to avoid overhead later. */
-		ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		ep->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		ep->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
+		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
+		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
 
 		if (status & TxUnderrun) { /* Tx FIFO underflow. */
-			ep->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 			outl(ep->tx_threshold += 128, ioaddr + TxThresh);
 			/* Restart the transmit process. */
 			outl(RestartTx, ioaddr + COMMAND);
@@ -1183,10 +1181,10 @@ static int epic_rx(struct net_device *dev, int budget)
 			if (status & 0x2000) {
 				printk(KERN_WARNING "%s: Oversized Ethernet frame spanned "
 					   "multiple buffers, status %4.4x!\n", dev->name, status);
-				ep->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			} else if (status & 0x0006)
 				/* Rx Frame errors are counted in hardware. */
-				ep->stats.rx_errors++;
+				dev->stats.rx_errors++;
 		} else {
 			/* Malloc up new buffer, compatible with net-2e. */
 			/* Omit the four octet CRC from the length. */
@@ -1223,8 +1221,8 @@ static int epic_rx(struct net_device *dev, int budget)
 			}
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_receive_skb(skb);
-			ep->stats.rx_packets++;
-			ep->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 		work_done++;
 		entry = (++ep->cur_rx) % RX_RING_SIZE;
@@ -1259,7 +1257,7 @@ static void epic_rx_err(struct net_device *dev, struct epic_private *ep)
 	if (status == EpicRemoved)
 		return;
 	if (status & RxOverflow) 	/* Missed a Rx frame. */
-		ep->stats.rx_errors++;
+		dev->stats.rx_errors++;
 	if (status & (RxOverflow | RxFull))
 		outw(RxQueued, ioaddr + COMMAND);
 }
@@ -1357,17 +1355,16 @@ static int epic_close(struct net_device *dev)
 
 static struct net_device_stats *epic_get_stats(struct net_device *dev)
 {
-	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (netif_running(dev)) {
 		/* Update the error counts. */
-		ep->stats.rx_missed_errors += inb(ioaddr + MPCNT);
-		ep->stats.rx_frame_errors += inb(ioaddr + ALICNT);
-		ep->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
+		dev->stats.rx_missed_errors += inb(ioaddr + MPCNT);
+		dev->stats.rx_frame_errors += inb(ioaddr + ALICNT);
+		dev->stats.rx_crc_errors += inb(ioaddr + CRCCNT);
 	}
 
-	return &ep->stats;
+	return &dev->stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
-- 
1.7.0.4
