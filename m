From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH 2/4] bcm43xx: Port preemptible-periodic-work to d80211
Date: Tue, 13 Jun 2006 21:18:29 +0200
Message-ID: <200606132118.29974.mb@bu3sch.de>
References: <20060613191206.122150000@ppc1>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:36293
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751130AbWFMTUP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 15:20:15 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Port the preemptible periodic work patch from bcm43xx-softmac to bcm43xx-d80211.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:24.000000000 +0200
@@ -529,11 +529,21 @@
 	return old_mask;
 }
 
+/* Synchronize IRQ top- and bottom-half.
+ * IRQs must be masked before calling this.
+ * This must not be called with the irq_lock held.
+ */
+static void bcm43xx_synchronize_irq(struct bcm43xx_private *bcm)
+{
+	synchronize_irq(bcm->irq);
+	tasklet_disable(&bcm->isr_tasklet);
+}
+
 /* Make sure we don't receive more data from the device. */
 static int bcm43xx_disable_interrupts_sync(struct bcm43xx_private *bcm, u32 *oldstate)
 {
-	u32 old;
 	unsigned long flags;
+	u32 old;
 
 	bcm43xx_lock_irqonly(bcm, flags);
 	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)) {
@@ -541,8 +551,9 @@
 		return -EBUSY;
 	}
 	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	tasklet_disable(&bcm->isr_tasklet);
 	bcm43xx_unlock_irqonly(bcm, flags);
+	bcm43xx_synchronize_irq(bcm);
+
 	if (oldstate)
 		*oldstate = old;
 
@@ -2951,14 +2962,10 @@
 	//TODO for APHY (temperature?)
 }
 
-static void bcm43xx_periodic_work_handler(void *d)
+static void do_periodic_work(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_private *bcm = d;
-	unsigned long flags;
 	unsigned int state;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
-
 	state = bcm->periodic_state;
 	if (state % 8 == 0)
 		bcm43xx_periodic_every120sec(bcm);
@@ -2966,13 +2973,79 @@
 		bcm43xx_periodic_every60sec(bcm);
 	if (state % 2 == 0)
 		bcm43xx_periodic_every30sec(bcm);
-	bcm43xx_periodic_every15sec(bcm);
+	if (state % 1 == 0)
+		bcm43xx_periodic_every15sec(bcm);
 	bcm->periodic_state = state + 1;
 
 	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+}
 
-	mmiowb();
-	bcm43xx_unlock_irqsafe(bcm, flags);
+/* Estimate a "Badness" value based on the periodic work
+ * state-machine state. "Badness" is worse (bigger), if the
+ * periodic work will take longer.
+ */
+static int estimate_periodic_work_badness(unsigned int state)
+{
+	int badness = 0;
+
+	if (state % 8 == 0) /* every 120 sec */
+		badness += 10;
+	if (state % 4 == 0) /* every 60 sec */
+		badness += 5;
+	if (state % 2 == 0) /* every 30 sec */
+		badness += 1;
+	if (state % 1 == 0) /* every 15 sec */
+		badness += 1;
+
+#define BADNESS_LIMIT	4
+	return badness;
+}
+
+static void bcm43xx_periodic_work_handler(void *d)
+{
+	struct bcm43xx_private *bcm = d;
+	unsigned long flags;
+	u32 savedirqs = 0;
+	int badness;
+
+	badness = estimate_periodic_work_badness(bcm->periodic_state);
+	if (badness > BADNESS_LIMIT) {
+		/* Periodic work will take a long time, so we want it to
+		 * be preemtible.
+		 */
+		bcm43xx_lock_irqonly(bcm, flags);
+		netif_stop_queue(bcm->net_dev);
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_freeze_txqueues(bcm);
+		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+		bcm43xx_unlock_irqonly(bcm, flags);
+		bcm43xx_lock_noirq(bcm);
+		bcm43xx_synchronize_irq(bcm);
+	} else {
+		/* Periodic work should take short time, so we want low
+		 * locking overhead.
+		 */
+		bcm43xx_lock_irqsafe(bcm, flags);
+	}
+
+	do_periodic_work(bcm);
+
+	if (badness > BADNESS_LIMIT) {
+		bcm43xx_lock_irqonly(bcm, flags);
+		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
+			tasklet_enable(&bcm->isr_tasklet);
+			bcm43xx_interrupt_enable(bcm, savedirqs);
+			if (bcm43xx_using_pio(bcm))
+				bcm43xx_pio_thaw_txqueues(bcm);
+		}
+		netif_wake_queue(bcm->net_dev);
+		mmiowb();
+		bcm43xx_unlock_irqonly(bcm, flags);
+		bcm43xx_unlock_noirq(bcm);
+	} else {
+		mmiowb();
+		bcm43xx_unlock_irqsafe(bcm, flags);
+	}
 }
 
 static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
@@ -4178,9 +4251,11 @@
 static int bcm43xx_net_stop(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	int err;
 
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
-		bcm43xx_disable_interrupts_sync(bcm, NULL);
+		err = bcm43xx_disable_interrupts_sync(bcm, NULL);
+		assert(!err);
 		bcm43xx_free_board(bcm);
 	}
 
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-06-13 21:11:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-06-13 21:11:24.000000000 +0200
@@ -1410,7 +1410,10 @@
 u16 bcm43xx_phy_lo_g_deviation_subval(struct bcm43xx_private *bcm, u16 control)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+	u16 ret;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	if (phy->connected) {
 		bcm43xx_phy_write(bcm, 0x15, 0xE300);
 		control <<= 8;
@@ -1430,8 +1433,10 @@
 		bcm43xx_phy_write(bcm, 0x0015, control | 0xFFE0);
 		udelay(8);
 	}
+	ret = bcm43xx_phy_read(bcm, 0x002D);
+	local_irq_restore(flags);
 
-	return bcm43xx_phy_read(bcm, 0x002D);
+	return ret;
 }
 
 static u32 bcm43xx_phy_lo_g_singledeviation(struct bcm43xx_private *bcm, u16 control)
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:24.000000000 +0200
@@ -258,6 +258,9 @@
 	int err;
 
 	bcm43xx_lock_irqonly(bcm, flags);
+	if (queue->tx_frozen)
+		goto out_unlock;
+
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txqueue, list) {
 		/* Try to transmit the packet. This can fail, if
 		 * the device queue is full. In case of failure, the
@@ -270,6 +273,7 @@
 		if (err)
 			break;
 	}
+out_unlock:
 	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
@@ -589,3 +593,35 @@
 	}
 	bcm43xx_rx(queue->bcm, skb, rxhdr);
 }
+
+void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_pio *pio;
+
+	assert(bcm43xx_using_pio(bcm));
+	pio = bcm43xx_current_pio(bcm);
+	pio->queue0->tx_frozen = 1;
+	pio->queue1->tx_frozen = 1;
+	pio->queue2->tx_frozen = 1;
+	pio->queue3->tx_frozen = 1;
+}
+
+void bcm43xx_pio_thaw_txqueues(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_pio *pio;
+
+	assert(bcm43xx_using_pio(bcm));
+	pio = bcm43xx_current_pio(bcm);
+	pio->queue0->tx_frozen = 0;
+	pio->queue1->tx_frozen = 0;
+	pio->queue2->tx_frozen = 0;
+	pio->queue3->tx_frozen = 0;
+	if (!list_empty(&pio->queue0->txqueue))
+		tasklet_schedule(&pio->queue0->txtask);
+	if (!list_empty(&pio->queue1->txqueue))
+		tasklet_schedule(&pio->queue1->txtask);
+	if (!list_empty(&pio->queue2->txqueue))
+		tasklet_schedule(&pio->queue2->txtask);
+	if (!list_empty(&pio->queue3->txqueue))
+		tasklet_schedule(&pio->queue3->txtask);
+}
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h	2006-06-13 21:11:24.000000000 +0200
@@ -52,6 +52,7 @@
 	u16 mmio_base;
 
 	u8 tx_suspended:1,
+	   tx_frozen:1,
 	   need_workarounds:1; /* Workarounds needed for core.rev < 3 */
 
 	/* Adjusted size of the device internal TX buffer. */
@@ -106,8 +107,10 @@
 				   struct bcm43xx_xmitstatus *status);
 void bcm43xx_pio_get_tx_stats(struct bcm43xx_private *bcm,
 			      struct ieee80211_tx_queue_stats *stats);
-
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue);
+/* Suspend (freeze) the TX tasklet (software level). */
+void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm);
+void bcm43xx_pio_thaw_txqueues(struct bcm43xx_private *bcm);
 
 #else /* CONFIG_BCM43XX_D80211_PIO */
 
@@ -141,6 +144,14 @@
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue)
 {
 }
+static inline
+void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm)
+{
+}
+static inline
+void bcm43xx_pio_thaw_txqueues(struct bcm43xx_private *bcm)
+{
+}
 
 #endif /* CONFIG_BCM43XX_D80211_PIO */
 #endif /* BCM43xx_PIO_H_ */

--

