From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] e100: FIX: fix netconsole fast reboot attached to e100
Date: Tue, 17 Oct 2006 12:02:50 -0700
Message-ID: <20061017190250.4194.70575.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:20238 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751443AbWJQSyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:54:54 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When rebooting with netconsole over e100, the driver shutdown code
would deadlock with netpoll. Reduce shutdown code to a bare minimum
while retaining WoL functionality.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e100.c |   52 ++++++++++++++++++++++++++++++++--------------------
 1 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 27d5d2f..d4a2572 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.17-k2"DRV_EXT
+#define DRV_VERSION		"3.5.17-k4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -2039,7 +2039,6 @@ static int e100_change_mtu(struct net_de
 	return 0;
 }
 
-#ifdef CONFIG_PM
 static int e100_asf(struct nic *nic)
 {
 	/* ASF can be enabled from eeprom */
@@ -2048,7 +2047,6 @@ static int e100_asf(struct nic *nic)
 	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
 	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
 }
-#endif
 
 static int e100_up(struct nic *nic)
 {
@@ -2715,34 +2713,32 @@ static void __devexit e100_remove(struct
 	}
 }
 
+#ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	if (netif_running(netdev))
-		e100_down(nic);
-	e100_hw_reset(nic);
-	netif_device_detach(netdev);
+	netif_poll_disable(nic->netdev);
+	del_timer_sync(&nic->watchdog);
+	netif_carrier_off(nic->netdev);
 
-#ifdef CONFIG_PM
 	pci_save_state(pdev);
-	if (nic->flags & (wol_magic | e100_asf(nic)))
-#else
-	if (nic->flags & (wol_magic))
-#endif
-		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
-	else
-		/* disable PME */
-		pci_enable_wake(pdev, 0, 0);
+
+	if ((nic->flags & wol_magic) | e100_asf(nic)) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
 
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
-#ifdef CONFIG_PM
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2764,7 +2760,23 @@ static int e100_resume(struct pci_dev *p
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	e100_suspend(pdev, PMSG_SUSPEND);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nic *nic = netdev_priv(netdev);
+
+	netif_poll_disable(nic->netdev);
+	del_timer_sync(&nic->watchdog);
+	netif_carrier_off(nic->netdev);
+
+	if ((nic->flags & wol_magic) | e100_asf(nic)) {
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */
@@ -2848,9 +2860,9 @@ static struct pci_driver e100_driver = {
 	.id_table =     e100_id_table,
 	.probe =        e100_probe,
 	.remove =       __devexit_p(e100_remove),
+#ifdef CONFIG_PM
 	/* Power Management hooks */
 	.suspend =      e100_suspend,
-#ifdef CONFIG_PM
 	.resume =       e100_resume,
 #endif
 	.shutdown =     e100_shutdown,



---
Auke Kok <auke-jan.h.kok@intel.com>
