From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] sky2: hold RTNL when doing suspend/shutdown operations
Date: Fri, 14 Aug 2009 08:15:16 -0700
Message-ID: <20090814151608.280231213@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44115 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932511AbZHNPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:19:51 -0400
Content-Disposition: inline; filename=sky2-wol-rtnl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The suspend and shutdown code plays with shared state. Use consistent
locking, for extra protection. 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-14 07:58:46.664005121 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:47.421479764 -0700
@@ -4631,6 +4631,7 @@ static int sky2_suspend(struct pci_dev *
 	del_timer_sync(&hw->watchdog_timer);
 	cancel_work_sync(&hw->restart_work);
 
+	rtnl_lock();
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct sky2_port *sky2 = netdev_priv(dev);
@@ -4648,6 +4649,7 @@ static int sky2_suspend(struct pci_dev *
 	sky2_write32(hw, B0_IMSK, 0);
 	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
+	rtnl_unlock();
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
@@ -4717,6 +4719,7 @@ static void sky2_shutdown(struct pci_dev
 	if (!hw)
 		return;
 
+	rtnl_lock();
 	del_timer_sync(&hw->watchdog_timer);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -4731,6 +4734,7 @@ static void sky2_shutdown(struct pci_dev
 
 	if (wol)
 		sky2_power_aux(hw);
+	rtnl_unlock();
 
 	pci_enable_wake(pdev, PCI_D3hot, wol);
 	pci_enable_wake(pdev, PCI_D3cold, wol);

-- 

