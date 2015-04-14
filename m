From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v7 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 12:07:57 +0200
Message-ID: <1429006082-23489-4-git-send-email-nbd@openwrt.org>
References: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:54956
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754276AbbDNKIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:08:07 -0400
In-Reply-To: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate a new buffer before processing the completed one. If allocation
fails, reuse the old buffer.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 71 +++++++++++++++++------------------
 1 file changed, 34 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 424a68c..60b5c3c 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -386,6 +386,19 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
 	dma_desc->ctl1 = cpu_to_le32(ctl1);
 }
 
+static void bgmac_dma_rx_poison_buf(struct device *dma_dev,
+				    struct bgmac_slot_info *slot)
+{
+	struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
+
+	dma_sync_single_for_cpu(dma_dev, slot->dma_addr, BGMAC_RX_BUF_SIZE,
+				DMA_FROM_DEVICE);
+	rx->len = cpu_to_le16(0xdead);
+	rx->flags = cpu_to_le16(0xbeef);
+	dma_sync_single_for_device(dma_dev, slot->dma_addr, BGMAC_RX_BUF_SIZE,
+				   DMA_FROM_DEVICE);
+}
+
 static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			     int weight)
 {
@@ -406,53 +419,35 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
 		struct sk_buff *skb;
 		void *buf = slot->buf;
+		dma_addr_t dma_addr = slot->dma_addr;
 		u16 len, flags;
 
-		/* Unmap buffer to make it accessible to the CPU */
-		dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
-					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+		do {
+			/* Prepare new skb as replacement */
+			if (bgmac_dma_rx_skb_for_slot(bgmac, slot)) {
+				bgmac_dma_rx_poison_buf(dma_dev, slot);
+				break;
+			}
 
-		/* Get info from the header */
-		len = le16_to_cpu(rx->len);
-		flags = le16_to_cpu(rx->flags);
+			/* Unmap buffer to make it accessible to the CPU */
+			dma_unmap_single(dma_dev, dma_addr,
+					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
-		do {
-			dma_addr_t old_dma_addr = slot->dma_addr;
-			int err;
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
+				put_page(virt_to_head_page(buf));
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
@@ -465,6 +460,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			handled++;
 		} while (0);
 
+		bgmac_dma_rx_setup_desc(bgmac, ring, ring->start);
+
 		if (++ring->start >= BGMAC_RX_RING_SLOTS)
 			ring->start = 0;
 
@@ -532,14 +529,14 @@ static void bgmac_dma_rx_ring_free(struct bgmac *bgmac,
 
 	for (i = 0; i < ring->num_slots; i++) {
 		slot = &ring->slots[i];
-		if (!slot->buf)
+		if (!slot->dma_addr)
 			continue;
 
-		if (slot->dma_addr)
-			dma_unmap_single(dma_dev, slot->dma_addr,
-					 BGMAC_RX_BUF_SIZE,
-					 DMA_FROM_DEVICE);
+		dma_unmap_single(dma_dev, slot->dma_addr,
+				 BGMAC_RX_BUF_SIZE,
+				 DMA_FROM_DEVICE);
 		put_page(virt_to_head_page(slot->buf));
+		slot->dma_addr = 0;
 	}
 }
 
-- 
2.2.2
