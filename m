From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] net: ethernet: aquantia: switch to pci_alloc_irq_vectors
Date: Wed, 15 Feb 2017 08:38:47 +0100
Message-ID: <20170215073847.1030-1-hch@lst.de>
Cc: netdev@vger.kernel.org
To: vomlehn@texas.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:33865 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdBOHix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 02:38:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_enable_msix has been long deprecated, but this driver adds a new
instance.  Convert it to pci_alloc_irq_vectors so that no new instance
of the deprecated function reaches mainline.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 .../net/ethernet/aquantia/atlantic/aq_pci_func.c   | 101 +++++----------------
 1 file changed, 25 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
index da4bc09dac51..581de71a958a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c
@@ -22,13 +22,11 @@ struct aq_pci_func_s {
 	void *aq_vec[AQ_CFG_PCI_FUNC_MSIX_IRQS];
 	resource_size_t mmio_pa;
 	unsigned int msix_entry_mask;
-	unsigned int irq_type;
 	unsigned int ports;
 	bool is_pci_enabled;
 	bool is_regions;
 	bool is_pci_using_dac;
 	struct aq_hw_caps_s aq_hw_caps;
-	struct msix_entry msix_entry[AQ_CFG_PCI_FUNC_MSIX_IRQS];
 };
 
 struct aq_pci_func_s *aq_pci_func_alloc(struct aq_hw_ops *aq_hw_ops,
@@ -87,7 +85,6 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 	int err = 0;
 	unsigned int bar = 0U;
 	unsigned int port = 0U;
-	unsigned int i = 0U;
 
 	err = pci_enable_device(self->pdev);
 	if (err < 0)
@@ -145,27 +142,16 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 		}
 	}
 
-	for (i = 0; i < self->aq_hw_caps.msix_irqs; i++)
-		self->msix_entry[i].entry = i;
-
 	/*enable interrupts */
-#if AQ_CFG_FORCE_LEGACY_INT
-	self->irq_type = AQ_HW_IRQ_LEGACY;
-#else
-	err = pci_enable_msix(self->pdev, self->msix_entry,
-			      self->aq_hw_caps.msix_irqs);
+#if !AQ_CFG_FORCE_LEGACY_INT
+	err = pci_alloc_irq_vectors(self->pdev, self->aq_hw_caps.msix_irqs,
+			      self->aq_hw_caps.msix_irqs, PCI_IRQ_MSIX);
 
-	if (err >= 0) {
-		self->irq_type = AQ_HW_IRQ_MSIX;
-	} else {
-		err = pci_enable_msi(self->pdev);
-
-		if (err >= 0) {
-			self->irq_type = AQ_HW_IRQ_MSI;
-		} else {
-			self->irq_type = AQ_HW_IRQ_LEGACY;
-			err = 0;
-		}
+	if (err < 0) {
+		err = pci_alloc_irq_vectors(self->pdev, 1, 1,
+				PCI_IRQ_MSI | PCI_IRQ_LEGACY);
+		if (err < 0)
+			goto err_exit;
 	}
 #endif
 
@@ -196,34 +182,22 @@ int aq_pci_func_init(struct aq_pci_func_s *self)
 int aq_pci_func_alloc_irq(struct aq_pci_func_s *self, unsigned int i,
 			  char *name, void *aq_vec, cpumask_t *affinity_mask)
 {
+	struct pci_dev *pdev = self->pdev;
 	int err = 0;
 
-	switch (self->irq_type) {
-	case AQ_HW_IRQ_MSIX:
-		err = request_irq(self->msix_entry[i].vector, aq_vec_isr, 0,
+	if (pdev->msix_enabled || pdev->msi_enabled)
+		err = request_irq(pci_irq_vector(pdev, i), aq_vec_isr, 0,
 				  name, aq_vec);
-		break;
-
-	case AQ_HW_IRQ_MSI:
-		err = request_irq(self->pdev->irq, aq_vec_isr, 0, name, aq_vec);
-		break;
-
-	case AQ_HW_IRQ_LEGACY:
-		err = request_irq(self->pdev->irq, aq_vec_isr_legacy,
+	else
+		err = request_irq(pci_irq_vector(pdev, i), aq_vec_isr_legacy,
 				  IRQF_SHARED, name, aq_vec);
-		break;
-
-	default:
-		err = -EFAULT;
-		break;
-	}
 
 	if (err >= 0) {
 		self->msix_entry_mask |= (1 << i);
 		self->aq_vec[i] = aq_vec;
 
-		if (self->irq_type == AQ_HW_IRQ_MSIX)
-			irq_set_affinity_hint(self->msix_entry[i].vector,
+		if (pdev->msix_enabled)
+			irq_set_affinity_hint(pci_irq_vector(pdev, i),
 					      affinity_mask);
 	}
 
@@ -232,30 +206,16 @@ int aq_pci_func_alloc_irq(struct aq_pci_func_s *self, unsigned int i,
 
 void aq_pci_func_free_irqs(struct aq_pci_func_s *self)
 {
+	struct pci_dev *pdev = self->pdev;
 	unsigned int i = 0U;
 
 	for (i = 32U; i--;) {
 		if (!((1U << i) & self->msix_entry_mask))
 			continue;
 
-		switch (self->irq_type) {
-		case AQ_HW_IRQ_MSIX:
-			irq_set_affinity_hint(self->msix_entry[i].vector, NULL);
-			free_irq(self->msix_entry[i].vector, self->aq_vec[i]);
-			break;
-
-		case AQ_HW_IRQ_MSI:
-			free_irq(self->pdev->irq, self->aq_vec[i]);
-			break;
-
-		case AQ_HW_IRQ_LEGACY:
-			free_irq(self->pdev->irq, self->aq_vec[i]);
-			break;
-
-		default:
-			break;
-		}
-
+		free_irq(pci_irq_vector(pdev, i), self->aq_vec[i]);
+		if (pdev->msix_enabled)
+			irq_set_affinity_hint(pci_irq_vector(pdev, i), NULL);
 		self->msix_entry_mask &= ~(1U << i);
 	}
 }
@@ -267,7 +227,11 @@ void __iomem *aq_pci_func_get_mmio(struct aq_pci_func_s *self)
 
 unsigned int aq_pci_func_get_irq_type(struct aq_pci_func_s *self)
 {
-	return self->irq_type;
+	if (self->pdev->msix_enabled)
+		return AQ_HW_IRQ_MSIX;
+	if (self->pdev->msi_enabled)
+		return AQ_HW_IRQ_MSIX;
+	return AQ_HW_IRQ_LEGACY;
 }
 
 void aq_pci_func_deinit(struct aq_pci_func_s *self)
@@ -276,22 +240,7 @@ void aq_pci_func_deinit(struct aq_pci_func_s *self)
 		goto err_exit;
 
 	aq_pci_func_free_irqs(self);
-
-	switch (self->irq_type) {
-	case AQ_HW_IRQ_MSI:
-		pci_disable_msi(self->pdev);
-		break;
-
-	case AQ_HW_IRQ_MSIX:
-		pci_disable_msix(self->pdev);
-		break;
-
-	case AQ_HW_IRQ_LEGACY:
-		break;
-
-	default:
-		break;
-	}
+	pci_free_irq_vectors(self->pdev);
 
 	if (self->is_regions)
 		pci_release_regions(self->pdev);
-- 
2.11.0
