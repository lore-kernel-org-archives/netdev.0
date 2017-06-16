From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/11] dma-mapping: remove dma_alloc_noncoherent and dma_free_noncoherent
Date: Fri, 16 Jun 2017 09:17:16 +0200
Message-ID: <20170616071716.17321-12-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No users left, everyone switched to the _attrs versions.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/DMA-API.txt            | 30 ++++++++++++++++--------------
 arch/metag/include/asm/dma-mapping.h |  2 +-
 arch/nios2/include/asm/dma-mapping.h |  2 +-
 arch/tile/include/asm/dma-mapping.h  |  4 ++--
 include/linux/dma-mapping.h          | 14 --------------
 5 files changed, 20 insertions(+), 32 deletions(-)

diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index 6b20128fab8a..c55782f68348 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -451,14 +451,15 @@ processor and an I/O device, you should not be using this part of the
 API at all.
 
 void *
-dma_alloc_noncoherent(struct device *dev, size_t size,
-			       dma_addr_t *dma_handle, gfp_t flag)
+dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t flag, unsigned long attrs)
 
-Identical to dma_alloc_coherent() except that the platform will
-choose to return either consistent or non-consistent memory as it sees
-fit.  By using this API, you are guaranteeing to the platform that you
-have all the correct and necessary sync points for this memory in the
-driver should it choose to return non-consistent memory.
+Identical to dma_alloc_coherent() except that when the
+DMA_ATTR_NON_CONSISTENT flags is passed in the attrs argument, the
+platform will choose to return either consistent or non-consistent memory
+as it sees fit.  By using this API, you are guaranteeing to the platform
+that you have all the correct and necessary sync points for this memory
+in the driver should it choose to return non-consistent memory.
 
 Note: where the platform can return consistent memory, it will
 guarantee that the sync points become nops.
@@ -469,12 +470,13 @@ required to work on one of the rare (usually non-PCI) architectures
 that simply cannot make consistent memory.
 
 void
-dma_free_noncoherent(struct device *dev, size_t size, void *cpu_addr,
-			      dma_addr_t dma_handle)
+dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+	       dma_addr_t dma_handle, unsigned long attrs)
 
-Free memory allocated by the nonconsistent API.  All parameters must
-be identical to those passed in (and returned by
-dma_alloc_noncoherent()).
+Free memory allocated by the dma_alloc_attrs().  All parameters common
+parameters must identical to those otherwise passed to dma_fre_coherent,
+and the attrs argument must be identical to the attrs passed to
+dma_alloc_attrs().
 
 int
 dma_get_cache_alignment(void)
@@ -492,8 +494,8 @@ void
 dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 	       enum dma_data_direction direction)
 
-Do a partial sync of memory that was allocated by
-dma_alloc_noncoherent(), starting at virtual address vaddr and
+Do a partial sync of memory that was allocated by dma_alloc_attrs() with
+the DMA_ATTR_NON_CONSISTENT flag starting at virtual address vaddr and
 continuing on for size.  Again, you *must* observe the cache line
 boundaries when doing this.
 
diff --git a/arch/metag/include/asm/dma-mapping.h b/arch/metag/include/asm/dma-mapping.h
index fad3dc3cb210..ea573be2b6d0 100644
--- a/arch/metag/include/asm/dma-mapping.h
+++ b/arch/metag/include/asm/dma-mapping.h
@@ -9,7 +9,7 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 }
 
 /*
- * dma_alloc_noncoherent() returns non-cacheable memory, so there's no need to
+ * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
  * do any flushing here.
  */
 static inline void
diff --git a/arch/nios2/include/asm/dma-mapping.h b/arch/nios2/include/asm/dma-mapping.h
index 7b3c6f280293..f8dc62222741 100644
--- a/arch/nios2/include/asm/dma-mapping.h
+++ b/arch/nios2/include/asm/dma-mapping.h
@@ -18,7 +18,7 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 }
 
 /*
- * dma_alloc_noncoherent() returns non-cacheable memory, so there's no need to
+ * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
  * do any flushing here.
  */
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
diff --git a/arch/tile/include/asm/dma-mapping.h b/arch/tile/include/asm/dma-mapping.h
index bbc71a29b2c6..7061dc8af43a 100644
--- a/arch/tile/include/asm/dma-mapping.h
+++ b/arch/tile/include/asm/dma-mapping.h
@@ -68,8 +68,8 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 int dma_set_mask(struct device *dev, u64 mask);
 
 /*
- * dma_alloc_noncoherent() is #defined to return coherent memory,
- * so there's no need to do any flushing here.
+ * dma_alloc_attrs() always returns non-cacheable memory, so there's no need to
+ * do any flushing here.
  */
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 				  enum dma_data_direction direction)
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 6cdf5634906d..e8861e7df6ab 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -526,20 +526,6 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 	return dma_free_attrs(dev, size, cpu_addr, dma_handle, 0);
 }
 
-static inline void *dma_alloc_noncoherent(struct device *dev, size_t size,
-		dma_addr_t *dma_handle, gfp_t gfp)
-{
-	return dma_alloc_attrs(dev, size, dma_handle, gfp,
-			       DMA_ATTR_NON_CONSISTENT);
-}
-
-static inline void dma_free_noncoherent(struct device *dev, size_t size,
-		void *cpu_addr, dma_addr_t dma_handle)
-{
-	dma_free_attrs(dev, size, cpu_addr, dma_handle,
-		       DMA_ATTR_NON_CONSISTENT);
-}
-
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
 	debug_dma_mapping_error(dev, dma_addr);
-- 
2.11.0
