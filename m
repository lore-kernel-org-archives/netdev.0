From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next] aquantia: Switch to use napi_gro_receive
Date: Thu,  3 Aug 2017 18:15:32 +0300
Message-ID: <5ba75da7aa9caa1feb85e65edd47965fe0226ab6.1501771297.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0077.outbound.protection.outlook.com ([104.47.32.77]:37857
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751230AbdHCPQK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 11:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Add support for GRO (generic receive offload) for aQuantia Atlantic driver.
This results in a perfomance improvement when GRO is enabled.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 7 +++++--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h | 5 ++++-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c  | 1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 9a08179..4b44575 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -134,7 +134,10 @@ static inline unsigned int aq_ring_dx_in_range(unsigned int h, unsigned int i,
 }
 
 #define AQ_SKB_ALIGN SKB_DATA_ALIGN(sizeof(struct skb_shared_info))
-int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
+int aq_ring_rx_clean(struct aq_ring_s *self,
+		     struct napi_struct *napi,
+		     int *work_done,
+		     int budget)
 {
 	struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
 	int err = 0;
@@ -240,7 +243,7 @@ int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
 
 		skb_record_rx_queue(skb, self->idx);
 
-		netif_receive_skb(skb);
+		napi_gro_receive(napi, skb);
 
 		++self->stats.rx.packets;
 		self->stats.rx.bytes += skb->len;
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
index eecd6d1..782176c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.h
@@ -148,7 +148,10 @@ int aq_ring_init(struct aq_ring_s *self);
 void aq_ring_rx_deinit(struct aq_ring_s *self);
 void aq_ring_free(struct aq_ring_s *self);
 void aq_ring_tx_clean(struct aq_ring_s *self);
-int aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget);
+int aq_ring_rx_clean(struct aq_ring_s *self,
+		     struct napi_struct *napi,
+		     int *work_done,
+		     int budget);
 int aq_ring_rx_fill(struct aq_ring_s *self);
 
 #endif /* AQ_RING_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
index ad5b4d4d..ec390c5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_vec.c
@@ -78,6 +78,7 @@ __acquires(&self->lock)
 			if (ring[AQ_VEC_RX_ID].sw_head !=
 				ring[AQ_VEC_RX_ID].hw_head) {
 				err = aq_ring_rx_clean(&ring[AQ_VEC_RX_ID],
+						       napi,
 						       &work_done,
 						       budget - work_done);
 				if (err < 0)
-- 
2.7.4
