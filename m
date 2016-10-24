From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH RFC 12/26] arch/microblaze: Add option to skip DMA
 sync as a part of map and unmap
Date: Mon, 24 Oct 2016 08:05:30 -0400
Message-ID: <20161024120529.16276.23335.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <monstr@monstr.eu>, davem@davemloft.net,
        brouer@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Michal Simek <monstr@monstr.eu>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/microblaze/kernel/dma.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/microblaze/kernel/dma.c b/arch/microblaze/kernel/dma.c
index ec04dc1..818daf2 100644
--- a/arch/microblaze/kernel/dma.c
+++ b/arch/microblaze/kernel/dma.c
@@ -61,6 +61,10 @@ static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 	/* FIXME this part of code is untested */
 	for_each_sg(sgl, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		__dma_sync(page_to_phys(sg_page(sg)) + sg->offset,
 							sg->length, direction);
 	}
@@ -80,7 +84,8 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 					     enum dma_data_direction direction,
 					     unsigned long attrs)
 {
-	__dma_sync(page_to_phys(page) + offset, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync(page_to_phys(page) + offset, size, direction);
 	return page_to_phys(page) + offset;
 }
 
@@ -95,7 +100,8 @@ static inline void dma_direct_unmap_page(struct device *dev,
  * phys_to_virt is here because in __dma_sync_page is __virt_to_phys and
  * dma_address is physical address
  */
-	__dma_sync(dma_address, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		__dma_sync(dma_address, size, direction);
 }
 
 static inline void
