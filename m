From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net v2 2/4] net:ethernet:aquantia: Fix Tx queue hangups
Date: Mon, 25 Sep 2017 10:48:48 +0300
Message-ID: <741eecf97fcc91809cf25252ea25cfe128182b59.1506324091.git.igor.russkikh@aquantia.com>
References: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:41441
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbdIYHte (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 03:49:34 -0400
In-Reply-To: <cover.1506324091.git.igor.russkikh@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver did a poor job in managing its Tx queues: Sometimes it could stop
tx queues due to link down condition in aq_nic_xmit - but never waked up
them. That led to Tx path total suspend.
This patch fixes this and improves generic queue management:
- introduces queue restart counter
- uses generic netif_ interface to disable and enable tx path
- refactors link up/down condition and introduces dmesg log event when
  link changes.
- introduces new constant for minimum descriptors count required for queue
  wakeup

Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Igor Russkikh <igor.russkikh@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h  |  4 ++
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c  | 91 +++++++++++-------------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h  |  2 -
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 26 +++++++
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h |  4 ++
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c  |  8 +--
 6 files changed, 76 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
index 2149864..0fdaaa6 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_cfg.h
@@ -51,6 +51,10 @@
 
 #define AQ_CFG_SKB_FRAGS_MAX   32U
 
+/* Number of descriptors available in one ring to resume this ring queue
+ */
+#define AQ_CFG_RESTART_DESC_THRES   (AQ_CFG_SKB_FRAGS_MAX * 2)
+
 #define AQ_CFG_NAPI_WEIGHT     64U
 
 #define AQ_CFG_MULTICAST_ADDRESS_MAX     32U
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index bf26a59..072a550 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -119,6 +119,35 @@ int aq_nic_cfg_start(struct aq_nic_s *self)
 	return 0;
 }
 
+static int aq_nic_update_link_status(struct aq_nic_s *self)
+{
+	int err = self->aq_hw_ops.hw_get_link_status(self->aq_hw);
+
+	if (err)
+		return err;
+
+	if (self->link_status.mbps != self->aq_hw->aq_link_status.mbps)
+		pr_info("%s: link change old %d new %d\n",
+			AQ_CFG_DRV_NAME, self->link_status.mbps,
+			self->aq_hw->aq_link_status.mbps);
+
+	self->link_status = self->aq_hw->aq_link_status;
+	if (!netif_carrier_ok(self->ndev) && self->link_status.mbps) {
+		aq_utils_obj_set(&self->header.flags,
+				 AQ_NIC_FLAG_STARTED);
+		aq_utils_obj_clear(&self->header.flags,
+				   AQ_NIC_LINK_DOWN);
+		netif_carrier_on(self->ndev);
+		netif_tx_wake_all_queues(self->ndev);
+	}
+	if (netif_carrier_ok(self->ndev) && !self->link_status.mbps) {
+		netif_carrier_off(self->ndev);
+		netif_tx_disable(self->ndev);
+		aq_utils_obj_set(&self->header.flags, AQ_NIC_LINK_DOWN);
+	}
+	return 0;
+}
+
 static void aq_nic_service_timer_cb(unsigned long param)
 {
 	struct aq_nic_s *self = (struct aq_nic_s *)param;
@@ -131,26 +160,13 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	if (aq_utils_obj_test(&self->header.flags, AQ_NIC_FLAGS_IS_NOT_READY))
 		goto err_exit;
 
-	err = self->aq_hw_ops.hw_get_link_status(self->aq_hw);
-	if (err < 0)
+	err = aq_nic_update_link_status(self);
+	if (err)
 		goto err_exit;
 
-	self->link_status = self->aq_hw->aq_link_status;
-
 	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
 		    self->aq_nic_cfg.is_interrupt_moderation);
 
-	if (self->link_status.mbps) {
-		aq_utils_obj_set(&self->header.flags,
-				 AQ_NIC_FLAG_STARTED);
-		aq_utils_obj_clear(&self->header.flags,
-				   AQ_NIC_LINK_DOWN);
-		netif_carrier_on(self->ndev);
-	} else {
-		netif_carrier_off(self->ndev);
-		aq_utils_obj_set(&self->header.flags, AQ_NIC_LINK_DOWN);
-	}
-
 	memset(&stats_rx, 0U, sizeof(struct aq_ring_stats_rx_s));
 	memset(&stats_tx, 0U, sizeof(struct aq_ring_stats_tx_s));
 	for (i = AQ_DIMOF(self->aq_vec); i--;) {
@@ -240,7 +256,6 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
 int aq_nic_ndev_register(struct aq_nic_s *self)
 {
 	int err = 0;
-	unsigned int i = 0U;
 
 	if (!self->ndev) {
 		err = -EINVAL;
@@ -262,8 +277,7 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
 
 	netif_carrier_off(self->ndev);
 
-	for (i = AQ_CFG_VECS_MAX; i--;)
-		aq_nic_ndev_queue_stop(self, i);
+	netif_tx_disable(self->ndev);
 
 	err = register_netdev(self->ndev);
 	if (err < 0)
@@ -318,12 +332,8 @@ struct aq_nic_s *aq_nic_alloc_hot(struct net_device *ndev)
 		err = -EINVAL;
 		goto err_exit;
 	}
-	if (netif_running(ndev)) {
-		unsigned int i;
-
-		for (i = AQ_CFG_VECS_MAX; i--;)
-			netif_stop_subqueue(ndev, i);
-	}
+	if (netif_running(ndev))
+		netif_tx_disable(ndev);
 
 	for (self->aq_vecs = 0; self->aq_vecs < self->aq_nic_cfg.vecs;
 		self->aq_vecs++) {
@@ -383,16 +393,6 @@ int aq_nic_init(struct aq_nic_s *self)
 	return err;
 }
 
-void aq_nic_ndev_queue_start(struct aq_nic_s *self, unsigned int idx)
-{
-	netif_start_subqueue(self->ndev, idx);
-}
-
-void aq_nic_ndev_queue_stop(struct aq_nic_s *self, unsigned int idx)
-{
-	netif_stop_subqueue(self->ndev, idx);
-}
-
 int aq_nic_start(struct aq_nic_s *self)
 {
 	struct aq_vec_s *aq_vec = NULL;
@@ -451,10 +451,6 @@ int aq_nic_start(struct aq_nic_s *self)
 			goto err_exit;
 	}
 
-	for (i = 0U, aq_vec = self->aq_vec[0];
-		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
-		aq_nic_ndev_queue_start(self, i);
-
 	err = netif_set_real_num_tx_queues(self->ndev, self->aq_vecs);
 	if (err < 0)
 		goto err_exit;
@@ -463,6 +459,8 @@ int aq_nic_start(struct aq_nic_s *self)
 	if (err < 0)
 		goto err_exit;
 
+	netif_tx_start_all_queues(self->ndev);
+
 err_exit:
 	return err;
 }
@@ -602,7 +600,6 @@ int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
 	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
 	unsigned int tc = 0U;
 	int err = NETDEV_TX_OK;
-	bool is_nic_in_bad_state;
 
 	frags = skb_shinfo(skb)->nr_frags + 1;
 
@@ -613,13 +610,10 @@ int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
 		goto err_exit;
 	}
 
-	is_nic_in_bad_state = aq_utils_obj_test(&self->header.flags,
-						AQ_NIC_FLAGS_IS_NOT_TX_READY) ||
-						(aq_ring_avail_dx(ring) <
-						AQ_CFG_SKB_FRAGS_MAX);
+	aq_ring_update_queue_state(ring);
 
-	if (is_nic_in_bad_state) {
-		aq_nic_ndev_queue_stop(self, ring->idx);
+	/* Above status update may stop the queue. Check this. */
+	if (__netif_subqueue_stopped(self->ndev, ring->idx)) {
 		err = NETDEV_TX_BUSY;
 		goto err_exit;
 	}
@@ -631,9 +625,6 @@ int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
 						      ring,
 						      frags);
 		if (err >= 0) {
-			if (aq_ring_avail_dx(ring) < AQ_CFG_SKB_FRAGS_MAX + 1)
-				aq_nic_ndev_queue_stop(self, ring->idx);
-
 			++ring->stats.tx.packets;
 			ring->stats.tx.bytes += skb->len;
 		}
@@ -898,9 +889,7 @@ int aq_nic_stop(struct aq_nic_s *self)
 	struct aq_vec_s *aq_vec = NULL;
 	unsigned int i = 0U;
 
-	for (i = 0U, aq_vec = self->aq_vec[0];
-		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
-		aq_nic_ndev_queue_stop(self, i);
+	netif_tx_disable(self->ndev);
 
 	del_timer_sync(&self->service_timer);
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
index 7fc2a5e..0ddd556 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
@@ -83,8 +83,6 @@ struct net_device *aq_nic_get_ndev(struct aq_nic_s *self);
 int aq_nic_init(struct aq_nic_s *self);
 int aq_nic_cfg_start(struct aq_nic_s *self);
 int aq_nic_ndev_register(struct aq_nic_s *self);
-void aq_nic_ndev_queue_start(struct aq_nic_s *self, unsigned int idx);
-void aq_nic_ndev_queue_stop(struct aq_nic_s *self, unsigned int idx);
 void aq_nic_ndev_free(struct aq_nic_s *self);
 int aq_nic_start(struct aq_nic_s *self);
 int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 4eee199..02f79b0 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -104,6 +104,32 @@ int aq_ring_init(struct aq_ring_s *self)
 	return 0;
 }
 
+void aq_ring_update_queue_state(struct aq_ring_s *ring)
+{
+	if (aq_ring_avail_dx(ring) <= AQ_CFG_SKB_FRAGS_MAX)
+		aq_ring_queue_stop(ring);
+	else if (aq_ring_avail_dx(ring) > AQ_CFG_RESTART_DESC_THRES)
+		aq_ring_queue_wake(ring);
+}
+
+void aq_ring_queue_wake(struct aq_ring_s *ring)
+{
+	struct net_device *ndev = aq_nic_get_ndev(ring->aq_nic);
+
+	if (__netif_subqueue_stopped(ndev, ring->idx)) {
+		netif_wake_subqueue(ndev, ring->idx);
+		ring->stats.tx.queue_restarts++;
+	}
+}
+
+void aq_ring_queue_stop(struct aq_ring_s *ring)
+{
+	struct net_device *ndev = aq_nic_get_ndev(ring->aq_nic);
+
+	if (!__netif_subqueue_stopped(ndev, ring->idx))
+		netif_stop_subqueue(ndev, ring->idx);
+}
+
 void aq_ring_tx_clean(struct aq_ring_s *self)
 {
 	struct device *dev = aq_nic_get_dev(self->aq_nic);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index 782176c..24523b5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -94,6 +94,7 @@ struct aq_ring_stats_tx_s {
 	u64 errors;
 	u64 packets;
 	u64 bytes;
+	u64 queue_restarts;
 };
 
 union aq_ring_stats_s {
@@ -147,6 +148,9 @@ struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
 int aq_ring_init(struct aq_ring_s *self);
 void aq_ring_rx_deinit(struct aq_ring_s *self);
 void aq_ring_free(struct aq_ring_s *self);
+void aq_ring_update_queue_state(struct aq_ring_s *ring);
+void aq_ring_queue_wake(struct aq_ring_s *ring);
+void aq_ring_queue_stop(struct aq_ring_s *ring);
 void aq_ring_tx_clean(struct aq_ring_s *self);
 int aq_ring_rx_clean(struct aq_ring_s *self,
 		     struct napi_struct *napi,
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index ebf5880..305ff8f 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -59,12 +59,7 @@ static int aq_vec_poll(struct napi_struct *napi, int budget)
 			if (ring[AQ_VEC_TX_ID].sw_head !=
 			    ring[AQ_VEC_TX_ID].hw_head) {
 				aq_ring_tx_clean(&ring[AQ_VEC_TX_ID]);
-
-				if (aq_ring_avail_dx(&ring[AQ_VEC_TX_ID]) >
-				    AQ_CFG_SKB_FRAGS_MAX) {
-					aq_nic_ndev_queue_start(self->aq_nic,
-						ring[AQ_VEC_TX_ID].idx);
-				}
+				aq_ring_update_queue_state(&ring[AQ_VEC_TX_ID]);
 				was_tx_cleaned = true;
 			}
 
@@ -364,6 +359,7 @@ void aq_vec_add_stats(struct aq_vec_s *self,
 		stats_tx->packets += tx->packets;
 		stats_tx->bytes += tx->bytes;
 		stats_tx->errors += tx->errors;
+		stats_tx->queue_restarts += tx->queue_restarts;
 	}
 }
 
-- 
2.7.4
