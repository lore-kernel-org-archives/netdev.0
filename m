From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH net-next 2/3] bgmac: implement GRO and use build_skb
Date: Mon, 23 Mar 2015 12:35:36 +0100
Message-ID: <1427110537-18091-2-git-send-email-nbd@openwrt.org>
References: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:51358
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752497AbbCWLvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:51:31 -0400
In-Reply-To: <1427110537-18091-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves performance for routing and local rx

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 80 ++++++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bgmac.h |  7 ++-
 2 files changed, 62 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index efda7cf..c7da37a 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -276,31 +276,31 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 				     struct bgmac_slot_info *slot)
 {
 	struct device *dma_dev = bgmac->core->dma_dev;
-	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 	struct bgmac_rx_header *rx;
+	void *buf;
 
 	/* Alloc skb */
-	skb = netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
-	if (!skb)
+	buf = netdev_alloc_frag(BGMAC_RX_ALLOC_SIZE);
+	if (!buf)
 		return -ENOMEM;
 
 	/* Poison - if everything goes fine, hardware will overwrite it */
-	rx = (struct bgmac_rx_header *)skb->data;
+	rx = buf;
 	rx->len = cpu_to_le16(0xdead);
 	rx->flags = cpu_to_le16(0xbeef);
 
 	/* Map skb for the DMA */
-	dma_addr = dma_map_single(dma_dev, skb->data,
-				  BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+	dma_addr = dma_map_single(dma_dev, buf, BGMAC_RX_BUF_SIZE,
+				  DMA_FROM_DEVICE);
 	if (dma_mapping_error(dma_dev, dma_addr)) {
 		bgmac_err(bgmac, "DMA mapping error\n");
-		dev_kfree_skb(skb);
+		put_page(virt_to_head_page(buf));
 		return -ENOMEM;
 	}
 
 	/* Update the slot */
-	slot->skb = skb;
+	slot->buf = buf;
 	slot->dma_addr = dma_addr;
 
 	return 0;
@@ -343,8 +343,9 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	while (ring->start != ring->end) {
 		struct device *dma_dev = bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
-		struct sk_buff *skb = slot->skb;
-		struct bgmac_rx_header *rx;
+		struct bgmac_rx_header *rx = slot->buf;
+		struct sk_buff *skb;
+		void *buf = slot->buf;
 		u16 len, flags;
 
 		/* Unmap buffer to make it accessible to the CPU */
@@ -352,7 +353,6 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
 		/* Get info from the header */
-		rx = (struct bgmac_rx_header *)skb->data;
 		len = le16_to_cpu(rx->len);
 		flags = le16_to_cpu(rx->flags);
 
@@ -393,12 +393,13 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			dma_unmap_single(dma_dev, old_dma_addr,
 					 BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
+			skb = build_skb(buf, BGMAC_RX_ALLOC_SIZE);
 			skb_put(skb, BGMAC_RX_FRAME_OFFSET + len);
 			skb_pull(skb, BGMAC_RX_FRAME_OFFSET);
 
 			skb_checksum_none_assert(skb);
 			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
-			netif_receive_skb(skb);
+			napi_gro_receive(&bgmac->napi, skb);
 			handled++;
 		} while (0);
 
@@ -434,12 +435,11 @@ static bool bgmac_dma_unaligned(struct bgmac *bgmac,
 	return false;
 }
 
-static void bgmac_dma_ring_free(struct bgmac *bgmac,
-				struct bgmac_dma_ring *ring)
+static void bgmac_dma_tx_ring_free(struct bgmac *bgmac,
+				   struct bgmac_dma_ring *ring)
 {
 	struct device *dma_dev = bgmac->core->dma_dev;
 	struct bgmac_slot_info *slot;
-	int size;
 	int i;
 
 	for (i = 0; i < ring->num_slots; i++) {
@@ -451,23 +451,55 @@ static void bgmac_dma_ring_free(struct bgmac *bgmac,
 			dev_kfree_skb(slot->skb);
 		}
 	}
+}
 
-	if (ring->cpu_base) {
-		/* Free ring of descriptors */
-		size = ring->num_slots * sizeof(struct bgmac_dma_desc);
-		dma_free_coherent(dma_dev, size, ring->cpu_base,
-				  ring->dma_base);
+static void bgmac_dma_rx_ring_free(struct bgmac *bgmac,
+				   struct bgmac_dma_ring *ring)
+{
+	struct device *dma_dev = bgmac->core->dma_dev;
+	struct bgmac_slot_info *slot;
+	int i;
+
+	for (i = 0; i < ring->num_slots; i++) {
+		slot = &ring->slots[i];
+		if (!slot->buf)
+			continue;
+
+		if (slot->dma_addr)
+			dma_unmap_single(dma_dev, slot->dma_addr,
+					 BGMAC_RX_BUF_SIZE,
+					 DMA_FROM_DEVICE);
+		put_page(virt_to_head_page(slot->buf));
 	}
 }
 
+static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
+				     struct bgmac_dma_ring *ring)
+{
+	struct device *dma_dev = bgmac->core->dma_dev;
+	int size;
+
+	if (!ring->cpu_base)
+	    return;
+
+	/* Free ring of descriptors */
+	size = ring->num_slots * sizeof(struct bgmac_dma_desc);
+	dma_free_coherent(dma_dev, size, ring->cpu_base,
+			  ring->dma_base);
+}
+
 static void bgmac_dma_free(struct bgmac *bgmac)
 {
 	int i;
 
-	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
-		bgmac_dma_ring_free(bgmac, &bgmac->tx_ring[i]);
-	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
-		bgmac_dma_ring_free(bgmac, &bgmac->rx_ring[i]);
+	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
+		bgmac_dma_tx_ring_free(bgmac, &bgmac->tx_ring[i]);
+		bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
+	}
+	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
+		bgmac_dma_rx_ring_free(bgmac, &bgmac->rx_ring[i]);
+		bgmac_dma_ring_desc_free(bgmac, &bgmac->rx_ring[i]);
+	}
 }
 
 static int bgmac_dma_alloc(struct bgmac *bgmac)
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 1f9f36f..3ad965f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -362,6 +362,8 @@
 #define BGMAC_RX_FRAME_OFFSET			30		/* There are 2 unused bytes between header and real data */
 #define BGMAC_RX_MAX_FRAME_SIZE			1536		/* Copied from b44/tg3 */
 #define BGMAC_RX_BUF_SIZE			(BGMAC_RX_FRAME_OFFSET + BGMAC_RX_MAX_FRAME_SIZE)
+#define BGMAC_RX_ALLOC_SIZE			(SKB_DATA_ALIGN(BGMAC_RX_BUF_SIZE) + \
+						 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 #define BGMAC_BFL_ENETROBO			0x0010		/* has ephy roboswitch spi */
 #define BGMAC_BFL_ENETADM			0x0080		/* has ADMtek switch */
@@ -383,7 +385,10 @@
 #define ETHER_MAX_LEN   1518
 
 struct bgmac_slot_info {
-	struct sk_buff *skb;
+	union {
+		struct sk_buff *skb;
+		void *buf;
+	};
 	dma_addr_t dma_addr;
 };
 
-- 
2.2.2
