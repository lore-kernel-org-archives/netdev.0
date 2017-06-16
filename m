From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/44] hexagon: switch to use ->mapping_error for error reporting
Date: Fri, 16 Jun 2017 20:10:32 +0200
Message-ID: <20170616181059.19206-18-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Richard Kuo <rkuo@codeaurora.org>
---
 arch/hexagon/include/asm/dma-mapping.h |  2 --
 arch/hexagon/kernel/dma.c              | 12 +++++++++---
 arch/hexagon/kernel/hexagon_ksyms.c    |  1 -
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/hexagon/include/asm/dma-mapping.h b/arch/hexagon/include/asm/dma-mapping.h
index d3a87bd9b686..00e3f10113b0 100644
--- a/arch/hexagon/include/asm/dma-mapping.h
+++ b/arch/hexagon/include/asm/dma-mapping.h
@@ -29,8 +29,6 @@
 #include <asm/io.h>
 
 struct device;
-extern int bad_dma_address;
-#define DMA_ERROR_CODE bad_dma_address
 
 extern const struct dma_map_ops *dma_ops;
 
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index e74b65009587..71269dc0f225 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -25,11 +25,11 @@
 #include <linux/module.h>
 #include <asm/page.h>
 
+#define HEXAGON_MAPPING_ERROR	0
+
 const struct dma_map_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
-int bad_dma_address;  /*  globals are automatically initialized to zero  */
-
 static inline void *dma_addr_to_virt(dma_addr_t dma_addr)
 {
 	return phys_to_virt((unsigned long) dma_addr);
@@ -181,7 +181,7 @@ static dma_addr_t hexagon_map_page(struct device *dev, struct page *page,
 	WARN_ON(size == 0);
 
 	if (!check_addr("map_single", dev, bus, size))
-		return bad_dma_address;
+		return HEXAGON_MAPPING_ERROR;
 
 	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
 		dma_sync(dma_addr_to_virt(bus), size, dir);
@@ -203,6 +203,11 @@ static void hexagon_sync_single_for_device(struct device *dev,
 	dma_sync(dma_addr_to_virt(dma_handle), size, dir);
 }
 
+static int hexagon_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == HEXAGON_MAPPING_ERROR;
+}
+
 const struct dma_map_ops hexagon_dma_ops = {
 	.alloc		= hexagon_dma_alloc_coherent,
 	.free		= hexagon_free_coherent,
@@ -210,6 +215,7 @@ const struct dma_map_ops hexagon_dma_ops = {
 	.map_page	= hexagon_map_page,
 	.sync_single_for_cpu = hexagon_sync_single_for_cpu,
 	.sync_single_for_device = hexagon_sync_single_for_device,
+	.mapping_error	= hexagon_mapping_error;
 	.is_phys	= 1,
 };
 
diff --git a/arch/hexagon/kernel/hexagon_ksyms.c b/arch/hexagon/kernel/hexagon_ksyms.c
index 00bcad9cbd8f..aa248f595431 100644
--- a/arch/hexagon/kernel/hexagon_ksyms.c
+++ b/arch/hexagon/kernel/hexagon_ksyms.c
@@ -40,7 +40,6 @@ EXPORT_SYMBOL(memset);
 /* Additional variables */
 EXPORT_SYMBOL(__phys_offset);
 EXPORT_SYMBOL(_dflt_cache_att);
-EXPORT_SYMBOL(bad_dma_address);
 
 #define DECLARE_EXPORT(name)     \
 	extern void name(void); EXPORT_SYMBOL(name)
-- 
2.11.0

