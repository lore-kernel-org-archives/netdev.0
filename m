From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx-softmac: Init, shutdown and restart fixes
Date: Mon, 21 Aug 2006 09:43:44 -0500
Message-ID: <44E9C6A0.3090107@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060008090507020403000706"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:39597 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030300AbWHUOns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 10:43:48 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060008090507020403000706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi John,

Please apply this to wireless-2.6.

Larry

--

This fixes various bugs in the init and shutdown code
that would lead to lockups and crashes, and is the softmac
equivalent of the patches submitted by Michael Buesch for
bcm43xx-d80211.
These changes may fix some of the NETDEV WATCHDOG transmit
timeouts, but they do not fix all of them, at least not in softmac.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

===============================





--------------060008090507020403000706
Content-Type: text/plain;
 name="patch_init"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_init"

index b095f3c..8ba7e0a 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -519,6 +519,7 @@ static int bcm43xx_disable_interrupts_sy
 		return -EBUSY;
 	}
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_MASK); /* flush */
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	bcm43xx_synchronize_irq(bcm);
 
@@ -3150,6 +3157,7 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
+		mutex_lock(&bcm->mutex);
 		netif_stop_queue(bcm->net_dev);
 		synchronize_net();
 		spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -3158,7 +3160,6 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		spin_unlock_irqrestore(&bcm->irq_lock, flags);
-		mutex_lock(&bcm->mutex);
 		bcm43xx_synchronize_irq(bcm);
 	} else {
 		/* Periodic work should take short time, so we want low
@@ -3172,13 +3173,11 @@ static void bcm43xx_periodic_work_handle
 
 	if (badness > BADNESS_LIMIT) {
 		spin_lock_irqsave(&bcm->irq_lock, flags);
-		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-			tasklet_enable(&bcm->isr_tasklet);
-			bcm43xx_interrupt_enable(bcm, savedirqs);
-			if (bcm43xx_using_pio(bcm))
-				bcm43xx_pio_thaw_txqueues(bcm);
-			bcm43xx_mac_enable(bcm);
-		}
+		tasklet_enable(&bcm->isr_tasklet);
+		bcm43xx_interrupt_enable(bcm, savedirqs);
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_thaw_txqueues(bcm);
+		bcm43xx_mac_enable(bcm);
 		netif_wake_queue(bcm->net_dev);
 	}
 	mmiowb();
@@ -3186,12 +3185,12 @@ static void bcm43xx_periodic_work_handle
 	mutex_unlock(&bcm->mutex);
 }
 
-static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
+void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
 {
 	cancel_rearming_delayed_work(&bcm->periodic_work);
 }
 
-static void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
+void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
 {
 	struct work_struct *work = &(bcm->periodic_work);
 
@@ -3537,11 +3536,10 @@ static int bcm43xx_init_board(struct bcm
 	err = bcm43xx_select_wireless_core(bcm, -1);
 	if (err)
 		goto err_crystal_off;
-
-	bcm43xx_periodic_tasks_setup(bcm);
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
+	bcm43xx_periodic_tasks_setup(bcm);
 	err = bcm43xx_rng_init(bcm);
 	if (err)
 		goto err_sysfs_unreg;
@@ -3965,6 +3963,7 @@ static int bcm43xx_net_stop(struct net_d
 	err = bcm43xx_disable_interrupts_sync(bcm);
 	assert(!err);
 	bcm43xx_free_board(bcm);
+	flush_scheduled_work();
 
 	return 0;
 }
@@ -4115,11 +4115,16 @@ static void bcm43xx_chip_reset(void *_bc
 {
 	struct bcm43xx_private *bcm = _bcm;
 	struct bcm43xx_phyinfo *phy;
-	int err;
+	int err = -ENODEV;
 
 	mutex_lock(&(bcm)->mutex);
-	phy = bcm43xx_current_phy(bcm);
-	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
+		bcm43xx_periodic_tasks_delete(bcm);
+		phy = bcm43xx_current_phy(bcm);
+		err = bcm43xx_select_wireless_core(bcm, phy->type);
+		if (!err)
+			bcm43xx_periodic_tasks_setup(bcm);
+	}
 	mutex_unlock(&(bcm)->mutex);
 
 	printk(KERN_ERR PFX "Controller restart%s\n",
@@ -4128,11 +4133,12 @@ static void bcm43xx_chip_reset(void *_bc
 
 /* Hard-reset the chip.
  * This can be called from interrupt or process context.
+ * bcm->irq_lock must be locked.
  */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
-	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
+		return;
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
 	INIT_WORK(&bcm->restart_work, bcm43xx_chip_reset, bcm);
 	schedule_work(&bcm->restart_work);

index 505c86e..f763571 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -141,6 +141,9 @@ void bcm43xx_wireless_core_reset(struct 
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm);
 
+void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm);
+void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm);
+
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason);
 
 int bcm43xx_sprom_read(struct bcm43xx_private *bcm, u16 *sprom);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index ece3351..a16400d 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -333,8 +333,11 @@ static ssize_t bcm43xx_attr_phymode_stor
 		goto out;
 	}
 
+	bcm43xx_periodic_tasks_delete(bcm);
 	mutex_lock(&(bcm)->mutex);
 	err = bcm43xx_select_wireless_core(bcm, phytype);
+	if (!err)
+		bcm43xx_periodic_tasks_setup(bcm);
 	mutex_unlock(&(bcm)->mutex);
 	if (err == -ESRCH)
 		err = -ENODEV;


--------------060008090507020403000706--
