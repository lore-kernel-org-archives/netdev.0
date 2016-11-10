From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 19/23] arch/xtensa: Add option to skip DMA sync as a
 part of mapping
Date: Thu, 10 Nov 2016 06:35:55 -0500
Message-ID: <20161110113555.76501.52536.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Filippov <jcmvbkbc@gmail.com>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
avoid invoking cache line invalidation if the driver will just handle it
via a sync_for_cpu or sync_for_device call.

Cc: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/xtensa/kernel/pci-dma.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index 1e68806..6a16dec 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -189,7 +189,9 @@ static dma_addr_t xtensa_map_page(struct device *dev, struct page *page,
 {
 	dma_addr_t dma_handle = page_to_phys(page) + offset;
 
-	xtensa_sync_single_for_device(dev, dma_handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		xtensa_sync_single_for_device(dev, dma_handle, size, dir);
+
 	return dma_handle;
 }
 
@@ -197,7 +199,8 @@ static void xtensa_unmap_page(struct device *dev, dma_addr_t dma_handle,
 			      size_t size, enum dma_data_direction dir,
 			      unsigned long attrs)
 {
-	xtensa_sync_single_for_cpu(dev, dma_handle, size, dir);
+	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
+		xtensa_sync_single_for_cpu(dev, dma_handle, size, dir);
 }
 
 static int xtensa_map_sg(struct device *dev, struct scatterlist *sg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
