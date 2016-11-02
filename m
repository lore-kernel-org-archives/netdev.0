From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v2 05/26] arch/arm: Add option to skip sync on DMA map
 and unmap
Date: Wed, 02 Nov 2016 07:13:21 -0400
Message-ID: <20161102111316.79519.75964.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
        linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
APIs in the arch/arm folder.  This change is meant to correct that so that
we get consistent behavior.

Cc: Russell King <linux@armlinux.org.uk>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 arch/arm/common/dmabounce.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 3012816..75055df 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -243,7 +243,8 @@ static int needs_bounce(struct device *dev, dma_addr_t dma_addr, size_t size)
 }
 
 static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
-		enum dma_data_direction dir)
+				    enum dma_data_direction dir,
+				    unsigned long attrs)
 {
 	struct dmabounce_device_info *device_info = dev->archdata.dmabounce;
 	struct safe_buffer *buf;
@@ -262,7 +263,8 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 		__func__, buf->ptr, virt_to_dma(dev, buf->ptr),
 		buf->safe, buf->safe_dma_addr);
 
-	if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL) {
+	if ((dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL) &&
+	    !(attrs & DMA_ATTR_SKIP_CPU_SYNC)) {
 		dev_dbg(dev, "%s: copy unsafe %p to safe %p, size %d\n",
 			__func__, ptr, buf->safe, size);
 		memcpy(buf->safe, ptr, size);
@@ -272,7 +274,8 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 }
 
 static inline void unmap_single(struct device *dev, struct safe_buffer *buf,
-		size_t size, enum dma_data_direction dir)
+				size_t size, enum dma_data_direction dir,
+				unsigned long attrs)
 {
 	BUG_ON(buf->size != size);
 	BUG_ON(buf->direction != dir);
@@ -283,7 +286,8 @@ static inline void unmap_single(struct device *dev, struct safe_buffer *buf,
 
 	DO_STATS(dev->archdata.dmabounce->bounce_count++);
 
-	if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL) {
+	if ((dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL) &&
+	    !(attrs & DMA_ATTR_SKIP_CPU_SYNC)) {
 		void *ptr = buf->ptr;
 
 		dev_dbg(dev, "%s: copy back safe %p to unsafe %p size %d\n",
@@ -334,7 +338,7 @@ static dma_addr_t dmabounce_map_page(struct device *dev, struct page *page,
 		return DMA_ERROR_CODE;
 	}
 
-	return map_single(dev, page_address(page) + offset, size, dir);
+	return map_single(dev, page_address(page) + offset, size, dir, attrs);
 }
 
 /*
@@ -357,7 +361,7 @@ static void dmabounce_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t
 		return;
 	}
 
-	unmap_single(dev, buf, size, dir);
+	unmap_single(dev, buf, size, dir, attrs);
 }
 
 static int __dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
