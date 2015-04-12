From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v2 3/4] bgmac: set received skb headroom to NET_SKB_PAD
Date: Sun, 12 Apr 2015 16:22:44 +0200
Message-ID: <1428848565-94187-3-git-send-email-nbd@openwrt.org>
References: <1428848565-94187-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:47432
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751074AbbDLOWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 10:22:48 -0400
In-Reply-To: <1428848565-94187-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A packet buffer offset of 30 bytes is inefficient, because the first 2
bytes end up in a different cacheline.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 14 ++++++++------
 drivers/net/ethernet/broadcom/bgmac.h |  4 +++-
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 66876c5..e332de8 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -342,13 +342,13 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 		return -ENOMEM;
 
 	/* Poison - if everything goes fine, hardware will overwrite it */
-	rx = buf;
+	rx = buf + BGMAC_RX_BUF_OFFSET;
 	rx->len = cpu_to_le16(0xdead);
 	rx->flags = cpu_to_le16(0xbeef);
 
 	/* Map skb for the DMA */
-	dma_addr = dma_map_single(dma_dev, buf, BGMAC_RX_BUF_SIZE,
-				  DMA_FROM_DEVICE);
+	dma_addr = dma_map_single(dma_dev, buf + BGMAC_RX_BUF_OFFSET,
+				  BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 	if (dma_mapping_error(dma_dev, dma_addr)) {
 		bgmac_err(bgmac, "DMA mapping error\n");
 		put_page(virt_to_head_page(buf));
@@ -399,7 +399,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	while (ring->start != ring->end) {
 		struct device *dma_dev = bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
-		struct bgmac_rx_header *rx = slot->buf;
+		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
 		struct sk_buff *skb;
 		void *buf = slot->buf;
 		u16 len, flags;
@@ -450,8 +450,10 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
 			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
-			skb_put(skb, BGMAC_RX_FRAME_OFFSET + len);
-			skb_pull(skb, BGMAC_RX_FRAME_OFFSET);
+			skb_put(skb, BGMAC_RX_FRAME_OFFSET +
+				BGMAC_RX_BUF_OFFSET + len);
+			skb_pull(skb, BGMAC_RX_FRAME_OFFSET +
+				 BGMAC_RX_BUF_OFFSET);
 
 			skb_checksum_none_assert(skb);
 			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index abd50d1..3db0d52 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -360,9 +360,11 @@
 
 #define BGMAC_RX_HEADER_LEN			28		/* Last 24 bytes are unused. Well... */
 #define BGMAC_RX_FRAME_OFFSET			30		/* There are 2 unused bytes between header and real data */
+#define BGMAC_RX_BUF_OFFSET			(NET_SKB_PAD + NET_IP_ALIGN - \
+						 BGMAC_RX_FRAME_OFFSET)
 #define BGMAC_RX_MAX_FRAME_SIZE			1536		/* Copied from b44/tg3 */
 #define BGMAC_RX_BUF_SIZE			(BGMAC_RX_FRAME_OFFSET + BGMAC_RX_MAX_FRAME_SIZE)
-#define BGMAC_RX_ALLOC_SIZE			(SKB_DATA_ALIGN(BGMAC_RX_BUF_SIZE) + \
+#define BGMAC_RX_ALLOC_SIZE			(SKB_DATA_ALIGN(BGMAC_RX_BUF_SIZE + BGMAC_RX_BUF_OFFSET) + \
 						 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 #define BGMAC_BFL_ENETROBO			0x0010		/* has ephy roboswitch spi */
-- 
2.2.2
