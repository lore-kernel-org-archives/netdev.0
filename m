From: Joerg Roedel <joerg.roedel@amd.com>
Subject: [PATCH 15/16] dma-debug: x86 architecture bindings
Date: Fri, 9 Jan 2009 17:19:29 +0100
Message-ID: <1231517970-20288-16-git-send-email-joerg.roedel@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	Joerg Roedel <joerg.roedel@amd.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-dub.frontbridge.com ([213.199.154.16]:28526 "EHLO
	IE1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbZAIQTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 11:19:50 -0500
In-Reply-To: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: make use of DMA-API debugging code in x86

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 arch/x86/Kconfig                   |    1 +
 arch/x86/include/asm/dma-mapping.h |   30 ++++++++++++++++++++++++++----
 arch/x86/kernel/pci-dma.c          |    5 +++++
 3 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 862adb9..68a806c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -39,6 +39,7 @@ config X86
 	select HAVE_GENERIC_DMA_COHERENT if X86_32
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS
 	select USER_STACKTRACE_SUPPORT
+	select HAVE_DMA_API_DEBUG
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 4035357..939d5b3 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -7,6 +7,7 @@
  */
 
 #include <linux/scatterlist.h>
+#include <linux/dma-debug.h>
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 #include <asm-generic/dma-coherent.h>
@@ -93,9 +94,12 @@ dma_map_single(struct device *hwdev, void *ptr, size_t size,
 	       int direction)
 {
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
+	dma_addr_t addr;
 
 	BUG_ON(!valid_dma_direction(direction));
-	return ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
+	addr = ops->map_single(hwdev, virt_to_phys(ptr), size, direction);
+	debug_map_single(hwdev, ptr, size, direction, addr);
+	return addr;
 }
 
 static inline void
@@ -105,6 +109,7 @@ dma_unmap_single(struct device *dev, dma_addr_t addr, size_t size,
 	struct dma_mapping_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_unmap_single(dev, addr, size, direction);
 	if (ops->unmap_single)
 		ops->unmap_single(dev, addr, size, direction);
 }
@@ -114,9 +119,13 @@ dma_map_sg(struct device *hwdev, struct scatterlist *sg,
 	   int nents, int direction)
 {
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
+	int ret;
 
 	BUG_ON(!valid_dma_direction(direction));
-	return ops->map_sg(hwdev, sg, nents, direction);
+	ret = ops->map_sg(hwdev, sg, nents, direction);
+	debug_map_sg(hwdev, sg, ret, direction);
+
+	return ret;
 }
 
 static inline void
@@ -126,6 +135,7 @@ dma_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_unmap_sg(hwdev, sg, nents, direction);
 	if (ops->unmap_sg)
 		ops->unmap_sg(hwdev, sg, nents, direction);
 }
@@ -137,6 +147,7 @@ dma_sync_single_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_sync_single_for_cpu(hwdev, dma_handle, size, direction);
 	if (ops->sync_single_for_cpu)
 		ops->sync_single_for_cpu(hwdev, dma_handle, size, direction);
 	flush_write_buffers();
@@ -149,6 +160,7 @@ dma_sync_single_for_device(struct device *hwdev, dma_addr_t dma_handle,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_sync_single_for_device(hwdev, dma_handle, size, direction);
 	if (ops->sync_single_for_device)
 		ops->sync_single_for_device(hwdev, dma_handle, size, direction);
 	flush_write_buffers();
@@ -161,6 +173,8 @@ dma_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dma_handle,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_sync_single_range_for_cpu(hwdev, dma_handle, offset, size,
+					direction);
 	if (ops->sync_single_range_for_cpu)
 		ops->sync_single_range_for_cpu(hwdev, dma_handle, offset,
 					       size, direction);
@@ -175,6 +189,8 @@ dma_sync_single_range_for_device(struct device *hwdev, dma_addr_t dma_handle,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+        debug_sync_single_range_for_device(hwdev, dma_handle, offset,
+					   size, direction);
 	if (ops->sync_single_range_for_device)
 		ops->sync_single_range_for_device(hwdev, dma_handle,
 						  offset, size, direction);
@@ -188,6 +204,7 @@ dma_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_sync_sg_for_cpu(hwdev, sg, nelems, direction);
 	if (ops->sync_sg_for_cpu)
 		ops->sync_sg_for_cpu(hwdev, sg, nelems, direction);
 	flush_write_buffers();
@@ -200,6 +217,7 @@ dma_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
 	struct dma_mapping_ops *ops = get_dma_ops(hwdev);
 
 	BUG_ON(!valid_dma_direction(direction));
+	debug_sync_sg_for_device(hwdev, sg, nelems, direction);
 	if (ops->sync_sg_for_device)
 		ops->sync_sg_for_device(hwdev, sg, nelems, direction);
 
@@ -267,7 +285,7 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp)
 {
 	struct dma_mapping_ops *ops = get_dma_ops(dev);
-	void *memory;
+	void *memory, *addr;
 
 	gfp &= ~(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32);
 
@@ -285,8 +303,11 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 	if (!ops->alloc_coherent)
 		return NULL;
 
-	return ops->alloc_coherent(dev, size, dma_handle,
+	addr = ops->alloc_coherent(dev, size, dma_handle,
 				   dma_alloc_coherent_gfp_flags(dev, gfp));
+	debug_alloc_coherent(dev, size, *dma_handle, addr);
+
+	return addr;
 }
 
 static inline void dma_free_coherent(struct device *dev, size_t size,
@@ -299,6 +320,7 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
 	if (dma_release_from_coherent(dev, get_order(size), vaddr))
 		return;
 
+	debug_free_coherent(dev, size, vaddr, bus);
 	if (ops->free_coherent)
 		ops->free_coherent(dev, size, vaddr, bus);
 }
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index b254285..c8efbcc 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -44,6 +44,9 @@ struct device x86_dma_fallback_dev = {
 };
 EXPORT_SYMBOL(x86_dma_fallback_dev);
 
+/* Number of entries preallocated for DMA-API debugging */
+#define PREALLOC_ENTRIES	8192	/* needs 512kb */
+
 int dma_set_mask(struct device *dev, u64 mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, mask))
@@ -265,6 +268,8 @@ EXPORT_SYMBOL(dma_supported);
 
 static int __init pci_iommu_init(void)
 {
+	dma_debug_init(PREALLOC_ENTRIES);
+
 	calgary_iommu_init();
 
 	intel_iommu_init();
-- 
1.5.6.4


