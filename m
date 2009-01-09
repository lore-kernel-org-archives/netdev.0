From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 11/16] dma-debug: add checking for [alloc|free]_coherent
Date: Fri, 9 Jan 2009 17:19:25 +0100
Message-ID: <1231517970-20288-12-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:36347 "EHLO
	VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbZAIQTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:45 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add debug callbacks for dma_[alloc|free]_coherent

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/dma-debug.h |   16 ++++++++++++++++
 lib/dma-debug.c           |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index b2131f4..a28a701 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -40,6 +40,12 @@ extern void debug_map_sg(struct device *dev, struct scatterlist *sg,
 extern void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
 			   int nelems, int dir);
 
+extern void debug_alloc_coherent(struct device *dev, size_t size,
+				 dma_addr_t dma_addr, void *virt);
+
+extern void debug_free_coherent(struct device *dev, size_t size,
+				void *virt, dma_addr_t addr);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline void dma_debug_init(u32 num_entries)
@@ -68,6 +74,16 @@ static inline void debug_unmap_sg(struct device *dev,
 {
 }
 
+static inline void debug_alloc_coherent(struct device *dev, size_t size,
+					dma_addr_t dma_addr, void *virt)
+{
+}
+
+static inline void debug_free_coherent(struct device *dev, size_t size,
+				       void *virt, dma_addr_t addr)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __DMA_DEBUG_H */
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index e6d45f9..a4a5b0f 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -604,3 +604,48 @@ void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
 }
 EXPORT_SYMBOL(debug_unmap_sg);
 
+void debug_alloc_coherent(struct device *dev, size_t size,
+			  dma_addr_t dma_addr, void *virt)
+{
+	struct dma_debug_entry *entry;
+
+	if (global_disable)
+		return;
+
+	if (dma_addr == bad_dma_address)
+		return;
+
+	entry = dma_entry_alloc();
+	if (!entry)
+		return;
+
+	entry->type      = dma_debug_coherent;
+	entry->dev       = dev;
+	entry->cpu_addr  = virt;
+	entry->size      = size;
+	entry->dev_addr  = dma_addr;
+	entry->direction = DMA_BIDIRECTIONAL;
+
+	add_dma_entry(entry);
+}
+EXPORT_SYMBOL(debug_alloc_coherent);
+
+void debug_free_coherent(struct device *dev, size_t size,
+			 void *virt, dma_addr_t addr)
+{
+	struct dma_debug_entry ref = {
+		.type           = dma_debug_coherent,
+		.dev            = dev,
+		.cpu_addr       = virt,
+		.dev_addr       = addr,
+		.size           = size,
+		.direction      = DMA_BIDIRECTIONAL,
+	};
+
+	if (global_disable)
+		return;
+
+	check_unmap(&ref);
+}
+EXPORT_SYMBOL(debug_free_coherent);
+
-- 
1.5.6.4


