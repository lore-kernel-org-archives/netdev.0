From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] net: aquantia: remove function aq_ring_tx_deinit
Date: Sat, 18 Feb 2017 12:27:12 +0100
Message-ID: <1487417232-4103-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: Simon.Edelhaus@aquantia.com, Pavel.Belous@aquantia.com,
        Alexey.Andriyanov@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:58028 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751162AbdBRL2U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 06:28:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both functions aq_ring_rx_deinit() and aq_ring_tx_clean() are almost
identical aside from an additional check in the latter.
Move that check from the function into its caller and replace
aq_ring_rx_deinit() with aq_ring_rx_deinit().

By doing this also adjust the functions return value from int to void
since it can never fail.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 33 +-----------------------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h |  3 +--
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c  | 14 ++++++----
 3 files changed, 11 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index dea9e9b..fed6ac5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -123,7 +123,7 @@ void aq_ring_tx_append_buffs(struct aq_ring_s *self,
 	}
 }
 
-int aq_ring_tx_clean(struct aq_ring_s *self)
+void aq_ring_tx_clean(struct aq_ring_s *self)
 {
 	struct device *dev = aq_nic_get_dev(self->aq_nic);
 
@@ -143,11 +143,6 @@ int aq_ring_tx_clean(struct aq_ring_s *self)
 		if (unlikely(buff->is_eop))
 			dev_kfree_skb_any(buff->skb);
 	}
-
-	if (aq_ring_avail_dx(self) > AQ_CFG_SKB_FRAGS_MAX)
-		aq_nic_ndev_queue_start(self->aq_nic, self->idx);
-
-	return 0;
 }
 
 static inline unsigned int aq_ring_dx_in_range(unsigned int h, unsigned int i,
@@ -333,32 +328,6 @@ void aq_ring_rx_deinit(struct aq_ring_s *self)
 err_exit:;
 }
 
-void aq_ring_tx_deinit(struct aq_ring_s *self)
-{
-	if (!self)
-		goto err_exit;
-
-	for (; self->sw_head != self->sw_tail;
-		self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
-		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
-		struct device *ndev = aq_nic_get_dev(self->aq_nic);
-
-		if (likely(buff->is_mapped)) {
-			if (unlikely(buff->is_sop)) {
-				dma_unmap_single(ndev, buff->pa, buff->len,
-						 DMA_TO_DEVICE);
-			} else {
-				dma_unmap_page(ndev, buff->pa, buff->len,
-					       DMA_TO_DEVICE);
-			}
-		}
-
-		if (unlikely(buff->is_eop))
-			dev_kfree_skb_any(buff->skb);
-	}
-err_exit:;
-}
-
 void aq_ring_free(struct aq_ring_s *self)
 {
 	if (!self)
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index 0ac3f9e..fb296b3 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -144,13 +144,12 @@ struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
 				   unsigned int idx,
 				   struct aq_nic_cfg_s *aq_nic_cfg);
 int aq_ring_init(struct aq_ring_s *self);
-void aq_ring_tx_deinit(struct aq_ring_s *self);
 void aq_ring_rx_deinit(struct aq_ring_s *self);
 void aq_ring_free(struct aq_ring_s *self);
 void aq_ring_tx_append_buffs(struct aq_ring_s *ring,
 			     struct aq_ring_buff_s *buffer,
 			     unsigned int buffers);
-int aq_ring_tx_clean(struct aq_ring_s *self);
+void aq_ring_tx_clean(struct aq_ring_s *self);
 int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget);
 int aq_ring_rx_fill(struct aq_ring_s *self);
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index cb30a63..ad5b4d4d 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -59,10 +59,14 @@ static int aq_vec_poll(struct napi_struct *napi, int budget)
 			}
 
 			if (ring[AQ_VEC_TX_ID].sw_head !=
-				ring[AQ_VEC_TX_ID].hw_head) {
-				err = aq_ring_tx_clean(&ring[AQ_VEC_TX_ID]);
-				if (err < 0)
-					goto err_exit;
+			    ring[AQ_VEC_TX_ID].hw_head) {
+				aq_ring_tx_clean(&ring[AQ_VEC_TX_ID]);
+
+				if (aq_ring_avail_dx(&ring[AQ_VEC_TX_ID]) >
+				    AQ_CFG_SKB_FRAGS_MAX) {
+					aq_nic_ndev_queue_start(self->aq_nic,
+						ring[AQ_VEC_TX_ID].idx);
+				}
 				was_tx_cleaned = true;
 			}
 
@@ -271,7 +275,7 @@ void aq_vec_deinit(struct aq_vec_s *self)
 
 	for (i = 0U, ring = self->ring[0];
 		self->tx_rings > i; ++i, ring = self->ring[i]) {
-		aq_ring_tx_deinit(&ring[AQ_VEC_TX_ID]);
+		aq_ring_tx_clean(&ring[AQ_VEC_TX_ID]);
 		aq_ring_rx_deinit(&ring[AQ_VEC_RX_ID]);
 	}
 err_exit:;
-- 
1.9.1
