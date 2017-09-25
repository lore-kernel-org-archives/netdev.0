From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net v2 4/4] net:ethernet:atlantic: fix iommu errors
Date: Mon, 25 Sep 2017 10:48:50 +0300
Message-ID: <83560083f457697606352b233dbfc44aed581f37.1506324091.git.igor.russkikh@aquantia.com>
References: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0083.outbound.protection.outlook.com ([104.47.33.83]:34707
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbdIYHto (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 03:49:44 -0400
In-Reply-To: <cover.1506324091.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Call skb_frag_dma_map multiple times if tx length is greater than
device max and avoid processing tx ring until entire packet has been
sent.

Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c  | 43 ++++++++++++++----------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 27 ++++++++++-----
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h |  6 ++--
 3 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 072a550..0a5bb41 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -473,6 +473,7 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int frag_count = 0U;
 	unsigned int dx = ring->sw_tail;
+	struct aq_ring_buff_s *first = NULL;
 	struct aq_ring_buff_s *dx_buff = &ring->buff_ring[dx];
 
 	if (unlikely(skb_is_gso(skb))) {
@@ -483,6 +484,7 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 		dx_buff->len_l4 = tcp_hdrlen(skb);
 		dx_buff->mss = skb_shinfo(skb)->gso_size;
 		dx_buff->is_txc = 1U;
+		dx_buff->eop_index = 0xffffU;
 
 		dx_buff->is_ipv6 =
 			(ip_hdr(skb)->version == 6) ? 1U : 0U;
@@ -502,6 +504,7 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 	if (unlikely(dma_mapping_error(aq_nic_get_dev(self), dx_buff->pa)))
 		goto exit;
 
+	first = dx_buff;
 	dx_buff->len_pkt = skb->len;
 	dx_buff->is_sop = 1U;
 	dx_buff->is_mapped = 1U;
@@ -530,40 +533,46 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 
 	for (; nr_frags--; ++frag_count) {
 		unsigned int frag_len = 0U;
+		unsigned int buff_offset = 0U;
+		unsigned int buff_size = 0U;
 		dma_addr_t frag_pa;
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_count];
 
 		frag_len = skb_frag_size(frag);
-		frag_pa = skb_frag_dma_map(aq_nic_get_dev(self), frag, 0,
-					   frag_len, DMA_TO_DEVICE);
 
-		if (unlikely(dma_mapping_error(aq_nic_get_dev(self), frag_pa)))
-			goto mapping_error;
+		while (frag_len) {
+			if (frag_len > AQ_CFG_TX_FRAME_MAX)
+				buff_size = AQ_CFG_TX_FRAME_MAX;
+			else
+				buff_size = frag_len;
+
+			frag_pa = skb_frag_dma_map(aq_nic_get_dev(self),
+						   frag,
+						   buff_offset,
+						   buff_size,
+						   DMA_TO_DEVICE);
+
+			if (unlikely(dma_mapping_error(aq_nic_get_dev(self),
+						       frag_pa)))
+				goto mapping_error;
 
-		while (frag_len > AQ_CFG_TX_FRAME_MAX) {
 			dx = aq_ring_next_dx(ring, dx);
 			dx_buff = &ring->buff_ring[dx];
 
 			dx_buff->flags = 0U;
-			dx_buff->len = AQ_CFG_TX_FRAME_MAX;
+			dx_buff->len = buff_size;
 			dx_buff->pa = frag_pa;
 			dx_buff->is_mapped = 1U;
+			dx_buff->eop_index = 0xffffU;
+
+			frag_len -= buff_size;
+			buff_offset += buff_size;
 
-			frag_len -= AQ_CFG_TX_FRAME_MAX;
-			frag_pa += AQ_CFG_TX_FRAME_MAX;
 			++ret;
 		}
-
-		dx = aq_ring_next_dx(ring, dx);
-		dx_buff = &ring->buff_ring[dx];
-
-		dx_buff->flags = 0U;
-		dx_buff->len = frag_len;
-		dx_buff->pa = frag_pa;
-		dx_buff->is_mapped = 1U;
-		++ret;
 	}
 
+	first->eop_index = dx;
 	dx_buff->is_eop = 1U;
 	dx_buff->skb = skb;
 	goto exit;
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 02f79b0..0654e0c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -104,6 +104,12 @@ int aq_ring_init(struct aq_ring_s *self)
 	return 0;
 }
 
+static inline bool aq_ring_dx_in_range(unsigned int h, unsigned int i,
+				       unsigned int t)
+{
+	return (h < t) ? ((h < i) && (i < t)) : ((h < i) || (i < t));
+}
+
 void aq_ring_update_queue_state(struct aq_ring_s *ring)
 {
 	if (aq_ring_avail_dx(ring) <= AQ_CFG_SKB_FRAGS_MAX)
@@ -139,23 +145,28 @@ void aq_ring_tx_clean(struct aq_ring_s *self)
 		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
 
 		if (likely(buff->is_mapped)) {
-			if (unlikely(buff->is_sop))
+			if (unlikely(buff->is_sop)) {
+				if (!buff->is_eop &&
+				    buff->eop_index != 0xffffU &&
+				    (!aq_ring_dx_in_range(self->sw_head,
+						buff->eop_index,
+						self->hw_head)))
+					break;
+
 				dma_unmap_single(dev, buff->pa, buff->len,
 						 DMA_TO_DEVICE);
-			else
+			} else {
 				dma_unmap_page(dev, buff->pa, buff->len,
 					       DMA_TO_DEVICE);
+			}
 		}
 
 		if (unlikely(buff->is_eop))
 			dev_kfree_skb_any(buff->skb);
-	}
-}
 
-static inline unsigned int aq_ring_dx_in_range(unsigned int h, unsigned int i,
-					       unsigned int t)
-{
-	return (h < t) ? ((h < i) && (i < t)) : ((h < i) || (i < t));
+		buff->pa = 0U;
+		buff->eop_index = 0xffffU;
+	}
 }
 
 #define AQ_SKB_ALIGN SKB_DATA_ALIGN(sizeof(struct skb_shared_info))
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index 24523b5..5844078 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -65,7 +65,7 @@ struct __packed aq_ring_buff_s {
 	};
 	union {
 		struct {
-			u32 len:16;
+			u16 len;
 			u32 is_ip_cso:1;
 			u32 is_udp_cso:1;
 			u32 is_tcp_cso:1;
@@ -77,8 +77,10 @@ struct __packed aq_ring_buff_s {
 			u32 is_cleaned:1;
 			u32 is_error:1;
 			u32 rsvd3:6;
+			u16 eop_index;
+			u16 rsvd4;
 		};
-		u32 flags;
+		u64 flags;
 	};
 };
 
-- 
2.7.4
