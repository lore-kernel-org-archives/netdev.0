From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] e1000: remove obsolete custom pci_save_state code
Date: Fri, 16 Feb 2007 14:39:28 -0800
Message-ID: <20070216223928.26963.47663.stgit@gitlost.site>
References: <20070216223913.26963.76602.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Garzik, Jeff" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1349 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946154AbXBPWZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 17:25:11 -0500
In-Reply-To: <20070216223913.26963.76602.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that 2.6.19 provides a proper implementation that saves MSI, PCI-E
config space, we can have the e1000 driver use those instead of it's
custom implementation.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   58 +---------------------------------------
 2 files changed, 2 insertions(+), 57 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 689f158..dd4b728 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -337,7 +337,6 @@ struct e1000_adapter {
 	struct e1000_rx_ring test_rx_ring;
 
 
-	uint32_t *config_space;
 	int msg_enable;
 #ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f293690..a710237 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -5071,58 +5071,6 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 	return 0;
 }
 
-#ifdef CONFIG_PM
-/* Save/restore 16 or 64 dwords of PCI config space depending on which
- * bus we're on (PCI(X) vs. PCI-E)
- */
-#define PCIE_CONFIG_SPACE_LEN 256
-#define PCI_CONFIG_SPACE_LEN 64
-static int
-e1000_pci_save_state(struct e1000_adapter *adapter)
-{
-	struct pci_dev *dev = adapter->pdev;
-	int size;
-	int i;
-
-	if (adapter->hw.mac_type >= e1000_82571)
-		size = PCIE_CONFIG_SPACE_LEN;
-	else
-		size = PCI_CONFIG_SPACE_LEN;
-
-	WARN_ON(adapter->config_space != NULL);
-
-	adapter->config_space = kmalloc(size, GFP_KERNEL);
-	if (!adapter->config_space) {
-		DPRINTK(PROBE, ERR, "unable to allocate %d bytes\n", size);
-		return -ENOMEM;
-	}
-	for (i = 0; i < (size / 4); i++)
-		pci_read_config_dword(dev, i * 4, &adapter->config_space[i]);
-	return 0;
-}
-
-static void
-e1000_pci_restore_state(struct e1000_adapter *adapter)
-{
-	struct pci_dev *dev = adapter->pdev;
-	int size;
-	int i;
-
-	if (adapter->config_space == NULL)
-		return;
-
-	if (adapter->hw.mac_type >= e1000_82571)
-		size = PCIE_CONFIG_SPACE_LEN;
-	else
-		size = PCI_CONFIG_SPACE_LEN;
-	for (i = 0; i < (size / 4); i++)
-		pci_write_config_dword(dev, i * 4, adapter->config_space[i]);
-	kfree(adapter->config_space);
-	adapter->config_space = NULL;
-	return;
-}
-#endif /* CONFIG_PM */
-
 static int
 e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 {
@@ -5142,9 +5090,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 #ifdef CONFIG_PM
-	/* Implement our own version of pci_save_state(pdev) because pci-
-	 * express adapters have 256-byte config spaces. */
-	retval = e1000_pci_save_state(adapter);
+	retval = pci_save_state(pdev);
 	if (retval)
 		return retval;
 #endif
@@ -5231,7 +5177,7 @@ e1000_resume(struct pci_dev *pdev)
 	uint32_t err;
 
 	pci_set_power_state(pdev, PCI_D0);
-	e1000_pci_restore_state(adapter);
+	pci_restore_state(pdev);
 	if ((err = pci_enable_device(pdev))) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;



---
Auke Kok <auke-jan.h.kok@intel.com>
