From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: opencoded locking
Date: Sun, 9 Jul 2006 03:50:42 +0200
Message-ID: <200607090350.42677.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:17063
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161040AbWGIBwk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 21:52:40 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

please apply to wireless-dev.

--

Port of the "opencoded locking" patch from bcm43xx-softmac
to bcm43xx-d80211.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-07-09 01:56:07.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-07-09 02:31:45.000000000 +0200
@@ -660,6 +660,19 @@
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
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
@@ -670,7 +683,6 @@
 
 	void __iomem *mmio_addr;
 
-	/* Locking, see "theory of locking" text below. */
 	spinlock_t irq_lock;
 	struct mutex mutex;
 
@@ -710,6 +722,7 @@
 	struct bcm43xx_sprominfo sprom;
 #define BCM43xx_NR_LEDS		4
 	struct bcm43xx_led leds[BCM43xx_NR_LEDS];
+	spinlock_t leds_lock;
 
 	/* The currently active core. */
 	struct bcm43xx_coreinfo *current_core;
@@ -779,55 +792,6 @@
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
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-07-09 02:31:45.000000000 +0200
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
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-07-09 02:31:45.000000000 +0200
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
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-07-09 02:08:08.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-07-09 02:50:15.000000000 +0200
@@ -386,7 +386,7 @@
 	 * Time is measured in microseconds.
 	 */
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	radio = bcm43xx_current_radio(bcm);
 	oldchan = radio->channel;
 	testchan = (oldchan == 6) ? 7 : 6;
@@ -394,7 +394,7 @@
 	bcm43xx_radio_selectchannel(bcm, testchan, 0);
 	bcm43xx_tsf_read(bcm, &stop);
 	bcm43xx_radio_selectchannel(bcm, oldchan, 0);
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	assert(stop > start);
 	bcm->ieee->channel_change_time = stop - start;
@@ -521,13 +521,13 @@
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
@@ -1843,7 +1843,7 @@
 # define bcmirq_handled(irq)	do { /* nothing */ } while (0)
 #endif /* CONFIG_BCM43XX_D80211_DEBUG*/
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	reason = bcm->irq_reason;
 	dma_reason[0] = bcm->dma_reason[0];
 	dma_reason[1] = bcm->dma_reason[1];
@@ -1869,7 +1869,7 @@
 			dma_reason[2], dma_reason[3]);
 		bcm43xx_controller_restart(bcm, "DMA error");
 		mmiowb();
-		bcm43xx_unlock_irqonly(bcm, flags);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		return;
 	}
 	if (unlikely((dma_reason[0] & BCM43xx_DMAIRQ_NONFATALMASK) |
@@ -1957,7 +1957,7 @@
 		bcm43xx_leds_update(bcm, activity);
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 	mmiowb();
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void pio_irq_workaround(struct bcm43xx_private *bcm,
@@ -3264,25 +3264,26 @@
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
@@ -3291,13 +3292,10 @@
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
@@ -3962,7 +3960,7 @@
 {
 	int i, err;
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
@@ -3983,7 +3981,7 @@
 	bcm43xx_free_modes(bcm);
 
 	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 }
 
 static int bcm43xx_init_board(struct bcm43xx_private *bcm)
@@ -3993,7 +3991,7 @@
 
 	might_sleep();
 
-	bcm43xx_lock_noirq(bcm);
+	mutex_lock(&bcm->mutex);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
 	err = bcm43xx_pctl_set_crystal(bcm, 1);
@@ -4073,7 +4071,7 @@
 
 	assert(err == 0);
 out:
-	bcm43xx_unlock_noirq(bcm);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 
@@ -4299,14 +4297,14 @@
 	int err = -ENODEV;
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		if (bcm43xx_using_pio(bcm))
 			err = bcm43xx_pio_tx(bcm, skb, ctl);
 		else
 			err = bcm43xx_dma_tx(bcm, skb, ctl);
 	}
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return err;
 }
@@ -4316,9 +4314,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	bcm43xx_controller_restart(bcm, "IEEE reset");
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return 0;
 }
@@ -4331,11 +4329,9 @@
 	struct bcm43xx_phyinfo *phy;
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
-	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
-		bcm43xx_unlock_irqonly(bcm, flags);
-		return 0;
-	}
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
+		goto out_unlock;
 	radio = bcm43xx_current_radio(bcm);
 	phy = bcm43xx_current_phy(bcm);
 
@@ -4384,7 +4380,8 @@
 		bcm43xx_refresh_templates(bcm);
 	}
 
-	bcm43xx_unlock_irqonly(bcm, flags);
+out_unlock:
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return 0;
 }
@@ -4424,7 +4421,9 @@
 	index = (u8)(key->keyidx);
 	if (index >= ARRAY_SIZE(bcm->key))
 		goto out;
-	bcm43xx_lock_irqsafe(bcm, flags);
+
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	switch (cmd) {
 	case SET_KEY:
 		err = bcm43xx_key_write(bcm, index, algorithm,
@@ -4452,7 +4451,8 @@
 		break;
 	}
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 out:
 	return err;
 }
@@ -4471,7 +4471,7 @@
 	unsigned long flags;
 	int err = -ENODEV;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_get_tx_stats(bcm, stats);
@@ -4479,7 +4479,7 @@
 			bcm43xx_dma_get_tx_stats(bcm, stats);
 		err = 0;
 	}
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return err;
 }
@@ -4490,9 +4490,9 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	memcpy(stats, &bcm->ieee_stats, sizeof(*stats));
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 
 	return 0;
 }
@@ -4537,7 +4537,8 @@
 	unsigned long flags;
 	int err = -EOPNOTSUPP;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
 		bcm->interface.monitor++;
@@ -4563,7 +4564,8 @@
 		BCM43xx_MACARG(conf->mac_addr));
 
 out_unlock:
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return err;
 }
@@ -4574,7 +4576,8 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
 		bcm->interface.monitor--;
 		assert(bcm->interface.monitor >= 0);
@@ -4582,7 +4585,8 @@
 		bcm->interface.operating = 0;
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 		bcm43xx_select_opmode(bcm);
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	dprintk(KERN_INFO PFX "Virtual interface removed "
 			      "(type: 0x%08X, ID: %d, MAC: "
@@ -4598,7 +4602,8 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqsafe(bcm, flags);
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (conf->type != IEEE80211_IF_TYPE_MNTR) {
 		assert(bcm->interface.if_id == if_id);
 		bcm->interface.bssid = conf->bssid;
@@ -4608,7 +4613,8 @@
 			bcm43xx_refresh_templates(bcm);
 		}
 	}
-	bcm43xx_unlock_irqsafe(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
 	return 0;
 }
@@ -4620,13 +4626,13 @@
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm->interface.promisc != !!(netflags & IFF_PROMISC)) {
 		bcm->interface.promisc = !!(netflags & IFF_PROMISC);
 		if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
 			bcm43xx_select_opmode(bcm);
 	}
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 /* Initialization of struct net_device, just after allocation. */
@@ -4652,6 +4658,7 @@
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
 	spin_lock_init(&bcm->irq_lock);
+	spin_lock_init(&bcm->leds_lock);
 	mutex_init(&bcm->mutex);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
@@ -4838,16 +4845,13 @@
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
 
 	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
 	if (try_to_shutdown) {
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-07-09 02:33:14.000000000 +0200
@@ -263,7 +263,7 @@
 	int err;
 	u16 txctl;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (queue->tx_frozen)
 		goto out_unlock;
 	txctl = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
@@ -283,7 +283,7 @@
 			break;
 	}
 out_unlock:
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
 static void setup_txqueues(struct bcm43xx_pioqueue *queue)
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-07-09 02:31:45.000000000 +0200
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

-- 
Greetings Michael.
