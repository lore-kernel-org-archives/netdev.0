From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/23] e100: rework WoL and shutdown handling
Date: Tue, 19 Sep 2006 10:28:40 -0700
Message-ID: <20060919172840.4605.33452.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:13325 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030338AbWISRTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:45 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Unify our shutdown/suspend/resume code and make it similar to e1000:
e1000_shutdown now calls suspend which does the exact same thing on
shutdown except saving PCI config state on suspend. WoL setup code
is now also more simple and works even when CONFIG_PM is not set, which
was previously broken.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |   51 ++++++++++++++++++++-------------------------------
 1 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index ae93c62..94ca60b 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2717,68 +2717,56 @@ static void __devexit e100_remove(struct
 	}
 }
 
-#ifdef CONFIG_PM
 static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
-	int retval;
 
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		e100_down(nic);
 	e100_hw_reset(nic);
 	netif_device_detach(netdev);
 
+#ifdef CONFIG_PM
 	pci_save_state(pdev);
-	retval = pci_enable_wake(pdev, pci_choose_state(pdev, state),
-	                         nic->flags & (wol_magic | e100_asf(nic)));
-	if (retval)
-		DPRINTK(PROBE,ERR, "Error enabling wake\n");
+	if (nic->flags & (wol_magic | e100_asf(nic)))
+#else
+	if (nic->flags & (wol_magic))
+#endif
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
+	else
+		/* disable PME */
+		pci_enable_wake(pdev, 0, 0);
+
 	pci_disable_device(pdev);
-	retval = pci_set_power_state(pdev, pci_choose_state(pdev, state));
-	if (retval)
-		DPRINTK(PROBE,ERR, "Error %d setting power state\n", retval);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int e100_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
-	int retval;
 
-	retval = pci_set_power_state(pdev, PCI_D0);
-	if (retval)
-		DPRINTK(PROBE,ERR, "Error waking adapter\n");
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	/* ack any pending wake events, disable PME */
-	retval = pci_enable_wake(pdev, 0, 0);
-	if (retval)
-		DPRINTK(PROBE,ERR, "Error clearing wake events\n");
+	pci_enable_wake(pdev, 0, 0);
 
 	netif_device_attach(netdev);
-	if(netif_running(netdev))
+	if (netif_running(netdev))
 		e100_up(nic);
 
 	return 0;
 }
-#endif
+#endif /* CONFIG_PM */
 
 
 static void e100_shutdown(struct pci_dev *pdev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct nic *nic = netdev_priv(netdev);
-	int retval;
-
-#ifdef CONFIG_PM
-	retval = pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
-#else
-	retval = pci_enable_wake(pdev, 0, nic->flags & (wol_magic));
-#endif
-	if (retval)
-		DPRINTK(PROBE,ERR, "Error enabling wake\n");
+	e100_suspend(pdev, PMSG_SUSPEND);
 }
 
 /* ------------------ PCI Error Recovery infrastructure  -------------- */
@@ -2862,8 +2850,9 @@ static struct pci_driver e100_driver = {
 	.id_table =     e100_id_table,
 	.probe =        e100_probe,
 	.remove =       __devexit_p(e100_remove),
-#ifdef CONFIG_PM
+	/* Power Management hooks */
 	.suspend =      e100_suspend,
+#ifdef CONFIG_PM
 	.resume =       e100_resume,
 #endif
 	.shutdown =     e100_shutdown,



---
Auke Kok <auke-jan.h.kok@intel.com>
