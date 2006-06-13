From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH 1/4] bcm43xx: Port new locking scheme to d80211
Date: Tue, 13 Jun 2006 21:18:15 +0200
Message-ID: <200606132118.16330.mb@bu3sch.de>
References: <20060613191206.122150000@ppc1>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:33221
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751108AbWFMTUK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 15:20:10 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Port the new locking scheme from bcm43xx-softmac to bcm43xx-d80211.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-06-13 21:11:08.000000000 +0200
@@ -649,6 +649,17 @@
 	unsigned int promisc:1;
 };
 
+/* Driver initialization status. */
+enum {
+	BCM43xx_STAT_UNINIT,		/* Uninitialized. */
+	BCM43xx_STAT_INITIALIZING,	/* init_board() in progress. */
+	BCM43xx_STAT_INITIALIZED,	/* Fully operational. */
+	BCM43xx_STAT_SHUTTINGDOWN,	/* free_board() in progress. */
+	BCM43xx_STAT_RESTARTING,	/* controller_restart() called. */
+};
+#define bcm43xx_status(bcm)		atomic_read(&(bcm)->init_status)
+#define bcm43xx_set_status(bcm, stat)	atomic_set(&(bcm)->init_status, (stat))
+
 struct bcm43xx_private {
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
@@ -659,18 +670,17 @@
 
 	void __iomem *mmio_addr;
 
-	/* Do not use the lock directly. Use the bcm43xx_lock* helper
-	 * functions, to be MMIO-safe. */
-	spinlock_t _lock;
-
-	/* Driver status flags. */
-	u32 initialized:1,		/* init_board() succeed */
-	    was_initialized:1,		/* for PCI suspend/resume. */
-	    shutting_down:1,		/* free_board() in progress */
+	/* Locking, see "theory of locking" text below. */
+	spinlock_t irq_lock;
+	struct mutex mutex;
+
+	/* Driver initialization status BCM43xx_STAT_*** */
+	atomic_t init_status;
+
+	u16 was_initialized:1,		/* for PCI suspend/resume. */
 	    __using_pio:1,		/* Internal, use bcm43xx_using_pio(). */
 	    bad_frames_preempt:1,	/* Use "Bad Frames Preemption" (default off) */
 	    reg124_set_0x4:1,		/* Some variable to keep track of IRQ stuff. */
-	    powersaving:1,		/* TRUE if we are in PowerSaving mode. FALSE otherwise. */
 	    short_preamble:1,		/* TRUE, if short preamble is enabled. */
 	    short_slot:1,		/* TRUE, if short slot timing is enabled. */
 	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend. */
@@ -738,7 +748,7 @@
 	struct tasklet_struct isr_tasklet;
 
 	/* Periodic tasks */
-	struct timer_list periodic_tasks;
+	struct work_struct periodic_work;
 	unsigned int periodic_state;
 
 	struct work_struct restart_work;
@@ -766,21 +776,55 @@
 #endif
 };
 
-/* bcm43xx_(un)lock() protect struct bcm43xx_private.
- * Note that _NO_ MMIO writes are allowed. If you want to
- * write to the device through MMIO in the critical section, use
- * the *_mmio lock functions.
- * MMIO read-access is allowed, though.
- */
-#define bcm43xx_lock(bcm, flags)	spin_lock_irqsave(&(bcm)->_lock, flags)
-#define bcm43xx_unlock(bcm, flags)	spin_unlock_irqrestore(&(bcm)->_lock, flags)
-/* bcm43xx_(un)lock_mmio() protect struct bcm43xx_private and MMIO.
- * MMIO write-access to the device is allowed.
- * All MMIO writes are flushed on unlock, so it is guaranteed to not
- * interfere with other threads writing MMIO registers.
+
+/*    *** THEORY OF LOCKING ***
+ *
+ * We have two different locks in the bcm43xx driver.
+ * => bcm->mutex:    General sleeping mutex. Protects struct bcm43xx_private
+ *                   and the device registers.
+ * => bcm->irq_lock: IRQ spinlock. Protects against IRQ handler concurrency.
+ *
+ * We have three types of helper function pairs to utilize these locks.
+ *     (Always use the helper functions.)
+ * 1) bcm43xx_{un}lock_noirq():
+ *     Takes bcm->mutex. Does _not_ protect against IRQ concurrency,
+ *     so it is almost always unsafe, if device IRQs are enabled.
+ *     So only use this, if device IRQs are masked.
+ *     Locking may sleep.
+ *     You can sleep within the critical section.
+ * 2) bcm43xx_{un}lock_irqonly():
+ *     Takes bcm->irq_lock. Does _not_ protect against
+ *     bcm43xx_lock_noirq() critical sections.
+ *     Does only protect against the IRQ handler path and other
+ *     irqonly() critical sections.
+ *     Locking does not sleep.
+ *     You must not sleep within the critical section.
+ * 3) bcm43xx_{un}lock_irqsafe():
+ *     This is the cummulative lock and takes both, mutex and irq_lock.
+ *     Protects against noirq() and irqonly() critical sections (and
+ *     the IRQ handler path).
+ *     Locking may sleep.
+ *     You must not sleep within the critical section.
  */
-#define bcm43xx_lock_mmio(bcm, flags)	bcm43xx_lock(bcm, flags)
-#define bcm43xx_unlock_mmio(bcm, flags)	do { mmiowb(); bcm43xx_unlock(bcm, flags); } while (0)
+
+/* Lock type 1 */
+#define bcm43xx_lock_noirq(bcm)		mutex_lock(&(bcm)->mutex)
+#define bcm43xx_unlock_noirq(bcm)	mutex_unlock(&(bcm)->mutex)
+/* Lock type 2 */
+#define bcm43xx_lock_irqonly(bcm, flags)	\
+	spin_lock_irqsave(&(bcm)->irq_lock, flags)
+#define bcm43xx_unlock_irqonly(bcm, flags)	\
+	spin_unlock_irqrestore(&(bcm)->irq_lock, flags)
+/* Lock type 3 */
+#define bcm43xx_lock_irqsafe(bcm, flags) do {	\
+	bcm43xx_lock_noirq(bcm);		\
+	bcm43xx_lock_irqonly(bcm, flags);	\
+		} while (0)
+#define bcm43xx_unlock_irqsafe(bcm, flags) do {	\
+	bcm43xx_unlock_irqonly(bcm, flags);	\
+	bcm43xx_unlock_noirq(bcm);		\
+		} while (0)
+
 
 static inline
 struct bcm43xx_private * bcm43xx_priv(struct net_device *dev)
@@ -848,16 +892,6 @@
 	return &(bcm->core_80211_ext[bcm->current_80211_core_idx].radio);
 }
 
-/* Are we running in init_board() context? */
-static inline
-int bcm43xx_is_initializing(struct bcm43xx_private *bcm)
-{
-	if (bcm->initialized)
-		return 0;
-	if (bcm->shutting_down)
-		return 0;
-	return 1;
-}
 
 static inline
 struct bcm43xx_lopair * bcm43xx_get_lopair(struct bcm43xx_phyinfo *phy,
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-06-13 21:11:08.000000000 +0200
@@ -77,8 +77,8 @@
 
 	down(&big_buffer_sem);
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -121,7 +121,7 @@
 	fappend("\n");
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -159,8 +159,8 @@
 	unsigned long flags;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -169,7 +169,7 @@
 	fappend("boardflags: 0x%04x\n", bcm->sprom.boardflags);
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -188,8 +188,8 @@
 	u64 tsf;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -199,7 +199,7 @@
 		(unsigned int)(tsf & 0xFFFFFFFFULL));
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -221,8 +221,8 @@
 	        res = -EFAULT;
 		goto out_up;
 	}
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		printk(KERN_INFO PFX "debugfs: Board not initialized.\n");
 		res = -EFAULT;
 		goto out_unlock;
@@ -233,10 +233,11 @@
 		goto out_unlock;
 	}
 	bcm43xx_tsf_write(bcm, tsf);
+	mmiowb();
 	res = buf_size;
 	
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 out_up:
 	up(&big_buffer_sem);
 	return res;
@@ -257,7 +258,7 @@
 	int i, cnt, j = 0;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	fappend("Last %d logged xmitstatus blobs (Latest first):\n\n",
 		BCM43xx_NR_LOGGED_XMITSTATUS);
@@ -293,14 +294,14 @@
 			i = BCM43xx_NR_LOGGED_XMITSTATUS - 1;
 	}
 
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (*ppos == pos) {
 		/* Done. Drop the copied data. */
 		e->xmitstatus_printing = 0;
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	up(&big_buffer_sem);
 	return res;
 }
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-06-13 21:11:08.000000000 +0200
@@ -51,12 +51,12 @@
 	struct bcm43xx_private *bcm = led->bcm;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	if (led->blink_interval) {
 		bcm43xx_led_changestate(led);
 		mod_timer(&led->blink_timer, jiffies + led->blink_interval);
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void bcm43xx_led_blink_start(struct bcm43xx_led *led,
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-06-13 21:11:08.000000000 +0200
@@ -369,7 +369,7 @@
 	 * Time is measured in microseconds.
 	 */
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	radio = bcm43xx_current_radio(bcm);
 	oldchan = radio->channel;
 	testchan = (oldchan == 6) ? 7 : 6;
@@ -377,7 +377,7 @@
 	bcm43xx_radio_selectchannel(bcm, testchan, 0);
 	bcm43xx_tsf_read(bcm, &stop);
 	bcm43xx_radio_selectchannel(bcm, oldchan, 0);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	assert(stop > start);
 	bcm->ieee->channel_change_time = stop - start;
@@ -535,14 +535,14 @@
 	u32 old;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm43xx_is_initializing(bcm) || bcm->shutting_down) {
-		bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)) {
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return -EBUSY;
 	}
 	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	tasklet_disable(&bcm->isr_tasklet);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 	if (oldstate)
 		*oldstate = old;
 
@@ -1277,7 +1277,7 @@
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
 	}
-	if (bcm->shutting_down) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_SHUTTINGDOWN) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
 				& ~(BCM43xx_SBF_MAC_ENABLED | 0x00000002));
@@ -1592,7 +1592,7 @@
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_D80211_DEBUG*/
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1617,7 +1617,8 @@
 		        dma_reason[0], dma_reason[1],
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
-		bcm43xx_unlock_mmio(bcm, flags);
+		mmiowb();
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1704,7 +1705,8 @@
 	if (!modparam_noleds)
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -1753,7 +1755,7 @@
 	if (!bcm)
 		return IRQ_NONE;
 
-	spin_lock(&bcm->_lock);
+	spin_lock(&bcm->irq_lock);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -1782,7 +1784,7 @@
 	 * completely, but some careful work is needed to fix this. I think it
 	 * is best to stay with this cheap workaround for now... .
 	 */
-	if (likely(bcm->initialized)) {
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		/* disable all IRQs. They are enabled again in the bottom half. */
 		bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		/* save the reason code and call our bottom half. */
@@ -1792,7 +1794,7 @@
 
 out:
 	mmiowb();
-	spin_unlock(&bcm->_lock);
+	spin_unlock(&bcm->irq_lock);
 
 	return ret;
 }
@@ -2949,15 +2951,14 @@
 	//TODO for APHY (temperature?)
 }
 
-static void bcm43xx_periodic_task_handler(unsigned long d)
+static void bcm43xx_periodic_work_handler(void *d)
 {
-	struct bcm43xx_private *bcm = (struct bcm43xx_private *)d;
+	struct bcm43xx_private *bcm = d;
 	unsigned long flags;
 	unsigned int state;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
-	assert(bcm->initialized);
 	state = bcm->periodic_state;
 	if (state % 8 == 0)
 		bcm43xx_periodic_every120sec(bcm);
@@ -2968,26 +2969,24 @@
 	bcm43xx_periodic_every15sec(bcm);
 	bcm->periodic_state = state + 1;
 
-	mod_timer(&bcm->periodic_tasks, jiffies + (HZ * 15));
+	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
 
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqsafe(bcm, flags);
 }
 
 static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
 {
-	del_timer_sync(&bcm->periodic_tasks);
+	cancel_rearming_delayed_work(&bcm->periodic_work);
 }
 
 static void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
 {
-	struct timer_list *timer = &(bcm->periodic_tasks);
+	struct work_struct *work = &(bcm->periodic_work);
 
-	assert(bcm->initialized);
-	setup_timer(timer,
-		    bcm43xx_periodic_task_handler,
-		    (unsigned long)bcm);
-	timer->expires = jiffies;
-	add_timer(timer);
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	INIT_WORK(work, bcm43xx_periodic_work_handler, bcm);
+	schedule_work(work);
 }
 
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
@@ -3637,16 +3636,12 @@
 static void bcm43xx_free_board(struct bcm43xx_private *bcm)
 {
 	int i, err;
-	unsigned long flags;
 
+	bcm43xx_lock_noirq(bcm);
 	bcm43xx_sysfs_unregister(bcm);
-
 	bcm43xx_periodic_tasks_delete(bcm);
 
-	bcm43xx_lock(bcm, flags);
-	bcm->initialized = 0;
-	bcm->shutting_down = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
 
 	for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
 		if (!bcm->core_80211[i].available)
@@ -3662,23 +3657,19 @@
 	bcm43xx_pctl_set_crystal(bcm, 0);
 	bcm43xx_free_modes(bcm);
 
-	bcm43xx_lock(bcm, flags);
-	bcm->shutting_down = 0;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
+	bcm43xx_unlock_noirq(bcm);
 }
 
 static int bcm43xx_init_board(struct bcm43xx_private *bcm)
 {
 	int i, err;
 	int connect_phy;
-	unsigned long flags;
 
 	might_sleep();
 
-	bcm43xx_lock(bcm, flags);
-	bcm->initialized = 0;
-	bcm->shutting_down = 0;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_lock_noirq(bcm);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
 	if (err)
@@ -3750,15 +3741,15 @@
 	}
 
 	/* Initialization of the board is done. Flag it as such. */
-	bcm43xx_lock(bcm, flags);
-	bcm->initialized = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
 
 	bcm43xx_periodic_tasks_setup(bcm);
 	bcm43xx_sysfs_register(bcm);
 
 	assert(err == 0);
 out:
+	bcm43xx_unlock_noirq(bcm);
+
 	return err;
 
 err_80211_unwind:
@@ -3983,14 +3974,14 @@
 	int err = -ENODEV;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (likely(bcm->initialized)) {
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		if (bcm43xx_using_pio(bcm))
 			err = bcm43xx_pio_tx(bcm, skb, ctl);
 		else
 			err = bcm43xx_dma_tx(bcm, skb, ctl);
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return err;
 }
@@ -4000,9 +3991,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	bcm43xx_controller_restart(bcm, "IEEE reset");
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return 0;
 }
@@ -4015,9 +4006,9 @@
 	struct bcm43xx_phyinfo *phy;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
-		bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return 0;
 	}
 	radio = bcm43xx_current_radio(bcm);
@@ -4052,7 +4043,7 @@
 	//TODO: phymode
 	//TODO: antennas
 
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return 0;
 }
@@ -4092,7 +4083,7 @@
 	index = (u8)(key->keyidx);
 	if (index >= ARRAY_SIZE(bcm->key))
 		goto out;
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	switch (cmd) {
 	case SET_KEY:
 		err = bcm43xx_key_write(bcm, index, algorithm,
@@ -4120,7 +4111,7 @@
 		break;
 	}
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 out:
 	return err;
 }
@@ -4139,15 +4130,15 @@
 	unsigned long flags;
 	int err = -ENODEV;
 
-	bcm43xx_lock(bcm, flags);
-	if (likely(bcm->initialized)) {
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_get_tx_stats(bcm, stats);
 		else
 			bcm43xx_dma_get_tx_stats(bcm, stats);
 		err = 0;
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return err;
 }
@@ -4158,9 +4149,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	memcpy(stats, &bcm->ieee_stats, sizeof(*stats));
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -4188,7 +4179,7 @@
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 
-	if (bcm->initialized) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_disable_interrupts_sync(bcm, NULL);
 		bcm43xx_free_board(bcm);
 	}
@@ -4203,7 +4194,7 @@
 	unsigned long flags;
 	int err = -EOPNOTSUPP;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
 		bcm->interface.monitor++;
@@ -4215,7 +4206,7 @@
 		bcm->interface.mac_addr = conf->mac_addr;
 		bcm->interface.type = conf->type;
 	}
-	if (bcm->initialized)
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		bcm43xx_select_opmode(bcm);
 	err = 0;
 
@@ -4226,7 +4217,7 @@
 		BCM43xx_MACARG(conf->mac_addr));
 
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -4237,15 +4228,15 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
 		bcm->interface.monitor--;
 		assert(bcm->interface.monitor >= 0);
 	} else
 		bcm->interface.operating = 0;
-	if (bcm->initialized)
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		bcm43xx_select_opmode(bcm);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	dprintk(KERN_INFO PFX "Virtual interface removed "
 			      "(type: 0x%08X, ID: %d, MAC: "
@@ -4261,12 +4252,12 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (conf->type != IEEE80211_IF_TYPE_MNTR) {
 		assert(bcm->interface.if_id == if_id);
 		bcm->interface.bssid = conf->bssid;
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -4278,13 +4269,13 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	if (bcm->interface.promisc != !!(netflags & IFF_PROMISC)) {
 		bcm->interface.promisc = !!(netflags & IFF_PROMISC);
-		if (bcm->initialized)
+		if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 			bcm43xx_select_opmode(bcm);
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 /* Initialization of struct net_device, just after allocation. */
@@ -4308,7 +4299,8 @@
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
-	spin_lock_init(&bcm->_lock);
+	spin_lock_init(&bcm->irq_lock);
+	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
@@ -4445,7 +4437,7 @@
 	struct pci_dev *pci_dev = bcm->pci_dev;
 	struct ieee80211_hw *ieee = bcm->ieee;
 	int err;
-	int was_initialized = bcm->initialized;
+	int was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
 	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
 	tasklet_disable(&bcm->isr_tasklet);
@@ -4480,6 +4472,7 @@
  */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
+	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
@@ -4498,11 +4491,11 @@
 
 	dprintk(KERN_INFO PFX "Suspending...\n");
 
-	bcm43xx_lock(bcm, flags);
-	bcm->was_initialized = bcm->initialized;
-	if (bcm->initialized)
+	bcm43xx_lock_irqsafe(bcm, flags);
+	bcm->was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	if (bcm->was_initialized)
 		try_to_shutdown = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
 	if (try_to_shutdown) {
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-06-13 21:11:08.000000000 +0200
@@ -120,12 +120,12 @@
 			GFP_KERNEL);
 	if (!sprom)
 		return -ENOMEM;
-	bcm43xx_lock_mmio(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	err = bcm43xx_sprom_read(bcm, sprom);
 	if (!err)
 		err = sprom2hex(sprom, buf, PAGE_SIZE);
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	kfree(sprom);
 
 	return err;
@@ -150,10 +150,10 @@
 	err = hex2sprom(sprom, buf, count);
 	if (err)
 		goto out_kfree;
-	bcm43xx_lock_mmio(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	err = bcm43xx_sprom_write(bcm, sprom);
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqsafe(bcm, flags);
 out_kfree:
 	kfree(sprom);
 
@@ -170,15 +170,13 @@
 					    char *buf)
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	unsigned long flags;
 	int err;
 	ssize_t count = 0;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_noirq(bcm);
 
 	switch (bcm43xx_current_radio(bcm)->interfmode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -195,7 +193,7 @@
 	}
 	err = 0;
 
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return err ? err : count;
 
@@ -231,16 +229,15 @@
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_mmio(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 	if (err) {
 		printk(KERN_ERR PFX "Interference Mitigation not "
 				    "supported by device\n");
 	}
-
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err ? err : count;
 }
@@ -254,15 +251,13 @@
 					  char *buf)
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	unsigned long flags;
 	int err;
 	ssize_t count;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_noirq(bcm);
 
 	if (bcm->short_preamble)
 		count = snprintf(buf, PAGE_SIZE, "1 (Short Preamble enabled)\n");
@@ -270,7 +265,7 @@
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
 	err = 0;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return err ? err : count;
 }
@@ -290,13 +285,12 @@
 	value = get_boolean(buf, count);
 	if (value < 0)
 		return value;
-	bcm43xx_lock(bcm, flags);
-	assert(bcm->initialized);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	bcm->short_preamble = !!value;
 
 	err = 0;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err ? err : count;
 }
@@ -310,7 +304,7 @@
 	struct device *dev = &bcm->pci_dev->dev;
 	int err;
 
-	assert(bcm->initialized);
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
 	err = device_create_file(dev, &dev_attr_sprom);
 	if (err)
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-06-13 21:11:06.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-06-13 21:11:08.000000000 +0200
@@ -1648,7 +1648,7 @@
 void bcm43xx_phy_lo_g_measure(struct bcm43xx_private *bcm)
 {
 	static const u8 pairorder[10] = { 3, 1, 5, 7, 9, 2, 0, 4, 6, 8 };
-	const int is_initializing = bcm43xx_is_initializing(bcm);
+	const int is_initializing = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZING);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	u16 h, i, oldi = 0, j;
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:06.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:08.000000000 +0200
@@ -257,7 +257,7 @@
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 	int err;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txqueue, list) {
 		/* Try to transmit the packet. This can fail, if
 		 * the device queue is full. In case of failure, the
@@ -270,7 +270,7 @@
 		if (err)
 			break;
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
@@ -339,7 +339,6 @@
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 
 	ieee80211_netif_oper(queue->bcm->net_dev, NETIF_DETACH);
-	assert(queue->bcm->shutting_down);
 	tasklet_disable(&queue->txtask);
 
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txrunning, list)

--

