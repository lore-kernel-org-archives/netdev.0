From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/6] tc35815: Statistics cleanup
Date: Fri, 11 Apr 2008 00:24:12 +0900 (JST)
Message-ID: <20080411.002412.03977557.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:64119 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758032AbYDJPXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:23:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use struct net_device_stats embedded in struct net_device.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   61 +++++++++++++++++++++++++------------------------
 1 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 370d329..f0e9566 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -418,7 +418,6 @@ struct tc35815_local {
 	struct napi_struct napi;
 
 	/* statistics */
-	struct net_device_stats stats;
 	struct {
 		int max_tx_qlen;
 		int tx_ints;
@@ -1192,7 +1191,7 @@ static void tc35815_tx_timeout(struct net_device *dev)
 	tc35815_restart(dev);
 	spin_unlock_irq(&lp->lock);
 
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* If we have space available to accept new transmit
 	 * requests, wake up the queueing layer.  This would
@@ -1392,7 +1391,7 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 		printk(KERN_WARNING
 		       "%s: Free Descriptor Area Exhausted (%#x).\n",
 		       dev->name, status);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		ret = 0;
 	}
 	if (status & Int_IntBLEx) {
@@ -1401,14 +1400,14 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 		printk(KERN_WARNING
 		       "%s: Buffer List Exhausted (%#x).\n",
 		       dev->name, status);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		ret = 0;
 	}
 	if (status & Int_IntExBD) {
 		printk(KERN_WARNING
 		       "%s: Excessive Buffer Descriptiors (%#x).\n",
 		       dev->name, status);
-		lp->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 		ret = 0;
 	}
 
@@ -1532,7 +1531,7 @@ tc35815_rx(struct net_device *dev)
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb, 2);   /* 16 bit alignment */
@@ -1602,10 +1601,10 @@ tc35815_rx(struct net_device *dev)
 			netif_rx(skb);
 #endif
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		} else {
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			printk(KERN_DEBUG "%s: Rx error (status %x)\n",
 			       dev->name, status & Rx_Stat_Mask);
 			/* WORKAROUND: LongErr and CRCErr means Overflow. */
@@ -1613,10 +1612,14 @@ tc35815_rx(struct net_device *dev)
 				status &= ~(Rx_LongErr|Rx_CRCErr);
 				status |= Rx_Over;
 			}
-			if (status & Rx_LongErr) lp->stats.rx_length_errors++;
-			if (status & Rx_Over) lp->stats.rx_fifo_errors++;
-			if (status & Rx_CRCErr) lp->stats.rx_crc_errors++;
-			if (status & Rx_Align) lp->stats.rx_frame_errors++;
+			if (status & Rx_LongErr)
+				dev->stats.rx_length_errors++;
+			if (status & Rx_Over)
+				dev->stats.rx_fifo_errors++;
+			if (status & Rx_CRCErr)
+				dev->stats.rx_crc_errors++;
+			if (status & Rx_Align)
+				dev->stats.rx_frame_errors++;
 		}
 
 		if (bd_count > 0) {
@@ -1777,9 +1780,9 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 
 	/* count collisions */
 	if (status & Tx_ExColl)
-		lp->stats.collisions += 16;
+		dev->stats.collisions += 16;
 	if (status & Tx_TxColl_MASK)
-		lp->stats.collisions += status & Tx_TxColl_MASK;
+		dev->stats.collisions += status & Tx_TxColl_MASK;
 
 #ifndef NO_CHECK_CARRIER
 	/* TX4939 does not have NCarr */
@@ -1795,17 +1798,17 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 
 	if (!(status & TX_STA_ERR)) {
 		/* no error. */
-		lp->stats.tx_packets++;
+		dev->stats.tx_packets++;
 		return;
 	}
 
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (status & Tx_ExColl) {
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_aborted_errors++;
 		msg = "Excessive Collision.";
 	}
 	if (status & Tx_Under) {
-		lp->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		msg = "Tx FIFO Underrun.";
 		if (lp->lstats.tx_underrun < TX_THRESHOLD_KEEP_LIMIT) {
 			lp->lstats.tx_underrun++;
@@ -1818,25 +1821,25 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 		}
 	}
 	if (status & Tx_Defer) {
-		lp->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		msg = "Excessive Deferral.";
 	}
 #ifndef NO_CHECK_CARRIER
 	if (status & Tx_NCarr) {
-		lp->stats.tx_carrier_errors++;
+		dev->stats.tx_carrier_errors++;
 		msg = "Lost Carrier Sense.";
 	}
 #endif
 	if (status & Tx_LateColl) {
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_aborted_errors++;
 		msg = "Late Collision.";
 	}
 	if (status & Tx_TxPar) {
-		lp->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 		msg = "Transmit Parity Error.";
 	}
 	if (status & Tx_SQErr) {
-		lp->stats.tx_heartbeat_errors++;
+		dev->stats.tx_heartbeat_errors++;
 		msg = "Signal Quality Error.";
 	}
 	if (msg && netif_msg_tx_err(lp))
@@ -1878,7 +1881,7 @@ tc35815_txdone(struct net_device *dev)
 		BUG_ON(lp->tx_skbs[lp->tfd_end].skb != skb);
 #endif
 		if (skb) {
-			lp->stats.tx_bytes += skb->len;
+			dev->stats.tx_bytes += skb->len;
 			pci_unmap_single(lp->pci_dev, lp->tx_skbs[lp->tfd_end].skb_dma, skb->len, PCI_DMA_TODEVICE);
 			lp->tx_skbs[lp->tfd_end].skb = NULL;
 			lp->tx_skbs[lp->tfd_end].skb_dma = 0;
@@ -1972,15 +1975,13 @@ tc35815_close(struct net_device *dev)
  */
 static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
-	if (netif_running(dev)) {
+	if (netif_running(dev))
 		/* Update the statistics from the device registers. */
-		lp->stats.rx_missed_errors = tc_readl(&tr->Miss_Cnt);
-	}
+		dev->stats.rx_missed_errors = tc_readl(&tr->Miss_Cnt);
 
-	return &lp->stats;
+	return &dev->stats;
 }
 
 static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned char *addr)
