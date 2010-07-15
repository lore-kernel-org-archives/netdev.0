From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/2] bnx2: allocate with GFP_KERNEL flag on RX path init
Date: Thu, 15 Jul 2010 10:25:42 -0400
Message-ID: <20100715142537.12504.60051.send-patch@dhcp-lab-109.englab.brq.redhat.com>
References: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Cc: Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933300Ab0GOOZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 10:25:45 -0400
In-Reply-To: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a203f39..6de4cb7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2664,13 +2664,13 @@ bnx2_set_mac_addr(struct bnx2 *bp, u8 *mac_addr, u32 pos)
 }
 
 static inline int
-bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
+bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gfp_t gfp)
 {
 	dma_addr_t mapping;
 	struct sw_pg *rx_pg = &rxr->rx_pg_ring[index];
 	struct rx_bd *rxbd =
 		&rxr->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
-	struct page *page = alloc_page(GFP_ATOMIC);
+	struct page *page = alloc_page(gfp);
 
 	if (!page)
 		return -ENOMEM;
@@ -2705,7 +2705,7 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 }
 
 static inline int
-bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
+bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	struct sw_bd *rx_buf = &rxr->rx_buf_ring[index];
@@ -2713,7 +2713,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	struct rx_bd *rxbd = &rxr->rx_desc_ring[RX_RING(index)][RX_IDX(index)];
 	unsigned long align;
 
-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	skb = __netdev_alloc_skb(bp->dev, bp->rx_buf_size, gfp);
 	if (skb == NULL) {
 		return -ENOMEM;
 	}
@@ -2974,7 +2974,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 	int err;
 	u16 prod = ring_idx & 0xffff;
 
-	err = bnx2_alloc_rx_skb(bp, rxr, prod);
+	err = bnx2_alloc_rx_skb(bp, rxr, prod, GFP_KERNEL);
 	if (unlikely(err)) {
 		bnx2_reuse_rx_skb(bp, rxr, skb, (u16) (ring_idx >> 16), prod);
 		if (hdr_len) {
@@ -3039,7 +3039,8 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 			rx_pg->page = NULL;
 
 			err = bnx2_alloc_rx_page(bp, rxr,
-						 RX_PG_RING_IDX(pg_prod));
+						 RX_PG_RING_IDX(pg_prod),
+						 GFP_ATOMIC);
 			if (unlikely(err)) {
 				rxr->rx_pg_cons = pg_cons;
 				rxr->rx_pg_prod = pg_prod;
@@ -5179,7 +5180,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	ring_prod = prod = rxr->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
-		if (bnx2_alloc_rx_page(bp, rxr, ring_prod) < 0) {
+		if (bnx2_alloc_rx_page(bp, rxr, ring_prod, GFP_KERNEL) < 0) {
 			netdev_warn(bp->dev, "init'ed rx page ring %d with %d/%d pages only\n",
 				    ring_num, i, bp->rx_pg_ring_size);
 			break;
@@ -5191,7 +5192,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	ring_prod = prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod) < 0) {
+		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod, GFP_KERNEL) < 0) {
 			netdev_warn(bp->dev, "init'ed rx ring %d with %d/%d skbs only\n",
 				    ring_num, i, bp->rx_ring_size);
 			break;
-- 
1.7.1

