From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 5/9] sky2: edge triggered workaround enhancement
Date: Mon, 08 May 2006 15:11:30 -0700
Message-ID: <20060508221228.989827000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13245 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751325AbWEHWXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:54 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003753
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:50 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmpQ023558
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-timer-tweak.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Need to make the edge-triggered workaround timer faster to get marginally
better peformance. The test_and_set_bit in schedule_prep() acts as a barrier
already. Make it a module parameter so that laptops who are concerned
about power can set it to 0; and user's stuck with broken BIOS's
can turn the driver into pure polling.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-05-02 09:49:37.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-02 09:49:38.000000000 -0700
@@ -98,6 +98,10 @@
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
+static int idle_timeout = 100;
+module_param(idle_timeout, int, 0);
+MODULE_PARM_DESC(idle_timeout, "Idle timeout workaround for lost interrupts (ms)");
+
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
@@ -2092,12 +2096,13 @@
  */
 static void sky2_idle(unsigned long arg)
 {
-	struct net_device *dev = (struct net_device *) arg;
+	struct sky2_hw *hw = (struct sky2_hw *) arg;
+	struct net_device *dev = hw->dev[0];
 
-	local_irq_disable();
 	if (__netif_rx_schedule_prep(dev))
 		__netif_rx_schedule(dev);
-	local_irq_enable();
+
+	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
 }
 
 
@@ -2145,8 +2150,6 @@
 	if (work_done >= work_limit)
 		return 1;
 
-	mod_timer(&hw->idle_timer, jiffies + HZ);
-
 	netif_rx_complete(dev0);
 
 	status = sky2_read32(hw, B0_Y2_SP_LISR);
@@ -2167,8 +2170,6 @@
 	prefetch(&hw->st_le[hw->st_idx]);
 	if (likely(__netif_rx_schedule_prep(dev0)))
 		__netif_rx_schedule(dev0);
-	else
-		printk(KERN_DEBUG PFX "irq race detected\n");
 
 	return IRQ_HANDLED;
 }
@@ -3290,7 +3291,10 @@
 
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) dev);
+	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	if (idle_timeout > 0)
+		mod_timer(&hw->idle_timer,
+			  jiffies + msecs_to_jiffies(idle_timeout));
 
 	pci_set_drvdata(pdev, hw);
 

--

