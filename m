From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH 1/4] bgmac: simplify tx ring index handling
Date: Sun, 12 Apr 2015 12:08:09 +0200
Message-ID: <1428833292-15356-1-git-send-email-nbd@openwrt.org>
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:46726
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751190AbbDLKIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 06:08:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep incrementing ring->start and ring->end instead of pointing it to
the actual ring slot entry. This simplifies the calculation of the
number of free slots.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 drivers/net/ethernet/broadcom/bgmac.c | 44 ++++++++++++++---------------------
 drivers/net/ethernet/broadcom/bgmac.h |  6 ++---
 2 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index fa8f9e1..73374b4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -142,11 +142,10 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 {
 	struct device *dma_dev = bgmac->core->dma_dev;
 	struct net_device *net_dev = bgmac->net_dev;
-	struct bgmac_slot_info *slot = &ring->slots[ring->end];
-	int free_slots;
+	int index = ring->end % BGMAC_TX_RING_SLOTS;
+	struct bgmac_slot_info *slot = &ring->slots[index];
 	int nr_frags;
 	u32 flags;
-	int index = ring->end;
 	int i;
 
 	if (skb->len > BGMAC_DESC_CTL1_LEN) {
@@ -158,13 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 		skb_checksum_help(skb);
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
-
-	if (ring->start <= ring->end)
-		free_slots = ring->start - ring->end + BGMAC_TX_RING_SLOTS;
-	else
-		free_slots = ring->start - ring->end;
-
-	if (free_slots <= nr_frags + 1) {
+	if (ring->end - ring->start + nr_frags + 1 >= BGMAC_TX_RING_SLOTS) {
 		bgmac_err(bgmac, "TX ring is full, queue should be stopped!\n");
 		netif_stop_queue(net_dev);
 		return NETDEV_TX_BUSY;
@@ -200,7 +193,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 	}
 
 	slot->skb = skb;
-
+	ring->end += nr_frags + 1;
 	netdev_sent_queue(net_dev, skb->len);
 
 	wmb();
@@ -208,13 +201,12 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 	/* Increase ring->end to point empty slot. We tell hardware the first
 	 * slot it should *not* read.
 	 */
-	ring->end = (index + 1) % BGMAC_TX_RING_SLOTS;
 	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_INDEX,
 		    ring->index_base +
-		    ring->end * sizeof(struct bgmac_dma_desc));
+		    (ring->end % BGMAC_TX_RING_SLOTS) *
+		    sizeof(struct bgmac_dma_desc));
 
-	free_slots -= nr_frags + 1;
-	if (free_slots < 8)
+	if (ring->end - ring->start >= BGMAC_TX_RING_SLOTS - 8)
 		netif_stop_queue(net_dev);
 
 	return NETDEV_TX_OK;
@@ -256,17 +248,17 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 	empty_slot &= BGMAC_DMA_TX_STATDPTR;
 	empty_slot /= sizeof(struct bgmac_dma_desc);
 
-	while (ring->start != empty_slot) {
-		struct bgmac_slot_info *slot = &ring->slots[ring->start];
-		u32 ctl1 = le32_to_cpu(ring->cpu_base[ring->start].ctl1);
-		int len = ctl1 & BGMAC_DESC_CTL1_LEN;
+	while (ring->start != ring->end) {
+		int slot_idx = ring->start % BGMAC_TX_RING_SLOTS;
+		struct bgmac_slot_info *slot = &ring->slots[slot_idx];
+		u32 ctl1;
+		int len;
 
-		if (!slot->dma_addr) {
-			bgmac_err(bgmac, "Hardware reported transmission for empty TX ring slot %d! End of ring: %d\n",
-				  ring->start, ring->end);
-			goto next;
-		}
+		if (slot_idx == empty_slot)
+			break;
 
+		ctl1 = le32_to_cpu(ring->cpu_base[slot_idx].ctl1);
+		len = ctl1 & BGMAC_DESC_CTL1_LEN;
 		if (ctl1 & BGMAC_DESC_CTL0_SOF)
 			/* Unmap no longer used buffer */
 			dma_unmap_single(dma_dev, slot->dma_addr, len,
@@ -284,10 +276,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 			slot->skb = NULL;
 		}
 
-next:
 		slot->dma_addr = 0;
-		if (++ring->start >= BGMAC_TX_RING_SLOTS)
-			ring->start = 0;
+		ring->start++;
 		freed = true;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 3ad965f..5a198d5 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -414,10 +414,10 @@ enum bgmac_dma_ring_type {
  * empty.
  */
 struct bgmac_dma_ring {
-	u16 num_slots;
-	u16 start;
-	u16 end;
+	u32 start;
+	u32 end;
 
+	u16 num_slots;
 	u16 mmio_base;
 	struct bgmac_dma_desc *cpu_base;
 	dma_addr_t dma_base;
-- 
2.2.2
