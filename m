From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 10 Jul 2006 17:31:02 -0400
Message-ID: <20060710213101.GG13775@tuxdriver.com>
References: <20060710212900.GF13775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:56843 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965241AbWGJVbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 17:31:53 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060710212900.GF13775@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are to be queued for 2.6.19...

---

The following changes since commit b312d799b324e895745ffe148def234fc60d5b74:
  Daniel Drake:
        zd1211rw: usb_clear_halt not allowed in IRQ context

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake:
      zd1211rw: Add Sagem device ID's

Larry Finger:
      bcm43xx: improved statistics

Michael Buesch:
      bcm43xx: opencoded locking
      bcm43xx: voluntary preemtion in the calibration loops

 drivers/net/wireless/bcm43xx/bcm43xx.h         |   64 ++-------
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |   34 +++--
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c    |   10 +
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |   64 +++++----
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c     |   33 +++--
 drivers/net/wireless/bcm43xx/bcm43xx_pio.c     |    4 -
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c   |   34 +++--
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |  162 ++++++++++++++----------
 drivers/net/wireless/zd1211rw/zd_usb.c         |    2 
 9 files changed, 215 insertions(+), 192 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 17a5682..ee6571e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -649,6 +649,19 @@ enum {
 #define bcm43xx_status(bcm)		atomic_read(&(bcm)->init_status)
 #define bcm43xx_set_status(bcm, stat)	atomic_set(&(bcm)->init_status, (stat))
 
+/*    *** THEORY OF LOCKING ***
+ *
+ * We have two different locks in the bcm43xx driver.
+ * => bcm->mutex:    General sleeping mutex. Protects struct bcm43xx_private
+ *                   and the device registers. This mutex does _not_ protect
+ *                   against concurrency from the IRQ handler.
+ * => bcm->irq_lock: IRQ spinlock. Protects against IRQ handler concurrency.
+ *
+ * Please note that, if you only take the irq_lock, you are not protected
+ * against concurrency from the periodic work handlers.
+ * Most times you want to take _both_ locks.
+ */
+
 struct bcm43xx_private {
 	struct ieee80211_device *ieee;
 	struct ieee80211softmac_device *softmac;
@@ -659,7 +672,6 @@ struct bcm43xx_private {
 
 	void __iomem *mmio_addr;
 
-	/* Locking, see "theory of locking" text below. */
 	spinlock_t irq_lock;
 	struct mutex mutex;
 
@@ -691,6 +703,7 @@ struct bcm43xx_private {
 	struct bcm43xx_sprominfo sprom;
 #define BCM43xx_NR_LEDS		4
 	struct bcm43xx_led leds[BCM43xx_NR_LEDS];
+	spinlock_t leds_lock;
 
 	/* The currently active core. */
 	struct bcm43xx_coreinfo *current_core;
@@ -763,55 +776,6 @@ #endif
 };
 
 
-/*    *** THEORY OF LOCKING ***
- *
- * We have two different locks in the bcm43xx driver.
- * => bcm->mutex:    General sleeping mutex. Protects struct bcm43xx_private
- *                   and the device registers.
- * => bcm->irq_lock: IRQ spinlock. Protects against IRQ handler concurrency.
- *
- * We have three types of helper function pairs to utilize these locks.
- *     (Always use the helper functions.)
- * 1) bcm43xx_{un}lock_noirq():
- *     Takes bcm->mutex. Does _not_ protect against IRQ concurrency,
- *     so it is almost always unsafe, if device IRQs are enabled.
- *     So only use this, if device IRQs are masked.
- *     Locking may sleep.
- *     You can sleep within the critical section.
- * 2) bcm43xx_{un}lock_irqonly():
- *     Takes bcm->irq_lock. Does _not_ protect against
- *     bcm43xx_lock_noirq() critical sections.
- *     Does only protect against the IRQ handler path and other
- *     irqonly() critical sections.
- *     Locking does not sleep.
- *     You must not sleep within the critical section.
- * 3) bcm43xx_{un}lock_irqsafe():
- *     This is the cummulative lock and takes both, mutex and irq_lock.
- *     Protects against noirq() and irqonly() critical sections (and
- *     the IRQ handler path).
- *     Locking may sleep.
- *     You must not sleep within the critical section.
- */
-
-/* Lock type 1 */
-#define bcm43xx_lock_noirq(bcm)		mutex_lock(&(bcm)->mutex)
-#define bcm43xx_unlock_noirq(bcm)	mutex_unlock(&(bcm)->mutex)
-/* Lock type 2 */
-#define bcm43xx_lock_irqonly(bcm, flags)	\
-	spin_lock_irqsave(&(bcm)->irq_lock, flags)
-#define bcm43xx_unlock_irqonly(bcm, flags)	\
-	spin_unlock_irqrestore(&(bcm)->irq_lock, flags)
-/* Lock type 3 */
-#define bcm43xx_lock_irqsafe(bcm, flags) do {	\
-	bcm43xx_lock_noirq(bcm);		\
-	bcm43xx_lock_irqonly(bcm, flags);	\
-		} while (0)
-#define bcm43xx_unlock_irqsafe(bcm, flags) do {	\
-	bcm43xx_unlock_irqonly(bcm, flags);	\
-	bcm43xx_unlock_noirq(bcm);		\
-		} while (0)
-
-
 static inline
 struct bcm43xx_private * bcm43xx_priv(struct net_device *dev)
 {
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
index ce2e40b..2600ee4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
@@ -77,7 +77,8 @@ static ssize_t devinfo_read_file(struct 
 
 	down(&big_buffer_sem);
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -121,7 +122,8 @@ #undef fappend_core
 	fappend("\n");
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -159,7 +161,8 @@ static ssize_t spromdump_read_file(struc
 	unsigned long flags;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -169,7 +172,8 @@ static ssize_t spromdump_read_file(struc
 	fappend("boardflags: 0x%04x\n", bcm->sprom.boardflags);
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -188,7 +192,8 @@ static ssize_t tsf_read_file(struct file
 	u64 tsf;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -199,7 +204,8 @@ static ssize_t tsf_read_file(struct file
 		(unsigned int)(tsf & 0xFFFFFFFFULL));
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -221,7 +227,8 @@ static ssize_t tsf_write_file(struct fil
 	        res = -EFAULT;
 		goto out_up;
 	}
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		printk(KERN_INFO PFX "debugfs: Board not initialized.\n");
 		res = -EFAULT;
@@ -237,7 +244,8 @@ static ssize_t tsf_write_file(struct fil
 	res = buf_size;
 	
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 out_up:
 	up(&big_buffer_sem);
 	return res;
@@ -258,7 +266,8 @@ static ssize_t txstat_read_file(struct f
 	int i, cnt, j = 0;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	fappend("Last %d logged xmitstatus blobs (Latest first):\n\n",
 		BCM43xx_NR_LOGGED_XMITSTATUS);
@@ -294,14 +303,15 @@ static ssize_t txstat_read_file(struct f
 			i = BCM43xx_NR_LOGGED_XMITSTATUS - 1;
 	}
 
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (*ppos == pos) {
 		/* Done. Drop the copied data. */
 		e->xmitstatus_printing = 0;
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	up(&big_buffer_sem);
 	return res;
 }
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index ec80692..c3f90c8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -51,12 +51,12 @@ static void bcm43xx_led_blink(unsigned l
 	struct bcm43xx_private *bcm = led->bcm;
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->leds_lock, flags);
 	if (led->blink_interval) {
 		bcm43xx_led_changestate(led);
 		mod_timer(&led->blink_timer, jiffies + led->blink_interval);
 	}
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->leds_lock, flags);
 }
 
 static void bcm43xx_led_blink_start(struct bcm43xx_led *led,
@@ -177,7 +177,9 @@ void bcm43xx_leds_update(struct bcm43xx_
 	int i, turn_on;
 	unsigned long interval = 0;
 	u16 ledctl;
+	unsigned long flags;
 
+	spin_lock_irqsave(&bcm->leds_lock, flags);
 	ledctl = bcm43xx_read16(bcm, BCM43xx_MMIO_GPIO_CONTROL);
 	for (i = 0; i < BCM43xx_NR_LEDS; i++) {
 		led = &(bcm->leds[i]);
@@ -266,6 +268,7 @@ #endif /* CONFIG_BCM43XX_DEBUG */
 			ledctl &= ~(1 << i);
 	}
 	bcm43xx_write16(bcm, BCM43xx_MMIO_GPIO_CONTROL, ledctl);
+	spin_unlock_irqrestore(&bcm->leds_lock, flags);
 }
 
 void bcm43xx_leds_switch_all(struct bcm43xx_private *bcm, int on)
@@ -274,7 +277,9 @@ void bcm43xx_leds_switch_all(struct bcm4
 	u16 ledctl;
 	int i;
 	int bit_on;
+	unsigned long flags;
 
+	spin_lock_irqsave(&bcm->leds_lock, flags);
 	ledctl = bcm43xx_read16(bcm, BCM43xx_MMIO_GPIO_CONTROL);
 	for (i = 0; i < BCM43xx_NR_LEDS; i++) {
 		led = &(bcm->leds[i]);
@@ -290,4 +295,5 @@ void bcm43xx_leds_switch_all(struct bcm4
 			ledctl &= ~(1 << i);
 	}
 	bcm43xx_write16(bcm, BCM43xx_MMIO_GPIO_CONTROL, ledctl);
+	spin_unlock_irqrestore(&bcm->leds_lock, flags);
 }
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 3889f79..ef9bc80 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -514,13 +514,13 @@ static int bcm43xx_disable_interrupts_sy
 	unsigned long flags;
 	u32 old;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)) {
-		bcm43xx_unlock_irqonly(bcm, flags);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		return -EBUSY;
 	}
 	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	bcm43xx_synchronize_irq(bcm);
 
 	if (oldstate)
@@ -1720,7 +1720,7 @@ #else
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_DEBUG*/
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1746,7 +1746,7 @@ #endif /* CONFIG_BCM43XX_DEBUG*/
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
 		mmiowb();
-		bcm43xx_unlock_irqonly(bcm, flags);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1834,7 +1834,7 @@ #undef bcmirq_handled
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 	mmiowb();
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -3182,25 +3182,26 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		bcm43xx_lock_irqonly(bcm, flags);
 		netif_stop_queue(bcm->net_dev);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		bcm43xx_unlock_irqonly(bcm, flags);
-		bcm43xx_lock_noirq(bcm);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
+		mutex_lock(&bcm->mutex);
 		bcm43xx_synchronize_irq(bcm);
 	} else {
 		/* Periodic work should take short time, so we want low
 		 * locking overhead.
 		 */
-		bcm43xx_lock_irqsafe(bcm, flags);
+		mutex_lock(&bcm->mutex);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 	}
 
 	do_periodic_work(bcm);
 
 	if (badness > BADNESS_LIMIT) {
-		bcm43xx_lock_irqonly(bcm, flags);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 			tasklet_enable(&bcm->isr_tasklet);
 			bcm43xx_interrupt_enable(bcm, savedirqs);
@@ -3208,13 +3209,10 @@ static void bcm43xx_periodic_work_handle
 				bcm43xx_pio_thaw_txqueues(bcm);
 		}
 		netif_wake_queue(bcm->net_dev);
-		mmiowb();
-		bcm43xx_unlock_irqonly(bcm, flags);
-		bcm43xx_unlock_noirq(bcm);
-	} else {
-		mmiowb();
-		bcm43xx_unlock_irqsafe(bcm, flags);
 	}
+	mmiowb();
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
@@ -3276,7 +3274,7 @@ static void bcm43xx_free_board(struct bc
 {
 	int i, err;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
@@ -3297,7 +3295,7 @@ static void bcm43xx_free_board(struct bc
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 }
 
 static int bcm43xx_init_board(struct bcm43xx_private *bcm)
@@ -3307,7 +3305,7 @@ static int bcm43xx_init_board(struct bcm
 
 	might_sleep();
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
@@ -3389,7 +3387,7 @@ static int bcm43xx_init_board(struct bcm
 
 	assert(err == 0);
 out:
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 
@@ -3647,7 +3645,8 @@ static void bcm43xx_ieee80211_set_chan(s
 	struct bcm43xx_radioinfo *radio;
 	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_mac_suspend(bcm);
 		bcm43xx_radio_selectchannel(bcm, channel, 0);
@@ -3656,7 +3655,8 @@ static void bcm43xx_ieee80211_set_chan(s
 		radio = bcm43xx_current_radio(bcm);
 		radio->initial_channel = channel;
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 /* set_security() callback in struct ieee80211_device */
@@ -3670,7 +3670,8 @@ static void bcm43xx_ieee80211_set_securi
 	
 	dprintk(KERN_INFO PFX "set security called");
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	for (keyidx = 0; keyidx<WEP_KEYS; keyidx++)
 		if (sec->flags & (1<<keyidx)) {
@@ -3739,7 +3740,8 @@ static void bcm43xx_ieee80211_set_securi
 		} else
 				bcm43xx_clear_keys(bcm);
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 /* hard_start_xmit() callback in struct ieee80211_device */
@@ -3751,10 +3753,10 @@ static int bcm43xx_ieee80211_hard_start_
 	int err = -ENODEV;
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED))
 		err = bcm43xx_tx(bcm, txb);
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return err;
 }
@@ -3769,9 +3771,9 @@ static void bcm43xx_net_tx_timeout(struc
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	bcm43xx_controller_restart(bcm, "TX timeout");
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3822,6 +3824,7 @@ static int bcm43xx_init_private(struct b
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
 	spin_lock_init(&bcm->irq_lock);
+	spin_lock_init(&bcm->leds_lock);
 	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
@@ -4002,16 +4005,13 @@ static int bcm43xx_suspend(struct pci_de
 {
 	struct net_device *net_dev = pci_get_drvdata(pdev);
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	int try_to_shutdown = 0, err;
 
 	dprintk(KERN_INFO PFX "Suspending...\n");
 
-	bcm43xx_lock_irqsafe(bcm, flags);
 	bcm->was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 	if (bcm->was_initialized)
 		try_to_shutdown = 1;
-	bcm43xx_unlock_irqsafe(bcm, flags);
 
 	netif_device_detach(net_dev);
 	if (try_to_shutdown) {
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index f8200de..eafd0f6 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -81,6 +81,16 @@ static const s8 bcm43xx_tssi2dbm_g_table
 static void bcm43xx_phy_initg(struct bcm43xx_private *bcm);
 
 
+static inline
+void bcm43xx_voluntary_preempt(void)
+{
+	assert(!in_atomic() && !in_irq() &&
+	       !in_interrupt() && !irqs_disabled());
+#ifndef CONFIG_PREEMPT
+	cond_resched();
+#endif /* CONFIG_PREEMPT */
+}
+
 void bcm43xx_raw_phy_lock(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
@@ -133,22 +143,14 @@ void bcm43xx_phy_write(struct bcm43xx_pr
 void bcm43xx_phy_calibrate(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	unsigned long flags;
 
 	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* Dummy read. */
 	if (phy->calibrated)
 		return;
 	if (phy->type == BCM43xx_PHYTYPE_G && phy->rev == 1) {
-		/* We do not want to be preempted while calibrating
-		 * the hardware.
-		 */
-		local_irq_save(flags);
-
 		bcm43xx_wireless_core_reset(bcm, 0);
 		bcm43xx_phy_initg(bcm);
 		bcm43xx_wireless_core_reset(bcm, 1);
-
-		local_irq_restore(flags);
 	}
 	phy->calibrated = 1;
 }
@@ -1299,7 +1301,9 @@ static u16 bcm43xx_phy_lo_b_r15_loop(str
 {
 	int i;
 	u16 ret = 0;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	for (i = 0; i < 10; i++){
 		bcm43xx_phy_write(bcm, 0x0015, 0xAFA0);
 		udelay(1);
@@ -1309,6 +1313,8 @@ static u16 bcm43xx_phy_lo_b_r15_loop(str
 		udelay(40);
 		ret += bcm43xx_phy_read(bcm, 0x002C);
 	}
+	local_irq_restore(flags);
+	bcm43xx_voluntary_preempt();
 
 	return ret;
 }
@@ -1435,6 +1441,7 @@ u16 bcm43xx_phy_lo_g_deviation_subval(st
 	}
 	ret = bcm43xx_phy_read(bcm, 0x002D);
 	local_irq_restore(flags);
+	bcm43xx_voluntary_preempt();
 
 	return ret;
 }
@@ -1760,6 +1767,7 @@ void bcm43xx_phy_lo_g_measure(struct bcm
 			bcm43xx_radio_write16(bcm, 0x43, i);
 			bcm43xx_radio_write16(bcm, 0x52, radio->txctl2);
 			udelay(10);
+			bcm43xx_voluntary_preempt();
 
 			bcm43xx_phy_set_baseband_attenuation(bcm, j * 2);
 
@@ -1803,6 +1811,7 @@ void bcm43xx_phy_lo_g_measure(struct bcm
 					      radio->txctl2
 					      | (3/*txctl1*/ << 4));//FIXME: shouldn't txctl1 be zero here and 3 in the loop above?
 			udelay(10);
+			bcm43xx_voluntary_preempt();
 
 			bcm43xx_phy_set_baseband_attenuation(bcm, j * 2);
 
@@ -1824,6 +1833,7 @@ void bcm43xx_phy_lo_g_measure(struct bcm
 		bcm43xx_phy_write(bcm, 0x0812, (r27 << 8) | 0xA2);
 		udelay(2);
 		bcm43xx_phy_write(bcm, 0x0812, (r27 << 8) | 0xA3);
+		bcm43xx_voluntary_preempt();
 	} else
 		bcm43xx_phy_write(bcm, 0x0015, r27 | 0xEFA0);
 	bcm43xx_phy_lo_adjust(bcm, is_initializing);
@@ -2188,12 +2198,6 @@ int bcm43xx_phy_init(struct bcm43xx_priv
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err = -ENODEV;
-	unsigned long flags;
-
-	/* We do not want to be preempted while calibrating
-	 * the hardware.
-	 */
-	local_irq_save(flags);
 
 	switch (phy->type) {
 	case BCM43xx_PHYTYPE_A:
@@ -2227,7 +2231,6 @@ int bcm43xx_phy_init(struct bcm43xx_priv
 		err = 0;
 		break;
 	}
-	local_irq_restore(flags);
 	if (err)
 		printk(KERN_WARNING PFX "Unknown PHYTYPE found!\n");
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
index 574085c..c60c174 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
@@ -262,7 +262,7 @@ static void tx_tasklet(unsigned long d)
 	int err;
 	u16 txctl;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	if (queue->tx_frozen)
 		goto out_unlock;
@@ -300,7 +300,7 @@ static void tx_tasklet(unsigned long d)
 		continue;
 	}
 out_unlock:
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index 6a23bdc..cc1ff3c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -120,12 +120,14 @@ static ssize_t bcm43xx_attr_sprom_show(s
 			GFP_KERNEL);
 	if (!sprom)
 		return -ENOMEM;
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	err = bcm43xx_sprom_read(bcm, sprom);
 	if (!err)
 		err = sprom2hex(sprom, buf, PAGE_SIZE);
 	mmiowb();
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	kfree(sprom);
 
 	return err;
@@ -150,10 +152,14 @@ static ssize_t bcm43xx_attr_sprom_store(
 	err = hex2sprom(sprom, buf, count);
 	if (err)
 		goto out_kfree;
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+	spin_lock(&bcm->leds_lock);
 	err = bcm43xx_sprom_write(bcm, sprom);
 	mmiowb();
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock(&bcm->leds_lock);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 out_kfree:
 	kfree(sprom);
 
@@ -176,7 +182,7 @@ static ssize_t bcm43xx_attr_interfmode_s
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 
 	switch (bcm43xx_current_radio(bcm)->interfmode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -193,7 +199,7 @@ static ssize_t bcm43xx_attr_interfmode_s
 	}
 	err = 0;
 
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 
@@ -229,7 +235,8 @@ static ssize_t bcm43xx_attr_interfmode_s
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 	if (err) {
@@ -237,7 +244,8 @@ static ssize_t bcm43xx_attr_interfmode_s
 				    "supported by device\n");
 	}
 	mmiowb();
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 }
@@ -257,7 +265,7 @@ static ssize_t bcm43xx_attr_preamble_sho
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 
 	if (bcm->short_preamble)
 		count = snprintf(buf, PAGE_SIZE, "1 (Short Preamble enabled)\n");
@@ -265,7 +273,7 @@ static ssize_t bcm43xx_attr_preamble_sho
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
 	err = 0;
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 }
@@ -285,12 +293,14 @@ static ssize_t bcm43xx_attr_preamble_sto
 	value = get_boolean(buf, count);
 	if (value < 0)
 		return value;
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	bcm->short_preamble = !!value;
 
 	err = 0;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 }
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 5c36e29..8ffd760 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -47,6 +47,9 @@ #include "bcm43xx_phy.h"
 #define BCM43xx_WX_VERSION	18
 
 #define MAX_WX_STRING		80
+/* FIXME: the next line is a guess as to what the maximum value of RX power
+          (in dBm) might be */
+#define RX_POWER_MAX		-10
 
 
 static int bcm43xx_wx_get_name(struct net_device *net_dev,
@@ -56,12 +59,11 @@ static int bcm43xx_wx_get_name(struct ne
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	int i;
-	unsigned long flags;
 	struct bcm43xx_phyinfo *phy;
 	char suffix[7] = { 0 };
 	int have_a = 0, have_b = 0, have_g = 0;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		phy = &(bcm->core_80211_ext[i].phy);
 		switch (phy->type) {
@@ -77,7 +79,7 @@ static int bcm43xx_wx_get_name(struct ne
 			assert(0);
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	i = 0;
 	if (have_a) {
@@ -111,7 +113,9 @@ static int bcm43xx_wx_set_channelfreq(st
 	int freq;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+
 	if ((data->freq.m >= 0) && (data->freq.m <= 1000)) {
 		channel = data->freq.m;
 		freq = bcm43xx_channel_to_freq(bcm, channel);
@@ -131,7 +135,8 @@ static int bcm43xx_wx_set_channelfreq(st
 		err = 0;
 	}
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -143,11 +148,10 @@ static int bcm43xx_wx_get_channelfreq(st
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct bcm43xx_radioinfo *radio;
-	unsigned long flags;
 	int err = -ENODEV;
 	u16 channel;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	radio = bcm43xx_current_radio(bcm);
 	channel = radio->channel;
 	if (channel == 0xFF) {
@@ -162,7 +166,7 @@ static int bcm43xx_wx_get_channelfreq(st
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -180,13 +184,15 @@ static int bcm43xx_wx_set_mode(struct ne
 	if (mode == IW_MODE_AUTO)
 		mode = BCM43xx_INITIAL_IWMODE;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		if (bcm->ieee->iw_mode != mode)
 			bcm43xx_set_iwmode(bcm, mode);
 	} else
 		bcm->ieee->iw_mode = mode;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -197,11 +203,10 @@ static int bcm43xx_wx_get_mode(struct ne
 			       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	data->mode = bcm->ieee->iw_mode;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -214,7 +219,6 @@ static int bcm43xx_wx_get_rangeparams(st
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	const struct ieee80211_geo *geo;
-	unsigned long flags;
 	int i, j;
 	struct bcm43xx_phyinfo *phy;
 
@@ -227,14 +231,14 @@ static int bcm43xx_wx_get_rangeparams(st
 
 	range->max_qual.qual = 100;
 	/* TODO: Real max RSSI */
-	range->max_qual.level = 3;
-	range->max_qual.noise = 100;
-	range->max_qual.updated = 7;
+	range->max_qual.level = 0;
+	range->max_qual.noise = 0;
+	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
 
-	range->avg_qual.qual = 70;
-	range->avg_qual.level = 2;
-	range->avg_qual.noise = 40;
-	range->avg_qual.updated = 7;
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 0;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_ALL_UPDATED;
 
 	range->min_rts = BCM43xx_MIN_RTS_THRESHOLD;
 	range->max_rts = BCM43xx_MAX_RTS_THRESHOLD;
@@ -254,7 +258,7 @@ static int bcm43xx_wx_get_rangeparams(st
 			  IW_ENC_CAPA_CIPHER_TKIP |
 			  IW_ENC_CAPA_CIPHER_CCMP;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	phy = bcm43xx_current_phy(bcm);
 
 	range->num_bitrates = 0;
@@ -301,7 +305,7 @@ static int bcm43xx_wx_get_rangeparams(st
 	}
 	range->num_frequency = j;
 
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -314,11 +318,11 @@ static int bcm43xx_wx_set_nick(struct ne
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	size_t len;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	len =  min((size_t)data->data.length, (size_t)IW_ESSID_MAX_SIZE);
 	memcpy(bcm->nick, extra, len);
 	bcm->nick[len] = '\0';
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -331,12 +335,12 @@ static int bcm43xx_wx_get_nick(struct ne
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	size_t len;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	len = strlen(bcm->nick) + 1;
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -350,7 +354,8 @@ static int bcm43xx_wx_set_rts(struct net
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (data->rts.disabled) {
 		bcm->rts_threshold = BCM43xx_MAX_RTS_THRESHOLD;
 		err = 0;
@@ -361,7 +366,8 @@ static int bcm43xx_wx_set_rts(struct net
 			err = 0;
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -372,13 +378,12 @@ static int bcm43xx_wx_get_rts(struct net
 			      char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	data->rts.value = bcm->rts_threshold;
 	data->rts.fixed = 0;
 	data->rts.disabled = (bcm->rts_threshold == BCM43xx_MAX_RTS_THRESHOLD);
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -392,7 +397,8 @@ static int bcm43xx_wx_set_frag(struct ne
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (data->frag.disabled) {
 		bcm->ieee->fts = MAX_FRAG_THRESHOLD;
 		err = 0;
@@ -403,7 +409,8 @@ static int bcm43xx_wx_set_frag(struct ne
 			err = 0;
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -414,13 +421,12 @@ static int bcm43xx_wx_get_frag(struct ne
 			       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	data->frag.value = bcm->ieee->fts;
 	data->frag.fixed = 0;
 	data->frag.disabled = (bcm->ieee->fts == MAX_FRAG_THRESHOLD);
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -442,7 +448,8 @@ static int bcm43xx_wx_set_xmitpower(stru
 		return -EOPNOTSUPP;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
@@ -466,7 +473,8 @@ static int bcm43xx_wx_set_xmitpower(stru
 	err = 0;
 
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -478,10 +486,9 @@ static int bcm43xx_wx_get_xmitpower(stru
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct bcm43xx_radioinfo *radio;
-	unsigned long flags;
 	int err = -ENODEV;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
@@ -493,7 +500,7 @@ static int bcm43xx_wx_get_xmitpower(stru
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -580,7 +587,8 @@ static int bcm43xx_wx_set_interfmode(str
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 		if (err) {
@@ -595,7 +603,8 @@ static int bcm43xx_wx_set_interfmode(str
 		} else
 			bcm43xx_current_radio(bcm)->interfmode = mode;
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -606,12 +615,11 @@ static int bcm43xx_wx_get_interfmode(str
 				     char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	int mode;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	mode = bcm43xx_current_radio(bcm)->interfmode;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	switch (mode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -641,9 +649,11 @@ static int bcm43xx_wx_set_shortpreamble(
 	int on;
 
 	on = *((int *)extra);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	bcm->short_preamble = !!on;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -654,12 +664,11 @@ static int bcm43xx_wx_get_shortpreamble(
 					char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	int on;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	on = bcm->short_preamble;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	if (on)
 		strncpy(extra, "1 (Short Preamble enabled)", MAX_WX_STRING);
@@ -681,11 +690,13 @@ static int bcm43xx_wx_set_swencryption(s
 	
 	on = *((int *)extra);
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	bcm->ieee->host_encrypt = !!on;
 	bcm->ieee->host_decrypt = !!on;
 	bcm->ieee->host_build_iv = !on;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -696,12 +707,11 @@ static int bcm43xx_wx_get_swencryption(s
 				       char *extra)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
 	int on;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	on = bcm->ieee->host_encrypt;
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	if (on)
 		strncpy(extra, "1 (SW encryption enabled) ", MAX_WX_STRING);
@@ -764,11 +774,13 @@ static int bcm43xx_wx_sprom_read(struct 
 	if (!sprom)
 		goto out;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	err = -ENODEV;
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		err = bcm43xx_sprom_read(bcm, sprom);
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	if (!err)
 		data->data.length = sprom2hex(sprom, extra);
 	kfree(sprom);
@@ -809,11 +821,15 @@ static int bcm43xx_wx_sprom_write(struct
 	if (err)
 		goto out_kfree;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+	spin_lock(&bcm->leds_lock);
 	err = -ENODEV;
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		err = bcm43xx_sprom_write(bcm, sprom);
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock(&bcm->leds_lock);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 out_kfree:
 	kfree(sprom);
 out:
@@ -827,6 +843,9 @@ static struct iw_statistics *bcm43xx_get
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
 	struct iw_statistics *wstats;
+	struct ieee80211_network *network = NULL;
+	static int tmp_level = 0;
+	unsigned long flags;
 
 	wstats = &bcm->stats.wstats;
 	if (!mac->associated) {
@@ -844,16 +863,25 @@ static struct iw_statistics *bcm43xx_get
 		wstats->qual.level = 0;
 		wstats->qual.noise = 0;
 		wstats->qual.updated = 7;
-		wstats->qual.updated |= IW_QUAL_NOISE_INVALID |
-			IW_QUAL_QUAL_INVALID | IW_QUAL_LEVEL_INVALID;
+		wstats->qual.updated |= IW_QUAL_ALL_UPDATED;
 		return wstats;
 	}
 	/* fill in the real statistics when iface associated */
-	wstats->qual.qual = 100;     // TODO: get the real signal quality
-	wstats->qual.level = 3 - bcm->stats.link_quality;
+	spin_lock_irqsave(&mac->ieee->lock, flags);
+	list_for_each_entry(network, &mac->ieee->network_list, list) {
+		if (!memcmp(mac->associnfo.bssid, network->bssid, ETH_ALEN)) {
+			if (!tmp_level)		/* get initial value */
+				tmp_level = network->stats.rssi;
+			else			/* smooth results */
+				tmp_level = (7 * tmp_level + network->stats.rssi)/8;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&mac->ieee->lock, flags);
+	wstats->qual.level = tmp_level;
+	wstats->qual.qual = 100 + tmp_level - RX_POWER_MAX; // TODO: get the real signal quality
 	wstats->qual.noise = bcm->stats.noise;
-	wstats->qual.updated = IW_QUAL_QUAL_UPDATED | IW_QUAL_LEVEL_UPDATED |
-			IW_QUAL_NOISE_UPDATED;
+	wstats->qual.updated = IW_QUAL_ALL_UPDATED;
 	wstats->discard.code = bcm->ieee->ieee_stats.rx_discards_undecryptable;
 	wstats->discard.retries = bcm->ieee->ieee_stats.tx_retry_limit_exceeded;
 	wstats->discard.nwid = bcm->ieee->ieee_stats.tx_discards_wrong_sa;
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 72f9052..c68b9f8 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -39,9 +39,11 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0df6, 0x9071), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300b), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x079b, 0x004a), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{}
 };
 
-- 
John W. Linville
linville@tuxdriver.com
