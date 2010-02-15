From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 5/5] ssb: remove the ssb DMA API
Date: Tue, 16 Feb 2010 00:04:10 +0900
Message-ID: <1266246250-5344-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	Michael Buesch <mb@bu3sch.de>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now they are unnecessary. We can use the generic DMA API with any bus.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Michael Buesch <mb@bu3sch.de>
Cc: Gary Zambrano <zambrano@broadcom.com>
Cc: Stefano Brivio <stefano.brivio@polimi.it>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/ssb/main.c      |   74 ----------------------
 include/linux/ssb/ssb.h |  157 -----------------------------------------------
 2 files changed, 0 insertions(+), 231 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 1a41b3f..1d457e2 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1225,80 +1225,6 @@ u32 ssb_dma_translation(struct ssb_device *dev)
 }
 EXPORT_SYMBOL(ssb_dma_translation);
 
-int ssb_dma_set_mask(struct ssb_device *dev, u64 mask)
-{
-#ifdef CONFIG_SSB_PCIHOST
-	int err;
-#endif
-
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		err = pci_set_dma_mask(dev->bus->host_pci, mask);
-		if (err)
-			return err;
-		err = pci_set_consistent_dma_mask(dev->bus->host_pci, mask);
-		return err;
-#endif
-	case SSB_BUSTYPE_SSB:
-		return dma_set_mask(dev->dev, mask);
-	default:
-		__ssb_dma_not_implemented(dev);
-	}
-	return -ENOSYS;
-}
-EXPORT_SYMBOL(ssb_dma_set_mask);
-
-void * ssb_dma_alloc_consistent(struct ssb_device *dev, size_t size,
-				dma_addr_t *dma_handle, gfp_t gfp_flags)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		if (gfp_flags & GFP_DMA) {
-			/* Workaround: The PCI API does not support passing
-			 * a GFP flag. */
-			return dma_alloc_coherent(&dev->bus->host_pci->dev,
-						  size, dma_handle, gfp_flags);
-		}
-		return pci_alloc_consistent(dev->bus->host_pci, size, dma_handle);
-#endif
-	case SSB_BUSTYPE_SSB:
-		return dma_alloc_coherent(dev->dev, size, dma_handle, gfp_flags);
-	default:
-		__ssb_dma_not_implemented(dev);
-	}
-	return NULL;
-}
-EXPORT_SYMBOL(ssb_dma_alloc_consistent);
-
-void ssb_dma_free_consistent(struct ssb_device *dev, size_t size,
-			     void *vaddr, dma_addr_t dma_handle,
-			     gfp_t gfp_flags)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		if (gfp_flags & GFP_DMA) {
-			/* Workaround: The PCI API does not support passing
-			 * a GFP flag. */
-			dma_free_coherent(&dev->bus->host_pci->dev,
-					  size, vaddr, dma_handle);
-			return;
-		}
-		pci_free_consistent(dev->bus->host_pci, size,
-				    vaddr, dma_handle);
-		return;
-#endif
-	case SSB_BUSTYPE_SSB:
-		dma_free_coherent(dev->dev, size, vaddr, dma_handle);
-		return;
-	default:
-		__ssb_dma_not_implemented(dev);
-	}
-}
-EXPORT_SYMBOL(ssb_dma_free_consistent);
-
 int ssb_bus_may_powerdown(struct ssb_bus *bus)
 {
 	struct ssb_chipcommon *cc;
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index c5e00b2..f7cbf76 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -466,14 +466,6 @@ extern u32 ssb_dma_translation(struct ssb_device *dev);
 #define SSB_DMA_TRANSLATION_MASK	0xC0000000
 #define SSB_DMA_TRANSLATION_SHIFT	30
 
-extern int ssb_dma_set_mask(struct ssb_device *dev, u64 mask);
-
-extern void * ssb_dma_alloc_consistent(struct ssb_device *dev, size_t size,
-				       dma_addr_t *dma_handle, gfp_t gfp_flags);
-extern void ssb_dma_free_consistent(struct ssb_device *dev, size_t size,
-				    void *vaddr, dma_addr_t dma_handle,
-				    gfp_t gfp_flags);
-
 static inline void __cold __ssb_dma_not_implemented(struct ssb_device *dev)
 {
 #ifdef CONFIG_SSB_DEBUG
@@ -482,155 +474,6 @@ static inline void __cold __ssb_dma_not_implemented(struct ssb_device *dev)
 #endif /* DEBUG */
 }
 
-static inline int ssb_dma_mapping_error(struct ssb_device *dev, dma_addr_t addr)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		return pci_dma_mapping_error(dev->bus->host_pci, addr);
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		return dma_mapping_error(dev->dev, addr);
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-	return -ENOSYS;
-}
-
-static inline dma_addr_t ssb_dma_map_single(struct ssb_device *dev, void *p,
-					    size_t size, enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		return pci_map_single(dev->bus->host_pci, p, size, dir);
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		return dma_map_single(dev->dev, p, size, dir);
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-	return 0;
-}
-
-static inline void ssb_dma_unmap_single(struct ssb_device *dev, dma_addr_t dma_addr,
-					size_t size, enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		pci_unmap_single(dev->bus->host_pci, dma_addr, size, dir);
-		return;
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		dma_unmap_single(dev->dev, dma_addr, size, dir);
-		return;
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-}
-
-static inline void ssb_dma_sync_single_for_cpu(struct ssb_device *dev,
-					       dma_addr_t dma_addr,
-					       size_t size,
-					       enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		pci_dma_sync_single_for_cpu(dev->bus->host_pci, dma_addr,
-					    size, dir);
-		return;
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		dma_sync_single_for_cpu(dev->dev, dma_addr, size, dir);
-		return;
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-}
-
-static inline void ssb_dma_sync_single_for_device(struct ssb_device *dev,
-						  dma_addr_t dma_addr,
-						  size_t size,
-						  enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		pci_dma_sync_single_for_device(dev->bus->host_pci, dma_addr,
-					       size, dir);
-		return;
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		dma_sync_single_for_device(dev->dev, dma_addr, size, dir);
-		return;
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-}
-
-static inline void ssb_dma_sync_single_range_for_cpu(struct ssb_device *dev,
-						     dma_addr_t dma_addr,
-						     unsigned long offset,
-						     size_t size,
-						     enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		/* Just sync everything. That's all the PCI API can do. */
-		pci_dma_sync_single_for_cpu(dev->bus->host_pci, dma_addr,
-					    offset + size, dir);
-		return;
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		dma_sync_single_range_for_cpu(dev->dev, dma_addr, offset,
-					      size, dir);
-		return;
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-}
-
-static inline void ssb_dma_sync_single_range_for_device(struct ssb_device *dev,
-							dma_addr_t dma_addr,
-							unsigned long offset,
-							size_t size,
-							enum dma_data_direction dir)
-{
-	switch (dev->bus->bustype) {
-	case SSB_BUSTYPE_PCI:
-#ifdef CONFIG_SSB_PCIHOST
-		/* Just sync everything. That's all the PCI API can do. */
-		pci_dma_sync_single_for_device(dev->bus->host_pci, dma_addr,
-					       offset + size, dir);
-		return;
-#endif
-		break;
-	case SSB_BUSTYPE_SSB:
-		dma_sync_single_range_for_device(dev->dev, dma_addr, offset,
-						 size, dir);
-		return;
-	default:
-		break;
-	}
-	__ssb_dma_not_implemented(dev);
-}
-
-
 #ifdef CONFIG_SSB_PCIHOST
 /* PCI-host wrapper driver */
 extern int ssb_pcihost_register(struct pci_driver *driver);
-- 
1.6.5
