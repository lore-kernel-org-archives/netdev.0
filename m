From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 17/44] hexagon: switch to use ->mapping_error for error reporting
Date: Thu,  8 Jun 2017 15:25:42 +0200
Message-ID: <20170608132609.32662-18-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
        linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
        linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
        linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608132609.32662-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
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
