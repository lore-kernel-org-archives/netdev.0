From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 09/10] x86: add checks for sync_single_range* code
Date: Fri, 21 Nov 2008 17:26:09 +0100
Message-ID: <1227284770-19215-10-git-send-email-joerg.roedel@amd.com>
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
	with ESMTP id S1755271AbYKUQ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:26:29 -0500
In-Reply-To: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: detect bugs in sync_single_range* usage

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/include/asm/dma-mapping.h |    4 ++++
 arch/x86/include/asm/dma_debug.h   |   26 ++++++++++++++++++++++++++
 arch/x86/kernel/pci-dma-debug.c    |   17 +++++++++++++++++
 3 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 63bed40..2b6399d 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -185,6 +185,8 @@ dma_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
 	if (ops->sync_single_range_for_cpu)
 		ops->sync_single_range_for_cpu(hwdev, dma_handle, offset,
 					       size, direction);
+	debug_sync_single_range_for_cpu(hwdev, dma_handle, offset,
+					size, direction);
 	flush_write_buffers();
 }
 
@@ -199,6 +201,8 @@ dma_sync_single_range_for_device(struct device *hwdev, dma_addr_t dma_handle,
 	if (ops->sync_single_range_for_device)
 		ops->sync_single_range_for_device(hwdev, dma_handle,
 						  offset, size, direction);
+	debug_sync_single_range_for_device(hwdev, dma_handle, offset,
+					   size, direction);
 	flush_write_buffers();
 }
 
diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
index 8262cd1..bc4a841 100644
--- a/arch/x86/include/asm/dma_debug.h
+++ b/arch/x86/include/asm/dma_debug.h
@@ -75,6 +75,17 @@ extern
 void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
 				  size_t size, int direction);
 
+extern
+void debug_sync_single_range_for_cpu(struct device *dev, dma_addr_t dma_handle,
+				     unsigned long offset, size_t size,
+				     int direction);
+
+extern
+void debug_sync_single_range_for_device(struct device *dev,
+					dma_addr_t dma_handle,
+					unsigned long offset,
+					size_t size, int direction);
+
 #else /* CONFIG_DMA_API_DEBUG */
 
 static inline
@@ -130,6 +141,21 @@ void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
 {
 }
 
+static inline
+void debug_sync_single_range_for_cpu(struct device *dev, dma_addr_t dma_handle,
+				     unsigned long offset, size_t size,
+				     int direction)
+{
+}
+
+static inline
+void debug_sync_single_range_for_device(struct device *dev,
+					dma_addr_t dma_handle,
+					unsigned long offset,
+					size_t size, int direction)
+{
+}
+
 #endif /* CONFIG_DMA_API_DEBUG */
 
 #endif /* __ASM_X86_DMA_DEBUG */
diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
index 1dfcd33..92b9491 100644
--- a/arch/x86/kernel/pci-dma-debug.c
+++ b/arch/x86/kernel/pci-dma-debug.c
@@ -422,3 +422,20 @@ void debug_sync_single_for_device(struct device *dev, dma_addr_t dma_handle,
 }
 EXPORT_SYMBOL(debug_sync_single_for_device);
 
+void debug_sync_single_range_for_cpu(struct device *dev, dma_addr_t dma_handle,
+				     unsigned long offset, size_t size,
+				     int direction)
+{
+	check_sync(dev, dma_handle, size, offset, direction, true);
+}
+EXPORT_SYMBOL(debug_sync_single_range_for_cpu);
+
+void debug_sync_single_range_for_device(struct device *dev,
+					dma_addr_t dma_handle,
+					unsigned long offset,
+					size_t size, int direction)
+{
+	check_sync(dev, dma_handle, size, offset, direction, false);
+}
+EXPORT_SYMBOL(debug_sync_single_range_for_device);
+
-- 
1.5.6.4


