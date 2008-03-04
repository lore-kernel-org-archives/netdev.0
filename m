From: akpm@linux-foundation.org
Subject: [patch (for 2.6.25?) 1/3] e100: do suspend/shutdown like e1000
Date: Tue, 04 Mar 2008 14:58:40 -0800
Message-ID: <200803042258.m24MwfoZ001397@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	auke-jan.h.kok@intel.com, arvidjaar@mail.ru
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49349 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762722AbYCDW7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:59:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kok, Auke" <auke-jan.h.kok@intel.com>

This fixes a "trying to free already free IRQ" message and simplifies the
shutdown/suspend code by re-using already existing code when going to
suspend.  The code is now symmetric with e100_resume.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Tested-by: Andrey Borzenkov <arvidjaar@mail.ru>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e100.c |   29 +++--------------------------
 1 file changed, 3 insertions(+), 26 deletions(-)

diff -puN drivers/net/e100.c~e100-do-suspend-shutdown-like-e1000 drivers/net/e100.c
--- a/drivers/net/e100.c~e100-do-suspend-shutdown-like-e1000
+++ a/drivers/net/e100.c
@@ -2782,16 +2782,13 @@ static void __devexit e100_remove(struct
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
@@ -2804,14 +2801,13 @@ static int e100_suspend(struct pci_dev *
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
@@ -2832,26 +2828,7 @@ static int e100_resume(struct pci_dev *p
 
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
_
