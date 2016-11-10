From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 08/23] arch/m68k: Add option to skip DMA sync as a
 part of mapping
Date: Thu, 10 Nov 2016 06:34:57 -0500
Message-ID: <20161110113457.76501.77603.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
later via a sync_for_cpu or sync_for_device call.

Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/m68k/kernel/dma.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/m68k/kernel/dma.c b/arch/m68k/kernel/dma.c
index 8cf97cb..0707006 100644
--- a/arch/m68k/kernel/dma.c
+++ b/arch/m68k/kernel/dma.c
@@ -134,7 +134,9 @@ static dma_addr_t m68k_dma_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t handle = page_to_phys(page) + offset;
 
-	dma_sync_single_for_device(dev, handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		dma_sync_single_for_device(dev, handle, size, dir);
+
 	return handle;
 }
 
@@ -146,6 +148,10 @@ static int m68k_dma_map_sg(struct device *dev, struct scatterlist *sglist,
 
 	for_each_sg(sglist, sg, nents, i) {
 		sg->dma_address = sg_phys(sg);
+
+		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
+			continue;
+
 		dma_sync_single_for_device(dev, sg->dma_address, sg->length,
 					   dir);
 	}
