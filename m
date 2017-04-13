From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/7] PCI: export pcie_flr
Date: Thu, 13 Apr 2017 16:53:33 +0200
Message-ID: <20170413145339.20186-2-hch@lst.de>
References: <20170413145339.20186-1-hch@lst.de>
Cc: linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:48067 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754450AbdDMOxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 10:53:54 -0400
In-Reply-To: <20170413145339.20186-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we opencode the FLR sequence in lots of place, export a core
helper instead.  We split out the probing for FLR support as all the
non-core callers already know their hardware.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/pci.c   | 34 +++++++++++++++++++++++++---------
 include/linux/pci.h |  1 +
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 7904d02ffdb9..3256a63c5d08 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -3773,24 +3773,38 @@ static void pci_flr_wait(struct pci_dev *dev)
 			 (i - 1) * 100);
 }
 
-static int pcie_flr(struct pci_dev *dev, int probe)
+/**
+ * pcie_has_flr - check if a device supports function level resets
+ * @dev:	device to check
+ *
+ * Returns true if the device advertises support for PCIe function level
+ * resets.
+ */
+static bool pcie_has_flr(struct pci_dev *dev)
 {
 	u32 cap;
 
 	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
-	if (!(cap & PCI_EXP_DEVCAP_FLR))
-		return -ENOTTY;
-
-	if (probe)
-		return 0;
+	return cap & PCI_EXP_DEVCAP_FLR;
+}
 
+/**
+ * pcie_flr - initiate a PCIe function level reset
+ * @dev:	device to reset
+ *
+ * Initiate a function level reset on @dev.  The caller should ensure the
+ * device supports FLR before calling this function, e.g. by using the
+ * pcie_has_flr helper.
+ */
+void pcie_flr(struct pci_dev *dev)
+{
 	if (!pci_wait_for_pending_transaction(dev))
 		dev_err(&dev->dev, "timed out waiting for pending transaction; performing function level reset anyway\n");
 
 	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
 	pci_flr_wait(dev);
-	return 0;
 }
+EXPORT_SYMBOL_GPL(pcie_flr);
 
 static int pci_af_flr(struct pci_dev *dev, int probe)
 {
@@ -3971,9 +3985,11 @@ static int __pci_dev_reset(struct pci_dev *dev, int probe)
 	if (rc != -ENOTTY)
 		goto done;
 
-	rc = pcie_flr(dev, probe);
-	if (rc != -ENOTTY)
+	if (pcie_has_flr(dev)) {
+		pcie_flr(dev);
+		rc = 0;
 		goto done;
+	}
 
 	rc = pci_af_flr(dev, probe);
 	if (rc != -ENOTTY)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index eb3da1a04e6c..f35e51eddad0 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1052,6 +1052,7 @@ int pcie_get_mps(struct pci_dev *dev);
 int pcie_set_mps(struct pci_dev *dev, int mps);
 int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
 			  enum pcie_link_width *width);
+void pcie_flr(struct pci_dev *dev);
 int __pci_reset_function(struct pci_dev *dev);
 int __pci_reset_function_locked(struct pci_dev *dev);
 int pci_reset_function(struct pci_dev *dev);
-- 
2.11.0
