From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH RFC 08/26] arch/frv: Add option to skip sync on DMA
 map
Date: Mon, 24 Oct 2016 08:05:08 -0400
Message-ID: <20161024120508.16276.75216.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
APIs in the arch/arm folder.  This change is meant to correct that so that
we get consistent behavior.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/frv/mb93090-mb00/pci-dma-nommu.c |   16 +++++++++++-----
 arch/frv/mb93090-mb00/pci-dma.c       |    7 ++++++-
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/arch/frv/mb93090-mb00/pci-dma-nommu.c b/arch/frv/mb93090-mb00/pci-dma-nommu.c
index 90f2e4c..ff606d1 100644
--- a/arch/frv/mb93090-mb00/pci-dma-nommu.c
+++ b/arch/frv/mb93090-mb00/pci-dma-nommu.c
@@ -109,16 +109,19 @@ static int frv_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 		int nents, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	int i;
 	struct scatterlist *sg;
+	int i;
+
+	WARN_ON(direction == DMA_NONE);
+
+	if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+		return nents;
 
 	for_each_sg(sglist, sg, nents, i) {
 		frv_cache_wback_inv(sg_dma_address(sg),
 				    sg_dma_address(sg) + sg_dma_len(sg));
 	}
 
-	BUG_ON(direction == DMA_NONE);
-
 	return nents;
 }
 
@@ -126,8 +129,11 @@ static dma_addr_t frv_dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size,
 		enum dma_data_direction direction, unsigned long attrs)
 {
-	BUG_ON(direction == DMA_NONE);
-	flush_dcache_page(page);
+	WARN_ON(direction == DMA_NONE);
+
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		flush_dcache_page(page);
+
 	return (dma_addr_t) page_to_phys(page) + offset;
 }
 
diff --git a/arch/frv/mb93090-mb00/pci-dma.c b/arch/frv/mb93090-mb00/pci-dma.c
index f585745..ee5dadf 100644
--- a/arch/frv/mb93090-mb00/pci-dma.c
+++ b/arch/frv/mb93090-mb00/pci-dma.c
@@ -52,6 +52,9 @@ static int frv_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 	for_each_sg(sglist, sg, nents, i) {
 		vaddr = kmap_atomic_primary(sg_page(sg));
 
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		frv_dcache_writeback((unsigned long) vaddr,
 				     (unsigned long) vaddr + PAGE_SIZE);
 
@@ -70,7 +73,9 @@ static dma_addr_t frv_dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size,
 		enum dma_data_direction direction, unsigned long attrs)
 {
-	flush_dcache_page(page);
+	if (!(attr & DMA_ATTR_SKIP_CPU_SYNC))
+		flush_dcache_page(page);
+
 	return (dma_addr_t) page_to_phys(page) + offset;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
