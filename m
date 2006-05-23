From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH, RTF/RFC] bcm43xx: Enable local IRQs while executing periodic work
Date: Tue, 23 May 2006 17:23:09 +0200
Message-ID: <200605231723.10028.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37835
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751348AbWEWPXZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 11:23:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is supposed to heavily increase overall system
vitality. It reduces the time periodic work in the bcm43xx driver
is run, with IRQs disabled, from several msecs to a few usecs.

I am not sure, if we still want to have this in 2.6.17, as
it is not a crash fix or something. But it fixes "lost interrupt"
problems for some people.

I would like to get this into wireless-2.6, but before that
happens I would like to have a few regression tests by people.
Please apply this and run high network traffic for 10-15 minutes.
Please enable kernel spinlock lockup and recursion detection
while testing.

--


Enable local CPU IRQs while executing periodic work handlers.
Periodic work handlers may take a long time to execute,
so disabling IRQs for the whole time is a bad idea.

This patch disables and synchronizes all bcm43xx IRQs on
periodic work entry and re-enables CPU IRQs afterwards.
It still tempoarly disables CPU IRQs while measuring the
deviation value, as I have the feeling that this is time
critical and may not be interrupted. This causes IRQs to be
disabled for about 35usecs. I hope that does not hurt.

This is an attempt to reduce system IRQ pressure and avoid
lost IRQs in other devices.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-05-22 13:32:34.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-05-22 14:14:18.000000000 +0200
@@ -647,9 +647,7 @@
 	void __iomem *mmio_addr;
 	unsigned int mmio_len;
 
-	/* Do not use the lock directly. Use the bcm43xx_lock* helper
-	 * functions, to be MMIO-safe. */
-	spinlock_t _lock;
+	spinlock_t lock;
 
 	/* Driver status flags. */
 	u32 initialized:1,		/* init_board() succeed */
@@ -753,8 +751,8 @@
  * the *_mmio lock functions.
  * MMIO read-access is allowed, though.
  */
-#define bcm43xx_lock(bcm, flags)	spin_lock_irqsave(&(bcm)->_lock, flags)
-#define bcm43xx_unlock(bcm, flags)	spin_unlock_irqrestore(&(bcm)->_lock, flags)
+#define bcm43xx_lock(bcm, flags)	spin_lock_irqsave(&(bcm)->lock, flags)
+#define bcm43xx_unlock(bcm, flags)	spin_unlock_irqrestore(&(bcm)->lock, flags)
 /* bcm43xx_(un)lock_mmio() protect struct bcm43xx_private and MMIO.
  * MMIO write-access to the device is allowed.
  * All MMIO writes are flushed on unlock, so it is guaranteed to not
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-22 13:32:34.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-22 14:40:08.000000000 +0200
@@ -496,20 +496,34 @@
 	return old_mask;
 }
 
-/* Make sure we don't receive more data from the device. */
+/* Disable IRQs on the device and make sure no IRQ handler
+ * (or tasklet) is running on return.
+ */
 static int bcm43xx_disable_interrupts_sync(struct bcm43xx_private *bcm, u32 *oldstate)
 {
 	u32 old;
 	unsigned long flags;
+	unsigned int irq;
 
 	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm43xx_is_initializing(bcm) || bcm->shutting_down) {
+	if (unlikely(bcm43xx_is_initializing(bcm) ||
+		     bcm->shutting_down)) {
 		bcm43xx_unlock_mmio(bcm, flags);
 		return -EBUSY;
 	}
+	irq = bcm->irq;
 	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	tasklet_disable(&bcm->isr_tasklet);
+
+	/* Unlock, so running IRQ handlers or tasklets can return
+	 * and don't deadlock.
+	 * The access of isr_tasklet after unlocking is Ok, because
+	 * it can not race after synchronizing IRQ.
+	 */
 	bcm43xx_unlock_mmio(bcm, flags);
+
+	synchronize_irq(irq);
+	tasklet_disable(&bcm->isr_tasklet);
+
 	if (oldstate)
 		*oldstate = old;
 
@@ -1860,7 +1874,7 @@
 	if (!bcm)
 		return IRQ_NONE;
 
-	spin_lock(&bcm->_lock);
+	spin_lock(&bcm->lock);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -1899,7 +1913,7 @@
 
 out:
 	mmiowb();
-	spin_unlock(&bcm->_lock);
+	spin_unlock(&bcm->lock);
 
 	return ret;
 }
@@ -3101,8 +3115,19 @@
 	struct bcm43xx_private *bcm = (struct bcm43xx_private *)d;
 	unsigned long flags;
 	unsigned int state;
+	u32 savedirqs;
+	int err;
 
-	bcm43xx_lock_mmio(bcm, flags);
+	err = bcm43xx_disable_interrupts_sync(bcm, &savedirqs);
+	assert(!err);
+	/* Periodic work can take a long time so we don't want
+	 * to disable IRQs on the CPU.
+	 * spin_lock() is deadlock safe here, because we previously
+	 * disabled and synced IRQs on the device. No IRQ is supposed
+	 * to happen before bcm43xx_interrupt_enable(), so it
+	 * can't deadlock with the spin_lock in the IRQ handler.
+	 */
+	spin_lock(&bcm->lock);
 
 	assert(bcm->initialized);
 	state = bcm->periodic_state;
@@ -3117,7 +3142,12 @@
 
 	mod_timer(&bcm->periodic_tasks, jiffies + (HZ * 15));
 
-	bcm43xx_unlock_mmio(bcm, flags);
+	local_irq_save(flags);
+	bcm43xx_interrupt_enable(bcm, savedirqs);
+	tasklet_enable(&bcm->isr_tasklet);
+	mmiowb();
+	spin_unlock(&bcm->lock);
+	local_irq_restore(flags);
 }
 
 static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
@@ -3678,9 +3708,11 @@
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
@@ -3700,7 +3732,7 @@
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
-	spin_lock_init(&bcm->_lock);
+	spin_lock_init(&bcm->lock);
 	tasklet_init(&bcm->isr_tasklet,
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-05-22 13:32:34.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_phy.c	2006-05-22 14:20:57.000000000 +0200
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
