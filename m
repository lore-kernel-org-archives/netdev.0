From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/4] 2.6.5-rc2 - epic100 napi
Date: Tue, 23 Mar 2004 00:52:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323005218.C1715@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <20040323005021.A1715@electric-eye.fr.zoreil.com> <20040323005114.B1715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040323005114.B1715@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Tue, Mar 23, 2004 at 12:51:14AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Isolate the classical TX part of epic_interrupt. Innocent code shuffling.


 drivers/net/epic100.c |  137 +++++++++++++++++++++++++++-----------------------
 1 files changed, 76 insertions(+), 61 deletions(-)

diff -puN drivers/net/epic100.c~epic100-napi-00 drivers/net/epic100.c
--- linux-2.6.5-rc2/drivers/net/epic100.c~epic100-napi-00	2004-03-22 22:53:18.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/epic100.c	2004-03-22 22:53:18.000000000 +0100
@@ -1045,6 +1045,79 @@ static int epic_start_xmit(struct sk_buf
 	return 0;
 }
 
+static void epic_tx_error(struct net_device *dev, struct epic_private *ep,
+			  int status)
+{
+	struct net_device_stats *stats = &ep->stats;
+
+#ifndef final_version
+	/* There was an major error, log it. */
+	if (debug > 1)
+		printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
+		       dev->name, status);
+#endif
+	stats->tx_errors++;
+	if (status & 0x1050)
+		stats->tx_aborted_errors++;
+	if (status & 0x0008)
+		stats->tx_carrier_errors++;
+	if (status & 0x0040)
+		stats->tx_window_errors++;
+	if (status & 0x0010)
+		stats->tx_fifo_errors++;
+}
+
+static void epic_tx(struct net_device *dev, struct epic_private *ep)
+{
+	unsigned int dirty_tx, cur_tx;
+
+	/*
+	 * Note: if this lock becomes a problem we can narrow the locked
+	 * region at the cost of occasionally grabbing the lock more times.
+	 */
+	spin_lock(&ep->lock);
+	cur_tx = ep->cur_tx;
+	for (dirty_tx = ep->dirty_tx; cur_tx - dirty_tx > 0; dirty_tx++) {
+		struct sk_buff *skb;
+		int entry = dirty_tx % TX_RING_SIZE;
+		int txstatus = le32_to_cpu(ep->tx_ring[entry].txstatus);
+
+		if (txstatus & DescOwn)
+			break;	/* It still hasn't been Txed */
+
+		if (likely(txstatus & 0x0001)) {
+			ep->stats.collisions += (txstatus >> 8) & 15;
+			ep->stats.tx_packets++;
+			ep->stats.tx_bytes += ep->tx_skbuff[entry]->len;
+		} else
+			epic_tx_error(dev, ep, txstatus);
+
+		/* Free the original skb. */
+		skb = ep->tx_skbuff[entry];
+		pci_unmap_single(ep->pci_dev, ep->tx_ring[entry].bufaddr, 
+				 skb->len, PCI_DMA_TODEVICE);
+		dev_kfree_skb_irq(skb);
+		ep->tx_skbuff[entry] = 0;
+	}
+
+#ifndef final_version
+	if (cur_tx - dirty_tx > TX_RING_SIZE) {
+		printk(KERN_WARNING
+		       "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
+		       dev->name, dirty_tx, cur_tx, ep->tx_full);
+		dirty_tx += TX_RING_SIZE;
+	}
+#endif
+	ep->dirty_tx = dirty_tx;
+	if (ep->tx_full && cur_tx - dirty_tx < TX_QUEUE_LEN - 4) {
+		/* The ring is no longer full, allow new TX entries. */
+		ep->tx_full = 0;
+		netif_wake_queue(dev);
+	}
+	spin_unlock(&ep->lock);
+}
+
+
 /* The interrupt handler does all of the Rx thread work and cleans up
    after the Tx thread. */
 static irqreturn_t epic_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
@@ -1072,66 +1145,8 @@ static irqreturn_t epic_interrupt(int ir
 		if (status & (RxDone | RxStarted | RxEarlyWarn | RxOverflow))
 			epic_rx(dev);
 
-		if (status & (TxEmpty | TxDone)) {
-			unsigned int dirty_tx, cur_tx;
-
-			/* Note: if this lock becomes a problem we can narrow the locked
-			   region at the cost of occasionally grabbing the lock more
-			   times. */
-			spin_lock(&ep->lock);
-			cur_tx = ep->cur_tx;
-			dirty_tx = ep->dirty_tx;
-			for (; cur_tx - dirty_tx > 0; dirty_tx++) {
-				struct sk_buff *skb;
-				int entry = dirty_tx % TX_RING_SIZE;
-				int txstatus = le32_to_cpu(ep->tx_ring[entry].txstatus);
-
-				if (txstatus & DescOwn)
-					break;			/* It still hasn't been Txed */
-
-				if ( ! (txstatus & 0x0001)) {
-					/* There was an major error, log it. */
-#ifndef final_version
-					if (debug > 1)
-						printk(KERN_DEBUG "%s: Transmit error, Tx status %8.8x.\n",
-							   dev->name, txstatus);
-#endif
-					ep->stats.tx_errors++;
-					if (txstatus & 0x1050) ep->stats.tx_aborted_errors++;
-					if (txstatus & 0x0008) ep->stats.tx_carrier_errors++;
-					if (txstatus & 0x0040) ep->stats.tx_window_errors++;
-					if (txstatus & 0x0010) ep->stats.tx_fifo_errors++;
-				} else {
-					ep->stats.collisions += (txstatus >> 8) & 15;
-					ep->stats.tx_packets++;
-					ep->stats.tx_bytes += ep->tx_skbuff[entry]->len;
-				}
-
-				/* Free the original skb. */
-				skb = ep->tx_skbuff[entry];
-				pci_unmap_single(ep->pci_dev, ep->tx_ring[entry].bufaddr, 
-						 skb->len, PCI_DMA_TODEVICE);
-				dev_kfree_skb_irq(skb);
-				ep->tx_skbuff[entry] = 0;
-			}
-
-#ifndef final_version
-			if (cur_tx - dirty_tx > TX_RING_SIZE) {
-				printk(KERN_WARNING "%s: Out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
-					   dev->name, dirty_tx, cur_tx, ep->tx_full);
-				dirty_tx += TX_RING_SIZE;
-			}
-#endif
-			ep->dirty_tx = dirty_tx;
-			if (ep->tx_full
-				&& cur_tx - dirty_tx < TX_QUEUE_LEN - 4) {
-				/* The ring is no longer full, allow new TX entries. */
-				ep->tx_full = 0;
-				spin_unlock(&ep->lock);
-				netif_wake_queue(dev);
-			} else
-				spin_unlock(&ep->lock);
-		}
+		if (status & (TxEmpty | TxDone))
+			epic_tx(dev, ep);
 
 		/* Check uncommon events all at once. */
 		if (status & (CntFull | TxUnderrun | RxOverflow | RxFull |
@@ -1149,7 +1164,7 @@ static irqreturn_t epic_interrupt(int ir
 				/* Restart the transmit process. */
 				outl(RestartTx, ioaddr + COMMAND);
 			}
-			if (status & RxOverflow) {		/* Missed a Rx frame. */
+			if (status & RxOverflow) {	/* Missed a Rx frame. */
 				ep->stats.rx_errors++;
 			}
 			if (status & (RxOverflow | RxFull))

_
