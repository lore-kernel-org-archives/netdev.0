From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next] cxgb4: Add low latency socket busy_poll support
Date: Wed,  4 Feb 2015 15:32:52 +0530
Message-ID: <1423044172-23586-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6820 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964793AbbBDJ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 04:57:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb_busy_poll, corresponding to ndo_busy_poll, gets called by the socket
waiting for data.

With busy_poll enabled, improvement is seen in latency numbers as observed by
collecting netperf TCP_RR numbers.
Below are latency number, with and without busy-poll, in a switched environment
for a particular msg size:
netperf command: netperf -4 -H <ip> -l 30 -t TCP_RR -- -r1,1
Latency without busy-poll: ~16.25 us
Latency with busy-poll   : ~08.79 us

Based on original work by Kumar Sanghvi <kumaras@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
V2: fix napi poll return value for repoll, thanks to pointers by
    Eric Dumazet <eric.dumazet@gmail.com>

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  113 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   16 +++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   47 +++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |    1 +
 4 files changed, 174 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index fb6980a..55019c9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -476,6 +476,22 @@ struct sge_rspq {                   /* state for an SGE response queue */
 	struct adapter *adap;
 	struct net_device *netdev;  /* associated net device */
 	rspq_handler_t handler;
+#ifdef CONFIG_NET_RX_BUSY_POLL
+#define CXGB_POLL_STATE_IDLE		0
+#define CXGB_POLL_STATE_NAPI		BIT(0) /* NAPI owns this poll */
+#define CXGB_POLL_STATE_POLL		BIT(1) /* poll owns this poll */
+#define CXGB_POLL_STATE_NAPI_YIELD	BIT(2) /* NAPI yielded this poll */
+#define CXGB_POLL_STATE_POLL_YIELD	BIT(3) /* poll yielded this poll */
+#define CXGB_POLL_YIELD			(CXGB_POLL_STATE_NAPI_YIELD |   \
+					 CXGB_POLL_STATE_POLL_YIELD)
+#define CXGB_POLL_LOCKED		(CXGB_POLL_STATE_NAPI |         \
+					 CXGB_POLL_STATE_POLL)
+#define CXGB_POLL_USER_PEND		(CXGB_POLL_STATE_POLL |         \
+					 CXGB_POLL_STATE_POLL_YIELD)
+	unsigned int bpoll_state;
+	spinlock_t bpoll_lock;		/* lock for busy poll */
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 };
 
 struct sge_eth_stats {              /* Ethernet queue statistics */
@@ -880,6 +896,102 @@ static inline struct adapter *netdev2adap(const struct net_device *dev)
 	return netdev2pinfo(dev)->adapter;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static inline void cxgb_busy_poll_init_lock(struct sge_rspq *q)
+{
+	spin_lock_init(&q->bpoll_lock);
+	q->bpoll_state = CXGB_POLL_STATE_IDLE;
+}
+
+static inline bool cxgb_poll_lock_napi(struct sge_rspq *q)
+{
+	bool rc = true;
+
+	spin_lock(&q->bpoll_lock);
+	if (q->bpoll_state & CXGB_POLL_LOCKED) {
+		q->bpoll_state |= CXGB_POLL_STATE_NAPI_YIELD;
+		rc = false;
+	} else {
+		q->bpoll_state = CXGB_POLL_STATE_NAPI;
+	}
+	spin_unlock(&q->bpoll_lock);
+	return rc;
+}
+
+static inline bool cxgb_poll_unlock_napi(struct sge_rspq *q)
+{
+	bool rc = false;
+
+	spin_lock(&q->bpoll_lock);
+	if (q->bpoll_state & CXGB_POLL_STATE_POLL_YIELD)
+		rc = true;
+	q->bpoll_state = CXGB_POLL_STATE_IDLE;
+	spin_unlock(&q->bpoll_lock);
+	return rc;
+}
+
+static inline bool cxgb_poll_lock_poll(struct sge_rspq *q)
+{
+	bool rc = true;
+
+	spin_lock_bh(&q->bpoll_lock);
+	if (q->bpoll_state & CXGB_POLL_LOCKED) {
+		q->bpoll_state |= CXGB_POLL_STATE_POLL_YIELD;
+		rc = false;
+	} else {
+		q->bpoll_state |= CXGB_POLL_STATE_POLL;
+	}
+	spin_unlock_bh(&q->bpoll_lock);
+	return rc;
+}
+
+static inline bool cxgb_poll_unlock_poll(struct sge_rspq *q)
+{
+	bool rc = false;
+
+	spin_lock_bh(&q->bpoll_lock);
+	if (q->bpoll_state & CXGB_POLL_STATE_POLL_YIELD)
+		rc = true;
+	q->bpoll_state = CXGB_POLL_STATE_IDLE;
+	spin_unlock_bh(&q->bpoll_lock);
+	return rc;
+}
+
+static inline bool cxgb_poll_busy_polling(struct sge_rspq *q)
+{
+	return q->bpoll_state & CXGB_POLL_USER_PEND;
+}
+#else
+static inline void cxgb_busy_poll_init_lock(struct sge_rspq *q)
+{
+}
+
+static inline bool cxgb_poll_lock_napi(struct sge_rspq *q)
+{
+	return true;
+}
+
+static inline bool cxgb_poll_unlock_napi(struct sge_rspq *q)
+{
+	return false;
+}
+
+static inline bool cxgb_poll_lock_poll(struct sge_rspq *q)
+{
+	return false;
+}
+
+static inline bool cxgb_poll_unlock_poll(struct sge_rspq *q)
+{
+	return false;
+}
+
+static inline bool cxgb_poll_busy_polling(struct sge_rspq *q)
+{
+	return false;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 void t4_os_portmod_changed(const struct adapter *adap, int port_id);
 void t4_os_link_changed(struct adapter *adap, int port_id, int link_stat);
 
@@ -908,6 +1020,7 @@ irqreturn_t t4_sge_intr_msix(int irq, void *cookie);
 int t4_sge_init(struct adapter *adap);
 void t4_sge_start(struct adapter *adap);
 void t4_sge_stop(struct adapter *adap);
+int cxgb_busy_poll(struct napi_struct *napi);
 extern int dbfifo_int_thresh;
 
 #define for_each_port(adapter, iter) \
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5bf490a..041742b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -923,8 +923,14 @@ static void quiesce_rx(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(adap->sge.ingr_map); i++) {
 		struct sge_rspq *q = adap->sge.ingr_map[i];
 
-		if (q && q->handler)
+		if (q && q->handler) {
 			napi_disable(&q->napi);
+			local_bh_disable();
+			while (!cxgb_poll_lock_napi(q))
+				mdelay(1);
+			local_bh_enable();
+		}
+
 	}
 }
 
@@ -940,8 +946,10 @@ static void enable_rx(struct adapter *adap)
 
 		if (!q)
 			continue;
-		if (q->handler)
+		if (q->handler) {
+			cxgb_busy_poll_init_lock(q);
 			napi_enable(&q->napi);
+		}
 		/* 0-increment GTS to start the timer and enable interrupts */
 		t4_write_reg(adap, MYPF_REG(SGE_PF_GTS_A),
 			     SEINTARM_V(q->intr_params) |
@@ -4563,6 +4571,10 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller  = cxgb_netpoll,
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll        = cxgb_busy_poll,
+#endif
+
 };
 
 void t4_fatal_err(struct adapter *adap)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 6191561..b4b9f60 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -43,6 +43,9 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 #include <net/tcp.h>
+#ifdef CONFIG_NET_RX_BUSY_POLL
+#include <net/busy_poll.h>
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 #include "cxgb4.h"
 #include "t4_regs.h"
 #include "t4_values.h"
@@ -1720,6 +1723,7 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->truesize += skb->data_len;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
+	skb_mark_napi_id(skb, &rxq->rspq.napi);
 	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, (__force u32)pkt->rsshdr.hash_val,
 			     PKT_HASH_TYPE_L3);
@@ -1763,6 +1767,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	csum_ok = pkt->csum_calc && !pkt->err_vec &&
 		  (q->netdev->features & NETIF_F_RXCSUM);
 	if ((pkt->l2info & htonl(RXF_TCP_F)) &&
+	    !(cxgb_poll_busy_polling(q)) &&
 	    (q->netdev->features & NETIF_F_GRO) && csum_ok && !pkt->ip_frag) {
 		do_gro(rxq, si, pkt);
 		return 0;
@@ -1801,6 +1806,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(pkt->vlan));
 		rxq->stats.vlan_ex++;
 	}
+	skb_mark_napi_id(skb, &q->napi);
 	netif_receive_skb(skb);
 	return 0;
 }
@@ -1963,6 +1969,38 @@ static int process_responses(struct sge_rspq *q, int budget)
 	return budget - budget_left;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+int cxgb_busy_poll(struct napi_struct *napi)
+{
+	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
+	unsigned int params, work_done;
+	u32 val;
+
+	if (!cxgb_poll_lock_poll(q))
+		return LL_FLUSH_BUSY;
+
+	work_done = process_responses(q, 4);
+	params = QINTR_TIMER_IDX(TIMERREG_COUNTER0_X) | QINTR_CNT_EN;
+	q->next_intr_params = params;
+	val = CIDXINC_V(work_done) | SEINTARM_V(params);
+
+	/* If we don't have access to the new User GTS (T5+), use the old
+	 * doorbell mechanism; otherwise use the new BAR2 mechanism.
+	 */
+	if (unlikely(!q->bar2_addr))
+		t4_write_reg(q->adap, MYPF_REG(SGE_PF_GTS_A),
+			     val | INGRESSQID_V((u32)q->cntxt_id));
+	else {
+		writel(val | INGRESSQID_V(q->bar2_qid),
+		       q->bar2_addr + SGE_UDB_GTS);
+		wmb();
+	}
+
+	cxgb_poll_unlock_poll(q);
+	return work_done;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 /**
  *	napi_rx_handler - the NAPI handler for Rx processing
  *	@napi: the napi instance
@@ -1978,9 +2016,13 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 {
 	unsigned int params;
 	struct sge_rspq *q = container_of(napi, struct sge_rspq, napi);
-	int work_done = process_responses(q, budget);
+	int work_done;
 	u32 val;
 
+	if (!cxgb_poll_lock_napi(q))
+		return budget;
+
+	work_done = process_responses(q, budget);
 	if (likely(work_done < budget)) {
 		int timer_index;
 
@@ -2018,6 +2060,7 @@ static int napi_rx_handler(struct napi_struct *napi, int budget)
 		       q->bar2_addr + SGE_UDB_GTS);
 		wmb();
 	}
+	cxgb_poll_unlock_napi(q);
 	return work_done;
 }
 
@@ -2341,6 +2384,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		goto err;
 
 	netif_napi_add(dev, &iq->napi, napi_rx_handler, 64);
+	napi_hash_add(&iq->napi);
 	iq->cur_desc = iq->desc;
 	iq->cidx = 0;
 	iq->gen = 1;
@@ -2598,6 +2642,7 @@ static void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq,
 		   rq->cntxt_id, fl_id, 0xffff);
 	dma_free_coherent(adap->pdev_dev, (rq->size + 1) * rq->iqe_len,
 			  rq->desc, rq->phys_addr);
+	napi_hash_del(&rq->napi);
 	netif_napi_del(&rq->napi);
 	rq->netdev = NULL;
 	rq->cntxt_id = rq->abs_id = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index a404844..997ec87 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -59,6 +59,7 @@
 
 /* GTS register */
 #define SGE_TIMERREGS			6
+#define TIMERREG_COUNTER0_X		0
 
 /* T5 and later support a new BAR2-based doorbell mechanism for Egress Queues.
  * The User Doorbells are each 128 bytes in length with a Simple Doorbell at
-- 
1.7.1
