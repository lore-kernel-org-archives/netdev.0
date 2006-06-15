From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Thu, 15 Jun 2006 16:03:02 -0400
Message-ID: <20060615200257.GB32582@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:28164
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1031239AbWFOUDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 16:03:42 -0400
Received: from bilbo.hq.tuxdriver.com (rrcs-70-61-120-53.midsouth.biz.rr.com [70.61.120.53])
	by ra.tuxdriver.com (8.13.6/8.13.6) with ESMTP id k5FK34ij002138
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 16:03:05 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k5FK334u009133
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 16:03:03 -0400
To: jeff@garik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 76df73ff90e99681a99e457aec4cfe0a240b7982:
  John W. Linville:
        Merge branch 'from-linus' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Jiri Slaby:
      pci: bcm43xx avoid pci_find_device

Larry Finger:
      wireless: Changes to ieee80211.h for user space regulatory daemon
      wireless: correct dump of WPA IE

Michael Buesch:
      bcm43xx: redesign locking
      bcm43xx: preemptible periodic work

Zhu Yi:
      ipw2200 locking fix

 drivers/net/wireless/bcm43xx/bcm43xx.h         |  100 +++++++----
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |   33 ++--
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c    |    4 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |  221 ++++++++++++++++--------
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c     |    9 +
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c     |   44 ++++-
 drivers/net/wireless/bcm43xx/bcm43xx_pio.h     |   13 +
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c   |   38 ++--
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |  107 ++++++------
 drivers/net/wireless/ipw2200.c                 |   41 +++-
 drivers/net/wireless/ipw2200.h                 |    1 
 include/net/ieee80211.h                        |    5 -
 net/ieee80211/softmac/ieee80211softmac_wx.c    |    2 
 13 files changed, 402 insertions(+), 216 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index e66fdb1..d8f917c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -636,6 +636,17 @@ struct bcm43xx_key {
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
@@ -646,18 +657,17 @@ struct bcm43xx_private {
 
 	void __iomem *mmio_addr;
 
-	/* Do not use the lock directly. Use the bcm43xx_lock* helper
-	 * functions, to be MMIO-safe. */
-	spinlock_t _lock;
+	/* Locking, see "theory of locking" text below. */
+	spinlock_t irq_lock;
+	struct mutex mutex;
 
-	/* Driver status flags. */
-	u32 initialized:1,		/* init_board() succeed */
-	    was_initialized:1,		/* for PCI suspend/resume. */
-	    shutting_down:1,		/* free_board() in progress */
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
 
@@ -721,7 +731,7 @@ #endif
 	struct tasklet_struct isr_tasklet;
 
 	/* Periodic tasks */
-	struct timer_list periodic_tasks;
+	struct work_struct periodic_work;
 	unsigned int periodic_state;
 
 	struct work_struct restart_work;
@@ -746,21 +756,55 @@ #ifdef CONFIG_BCM43XX_DEBUG
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
@@ -843,16 +887,6 @@ struct bcm43xx_radioinfo * bcm43xx_curre
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
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
index 7497fb1..ce2e40b 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
@@ -77,8 +77,8 @@ static ssize_t devinfo_read_file(struct 
 
 	down(&big_buffer_sem);
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -121,7 +121,7 @@ #undef fappend_core
 	fappend("\n");
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -159,8 +159,8 @@ static ssize_t spromdump_read_file(struc
 	unsigned long flags;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -169,7 +169,7 @@ static ssize_t spromdump_read_file(struc
 	fappend("boardflags: 0x%04x\n", bcm->sprom.boardflags);
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -188,8 +188,8 @@ static ssize_t tsf_read_file(struct file
 	u64 tsf;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
 	}
@@ -199,7 +199,7 @@ static ssize_t tsf_read_file(struct file
 		(unsigned int)(tsf & 0xFFFFFFFFULL));
 
 out:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -221,8 +221,8 @@ static ssize_t tsf_write_file(struct fil
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
@@ -233,10 +233,11 @@ static ssize_t tsf_write_file(struct fil
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
@@ -257,7 +258,7 @@ static ssize_t txstat_read_file(struct f
 	int i, cnt, j = 0;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	fappend("Last %d logged xmitstatus blobs (Latest first):\n\n",
 		BCM43xx_NR_LOGGED_XMITSTATUS);
@@ -293,14 +294,14 @@ static ssize_t txstat_read_file(struct f
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
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index 4b2c02c..ec80692 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -51,12 +51,12 @@ static void bcm43xx_led_blink(unsigned l
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
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 736dde9..085d785 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -498,20 +498,31 @@ static inline u32 bcm43xx_interrupt_disa
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
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm43xx_is_initializing(bcm) || bcm->shutting_down) {
-		bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
+	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)) {
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return -EBUSY;
 	}
 	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	tasklet_disable(&bcm->isr_tasklet);
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
+	bcm43xx_synchronize_irq(bcm);
+
 	if (oldstate)
 		*oldstate = old;
 
@@ -1389,7 +1400,7 @@ #ifndef CONFIG_BCM947XX
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
 	}
-	if (bcm->shutting_down) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_SHUTTINGDOWN) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
 				& ~(BCM43xx_SBF_MAC_ENABLED | 0x00000002));
@@ -1709,7 +1720,7 @@ #else
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_DEBUG*/
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1734,7 +1745,8 @@ #endif /* CONFIG_BCM43XX_DEBUG*/
 		        dma_reason[0], dma_reason[1],
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
-		bcm43xx_unlock_mmio(bcm, flags);
+		mmiowb();
+		bcm43xx_unlock_irqonly(bcm, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1821,7 +1833,8 @@ #undef bcmirq_handled
 	if (!modparam_noleds)
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
-	bcm43xx_unlock_mmio(bcm, flags);
+	mmiowb();
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -1870,7 +1883,7 @@ static irqreturn_t bcm43xx_interrupt_han
 	if (!bcm)
 		return IRQ_NONE;
 
-	spin_lock(&bcm->_lock);
+	spin_lock(&bcm->irq_lock);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -1899,7 +1912,7 @@ static irqreturn_t bcm43xx_interrupt_han
 	 * completely, but some careful work is needed to fix this. I think it
 	 * is best to stay with this cheap workaround for now... .
 	 */
-	if (likely(bcm->initialized)) {
+	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		/* disable all IRQs. They are enabled again in the bottom half. */
 		bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		/* save the reason code and call our bottom half. */
@@ -1909,7 +1922,7 @@ static irqreturn_t bcm43xx_interrupt_han
 
 out:
 	mmiowb();
-	spin_unlock(&bcm->_lock);
+	spin_unlock(&bcm->irq_lock);
 
 	return ret;
 }
@@ -2133,6 +2146,13 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_BCM947XX
+static struct pci_device_id bcm43xx_47xx_ids[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4324) },
+	{ 0 }
+};
+#endif
+
 static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
 {
 	int res;
@@ -2142,11 +2162,15 @@ static int bcm43xx_initialize_irq(struct
 	bcm->irq = bcm->pci_dev->irq;
 #ifdef CONFIG_BCM947XX
 	if (bcm->pci_dev->bus->number == 0) {
-		struct pci_dev *d = NULL;
-		/* FIXME: we will probably need more device IDs here... */
-		d = pci_find_device(PCI_VENDOR_ID_BROADCOM, 0x4324, NULL);
-		if (d != NULL) {
-			bcm->irq = d->irq;
+		struct pci_dev *d;
+		struct pci_device_id *id;
+		for (id = bcm43xx_47xx_ids; id->vendor; id++) {
+			d = pci_get_device(id->vendor, id->device, NULL);
+			if (d != NULL) {
+				bcm->irq = d->irq;
+				pci_dev_put(d);
+				break;
+			}
 		}
 	}
 #endif
@@ -3106,15 +3130,10 @@ static void bcm43xx_periodic_every15sec(
 	//TODO for APHY (temperature?)
 }
 
-static void bcm43xx_periodic_task_handler(unsigned long d)
+static void do_periodic_work(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_private *bcm = (struct bcm43xx_private *)d;
-	unsigned long flags;
 	unsigned int state;
 
-	bcm43xx_lock_mmio(bcm, flags);
-
-	assert(bcm->initialized);
 	state = bcm->periodic_state;
 	if (state % 8 == 0)
 		bcm43xx_periodic_every120sec(bcm);
@@ -3122,29 +3141,93 @@ static void bcm43xx_periodic_task_handle
 		bcm43xx_periodic_every60sec(bcm);
 	if (state % 2 == 0)
 		bcm43xx_periodic_every30sec(bcm);
-	bcm43xx_periodic_every15sec(bcm);
+	if (state % 1 == 0)
+		bcm43xx_periodic_every15sec(bcm);
 	bcm->periodic_state = state + 1;
 
-	mod_timer(&bcm->periodic_tasks, jiffies + (HZ * 15));
+	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+}
+
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
 
-	bcm43xx_unlock_mmio(bcm, flags);
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
@@ -3158,16 +3241,12 @@ static void bcm43xx_security_init(struct
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
@@ -3182,23 +3261,19 @@ static void bcm43xx_free_board(struct bc
 
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
@@ -3265,9 +3340,7 @@ static int bcm43xx_init_board(struct bcm
 	}
 
 	/* Initialization of the board is done. Flag it as such. */
-	bcm43xx_lock(bcm, flags);
-	bcm->initialized = 1;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
 
 	bcm43xx_periodic_tasks_setup(bcm);
 	bcm43xx_sysfs_register(bcm);
@@ -3278,6 +3351,8 @@ static int bcm43xx_init_board(struct bcm
 
 	assert(err == 0);
 out:
+	bcm43xx_unlock_noirq(bcm);
+
 	return err;
 
 err_80211_unwind:
@@ -3534,8 +3609,8 @@ static void bcm43xx_ieee80211_set_chan(s
 	struct bcm43xx_radioinfo *radio;
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_mac_suspend(bcm);
 		bcm43xx_radio_selectchannel(bcm, channel, 0);
 		bcm43xx_mac_enable(bcm);
@@ -3543,7 +3618,7 @@ static void bcm43xx_ieee80211_set_chan(s
 		radio = bcm43xx_current_radio(bcm);
 		radio->initial_channel = channel;
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 }
 
 /* set_security() callback in struct ieee80211_device */
@@ -3557,7 +3632,7 @@ static void bcm43xx_ieee80211_set_securi
 	
 	dprintk(KERN_INFO PFX "set security called");
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 
 	for (keyidx = 0; keyidx<WEP_KEYS; keyidx++)
 		if (sec->flags & (1<<keyidx)) {
@@ -3587,7 +3662,8 @@ static void bcm43xx_ieee80211_set_securi
 		dprintk(", .encrypt = %d", sec->encrypt);
 	}
 	dprintk("\n");
-	if (bcm->initialized && !bcm->ieee->host_encrypt) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
+	    !bcm->ieee->host_encrypt) {
 		if (secinfo->enabled) {
 			/* upload WEP keys to hardware */
 			char null_address[6] = { 0 };
@@ -3621,7 +3697,7 @@ static void bcm43xx_ieee80211_set_securi
 		} else
 				bcm43xx_clear_keys(bcm);
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 }
 
 /* hard_start_xmit() callback in struct ieee80211_device */
@@ -3633,10 +3709,10 @@ static int bcm43xx_ieee80211_hard_start_
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
@@ -3651,9 +3727,9 @@ static void bcm43xx_net_tx_timeout(struc
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 	bcm43xx_controller_restart(bcm, "TX timeout");
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3678,9 +3754,11 @@ static int bcm43xx_net_open(struct net_d
 static int bcm43xx_net_stop(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	int err;
 
 	ieee80211softmac_stop(net_dev);
-	bcm43xx_disable_interrupts_sync(bcm, NULL);
+	err = bcm43xx_disable_interrupts_sync(bcm, NULL);
+	assert(!err);
 	bcm43xx_free_board(bcm);
 
 	return 0;
@@ -3692,6 +3770,7 @@ static int bcm43xx_init_private(struct b
 {
 	int err;
 
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
@@ -3700,7 +3779,8 @@ static int bcm43xx_init_private(struct b
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
-	spin_lock_init(&bcm->_lock);
+	spin_lock_init(&bcm->irq_lock);
+	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
@@ -3831,7 +3911,7 @@ static void bcm43xx_chip_reset(void *_bc
 	struct net_device *net_dev = bcm->net_dev;
 	struct pci_dev *pci_dev = bcm->pci_dev;
 	int err;
-	int was_initialized = bcm->initialized;
+	int was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
 	netif_stop_queue(bcm->net_dev);
 	tasklet_disable(&bcm->isr_tasklet);
@@ -3866,6 +3946,7 @@ failure:
 */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
+	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
@@ -3884,11 +3965,11 @@ static int bcm43xx_suspend(struct pci_de
 
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
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index b0abac5..f8200de 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -1410,7 +1410,10 @@ static inline
 u16 bcm43xx_phy_lo_g_deviation_subval(struct bcm43xx_private *bcm, u16 control)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+	u16 ret;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	if (phy->connected) {
 		bcm43xx_phy_write(bcm, 0x15, 0xE300);
 		control <<= 8;
@@ -1430,8 +1433,10 @@ u16 bcm43xx_phy_lo_g_deviation_subval(st
 		bcm43xx_phy_write(bcm, 0x0015, control | 0xFFE0);
 		udelay(8);
 	}
+	ret = bcm43xx_phy_read(bcm, 0x002D);
+	local_irq_restore(flags);
 
-	return bcm43xx_phy_read(bcm, 0x002D);
+	return ret;
 }
 
 static u32 bcm43xx_phy_lo_g_singledeviation(struct bcm43xx_private *bcm, u16 control)
@@ -1648,7 +1653,7 @@ void bcm43xx_phy_set_baseband_attenuatio
 void bcm43xx_phy_lo_g_measure(struct bcm43xx_private *bcm)
 {
 	static const u8 pairorder[10] = { 3, 1, 5, 7, 9, 2, 0, 4, 6, 8 };
-	const int is_initializing = bcm43xx_is_initializing(bcm);
+	const int is_initializing = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZING);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	u16 h, i, oldi = 0, j;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
index 0aa1bd2..574085c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
@@ -262,8 +262,10 @@ static void tx_tasklet(unsigned long d)
 	int err;
 	u16 txctl;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqonly(bcm, flags);
 
+	if (queue->tx_frozen)
+		goto out_unlock;
 	txctl = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
 	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
 		goto out_unlock;
@@ -298,7 +300,7 @@ static void tx_tasklet(unsigned long d)
 		continue;
 	}
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqonly(bcm, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
@@ -374,7 +376,6 @@ static void cancel_transfers(struct bcm4
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 
 	netif_tx_disable(queue->bcm->net_dev);
-	assert(queue->bcm->shutting_down);
 	tasklet_disable(&queue->txtask);
 
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txrunning, list)
@@ -634,5 +635,40 @@ void bcm43xx_pio_tx_resume(struct bcm43x
 			  bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL)
 			  & ~BCM43xx_PIO_TXCTL_SUSPEND);
 	bcm43xx_power_saving_ctl_bits(queue->bcm, -1, -1);
-	tasklet_schedule(&queue->txtask);
+	if (!list_empty(&queue->txqueue))
+		tasklet_schedule(&queue->txtask);
+}
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
 }
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
+
+
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_pio.h b/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
index dfc7820..bc78a3c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
@@ -54,6 +54,7 @@ struct bcm43xx_pioqueue {
 	u16 mmio_base;
 
 	u8 tx_suspended:1,
+	   tx_frozen:1,
 	   need_workarounds:1; /* Workarounds needed for core.rev < 3 */
 
 	/* Adjusted size of the device internal TX buffer. */
@@ -108,8 +109,12 @@ void bcm43xx_pio_handle_xmitstatus(struc
 				   struct bcm43xx_xmitstatus *status);
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue);
 
+/* Suspend a TX queue on hardware level. */
 void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue);
 void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue);
+/* Suspend (freeze) the TX tasklet (software level). */
+void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm);
+void bcm43xx_pio_thaw_txqueues(struct bcm43xx_private *bcm);
 
 #else /* CONFIG_BCM43XX_PIO */
 
@@ -145,6 +150,14 @@ static inline
 void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
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
 
 #endif /* CONFIG_BCM43XX_PIO */
 #endif /* BCM43xx_PIO_H_ */
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index b438f48..6a23bdc 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -120,12 +120,12 @@ static ssize_t bcm43xx_attr_sprom_show(s
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
@@ -150,10 +150,10 @@ static ssize_t bcm43xx_attr_sprom_store(
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
 
@@ -170,15 +170,13 @@ static ssize_t bcm43xx_attr_interfmode_s
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
@@ -195,7 +193,7 @@ static ssize_t bcm43xx_attr_interfmode_s
 	}
 	err = 0;
 
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return err ? err : count;
 
@@ -231,16 +229,15 @@ static ssize_t bcm43xx_attr_interfmode_s
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
@@ -254,15 +251,13 @@ static ssize_t bcm43xx_attr_preamble_sho
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
@@ -270,7 +265,7 @@ static ssize_t bcm43xx_attr_preamble_sho
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
 	err = 0;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_noirq(bcm);
 
 	return err ? err : count;
 }
@@ -290,13 +285,12 @@ static ssize_t bcm43xx_attr_preamble_sto
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
@@ -310,7 +304,7 @@ int bcm43xx_sysfs_register(struct bcm43x
 	struct device *dev = &bcm->pci_dev->dev;
 	int err;
 
-	assert(bcm->initialized);
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
 	err = device_create_file(dev, &dev_attr_sprom);
 	if (err)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index b450639..c35cb3a 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -55,13 +55,13 @@ static int bcm43xx_wx_get_name(struct ne
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
@@ -77,7 +77,7 @@ static int bcm43xx_wx_get_name(struct ne
 			assert(0);
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	i = 0;
 	if (have_a) {
@@ -111,7 +111,7 @@ static int bcm43xx_wx_set_channelfreq(st
 	int freq;
 	int err = -EINVAL;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if ((data->freq.m >= 0) && (data->freq.m <= 1000)) {
 		channel = data->freq.m;
 		freq = bcm43xx_channel_to_freq(bcm, channel);
@@ -121,7 +121,7 @@ static int bcm43xx_wx_set_channelfreq(st
 	}
 	if (!bcm43xx_is_valid_channel(bcm, channel))
 		goto out_unlock;
-	if (bcm->initialized) {
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		//ieee80211softmac_disassoc(softmac, $REASON);
 		bcm43xx_mac_suspend(bcm);
 		err = bcm43xx_radio_selectchannel(bcm, channel, 0);
@@ -131,7 +131,7 @@ static int bcm43xx_wx_set_channelfreq(st
 		err = 0;
 	}
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -147,11 +147,10 @@ static int bcm43xx_wx_get_channelfreq(st
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
@@ -163,7 +162,7 @@ static int bcm43xx_wx_get_channelfreq(st
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -181,13 +180,13 @@ static int bcm43xx_wx_set_mode(struct ne
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
@@ -200,9 +199,9 @@ static int bcm43xx_wx_get_mode(struct ne
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	data->mode = bcm->ieee->iw_mode;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -255,7 +254,7 @@ static int bcm43xx_wx_get_rangeparams(st
 			  IW_ENC_CAPA_CIPHER_TKIP |
 			  IW_ENC_CAPA_CIPHER_CCMP;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	phy = bcm43xx_current_phy(bcm);
 
 	range->num_bitrates = 0;
@@ -302,7 +301,7 @@ static int bcm43xx_wx_get_rangeparams(st
 	}
 	range->num_frequency = j;
 
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -313,14 +312,13 @@ static int bcm43xx_wx_set_nick(struct ne
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
@@ -331,15 +329,14 @@ static int bcm43xx_wx_get_nick(struct ne
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
@@ -353,7 +350,7 @@ static int bcm43xx_wx_set_rts(struct net
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (data->rts.disabled) {
 		bcm->rts_threshold = BCM43xx_MAX_RTS_THRESHOLD;
 		err = 0;
@@ -364,7 +361,7 @@ static int bcm43xx_wx_set_rts(struct net
 			err = 0;
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -377,11 +374,11 @@ static int bcm43xx_wx_get_rts(struct net
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
@@ -395,7 +392,7 @@ static int bcm43xx_wx_set_frag(struct ne
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	if (data->frag.disabled) {
 		bcm->ieee->fts = MAX_FRAG_THRESHOLD;
 		err = 0;
@@ -406,7 +403,7 @@ static int bcm43xx_wx_set_frag(struct ne
 			err = 0;
 		}
 	}
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -419,11 +416,11 @@ static int bcm43xx_wx_get_frag(struct ne
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
@@ -445,8 +442,8 @@ static int bcm43xx_wx_set_xmitpower(stru
 		return -EOPNOTSUPP;
 	}
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (!bcm->initialized)
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
 	phy = bcm43xx_current_phy(bcm);
@@ -469,7 +466,7 @@ static int bcm43xx_wx_set_xmitpower(stru
 	err = 0;
 
 out_unlock:
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -484,8 +481,8 @@ static int bcm43xx_wx_get_xmitpower(stru
 	unsigned long flags;
 	int err = -ENODEV;
 
-	bcm43xx_lock(bcm, flags);
-	if (!bcm->initialized)
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
 	/* desired dBm value is in Q5.2 */
@@ -496,7 +493,7 @@ static int bcm43xx_wx_get_xmitpower(stru
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -583,8 +580,8 @@ static int bcm43xx_wx_set_interfmode(str
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->initialized) {
+	bcm43xx_lock_irqsafe(bcm, flags);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 		if (err) {
 			printk(KERN_ERR PFX "Interference Mitigation not "
@@ -598,7 +595,7 @@ static int bcm43xx_wx_set_interfmode(str
 		} else
 			bcm43xx_current_radio(bcm)->interfmode = mode;
 	}
-	bcm43xx_unlock_mmio(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return err;
 }
@@ -612,9 +609,9 @@ static int bcm43xx_wx_get_interfmode(str
 	unsigned long flags;
 	int mode;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	mode = bcm43xx_current_radio(bcm)->interfmode;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	switch (mode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -644,9 +641,9 @@ static int bcm43xx_wx_set_shortpreamble(
 	int on;
 
 	on = *((int *)extra);
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	bcm->short_preamble = !!on;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	return 0;
 }
@@ -660,9 +657,9 @@ static int bcm43xx_wx_get_shortpreamble(
 	unsigned long flags;
 	int on;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	on = bcm->short_preamble;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	if (on)
 		strncpy(extra, "1 (Short Preamble enabled)", MAX_WX_STRING);
@@ -684,11 +681,11 @@ static int bcm43xx_wx_set_swencryption(s
 	
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
@@ -702,9 +699,9 @@ static int bcm43xx_wx_get_swencryption(s
 	unsigned long flags;
 	int on;
 
-	bcm43xx_lock(bcm, flags);
+	bcm43xx_lock_irqsafe(bcm, flags);
 	on = bcm->ieee->host_encrypt;
-	bcm43xx_unlock(bcm, flags);
+	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	if (on)
 		strncpy(extra, "1 (SW encryption enabled) ", MAX_WX_STRING);
@@ -767,11 +764,11 @@ static int bcm43xx_wx_sprom_read(struct 
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
@@ -812,11 +809,11 @@ static int bcm43xx_wx_sprom_write(struct
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
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 39f82f2..081a899 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -533,7 +533,7 @@ static inline void ipw_clear_bit(struct 
 	ipw_write32(priv, reg, ipw_read32(priv, reg) & ~mask);
 }
 
-static inline void ipw_enable_interrupts(struct ipw_priv *priv)
+static inline void __ipw_enable_interrupts(struct ipw_priv *priv)
 {
 	if (priv->status & STATUS_INT_ENABLED)
 		return;
@@ -541,7 +541,7 @@ static inline void ipw_enable_interrupts
 	ipw_write32(priv, IPW_INTA_MASK_R, IPW_INTA_MASK_ALL);
 }
 
-static inline void ipw_disable_interrupts(struct ipw_priv *priv)
+static inline void __ipw_disable_interrupts(struct ipw_priv *priv)
 {
 	if (!(priv->status & STATUS_INT_ENABLED))
 		return;
@@ -549,6 +549,24 @@ static inline void ipw_disable_interrupt
 	ipw_write32(priv, IPW_INTA_MASK_R, ~IPW_INTA_MASK_ALL);
 }
 
+static inline void ipw_enable_interrupts(struct ipw_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	__ipw_enable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static inline void ipw_disable_interrupts(struct ipw_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	__ipw_disable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
 #ifdef CONFIG_IPW2200_DEBUG
 static char *ipw_error_desc(u32 val)
 {
@@ -1856,7 +1874,7 @@ static void ipw_irq_tasklet(struct ipw_p
 	unsigned long flags;
 	int rc = 0;
 
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->irq_lock, flags);
 
 	inta = ipw_read32(priv, IPW_INTA_RW);
 	inta_mask = ipw_read32(priv, IPW_INTA_MASK_R);
@@ -1865,6 +1883,10 @@ static void ipw_irq_tasklet(struct ipw_p
 	/* Add any cached INTA values that need to be handled */
 	inta |= priv->isr_inta;
 
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+
+	spin_lock_irqsave(&priv->lock, flags);
+
 	/* handle all the justifications for the interrupt */
 	if (inta & IPW_INTA_BIT_RX_TRANSFER) {
 		ipw_rx(priv);
@@ -1993,10 +2015,10 @@ #endif
 		IPW_ERROR("Unhandled INTA bits 0x%08x\n", inta & ~handled);
 	}
 
+	spin_unlock_irqrestore(&priv->lock, flags);
+
 	/* enable all interrupts */
 	ipw_enable_interrupts(priv);
-
-	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 #define IPW_CMD(x) case IPW_CMD_ ## x : return #x
@@ -10460,7 +10482,7 @@ static irqreturn_t ipw_isr(int irq, void
 	if (!priv)
 		return IRQ_NONE;
 
-	spin_lock(&priv->lock);
+	spin_lock(&priv->irq_lock);
 
 	if (!(priv->status & STATUS_INT_ENABLED)) {
 		/* Shared IRQ */
@@ -10482,7 +10504,7 @@ static irqreturn_t ipw_isr(int irq, void
 	}
 
 	/* tell the device to stop sending interrupts */
-	ipw_disable_interrupts(priv);
+	__ipw_disable_interrupts(priv);
 
 	/* ack current interrupts */
 	inta &= (IPW_INTA_MASK_ALL & inta_mask);
@@ -10493,11 +10515,11 @@ static irqreturn_t ipw_isr(int irq, void
 
 	tasklet_schedule(&priv->irq_tasklet);
 
-	spin_unlock(&priv->lock);
+	spin_unlock(&priv->irq_lock);
 
 	return IRQ_HANDLED;
       none:
-	spin_unlock(&priv->lock);
+	spin_unlock(&priv->irq_lock);
 	return IRQ_NONE;
 }
 
@@ -11477,6 +11499,7 @@ static int ipw_pci_probe(struct pci_dev 
 #ifdef CONFIG_IPW2200_DEBUG
 	ipw_debug_level = debug;
 #endif
+	spin_lock_init(&priv->irq_lock);
 	spin_lock_init(&priv->lock);
 	for (i = 0; i < IPW_IBSS_MAC_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&priv->ibss_mac_hash[i]);
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 6044c0b..ea12ad6 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1173,6 +1173,7 @@ struct ipw_priv {
 	struct ieee80211_device *ieee;
 
 	spinlock_t lock;
+	spinlock_t irq_lock;
 	struct mutex mutex;
 
 	/* basic pci-network driver stuff */
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index d514777..ecc4286 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -968,6 +968,7 @@ #define IEEE80211_52GHZ_CHANNELS (IEEE80
 
 enum {
 	IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
+	IEEE80211_CH_80211H_RULES = (1 << 1),
 	IEEE80211_CH_B_ONLY = (1 << 2),
 	IEEE80211_CH_NO_IBSS = (1 << 3),
 	IEEE80211_CH_UNIFORM_SPREADING = (1 << 4),
@@ -976,10 +977,10 @@ enum {
 };
 
 struct ieee80211_channel {
-	u32 freq;
+	u32 freq;	/* in MHz */
 	u8 channel;
 	u8 flags;
-	u8 max_power;
+	u8 max_power;	/* in dBm */
 };
 
 struct ieee80211_geo {
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 22aa619..0e65ff4 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -388,7 +388,7 @@ ieee80211softmac_wx_set_genie(struct net
 		memcpy(mac->wpa.IE, extra, wrqu->data.length);
 		dprintk(KERN_INFO PFX "generic IE set to ");
 		for (i=0;i<wrqu->data.length;i++)
-			dprintk("%.2x", mac->wpa.IE[i]);
+			dprintk("%.2x", (u8)mac->wpa.IE[i]);
 		dprintk("\n");
 		mac->wpa.IElen = wrqu->data.length;
 	} else {
-- 
John W. Linville
linville@tuxdriver.com
