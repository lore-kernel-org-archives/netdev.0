From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: fix suspend/resume for down interface
Date: Mon, 2 Apr 2007 23:01:11 +0200
Message-ID: <20070402210111.GB23368@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaud Patard <apatard@mandriva.com>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35488 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965884AbXDBVEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 17:04:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PM hooks are no-op if the r8169 interface is down (i.e. !IFF_UP).
However, as the chipset is enabled, the device will not work after a
suspend/resume cycle. The patch always issue the required PCI suspend
sequence and removes the module unload/reload workaround.

Signed-off-by: Arnaud Patard <apatard@mandriva.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 60f630e..6a77b8a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2890,7 +2890,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (!netif_running(dev))
-		goto out;
+		goto out_pci_suspend;
 
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
@@ -2904,10 +2904,11 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	spin_unlock_irq(&tp->lock);
 
+out_pci_suspend:
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
+
 	return 0;
 }
 
@@ -2915,15 +2916,15 @@ static int rtl8169_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	pci_enable_wake(pdev, PCI_D0, 0);
+
 	if (!netif_running(dev))
 		goto out;
 
 	netif_device_attach(dev);
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
 out:
 	return 0;
-- 
1.5.0.5

