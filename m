From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 09/23] arch/metag: Add option to skip DMA sync as a
 part of map and unmap
Date: Thu, 10 Nov 2016 06:35:03 -0500
Message-ID: <20161110113503.76501.80809.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James Hogan <james.hogan@imgtec.com>,
 linux-metag@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-metag@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/metag/kernel/dma.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/arch/metag/kernel/dma.c b/arch/metag/kernel/dma.c
index 0db31e2..91968d9 100644
--- a/arch/metag/kernel/dma.c
+++ b/arch/metag/kernel/dma.c
@@ -484,8 +484,9 @@ static dma_addr_t metag_dma_map_page(struct device *dev, struct page *page,
 		unsigned long offset, size_t size,
 		enum dma_data_direction direction, unsigned long attrs)
 {
-	dma_sync_for_device((void *)(page_to_phys(page) + offset), size,
-			    direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_for_device((void *)(page_to_phys(page) + offset),
+				    size, direction);
 	return page_to_phys(page) + offset;
 }
 
@@ -493,7 +494,8 @@ static void metag_dma_unmap_page(struct device *dev, dma_addr_t dma_address,
 		size_t size, enum dma_data_direction direction,
 		unsigned long attrs)
 {
-	dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_for_cpu(phys_to_virt(dma_address), size, direction);
 }
 
 static int metag_dma_map_sg(struct device *dev, struct scatterlist *sglist,
@@ -507,6 +509,10 @@ static int metag_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 		BUG_ON(!sg_page(sg));
 
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_for_device(sg_virt(sg), sg->length, direction);
 	}
 
@@ -525,6 +531,10 @@ static void metag_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		BUG_ON(!sg_page(sg));
 
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_for_cpu(sg_virt(sg), sg->length, direction);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
