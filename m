From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] sky2: safer transmit timeout
Date: Tue, 06 Feb 2007 10:45:42 -0800
Message-ID: <20070206184855.156031000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45606 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965223AbXBFSxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:16 -0500
Content-Disposition: inline; filename=sky2-tx-reset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than trying to be "smart" about possible transmit timeout
causes. Just clear all pending frames and reset the PHY.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   41 +++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:21.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:23.000000000 -0800
@@ -1840,48 +1840,37 @@
 }
 
 
-/* Transmit timeout is only called if we are running, carries is up
+/* Transmit timeout is only called if we are running, carrier is up
  * and tx queue is full (stopped).
+ * Called with netif_tx_lock held.
  */
 static void sky2_tx_timeout(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
-	unsigned txq = txqaddr[sky2->port];
-	u16 report, done;
+	u32 imask;
 
 	if (netif_msg_timer(sky2))
 		printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);
 
-	report = sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX);
-	done = sky2_read16(hw, Q_ADDR(txq, Q_DONE));
-
 	printk(KERN_DEBUG PFX "%s: transmit ring %u .. %u report=%u done=%u\n",
-	       dev->name,
-	       sky2->tx_cons, sky2->tx_prod, report, done);
-
-	if (report != done) {
-		printk(KERN_INFO PFX "status burst pending (irq moderation?)\n");
+	       dev->name, sky2->tx_cons, sky2->tx_prod,
+	       sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+	       sky2_read16(hw, Q_ADDR(txqaddr[sky2->port], Q_DONE)));
 
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
-		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
-	} else if (report != sky2->tx_cons) {
-		printk(KERN_INFO PFX "status report lost?\n");
+	imask = sky2_read32(hw, B0_IMSK);	/* block IRQ in hw */
+	sky2_write32(hw, B0_IMSK, 0);
+	sky2_read32(hw, B0_IMSK);
 
-		netif_tx_lock_bh(dev);
-		sky2_tx_complete(sky2, report);
-		netif_tx_unlock_bh(dev);
-	} else {
-		printk(KERN_INFO PFX "hardware hung? flushing\n");
+	netif_poll_disable(hw->dev[0]);		/* stop NAPI poll */
+	synchronize_irq(hw->pdev->irq);
 
-		sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
-		sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	netif_start_queue(dev);			/* don't wakeup during flush */
+	sky2_tx_complete(sky2, sky2->tx_prod);	/* Flush transmit queue */
 
-		sky2_tx_clean(dev);
+	sky2_write32(hw, B0_IMSK, imask);
 
-		sky2_qset(hw, txq);
-		sky2_prefetch_init(hw, txq, sky2->tx_le_map, TX_RING_SIZE - 1);
-	}
+	sky2_phy_reinit(sky2);			/* this clears flow control etc */
 }
 
 static int sky2_change_mtu(struct net_device *dev, int new_mtu)

--
Stephen Hemminger <shemminger@linux-foundation.org>

