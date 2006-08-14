From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx-d80211: Init, shutdown and restart fixes
Date: Mon, 14 Aug 2006 21:32:24 +0200
Message-ID: <200608142132.25398.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.

--

This fixes various bugs in the init and shutdown code
that would lead to lockups and crashes.
This is best reproducable by receiving a timeout from
the netdev watchdog.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-13 23:55:33.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-14 18:19:14.000000000 +0200
@@ -593,6 +593,7 @@
 		return -EBUSY;
 	}
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_MASK); /* flush */
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	bcm43xx_synchronize_irq(bcm);
 
@@ -2896,6 +2897,7 @@
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
+		mutex_lock(&bcm->mutex);
 		netif_stop_queue(bcm->net_dev);
 		synchronize_net();
 		spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -2904,7 +2906,6 @@
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		spin_unlock_irqrestore(&bcm->irq_lock, flags);
-		mutex_lock(&bcm->mutex);
 		bcm43xx_synchronize_irq(bcm);
 	} else {
 		/* Periodic work should take short time, so we want low
@@ -2918,13 +2919,11 @@
 
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
@@ -3622,13 +3621,16 @@
 	if (!active_core)
 		return -ESRCH; /* No such PHYTYPE on this board. */
 
+	/* Disable all network traffic. */
+	for (i = 0; i < bcm->ieee->queues; i++)
+		ieee80211_stop_queue(bcm->net_dev, i);
+	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
+
 	if (bcm->active_80211_core) {
 		/* We already selected a wl core in the past.
 		 * So first clean up everything.
 		 */
 		dprintk(KERN_INFO PFX "select_wireless_core: cleanup\n");
-		ieee80211_netif_oper(bcm->net_dev, NETIF_STOP);
-		ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
 		bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
 		err = bcm43xx_disable_interrupts_sync(bcm);
 		assert(!err);
@@ -3700,10 +3702,8 @@
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
-	ieee80211_start_queues(bcm->net_dev);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
-	ieee80211_netif_oper(bcm->net_dev, NETIF_START);
-	ieee80211_netif_oper(bcm->net_dev, NETIF_WAKE);
+	ieee80211_start_queues(bcm->net_dev);
 
 	/* Let's go! Be careful after enabling the IRQs.
 	 * Don't switch cores, for example.
@@ -3742,11 +3742,10 @@
 	err = bcm43xx_select_wireless_core(bcm, -1);
 	if (err)
 		goto err_crystal_off;
-
-	bcm43xx_periodic_tasks_setup(bcm);
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
+	bcm43xx_periodic_tasks_setup(bcm);
 out:
 	mutex_unlock(&bcm->mutex);
 
@@ -4028,9 +4027,13 @@
 		assert(0);
 	}
 	if (phy->type != new_phymode) {
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
+		bcm43xx_periodic_tasks_delete(bcm);
 		err = bcm43xx_select_wireless_core(bcm, new_phymode);
 		if (err)
-			goto out_unlock;
+			goto out_unlock_mutex;
+		bcm43xx_periodic_tasks_setup(bcm);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
 		phy = bcm43xx_current_phy(bcm);
 		radio = bcm43xx_current_radio(bcm);
 	}
@@ -4091,6 +4094,7 @@
 
 out_unlock:
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+out_unlock_mutex:
 	mutex_unlock(&bcm->mutex);
 
 	return err;
@@ -4237,6 +4241,7 @@
 		assert(!err);
 		bcm43xx_free_board(bcm);
 	}
+	flush_scheduled_work();
 
 	return 0;
 }
@@ -4504,11 +4509,16 @@
 {
 	struct bcm43xx_private *bcm = _bcm;
 	struct bcm43xx_phyinfo *phy;
-	int err;
+	int err = -ENODEV;
 
 	mutex_lock(&bcm->mutex);
-	phy = bcm43xx_current_phy(bcm);
-	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
+		bcm43xx_periodic_tasks_delete(bcm);
+		phy = bcm43xx_current_phy(bcm);
+		err = bcm43xx_select_wireless_core(bcm, phy->type);
+		if (!err)
+			bcm43xx_periodic_tasks_setup(bcm);
+	}
 	mutex_unlock(&bcm->mutex);
 
 	printk("%s" PFX "Controller restart%s\n",
@@ -4518,11 +4528,12 @@
 
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


-- 
Greetings Michael.
