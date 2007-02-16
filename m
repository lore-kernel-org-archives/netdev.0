From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: transmit timeout
Date: Thu, 15 Feb 2007 16:40:33 -0800
Message-ID: <20070216004142.176408000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40591 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422938AbXBPAn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:29 -0500
Content-Disposition: inline; filename=sky2-timeout3.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The transmit timeout code could hang, and it would not clear out
problems if the hardware was stuck.  Change the code to effectively do
a device down/up similar to the suspend/resume code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-15 11:44:39.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-15 12:47:05.000000000 -0800
@@ -1866,16 +1866,13 @@
 	spin_unlock(&sky2->phy_lock);
 }
 
-
 /* Transmit timeout is only called if we are running, carrier is up
  * and tx queue is full (stopped).
- * Called with netif_tx_lock held.
  */
 static void sky2_tx_timeout(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
-	u32 imask;
 
 	if (netif_msg_timer(sky2))
 		printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);
@@ -1885,19 +1882,8 @@
 	       sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
 	       sky2_read16(hw, Q_ADDR(txqaddr[sky2->port], Q_DONE)));
 
-	imask = sky2_read32(hw, B0_IMSK);	/* block IRQ in hw */
-	sky2_write32(hw, B0_IMSK, 0);
-	sky2_read32(hw, B0_IMSK);
-
-	netif_poll_disable(hw->dev[0]);		/* stop NAPI poll */
-	synchronize_irq(hw->pdev->irq);
-
-	netif_start_queue(dev);			/* don't wakeup during flush */
-	sky2_tx_complete(sky2, sky2->tx_prod);	/* Flush transmit queue */
-
-	sky2_write32(hw, B0_IMSK, imask);
-
-	sky2_phy_reinit(sky2);			/* this clears flow control etc */
+	/* can't restart safely under softirq */
+	schedule_work(&hw->restart_work);
 }
 
 static int sky2_change_mtu(struct net_device *dev, int new_mtu)
@@ -2651,6 +2637,49 @@
 	sky2_write8(hw, STAT_ISR_TIMER_CTRL, TIM_START);
 }
 
+static void sky2_restart(struct work_struct *work)
+{
+	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
+	struct net_device *dev;
+	int i, err;
+
+	dev_dbg(&hw->pdev->dev, "restarting\n");
+
+	del_timer_sync(&hw->idle_timer);
+
+	rtnl_lock();
+	sky2_write32(hw, B0_IMSK, 0);
+	sky2_read32(hw, B0_IMSK);
+
+	netif_poll_disable(hw->dev[0]);
+
+	for (i = 0; i < hw->ports; i++) {
+		dev = hw->dev[i];
+		if (netif_running(dev))
+			sky2_down(dev);
+	}
+
+	sky2_reset(hw);
+	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
+	netif_poll_enable(hw->dev[0]);
+
+	for (i = 0; i < hw->ports; i++) {
+		dev = hw->dev[i];
+		if (netif_running(dev)) {
+			err = sky2_up(dev);
+			if (err) {
+				printk(KERN_INFO PFX "%s: could not restart %d\n",
+				       dev->name, err);
+				dev_close(dev);
+			}
+		}
+	}
+
+	sky2_idle_start(hw);
+
+	rtnl_unlock();
+}
+
 static inline u8 sky2_wol_supported(const struct sky2_hw *hw)
 {
 	return sky2_is_copper(hw) ? (WAKE_PHY | WAKE_MAGIC) : 0;
@@ -3613,6 +3642,8 @@
 	}
 
 	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	INIT_WORK(&hw->restart_work, sky2_restart);
+
 	sky2_idle_start(hw);
 
 	pci_set_drvdata(pdev, hw);
@@ -3649,6 +3680,8 @@
 
 	del_timer_sync(&hw->idle_timer);
 
+	flush_scheduled_work();
+
 	sky2_write32(hw, B0_IMSK, 0);
 	synchronize_irq(hw->pdev->irq);
 
--- sky2-dev.orig/drivers/net/sky2.h	2007-02-15 11:58:51.000000000 -0800
+++ sky2-dev/drivers/net/sky2.h	2007-02-15 11:59:07.000000000 -0800
@@ -1933,6 +1933,7 @@
 	dma_addr_t   	     st_dma;
 
 	struct timer_list    idle_timer;
+	struct work_struct   restart_work;
 	int		     msi;
 	wait_queue_head_t    msi_wait;
 };

--
Stephen Hemminger <shemminger@linux-foundation.org>

