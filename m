From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 06/10] x86: add check code for map/unmap_sg code
Date: Fri, 21 Nov 2008 17:26:06 +0100
Message-ID: <1227284770-19215-7-git-send-email-joerg.roedel@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:5021 "EHLO
	WA4EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbYKUQ0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:23 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: detect bugs in map/unmap_sg usage

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/include/asm/dma-mapping.h |    9 ++++-
 arch/x86/include/asm/dma_debug.h   |   20 +++++++++++
 arch/x86/kernel/pci-dma-debug.c    |   63 ++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index c9bead2..c7bdb75 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -126,9 +126,14 @@ dma_map_sg(struct device *hwdev, struct scatterlist *sg,
 	   int nents, int direction)
 {
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
+	int ret;
 
 	BUG_ON(!valid_dma_direction(direction));
-	return ops->map_sg(hwdev, sg, nents, direction);
+	ret =  ops->map_sg(hwdev, sg, nents, direction);
+
+	debug_map_sg(hwdev, sg, ret, direction);
+
+	return ret;
 }
 
 static inline void
@@ -140,6 +145,8 @@ dma_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
 	BUG_ON(!valid_dma_direction(direction));
 	if (ops->unmap_sg)
 		ops->unmap_sg(hwdev, sg, nents, direction);
+
+	debug_unmap_sg(hwdev, sg, nents, direction);
 }
 
 static inline void
diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
index ba4d9b7..ff06d1c 100644
--- a/arch/x86/include/asm/dma_debug.h
+++ b/arch/x86/include/asm/dma_debug.h
@@ -51,6 +51,14 @@ extern
 void debug_unmap_single(struct device *dev, dma_addr_t addr,
 			size_t size, int direction);
 
+extern
+void debug_map_sg(struct device *dev, struct scatterlist *sg,
+		  int nents, int direction);
+
+extern
+void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
+		    int nelems, int dir);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline
@@ -70,6 +78,18 @@ void debug_unmap_single(struct device *dev, dma_addr_t addr,
 {
 }
 
+static inline
+void debug_map_sg(struct device *dev, struct scatterlist *sg,
+		  int nents, int direction)
+{
+}
+
+static inline
+void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
+		    int nelems, int dir)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __ASM_X86_DMA_DEBUG */
diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
index 9afb6c8..55ef69a 100644
--- a/arch/x86/kernel/pci-dma-debug.c
+++ b/arch/x86/kernel/pci-dma-debug.c
@@ -289,3 +289,66 @@ void debug_unmap_single(struct device *dev, dma_addr_t addr,
 }
 EXPORT_SYMBOL(debug_unmap_single);
 
+void debug_map_sg(struct device *dev, struct scatterlist *sg,
+		  int nents, int direction)
+{
+	unsigned long flags;
+	struct dma_debug_entry *entry;
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nents, i) {
+		entry = dma_entry_alloc();
+		if (!entry)
+			return;
+
+		entry->type      = DMA_DEBUG_SG;
+		entry->dev       = dev;
+		entry->cpu_addr  = sg_virt(s);
+		entry->size      = s->length;
+		entry->dev_addr  = s->dma_address;
+		entry->direction = direction;
+
+		spin_lock_irqsave(&dma_lock, flags);
+		add_dma_entry(entry);
+		spin_unlock_irqrestore(&dma_lock, flags);
+	}
+}
+EXPORT_SYMBOL(debug_map_sg);
+
+void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
+		    int nelems, int dir)
+{
+	unsigned long flags;
+	struct dma_debug_entry *entry;
+	struct scatterlist *s;
+	int i;
+
+	spin_lock_irqsave(&dma_lock, flags);
+
+	for_each_sg(sglist, s, nelems, i) {
+
+		struct dma_debug_entry ref = {
+			.type = DMA_DEBUG_SG,
+			.dev = dev,
+			.cpu_addr = sg_virt(s),
+			.dev_addr = s->dma_address,
+			.size = s->length,
+			.direction = dir,
+		};
+
+		if (ref.dev_addr == bad_dma_address)
+			continue;
+
+		entry = find_dma_entry(&ref);
+
+		if (check_unmap(&ref, entry)) {
+			remove_dma_entry(entry);
+			dma_entry_free(entry);
+		}
+	}
+
+	spin_unlock_irqrestore(&dma_lock, flags);
+}
+EXPORT_SYMBOL(debug_unmap_sg);
+
-- 
1.5.6.4


