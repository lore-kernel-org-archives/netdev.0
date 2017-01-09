From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/3] PCI/msi: remove pci_enable_msi_{exact,range}
Date: Mon,  9 Jan 2017 21:37:40 +0100
Message-ID: <1483994260-19797-4-git-send-email-hch@lst.de>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1483994260-19797-1-git-send-email-hch@lst.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All multi-MSI allocations are now done through pci_irq_alloc_vectors,
so remove the old interface.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/PCI/MSI-HOWTO.txt |  6 ++----
 drivers/pci/msi.c               | 26 +++++++++-----------------
 include/linux/pci.h             | 16 ++--------------
 3 files changed, 13 insertions(+), 35 deletions(-)

diff --git a/Documentation/PCI/MSI-HOWTO.txt b/Documentation/PCI/MSI-HOWTO.txt
index cd9c9f6..b570a92 100644
--- a/Documentation/PCI/MSI-HOWTO.txt
+++ b/Documentation/PCI/MSI-HOWTO.txt
@@ -162,8 +162,6 @@ The following old APIs to enable and disable MSI or MSI-X interrupts should
 not be used in new code:
 
   pci_enable_msi()		/* deprecated */
-  pci_enable_msi_range()	/* deprecated */
-  pci_enable_msi_exact()	/* deprecated */
   pci_disable_msi()		/* deprecated */
   pci_enable_msix_range()	/* deprecated */
   pci_enable_msix_exact()	/* deprecated */
@@ -268,5 +266,5 @@ or disabled (0).  If 0 is found in any of the msi_bus files belonging
 to bridges between the PCI root and the device, MSIs are disabled.
 
 It is also worth checking the device driver to see whether it supports MSIs.
-For example, it may contain calls to pci_enable_msi_range() or
-pci_enable_msix_range().
+For example, it may contain calls to pci_irq_alloc_vectors with the
+PCI_IRQ_MSI or PCI_IRQ_MSIX flags.
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 50c5003..16dda43 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -1109,23 +1109,15 @@ static int __pci_enable_msi_range(struct pci_dev *dev, int minvec, int maxvec,
 	}
 }
 
-/**
- * pci_enable_msi_range - configure device's MSI capability structure
- * @dev: device to configure
- * @minvec: minimal number of interrupts to configure
- * @maxvec: maximum number of interrupts to configure
- *
- * This function tries to allocate a maximum possible number of interrupts in a
- * range between @minvec and @maxvec. It returns a negative errno if an error
- * occurs. If it succeeds, it returns the actual number of interrupts allocated
- * and updates the @dev's irq member to the lowest new interrupt number;
- * the other interrupt numbers allocated to this device are consecutive.
- **/
-int pci_enable_msi_range(struct pci_dev *dev, int minvec, int maxvec)
+/* deprecated, don't use */
+int pci_enable_msi(struct pci_dev *dev)
 {
-	return __pci_enable_msi_range(dev, minvec, maxvec, NULL);
+	int rc = __pci_enable_msi_range(dev, 1, 1, NULL);
+	if (rc < 0)
+		return rc;
+	return 0;
 }
-EXPORT_SYMBOL(pci_enable_msi_range);
+EXPORT_SYMBOL(pci_enable_msi);
 
 static int __pci_enable_msix_range(struct pci_dev *dev,
 				   struct msix_entry *entries, int minvec,
@@ -1381,7 +1373,7 @@ int pci_msi_domain_check_cap(struct irq_domain *domain,
 {
 	struct msi_desc *desc = first_pci_msi_entry(to_pci_dev(dev));
 
-	/* Special handling to support pci_enable_msi_range() */
+	/* Special handling to support __pci_enable_msi_range() */
 	if (pci_msi_desc_is_multi_msi(desc) &&
 	    !(info->flags & MSI_FLAG_MULTI_PCI_MSI))
 		return 1;
@@ -1394,7 +1386,7 @@ int pci_msi_domain_check_cap(struct irq_domain *domain,
 static int pci_msi_domain_handle_error(struct irq_domain *domain,
 				       struct msi_desc *desc, int error)
 {
-	/* Special handling to support pci_enable_msi_range() */
+	/* Special handling to support __pci_enable_msi_range() */
 	if (pci_msi_desc_is_multi_msi(desc) && error == -ENOSPC)
 		return 1;
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e2d1a12..2159376 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1309,14 +1309,7 @@ void pci_msix_shutdown(struct pci_dev *dev);
 void pci_disable_msix(struct pci_dev *dev);
 void pci_restore_msi_state(struct pci_dev *dev);
 int pci_msi_enabled(void);
-int pci_enable_msi_range(struct pci_dev *dev, int minvec, int maxvec);
-static inline int pci_enable_msi_exact(struct pci_dev *dev, int nvec)
-{
-	int rc = pci_enable_msi_range(dev, nvec, nvec);
-	if (rc < 0)
-		return rc;
-	return 0;
-}
+int pci_enable_msi(struct pci_dev *dev);
 int pci_enable_msix_range(struct pci_dev *dev, struct msix_entry *entries,
 			  int minvec, int maxvec);
 static inline int pci_enable_msix_exact(struct pci_dev *dev,
@@ -1347,10 +1340,7 @@ static inline void pci_msix_shutdown(struct pci_dev *dev) { }
 static inline void pci_disable_msix(struct pci_dev *dev) { }
 static inline void pci_restore_msi_state(struct pci_dev *dev) { }
 static inline int pci_msi_enabled(void) { return 0; }
-static inline int pci_enable_msi_range(struct pci_dev *dev, int minvec,
-				       int maxvec)
-{ return -ENOSYS; }
-static inline int pci_enable_msi_exact(struct pci_dev *dev, int nvec)
+static inline int pci_enable_msi(struct pci_dev *dev)
 { return -ENOSYS; }
 static inline int pci_enable_msix_range(struct pci_dev *dev,
 		      struct msix_entry *entries, int minvec, int maxvec)
@@ -1426,8 +1416,6 @@ static inline void pcie_set_ecrc_checking(struct pci_dev *dev) { }
 static inline void pcie_ecrc_get_policy(char *str) { }
 #endif
 
-#define pci_enable_msi(pdev)	pci_enable_msi_exact(pdev, 1)
-
 #ifdef CONFIG_HT_IRQ
 /* The functions a driver should call */
 int  ht_create_irq(struct pci_dev *dev, int idx);
-- 
2.1.4
