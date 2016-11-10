From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 20/23] dma: Add calls for dma_map_page_attrs and
 dma_unmap_page_attrs
Date: Thu, 10 Nov 2016 06:36:01 -0500
Message-ID: <20161110113601.76501.46095.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for mapping and unmapping a page with attributes.  The primary
use for this is currently to allow for us to pass the
DMA_ATTR_SKIP_CPU_SYNC attribute when mapping and unmapping a page.  On
some architectures such as ARM the synchronization has significant overhead
and if we are already taking care of the sync_for_cpu and sync_for_device
from the driver there isn't much need to handle this in the map/unmap calls
as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/dma-mapping.h |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 15400b4..2520a1d 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -237,29 +237,33 @@ static inline void dma_unmap_sg_attrs(struct device *dev, struct scatterlist *sg
 		ops->unmap_sg(dev, sg, nents, dir, attrs);
 }
 
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-				      size_t offset, size_t size,
-				      enum dma_data_direction dir)
+static inline dma_addr_t dma_map_page_attrs(struct device *dev,
+					    struct page *page,
+					    size_t offset, size_t size,
+					    enum dma_data_direction dir,
+					    unsigned long attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 	dma_addr_t addr;
 
 	kmemcheck_mark_initialized(page_address(page) + offset, size);
 	BUG_ON(!valid_dma_direction(dir));
-	addr = ops->map_page(dev, page, offset, size, dir, 0);
+	addr = ops->map_page(dev, page, offset, size, dir, attrs);
 	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
 
 	return addr;
 }
 
-static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
-				  size_t size, enum dma_data_direction dir)
+static inline void dma_unmap_page_attrs(struct device *dev,
+					dma_addr_t addr, size_t size,
+					enum dma_data_direction dir,
+					unsigned long attrs)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(dir));
 	if (ops->unmap_page)
-		ops->unmap_page(dev, addr, size, dir, 0);
+		ops->unmap_page(dev, addr, size, dir, attrs);
 	debug_dma_unmap_page(dev, addr, size, dir, false);
 }
 
@@ -344,6 +348,8 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, 0)
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, 0)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, 0)
+#define dma_map_page(d, p, o, s, r) dma_map_page_attrs(d, p, o, s, r, 0)
+#define dma_unmap_page(d, a, s, r) dma_unmap_page_attrs(d, a, s, r, 0)
 
 extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 			   void *cpu_addr, dma_addr_t dma_addr, size_t size);
