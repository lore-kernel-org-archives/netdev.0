From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 01/14] bnxt_en: Remove busy poll logic in the driver.
Date: Thu, 29 Dec 2016 12:13:31 -0500
Message-ID: <1483031624-20076-2-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34279 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752912AbcL2ROB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:01 -0500
Received: by mail-pg0-f48.google.com with SMTP id y62so116419483pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:00 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use native NAPI polling instead.  The next patch will complete the work
by switching to use napi_complete_done()

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 53 +----------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 99 -------------------------------
 2 files changed, 3 insertions(+), 149 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9608cb4..b53f958 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -39,9 +39,6 @@
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <net/udp_tunnel.h>
-#ifdef CONFIG_NET_RX_BUSY_POLL
-#include <net/busy_poll.h>
-#endif
 #include <linux/workqueue.h>
 #include <linux/prefetch.h>
 #include <linux/cache.h>
@@ -1356,11 +1353,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 		rc = -ENOMEM;
 		if (likely(skb)) {
 			skb_record_rx_queue(skb, bnapi->index);
-			skb_mark_napi_id(skb, &bnapi->napi);
-			if (bnxt_busy_polling(bnapi))
-				netif_receive_skb(skb);
-			else
-				napi_gro_receive(&bnapi->napi, skb);
+			napi_gro_receive(&bnapi->napi, skb);
 			rc = 1;
 		}
 		goto next_rx_no_prod;
@@ -1460,11 +1453,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	}
 
 	skb_record_rx_queue(skb, bnapi->index);
-	skb_mark_napi_id(skb, &bnapi->napi);
-	if (bnxt_busy_polling(bnapi))
-		netif_receive_skb(skb);
-	else
-		napi_gro_receive(&bnapi->napi, skb);
+	napi_gro_receive(&bnapi->napi, skb);
 	rc = 1;
 
 next_rx:
@@ -1782,9 +1771,6 @@ static int bnxt_poll(struct napi_struct *napi, int budget)
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
 	int work_done = 0;
 
-	if (!bnxt_lock_napi(bnapi))
-		return budget;
-
 	while (1) {
 		work_done += bnxt_poll_work(bp, bnapi, budget - work_done);
 
@@ -1798,36 +1784,9 @@ static int bnxt_poll(struct napi_struct *napi, int budget)
 		}
 	}
 	mmiowb();
-	bnxt_unlock_napi(bnapi);
 	return work_done;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int bnxt_busy_poll(struct napi_struct *napi)
-{
-	struct bnxt_napi *bnapi = container_of(napi, struct bnxt_napi, napi);
-	struct bnxt *bp = bnapi->bp;
-	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-	int rx_work, budget = 4;
-
-	if (atomic_read(&bp->intr_sem) != 0)
-		return LL_FLUSH_FAILED;
-
-	if (!bp->link_info.link_up)
-		return LL_FLUSH_FAILED;
-
-	if (!bnxt_lock_poll(bnapi))
-		return LL_FLUSH_BUSY;
-
-	rx_work = bnxt_poll_work(bp, bnapi, budget);
-
-	BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
-
-	bnxt_unlock_poll(bnapi);
-	return rx_work;
-}
-#endif
-
 static void bnxt_free_tx_skbs(struct bnxt *bp)
 {
 	int i, max_idx;
@@ -5094,10 +5053,8 @@ static void bnxt_disable_napi(struct bnxt *bp)
 	if (!bp->bnapi)
 		return;
 
-	for (i = 0; i < bp->cp_nr_rings; i++) {
+	for (i = 0; i < bp->cp_nr_rings; i++)
 		napi_disable(&bp->bnapi[i]->napi);
-		bnxt_disable_poll(bp->bnapi[i]);
-	}
 }
 
 static void bnxt_enable_napi(struct bnxt *bp)
@@ -5106,7 +5063,6 @@ static void bnxt_enable_napi(struct bnxt *bp)
 
 	for (i = 0; i < bp->cp_nr_rings; i++) {
 		bp->bnapi[i]->in_reset = false;
-		bnxt_enable_poll(bp->bnapi[i]);
 		napi_enable(&bp->bnapi[i]->napi);
 	}
 }
@@ -6765,9 +6721,6 @@ static void bnxt_udp_tunnel_del(struct net_device *dev,
 #endif
 	.ndo_udp_tunnel_add	= bnxt_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= bnxt_udp_tunnel_del,
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= bnxt_busy_poll,
-#endif
 };
 
 static void bnxt_remove_one(struct pci_dev *pdev)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 16defe9..fddc316 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -654,21 +654,9 @@ struct bnxt_napi {
 	struct bnxt_rx_ring_info	*rx_ring;
 	struct bnxt_tx_ring_info	*tx_ring;
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	atomic_t		poll_state;
-#endif
 	bool			in_reset;
 };
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-enum bnxt_poll_state_t {
-	BNXT_STATE_IDLE = 0,
-	BNXT_STATE_NAPI,
-	BNXT_STATE_POLL,
-	BNXT_STATE_DISABLE,
-};
-#endif
-
 struct bnxt_irq {
 	irq_handler_t	handler;
 	unsigned int	vector;
@@ -1141,93 +1129,6 @@ struct bnxt {
 	((offsetof(struct tx_port_stats, counter) +	\
 	  sizeof(struct rx_port_stats) + 512) / 8)
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline void bnxt_enable_poll(struct bnxt_napi *bnapi)
-{
-	atomic_set(&bnapi->poll_state, BNXT_STATE_IDLE);
-}
-
-/* called from the NAPI poll routine to get ownership of a bnapi */
-static inline bool bnxt_lock_napi(struct bnxt_napi *bnapi)
-{
-	int rc = atomic_cmpxchg(&bnapi->poll_state, BNXT_STATE_IDLE,
-				BNXT_STATE_NAPI);
-
-	return rc == BNXT_STATE_IDLE;
-}
-
-static inline void bnxt_unlock_napi(struct bnxt_napi *bnapi)
-{
-	atomic_set(&bnapi->poll_state, BNXT_STATE_IDLE);
-}
-
-/* called from the busy poll routine to get ownership of a bnapi */
-static inline bool bnxt_lock_poll(struct bnxt_napi *bnapi)
-{
-	int rc = atomic_cmpxchg(&bnapi->poll_state, BNXT_STATE_IDLE,
-				BNXT_STATE_POLL);
-
-	return rc == BNXT_STATE_IDLE;
-}
-
-static inline void bnxt_unlock_poll(struct bnxt_napi *bnapi)
-{
-	atomic_set(&bnapi->poll_state, BNXT_STATE_IDLE);
-}
-
-static inline bool bnxt_busy_polling(struct bnxt_napi *bnapi)
-{
-	return atomic_read(&bnapi->poll_state) == BNXT_STATE_POLL;
-}
-
-static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
-{
-	int old;
-
-	while (1) {
-		old = atomic_cmpxchg(&bnapi->poll_state, BNXT_STATE_IDLE,
-				     BNXT_STATE_DISABLE);
-		if (old == BNXT_STATE_IDLE)
-			break;
-		usleep_range(500, 5000);
-	}
-}
-
-#else
-
-static inline void bnxt_enable_poll(struct bnxt_napi *bnapi)
-{
-}
-
-static inline bool bnxt_lock_napi(struct bnxt_napi *bnapi)
-{
-	return true;
-}
-
-static inline void bnxt_unlock_napi(struct bnxt_napi *bnapi)
-{
-}
-
-static inline bool bnxt_lock_poll(struct bnxt_napi *bnapi)
-{
-	return false;
-}
-
-static inline void bnxt_unlock_poll(struct bnxt_napi *bnapi)
-{
-}
-
-static inline bool bnxt_busy_polling(struct bnxt_napi *bnapi)
-{
-	return false;
-}
-
-static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
-{
-}
-
-#endif
-
 #define I2C_DEV_ADDR_A0				0xa0
 #define I2C_DEV_ADDR_A2				0xa2
 #define SFP_EEPROM_SFF_8472_COMP_ADDR		0x5e
-- 
1.8.3.1
