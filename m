From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 15/23] arch/powerpc: Add option to skip DMA sync as a
 part of mapping
Date: Thu, 10 Nov 2016 06:35:34 -0500
Message-ID: <20161110113534.76501.86492.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/powerpc/kernel/dma.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index e64a601..6877e3f 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -203,6 +203,10 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	for_each_sg(sgl, sg, nents, i) {
 		sg->dma_address = sg_phys(sg) + get_dma_offset(dev);
 		sg->dma_length = sg->length;
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
 	}
 
@@ -235,7 +239,10 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 					     unsigned long attrs)
 {
 	BUG_ON(dir == DMA_NONE);
-	__dma_sync_page(page, offset, size, dir);
+
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync_page(page, offset, size, dir);
+
 	return page_to_phys(page) + offset + get_dma_offset(dev);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
