From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 10/16] dma-debug: add add checking for map/unmap_sg
Date: Fri, 9 Jan 2009 17:19:24 +0100
Message-ID: <1231517970-20288-11-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:47695 "EHLO
	SG2EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbZAIQUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:20:09 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: add debug callbacks for dma_{un}map_sg

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 include/linux/dma-debug.h |   15 ++++++++++++
 lib/dma-debug.c           |   53 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index 82ae9ca..b2131f4 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -34,6 +34,11 @@ extern void debug_map_single(struct device *dev, void *ptr, size_t size,
 extern void debug_unmap_single(struct device *dev, dma_addr_t addr,
 			       size_t size, int direction);
 
+extern void debug_map_sg(struct device *dev, struct scatterlist *sg,
+			 int nents, int direction);
+
+extern void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
+			   int nelems, int dir);
 
 #else /* CONFIG_DMA_API_DEBUG */
 
@@ -52,6 +57,16 @@ static inline void debug_unmap_single(struct device *dev, dma_addr_t addr,
 {
 }
 
+static inline void debug_map_sg(struct device *dev, struct scatterlist *sg,
+				int nents, int direction)
+{
+}
+
+static inline void debug_unmap_sg(struct device *dev,
+				  struct scatterlist *sglist,
+				  int nelems, int dir)
+{
+}
 
 #endif /* CONFIG_DMA_API_DEBUG */
 
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index d4d14e5..e6d45f9 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -17,6 +17,7 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
  */
 
+#include <linux/scatterlist.h>
 #include <linux/dma-mapping.h>
 #include <linux/dma-debug.h>
 #include <linux/spinlock.h>
@@ -551,3 +552,55 @@ void debug_unmap_single(struct device *dev, dma_addr_t addr,
 }
 EXPORT_SYMBOL(debug_unmap_single);
 
+void debug_map_sg(struct device *dev, struct scatterlist *sg,
+		  int nents, int direction)
+{
+	struct dma_debug_entry *entry;
+	struct scatterlist *s;
+	int i;
+
+	if (global_disable)
+		return;
+
+	for_each_sg(sg, s, nents, i) {
+		entry = dma_entry_alloc();
+		if (!entry)
+			return;
+
+		entry->type      = dma_debug_sg;
+		entry->dev       = dev;
+		entry->cpu_addr  = sg_virt(s);
+		entry->size      = s->length;
+		entry->dev_addr  = s->dma_address;
+		entry->direction = direction;
+
+		add_dma_entry(entry);
+	}
+}
+EXPORT_SYMBOL(debug_map_sg);
+
+void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
+		    int nelems, int dir)
+{
+	struct scatterlist *s;
+	int i;
+
+	if (global_disable)
+		return;
+
+	for_each_sg(sglist, s, nelems, i) {
+
+		struct dma_debug_entry ref = {
+			.type           = dma_debug_sg,
+			.dev            = dev,
+			.cpu_addr       = sg_virt(s),
+			.dev_addr       = s->dma_address,
+			.size           = s->length,
+			.direction      = dir,
+		};
+
+		check_unmap(&ref);
+	}
+}
+EXPORT_SYMBOL(debug_unmap_sg);
+
-- 
1.5.6.4


