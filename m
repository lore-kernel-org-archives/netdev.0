From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] sky2: reduce impact of watchdog timer
Date: Fri, 28 Sep 2007 09:48:12 -0700
Message-ID: <20070928164858.474820246@linux-foundation.org>
References: <20070928164811.387831540@linux-foundation.org>
Cc: stable@kernel.org, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44639 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751201AbXI1QwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:52:07 -0400
Content-Disposition: inline; filename=sky2-hw-watchdog.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the 2.6.22 version of a regression fix that is already
in 2.6.23.  Change the watchdog timer form 10 per second all the time,
to 1 per second and only if interface is up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-09-17 10:39:47.000000000 -0700
+++ b/drivers/net/sky2.c	2007-09-28 09:13:38.000000000 -0700
@@ -96,10 +96,6 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 100;
-module_param(idle_timeout, int, 0);
-MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
-
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
@@ -1693,6 +1689,8 @@ static void sky2_link_up(struct sky2_por
 
 	netif_carrier_on(sky2->netdev);
 
+	mod_timer(&hw->watchdog_timer, jiffies + 1);
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
@@ -2384,25 +2382,25 @@ static void sky2_le_error(struct sky2_hw
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
+/* Force a fake soft NAPI poll to handle lost IRQ's */
+static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
 	struct net_device *dev = hw->dev[0];
+	int i, active = 0;
 
 	if (__netif_rx_schedule_prep(dev))
 		__netif_rx_schedule(dev);
 
-	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
+	for (i = 0; i < hw->ports; i++) {
+		dev = hw->dev[i];
+		if (!netif_running(dev))
+			continue;
+		++active;
+	}
+
+	if (active)
+		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
@@ -2692,8 +2690,6 @@ static void sky2_restart(struct work_str
 
 	dev_dbg(&hw->pdev->dev, "restarting\n");
 
-	del_timer_sync(&hw->idle_timer);
-
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
@@ -2722,8 +2718,6 @@ static void sky2_restart(struct work_str
 		}
 	}
 
-	sky2_idle_start(hw);
-
 	rtnl_unlock();
 }
 
@@ -3713,11 +3707,9 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
-	sky2_idle_start(hw);
-
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
@@ -3752,7 +3744,7 @@ static void __devexit sky2_remove(struct
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 
 	flush_scheduled_work();
 
@@ -3796,7 +3788,7 @@ static int sky2_suspend(struct pci_dev *
 	if (!hw)
 		return 0;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -3862,7 +3854,7 @@ static int sky2_resume(struct pci_dev *p
 	}
 
 	netif_poll_enable(hw->dev[0]);
-	sky2_idle_start(hw);
+
 	return 0;
 out:
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
@@ -3879,7 +3871,6 @@ static void sky2_shutdown(struct pci_dev
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
--- a/drivers/net/sky2.h	2007-08-21 10:59:11.000000000 -0700
+++ b/drivers/net/sky2.h	2007-09-28 09:13:15.000000000 -0700
@@ -1921,7 +1921,7 @@ struct sky2_hw {
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;
 
-	struct timer_list    idle_timer;
+	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	int		     msi;
 	wait_queue_head_t    msi_wait;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

