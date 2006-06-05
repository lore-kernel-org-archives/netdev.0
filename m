From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH 1/2] bcm43xx: redesign locking
Date: Mon, 5 Jun 2006 20:24:10 +0200
Message-ID: <200606052024.11746.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Jason Lunz <lunz@falooley.org>,
	"Jory A. Pratt" <anarchy@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39403
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751124AbWFES1H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 14:27:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John, please queue for 2.6.18.

--

Redesign the bcm43xx locking.
This is pre-work to get a preemptible periodic work handler.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-03 21:04:17.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-05 18:19:59.000000000 +0200
@@ -636,6 +636,17 @@
 	u8 algorithm;
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
 	struct ieee80211_device *ieee;
 	struct ieee80211softmac_device *softmac;
@@ -647,18 +658,17 @@
 	void __iomem *mmio_addr;
 	unsigned int mmio_len;
 
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
 	    firmware_norelease:1;	/* Do not release the firmware. Used on suspend. */
 
@@ -722,7 +732,7 @@
 	struct tasklet_struct isr_tasklet;
 
 	/* Periodic tasks */
-	struct timer_list periodic_tasks;
+	struct work_struct periodic_work;
 	unsigned int periodic_state;
 
 	struct work_struct restart_work;
@@ -747,21 +757,55 @@
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
@@ -844,16 +888,6 @@
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
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-06-05 18:31:30.000000000 +0200
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
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-04-11 06:00:00.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-06-03 21:15:23.000000000 +0200
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
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-03 21:04:17.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-05 20:17:31.000000000 +0200
@@ -502,14 +502,14 @@
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
 
@@ -1387,7 +1387,7 @@
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
 	}
-	if (bcm->shutting_down) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_SHUTTINGDOWN) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
 				& ~(BCM43xx_SBF_MAC_ENABLED | 0x00000002));
@@ -1707,7 +1707,7 @@
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_DEBUG*/
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1732,7 +1732,8 @@
 		        dma_reason[0], dma_reason[1],
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
-		bcm43xx_unlock_mmio(bcm, flags);
+		mmiowb();
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1819,7 +1820,8 @@
 	if (!modparam_noleds)
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -1868,7 +1870,7 @@
 	if (!bcm)
 		return IRQ_NONE;
 
-	spin_lock(&bcm->_lock);
+	spin_lock(&bcm->irq_lock);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -1897,7 +1899,7 @@
 	 * completely, but some careful work is needed to fix this. I think it
 	 * is best to stay with this cheap workaround for now... .
 	 */
-	if (likely(bcm->initialized)) {
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		/* disable all IRQs. They are enabled again in the bottom half. */
 		bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		/* save the reason code and call our bottom half. */
@@ -1907,7 +1909,7 @@
 
 out:
 	mmiowb();
-	spin_unlock(&bcm->_lock);
+	spin_unlock(&bcm->irq_lock);
 
 	return ret;
 }
@@ -3104,15 +3106,14 @@
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
@@ -3123,26 +3124,24 @@
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
 
 static void bcm43xx_security_init(struct bcm43xx_private *bcm)
@@ -3156,16 +3155,12 @@
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
@@ -3180,23 +3175,19 @@
 
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
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
@@ -3263,9 +3254,7 @@
 	}
 
 	/* Initialization of the board is done. Flag it as such. */
-	bcm43xx_lock(bcm, flags);
-	bcm->initialized = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
 
 	bcm43xx_periodic_tasks_setup(bcm);
 	bcm43xx_sysfs_register(bcm);
@@ -3273,6 +3262,8 @@
 
 	assert(err == 0);
 out:
+	bcm43xx_unlock_noirq(bcm);
+
 	return err;
 
 err_80211_unwind:
@@ -3544,8 +3535,8 @@
 	struct bcm43xx_radioinfo *radio;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_mac_suspend(bcm);
 		bcm43xx_radio_selectchannel(bcm, channel, 0);
 		bcm43xx_mac_enable(bcm);
@@ -3553,7 +3544,7 @@
 		radio = bcm43xx_current_radio(bcm);
 		radio->initial_channel = channel;
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 }
 
 /* set_security() callback in struct ieee80211_device */
@@ -3567,7 +3558,7 @@
 	
 	dprintk(KERN_INFO PFX "set security called\n");
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	for (keyidx = 0; keyidx<WEP_KEYS; keyidx++)
 		if (sec->flags & (1<<keyidx)) {
@@ -3596,7 +3587,8 @@
 		secinfo->encrypt = sec->encrypt;
 		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
 	}
-	if (bcm->initialized && !bcm->ieee->host_encrypt) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
+	    !bcm->ieee->host_encrypt) {
 		if (secinfo->enabled) {
 			/* upload WEP keys to hardware */
 			char null_address[6] = { 0 };
@@ -3630,7 +3622,7 @@
 		} else
 				bcm43xx_clear_keys(bcm);
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 }
 
 /* hard_start_xmit() callback in struct ieee80211_device */
@@ -3642,10 +3634,10 @@
 	int err = -ENODEV;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (likely(bcm->initialized))
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED))
 		err = bcm43xx_tx(bcm, txb);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 
 	return err;
 }
@@ -3660,9 +3652,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	bcm43xx_controller_restart(bcm, "TX timeout");
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3701,6 +3693,7 @@
 {
 	int err;
 
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
@@ -3709,7 +3702,8 @@
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
-	spin_lock_init(&bcm->_lock);
+	spin_lock_init(&bcm->irq_lock);
+	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
@@ -3840,7 +3834,7 @@
 	struct net_device *net_dev = bcm->net_dev;
 	struct pci_dev *pci_dev = bcm->pci_dev;
 	int err;
-	int was_initialized = bcm->initialized;
+	int was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
 	netif_stop_queue(bcm->net_dev);
 	tasklet_disable(&bcm->isr_tasklet);
@@ -3875,6 +3869,7 @@
 */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
+	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
@@ -3893,11 +3888,11 @@
 
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
 
 	netif_device_detach(net_dev);
 	if (try_to_shutdown) {
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-06-05 20:17:31.000000000 +0200
@@ -262,7 +262,7 @@
 	int err;
 	u16 txctl;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 
 	txctl = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
 	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
@@ -298,7 +298,7 @@
 		continue;
 	}
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
@@ -374,7 +374,6 @@
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 
 	netif_tx_disable(queue->bcm->net_dev);
-	assert(queue->bcm->shutting_down);
 	tasklet_disable(&queue->txtask);
 
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txrunning, list)
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-04-28 16:13:40.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-06-05 18:29:34.000000000 +0200
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
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-05-25 20:54:02.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-06-05 18:27:12.000000000 +0200
@@ -55,13 +55,13 @@
 			       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	int i;
+	unsigned long flags;
 	struct bcm43xx_phyinfo *phy;
 	char suffix[7] = { 0 };
 	int have_a = 0, have_b = 0, have_g = 0;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		phy = &(bcm->core_80211_ext[i].phy);
 		switch (phy->type) {
@@ -77,7 +77,7 @@
 			assert(0);
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	i = 0;
 	if (have_a) {
@@ -111,7 +111,7 @@
 	int freq;
 	int err = -EINVAL;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if ((data->freq.m >= 0) && (data->freq.m <= 1000)) {
 		channel = data->freq.m;
 		freq = bcm43xx_channel_to_freq(bcm, channel);
@@ -121,7 +121,7 @@
 	}
 	if (!bcm43xx_is_valid_channel(bcm, channel))
 		goto out_unlock;
-	if (bcm->initialized) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		//ieee80211softmac_disassoc(softmac, $REASON);
 		bcm43xx_mac_suspend(bcm);
 		err = bcm43xx_radio_selectchannel(bcm, channel, 0);
@@ -131,7 +131,7 @@
 		err = 0;
 	}
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -147,11 +147,10 @@
 	int err = -ENODEV;
 	u16 channel;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	radio = bcm43xx_current_radio(bcm);
 	channel = radio->channel;
 	if (channel == 0xFF) {
-		assert(!bcm->initialized);
 		channel = radio->initial_channel;
 		if (channel == 0xFF)
 			goto out_unlock;
@@ -163,7 +162,7 @@
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -181,13 +180,13 @@
 	if (mode == IW_MODE_AUTO)
 		mode = BCM43xx_INITIAL_IWMODE;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		if (bcm->ieee->iw_mode != mode)
 			bcm43xx_set_iwmode(bcm, mode);
 	} else
 		bcm->ieee->iw_mode = mode;
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -200,9 +199,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	data->mode = bcm->ieee->iw_mode;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -255,7 +254,7 @@
 			  IW_ENC_CAPA_CIPHER_TKIP |
 			  IW_ENC_CAPA_CIPHER_CCMP;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	phy = bcm43xx_current_phy(bcm);
 
 	range->num_bitrates = 0;
@@ -302,7 +301,7 @@
 	}
 	range->num_frequency = j;
 
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -313,14 +312,13 @@
 			       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	size_t len;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_noirq(bcm);
 	len =  min((size_t)data->data.length, (size_t)IW_ESSID_MAX_SIZE);
 	memcpy(bcm->nick, extra, len);
 	bcm->nick[len] = '\0';
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return 0;
 }
@@ -331,15 +329,14 @@
 			       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	size_t len;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_noirq(bcm);
 	len = strlen(bcm->nick) + 1;
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return 0;
 }
@@ -353,7 +350,7 @@
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (data->rts.disabled) {
 		bcm->rts_threshold = BCM43xx_MAX_RTS_THRESHOLD;
 		err = 0;
@@ -364,7 +361,7 @@
 			err = 0;
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -377,11 +374,11 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	data->rts.value = bcm->rts_threshold;
 	data->rts.fixed = 0;
 	data->rts.disabled = (bcm->rts_threshold == BCM43xx_MAX_RTS_THRESHOLD);
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -395,7 +392,7 @@
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (data->frag.disabled) {
 		bcm->ieee->fts = MAX_FRAG_THRESHOLD;
 		err = 0;
@@ -406,7 +403,7 @@
 			err = 0;
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -419,11 +416,11 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	data->frag.value = bcm->ieee->fts;
 	data->frag.fixed = 0;
 	data->frag.disabled = (bcm->ieee->fts == MAX_FRAG_THRESHOLD);
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -445,8 +442,8 @@
 		return -EOPNOTSUPP;
 	}
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized)
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
 	phy = bcm43xx_current_phy(bcm);
@@ -469,7 +466,7 @@
 	err = 0;
 
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -484,8 +481,8 @@
 	unsigned long flags;
 	int err = -ENODEV;
 
-	bcm43xx_lock(bcm, flags);
-	if (!bcm->initialized)
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
 	/* desired dBm value is in Q5.2 */
@@ -496,7 +493,7 @@
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -583,8 +580,8 @@
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 		if (err) {
 			printk(KERN_ERR PFX "Interference Mitigation not "
@@ -598,7 +595,7 @@
 		} else
 			bcm43xx_current_radio(bcm)->interfmode = mode;
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -612,9 +609,9 @@
 	unsigned long flags;
 	int mode;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	mode = bcm43xx_current_radio(bcm)->interfmode;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	switch (mode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -644,9 +641,9 @@
 	int on;
 
 	on = *((int *)extra);
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	bcm->short_preamble = !!on;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -660,9 +657,9 @@
 	unsigned long flags;
 	int on;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	on = bcm->short_preamble;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	if (on)
 		strncpy(extra, "1 (Short Preamble enabled)", MAX_WX_STRING);
@@ -684,11 +681,11 @@
 	
 	on = *((int *)extra);
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	bcm->ieee->host_encrypt = !!on;
 	bcm->ieee->host_decrypt = !!on;
 	bcm->ieee->host_build_iv = !on;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -702,9 +699,9 @@
 	unsigned long flags;
 	int on;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	on = bcm->ieee->host_encrypt;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	if (on)
 		strncpy(extra, "1 (SW encryption enabled) ", MAX_WX_STRING);
@@ -767,11 +764,11 @@
 	if (!sprom)
 		goto out;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	err = -ENODEV;
-	if (bcm->initialized)
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		err = bcm43xx_sprom_read(bcm, sprom);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	if (!err)
 		data->data.length = sprom2hex(sprom, extra);
 	kfree(sprom);
@@ -812,11 +809,11 @@
 	if (err)
 		goto out_kfree;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	err = -ENODEV;
-	if (bcm->initialized)
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		err = bcm43xx_sprom_write(bcm, sprom);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 out_kfree:
 	kfree(sprom);
 out:
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-06-05 17:47:26.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-06-05 20:17:31.000000000 +0200
@@ -1648,7 +1648,7 @@
 void bcm43xx_phy_lo_g_measure(struct bcm43xx_private *bcm)
 {
 	static const u8 pairorder[10] = { 3, 1, 5, 7, 9, 2, 0, 4, 6, 8 };
-	const int is_initializing = bcm43xx_is_initializing(bcm);
+	const int is_initializing = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZING);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	u16 h, i, oldi = 0, j;


-- 
Greetings Michael.
