From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 12/12] net: ethernet: aquantia: Copying tx buffers is not needed.
Date: Mon, 20 Feb 2017 22:36:50 +0300
Message-ID: <1a23381dee69ab152b7064b82cbcd2af222c5aae.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752366AbdBTTiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:38:09 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This fix removes copying of tx biffers.
Now we use ring->buff_fing directly.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c  | 170 +++++++++++++----------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c |  19 ---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h |   3 -
 3 files changed, 97 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index bce312a..ee78444 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -468,95 +468,116 @@ int aq_nic_start(struct aq_nic_s *self)
 	return err;
 }
 
-static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
-					struct sk_buff *skb,
-					struct aq_ring_buff_s *dx)
+static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
+				   struct sk_buff *skb,
+				   struct aq_ring_s *ring)
 {
 	unsigned int ret = 0U;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int frag_count = 0U;
+	unsigned int dx = ring->sw_tail;
+	struct aq_ring_buff_s *dx_buff = &ring->buff_ring[dx];
 
-	dx->flags = 0U;
-	dx->len = skb_headlen(skb);
-	dx->pa = dma_map_single(aq_nic_get_dev(self), skb->data, dx->len,
-				DMA_TO_DEVICE);
-	dx->len_pkt = skb->len;
-	dx->is_sop = 1U;
-	dx->is_mapped = 1U;
+	if (unlikely(skb_is_gso(skb))) {
+		dx_buff->flags = 0U;
+		dx_buff->len_pkt = skb->len;
+		dx_buff->len_l2 = ETH_HLEN;
+		dx_buff->len_l3 = ip_hdrlen(skb);
+		dx_buff->len_l4 = tcp_hdrlen(skb);
+		dx_buff->mss = skb_shinfo(skb)->gso_size;
+		dx_buff->is_txc = 1U;
+
+		dx = aq_ring_next_dx(ring, dx);
+		dx_buff = &ring->buff_ring[dx];
+		++ret;
+	}
+
+	dx_buff->flags = 0U;
+	dx_buff->len = skb_headlen(skb);
+	dx_buff->pa = dma_map_single(aq_nic_get_dev(self),
+				     skb->data,
+				     dx_buff->len,
+				     DMA_TO_DEVICE);
 
+	if (unlikely(dma_mapping_error(aq_nic_get_dev(self), dx_buff->pa)))
+		goto exit;
+
+	dx_buff->len_pkt = skb->len;
+	dx_buff->is_sop = 1U;
+	dx_buff->is_mapped = 1U;
 	++ret;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		dx->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ? 1U : 0U;
-		dx->is_tcp_cso =
+		dx_buff->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ?
+			1U : 0U;
+		dx_buff->is_tcp_cso =
 			(ip_hdr(skb)->protocol == IPPROTO_TCP) ? 1U : 0U;
-		dx->is_udp_cso =
+		dx_buff->is_udp_cso =
 			(ip_hdr(skb)->protocol == IPPROTO_UDP) ? 1U : 0U;
 	}
 
 	for (; nr_frags--; ++frag_count) {
-		unsigned int frag_len;
+		unsigned int frag_len = 0U;
 		dma_addr_t frag_pa;
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_count];
 
 		frag_len = skb_frag_size(frag);
-
 		frag_pa = skb_frag_dma_map(aq_nic_get_dev(self), frag, 0,
 					   frag_len, DMA_TO_DEVICE);
 
+		if (unlikely(dma_mapping_error(aq_nic_get_dev(self), frag_pa)))
+			goto mapping_error;
+
 		while (frag_len > AQ_CFG_TX_FRAME_MAX) {
-			++dx;
-			++ret;
-			dx->flags = 0U;
-			dx->len = AQ_CFG_TX_FRAME_MAX;
-			dx->pa = frag_pa;
-			dx->is_mapped = 1U;
+			dx = aq_ring_next_dx(ring, dx);
+			dx_buff = &ring->buff_ring[dx];
+
+			dx_buff->flags = 0U;
+			dx_buff->len = AQ_CFG_TX_FRAME_MAX;
+			dx_buff->pa = frag_pa;
+			dx_buff->is_mapped = 1U;
 
 			frag_len -= AQ_CFG_TX_FRAME_MAX;
 			frag_pa += AQ_CFG_TX_FRAME_MAX;
+			++ret;
 		}
 
-		++dx;
-		++ret;
+		dx = aq_ring_next_dx(ring, dx);
+		dx_buff = &ring->buff_ring[dx];
 
-		dx->flags = 0U;
-		dx->len = frag_len;
-		dx->pa = frag_pa;
-		dx->is_mapped = 1U;
+		dx_buff->flags = 0U;
+		dx_buff->len = frag_len;
+		dx_buff->pa = frag_pa;
+		dx_buff->is_mapped = 1U;
+		++ret;
 	}
 
-	dx->is_eop = 1U;
-	dx->skb = skb;
-
-	return ret;
-}
-
-static unsigned int aq_nic_map_skb_lso(struct aq_nic_s *self,
-				       struct sk_buff *skb,
-				       struct aq_ring_buff_s *dx)
-{
-	dx->flags = 0U;
-	dx->len_pkt = skb->len;
-	dx->len_l2 = ETH_HLEN;
-	dx->len_l3 = ip_hdrlen(skb);
-	dx->len_l4 = tcp_hdrlen(skb);
-	dx->mss = skb_shinfo(skb)->gso_size;
-	dx->is_txc = 1U;
-	return 1U;
-}
-
-static unsigned int aq_nic_map_skb(struct aq_nic_s *self, struct sk_buff *skb,
-				   struct aq_ring_buff_s *dx)
-{
-	unsigned int ret = 0U;
-
-	if (unlikely(skb_is_gso(skb))) {
-		ret = aq_nic_map_skb_lso(self, skb, dx);
-		++dx;
+	dx_buff->is_eop = 1U;
+	dx_buff->skb = skb;
+	goto exit;
+
+mapping_error:
+	for (dx = ring->sw_tail;
+	     ret > 0;
+	     --ret, dx = aq_ring_next_dx(ring, dx)) {
+		dx_buff = &ring->buff_ring[dx];
+
+		if (!dx_buff->is_txc && dx_buff->pa) {
+			if (unlikely(dx_buff->is_sop)) {
+				dma_unmap_single(aq_nic_get_dev(self),
+						 dx_buff->pa,
+						 dx_buff->len,
+						 DMA_TO_DEVICE);
+			} else {
+				dma_unmap_page(aq_nic_get_dev(self),
+					       dx_buff->pa,
+					       dx_buff->len,
+					       DMA_TO_DEVICE);
+			}
+		}
 	}
 
-	ret += aq_nic_map_skb_frag(self, skb, dx);
-
+exit:
 	return ret;
 }
 
@@ -571,7 +592,6 @@ __acquires(&ring->lock)
 	unsigned int trys = AQ_CFG_LOCK_TRYS;
 	int err = NETDEV_TX_OK;
 	bool is_nic_in_bad_state;
-	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
 
 	frags = skb_shinfo(skb)->nr_frags + 1;
 
@@ -595,23 +615,27 @@ __acquires(&ring->lock)
 
 	do {
 		if (spin_trylock(&ring->header.lock)) {
-			frags = aq_nic_map_skb(self, skb, &buffers[0]);
-
-			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
-
-			err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
-							      ring, frags);
-			if (err >= 0) {
-				if (aq_ring_avail_dx(ring) <
-				    AQ_CFG_SKB_FRAGS_MAX + 1)
-					aq_nic_ndev_queue_stop(self, ring->idx);
+			frags = aq_nic_map_skb(self, skb, ring);
+
+			if (likely(frags)) {
+				err = self->aq_hw_ops.hw_ring_tx_xmit(
+								self->aq_hw,
+								ring, frags);
+				if (err >= 0) {
+					if (aq_ring_avail_dx(ring) <
+					    AQ_CFG_SKB_FRAGS_MAX + 1)
+						aq_nic_ndev_queue_stop(
+								self,
+								ring->idx);
+
+					++ring->stats.tx.packets;
+					ring->stats.tx.bytes += skb->len;
+				}
+			} else {
+				err = NETDEV_TX_BUSY;
 			}
-			spin_unlock(&ring->header.lock);
 
-			if (err >= 0) {
-				++ring->stats.tx.packets;
-				ring->stats.tx.bytes += skb->len;
-			}
+			spin_unlock(&ring->header.lock);
 			break;
 		}
 	} while (--trys);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 51f4e7f..0358e607 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -104,25 +104,6 @@ int aq_ring_init(struct aq_ring_s *self)
 	return 0;
 }
 
-void aq_ring_tx_append_buffs(struct aq_ring_s *self,
-			     struct aq_ring_buff_s *buffer,
-			     unsigned int buffers)
-{
-	if (likely(self->sw_tail + buffers < self->size)) {
-		memcpy(&self->buff_ring[self->sw_tail], buffer,
-		       sizeof(buffer[0]) * buffers);
-	} else {
-		unsigned int first_part = self->size - self->sw_tail;
-		unsigned int second_part = buffers - first_part;
-
-		memcpy(&self->buff_ring[self->sw_tail], buffer,
-		       sizeof(buffer[0]) * first_part);
-
-		memcpy(&self->buff_ring[0], &buffer[first_part],
-		       sizeof(buffer[0]) * second_part);
-	}
-}
-
 void aq_ring_tx_clean(struct aq_ring_s *self)
 {
 	struct device *dev = aq_nic_get_dev(self->aq_nic);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index fb296b3..2572546 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -146,9 +146,6 @@ struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
 int aq_ring_init(struct aq_ring_s *self);
 void aq_ring_rx_deinit(struct aq_ring_s *self);
 void aq_ring_free(struct aq_ring_s *self);
-void aq_ring_tx_append_buffs(struct aq_ring_s *ring,
-			     struct aq_ring_buff_s *buffer,
-			     unsigned int buffers);
 void aq_ring_tx_clean(struct aq_ring_s *self);
 int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget);
 int aq_ring_rx_fill(struct aq_ring_s *self);
-- 
2.7.4
