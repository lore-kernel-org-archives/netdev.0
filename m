From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next] be2net: add support for ndo_busy_poll
Date: Thu, 24 Oct 2013 11:17:18 +0530
Message-ID: <1382593638-8079-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:31065 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3JXFm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 01:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes:
- ndo_busy_poll implementation
- Locking between napi and busy_poll
- Fix rx_post_starvation (replenish rx-queues in out-of-mememory scenario)
  logic to accomodate busy_poll.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  122 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   86 +++++++++++++++----
 2 files changed, 189 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 1bce77f..b2765eb 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -199,6 +199,19 @@ struct be_eq_obj {
 	u16 spurious_intr;
 	struct napi_struct napi;
 	struct be_adapter *adapter;
+
+#ifdef CONFIG_NET_RX_BUSY_POLL
+#define BE_EQ_IDLE		0
+#define BE_EQ_NAPI		1	/* napi owns this EQ */
+#define BE_EQ_POLL		2	/* poll owns this EQ */
+#define BE_EQ_LOCKED		(BE_EQ_NAPI | BE_EQ_POLL)
+#define BE_EQ_NAPI_YIELD	4	/* napi yielded this EQ */
+#define BE_EQ_POLL_YIELD	8	/* poll yielded this EQ */
+#define BE_EQ_YIELD		(BE_EQ_NAPI_YIELD | BE_EQ_POLL_YIELD)
+#define BE_EQ_USER_PEND		(BE_EQ_POLL | BE_EQ_POLL_YIELD)
+	unsigned int state;
+	spinlock_t lock;	/* lock to serialize napi and busy-poll */
+#endif  /* CONFIG_NET_RX_BUSY_POLL */
 } ____cacheline_aligned_in_smp;
 
 struct be_aic_obj {		/* Adaptive interrupt coalescing (AIC) info */
@@ -212,6 +225,11 @@ struct be_aic_obj {		/* Adaptive interrupt coalescing (AIC) info */
 	u64 tx_reqs_prev;	/* Used to calculate TX pps */
 };
 
+enum {
+	NAPI_POLLING,
+	BUSY_POLLING
+};
+
 struct be_mcc_obj {
 	struct be_queue_info q;
 	struct be_queue_info cq;
@@ -561,6 +579,10 @@ extern const struct ethtool_ops be_ethtool_ops;
 	for (i = 0, eqo = &adapter->eq_obj[i]; i < adapter->num_evt_qs; \
 		i++, eqo++)
 
+#define for_all_rx_queues_on_eq(adapter, eqo, rxo, i)			\
+	for (i = eqo->idx, rxo = &adapter->rx_obj[i]; i < adapter->num_rx_qs;\
+		 i += adapter->num_evt_qs, rxo += adapter->num_evt_qs)
+
 #define is_mcc_eqo(eqo)			(eqo->idx == 0)
 #define mcc_eqo(adapter)		(&adapter->eq_obj[0])
 
@@ -711,6 +733,106 @@ static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
 	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static inline bool be_lock_napi(struct be_eq_obj *eqo)
+{
+	bool status = true;
+
+	spin_lock(&eqo->lock); /* BH is already disabled */
+	if (eqo->state & BE_EQ_LOCKED) {
+		WARN_ON(eqo->state & BE_EQ_NAPI);
+		eqo->state |= BE_EQ_NAPI_YIELD;
+		status = false;
+	} else {
+		eqo->state = BE_EQ_NAPI;
+	}
+	spin_unlock(&eqo->lock);
+	return status;
+}
+
+static inline void be_unlock_napi(struct be_eq_obj *eqo)
+{
+	spin_lock(&eqo->lock); /* BH is already disabled */
+
+	WARN_ON(eqo->state & (BE_EQ_POLL | BE_EQ_NAPI_YIELD));
+	eqo->state = BE_EQ_IDLE;
+
+	spin_unlock(&eqo->lock);
+}
+
+static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+{
+	bool status = true;
+
+	spin_lock_bh(&eqo->lock);
+	if (eqo->state & BE_EQ_LOCKED) {
+		eqo->state |= BE_EQ_POLL_YIELD;
+		status = false;
+	} else {
+		eqo->state |= BE_EQ_POLL;
+	}
+	spin_unlock_bh(&eqo->lock);
+	return status;
+}
+
+static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+{
+	spin_lock_bh(&eqo->lock);
+
+	WARN_ON(eqo->state & (BE_EQ_NAPI));
+	eqo->state = BE_EQ_IDLE;
+
+	spin_unlock_bh(&eqo->lock);
+}
+
+static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+{
+	spin_lock_init(&eqo->lock);
+	eqo->state = BE_EQ_IDLE;
+}
+
+static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+{
+	local_bh_disable();
+
+	/* It's enough to just acquire napi lock on the eqo to stop
+	 * be_busy_poll() from processing any queueus.
+	 */
+	while (!be_lock_napi(eqo))
+		mdelay(1);
+
+	local_bh_enable();
+}
+
+#else /* CONFIG_NET_RX_BUSY_POLL */
+
+static inline bool be_lock_napi(struct be_eq_obj *eqo)
+{
+	return true;
+}
+
+static inline void be_unlock_napi(struct be_eq_obj *eqo)
+{
+}
+
+static inline bool be_lock_busy_poll(struct be_eq_obj *eqo)
+{
+	return false;
+}
+
+static inline void be_unlock_busy_poll(struct be_eq_obj *eqo)
+{
+}
+
+static inline void be_enable_busy_poll(struct be_eq_obj *eqo)
+{
+}
+
+static inline void be_disable_busy_poll(struct be_eq_obj *eqo)
+{
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		  u16 num_popped);
 void be_link_status_update(struct be_adapter *adapter, u8 link_status);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 393e3dc..bb1cd55 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -22,6 +22,7 @@
 #include <asm/div64.h>
 #include <linux/aer.h>
 #include <linux/if_bridge.h>
+#include <net/busy_poll.h>
 
 MODULE_VERSION(DRV_VER);
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
@@ -1556,7 +1557,7 @@ static void skb_fill_rx_data(struct be_rx_obj *rxo, struct sk_buff *skb,
 }
 
 /* Process the RX completion indicated by rxcp when GRO is disabled */
-static void be_rx_compl_process(struct be_rx_obj *rxo,
+static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 				struct be_rx_compl_info *rxcp)
 {
 	struct be_adapter *adapter = rxo->adapter;
@@ -1581,7 +1582,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
-
+	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
@@ -1639,6 +1640,7 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
+	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rxcp->vlan_tag);
@@ -1819,6 +1821,8 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 
 	if (posted) {
 		atomic_add(posted, &rxq->used);
+		if (rxo->rx_post_starved)
+			rxo->rx_post_starved = false;
 		be_rxq_notify(adapter, rxq->id, posted);
 	} else if (atomic_read(&rxq->used) == 0) {
 		/* Let be_worker replenish when memory is available */
@@ -2021,6 +2025,7 @@ static void be_evt_queues_destroy(struct be_adapter *adapter)
 		if (eqo->q.created) {
 			be_eq_clean(eqo);
 			be_cmd_q_destroy(adapter, &eqo->q, QTYPE_EQ);
+			napi_hash_del(&eqo->napi);
 			netif_napi_del(&eqo->napi);
 		}
 		be_queue_free(adapter, &eqo->q);
@@ -2262,7 +2267,7 @@ static inline bool do_gro(struct be_rx_compl_info *rxcp)
 }
 
 static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
-			int budget)
+			int budget, int polling)
 {
 	struct be_adapter *adapter = rxo->adapter;
 	struct be_queue_info *rx_cq = &rxo->cq;
@@ -2293,19 +2298,27 @@ static int be_process_rx(struct be_rx_obj *rxo, struct napi_struct *napi,
 			goto loop_continue;
 		}
 
-		if (do_gro(rxcp))
+		/* Don't do gro when we're busy_polling */
+		if (do_gro(rxcp) && polling != BUSY_POLLING)
 			be_rx_compl_process_gro(rxo, napi, rxcp);
 		else
-			be_rx_compl_process(rxo, rxcp);
+			be_rx_compl_process(rxo, napi, rxcp);
+
 loop_continue:
 		be_rx_stats_update(rxo, rxcp);
 	}
 
 	if (work_done) {
+		gfp_t gfp = (polling == BUSY_POLLING) ? GFP_KERNEL : GFP_ATOMIC;
+
 		be_cq_notify(adapter, rx_cq->id, true, work_done);
 
-		if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
-			be_post_rx_frags(rxo, GFP_ATOMIC);
+		/* When an rx-obj gets into post_starved state, just
+		 * let be_worker do the posting.
+		 */
+		if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM &&
+		    !rxo->rx_post_starved)
+			be_post_rx_frags(rxo, gfp);
 	}
 
 	return work_done;
@@ -2349,6 +2362,7 @@ int be_poll(struct napi_struct *napi, int budget)
 	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
 	struct be_adapter *adapter = eqo->adapter;
 	int max_work = 0, work, i, num_evts;
+	struct be_rx_obj *rxo;
 	bool tx_done;
 
 	num_evts = events_get(eqo);
@@ -2361,13 +2375,18 @@ int be_poll(struct napi_struct *napi, int budget)
 			max_work = budget;
 	}
 
-	/* This loop will iterate twice for EQ0 in which
-	 * completions of the last RXQ (default one) are also processed
-	 * For other EQs the loop iterates only once
-	 */
-	for (i = eqo->idx; i < adapter->num_rx_qs; i += adapter->num_evt_qs) {
-		work = be_process_rx(&adapter->rx_obj[i], napi, budget);
-		max_work = max(work, max_work);
+	if (be_lock_napi(eqo)) {
+		/* This loop will iterate twice for EQ0 in which
+		 * completions of the last RXQ (default one) are also processed
+		 * For other EQs the loop iterates only once
+		 */
+		for_all_rx_queues_on_eq(adapter, eqo, rxo, i) {
+			work = be_process_rx(rxo, napi, budget, NAPI_POLLING);
+			max_work = max(work, max_work);
+		}
+		be_unlock_napi(eqo);
+	} else {
+		max_work = budget;
 	}
 
 	if (is_mcc_eqo(eqo))
@@ -2383,6 +2402,28 @@ int be_poll(struct napi_struct *napi, int budget)
 	return max_work;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static int be_busy_poll(struct napi_struct *napi)
+{
+	struct be_eq_obj *eqo = container_of(napi, struct be_eq_obj, napi);
+	struct be_adapter *adapter = eqo->adapter;
+	struct be_rx_obj *rxo;
+	int i, work = 0;
+
+	if (!be_lock_busy_poll(eqo))
+		return LL_FLUSH_BUSY;
+
+	for_all_rx_queues_on_eq(adapter, eqo, rxo, i) {
+		work = be_process_rx(rxo, napi, 4, BUSY_POLLING);
+		if (work)
+			break;
+	}
+
+	be_unlock_busy_poll(eqo);
+	return work;
+}
+#endif
+
 void be_detect_error(struct be_adapter *adapter)
 {
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
@@ -2614,9 +2655,11 @@ static int be_close(struct net_device *netdev)
 
 	be_roce_dev_close(adapter);
 
-	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
-		for_all_evt_queues(adapter, eqo, i)
+	for_all_evt_queues(adapter, eqo, i) {
+		if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
 			napi_disable(&eqo->napi);
+			be_disable_busy_poll(eqo);
+		}
 		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
 	}
 
@@ -2727,6 +2770,7 @@ static int be_open(struct net_device *netdev)
 
 	for_all_evt_queues(adapter, eqo, i) {
 		napi_enable(&eqo->napi);
+		be_enable_busy_poll(eqo);
 		be_eq_notify(adapter, eqo->q.id, true, false, 0);
 	}
 	adapter->flags |= BE_FLAGS_NAPI_ENABLED;
@@ -3989,6 +4033,9 @@ static const struct net_device_ops be_netdev_ops = {
 #endif
 	.ndo_bridge_setlink	= be_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= be_ndo_bridge_getlink,
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= be_busy_poll
+#endif
 };
 
 static void be_netdev_init(struct net_device *netdev)
@@ -4376,10 +4423,11 @@ static void be_worker(struct work_struct *work)
 		be_cmd_get_die_temperature(adapter);
 
 	for_all_rx_queues(adapter, rxo, i) {
-		if (rxo->rx_post_starved) {
-			rxo->rx_post_starved = false;
+		/* Replenish RX-queues starved due to memory
+		 * allocation failures.
+		 */
+		if (rxo->rx_post_starved)
 			be_post_rx_frags(rxo, GFP_KERNEL);
-		}
 	}
 
 	be_eqd_update(adapter);
-- 
1.7.1
