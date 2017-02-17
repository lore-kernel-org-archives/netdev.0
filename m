From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 02/12] net: ethernet: aquantia: Removed busy_count field.
Date: Sat, 18 Feb 2017 00:07:24 +0300
Message-ID: <79f9f6857e80493c2b19a0ba01399b49eede4fdf.1487365317.git.pavel.belous@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0077.outbound.protection.outlook.com ([104.47.32.77]:52345
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935044AbdBQVJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:09 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

 busy_count field and is_busy flag is not needed at all.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c   | 11 -----------
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h |  1 -
 2 files changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index aa22a7c..a153750 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -122,14 +122,11 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	struct aq_nic_s *self = (struct aq_nic_s *)param;
 	struct net_device *ndev = aq_nic_get_ndev(self);
 	int err = 0;
-	bool is_busy = false;
 	unsigned int i = 0U;
 	struct aq_hw_link_status_s link_status;
 	struct aq_ring_stats_rx_s stats_rx;
 	struct aq_ring_stats_tx_s stats_tx;
 
-	atomic_inc(&self->header.busy_count);
-	is_busy = true;
 	if (aq_utils_obj_test(&self->header.flags, AQ_NIC_FLAGS_IS_NOT_READY))
 		goto err_exit;
 
@@ -170,8 +167,6 @@ static void aq_nic_service_timer_cb(unsigned long param)
 	ndev->stats.tx_errors = stats_tx.errors;
 
 err_exit:
-	if (is_busy)
-		atomic_dec(&self->header.busy_count);
 	mod_timer(&self->service_timer,
 		  jiffies + AQ_CFG_SERVICE_TIMER_INTERVAL);
 }
@@ -574,16 +569,12 @@ __acquires(&ring->lock)
 	unsigned int trys = AQ_CFG_LOCK_TRYS;
 	int err = 0;
 	bool is_nic_in_bad_state;
-	bool is_busy = false;
 	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
 
 	frags = skb_shinfo(skb)->nr_frags + 1;
 
 	ring = self->aq_ring_tx[AQ_NIC_TCVEC2RING(self, tc, vec)];
 
-	atomic_inc(&self->header.busy_count);
-	is_busy = true;
-
 	if (frags > AQ_CFG_SKB_FRAGS_MAX) {
 		dev_kfree_skb_any(skb);
 		goto err_exit;
@@ -629,8 +620,6 @@ __acquires(&ring->lock)
 	}
 
 err_exit:
-	if (is_busy)
-		atomic_dec(&self->header.busy_count);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
index 4446bd9..f6012b3 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_utils.h
@@ -19,7 +19,6 @@
 struct aq_obj_s {
 	spinlock_t lock; /* spinlock for nic/rings processing */
 	atomic_t flags;
-	atomic_t busy_count;
 };
 
 static inline void aq_utils_obj_set(atomic_t *flags, u32 mask)
-- 
2.7.4
