From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH RFC 09/26] arch/hexagon: Add option to skip DMA
 sync as a part of mapping
Date: Mon, 24 Oct 2016 08:05:14 -0400
Message-ID: <20161024120513.16276.39929.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-hexagon@vger.kernel.org, brouer@redhat.com, davem@davemloft.net,
 Richard Kuo <rkuo@codeaurora.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: linux-hexagon@vger.kernel.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/hexagon/kernel/dma.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index b901778..dbc4f10 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -119,6 +119,9 @@ static int hexagon_map_sg(struct device *hwdev, struct scatterlist *sg,
 
 		s->dma_length = s->length;
 
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		flush_dcache_range(dma_addr_to_virt(s->dma_address),
 				   dma_addr_to_virt(s->dma_address + s->length));
 	}
@@ -180,7 +183,8 @@ static dma_addr_t hexagon_map_page(struct device *dev, struct page *page,
 	if (!check_addr("map_single", dev, bus, size))
 		return bad_dma_address;
 
-	dma_sync(dma_addr_to_virt(bus), size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync(dma_addr_to_virt(bus), size, dir);
 
 	return bus;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
