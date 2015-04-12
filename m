From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v3 4/9] bgmac: simplify rx DMA error handling
Date: Sun, 12 Apr 2015 23:38:26 +0200
Message-ID: <1428874711-23950-4-git-send-email-nbd@openwrt.org>
References: <1428874711-23950-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:48620
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752628AbbDLVih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 17:38:37 -0400
In-Reply-To: <1428874711-23950-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unmap the DMA buffer before checking it. If it is poisoned, map it again
and pass it back to the hardware.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e332de8..e004588 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -405,25 +405,20 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 		u16 len, flags;
 
 		/* Unmap buffer to make it accessible to the CPU */
-		dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
-					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+		dma_unmap_single(dma_dev, slot->dma_addr,
+				 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
 		/* Get info from the header */
 		len = le16_to_cpu(rx->len);
 		flags = le16_to_cpu(rx->flags);
 
 		do {
-			dma_addr_t old_dma_addr = slot->dma_addr;
 			int err;
 
 			/* Check for poison and drop or pass the packet */
 			if (len == 0xdead && flags == 0xbeef) {
 				bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
 					  ring->start);
-				dma_sync_single_for_device(dma_dev,
-							   slot->dma_addr,
-							   BGMAC_RX_BUF_SIZE,
-							   DMA_FROM_DEVICE);
 				break;
 			}
 
@@ -436,18 +431,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 				/* Poison the old skb */
 				rx->len = cpu_to_le16(0xdead);
 				rx->flags = cpu_to_le16(0xbeef);
-
-				dma_sync_single_for_device(dma_dev,
-							   slot->dma_addr,
-							   BGMAC_RX_BUF_SIZE,
-							   DMA_FROM_DEVICE);
 				break;
 			}
-			bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
-
-			/* Unmap old skb, we'll pass it to the netfif */
-			dma_unmap_single(dma_dev, old_dma_addr,
-					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
 			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
 			skb_put(skb, BGMAC_RX_FRAME_OFFSET +
@@ -461,6 +446,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			handled++;
 		} while (0);
 
+		bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
+
 		if (++ring->start >= BGMAC_RX_RING_SLOTS)
 			ring->start = 0;
 
-- 
2.2.2
