From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v7 8/9] bgmac: fix DMA rx corruption
Date: Tue, 14 Apr 2015 12:08:01 +0200
Message-ID: <1429006082-23489-8-git-send-email-nbd@openwrt.org>
References: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:54948
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753290AbbDNKIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 06:08:06 -0400
In-Reply-To: <1429006082-23489-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver needs to inform the hardware about the first invalid (not yet
filled) rx slot, by writing its DMA descriptor pointer offset to the
BGMAC_DMA_RX_INDEX register.

This register was set to a value exceeding the rx ring size, effectively
allowing the hardware constant access to the full ring, regardless of
which slots are initialized.

To fix this issue, always mark the last filled rx slot as invalid.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 79216d6..29af9e6 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -366,6 +366,16 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 	return 0;
 }
 
+static void bgmac_dma_rx_update_index(struct bgmac *bgmac,
+				      struct bgmac_dma_ring *ring)
+{
+	dma_wmb();
+
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
+		    ring->index_base +
+		    ring->end * sizeof(struct bgmac_dma_desc));
+}
+
 static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
 				    struct bgmac_dma_ring *ring, int desc_idx)
 {
@@ -384,6 +394,8 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
 	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
 	dma_desc->ctl0 = cpu_to_le32(ctl0);
 	dma_desc->ctl1 = cpu_to_le32(ctl1);
+
+	ring->end = desc_idx;
 }
 
 static void bgmac_dma_rx_poison_buf(struct device *dma_dev,
@@ -411,9 +423,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	end_slot &= BGMAC_DMA_RX_STATDPTR;
 	end_slot /= sizeof(struct bgmac_dma_desc);
 
-	ring->end = end_slot;
-
-	while (ring->start != ring->end) {
+	while (ring->start != end_slot) {
 		struct device *dma_dev = bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
 		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
@@ -476,6 +486,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			break;
 	}
 
+	bgmac_dma_rx_update_index(bgmac, ring);
+
 	return handled;
 }
 
@@ -695,6 +707,8 @@ static int bgmac_dma_init(struct bgmac *bgmac)
 		if (ring->unaligned)
 			bgmac_dma_rx_enable(bgmac, ring);
 
+		ring->start = 0;
+		ring->end = 0;
 		for (j = 0; j < ring->num_slots; j++) {
 			err = bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
 			if (err)
@@ -703,12 +717,7 @@ static int bgmac_dma_init(struct bgmac *bgmac)
 			bgmac_dma_rx_setup_desc(bgmac, ring, j);
 		}
 
-		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
-			    ring->index_base +
-			    ring->num_slots * sizeof(struct bgmac_dma_desc));
-
-		ring->start = 0;
-		ring->end = 0;
+		bgmac_dma_rx_update_index(bgmac, ring);
 	}
 
 	return 0;
-- 
2.2.2
