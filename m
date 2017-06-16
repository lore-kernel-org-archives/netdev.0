From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 28/44] sparc: remove arch specific dma_supported implementations
Date: Fri, 16 Jun 2017 20:10:43 +0200
Message-ID: <20170616181059.19206-29-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Usually dma_supported decisions are done by the dma_map_ops instance.
Switch sparc to that model by providing a ->dma_supported instance for
sbus that always returns false, and implementations tailored to the sun4u
and sun4v cases for sparc64, and leave it unimplemented for PCI on
sparc32, which means always supported.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/dma-mapping.h |  3 ---
 arch/sparc/kernel/iommu.c            | 40 +++++++++++++++---------------------
 arch/sparc/kernel/ioport.c           | 22 ++++++--------------
 arch/sparc/kernel/pci_sun4v.c        | 17 +++++++++++++++
 4 files changed, 39 insertions(+), 43 deletions(-)

diff --git a/arch/sparc/include/asm/dma-mapping.h b/arch/sparc/include/asm/dma-mapping.h
index 98da9f92c318..60bf1633d554 100644
--- a/arch/sparc/include/asm/dma-mapping.h
+++ b/arch/sparc/include/asm/dma-mapping.h
@@ -5,9 +5,6 @@
 #include <linux/mm.h>
 #include <linux/dma-debug.h>
 
-#define HAVE_ARCH_DMA_SUPPORTED 1
-int dma_supported(struct device *dev, u64 mask);
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 				  enum dma_data_direction dir)
 {
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index dafa316d978d..fcbcc031f615 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -746,6 +746,21 @@ static int dma_4u_mapping_error(struct device *dev, dma_addr_t dma_addr)
 	return dma_addr == SPARC_MAPPING_ERROR;
 }
 
+static int dma_4u_supported(struct device *dev, u64 device_mask)
+{
+	struct iommu *iommu = dev->archdata.iommu;
+
+	if (device_mask > DMA_BIT_MASK(32))
+		return 0;
+	if ((device_mask & iommu->dma_addr_mask) == iommu->dma_addr_mask)
+		return 1;
+#ifdef CONFIG_PCI
+	if (dev_is_pci(dev))
+		return pci64_dma_supported(to_pci_dev(dev), device_mask);
+#endif
+	return 0;
+}
+
 static const struct dma_map_ops sun4u_dma_ops = {
 	.alloc			= dma_4u_alloc_coherent,
 	.free			= dma_4u_free_coherent,
@@ -755,32 +770,9 @@ static const struct dma_map_ops sun4u_dma_ops = {
 	.unmap_sg		= dma_4u_unmap_sg,
 	.sync_single_for_cpu	= dma_4u_sync_single_for_cpu,
 	.sync_sg_for_cpu	= dma_4u_sync_sg_for_cpu,
+	.dma_supported		= dma_4u_supported,
 	.mapping_error		= dma_4u_mapping_error,
 };
 
 const struct dma_map_ops *dma_ops = &sun4u_dma_ops;
 EXPORT_SYMBOL(dma_ops);
-
-int dma_supported(struct device *dev, u64 device_mask)
-{
-	struct iommu *iommu = dev->archdata.iommu;
-	u64 dma_addr_mask = iommu->dma_addr_mask;
-
-	if (device_mask > DMA_BIT_MASK(32)) {
-		if (iommu->atu)
-			dma_addr_mask = iommu->atu->dma_addr_mask;
-		else
-			return 0;
-	}
-
-	if ((device_mask & dma_addr_mask) == dma_addr_mask)
-		return 1;
-
-#ifdef CONFIG_PCI
-	if (dev_is_pci(dev))
-		return pci64_dma_supported(to_pci_dev(dev), device_mask);
-#endif
-
-	return 0;
-}
-EXPORT_SYMBOL(dma_supported);
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index dd081d557609..12894f259bea 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -401,6 +401,11 @@ static void sbus_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 	BUG();
 }
 
+static int sbus_dma_supported(struct device *dev, u64 mask)
+{
+	return 0;
+}
+
 static const struct dma_map_ops sbus_dma_ops = {
 	.alloc			= sbus_alloc_coherent,
 	.free			= sbus_free_coherent,
@@ -410,6 +415,7 @@ static const struct dma_map_ops sbus_dma_ops = {
 	.unmap_sg		= sbus_unmap_sg,
 	.sync_sg_for_cpu	= sbus_sync_sg_for_cpu,
 	.sync_sg_for_device	= sbus_sync_sg_for_device,
+	.dma_supported		= sbus_dma_supported,
 };
 
 static int __init sparc_register_ioport(void)
@@ -655,22 +661,6 @@ EXPORT_SYMBOL(pci32_dma_ops);
 const struct dma_map_ops *dma_ops = &sbus_dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
-
-/*
- * Return whether the given PCI device DMA address mask can be
- * supported properly.  For example, if your device can only drive the
- * low 24-bits during PCI bus mastering, then you would pass
- * 0x00ffffff as the mask to this function.
- */
-int dma_supported(struct device *dev, u64 mask)
-{
-	if (dev_is_pci(dev))
-		return 1;
-
-	return 0;
-}
-EXPORT_SYMBOL(dma_supported);
-
 #ifdef CONFIG_PROC_FS
 
 static int sparc_io_proc_show(struct seq_file *m, void *v)
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 8e2a56f4c03a..24f21c726dfa 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -24,6 +24,7 @@
 
 #include "pci_impl.h"
 #include "iommu_common.h"
+#include "kernel.h"
 
 #include "pci_sun4v.h"
 
@@ -669,6 +670,21 @@ static void dma_4v_unmap_sg(struct device *dev, struct scatterlist *sglist,
 	local_irq_restore(flags);
 }
 
+static int dma_4v_supported(struct device *dev, u64 device_mask)
+{
+	struct iommu *iommu = dev->archdata.iommu;
+	u64 dma_addr_mask;
+
+	if (device_mask > DMA_BIT_MASK(32) && iommu->atu)
+		dma_addr_mask = iommu->atu->dma_addr_mask;
+	else
+		dma_addr_mask = iommu->dma_addr_mask;
+
+	if ((device_mask & dma_addr_mask) == dma_addr_mask)
+		return 1;
+	return pci64_dma_supported(to_pci_dev(dev), device_mask);
+}
+
 static int dma_4v_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	return dma_addr == SPARC_MAPPING_ERROR;
@@ -681,6 +697,7 @@ static const struct dma_map_ops sun4v_dma_ops = {
 	.unmap_page			= dma_4v_unmap_page,
 	.map_sg				= dma_4v_map_sg,
 	.unmap_sg			= dma_4v_unmap_sg,
+	.dma_supported			= dma_4v_supported,
 	.mapping_error			= dma_4v_mapping_error,
 };
 
-- 
2.11.0

