From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 1/7] net:ethernet:aquantia: Extra spinlocks removed.
Date: Wed, 23 Aug 2017 17:05:02 +0300
Message-ID: <acf3a0f9bf9ed8fb29723abc6a13a78ab615d48d.1503496727.git.pavel.belous@aquantia.com>
References: <cover.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0040.outbound.protection.outlook.com ([104.47.36.40]:19310
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932080AbdHWOFj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:05:39 -0400
In-Reply-To: <cover.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This patch removes datapath spinlocks which does not perform any
useful work.

Fixes: 6e70637f9f1e ("net: ethernet: aquantia: Add ring support code")
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c   | 42 +++++++----------------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c  |  1 -
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h |  1 -
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c   | 11 ++----
 4 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 9ee1c50..08b7275 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -597,14 +597,11 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
 }
 
 int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
-__releases(&ring->lock)
-__acquires(&ring->lock)
 {
 	struct aq_ring_s *ring = NULL;
 	unsigned int frags = 0U;
 	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
 	unsigned int tc = 0U;
-	unsigned int trys = AQ_CFG_LOCK_TRYS;
 	int err = NETDEV_TX_OK;
 	bool is_nic_in_bad_state;
 
@@ -628,36 +625,21 @@ __acquires(&ring->lock)
 		goto err_exit;
 	}
 
-	do {
-		if (spin_trylock(&ring->header.lock)) {
-			frags = aq_nic_map_skb(self, skb, ring);
-
-			if (likely(frags)) {
-				err = self->aq_hw_ops.hw_ring_tx_xmit(
-								self->aq_hw,
-								ring, frags);
-				if (err >= 0) {
-					if (aq_ring_avail_dx(ring) <
-					    AQ_CFG_SKB_FRAGS_MAX + 1)
-						aq_nic_ndev_queue_stop(
-								self,
-								ring->idx);
-
-					++ring->stats.tx.packets;
-					ring->stats.tx.bytes += skb->len;
-				}
-			} else {
-				err = NETDEV_TX_BUSY;
-			}
+	frags = aq_nic_map_skb(self, skb, ring);
 
-			spin_unlock(&ring->header.lock);
-			break;
-		}
-	} while (--trys);
+	if (likely(frags)) {
+		err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
+						      ring,
+						      frags);
+		if (err >= 0) {
+			if (aq_ring_avail_dx(ring) < AQ_CFG_SKB_FRAGS_MAX + 1)
+				aq_nic_ndev_queue_stop(self, ring->idx);
 
-	if (!trys) {
+			++ring->stats.tx.packets;
+			ring->stats.tx.bytes += skb->len;
+		}
+	} else {
 		err = NETDEV_TX_BUSY;
-		goto err_exit;
 	}
 
 err_exit:
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 9a08179..ec5579f 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -101,7 +101,6 @@ int aq_ring_init(struct aq_ring_s *self)
 	self->hw_head = 0;
 	self->sw_head = 0;
 	self->sw_tail = 0;
-	spin_lock_init(&self->header.lock);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
index f6012b3..e12bcdf 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
@@ -17,7 +17,6 @@
 #define AQ_DIMOF(_ARY_)  ARRAY_SIZE(_ARY_)
 
 struct aq_obj_s {
-	spinlock_t lock; /* spinlock for nic/rings processing */
 	atomic_t flags;
 };
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index ad5b4d4d..fee446a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -34,8 +34,6 @@ struct aq_vec_s {
 #define AQ_VEC_RX_ID 1
 
 static int aq_vec_poll(struct napi_struct *napi, int budget)
-__releases(&self->lock)
-__acquires(&self->lock)
 {
 	struct aq_vec_s *self = container_of(napi, struct aq_vec_s, napi);
 	struct aq_ring_s *ring = NULL;
@@ -47,7 +45,7 @@ __acquires(&self->lock)
 
 	if (!self) {
 		err = -EINVAL;
-	} else if (spin_trylock(&self->header.lock)) {
+	} else {
 		for (i = 0U, ring = self->ring[0];
 			self->tx_rings > i; ++i, ring = self->ring[i]) {
 			if (self->aq_hw_ops->hw_ring_tx_head_update) {
@@ -105,11 +103,8 @@ __acquires(&self->lock)
 			self->aq_hw_ops->hw_irq_enable(self->aq_hw,
 					1U << self->aq_ring_param.vec_idx);
 		}
-
-err_exit:
-		spin_unlock(&self->header.lock);
 	}
-
+err_exit:
 	return work_done;
 }
 
@@ -185,8 +180,6 @@ int aq_vec_init(struct aq_vec_s *self, struct aq_hw_ops *aq_hw_ops,
 	self->aq_hw_ops = aq_hw_ops;
 	self->aq_hw = aq_hw;
 
-	spin_lock_init(&self->header.lock);
-
 	for (i = 0U, ring = self->ring[0];
 		self->tx_rings > i; ++i, ring = self->ring[i]) {
 		err = aq_ring_init(&ring[AQ_VEC_TX_ID]);
-- 
2.7.4
