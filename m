From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 07/44] xen-swiotlb: consolidate xen_swiotlb_dma_ops
Date: Thu,  8 Jun 2017 15:25:32 +0200
Message-ID: <20170608132609.32662-8-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170608132609.32662-1-hch-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

ARM and x86 had duplicated versions of the dma_ops structure, the
only difference is that x86 hasn't wired up the set_dma_mask,
mmap, and get_sgtable ops yet.  On x86 all of them are identical
to the generic version, so they aren't needed but harmless.

All the symbols used only for xen_swiotlb_dma_ops can now be marked
static as well.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 arch/arm/xen/mm.c              | 17 --------
 arch/x86/xen/pci-swiotlb-xen.c | 14 -------
 drivers/xen/swiotlb-xen.c      | 93 ++++++++++++++++++++++--------------------
 include/xen/swiotlb-xen.h      | 62 +---------------------------
 4 files changed, 49 insertions(+), 137 deletions(-)

diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index f0325d96b97a..785d2a562a23 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -185,23 +185,6 @@ EXPORT_SYMBOL_GPL(xen_destroy_contiguous_region);
 const struct dma_map_ops *xen_dma_ops;
 EXPORT_SYMBOL(xen_dma_ops);
 
-static const struct dma_map_ops xen_swiotlb_dma_ops = {
-	.alloc = xen_swiotlb_alloc_coherent,
-	.free = xen_swiotlb_free_coherent,
-	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = xen_swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = xen_swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = xen_swiotlb_sync_sg_for_device,
-	.map_sg = xen_swiotlb_map_sg_attrs,
-	.unmap_sg = xen_swiotlb_unmap_sg_attrs,
-	.map_page = xen_swiotlb_map_page,
-	.unmap_page = xen_swiotlb_unmap_page,
-	.dma_supported = xen_swiotlb_dma_supported,
-	.set_dma_mask = xen_swiotlb_set_dma_mask,
-	.mmap = xen_swiotlb_dma_mmap,
-	.get_sgtable = xen_swiotlb_get_sgtable,
-};
-
 int __init xen_mm_init(void)
 {
 	struct gnttab_cache_flush cflush;
diff --git a/arch/x86/xen/pci-swiotlb-xen.c b/arch/x86/xen/pci-swiotlb-xen.c
index 42b08f8fc2ca..37c6056a7bba 100644
--- a/arch/x86/xen/pci-swiotlb-xen.c
+++ b/arch/x86/xen/pci-swiotlb-xen.c
@@ -18,20 +18,6 @@
 
 int xen_swiotlb __read_mostly;
 
-static const struct dma_map_ops xen_swiotlb_dma_ops = {
-	.alloc = xen_swiotlb_alloc_coherent,
-	.free = xen_swiotlb_free_coherent,
-	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = xen_swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = xen_swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = xen_swiotlb_sync_sg_for_device,
-	.map_sg = xen_swiotlb_map_sg_attrs,
-	.unmap_sg = xen_swiotlb_unmap_sg_attrs,
-	.map_page = xen_swiotlb_map_page,
-	.unmap_page = xen_swiotlb_unmap_page,
-	.dma_supported = xen_swiotlb_dma_supported,
-};
-
 /*
  * pci_xen_swiotlb_detect - set xen_swiotlb to 1 if necessary
  *
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 8dab0d3dc172..a0f006daab48 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -295,7 +295,8 @@ int __ref xen_swiotlb_init(int verbose, bool early)
 		free_pages((unsigned long)xen_io_tlb_start, order);
 	return rc;
 }
-void *
+
+static void *
 xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 			   dma_addr_t *dma_handle, gfp_t flags,
 			   unsigned long attrs)
@@ -346,9 +347,8 @@ xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	memset(ret, 0, size);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_alloc_coherent);
 
-void
+static void
 xen_swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 			  dma_addr_t dev_addr, unsigned long attrs)
 {
@@ -369,8 +369,6 @@ xen_swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 
 	xen_free_coherent_pages(hwdev, size, vaddr, (dma_addr_t)phys, attrs);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_free_coherent);
-
 
 /*
  * Map a single buffer of the indicated size for DMA in streaming mode.  The
@@ -379,7 +377,7 @@ EXPORT_SYMBOL_GPL(xen_swiotlb_free_coherent);
  * Once the device is given the dma address, the device owns this memory until
  * either xen_swiotlb_unmap_page or xen_swiotlb_dma_sync_single is performed.
  */
-dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
+static dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 				unsigned long offset, size_t size,
 				enum dma_data_direction dir,
 				unsigned long attrs)
@@ -429,7 +427,6 @@ dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
 
 	return DMA_ERROR_CODE;
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_map_page);
 
 /*
  * Unmap a single streaming mode DMA translation.  The dma_addr and size must
@@ -467,13 +464,12 @@ static void xen_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
 	dma_mark_clean(phys_to_virt(paddr), size);
 }
 
-void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
+static void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			    size_t size, enum dma_data_direction dir,
 			    unsigned long attrs)
 {
 	xen_unmap_single(hwdev, dev_addr, size, dir, attrs);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_unmap_page);
 
 /*
  * Make physical memory consistent for a single streaming mode DMA translation
@@ -516,7 +512,6 @@ xen_swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
 {
 	xen_swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_CPU);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_sync_single_for_cpu);
 
 void
 xen_swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
@@ -524,7 +519,25 @@ xen_swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
 {
 	xen_swiotlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_DEVICE);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_sync_single_for_device);
+
+/*
+ * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
+ * concerning calls here are the same as for swiotlb_unmap_page() above.
+ */
+static void
+xen_swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
+			   int nelems, enum dma_data_direction dir,
+			   unsigned long attrs)
+{
+	struct scatterlist *sg;
+	int i;
+
+	BUG_ON(dir == DMA_NONE);
+
+	for_each_sg(sgl, sg, nelems, i)
+		xen_unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir, attrs);
+
+}
 
 /*
  * Map a set of buffers described by scatterlist in streaming mode for DMA.
@@ -542,7 +555,7 @@ EXPORT_SYMBOL_GPL(xen_swiotlb_sync_single_for_device);
  * Device ownership issues as mentioned above for xen_swiotlb_map_page are the
  * same here.
  */
-int
+static int
 xen_swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 			 int nelems, enum dma_data_direction dir,
 			 unsigned long attrs)
@@ -599,27 +612,6 @@ xen_swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 	}
 	return nelems;
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_map_sg_attrs);
-
-/*
- * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
- * concerning calls here are the same as for swiotlb_unmap_page() above.
- */
-void
-xen_swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
-			   int nelems, enum dma_data_direction dir,
-			   unsigned long attrs)
-{
-	struct scatterlist *sg;
-	int i;
-
-	BUG_ON(dir == DMA_NONE);
-
-	for_each_sg(sgl, sg, nelems, i)
-		xen_unmap_single(hwdev, sg->dma_address, sg_dma_len(sg), dir, attrs);
-
-}
-EXPORT_SYMBOL_GPL(xen_swiotlb_unmap_sg_attrs);
 
 /*
  * Make physical memory consistent for a set of streaming mode DMA translations
@@ -641,21 +633,19 @@ xen_swiotlb_sync_sg(struct device *hwdev, struct scatterlist *sgl,
 					sg_dma_len(sg), dir, target);
 }
 
-void
+static void
 xen_swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
 			    int nelems, enum dma_data_direction dir)
 {
 	xen_swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_CPU);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_sync_sg_for_cpu);
 
-void
+static void
 xen_swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
 			       int nelems, enum dma_data_direction dir)
 {
 	xen_swiotlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_DEVICE);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_sync_sg_for_device);
 
 /*
  * Return whether the given device DMA address mask can be supported
@@ -663,14 +653,13 @@ EXPORT_SYMBOL_GPL(xen_swiotlb_sync_sg_for_device);
  * during bus mastering, then you would pass 0x00ffffff as the mask to
  * this function.
  */
-int
+static int
 xen_swiotlb_dma_supported(struct device *hwdev, u64 mask)
 {
 	return xen_virt_to_bus(xen_io_tlb_end - 1) <= mask;
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_dma_supported);
 
-int
+static int
 xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask)
 {
 	if (!dev->dma_mask || !xen_swiotlb_dma_supported(dev, dma_mask))
@@ -680,14 +669,13 @@ xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_set_dma_mask);
 
 /*
  * Create userspace mapping for the DMA-coherent memory.
  * This function should be called with the pages from the current domain only,
  * passing pages mapped from other domains would lead to memory corruption.
  */
-int
+static int
 xen_swiotlb_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 		     void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		     unsigned long attrs)
@@ -699,13 +687,12 @@ xen_swiotlb_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 #endif
 	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_dma_mmap);
 
 /*
  * This function should be called with the pages from the current domain only,
  * passing pages mapped from other domains would lead to memory corruption.
  */
-int
+static int
 xen_swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
 			void *cpu_addr, dma_addr_t handle, size_t size,
 			unsigned long attrs)
@@ -727,4 +714,20 @@ xen_swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
 #endif
 	return dma_common_get_sgtable(dev, sgt, cpu_addr, handle, size);
 }
-EXPORT_SYMBOL_GPL(xen_swiotlb_get_sgtable);
+
+const struct dma_map_ops xen_swiotlb_dma_ops = {
+	.alloc = xen_swiotlb_alloc_coherent,
+	.free = xen_swiotlb_free_coherent,
+	.sync_single_for_cpu = xen_swiotlb_sync_single_for_cpu,
+	.sync_single_for_device = xen_swiotlb_sync_single_for_device,
+	.sync_sg_for_cpu = xen_swiotlb_sync_sg_for_cpu,
+	.sync_sg_for_device = xen_swiotlb_sync_sg_for_device,
+	.map_sg = xen_swiotlb_map_sg_attrs,
+	.unmap_sg = xen_swiotlb_unmap_sg_attrs,
+	.map_page = xen_swiotlb_map_page,
+	.unmap_page = xen_swiotlb_unmap_page,
+	.dma_supported = xen_swiotlb_dma_supported,
+	.set_dma_mask = xen_swiotlb_set_dma_mask,
+	.mmap = xen_swiotlb_dma_mmap,
+	.get_sgtable = xen_swiotlb_get_sgtable,
+};
diff --git a/include/xen/swiotlb-xen.h b/include/xen/swiotlb-xen.h
index 1f6d78f044b6..ed2de363da33 100644
--- a/include/xen/swiotlb-xen.h
+++ b/include/xen/swiotlb-xen.h
@@ -1,69 +1,9 @@
 #ifndef __LINUX_SWIOTLB_XEN_H
 #define __LINUX_SWIOTLB_XEN_H
 
-#include <linux/dma-direction.h>
-#include <linux/scatterlist.h>
 #include <linux/swiotlb.h>
 
 extern int xen_swiotlb_init(int verbose, bool early);
+extern const struct dma_map_ops xen_swiotlb_dma_ops;
 
-extern void
-*xen_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
-			    dma_addr_t *dma_handle, gfp_t flags,
-			    unsigned long attrs);
-
-extern void
-xen_swiotlb_free_coherent(struct device *hwdev, size_t size,
-			  void *vaddr, dma_addr_t dma_handle,
-			  unsigned long attrs);
-
-extern dma_addr_t xen_swiotlb_map_page(struct device *dev, struct page *page,
-				       unsigned long offset, size_t size,
-				       enum dma_data_direction dir,
-				       unsigned long attrs);
-
-extern void xen_swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
-				   size_t size, enum dma_data_direction dir,
-				   unsigned long attrs);
-extern int
-xen_swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
-			 int nelems, enum dma_data_direction dir,
-			 unsigned long attrs);
-
-extern void
-xen_swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
-			   int nelems, enum dma_data_direction dir,
-			   unsigned long attrs);
-
-extern void
-xen_swiotlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
-				size_t size, enum dma_data_direction dir);
-
-extern void
-xen_swiotlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
-			    int nelems, enum dma_data_direction dir);
-
-extern void
-xen_swiotlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
-				   size_t size, enum dma_data_direction dir);
-
-extern void
-xen_swiotlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
-			       int nelems, enum dma_data_direction dir);
-
-extern int
-xen_swiotlb_dma_supported(struct device *hwdev, u64 mask);
-
-extern int
-xen_swiotlb_set_dma_mask(struct device *dev, u64 dma_mask);
-
-extern int
-xen_swiotlb_dma_mmap(struct device *dev, struct vm_area_struct *vma,
-		     void *cpu_addr, dma_addr_t dma_addr, size_t size,
-		     unsigned long attrs);
-
-extern int
-xen_swiotlb_get_sgtable(struct device *dev, struct sg_table *sgt,
-			void *cpu_addr, dma_addr_t handle, size_t size,
-			unsigned long attrs);
 #endif /* __LINUX_SWIOTLB_XEN_H */
-- 
2.11.0
