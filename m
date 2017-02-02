From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] be2net: get rid of custom busy poll code
Date: Thu, 02 Feb 2017 10:16:00 -0800
Message-ID: <1486059360.21871.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34962 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdBBSQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:16:02 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so2443351pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:16:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Compared to custom busy_poll, the generic NAPI one is better, since
it allows to use GRO, and it removes a lot of code and extra locked
operations in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    5 
 drivers/net/ethernet/emulex/benet/be_main.c |  151 +-----------------
 2 files changed, 9 insertions(+), 147 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4c30c44b242e67e59d52f5cc00a230ba81ba68d4..d49528ad7821d202355ef9b1a18d58e56794b162 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -226,11 +226,6 @@ struct be_aic_obj {		/* Adaptive interrupt coalescing (AIC) info */
 	u64 tx_reqs_prev;	/* Used to calculate TX pps */
 };
 
-enum {
-	NAPI_POLLING,
-	BUSY_POLLING
-};
-
 struct be_mcc_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b3a054026e71ea685d136c5c84be7d0c4500b814..2fad56e71c28d2140ee139bb77277bac5d87a517 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3061,7 +3061,7 @@ static inline bool do_gro(struct be_rx_compl_info *rxcp)
 }
 
 static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
-			 int budget, int polling)
+			 int budget)
 {
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_queue_info *rx_cq = &rxo->cq;
@@ -3093,8 +3093,7 @@ static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
 			goto loop_continue;
 		}
 
-		/* Don't do gro when we're busy_polling */
-		if (do_gro(rxcp) && polling != BUSY_POLLING)
+		if (do_gro(rxcp))
 			be_rx_compl_process_gro(rxo, napi, rxcp);
 		else
 			be_rx_compl_process(rxo, napi, rxcp);
@@ -3192,106 +3191,6 @@ static void be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 	}
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline bool be_lock_napi(struct be_eq_obj *eqo)
-{
-	bool status = true;
-
-	spin_lock(&eqo->lock); /* BH is already disabled */
-	if (eqo->state & BE_EQ_LOCKED) {
-		WARN_ON(eqo->state & BE_EQ_NAPI);
-		eqo->state |= BE_EQ_NAPI_YIELD;
-		status = false;
-	} else {
-		eqo->state = BE_EQ_NAPI;
-	}
-	spin_unlock(&eqo->lock);
-	return status;
-}
-
-static inline void be_unlock_napi(struct be_eq_obj *eqo)
-{
-	spin_lock(&eqo->lock); /* BH is already disabled */
-
-	WARN_ON(eqo->state & (BE_EQ_POLL | BE_EQ_NAPI_YIELD));
-	eqo->state = BE_EQ_IDLE;
-
-	spin_unlock(&eqo->lock);
-}
-
-static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
-{
-	bool status = true;
-
-	spin_lock_bh(&eqo->lock);
-	if (eqo->state & BE_EQ_LOCKED) {
-		eqo->state |= BE_EQ_POLL_YIELD;
-		status = false;
-	} else {
-		eqo->state |= BE_EQ_POLL;
-	}
-	spin_unlock_bh(&eqo->lock);
-	return status;
-}
-
-static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
-{
-	spin_lock_bh(&eqo->lock);
-
-	WARN_ON(eqo->state & (BE_EQ_NAPI));
-	eqo->state = BE_EQ_IDLE;
-
-	spin_unlock_bh(&eqo->lock);
-}
-
-static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
-{
-	spin_lock_init(&eqo->lock);
-	eqo->state = BE_EQ_IDLE;
-}
-
-static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
-{
-	local_bh_disable();
-
-	/* It's enough to just acquire napi lock on the eqo to stop
-	 * be_busy_poll() from processing any queueus.
-	 */
-	while (!be_lock_napi(eqo))
-		mdelay(1);
-
-	local_bh_enable();
-}
-
-#else /* CONFIG_NET_RX_BUSY_POLL */
-
-static inline bool be_lock_napi(struct be_eq_obj *eqo)
-{
-	return true;
-}
-
-static inline void be_unlock_napi(struct be_eq_obj *eqo)
-{
-}
-
-static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
-{
-	return false;
-}
-
-static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
-{
-}
-
-static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
-{
-}
-
-static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
-{
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 int be_poll(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
@@ -3306,18 +3205,13 @@ int be_poll(struct napi_struct *napi, int budget)
 	for_all_tx_queues_on_eq(adapter, eqo, txo, i)
 		be_process_tx(adapter, txo, i);
 
-	if (be_lock_napi(eqo)) {
-		/* This loop will iterate twice for EQ0 in which
-		 * completions of the last RXQ (default one) are also processed
-		 * For other EQs the loop iterates only once
-		 */
-		for_all_rx_queues_on_eq(adapter, eqo, rxo, i) {
-			work = be_process_rx(rxo, napi, budget, NAPI_POLLING);
-			max_work = max(work, max_work);
-		}
-		be_unlock_napi(eqo);
-	} else {
-		max_work = budget;
+	/* This loop will iterate twice for EQ0 in which
+	 * completions of the last RXQ (default one) are also processed
+	 * For other EQs the loop iterates only once
+	 */
+	for_all_rx_queues_on_eq(adapter, eqo, rxo, i) {
+		work = be_process_rx(rxo, napi, budget);
+		max_work = max(work, max_work);
 	}
 
 	if (is_mcc_eqo(eqo))
@@ -3341,28 +3235,6 @@ int be_poll(struct napi_struct *napi, int budget)
 	return max_work;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int be_busy_poll(struct napi_struct *napi)
-{
-	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
-	struct be_adapter *adapter = eqo->adapter;
-	struct be_rx_obj *rxo;
-	int i, work = 0;
-
-	if (!be_lock_busy_poll(eqo))
-		return LL_FLUSH_BUSY;
-
-	for_all_rx_queues_on_eq(adapter, eqo, rxo, i) {
-		work = be_process_rx(rxo, napi, 4, BUSY_POLLING);
-		if (work)
-			break;
-	}
-
-	be_unlock_busy_poll(eqo);
-	return work;
-}
-#endif
-
 void be_detect_error(struct be_adapter *adapter)
 {
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
@@ -3665,7 +3537,6 @@ static int be_close(struct net_device *netdev)
 	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
 		for_all_evt_queues(adapter, eqo, i) {
 			napi_disable(&eqo->napi);
-			be_disable_busy_poll(eqo);
 		}
 		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
 	}
@@ -3820,7 +3691,6 @@ static int be_open(struct net_device *netdev)
 
 	for_all_evt_queues(adapter, eqo, i) {
 		napi_enable(&eqo->napi);
-		be_enable_busy_poll(eqo);
 		be_eq_notify(adapter, eqo->q.id, true, true, 0, 0);
 	}
 	adapter->flags |= BE_FLAGS_NAPI_ENABLED;
@@ -5222,9 +5092,6 @@ static const struct net_device_ops be_netdev_ops = {
 #endif
 	.ndo_bridge_setlink	= be_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= be_ndo_bridge_getlink,
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= be_busy_poll,
-#endif
 	.ndo_udp_tunnel_add	= be_add_vxlan_port,
 	.ndo_udp_tunnel_del	= be_del_vxlan_port,
 	.ndo_features_check	= be_features_check,
