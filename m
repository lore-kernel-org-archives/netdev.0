From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/4] dma-mapping: remove dma_alloc_noncoherent and dma_free_noncoherent
Date: Sat, 26 Aug 2017 09:21:25 +0200
Message-ID: <20170826072125.9790-5-hch@lst.de>
References: <20170826072125.9790-1-hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>, linux-mips@vger.kernel.org,
        linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20170826072125.9790-1-hch@lst.de>
Sender: linux-parisc-owner@vger.kernel.org
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
index 45b29326d719..ef3a04fcad65 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -515,14 +515,15 @@ API at all.
 ::
 
 	void *
-	dma_alloc_noncoherent(struct device *dev, size_t size,
-			      dma_addr_t *dma_handle, gfp_t flag)
+	dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+			gfp_t flag, unsigned long attrs)
 
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
@@ -535,12 +536,13 @@ that simply cannot make consistent memory.
 ::
 
 	void
-	dma_free_noncoherent(struct device *dev, size_t size, void *cpu_addr,
-			     dma_addr_t dma_handle)
+	dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+		       dma_addr_t dma_handle, unsigned long attrs)
 
-Free memory allocated by the nonconsistent API.  All parameters must
-be identical to those passed in (and returned by
-dma_alloc_noncoherent()).
+Free memory allocated by the dma_alloc_attrs().  All parameters common
+parameters must identical to those otherwise passed to dma_fre_coherent,
+and the attrs argument must be identical to the attrs passed to
+dma_alloc_attrs().
 
 ::
 
@@ -564,8 +566,8 @@ memory or doing partial flushes.
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
index 66d8ea68f40b..4c98cc96971f 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -549,20 +549,6 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
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
