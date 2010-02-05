From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] ssb: replace the dma_sync_single_range_for_cpu/device API
Date: Fri, 5 Feb 2010 14:49:33 +0900
Message-ID: <20100205144920X.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, linville@tuxdriver.com, linux-kernel@vger.kernel.org,
	zambrano@broadcom.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are only two users of the dma_sync_single_range_for_cpu/device
API in mainline (mlx4 and ssb). The
dma_sync_single_range_for_cpu/device API has never been documented and
the dma_sync_single_for_cpu/device API also support a partial sync.

This converts ssb (and b44) to use the dma_sync_single_for_cpu/device
API (preparations for the removal of the
dma_sync_single_range_for_cpu/device API). It also removes unnecessary
ssb_dma_sync_single_range_for_cpu/device.

This lets dma_desc_align_mask alone in b44 but we can remove it since
dma_sync_single_for_cpu/device() rounds up/down safely.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/b44.c       |   10 +++-----
 include/linux/ssb/ssb.h |   51 -----------------------------------------------
 2 files changed, 4 insertions(+), 57 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 44b66be..c3177e3 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -148,9 +148,8 @@ static inline void b44_sync_dma_desc_for_device(struct ssb_device *sdev,
 						unsigned long offset,
 						enum dma_data_direction dir)
 {
-	ssb_dma_sync_single_range_for_device(sdev, dma_base,
-					     offset & dma_desc_align_mask,
-					     dma_desc_sync_size, dir);
+	ssb_dma_sync_single_for_device(sdev, dma_base + (offset & dma_desc_align_mask),
+				       dma_desc_sync_size, dir);
 }
 
 static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
@@ -158,9 +157,8 @@ static inline void b44_sync_dma_desc_for_cpu(struct ssb_device *sdev,
 					     unsigned long offset,
 					     enum dma_data_direction dir)
 {
-	ssb_dma_sync_single_range_for_cpu(sdev, dma_base,
-					  offset & dma_desc_align_mask,
-					  dma_desc_sync_size, dir);
+	ssb_dma_sync_single_for_cpu(sdev, dma_base + (offset & dma_desc_align_mask),
+				    dma_desc_sync_size, dir);
 }
 
 static inline unsigned long br32(const struct b44 *bp, unsigned long reg)
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index 24f9885..e99c5d3 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -580,57 +580,6 @@ static inline void ssb_dma_sync_single_for_device(struct ssb_device *dev,
 	__ssb_dma_not_implemented(dev);
 }
 
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
1.5.6.5
