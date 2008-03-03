From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/4] e100: Do suspend/shutdown like e1000
Date: Mon, 03 Mar 2008 14:37:31 -0800
Message-ID: <20080303223731.16344.94975.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30893 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179AbYCCWma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:42:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a "trying to free already free IRQ" message and simplifies
the shutdown/suspend code by re-using already existing code when going
to suspend. The code is now symmetric with e100_resume.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   29 +++--------------------------
 1 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 36ba6dc..cdf3090 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2782,16 +2782,13 @@ static void __devexit e100_remove(struct pci_dev *pdev)
 	}
 }
 
-#ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
 	if (netif_running(netdev))
-		napi_disable(&nic->napi);
-	del_timer_sync(&nic->watchdog);
-	netif_carrier_off(nic->netdev);
+		e100_down(nic);
 	netif_device_detach(netdev);
 
 	pci_save_state(pdev);
@@ -2804,14 +2801,13 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	free_irq(pdev->irq, netdev);
-
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2832,26 +2828,7 @@ static int e100_resume(struct pci_dev *pdev)
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct nic *nic = netdev_priv(netdev);
-
-	if (netif_running(netdev))
-		napi_disable(&nic->napi);
-	del_timer_sync(&nic->watchdog);
-	netif_carrier_off(nic->netdev);
-
-	if ((nic->flags & wol_magic) | e100_asf(nic)) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
-	}
-
-	free_irq(pdev->irq, netdev);
-
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	e100_suspend(pdev, PMSG_SUSPEND);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */

