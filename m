From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 14:21:58 +0900
Message-ID: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de, davem@davemloft.net,
	stefano.brivio@polimi.it, Larry.Finger@lwfinger.net,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:33804 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268Ab0BOFW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 00:22:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is against -mm since it depends on the DMA API changes in
-mm.

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm] ssb: open-code dma_alloc_coherent

This removes ssb_dma_alloc_consistent, a wrapper for
dma_alloc_coherent and pci_alloc_consistent. dma_alloc_coherent
internally calls pci_alloc_consistent against pci devices so we always
use dma_alloc_coherent.

I prefer to use the DMA API directly instead of creating the ssb_dma_
API. We have been removing any bus specific DMA APIs.

One disadvantage of this approach that we lost the debugging ability
of checking the buggy usage of the DMA API against non DMA-capable ssb
buses. But I guess that the ssb drivers are mature enough and can cope
with such change?

I plan to replace all the ssb_dma API if this approach is fine.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Michael Buesch <mb@bu3sch.de>
Cc: Gary Zambrano <zambrano@broadcom.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Stefano Brivio <stefano.brivio@polimi.it>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/b44.c                    |    4 ++--
 drivers/net/wireless/b43/dma.c       |    6 +++---
 drivers/net/wireless/b43legacy/dma.c |    8 ++++----
 drivers/ssb/main.c                   |   25 ++-----------------------
 include/linux/ssb/ssb.h              |    2 +-
 5 files changed, 12 insertions(+), 33 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 16e760b..dbe7480 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1182,7 +1182,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		goto out_err;
 
 	size = DMA_TABLE_BYTES;
-	bp->rx_ring = ssb_dma_alloc_consistent(bp->sdev, size, &bp->rx_ring_dma, gfp);
+	bp->rx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->rx_ring_dma, gfp);
 	if (!bp->rx_ring) {
 		/* Allocation may have failed due to pci_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
@@ -1209,7 +1209,7 @@ static int b44_alloc_consistent(struct b44 *bp, gfp_t gfp)
 		bp->flags |= B44_FLAG_RX_RING_HACK;
 	}
 
-	bp->tx_ring = ssb_dma_alloc_consistent(bp->sdev, size, &bp->tx_ring_dma, gfp);
+	bp->tx_ring = dma_alloc_coherent(bp->sdev->dma_dev, size, &bp->tx_ring_dma, gfp);
 	if (!bp->tx_ring) {
 		/* Allocation may have failed due to ssb_dma_alloc_consistent
 		   insisting on use of GFP_DMA, which is more restrictive
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index be7abf8..b5e00dd 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -400,9 +400,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 	 */
 	if (ring->type == B43_DMA_64BIT)
 		flags |= GFP_DMA;
-	ring->descbase = ssb_dma_alloc_consistent(ring->dev->dev,
-						  B43_DMA_RINGMEMSIZE,
-						  &(ring->dmabase), flags);
+	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
+					      B43_DMA_RINGMEMSIZE,
+					      &(ring->dmabase), flags);
 	if (!ring->descbase) {
 		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 8b9387c..4942f10 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -459,10 +459,10 @@ void free_descriptor_buffer(struct b43legacy_dmaring *ring,
 static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 {
 	/* GFP flags must match the flags in free_ringmemory()! */
-	ring->descbase = ssb_dma_alloc_consistent(ring->dev->dev,
-						  B43legacy_DMA_RINGMEMSIZE,
-						  &(ring->dmabase),
-						  GFP_KERNEL);
+	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
+					    B43legacy_DMA_RINGMEMSIZE,
+					    &(ring->dmabase),
+					    GFP_KERNEL);
 	if (!ring->descbase) {
 		b43legacyerr(ring->dev->wl, "DMA ringmemory allocation"
 			     " failed\n");
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 03dfd27..d823041 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -485,6 +485,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 #ifdef CONFIG_SSB_PCIHOST
 			sdev->irq = bus->host_pci->irq;
 			dev->parent = &bus->host_pci->dev;
+			sdev->dma_dev = dev->parent;
 #endif
 			break;
 		case SSB_BUSTYPE_PCMCIA:
@@ -500,6 +501,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 			break;
 		case SSB_BUSTYPE_SSB:
 			dev->dma_mask = &dev->coherent_dma_mask;
+			sdev->dma_dev = dev;
 			break;
 		}
 
@@ -1246,29 +1248,6 @@ int ssb_dma_set_mask(struct ssb_device *dev, u64 mask)
 }
 EXPORT_SYMBOL(ssb_dma_set_mask);
 
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
 void ssb_dma_free_consistent(struct ssb_device *dev, size_t size,
 			     void *vaddr, dma_addr_t dma_handle,
 			     gfp_t gfp_flags)
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index e99c5d3..4604ee5 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -167,7 +167,7 @@ struct ssb_device {
 	 * is an optimization. */
 	const struct ssb_bus_ops *ops;
 
-	struct device *dev;
+	struct device *dev, *dma_dev;
 
 	struct ssb_bus *bus;
 	struct ssb_device_id id;
-- 
1.6.5

