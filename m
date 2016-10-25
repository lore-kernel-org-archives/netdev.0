From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 06/27] arch/avr32: Add option to skip sync on DMA
 map
Date: Tue, 25 Oct 2016 11:37:20 -0400
Message-ID: <20161025153720.4815.9188.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, davem@davemloft.net,
 Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
APIs in the arch/arm folder.  This change is meant to correct that so that
we get consistent behavior.

Acked-by: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/avr32/mm/dma-coherent.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/avr32/mm/dma-coherent.c b/arch/avr32/mm/dma-coherent.c
index 58610d0..54534e5 100644
--- a/arch/avr32/mm/dma-coherent.c
+++ b/arch/avr32/mm/dma-coherent.c
@@ -146,7 +146,8 @@ static dma_addr_t avr32_dma_map_page(struct device *dev, struct page *page,
 {
 	void *cpu_addr = page_address(page) + offset;
 
-	dma_cache_sync(dev, cpu_addr, size, direction);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_cache_sync(dev, cpu_addr, size, direction);
 	return virt_to_bus(cpu_addr);
 }
 
@@ -162,6 +163,10 @@ static int avr32_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 		sg->dma_address = page_to_bus(sg_page(sg)) + sg->offset;
 		virt = sg_virt(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_cache_sync(dev, virt, sg->length, direction);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
