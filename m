From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] sky2: only bring up watchdog if link is active
Date: Tue, 21 Aug 2007 14:34:03 -0700
Message-ID: <20070821213456.627533707@linux-foundation.org>
References: <20070821213401.543412708@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarxik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58289 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753414AbXHUVif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 17:38:35 -0400
Content-Disposition: inline; filename=sky2-timer-power.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the extra timer overhead that people were whining about
as a 2.6.23 regression.

Running the watchdog timer all the time is unneeded. Change it
to run only if link is up, and reduce frequency to save power.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-21 09:53:50.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 09:54:15.000000000 -0700
@@ -99,10 +99,6 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 100;
-module_param(idle_timeout, int, 0);
-MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
-
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
@@ -1624,6 +1620,9 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
+	if (netif_carrier_ok(dev) && --hw->active == 0)
+		del_timer(&hw->watchdog_timer);
+
 	/* Stop more packets from being queued */
 	netif_stop_queue(dev);
 
@@ -1744,6 +1743,10 @@ static void sky2_link_up(struct sky2_por
 
 	netif_carrier_on(sky2->netdev);
 
+	if (hw->active++ == 0)
+		mod_timer(&hw->watchdog_timer, jiffies + 1);
+
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
@@ -1795,6 +1798,11 @@ static void sky2_link_down(struct sky2_p
 
 	netif_carrier_off(sky2->netdev);
 
+	/* Stop watchdog if both ports are not active */
+	if (--hw->active == 0)
+		del_timer(&hw->watchdog_timer);
+
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 
@@ -2426,25 +2434,20 @@ static void sky2_le_error(struct sky2_hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* If idle then force a fake soft NAPI poll once a second
- * to work around cases where sharing an edge triggered interrupt.
- */
-static inline void sky2_idle_start(struct sky2_hw *hw)
-{
-	if (idle_timeout > 0)
-		mod_timer(&hw->idle_timer,
-			  jiffies + msecs_to_jiffies(idle_timeout));
-}
-
-static void sky2_idle(unsigned long arg)
+/* Check for lost IRQ once a second */
+static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
-	struct net_device *dev = hw->dev[0];
 
-	if (__netif_rx_schedule_prep(dev))
-		__netif_rx_schedule(dev);
+	if (sky2_read32(hw, B0_ISRC)) {
+		struct net_device *dev = hw->dev[0];
+
+		if (__netif_rx_schedule_prep(dev))
+			__netif_rx_schedule(dev);
+	}
 
-	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
+	if (hw->active > 0)
+		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
@@ -2732,8 +2735,6 @@ static void sky2_restart(struct work_str
 	struct net_device *dev;
 	int i, err;
 
-	del_timer_sync(&hw->idle_timer);
-
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
@@ -2762,8 +2763,6 @@ static void sky2_restart(struct work_str
 		}
 	}
 
-	sky2_idle_start(hw);
-
 	rtnl_unlock();
 }
 
@@ -4030,11 +4029,9 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
-	sky2_idle_start(hw);
-
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
@@ -4069,7 +4066,7 @@ static void __devexit sky2_remove(struct
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 
 	flush_scheduled_work();
 
@@ -4113,7 +4110,6 @@ static int sky2_suspend(struct pci_dev *
 	if (!hw)
 		return 0;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -4179,7 +4175,7 @@ static int sky2_resume(struct pci_dev *p
 	}
 
 	netif_poll_enable(hw->dev[0]);
-	sky2_idle_start(hw);
+
 	return 0;
 out:
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
@@ -4196,7 +4192,6 @@ static void sky2_shutdown(struct pci_dev
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
--- a/drivers/net/sky2.h	2007-08-20 16:32:28.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-21 09:53:53.000000000 -0700
@@ -2045,12 +2045,13 @@ struct sky2_hw {
 	u8		     chip_rev;
 	u8		     pmd_type;
 	u8		     ports;
+	u8		     active;
 
 	struct sky2_status_le *st_le;
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;
 
-	struct timer_list    idle_timer;
+	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	int		     msi;
 	wait_queue_head_t    msi_wait;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

