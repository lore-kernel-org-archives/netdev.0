From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 10/10] x86: add checks for sync_sg* code
Date: Fri, 21 Nov 2008 17:26:10 +0100
Message-ID: <1227284770-19215-11-git-send-email-joerg.roedel@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:3687 "EHLO
	SG2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbYKUQ0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:40 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: detect bugs in sync_sg* usage

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/include/asm/dma-mapping.h |    2 ++
 arch/x86/include/asm/dma_debug.h   |   20 ++++++++++++++++++++
 arch/x86/kernel/pci-dma-debug.c    |   24 ++++++++++++++++++++++++
 3 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 2b6399d..6a580e9 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -215,6 +215,7 @@ dma_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
 	BUG_ON(!valid_dma_direction(direction));
 	if (ops->sync_sg_for_cpu)
 		ops->sync_sg_for_cpu(hwdev, sg, nelems, direction);
+	debug_sync_sg_for_cpu(hwdev, sg, nelems, direction);
 	flush_write_buffers();
 }
 
@@ -227,6 +228,7 @@ dma_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
 	BUG_ON(!valid_dma_direction(direction));
 	if (ops->sync_sg_for_device)
 		ops->sync_sg_for_device(hwdev, sg, nelems, direction);
+	debug_sync_sg_for_device(hwdev, sg, nelems, direction);
 
 	flush_write_buffers();
 }
diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
index bc4a841..b30d3c9 100644
--- a/arch/x86/include/asm/dma_debug.h
+++ b/arch/x86/include/asm/dma_debug.h
@@ -86,6 +86,14 @@ void debug_sync_single_range_for_device(struct device *dev,
 					unsigned long offset,
 					size_t size, int direction);
 
+extern
+void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+			   int nelems, int direction);
+
+extern
+void debug_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+			      int nelems, int direction);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline
@@ -156,6 +164,18 @@ void debug_sync_single_range_for_device(struct device *dev,
 {
 }
 
+static inline
+void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+			   int nelems, int direction)
+{
+}
+
+static inline
+void debug_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+			      int nelems, int direction)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __ASM_X86_DMA_DEBUG */
diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
index 92b9491..ac8e1f9 100644
--- a/arch/x86/kernel/pci-dma-debug.c
+++ b/arch/x86/kernel/pci-dma-debug.c
@@ -439,3 +439,27 @@ void debug_sync_single_range_for_device(struct device *dev,
 }
 EXPORT_SYMBOL(debug_sync_single_range_for_device);
 
+void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+			   int nelems, int direction)
+{
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nelems, i)
+		check_sync(dev, s->dma_address, s->dma_length, 0,
+			   direction, true);
+}
+EXPORT_SYMBOL(debug_sync_sg_for_cpu);
+
+void debug_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+			      int nelems, int direction)
+{
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nelems, i)
+		check_sync(dev, s->dma_address, s->dma_length, 0,
+			   direction, false);
+}
+EXPORT_SYMBOL(debug_sync_sg_for_device);
+
-- 
1.5.6.4


