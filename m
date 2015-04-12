From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 12:08:12 +0200
Message-ID: <1428833292-15356-4-git-send-email-nbd@openwrt.org>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:46727
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751240AbbDLKIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 06:08:17 -0400
In-Reply-To: <1428833292-15356-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver needs to inform the hardware about the first invalid (not yet
filled) rx slot, by writing its DMA descriptor pointer offset to the
BGMAC_DMA_RX_INDEX register.

This register was set to a value exceeding the rx ring size, effectively
allowing the hardware constant access to the full ring, regardless of
which slots are initialized.

Fix this by updating the register in bgmac_dma_rx_setup_desc.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e332de8..856ceee 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -380,6 +380,12 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
 	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
 	dma_desc->ctl0 = cpu_to_le32(ctl0);
 	dma_desc->ctl1 = cpu_to_le32(ctl1);
+
+	desc_idx = (desc_idx + 1) % BGMAC_RX_RING_SLOTS;
+
+	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
+			ring->index_base +
+			desc_idx * sizeof(struct bgmac_dma_desc));
 }
 
 static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
@@ -394,9 +400,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	end_slot &= BGMAC_DMA_RX_STATDPTR;
 	end_slot /= sizeof(struct bgmac_dma_desc);
 
-	ring->end = end_slot;
-
-	while (ring->start != ring->end) {
+	while (ring->start != end_slot) {
 		struct device *dma_dev = bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
 		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
@@ -693,10 +697,6 @@ static void bgmac_dma_init(struct bgmac *bgmac)
 		for (j = 0; j < ring->num_slots; j++)
 			bgmac_dma_rx_setup_desc(bgmac, ring, j);
 
-		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
-			    ring->index_base +
-			    ring->num_slots * sizeof(struct bgmac_dma_desc));
-
 		ring->start = 0;
 		ring->end = 0;
 	}
-- 
2.2.2
