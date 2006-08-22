From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] sky2: transmit complete alternative
Date: Tue, 22 Aug 2006 15:38:41 -0700
Message-ID: <20060822153841.1832f690@localhost.localdomain>
References: <44E9A9E0.20106@cheetah.uio.no>
	<44E9B28C.9050207@gentoo.org>
	<44E9C153.1010300@cheetah.uio.no>
	<20060821095116.1b7f725d@localhost.localdomain>
	<44EA2DD7.9060605@cheetah.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31172 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750973AbWHVWiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 18:38:51 -0400
To: Jon Wikne <wikne@cheetah.uio.no>
In-Reply-To: <44EA2DD7.9060605@cheetah.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does the following get rid of the hang?
--------
Recode the transmit completion handling to avoid races between the hardware
status report mechanism and the interrupt handler. Rather than relying on
the index value in the status ring, read the chip register and cleanup
all completed transmits. 

Reduce the transmit lock window smaller to allow more parallelism.

--- sky2.orig/drivers/net/sky2.c	2006-08-22 13:45:17.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-08-22 14:01:52.000000000 -0700
@@ -135,6 +135,7 @@
 static const unsigned txqaddr[] = { Q_XA1, Q_XA2 };
 static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
+static const u16 report_idx[] = { STAT_TXA1_RIDX, STAT_TXA2_RIDX };
 
 /* This driver supports yukon2 chipset only */
 static const char *yukon2_name[] = {
@@ -1189,7 +1190,6 @@
 	struct sky2_tx_le *le = NULL;
 	struct tx_ring_info *re;
 	unsigned i, len;
-	int avail;
 	dma_addr_t mapping;
 	u32 addr64;
 	u16 mss;
@@ -1332,12 +1332,8 @@
 	re->idx = sky2->tx_prod;
 	le->ctrl |= EOP;
 
-	avail = tx_avail(sky2);
-	if (mss != 0 || avail < TX_MIN_PENDING) {
- 		le->ctrl |= FRC_STAT;
-		if (avail <= MAX_SKB_TX_LE)
-			netif_stop_queue(dev);
-	}
+	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
+		netif_stop_queue(dev);
 
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
@@ -1361,12 +1357,10 @@
 	u16 nxt, put;
 	unsigned i;
 
-	BUG_ON(done >= TX_RING_SIZE);
-
-	if (unlikely(netif_msg_tx_done(sky2)))
-		printk(KERN_DEBUG "%s: tx done, up to %u\n",
-		       dev->name, done);
+	if (done == sky2->tx_cons)
+		return;
 
+	BUG_ON(done >= TX_RING_SIZE);
 	for (put = sky2->tx_cons; put != done; put = nxt) {
 		struct tx_ring_info *re = sky2->tx_ring + put;
 		struct sk_buff *skb = re->skb;
@@ -1391,20 +1385,26 @@
 				       PCI_DMA_TODEVICE);
 		}
 
+		if (unlikely(netif_msg_tx_done(sky2)))
+			printk(KERN_DEBUG "%s: tx done, slot %u\n",
+			       dev->name, put);
+
 		dev_kfree_skb(skb);
 	}
 
+	spin_lock(&sky2->tx_lock);
 	sky2->tx_cons = put;
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
+	spin_unlock(&sky2->tx_lock);
 }
 
 /* Cleanup all untransmitted buffers, assume transmitter not running */
 static void sky2_tx_clean(struct sky2_port *sky2)
 {
-	spin_lock_bh(&sky2->tx_lock);
+	local_bh_disable();
 	sky2_tx_complete(sky2, sky2->tx_prod);
-	spin_unlock_bh(&sky2->tx_lock);
+	local_bh_enable();
 }
 
 /* Network shutdown */
@@ -1732,7 +1732,7 @@
 	if (netif_msg_timer(sky2))
 		printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);
 
-	report = sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX);
+	report = sky2_read16(hw, report_idx[sky2->port]);
 	done = sky2_read16(hw, Q_ADDR(txq, Q_DONE));
 
 	printk(KERN_DEBUG PFX "%s: transmit ring %u .. %u report=%u done=%u\n",
@@ -1747,9 +1747,7 @@
 	} else if (report != sky2->tx_cons) {
 		printk(KERN_INFO PFX "status report lost?\n");
 
-		spin_lock_bh(&sky2->tx_lock);
 		sky2_tx_complete(sky2, report);
-		spin_unlock_bh(&sky2->tx_lock);
 	} else {
 		printk(KERN_INFO PFX "hardware hung? flushing\n");
 
@@ -1919,15 +1917,14 @@
 	goto resubmit;
 }
 
-/* Transmit complete */
-static inline void sky2_tx_done(struct net_device *dev, u16 last)
+/* Transmit completion handling */
+static void sky2_tx(struct sky2_hw *hw, unsigned port)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
+	struct net_device *dev = hw->dev[port];
 
-	if (netif_running(dev)) {
-		spin_lock(&sky2->tx_lock);
-		sky2_tx_complete(sky2, last);
-		spin_unlock(&sky2->tx_lock);
+	if (dev && netif_running(dev)) {
+		u16 last = sky2_read16(hw, report_idx[port]);
+		sky2_tx_complete(netdev_priv(dev), last);
 	}
 }
 
@@ -1939,6 +1936,10 @@
 	unsigned buf_write[2] = { 0, 0 };
 	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
+	sky2_tx(hw, 0);
+	if (hw->ports > 1)
+		sky2_tx(hw, 1);
+
 	rmb();
 
 	while (hw->st_idx != hwidx) {
@@ -2004,13 +2005,7 @@
 			break;
 
 		case OP_TXINDEXLE:
-			/* TX index reports status for both ports */
-			BUILD_BUG_ON(TX_RING_SIZE > 0x1000);
-			sky2_tx_done(hw->dev[0], status & 0xfff);
-			if (hw->dev[1])
-				sky2_tx_done(hw->dev[1],
-				     ((status >> 24) & 0xff)
-					     | (u16)(length & 0xf) << 8);
+			/* TX completion handled above */
 			break;
 
 		default:
