From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/7] PCI: export pcie_flr
Date: Fri, 14 Apr 2017 21:11:25 +0200
Message-ID: <20170414191131.14286-2-hch@lst.de>
References: <20170414191131.14286-1-hch@lst.de>
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170414191131.14286-1-hch@lst.de>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we opencode the FLR sequence in lots of place, export a core
helper instead.  We split out the probing for FLR support as all the
non-core callers already know their hardware.

Note that in the new pci_has_flr function the quirk check has been moved
before the capability check as there is no point in reading the
capability in this case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
---
 drivers/pci/pci.c   | 39 ++++++++++++++++++++++++++++-----------
 include/linux/pci.h |  1 +
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index bef14777bb30..957a11a6a840 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -3773,27 +3773,41 @@ static void pci_flr_wait(struct pci_dev *dev)
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
 
-	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
-	if (!(cap & PCI_EXP_DEVCAP_FLR))
-		return -ENOTTY;
-
 	if (dev->dev_flags & PCI_DEV_FLAGS_NO_FLR_RESET)
-		return -ENOTTY;
+		return false;
 
-	if (probe)
-		return 0;
+	pcie_capability_read_dword(dev, PCI_EXP_DEVCAP, &cap);
+	return cap & PCI_EXP_DEVCAP_FLR;
+}
 
+/**
+ * pcie_flr - initiate a PCIe function level reset
+ * @dev:	device to reset
+ *
+ * Initiate a function level reset on @dev.  The caller should ensure the
+ * device supports FLR before calling this function, e.g. by using the
+ * pcie_has_flr() helper.
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
@@ -3977,9 +3991,12 @@ static int __pci_dev_reset(struct pci_dev *dev, int probe)
 	if (rc != -ENOTTY)
 		goto done;
 
-	rc = pcie_flr(dev, probe);
-	if (rc != -ENOTTY)
+	if (pcie_has_flr(dev)) {
+		if (!probe)
+			pcie_flr(dev);
+		rc = 0;
 		goto done;
+	}
 
 	rc = pci_af_flr(dev, probe);
 	if (rc != -ENOTTY)
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 20e1865233a4..60162f51227a 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1054,6 +1054,7 @@ int pcie_get_mps(struct pci_dev *dev);
 int pcie_set_mps(struct pci_dev *dev, int mps);
 int pcie_get_minimum_link(struct pci_dev *dev, enum pci_bus_speed *speed,
 			  enum pcie_link_width *width);
+void pcie_flr(struct pci_dev *dev);
 int __pci_reset_function(struct pci_dev *dev);
 int __pci_reset_function_locked(struct pci_dev *dev);
 int pci_reset_function(struct pci_dev *dev);
-- 
2.11.0
