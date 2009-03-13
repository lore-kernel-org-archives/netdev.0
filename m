From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 5/10] cxgb3: separate TX and RX reclaim handlers
Date: Fri, 13 Mar 2009 00:14:04 -0700
Message-ID: <20090313071404.21994.97427.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27504 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbZCMHOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:14:07 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Separate TX and RX reclaim handlers
Don't disable interrupts in RX reclaim handler.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    1 
 drivers/net/cxgb3/sge.c     |  128 ++++++++++++++++++++++++++++++-------------
 2 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 95dce48..66ce456 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -197,6 +197,7 @@ struct sge_qset {		/* an SGE queue set */
 	struct netdev_queue *tx_q;	/* associated netdev TX queue */
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
+	struct timer_list rx_reclaim_timer;	/* reclaims RX buffers */
 	unsigned long port_stats[SGE_PSTAT_MAX];
 } ____cacheline_aligned;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index a482429..7d779d1 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -61,6 +61,7 @@
 #define FL1_PG_ORDER (PAGE_SIZE > 8192 ? 0 : 1)
 
 #define SGE_RX_DROP_THRES 16
+#define RX_RECLAIM_PERIOD (HZ/4)
 
 /*
  * Max number of Rx buffers we replenish at a time.
@@ -71,6 +72,8 @@
  * frequently as Tx buffers are usually reclaimed by new Tx packets.
  */
 #define TX_RECLAIM_PERIOD (HZ / 4)
+#define TX_RECLAIM_TIMER_CHUNK 64U
+#define TX_RECLAIM_CHUNK 16U
 
 /* WR size in bytes */
 #define WR_LEN (WR_FLITS * 8)
@@ -308,21 +311,25 @@ static void free_tx_desc(struct adapter *adapter, struct sge_txq *q,
  *	reclaim_completed_tx - reclaims completed Tx descriptors
  *	@adapter: the adapter
  *	@q: the Tx queue to reclaim completed descriptors from
+ *	@chunk: maximum number of descriptors to reclaim
  *
  *	Reclaims Tx descriptors that the SGE has indicated it has processed,
  *	and frees the associated buffers if possible.  Called with the Tx
  *	queue's lock held.
  */
-static inline void reclaim_completed_tx(struct adapter *adapter,
-					struct sge_txq *q)
+static inline unsigned int reclaim_completed_tx(struct adapter *adapter,
+						struct sge_txq *q,
+						unsigned int chunk)
 {
 	unsigned int reclaim = q->processed - q->cleaned;
 
+	reclaim = min(chunk, reclaim);
 	if (reclaim) {
 		free_tx_desc(adapter, q, reclaim);
 		q->cleaned += reclaim;
 		q->in_use -= reclaim;
 	}
+	return q->processed - q->cleaned;
 }
 
 /**
@@ -601,6 +608,7 @@ static void t3_reset_qset(struct sge_qset *q)
 	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
 	q->txq_stopped = 0;
 	q->tx_reclaim_timer.function = NULL; /* for t3_stop_sge_timers() */
+	q->rx_reclaim_timer.function = NULL;
 	q->lro_frag_tbl.nr_frags = q->lro_frag_tbl.len = 0;
 }
 
@@ -1179,7 +1187,7 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq = netdev_get_tx_queue(dev, qidx);
 
 	spin_lock(&q->lock);
-	reclaim_completed_tx(adap, q);
+	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 
 	credits = q->size - q->in_use;
 	ndesc = calc_tx_descs(skb);
@@ -1588,7 +1596,7 @@ static int ofld_xmit(struct adapter *adap, struct sge_txq *q,
 	unsigned int ndesc = calc_tx_descs_ofld(skb), pidx, gen;
 
 	spin_lock(&q->lock);
-      again:reclaim_completed_tx(adap, q);
+again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 
 	ret = check_desc_avail(adap, q, skb, ndesc, TXQ_OFLD);
 	if (unlikely(ret)) {
@@ -1630,7 +1638,7 @@ static void restart_offloadq(unsigned long data)
 	struct adapter *adap = pi->adapter;
 
 	spin_lock(&q->lock);
-      again:reclaim_completed_tx(adap, q);
+again:	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 
 	while ((skb = skb_peek(&q->sendq)) != NULL) {
 		unsigned int gen, pidx;
@@ -2747,13 +2755,13 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
 }
 
 /**
- *	sge_timer_cb - perform periodic maintenance of an SGE qset
+ *	sge_timer_tx - perform periodic maintenance of an SGE qset
  *	@data: the SGE queue set to maintain
  *
  *	Runs periodically from a timer to perform maintenance of an SGE queue
  *	set.  It performs two tasks:
  *
- *	a) Cleans up any completed Tx descriptors that may still be pending.
+ *	Cleans up any completed Tx descriptors that may still be pending.
  *	Normal descriptor cleanup happens when new packets are added to a Tx
  *	queue so this timer is relatively infrequent and does any cleanup only
  *	if the Tx queue has not seen any new packets in a while.  We make a
@@ -2763,51 +2771,87 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
  *	up).  Since control queues use immediate data exclusively we don't
  *	bother cleaning them up here.
  *
- *	b) Replenishes Rx queues that have run out due to memory shortage.
- *	Normally new Rx buffers are added when existing ones are consumed but
- *	when out of memory a queue can become empty.  We try to add only a few
- *	buffers here, the queue will be replenished fully as these new buffers
- *	are used up if memory shortage has subsided.
  */
-static void sge_timer_cb(unsigned long data)
+static void sge_timer_tx(unsigned long data)
 {
-	spinlock_t *lock;
 	struct sge_qset *qs = (struct sge_qset *)data;
-	struct adapter *adap = qs->adap;
+	struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
+	unsigned int tbd[SGE_TXQ_PER_SET] = {0, 0};
+	unsigned long next_period;
 
 	if (spin_trylock(&qs->txq[TXQ_ETH].lock)) {
-		reclaim_completed_tx(adap, &qs->txq[TXQ_ETH]);
+		tbd[TXQ_ETH] = reclaim_completed_tx(adap, &qs->txq[TXQ_ETH],
+						    TX_RECLAIM_TIMER_CHUNK);
 		spin_unlock(&qs->txq[TXQ_ETH].lock);
 	}
 	if (spin_trylock(&qs->txq[TXQ_OFLD].lock)) {
-		reclaim_completed_tx(adap, &qs->txq[TXQ_OFLD]);
+		tbd[TXQ_OFLD] = reclaim_completed_tx(adap, &qs->txq[TXQ_OFLD],
+						     TX_RECLAIM_TIMER_CHUNK);
 		spin_unlock(&qs->txq[TXQ_OFLD].lock);
 	}
-	lock = (adap->flags & USING_MSIX) ? &qs->rspq.lock :
-					    &adap->sge.qs[0].rspq.lock;
-	if (spin_trylock_irq(lock)) {
-		if (!napi_is_scheduled(&qs->napi)) {
-			u32 status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
-
-			if (qs->fl[0].credits < qs->fl[0].size)
-				__refill_fl(adap, &qs->fl[0]);
-			if (qs->fl[1].credits < qs->fl[1].size)
-				__refill_fl(adap, &qs->fl[1]);
-
-			if (status & (1 << qs->rspq.cntxt_id)) {
-				qs->rspq.starved++;
-				if (qs->rspq.credits) {
-					refill_rspq(adap, &qs->rspq, 1);
-					qs->rspq.credits--;
-					qs->rspq.restarted++;
-					t3_write_reg(adap, A_SG_RSPQ_FL_STATUS,
-						     1 << qs->rspq.cntxt_id);
-				}
+
+	next_period = TX_RECLAIM_PERIOD >>
+		      (max(tbd[TXQ_ETH], tbd[TXQ_OFLD]) /
+		       TX_RECLAIM_TIMER_CHUNK);
+	mod_timer(&qs->tx_reclaim_timer, jiffies + next_period);
+}
+
+/*
+ *	sge_timer_rx - perform periodic maintenance of an SGE qset
+ *	@data: the SGE queue set to maintain
+ *
+ *	a) Replenishes Rx queues that have run out due to memory shortage.
+ *	Normally new Rx buffers are added when existing ones are consumed but
+ *	when out of memory a queue can become empty.  We try to add only a few
+ *	buffers here, the queue will be replenished fully as these new buffers
+ *	are used up if memory shortage has subsided.
+ *
+ *	b) Return coalesced response queue credits in case a response queue is
+ *	starved.
+ *
+ */
+static void sge_timer_rx(unsigned long data)
+{
+	spinlock_t *lock;
+	struct sge_qset *qs = (struct sge_qset *)data;
+	struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
+	u32 status;
+
+	lock = adap->params.rev > 0 ?
+	       &qs->rspq.lock : &adap->sge.qs[0].rspq.lock;
+
+	if (!spin_trylock_irq(lock))
+		goto out;
+
+	if (napi_is_scheduled(&qs->napi))
+		goto unlock;
+
+	if (adap->params.rev < 4) {
+		status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
+
+		if (status & (1 << qs->rspq.cntxt_id)) {
+			qs->rspq.starved++;
+			if (qs->rspq.credits) {
+				qs->rspq.credits--;
+				refill_rspq(adap, &qs->rspq, 1);
+				qs->rspq.restarted++;
+				t3_write_reg(adap, A_SG_RSPQ_FL_STATUS,
+					     1 << qs->rspq.cntxt_id);
 			}
 		}
-		spin_unlock_irq(lock);
 	}
-	mod_timer(&qs->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
+
+	if (qs->fl[0].credits < qs->fl[0].size)
+		__refill_fl(adap, &qs->fl[0]);
+	if (qs->fl[1].credits < qs->fl[1].size)
+		__refill_fl(adap, &qs->fl[1]);
+
+unlock:
+	spin_unlock_irq(lock);
+out:
+	mod_timer(&qs->rx_reclaim_timer, jiffies + RX_RECLAIM_PERIOD);
 }
 
 /**
@@ -2850,7 +2894,8 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	struct sge_qset *q = &adapter->sge.qs[id];
 
 	init_qset_cntxt(q, id);
-	setup_timer(&q->tx_reclaim_timer, sge_timer_cb, (unsigned long)q);
+	setup_timer(&q->tx_reclaim_timer, sge_timer_tx, (unsigned long)q);
+	setup_timer(&q->rx_reclaim_timer, sge_timer_rx, (unsigned long)q);
 
 	q->fl[0].desc = alloc_ring(adapter->pdev, p->fl_size,
 				   sizeof(struct rx_desc),
@@ -2999,6 +3044,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		     V_NEWTIMER(q->rspq.holdoff_tmr));
 
 	mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
+	mod_timer(&q->rx_reclaim_timer, jiffies + RX_RECLAIM_PERIOD);
 
 	return 0;
 
@@ -3024,6 +3070,8 @@ void t3_stop_sge_timers(struct adapter *adap)
 
 		if (q->tx_reclaim_timer.function)
 			del_timer_sync(&q->tx_reclaim_timer);
+		if (q->rx_reclaim_timer.function)
+			del_timer_sync(&q->rx_reclaim_timer);
 	}
 }
 

