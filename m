From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 08/44] xen-swiotlb: implement ->mapping_error
Date: Thu,  8 Jun 2017 15:25:33 +0200
Message-ID: <20170608132609.32662-9-hch@lst.de>
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

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/xen/swiotlb-xen.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index a0f006daab48..c3a04b2d7532 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -67,6 +67,8 @@ static unsigned long dma_alloc_coherent_mask(struct device *dev,
 }
 #endif
 
+#define XEN_SWIOTLB_ERROR_CODE	(~(dma_addr_t)0x0)
+
 static char *xen_io_tlb_start, *xen_io_tlb_end;
 static unsigned long xen_io_tlb_nslabs;
 /*
@@ -410,7 +412,7 @@ static dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	map = swiotlb_tbl_map_single(dev, start_dma_addr, phys, size, dir,
 				     attrs);
 	if (map == SWIOTLB_MAP_ERROR)
-		return DMA_ERROR_CODE;
+		return XEN_SWIOTLB_ERROR_CODE;
 
 	dev_addr = xen_phys_to_bus(map);
 	xen_dma_map_page(dev, pfn_to_page(map >> PAGE_SHIFT),
@@ -425,7 +427,7 @@ static dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 	attrs |= DMA_ATTR_SKIP_CPU_SYNC;
 	swiotlb_tbl_unmap_single(dev, map, size, dir, attrs);
 
-	return DMA_ERROR_CODE;
+	return XEN_SWIOTLB_ERROR_CODE;
 }
 
 /*
@@ -715,6 +717,11 @@ xen_swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
 	return dma_common_get_sgtable(dev, sgt, cpu_addr, handle, size);
 }
 
+static int xen_swiotlb_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == XEN_SWIOTLB_ERROR_CODE;
+}
+
 const struct dma_map_ops xen_swiotlb_dma_ops = {
 	.alloc = xen_swiotlb_alloc_coherent,
 	.free = xen_swiotlb_free_coherent,
@@ -730,4 +737,5 @@ const struct dma_map_ops xen_swiotlb_dma_ops = {
 	.set_dma_mask = xen_swiotlb_set_dma_mask,
 	.mmap = xen_swiotlb_dma_mmap,
 	.get_sgtable = xen_swiotlb_get_sgtable,
+	.mapping_error	= xen_swiotlb_mapping_error,
 };
-- 
2.11.0
