From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/11] dma-mapping: replace dmam_alloc_noncoherent with dmam_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:07 +0200
Message-ID: <20170616071716.17321-3-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:60924 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752564AbdFPHRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:17:30 -0400
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dmam_alloc_noncoherent is a trivial wrapper around dmam_alloc_attrs,
that hardcodes one particular flag.  Make the devres code more
flexible by allowing the callers to pass arbitrary flags.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/driver-model/devres.txt |  2 +-
 drivers/base/dma-mapping.c            | 36 ++++++++++++++++-------------------
 drivers/video/fbdev/au1200fb.c        |  5 +++--
 include/linux/dma-mapping.h           |  5 +++--
 4 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/Documentation/driver-model/devres.txt b/Documentation/driver-model/devres.txt
index 9070ff06b558..7e08c02b5393 100644
--- a/Documentation/driver-model/devres.txt
+++ b/Documentation/driver-model/devres.txt
@@ -240,7 +240,7 @@ CLOCK
 
 DMA
   dmam_alloc_coherent()
-  dmam_alloc_noncoherent()
+  dmam_alloc_attrs()
   dmam_declare_coherent_memory()
   dmam_free_coherent()
   dmam_pool_create()
diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 5940c9dace36..10e7c022e8cf 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -22,20 +22,15 @@ struct dma_devres {
 	size_t		size;
 	void		*vaddr;
 	dma_addr_t	dma_handle;
+	unsigned long	attrs;
 };
 
-static void dmam_coherent_release(struct device *dev, void *res)
+static void dmam_release(struct device *dev, void *res)
 {
 	struct dma_devres *this = res;
 
-	dma_free_coherent(dev, this->size, this->vaddr, this->dma_handle);
-}
-
-static void dmam_noncoherent_release(struct device *dev, void *res)
-{
-	struct dma_devres *this = res;
-
-	dma_free_noncoherent(dev, this->size, this->vaddr, this->dma_handle);
+	dma_free_attrs(dev, this->size, this->vaddr, this->dma_handle,
+			this->attrs);
 }
 
 static int dmam_match(struct device *dev, void *res, void *match_data)
@@ -69,7 +64,7 @@ void *dmam_alloc_coherent(struct device *dev, size_t size,
 	struct dma_devres *dr;
 	void *vaddr;
 
-	dr = devres_alloc(dmam_coherent_release, sizeof(*dr), gfp);
+	dr = devres_alloc(dmam_release, sizeof(*dr), gfp);
 	if (!dr)
 		return NULL;
 
@@ -104,35 +99,35 @@ void dmam_free_coherent(struct device *dev, size_t size, void *vaddr,
 	struct dma_devres match_data = { size, vaddr, dma_handle };
 
 	dma_free_coherent(dev, size, vaddr, dma_handle);
-	WARN_ON(devres_destroy(dev, dmam_coherent_release, dmam_match,
-			       &match_data));
+	WARN_ON(devres_destroy(dev, dmam_release, dmam_match, &match_data));
 }
 EXPORT_SYMBOL(dmam_free_coherent);
 
 /**
- * dmam_alloc_non_coherent - Managed dma_alloc_noncoherent()
+ * dmam_alloc_attrs - Managed dma_alloc_attrs()
  * @dev: Device to allocate non_coherent memory for
  * @size: Size of allocation
  * @dma_handle: Out argument for allocated DMA handle
  * @gfp: Allocation flags
+ * @attrs: Flags in the DMA_ATTR_* namespace.
  *
- * Managed dma_alloc_noncoherent().  Memory allocated using this
- * function will be automatically released on driver detach.
+ * Managed dma_alloc_attrs().  Memory allocated using this function will be
+ * automatically released on driver detach.
  *
  * RETURNS:
  * Pointer to allocated memory on success, NULL on failure.
  */
-void *dmam_alloc_noncoherent(struct device *dev, size_t size,
-			     dma_addr_t *dma_handle, gfp_t gfp)
+void *dmam_alloc_attrs(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, unsigned long attrs)
 {
 	struct dma_devres *dr;
 	void *vaddr;
 
-	dr = devres_alloc(dmam_noncoherent_release, sizeof(*dr), gfp);
+	dr = devres_alloc(dmam_release, sizeof(*dr), gfp);
 	if (!dr)
 		return NULL;
 
-	vaddr = dma_alloc_noncoherent(dev, size, dma_handle, gfp);
+	vaddr = dma_alloc_attrs(dev, size, dma_handle, gfp, attrs);
 	if (!vaddr) {
 		devres_free(dr);
 		return NULL;
@@ -141,12 +136,13 @@ void *dmam_alloc_noncoherent(struct device *dev, size_t size,
 	dr->vaddr = vaddr;
 	dr->dma_handle = *dma_handle;
 	dr->size = size;
+	dr->attrs = attrs;
 
 	devres_add(dev, dr);
 
 	return vaddr;
 }
-EXPORT_SYMBOL(dmam_alloc_noncoherent);
+EXPORT_SYMBOL(dmam_alloc_attrs);
 
 #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
 
diff --git a/drivers/video/fbdev/au1200fb.c b/drivers/video/fbdev/au1200fb.c
index 6c2b2ca4a909..5f04b4096c42 100644
--- a/drivers/video/fbdev/au1200fb.c
+++ b/drivers/video/fbdev/au1200fb.c
@@ -1694,9 +1694,10 @@ static int au1200fb_drv_probe(struct platform_device *dev)
 		/* Allocate the framebuffer to the maximum screen size */
 		fbdev->fb_len = (win->w[plane].xres * win->w[plane].yres * bpp) / 8;
 
-		fbdev->fb_mem = dmam_alloc_noncoherent(&dev->dev,
+		fbdev->fb_mem = dmam_alloc_attrs(&dev->dev,
 				PAGE_ALIGN(fbdev->fb_len),
-				&fbdev->fb_phys, GFP_KERNEL);
+				&fbdev->fb_phys, GFP_KERNEL,
+				DMA_ATTR_NON_CONSISTENT);
 		if (!fbdev->fb_mem) {
 			print_err("fail to allocate frambuffer (size: %dK))",
 				  fbdev->fb_len / 1024);
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 830ec5f06a4f..6cdf5634906d 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -747,8 +747,9 @@ extern void *dmam_alloc_coherent(struct device *dev, size_t size,
 				 dma_addr_t *dma_handle, gfp_t gfp);
 extern void dmam_free_coherent(struct device *dev, size_t size, void *vaddr,
 			       dma_addr_t dma_handle);
-extern void *dmam_alloc_noncoherent(struct device *dev, size_t size,
-				    dma_addr_t *dma_handle, gfp_t gfp);
+extern void *dmam_alloc_attrs(struct device *dev, size_t size,
+			      dma_addr_t *dma_handle, gfp_t gfp,
+			      unsigned long attrs);
 #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
 extern int dmam_declare_coherent_memory(struct device *dev,
 					phys_addr_t phys_addr,
-- 
2.11.0
