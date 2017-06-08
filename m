From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 23/44] x86/calgary: implement ->mapping_error
Date: Thu,  8 Jun 2017 15:25:48 +0200
Message-ID: <20170608132609.32662-24-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
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
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/kernel/pci-calgary_64.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/pci-calgary_64.c b/arch/x86/kernel/pci-calgary_64.c
index fda7867046d0..e75b490f2b0b 100644
--- a/arch/x86/kernel/pci-calgary_64.c
+++ b/arch/x86/kernel/pci-calgary_64.c
@@ -50,6 +50,8 @@
 #include <asm/x86_init.h>
 #include <asm/iommu_table.h>
 
+#define CALGARY_MAPPING_ERROR	0
+
 #ifdef CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT
 int use_calgary __read_mostly = 1;
 #else
@@ -252,7 +254,7 @@ static unsigned long iommu_range_alloc(struct device *dev,
 			if (panic_on_overflow)
 				panic("Calgary: fix the allocator.\n");
 			else
-				return DMA_ERROR_CODE;
+				return CALGARY_MAPPING_ERROR;
 		}
 	}
 
@@ -272,10 +274,10 @@ static dma_addr_t iommu_alloc(struct device *dev, struct iommu_table *tbl,
 
 	entry = iommu_range_alloc(dev, tbl, npages);
 
-	if (unlikely(entry == DMA_ERROR_CODE)) {
+	if (unlikely(entry == CALGARY_MAPPING_ERROR)) {
 		pr_warn("failed to allocate %u pages in iommu %p\n",
 			npages, tbl);
-		return DMA_ERROR_CODE;
+		return CALGARY_MAPPING_ERROR;
 	}
 
 	/* set the return dma address */
@@ -295,7 +297,7 @@ static void iommu_free(struct iommu_table *tbl, dma_addr_t dma_addr,
 	unsigned long flags;
 
 	/* were we called with bad_dma_address? */
-	badend = DMA_ERROR_CODE + (EMERGENCY_PAGES * PAGE_SIZE);
+	badend = CALGARY_MAPPING_ERROR + (EMERGENCY_PAGES * PAGE_SIZE);
 	if (unlikely(dma_addr < badend)) {
 		WARN(1, KERN_ERR "Calgary: driver tried unmapping bad DMA "
 		       "address 0x%Lx\n", dma_addr);
@@ -380,7 +382,7 @@ static int calgary_map_sg(struct device *dev, struct scatterlist *sg,
 		npages = iommu_num_pages(vaddr, s->length, PAGE_SIZE);
 
 		entry = iommu_range_alloc(dev, tbl, npages);
-		if (entry == DMA_ERROR_CODE) {
+		if (entry == CALGARY_MAPPING_ERROR) {
 			/* makes sure unmap knows to stop */
 			s->dma_length = 0;
 			goto error;
@@ -398,7 +400,7 @@ static int calgary_map_sg(struct device *dev, struct scatterlist *sg,
 error:
 	calgary_unmap_sg(dev, sg, nelems, dir, 0);
 	for_each_sg(sg, s, nelems, i) {
-		sg->dma_address = DMA_ERROR_CODE;
+		sg->dma_address = CALGARY_MAPPING_ERROR;
 		sg->dma_length = 0;
 	}
 	return 0;
@@ -453,7 +455,7 @@ static void* calgary_alloc_coherent(struct device *dev, size_t size,
 
 	/* set up tces to cover the allocated range */
 	mapping = iommu_alloc(dev, tbl, ret, npages, DMA_BIDIRECTIONAL);
-	if (mapping == DMA_ERROR_CODE)
+	if (mapping == CALGARY_MAPPING_ERROR)
 		goto free;
 	*dma_handle = mapping;
 	return ret;
@@ -478,6 +480,11 @@ static void calgary_free_coherent(struct device *dev, size_t size,
 	free_pages((unsigned long)vaddr, get_order(size));
 }
 
+static int calgary_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == CALGARY_MAPPING_ERROR;
+}
+
 static const struct dma_map_ops calgary_dma_ops = {
 	.alloc = calgary_alloc_coherent,
 	.free = calgary_free_coherent,
@@ -485,6 +492,7 @@ static const struct dma_map_ops calgary_dma_ops = {
 	.unmap_sg = calgary_unmap_sg,
 	.map_page = calgary_map_page,
 	.unmap_page = calgary_unmap_page,
+	.mapping_error = calgary_mapping_error,
 };
 
 static inline void __iomem * busno_to_bbar(unsigned char num)
@@ -732,7 +740,7 @@ static void __init calgary_reserve_regions(struct pci_dev *dev)
 	struct iommu_table *tbl = pci_iommu(dev->bus);
 
 	/* reserve EMERGENCY_PAGES from bad_dma_address and up */
-	iommu_range_reserve(tbl, DMA_ERROR_CODE, EMERGENCY_PAGES);
+	iommu_range_reserve(tbl, CALGARY_MAPPING_ERROR, EMERGENCY_PAGES);
 
 	/* avoid the BIOS/VGA first 640KB-1MB region */
 	/* for CalIOC2 - avoid the entire first MB */
-- 
2.11.0
