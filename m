From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] cxgb4: get rid of custom busy poll code
Date: Thu, 02 Feb 2017 11:44:27 -0800
Message-ID: <1486064667.21871.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35189 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBBTot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 14:44:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so2618105pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 11:44:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In linux-4.5, busy polling was implemented in core
NAPI stack, meaning that all custom implementation can
be removed from drivers.

Not only we remove lot of code, we also remove one spin_lock()
from driver fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  113 --------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   16 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c  |   12 -
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   39 ----
 4 files changed, 6 insertions(+), 174 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ccb455f14d08b94542252287f48ce24f81e5c4ab..163543b1ea0bf1bec215f0613a6bce2a729fa337 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -586,22 +586,6 @@ struct sge_rspq {                   /* state for an SGE response queue */
 	rspq_handler_t handler;
 	rspq_flush_handler_t flush_handler;
 	struct t4_lro_mgr lro_mgr;
-#ifdef CONFIG_NET_RX_BUSY_POLL
-#define CXGB_POLL_STATE_IDLE		0
-#define CXGB_POLL_STATE_NAPI		BIT(0) /* NAPI owns this poll */
-#define CXGB_POLL_STATE_POLL		BIT(1) /* poll owns this poll */
-#define CXGB_POLL_STATE_NAPI_YIELD	BIT(2) /* NAPI yielded this poll */
-#define CXGB_POLL_STATE_POLL_YIELD	BIT(3) /* poll yielded this poll */
-#define CXGB_POLL_YIELD			(CXGB_POLL_STATE_NAPI_YIELD |   \
-					 CXGB_POLL_STATE_POLL_YIELD)
-#define CXGB_POLL_LOCKED		(CXGB_POLL_STATE_NAPI |         \
-					 CXGB_POLL_STATE_POLL)
-#define CXGB_POLL_USER_PEND		(CXGB_POLL_STATE_POLL |         \
-					 CXGB_POLL_STATE_POLL_YIELD)
-	unsigned int bpoll_state;
-	spinlock_t bpoll_lock;		/* lock for busy poll */
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 };
 
 struct sge_eth_stats {              /* Ethernet queue statistics */
@@ -1173,102 +1157,6 @@ static inline struct adapter *netdev2adap(const struct net_device *dev)
 	return netdev2pinfo(dev)->adapter;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline void cxgb_busy_poll_init_lock(struct sge_rspq *q)
-{
-	spin_lock_init(&q->bpoll_lock);
-	q->bpoll_state = CXGB_POLL_STATE_IDLE;
-}
-
-static inline bool cxgb_poll_lock_napi(struct sge_rspq *q)
-{
-	bool rc = true;
-
-	spin_lock(&q->bpoll_lock);
-	if (q->bpoll_state & CXGB_POLL_LOCKED) {
-		q->bpoll_state |= CXGB_POLL_STATE_NAPI_YIELD;
-		rc = false;
-	} else {
-		q->bpoll_state = CXGB_POLL_STATE_NAPI;
-	}
-	spin_unlock(&q->bpoll_lock);
-	return rc;
-}
-
-static inline bool cxgb_poll_unlock_napi(struct sge_rspq *q)
-{
-	bool rc = false;
-
-	spin_lock(&q->bpoll_lock);
-	if (q->bpoll_state & CXGB_POLL_STATE_POLL_YIELD)
-		rc = true;
-	q->bpoll_state = CXGB_POLL_STATE_IDLE;
-	spin_unlock(&q->bpoll_lock);
-	return rc;
-}
-
-static inline bool cxgb_poll_lock_poll(struct sge_rspq *q)
-{
-	bool rc = true;
-
-	spin_lock_bh(&q->bpoll_lock);
-	if (q->bpoll_state & CXGB_POLL_LOCKED) {
-		q->bpoll_state |= CXGB_POLL_STATE_POLL_YIELD;
-		rc = false;
-	} else {
-		q->bpoll_state |= CXGB_POLL_STATE_POLL;
-	}
-	spin_unlock_bh(&q->bpoll_lock);
-	return rc;
-}
-
-static inline bool cxgb_poll_unlock_poll(struct sge_rspq *q)
-{
-	bool rc = false;
-
-	spin_lock_bh(&q->bpoll_lock);
-	if (q->bpoll_state & CXGB_POLL_STATE_POLL_YIELD)
-		rc = true;
-	q->bpoll_state = CXGB_POLL_STATE_IDLE;
-	spin_unlock_bh(&q->bpoll_lock);
-	return rc;
-}
-
-static inline bool cxgb_poll_busy_polling(struct sge_rspq *q)
-{
-	return q->bpoll_state & CXGB_POLL_USER_PEND;
-}
-#else
-static inline void cxgb_busy_poll_init_lock(struct sge_rspq *q)
-{
-}
-
-static inline bool cxgb_poll_lock_napi(struct sge_rspq *q)
-{
-	return true;
-}
-
-static inline bool cxgb_poll_unlock_napi(struct sge_rspq *q)
-{
-	return false;
-}
-
-static inline bool cxgb_poll_lock_poll(struct sge_rspq *q)
-{
-	return false;
-}
-
-static inline bool cxgb_poll_unlock_poll(struct sge_rspq *q)
-{
-	return false;
-}
-
-static inline bool cxgb_poll_busy_polling(struct sge_rspq *q)
-{
-	return false;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 /* Return a version number to identify the type of adapter.  The scheme is:
  * - bits 0..9: chip version
  * - bits 10..15: chip revision
@@ -1325,7 +1213,6 @@ irqreturn_t t4_sge_intr_msix(int irq, void *cookie);
 int t4_sge_init(struct adapter *adap);
 void t4_sge_start(struct adapter *adap);
 void t4_sge_stop(struct adapter *adap);
-int cxgb_busy_poll(struct napi_struct *napi);
 void cxgb4_set_ethtool_ops(struct net_device *netdev);
 int cxgb4_write_rss(const struct port_info *pi, const u16 *queues);
 extern int dbfifo_int_thresh;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 49e000ebd2b9ce14a26d4b1d9dcaec9cb360d8b9..f4f569060689c833a320c1d854e125278420ac89 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -744,14 +744,8 @@ static void quiesce_rx(struct adapter *adap)
 	for (i = 0; i < adap->sge.ingr_sz; i++) {
 		struct sge_rspq *q = adap->sge.ingr_map[i];
 
-		if (q && q->handler) {
+		if (q && q->handler)
 			napi_disable(&q->napi);
-			local_bh_disable();
-			while (!cxgb_poll_lock_napi(q))
-				mdelay(1);
-			local_bh_enable();
-		}
-
 	}
 }
 
@@ -782,10 +776,9 @@ static void enable_rx(struct adapter *adap)
 
 		if (!q)
 			continue;
-		if (q->handler) {
-			cxgb_busy_poll_init_lock(q);
+		if (q->handler)
 			napi_enable(&q->napi);
-		}
+
 		/* 0-increment GTS to start the timer and enable interrupts */
 		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
 			     SEINTARM_V(q->intr_params) |
@@ -2763,9 +2756,6 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_fcoe_enable      = cxgb_fcoe_enable,
 	.ndo_fcoe_disable     = cxgb_fcoe_disable,
 #endif /* CONFIG_CHELSIO_T4_FCOE */
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll        = cxgb_busy_poll,
-#endif
 	.ndo_set_tx_maxrate   = cxgb_set_tx_maxrate,
 	.ndo_setup_tc         = cxgb_setup_tc,
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 8098902c094a1d6e9e340dfbd54102079823e488..36105b6837cbc0adf5a78b47ac286840517f0145 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -408,10 +408,9 @@ static void enable_rx(struct adapter *adap, struct sge_rspq *q)
 	if (!q)
 		return;
 
-	if (q->handler) {
-		cxgb_busy_poll_init_lock(q);
+	if (q->handler)
 		napi_enable(&q->napi);
-	}
+
 	/* 0-increment GTS to start the timer and enable interrupts */
 	t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
 		     SEINTARM_V(q->intr_params) |
@@ -420,13 +419,8 @@ static void enable_rx(struct adapter *adap, struct sge_rspq *q)
 
 static void quiesce_rx(struct adapter *adap, struct sge_rspq *q)
 {
-	if (q && q->handler) {
+	if (q && q->handler)
 		napi_disable(&q->napi);
-		local_bh_disable();
-		while (!cxgb_poll_lock_napi(q))
-			mdelay(1);
-		local_bh_enable();
-	}
 }
 
 static void enable_rx_uld(struct adapter *adap, unsigned int uld_type)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 0fe04b482c382cf1e0c4333fe371d6a5e3efa6e1..85d30b33151ffc83ece3d731f8084110b56bb131 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -43,9 +43,7 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
-#ifdef CONFIG_NET_RX_BUSY_POLL
 #include <net/busy_poll.h>
-#endif /* CONFIG_NET_RX_BUSY_POLL */
 #ifdef CONFIG_CHELSIO_T4_FCOE
 #include <scsi/fc/fc_fcoe.h>
 #endif /* CONFIG_CHELSIO_T4_FCOE */
@@ -2054,7 +2052,6 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	csum_ok = pkt->csum_calc && !err_vec &&
 		  (q->netdev->features & NETIF_F_RXCSUM);
 	if ((pkt->l2info & htonl(RXF_TCP_F)) &&
-	    !(cxgb_poll_busy_polling(q)) &&
 	    (q->netdev->features & NETIF_F_GRO) && csum_ok && !pkt->ip_frag) {
 		do_gro(rxq, si, pkt);
 		return 0;
@@ -2285,38 +2282,6 @@ static int process_responses(struct sge_rspq *q, int budget)
 	return budget - budget_left;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-int cxgb_busy_poll(struct napi_struct *napi)
-{
-	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
-	unsigned int params, work_done;
-	u32 val;
-
-	if (!cxgb_poll_lock_poll(q))
-		return LL_FLUSH_BUSY;
-
-	work_done = process_responses(q, 4);
-	params = QINTR_TIMER_IDX_V(TIMERREG_COUNTER0_X) | QINTR_CNT_EN_V(1);
-	q->next_intr_params = params;
-	val = CIDXINC_V(work_done) | SEINTARM_V(params);
-
-	/* If we don't have access to the new User GTS (T5+), use the old
-	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
-	 */
-	if (unlikely(!q->bar2_addr))
-		t4_write_reg(q->adap, MYPF_REG(SGE_PF_GTS_A),
-			     val | INGRESSQID_V((u32)q->cntxt_id));
-	else {
-		writel(val | INGRESSQID_V(q->bar2_qid),
-		       q->bar2_addr + SGE_UDB_GTS);
-		wmb();
-	}
-
-	cxgb_poll_unlock_poll(q);
-	return work_done;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 /**
  *	napi_rx_handler - the NAPI handler for Rx processing
  *	@napi: the napi instance
@@ -2335,9 +2300,6 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 	int work_done;
 	u32 val;
 
-	if (!cxgb_poll_lock_napi(q))
-		return budget;
-
 	work_done = process_responses(q, budget);
 	if (likely(work_done < budget)) {
 		int timer_index;
@@ -2377,7 +2339,6 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
-	cxgb_poll_unlock_napi(q);
 	return work_done;
 }
 
