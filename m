From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Support DMA-API debugging facility on PowerPC
Date: Wed, 01 Jul 2009 14:19:40 +0100
Message-ID: <1246454380.3681.1634.camel@macbook.infradead.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	 <1227286492.4901.208.camel@macbook.infradead.org>
	 <20081121165722.GD1386@amd.com>
	 <1227287215.4901.213.camel@macbook.infradead.org>
	 <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com>
	 <1227288269.4901.222.camel@macbook.infradead.org>
	 <20081121172722.GG1386@amd.com>
	 <1233873842.8135.6.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <joerg.roedel@amd.com>, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59473 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbZGANTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 09:19:44 -0400
In-Reply-To: <1233873842.8135.6.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Tested-by: Johannes Berg <johannes@sipsolutions.net>
---
Some fixing from Johannes to make it apply to a current kernel...

 arch/powerpc/Kconfig                   |    1 
 arch/powerpc/include/asm/dma-mapping.h |   47 ++++++++++++++++++++++++++++++---
 arch/powerpc/kernel/dma.c              |   11 +++++++
 3 files changed, 55 insertions(+), 4 deletions(-)

--- wireless-testing.orig/arch/powerpc/include/asm/dma-mapping.h	2009-07-01 12:58:01.691534801 +0200
+++ wireless-testing/arch/powerpc/include/asm/dma-mapping.h	2009-07-01 13:17:47.965537743 +0200
@@ -13,6 +13,7 @@
 /* need struct page definitions */
 #include <linux/mm.h>
 #include <linux/scatterlist.h>
+#include <linux/dma-debug.h>
 #include <linux/dma-attrs.h>
 #include <asm/io.h>
 #include <asm/swiotlb.h>
@@ -173,12 +174,17 @@ static inline dma_addr_t dma_map_single_
 					      struct dma_attrs *attrs)
 {
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
+	dma_addr_t addr;
 
 	BUG_ON(!dma_ops);
 
-	return dma_ops->map_page(dev, virt_to_page(cpu_addr),
+	addr = dma_ops->map_page(dev, virt_to_page(cpu_addr),
 				 (unsigned long)cpu_addr % PAGE_SIZE, size,
 				 direction, attrs);
+	debug_dma_map_page(dev, virt_to_page(cpu_addr),
+			   (unsigned long)cpu_addr & PAGE_SIZE, size,
+			   direction, addr, true);
+	return addr;
 }
 
 static inline void dma_unmap_single_attrs(struct device *dev,
@@ -192,6 +198,7 @@ static inline void dma_unmap_single_attr
 	BUG_ON(!dma_ops);
 
 	dma_ops->unmap_page(dev, dma_addr, size, direction, attrs);
+	debug_dma_unmap_page(dev, dma_addr, size, direction, true);
 }
 
 static inline dma_addr_t dma_map_page_attrs(struct device *dev,
@@ -201,10 +208,13 @@ static inline dma_addr_t dma_map_page_at
 					    struct dma_attrs *attrs)
 {
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
+	dma_addr_t addr;
 
 	BUG_ON(!dma_ops);
 
-	return dma_ops->map_page(dev, page, offset, size, direction, attrs);
+	addr = dma_ops->map_page(dev, page, offset, size, direction, attrs);
+	debug_dma_map_page(dev, page, offset, size, direction, addr, false);
+	return addr;
 }
 
 static inline void dma_unmap_page_attrs(struct device *dev,
@@ -218,6 +228,7 @@ static inline void dma_unmap_page_attrs(
 	BUG_ON(!dma_ops);
 
 	dma_ops->unmap_page(dev, dma_address, size, direction, attrs);
+	debug_dma_unmap_page(dev, dma_address, size, direction, false);
 }
 
 static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
@@ -225,9 +236,12 @@ static inline int dma_map_sg_attrs(struc
 				   struct dma_attrs *attrs)
 {
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
+	int ents;
 
 	BUG_ON(!dma_ops);
-	return dma_ops->map_sg(dev, sg, nents, direction, attrs);
+	ents = dma_ops->map_sg(dev, sg, nents, direction, attrs);
+	debug_dma_map_sg(dev, sg, nents, ents, direction);
+	return ents;
 }
 
 static inline void dma_unmap_sg_attrs(struct device *dev,
@@ -240,15 +254,19 @@ static inline void dma_unmap_sg_attrs(st
 
 	BUG_ON(!dma_ops);
 	dma_ops->unmap_sg(dev, sg, nhwentries, direction, attrs);
+	debug_dma_unmap_sg(dev, sg, nhwentries, direction);
 }
 
 static inline void *dma_alloc_coherent(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag)
 {
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
+	void *mem;
 
 	BUG_ON(!dma_ops);
-	return dma_ops->alloc_coherent(dev, size, dma_handle, flag);
+	mem = dma_ops->alloc_coherent(dev, size, dma_handle, flag);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, mem);
+	return mem;
 }
 
 static inline void dma_free_coherent(struct device *dev, size_t size,
@@ -257,6 +275,7 @@ static inline void dma_free_coherent(str
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
 	dma_ops->free_coherent(dev, size, cpu_addr, dma_handle);
 }
 
@@ -309,6 +328,8 @@ static inline void dma_sync_single_for_c
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_single_range_for_cpu(dev, dma_handle, 0,
+					    size, direction);
 	dma_ops->sync_single_range_for_cpu(dev, dma_handle, 0,
 					   size, direction);
 }
@@ -320,6 +341,8 @@ static inline void dma_sync_single_for_d
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_single_range_for_device(dev, dma_handle,
+					       0, size, direction);
 	dma_ops->sync_single_range_for_device(dev, dma_handle,
 					      0, size, direction);
 }
@@ -331,6 +354,7 @@ static inline void dma_sync_sg_for_cpu(s
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_sg_for_cpu(dev, sgl, nents, direction);
 	dma_ops->sync_sg_for_cpu(dev, sgl, nents, direction);
 }
 
@@ -341,6 +365,7 @@ static inline void dma_sync_sg_for_devic
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_sg_for_device(dev, sgl, nents, direction);
 	dma_ops->sync_sg_for_device(dev, sgl, nents, direction);
 }
 
@@ -351,6 +376,8 @@ static inline void dma_sync_single_range
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_single_range_for_cpu(dev, dma_handle,
+					    offset, size, direction);
 	dma_ops->sync_single_range_for_cpu(dev, dma_handle,
 					   offset, size, direction);
 }
@@ -362,6 +389,8 @@ static inline void dma_sync_single_range
 	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
 
 	BUG_ON(!dma_ops);
+	debug_dma_sync_single_range_for_device(dev, dma_handle, offset,
+					       size, direction);
 	dma_ops->sync_single_range_for_device(dev, dma_handle, offset,
 					      size, direction);
 }
@@ -370,36 +399,46 @@ static inline void dma_sync_single_for_c
 		dma_addr_t dma_handle, size_t size,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_single_range_for_cpu(dev, dma_handle, 0,
+					    size, direction);
 }
 
 static inline void dma_sync_single_for_device(struct device *dev,
 		dma_addr_t dma_handle, size_t size,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_single_range_for_device(dev, dma_handle,
+					       0, size, direction);
 }
 
 static inline void dma_sync_sg_for_cpu(struct device *dev,
 		struct scatterlist *sgl, int nents,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_sg_for_cpu(dev, sgl, nents, direction);
 }
 
 static inline void dma_sync_sg_for_device(struct device *dev,
 		struct scatterlist *sgl, int nents,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_sg_for_device(dev, sgl, nents, direction);
 }
 
 static inline void dma_sync_single_range_for_cpu(struct device *dev,
 		dma_addr_t dma_handle, unsigned long offset, size_t size,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_single_range_for_cpu(dev, dma_handle,
+					    offset, size, direction);
 }
 
 static inline void dma_sync_single_range_for_device(struct device *dev,
 		dma_addr_t dma_handle, unsigned long offset, size_t size,
 		enum dma_data_direction direction)
 {
+	debug_dma_sync_single_range_for_device(dev, dma_handle, offset,
+					       size, direction);
 }
 #endif
 
--- wireless-testing.orig/arch/powerpc/kernel/dma.c	2009-07-01 12:58:01.853767180 +0200
+++ wireless-testing/arch/powerpc/kernel/dma.c	2009-07-01 13:15:49.153787540 +0200
@@ -6,7 +6,9 @@
  */
 
 #include <linux/device.h>
+#include <linux/dma-debug.h>
 #include <linux/dma-mapping.h>
+#include <linux/init.h>
 #include <asm/bug.h>
 #include <asm/abs_addr.h>
 
@@ -156,3 +158,12 @@ struct dma_mapping_ops dma_direct_ops = 
 #endif
 };
 EXPORT_SYMBOL(dma_direct_ops);
+
+#define PREALLOC_DMA_DEBUG_ENTRIES		8192
+
+static int __init dma_debug_init_ppc(void)
+{
+	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
+	return 0;
+}
+fs_initcall(dma_debug_init_ppc);
--- wireless-testing.orig/arch/powerpc/Kconfig	2009-07-01 13:15:51.739536241 +0200
+++ wireless-testing/arch/powerpc/Kconfig	2009-07-01 13:16:11.429788207 +0200
@@ -127,6 +127,7 @@ config PPC
 	select HAVE_SYSCALL_WRAPPERS if PPC64
 	select GENERIC_ATOMIC64 if PPC32
 	select HAVE_PERF_COUNTERS
+	select HAVE_DMA_API_DEBUG
 
 config EARLY_PRINTK
 	bool


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

