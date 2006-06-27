From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: opencoded locking
Date: Tue, 27 Jun 2006 21:38:40 +0200
Message-ID: <200606272138.41251.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:18389
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030251AbWF0TjZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 15:39:25 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As many people don't seem to like the locking "obfuscation"
in the bcm43xx driver, this patch removes it.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-27 17:47:24.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-06-27 20:44:27.000000000 +0200
@@ -647,6 +647,19 @@
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
@@ -657,7 +670,6 @@
 
 	void __iomem *mmio_addr;
 
-	/* Locking, see "theory of locking" text below. */
 	spinlock_t irq_lock;
 	struct mutex mutex;
 
@@ -689,6 +701,7 @@
 	struct bcm43xx_sprominfo sprom;
 #define BCM43xx_NR_LEDS		4
 	struct bcm43xx_led leds[BCM43xx_NR_LEDS];
+	spinlock_t leds_lock;
 
 	/* The currently active core. */
 	struct bcm43xx_coreinfo *current_core;
@@ -759,55 +772,6 @@
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
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-06-24 22:13:44.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-06-27 20:44:27.000000000 +0200
@@ -77,7 +77,8 @@
 
 	down(&big_buffer_sem);
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -121,7 +122,8 @@
 	fappend("\n");
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -159,7 +161,8 @@
 	unsigned long flags;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -169,7 +172,8 @@
 	fappend("boardflags: 0x%04x\n", bcm->sprom.boardflags);
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -188,7 +192,8 @@
 	u64 tsf;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		fappend("Board not initialized.\n");
 		goto out;
@@ -199,7 +204,8 @@
 		(unsigned int)(tsf & 0xFFFFFFFFULL));
 
 out:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
 	up(&big_buffer_sem);
 	return res;
@@ -221,7 +227,8 @@
 	        res = -EFAULT;
 		goto out_up;
 	}
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
 		printk(KERN_INFO PFX "debugfs: Board not initialized.\n");
 		res = -EFAULT;
@@ -237,7 +244,8 @@
 	res = buf_size;
 	
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 out_up:
 	up(&big_buffer_sem);
 	return res;
@@ -258,7 +266,8 @@
 	int i, cnt, j = 0;
 
 	down(&big_buffer_sem);
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	fappend("Last %d logged xmitstatus blobs (Latest first):\n\n",
 		BCM43xx_NR_LOGGED_XMITSTATUS);
@@ -294,14 +303,15 @@
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
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-06-24 22:13:44.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-06-27 20:44:27.000000000 +0200
@@ -51,12 +51,12 @@
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
@@ -177,7 +177,9 @@
 	int i, turn_on;
 	unsigned long interval = 0;
 	u16 ledctl;
+	unsigned long flags;
 
+	spin_lock_irqsave(&bcm->leds_lock, flags);
 	ledctl = bcm43xx_read16(bcm, BCM43xx_MMIO_GPIO_CONTROL);
 	for (i = 0; i < BCM43xx_NR_LEDS; i++) {
 		led = &(bcm->leds[i]);
@@ -266,6 +268,7 @@
 			ledctl &= ~(1 << i);
 	}
 	bcm43xx_write16(bcm, BCM43xx_MMIO_GPIO_CONTROL, ledctl);
+	spin_unlock_irqrestore(&bcm->leds_lock, flags);
 }
 
 void bcm43xx_leds_switch_all(struct bcm43xx_private *bcm, int on)
@@ -274,7 +277,9 @@
 	u16 ledctl;
 	int i;
 	int bit_on;
+	unsigned long flags;
 
+	spin_lock_irqsave(&bcm->leds_lock, flags);
 	ledctl = bcm43xx_read16(bcm, BCM43xx_MMIO_GPIO_CONTROL);
 	for (i = 0; i < BCM43xx_NR_LEDS; i++) {
 		led = &(bcm->leds[i]);
@@ -290,4 +295,5 @@
 			ledctl &= ~(1 << i);
 	}
 	bcm43xx_write16(bcm, BCM43xx_MMIO_GPIO_CONTROL, ledctl);
+	spin_unlock_irqrestore(&bcm->leds_lock, flags);
 }
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 20:41:18.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 21:21:17.000000000 +0200
@@ -514,13 +514,13 @@
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
@@ -1720,7 +1720,7 @@
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_DEBUG*/
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1746,7 +1746,7 @@
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
 		mmiowb();
-		bcm43xx_unlock_irqonly(bcm, flags);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1834,7 +1834,7 @@
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 	mmiowb();
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -3193,25 +3193,26 @@
 		 */
 		netif_stop_queue(bcm->net_dev);
 		synchronize_net();
-		bcm43xx_lock_irqonly(bcm, flags);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
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
@@ -3220,13 +3221,10 @@
 			bcm43xx_mac_enable(bcm);
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
@@ -3255,7 +3253,7 @@
 {
 	int i, err;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
@@ -3275,7 +3273,7 @@
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 }
 
 static int bcm43xx_init_board(struct bcm43xx_private *bcm)
@@ -3285,7 +3283,7 @@
 
 	might_sleep();
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
@@ -3364,7 +3362,7 @@
 
 	assert(err == 0);
 out:
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 
@@ -3622,7 +3620,8 @@
 	struct bcm43xx_radioinfo *radio;
 	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm43xx_mac_suspend(bcm);
 		bcm43xx_radio_selectchannel(bcm, channel, 0);
@@ -3631,7 +3630,8 @@
 		radio = bcm43xx_current_radio(bcm);
 		radio->initial_channel = channel;
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 /* set_security() callback in struct ieee80211_device */
@@ -3645,7 +3645,8 @@
 	
 	dprintk(KERN_INFO PFX "set security called");
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	for (keyidx = 0; keyidx<WEP_KEYS; keyidx++)
 		if (sec->flags & (1<<keyidx)) {
@@ -3714,7 +3715,8 @@
 		} else
 				bcm43xx_clear_keys(bcm);
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 }
 
 /* hard_start_xmit() callback in struct ieee80211_device */
@@ -3726,10 +3728,10 @@
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
@@ -3744,9 +3746,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	bcm43xx_controller_restart(bcm, "TX timeout");
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -3798,6 +3800,7 @@
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
 	spin_lock_init(&bcm->irq_lock);
+	spin_lock_init(&bcm->leds_lock);
 	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
@@ -3978,16 +3981,13 @@
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
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-06-24 22:13:44.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-06-27 20:44:28.000000000 +0200
@@ -262,7 +262,7 @@
 	int err;
 	u16 txctl;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	if (queue->tx_frozen)
 		goto out_unlock;
@@ -300,7 +300,7 @@
 		continue;
 	}
 out_unlock:
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-06-24 22:13:44.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-06-27 20:44:28.000000000 +0200
@@ -120,12 +120,14 @@
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
@@ -150,10 +152,14 @@
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
 
@@ -176,7 +182,7 @@
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 
 	switch (bcm43xx_current_radio(bcm)->interfmode) {
 	case BCM43xx_RADIO_INTERFMODE_NONE:
@@ -193,7 +199,7 @@
 	}
 	err = 0;
 
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 
@@ -229,7 +235,8 @@
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 	if (err) {
@@ -237,7 +244,8 @@
 				    "supported by device\n");
 	}
 	mmiowb();
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 }
@@ -257,7 +265,7 @@
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 
 	if (bcm->short_preamble)
 		count = snprintf(buf, PAGE_SIZE, "1 (Short Preamble enabled)\n");
@@ -265,7 +273,7 @@
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
 	err = 0;
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err ? err : count;
 }
@@ -285,12 +293,14 @@
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
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-06-27 17:47:24.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-06-27 21:36:31.000000000 +0200
@@ -56,12 +56,11 @@
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
@@ -77,7 +76,7 @@
 			assert(0);
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	i = 0;
 	if (have_a) {
@@ -111,7 +110,9 @@
 	int freq;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+
 	if ((data->freq.m >= 0) && (data->freq.m <= 1000)) {
 		channel = data->freq.m;
 		freq = bcm43xx_channel_to_freq(bcm, channel);
@@ -131,7 +132,8 @@
 		err = 0;
 	}
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -143,11 +145,10 @@
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
@@ -162,7 +163,7 @@
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -180,13 +181,15 @@
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
@@ -197,11 +200,10 @@
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
@@ -214,7 +216,6 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	const struct ieee80211_geo *geo;
-	unsigned long flags;
 	int i, j;
 	struct bcm43xx_phyinfo *phy;
 
@@ -254,7 +255,7 @@
 			  IW_ENC_CAPA_CIPHER_TKIP |
 			  IW_ENC_CAPA_CIPHER_CCMP;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
 	phy = bcm43xx_current_phy(bcm);
 
 	range->num_bitrates = 0;
@@ -301,7 +302,7 @@
 	}
 	range->num_frequency = j;
 
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -314,11 +315,11 @@
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
@@ -331,12 +332,12 @@
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
@@ -350,7 +351,8 @@
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (data->rts.disabled) {
 		bcm->rts_threshold = BCM43xx_MAX_RTS_THRESHOLD;
 		err = 0;
@@ -361,7 +363,8 @@
 			err = 0;
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -372,13 +375,12 @@
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
@@ -392,7 +394,8 @@
 	unsigned long flags;
 	int err = -EINVAL;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (data->frag.disabled) {
 		bcm->ieee->fts = MAX_FRAG_THRESHOLD;
 		err = 0;
@@ -403,7 +406,8 @@
 			err = 0;
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -414,13 +418,12 @@
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
@@ -442,7 +445,8 @@
 		return -EOPNOTSUPP;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
@@ -466,7 +470,8 @@
 	err = 0;
 
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -478,10 +483,9 @@
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
@@ -493,7 +497,7 @@
 
 	err = 0;
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -580,7 +584,8 @@
 		return -EINVAL;
 	}
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		err = bcm43xx_radio_set_interference_mitigation(bcm, mode);
 		if (err) {
@@ -595,7 +600,8 @@
 		} else
 			bcm43xx_current_radio(bcm)->interfmode = mode;
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -606,12 +612,11 @@
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
@@ -641,9 +646,11 @@
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
@@ -654,12 +661,11 @@
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
@@ -681,11 +687,13 @@
 	
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
@@ -696,12 +704,11 @@
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
@@ -764,11 +771,13 @@
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
@@ -809,11 +818,15 @@
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


-- 
Greetings Michael.
