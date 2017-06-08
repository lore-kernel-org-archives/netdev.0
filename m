From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 19/44] s390: implement ->mapping_error
Date: Thu,  8 Jun 2017 15:25:44 +0200
Message-ID: <20170608132609.32662-20-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
        linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
        linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
        linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608132609.32662-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

s390 can also use noop_dma_ops, and while that currently does not return
errors it will so in the future.  Implementing the mapping_error method
is the proper way to have per-ops error conditions.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 arch/s390/include/asm/dma-mapping.h |  2 --
 arch/s390/pci/pci_dma.c             | 18 +++++++++++++-----
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/arch/s390/include/asm/dma-mapping.h b/arch/s390/include/asm/dma-mapping.h
index 3108b8dbe266..512ad0eaa11a 100644
--- a/arch/s390/include/asm/dma-mapping.h
+++ b/arch/s390/include/asm/dma-mapping.h
@@ -8,8 +8,6 @@
 #include <linux/dma-debug.h>
 #include <linux/io.h>
 
-#define DMA_ERROR_CODE		(~(dma_addr_t) 0x0)
-
 extern const struct dma_map_ops s390_pci_dma_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index 9081a57fa340..ea623faab525 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -14,6 +14,8 @@
 #include <linux/pci.h>
 #include <asm/pci_dma.h>
 
+#define S390_MAPPING_ERROR		(~(dma_addr_t) 0x0)
+
 static struct kmem_cache *dma_region_table_cache;
 static struct kmem_cache *dma_page_table_cache;
 static int s390_iommu_strict;
@@ -281,7 +283,7 @@ static dma_addr_t dma_alloc_address(struct device *dev, int size)
 
 out_error:
 	spin_unlock_irqrestore(&zdev->iommu_bitmap_lock, flags);
-	return DMA_ERROR_CODE;
+	return S390_MAPPING_ERROR;
 }
 
 static void dma_free_address(struct device *dev, dma_addr_t dma_addr, int size)
@@ -329,7 +331,7 @@ static dma_addr_t s390_dma_map_pages(struct device *dev, struct page *page,
 	/* This rounds up number of pages based on size and offset */
 	nr_pages = iommu_num_pages(pa, size, PAGE_SIZE);
 	dma_addr = dma_alloc_address(dev, nr_pages);
-	if (dma_addr == DMA_ERROR_CODE) {
+	if (dma_addr == S390_MAPPING_ERROR) {
 		ret = -ENOSPC;
 		goto out_err;
 	}
@@ -352,7 +354,7 @@ static dma_addr_t s390_dma_map_pages(struct device *dev, struct page *page,
 out_err:
 	zpci_err("map error:\n");
 	zpci_err_dma(ret, pa);
-	return DMA_ERROR_CODE;
+	return S390_MAPPING_ERROR;
 }
 
 static void s390_dma_unmap_pages(struct device *dev, dma_addr_t dma_addr,
@@ -429,7 +431,7 @@ static int __s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	int ret;
 
 	dma_addr_base = dma_alloc_address(dev, nr_pages);
-	if (dma_addr_base == DMA_ERROR_CODE)
+	if (dma_addr_base == S390_MAPPING_ERROR)
 		return -ENOMEM;
 
 	dma_addr = dma_addr_base;
@@ -476,7 +478,7 @@ static int s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	for (i = 1; i < nr_elements; i++) {
 		s = sg_next(s);
 
-		s->dma_address = DMA_ERROR_CODE;
+		s->dma_address = S390_MAPPING_ERROR;
 		s->dma_length = 0;
 
 		if (s->offset || (size & ~PAGE_MASK) ||
@@ -525,6 +527,11 @@ static void s390_dma_unmap_sg(struct device *dev, struct scatterlist *sg,
 		s->dma_length = 0;
 	}
 }
+	
+static int s390_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == S390_MAPPING_ERROR;
+}
 
 int zpci_dma_init_device(struct zpci_dev *zdev)
 {
@@ -657,6 +664,7 @@ const struct dma_map_ops s390_pci_dma_ops = {
 	.unmap_sg	= s390_dma_unmap_sg,
 	.map_page	= s390_dma_map_pages,
 	.unmap_page	= s390_dma_unmap_pages,
+	.mapping_error	= s390_mapping_error,
 	/* if we support direct DMA this must be conditional */
 	.is_phys	= 0,
 	/* dma_supported is unconditionally true without a callback */
-- 
2.11.0
