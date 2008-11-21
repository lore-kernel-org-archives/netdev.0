From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 08/10] x86: add checks for sync_single* code
Date: Fri, 21 Nov 2008 17:26:08 +0100
Message-ID: <1227284770-19215-9-git-send-email-joerg.roedel@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:3152 "EHLO
	VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbYKUQ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:29 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: detect bugs in sync_single* usage

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/include/asm/dma-mapping.h |    2 ++
 arch/x86/include/asm/dma_debug.h   |   20 ++++++++++++++++++++
 arch/x86/kernel/pci-dma-debug.c    |   14 ++++++++++++++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 2893adb..63bed40 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -158,6 +158,7 @@ dma_sync_single_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
 	BUG_ON(!valid_dma_direction(direction));
 	if (ops->sync_single_for_cpu)
 		ops->sync_single_for_cpu(hwdev, dma_handle, size, direction);
+	debug_sync_single_for_cpu(hwdev, dma_handle, size, direction);
 	flush_write_buffers();
 }
 
@@ -170,6 +171,7 @@ dma_sync_single_for_device(struct device *hwdev, dma_addr_t dma_handle,
 	BUG_ON(!valid_dma_direction(direction));
 	if (ops->sync_single_for_device)
 		ops->sync_single_for_device(hwdev, dma_handle, size, direction);
+	debug_sync_single_for_device(hwdev, dma_handle, size, direction);
 	flush_write_buffers();
 }
 
diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
index 7245e27..8262cd1 100644
--- a/arch/x86/include/asm/dma_debug.h
+++ b/arch/x86/include/asm/dma_debug.h
@@ -67,6 +67,14 @@ extern
 void debug_free_coherent(struct device *dev, size_t size,
 			 void *virt, dma_addr_t addr);
 
+extern
+void debug_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
+			       size_t size, int direction);
+
+extern
+void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
+				  size_t size, int direction);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline
@@ -110,6 +118,18 @@ void debug_free_coherent(struct device *dev, size_t size,
 {
 }
 
+static inline
+void debug_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
+			       size_t size, int direction)
+{
+}
+
+static inline
+void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
+				  size_t size, int direction)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __ASM_X86_DMA_DEBUG */
diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
index db5ef9a..1dfcd33 100644
--- a/arch/x86/kernel/pci-dma-debug.c
+++ b/arch/x86/kernel/pci-dma-debug.c
@@ -408,3 +408,17 @@ void debug_free_coherent(struct device *dev, size_t size,
 }
 EXPORT_SYMBOL(debug_free_coherent);
 
+void debug_sync_single_for_cpu(struct device *dev, dma_addr_t dma_handle,
+			       size_t size, int direction)
+{
+	check_sync(dev, dma_handle, size, 0, direction, true);
+}
+EXPORT_SYMBOL(debug_sync_single_for_cpu);
+
+void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
+				  size_t size, int direction)
+{
+	check_sync(dev, dma_handle, size, 0, direction, false);
+}
+EXPORT_SYMBOL(debug_sync_single_for_device);
+
-- 
1.5.6.4


