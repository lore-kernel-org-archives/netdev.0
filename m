From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V2 1/4] pci: Add pci_wait_for_pending_transaction to wait for pending pci transaction
Date: Tue,  6 Aug 2013 15:48:36 +0530
Message-ID: <1375784319-25760-2-git-send-email-vipul@chelsio.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Cc: bhelgaas@google.com, leedom@chelsio.com, tomreu@chelsio.com,
	vipul@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com, netdev@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15340 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755674Ab3HFKZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 06:25:43 -0400
In-Reply-To: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>

New routine to avoid duplication of waiting for pending pci transaction code.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
V2: Added pci_wait_for_pending_transaction routine and replaced it at respective
places. Made the patch series for the same.
V2: Used dev->msix_cap directly for capability offset
V2: Removed use of 'rc' variable.

 drivers/pci/pci.c   | 38 +++++++++++++++++++++++++-------------
 include/linux/pci.h |  1 +
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index a8d5fd0..7d6ce2e 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -3159,19 +3159,17 @@ int pci_set_dma_seg_boundary(struct pci_dev *dev, unsigned long mask)
 }
 EXPORT_SYMBOL(pci_set_dma_seg_boundary);
 
-static int pcie_flr(struct pci_dev *dev, int probe)
+/**
+ * pci_wait_for_pending_transaction - waits for pending transaction
+ * @dev: the PCI device to operate on
+ *
+ * Return 0 if transaction is pending 1 otherwise.
+ */
+int pci_wait_for_pending_transaction(struct pci_dev *dev)
 {
 	int i;
-	u32 cap;
 	u16 status;
 
-	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
-	if (!(cap & PCI_EXP_DEVCAP_FLR))
-		return -ENOTTY;
-
-	if (probe)
-		return 0;
-
 	/* Wait for Transaction Pending bit clean */
 	for (i = 0; i < 4; i++) {
 		if (i)
@@ -3179,13 +3177,27 @@ static int pcie_flr(struct pci_dev *dev, int probe)
 
 		pcie_capability_read_word(dev, PCI_EXP_DEVSTA, &status);
 		if (!(status & PCI_EXP_DEVSTA_TRPND))
-			goto clear;
+			return 1;
 	}
 
-	dev_err(&dev->dev, "transaction is not cleared; "
-			"proceeding with reset anyway\n");
+	return 0;
+}
+EXPORT_SYMBOL(pci_wait_for_pending_transaction);
+
+static int pcie_flr(struct pci_dev *dev, int probe)
+{
+	u32 cap;
+
+	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
+	if (!(cap & PCI_EXP_DEVCAP_FLR))
+		return -ENOTTY;
+
+	if (probe)
+		return 0;
+
+	if (!pci_wait_for_pending_transaction(dev))
+		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
 
-clear:
 	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
 
 	msleep(100);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 0fd1f15..e647001 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -914,6 +914,7 @@ bool pci_check_and_unmask_intx(struct pci_dev *dev);
 void pci_msi_off(struct pci_dev *dev);
 int pci_set_dma_max_seg_size(struct pci_dev *dev, unsigned int size);
 int pci_set_dma_seg_boundary(struct pci_dev *dev, unsigned long mask);
+int pci_wait_for_pending_transaction(struct pci_dev *dev);
 int pcix_get_max_mmrbc(struct pci_dev *dev);
 int pcix_get_mmrbc(struct pci_dev *dev);
 int pcix_set_mmrbc(struct pci_dev *dev, int mmrbc);
-- 
1.8.0
