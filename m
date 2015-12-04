From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/7] cxgb4: prevent simultaneous execution of service_ofldq()
Date: Fri,  4 Dec 2015 14:18:08 +0530
Message-ID: <1449218891-7819-5-git-send-email-hariprasad@chelsio.com>
References: <1449218891-7819-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:24918 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755935AbbLDJt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 04:49:58 -0500
In-Reply-To: <1449218891-7819-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change mutual exclusion mechanism to prevent multiple threads of
execution from running in service_ofldq() at the same time.  The old
mechanism used an implicit guard on the down-call path and none on the
restart path and wasn't working. This checking makes the mechanism
explicit and is much easier to understand as a result.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |  1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 56 ++++++++++++++++++++++++++----
 2 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 55a47de..b3a1353 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -618,6 +618,7 @@ struct sge_ofld_txq {               /* state for an SGE offload Tx queue */
 	struct adapter *adap;
 	struct sk_buff_head sendq;  /* list of backpressured packets */
 	struct tasklet_struct qresume_tsk; /* restarts the queue */
+	u8 service_ofldq_running;   /* service_ofldq() is processing sendq */
 	u8 full;                    /* the Tx ring is full */
 	unsigned long mapping_err;  /* # of I/O MMU packet mapping errors */
 } ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 1076c35..c71cd50 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1542,11 +1542,22 @@ static void ofldtxq_stop(struct sge_ofld_txq *q, struct sk_buff *skb)
 }
 
 /**
- *	service_ofldq - restart a suspended offload queue
+ *	service_ofldq - service/restart a suspended offload queue
  *	@q: the offload queue
  *
- *	Services an offload Tx queue by moving packets from its packet queue
- *	to the HW Tx ring.  The function starts and ends with the queue locked.
+ *	Services an offload Tx queue by moving packets from its Pending Send
+ *	Queue to the Hardware TX ring.  The function starts and ends with the
+ *	Send Queue locked, but drops the lock while putting the skb at the
+ *	head of the Send Queue onto the Hardware TX Ring.  Dropping the lock
+ *	allows more skbs to be added to the Send Queue by other threads.
+ *	The packet being processed at the head of the Pending Send Queue is
+ *	left on the queue in case we experience DMA Mapping errors, etc.
+ *	and need to give up and restart later.
+ *
+ *	service_ofldq() can be thought of as a task which opportunistically
+ *	uses other threads execution contexts.  We use the Offload Queue
+ *	boolean "service_ofldq_running" to make sure that only one instance
+ *	is ever running at a time ...
  */
 static void service_ofldq(struct sge_ofld_txq *q)
 {
@@ -1556,10 +1567,23 @@ static void service_ofldq(struct sge_ofld_txq *q)
 	unsigned int written = 0;
 	unsigned int flits, ndesc;
 
+	/* If another thread is currently in service_ofldq() processing the
+	 * Pending Send Queue then there's nothing to do. Otherwise, flag
+	 * that we're doing the work and continue.  Examining/modifying
+	 * the Offload Queue boolean "service_ofldq_running" must be done
+	 * while holding the Pending Send Queue Lock.
+	 */
+	if (q->service_ofldq_running)
+		return;
+	q->service_ofldq_running = 1;
+
 	while ((skb = skb_peek(&q->sendq)) != NULL && !q->full) {
-		/*
-		 * We drop the lock but leave skb on sendq, thus retaining
-		 * exclusive access to the state of the queue.
+		/* We drop the lock while we're working with the skb at the
+		 * head of the Pending Send Queue.  This allows more skbs to
+		 * be added to the Pending Send Queue while we're working on
+		 * this one.  We don't need to lock to guard the TX Ring
+		 * updates because only one thread of execution is ever
+		 * allowed into service_ofldq() at a time.
 		 */
 		spin_unlock(&q->sendq.lock);
 
@@ -1604,6 +1628,11 @@ static void service_ofldq(struct sge_ofld_txq *q)
 			written = 0;
 		}
 
+		/* Reacquire the Pending Send Queue Lock so we can unlink the
+		 * skb we've just successfully transferred to the TX Ring and
+		 * loop for the next skb which may be at the head of the
+		 * Pending Send Queue.
+		 */
 		spin_lock(&q->sendq.lock);
 		__skb_unlink(skb, &q->sendq);
 		if (is_ofld_imm(skb))
@@ -1611,6 +1640,11 @@ static void service_ofldq(struct sge_ofld_txq *q)
 	}
 	if (likely(written))
 		ring_tx_db(q->adap, &q->q, written);
+
+	/*Indicate that no thread is processing the Pending Send Queue
+	 * currently.
+	 */
+	q->service_ofldq_running = 0;
 }
 
 /**
@@ -1624,9 +1658,19 @@ static int ofld_xmit(struct sge_ofld_txq *q, struct sk_buff *skb)
 {
 	skb->priority = calc_tx_flits_ofld(skb);       /* save for restart */
 	spin_lock(&q->sendq.lock);
+
+	/* Queue the new skb onto the Offload Queue's Pending Send Queue.  If
+	 * that results in this new skb being the only one on the queue, start
+	 * servicing it.  If there are other skbs already on the list, then
+	 * either the queue is currently being processed or it's been stopped
+	 * for some reason and it'll be restarted at a later time.  Restart
+	 * paths are triggered by events like experiencing a DMA Mapping Error
+	 * or filling the Hardware TX Ring.
+	 */
 	__skb_queue_tail(&q->sendq, skb);
 	if (q->sendq.qlen == 1)
 		service_ofldq(q);
+
 	spin_unlock(&q->sendq.lock);
 	return NET_XMIT_SUCCESS;
 }
-- 
2.3.4
