From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v5 4/9] bgmac: simplify rx DMA error handling
Date: Mon, 13 Apr 2015 19:27:42 +0200
Message-ID: <1428946067-75650-4-git-send-email-nbd@openwrt.org>
References: <1428946067-75650-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51989
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753427AbbDMR1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:27:51 -0400
In-Reply-To: <1428946067-75650-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unmap the DMA buffer before checking it. If an error occurs, free the
buffer and allocate a new one. If allocation or mapping fails, retry as
long as there is NAPI poll budget left (count every attempt instead of
every frame).

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 56 +++++++++++++----------------------
 1 file changed, 20 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 9a6742e..1916ebc 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -404,51 +404,33 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 		void *buf = slot->buf;
 		u16 len, flags;
 
-		/* Unmap buffer to make it accessible to the CPU */
-		dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
-					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
-
-		/* Get info from the header */
-		len = le16_to_cpu(rx->len);
-		flags = le16_to_cpu(rx->flags);
+		if (++handled >= weight - 1) /* Should never be greater */
+			break;
 
 		do {
-			dma_addr_t old_dma_addr = slot->dma_addr;
-			int err;
+			if (!slot->dma_addr)
+				break;
+
+			/* Unmap buffer to make it accessible to the CPU */
+			dma_unmap_single(dma_dev, slot->dma_addr,
+					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+			slot->dma_addr = 0;
+
+			/* Get info from the header */
+			len = le16_to_cpu(rx->len);
+			flags = le16_to_cpu(rx->flags);
 
 			/* Check for poison and drop or pass the packet */
 			if (len == 0xdead && flags == 0xbeef) {
 				bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
 					  ring->start);
-				dma_sync_single_for_device(dma_dev,
-							   slot->dma_addr,
-							   BGMAC_RX_BUF_SIZE,
-							   DMA_FROM_DEVICE);
+				kfree(buf);
 				break;
 			}
 
 			/* Omit CRC. */
 			len -= ETH_FCS_LEN;
 
-			/* Prepare new skb as replacement */
-			err = bgmac_dma_rx_skb_for_slot(bgmac, slot);
-			if (err) {
-				/* Poison the old skb */
-				rx->len = cpu_to_le16(0xdead);
-				rx->flags = cpu_to_le16(0xbeef);
-
-				dma_sync_single_for_device(dma_dev,
-							   slot->dma_addr,
-							   BGMAC_RX_BUF_SIZE,
-							   DMA_FROM_DEVICE);
-				break;
-			}
-			bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
-
-			/* Unmap old skb, we'll pass it to the netfif */
-			dma_unmap_single(dma_dev, old_dma_addr,
-					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
-
 			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
 			skb_put(skb, BGMAC_RX_FRAME_OFFSET +
 				BGMAC_RX_BUF_OFFSET + len);
@@ -458,14 +440,16 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			skb_checksum_none_assert(skb);
 			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
 			napi_gro_receive(&bgmac->napi, skb);
-			handled++;
 		} while (0);
 
+		/* Prepare new skb as replacement */
+		if (bgmac_dma_rx_skb_for_slot(bgmac, slot))
+			continue;
+
+		bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
+
 		if (++ring->start >= BGMAC_RX_RING_SLOTS)
 			ring->start = 0;
-
-		if (handled >= weight) /* Should never be greater */
-			break;
 	}
 
 	return handled;
-- 
2.2.2
