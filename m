From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] sky2: add fake idle irq timer
Date: Tue, 25 Apr 2006 10:58:51 -0700
Message-ID: <20060425175951.444629000@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31617 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932307AbWDYVCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:42 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-idle-timer.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an fake NAPI schedule once a second. This is an attempt to work around
for broken configurations with edge-triggered interrupts.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:48:47.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:53:32.000000000 -0700
@@ -2086,6 +2086,20 @@
 	}
 }
 
+/* If idle then force a fake soft NAPI poll once a second
+ * to work around cases where sharing an edge triggered interrupt.
+ */
+static void sky2_idle(unsigned long arg)
+{
+	struct net_device *dev = (struct net_device *) arg;
+
+	local_irq_disable();
+	if (__netif_rx_schedule_prep(dev))
+		__netif_rx_schedule(dev);
+	local_irq_enable();
+}
+
+
 static int sky2_poll(struct net_device *dev0, int *budget)
 {
 	struct sky2_hw *hw = ((struct sky2_port *) netdev_priv(dev0))->hw;
@@ -2134,6 +2148,8 @@
 		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 	}
 
+	mod_timer(&hw->idle_timer, jiffies + HZ);
+
 	local_irq_disable();
 	__netif_rx_complete(dev0);
 
@@ -3288,6 +3304,8 @@
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
+	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) dev);
+
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
@@ -3323,13 +3341,15 @@
 	if (!hw)
 		return;
 
+	del_timer_sync(&hw->idle_timer);
+
+	sky2_write32(hw, B0_IMSK, 0);
 	dev0 = hw->dev[0];
 	dev1 = hw->dev[1];
 	if (dev1)
 		unregister_netdev(dev1);
 	unregister_netdev(dev0);
 
-	sky2_write32(hw, B0_IMSK, 0);
 	sky2_set_power_state(hw, PCI_D3hot);
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
--- sky2-2.6.17.orig/drivers/net/sky2.h	2006-04-25 10:48:42.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.h	2006-04-25 10:51:33.000000000 -0700
@@ -1880,6 +1880,8 @@
 	struct sky2_status_le *st_le;
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;
+
+	struct timer_list    idle_timer;
 	int		     msi_detected;
 	wait_queue_head_t    msi_wait;
 };

--

