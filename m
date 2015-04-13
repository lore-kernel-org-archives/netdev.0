From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v6 9/9] bgmac: drop ring->num_slots
Date: Tue, 14 Apr 2015 01:42:17 +0200
Message-ID: <1428968537-6181-9-git-send-email-nbd@openwrt.org>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:53113
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752087AbbDMXmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 19:42:21 -0400
In-Reply-To: <1428968537-6181-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ring size is always known at compile time, so make the code a bit
more efficient

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 27 ++++++++++++++-------------
 drivers/net/ethernet/broadcom/bgmac.h |  3 +--
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index a07a62e..30968e8 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -123,7 +123,7 @@ bgmac_dma_tx_add_buf(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 	struct bgmac_dma_desc *dma_desc;
 	u32 ctl1;
 
-	if (i == ring->num_slots - 1)
+	if (i == BGMAC_TX_RING_SLOTS - 1)
 		ctl0 |= BGMAC_DESC_CTL0_EOT;
 
 	ctl1 = len & BGMAC_DESC_CTL1_LEN;
@@ -378,7 +378,7 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
 	struct bgmac_dma_desc *dma_desc = ring->cpu_base + desc_idx;
 	u32 ctl0 = 0, ctl1 = 0;
 
-	if (desc_idx == ring->num_slots - 1)
+	if (desc_idx == BGMAC_RX_RING_SLOTS - 1)
 		ctl0 |= BGMAC_DESC_CTL0_EOT;
 	ctl1 |= BGMAC_RX_BUF_SIZE & BGMAC_DESC_CTL1_LEN;
 	/* Is there any BGMAC device that requires extension? */
@@ -516,7 +516,7 @@ static void bgmac_dma_tx_ring_free(struct bgmac *bgmac,
 	struct bgmac_slot_info *slot;
 	int i;
 
-	for (i = 0; i < ring->num_slots; i++) {
+	for (i = 0; i < BGMAC_TX_RING_SLOTS; i++) {
 		int len = dma_desc[i].ctl1 & BGMAC_DESC_CTL1_LEN;
 
 		slot = &ring->slots[i];
@@ -541,7 +541,7 @@ static void bgmac_dma_rx_ring_free(struct bgmac *bgmac,
 	struct bgmac_slot_info *slot;
 	int i;
 
-	for (i = 0; i < ring->num_slots; i++) {
+	for (i = 0; i < BGMAC_RX_RING_SLOTS; i++) {
 		slot = &ring->slots[i];
 		if (!slot->dma_addr)
 			continue;
@@ -555,7 +555,8 @@ static void bgmac_dma_rx_ring_free(struct bgmac *bgmac,
 }
 
 static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
-				     struct bgmac_dma_ring *ring)
+				     struct bgmac_dma_ring *ring,
+				     int num_slots)
 {
 	struct device *dma_dev = bgmac->core->dma_dev;
 	int size;
@@ -564,7 +565,7 @@ static void bgmac_dma_ring_desc_free(struct bgmac *bgmac,
 	    return;
 
 	/* Free ring of descriptors */
-	size = ring->num_slots * sizeof(struct bgmac_dma_desc);
+	size = num_slots * sizeof(struct bgmac_dma_desc);
 	dma_free_coherent(dma_dev, size, ring->cpu_base,
 			  ring->dma_base);
 }
@@ -585,10 +586,12 @@ static void bgmac_dma_free(struct bgmac *bgmac)
 	int i;
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++)
-		bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i]);
+		bgmac_dma_ring_desc_free(bgmac, &bgmac->tx_ring[i],
+					 BGMAC_TX_RING_SLOTS);
 
 	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++)
-		bgmac_dma_ring_desc_free(bgmac, &bgmac->rx_ring[i]);
+		bgmac_dma_ring_desc_free(bgmac, &bgmac->rx_ring[i],
+					 BGMAC_RX_RING_SLOTS);
 }
 
 static int bgmac_dma_alloc(struct bgmac *bgmac)
@@ -611,11 +614,10 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 
 	for (i = 0; i < BGMAC_MAX_TX_RINGS; i++) {
 		ring = &bgmac->tx_ring[i];
-		ring->num_slots = BGMAC_TX_RING_SLOTS;
 		ring->mmio_base = ring_base[i];
 
 		/* Alloc ring of descriptors */
-		size = ring->num_slots * sizeof(struct bgmac_dma_desc);
+		size = BGMAC_TX_RING_SLOTS * sizeof(struct bgmac_dma_desc);
 		ring->cpu_base = dma_zalloc_coherent(dma_dev, size,
 						     &ring->dma_base,
 						     GFP_KERNEL);
@@ -637,11 +639,10 @@ static int bgmac_dma_alloc(struct bgmac *bgmac)
 
 	for (i = 0; i < BGMAC_MAX_RX_RINGS; i++) {
 		ring = &bgmac->rx_ring[i];
-		ring->num_slots = BGMAC_RX_RING_SLOTS;
 		ring->mmio_base = ring_base[i];
 
 		/* Alloc ring of descriptors */
-		size = ring->num_slots * sizeof(struct bgmac_dma_desc);
+		size = BGMAC_RX_RING_SLOTS * sizeof(struct bgmac_dma_desc);
 		ring->cpu_base = dma_zalloc_coherent(dma_dev, size,
 						     &ring->dma_base,
 						     GFP_KERNEL);
@@ -704,7 +705,7 @@ static int bgmac_dma_init(struct bgmac *bgmac)
 
 		ring->start = 0;
 		ring->end = 0;
-		for (j = 0; j < ring->num_slots; j++) {
+		for (j = 0; j < BGMAC_RX_RING_SLOTS; j++) {
 			err = bgmac_dma_rx_skb_for_slot(bgmac, &ring->slots[j]);
 			if (err)
 				return err;
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index e45e303..db27feb 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -419,11 +419,10 @@ struct bgmac_dma_ring {
 	u32 start;
 	u32 end;
 
-	u16 num_slots;
-	u16 mmio_base;
 	struct bgmac_dma_desc *cpu_base;
 	dma_addr_t dma_base;
 	u32 index_base; /* Used for unaligned rings only, otherwise 0 */
+	u16 mmio_base;
 	bool unaligned;
 
 	struct bgmac_slot_info slots[BGMAC_RX_RING_SLOTS];
-- 
2.2.2
