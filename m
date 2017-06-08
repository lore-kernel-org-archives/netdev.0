From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 18/44] iommu/amd: implement ->mapping_error
Date: Thu,  8 Jun 2017 15:25:43 +0200
Message-ID: <20170608132609.32662-19-hch@lst.de>
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
Return-path: <linux-hexagon-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: linux-hexagon-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/iommu/amd_iommu.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 63cacf5d6cf2..d41280e869de 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -54,6 +54,8 @@
 #include "amd_iommu_types.h"
 #include "irq_remapping.h"
 
+#define AMD_IOMMU_MAPPING_ERROR	0
+
 #define CMD_SET_TYPE(cmd, t) ((cmd)->data[1] |= ((t) << 28))
 
 #define LOOP_TIMEOUT	100000
@@ -2394,7 +2396,7 @@ static dma_addr_t __map_single(struct device *dev,
 	paddr &= PAGE_MASK;
 
 	address = dma_ops_alloc_iova(dev, dma_dom, pages, dma_mask);
-	if (address == DMA_ERROR_CODE)
+	if (address == AMD_IOMMU_MAPPING_ERROR)
 		goto out;
 
 	prot = dir2prot(direction);
@@ -2431,7 +2433,7 @@ static dma_addr_t __map_single(struct device *dev,
 
 	dma_ops_free_iova(dma_dom, address, pages);
 
-	return DMA_ERROR_CODE;
+	return AMD_IOMMU_MAPPING_ERROR;
 }
 
 /*
@@ -2483,7 +2485,7 @@ static dma_addr_t map_page(struct device *dev, struct page *page,
 	if (PTR_ERR(domain) == -EINVAL)
 		return (dma_addr_t)paddr;
 	else if (IS_ERR(domain))
-		return DMA_ERROR_CODE;
+		return AMD_IOMMU_MAPPING_ERROR;
 
 	dma_mask = *dev->dma_mask;
 	dma_dom = to_dma_ops_domain(domain);
@@ -2560,7 +2562,7 @@ static int map_sg(struct device *dev, struct scatterlist *sglist,
 	npages = sg_num_pages(dev, sglist, nelems);
 
 	address = dma_ops_alloc_iova(dev, dma_dom, npages, dma_mask);
-	if (address == DMA_ERROR_CODE)
+	if (address == AMD_IOMMU_MAPPING_ERROR)
 		goto out_err;
 
 	prot = dir2prot(direction);
@@ -2683,7 +2685,7 @@ static void *alloc_coherent(struct device *dev, size_t size,
 	*dma_addr = __map_single(dev, dma_dom, page_to_phys(page),
 				 size, DMA_BIDIRECTIONAL, dma_mask);
 
-	if (*dma_addr == DMA_ERROR_CODE)
+	if (*dma_addr == AMD_IOMMU_MAPPING_ERROR)
 		goto out_free;
 
 	return page_address(page);
@@ -2732,6 +2734,11 @@ static int amd_iommu_dma_supported(struct device *dev, u64 mask)
 	return check_device(dev);
 }
 
+static int amd_iommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == AMD_IOMMU_MAPPING_ERROR;
+}
+
 static const struct dma_map_ops amd_iommu_dma_ops = {
 	.alloc		= alloc_coherent,
 	.free		= free_coherent,
@@ -2740,6 +2747,7 @@ static const struct dma_map_ops amd_iommu_dma_ops = {
 	.map_sg		= map_sg,
 	.unmap_sg	= unmap_sg,
 	.dma_supported	= amd_iommu_dma_supported,
+	.mapping_error	= amd_iommu_mapping_error,
 };
 
 static int init_reserved_iova_ranges(void)
-- 
2.11.0
