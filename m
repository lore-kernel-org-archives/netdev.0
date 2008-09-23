From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7]: cxgb3: Use SKB list interfaces instead of home-grown
 implementation.
Date: Mon, 22 Sep 2008 19:12:45 -0700 (PDT)
Message-ID: <20080922.191245.120692142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754134AbYIWCM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B577EC8C185
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


cxgb3: Use SKB list interfaces instead of home-grown implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cxgb3/adapter.h |    3 +-
 drivers/net/cxgb3/l2t.c     |   39 ++++++++++++++++---------------------
 drivers/net/cxgb3/l2t.h     |    3 +-
 drivers/net/cxgb3/sge.c     |   45 ++++++++++++++++++++++---------------------
 4 files changed, 42 insertions(+), 48 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 2711404..4f5cc69 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -124,8 +124,7 @@ struct sge_rspq {		/* state for an SGE response queue */
 	dma_addr_t phys_addr;	/* physical address of the ring */
 	unsigned int cntxt_id;	/* SGE context id for the response q */
 	spinlock_t lock;	/* guards response processing */
-	struct sk_buff *rx_head;	/* offload packet receive queue head */
-	struct sk_buff *rx_tail;	/* offload packet receive queue tail */
+	struct sk_buff_head rx_queue; /* offload packet receive queue */
 	struct sk_buff *pg_skb; /* used to build frag list in napi handler */
 
 	unsigned long offload_pkts;
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 825e510..b2c5314 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -86,6 +86,7 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
 				  struct l2t_entry *e)
 {
 	struct cpl_l2t_write_req *req;
+	struct sk_buff *tmp;
 
 	if (!skb) {
 		skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
@@ -103,13 +104,11 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
 	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
 	skb->priority = CPL_PRIORITY_CONTROL;
 	cxgb3_ofld_send(dev, skb);
-	while (e->arpq_head) {
-		skb = e->arpq_head;
-		e->arpq_head = skb->next;
-		skb->next = NULL;
+
+	skb_queue_walk_safe(&e->arpq, skb, tmp) {
+		__skb_unlink(skb, &e->arpq);
 		cxgb3_ofld_send(dev, skb);
 	}
-	e->arpq_tail = NULL;
 	e->state = L2T_STATE_VALID;
 
 	return 0;
@@ -121,12 +120,7 @@ static int setup_l2e_send_pending(struct t3cdev *dev, struct sk_buff *skb,
  */
 static inline void arpq_enqueue(struct l2t_entry *e, struct sk_buff *skb)
 {
-	skb->next = NULL;
-	if (e->arpq_head)
-		e->arpq_tail->next = skb;
-	else
-		e->arpq_head = skb;
-	e->arpq_tail = skb;
+	__skb_queue_tail(&e->arpq, skb);
 }
 
 int t3_l2t_send_slow(struct t3cdev *dev, struct sk_buff *skb,
@@ -167,7 +161,7 @@ again:
 				break;
 
 			spin_lock_bh(&e->lock);
-			if (e->arpq_head)
+			if (!skb_queue_empty(&e->arpq))
 				setup_l2e_send_pending(dev, skb, e);
 			else	/* we lost the race */
 				__kfree_skb(skb);
@@ -357,14 +351,14 @@ EXPORT_SYMBOL(t3_l2t_get);
  * XXX: maybe we should abandon the latter behavior and just require a failure
  * handler.
  */
-static void handle_failed_resolution(struct t3cdev *dev, struct sk_buff *arpq)
+static void handle_failed_resolution(struct t3cdev *dev, struct sk_buff_head *arpq)
 {
-	while (arpq) {
-		struct sk_buff *skb = arpq;
+	struct sk_buff *skb, *tmp;
+
+	skb_queue_walk_safe(arpq, skb, tmp) {
 		struct l2t_skb_cb *cb = L2T_SKB_CB(skb);
 
-		arpq = skb->next;
-		skb->next = NULL;
+		__skb_unlink(skb, arpq);
 		if (cb->arp_failure_handler)
 			cb->arp_failure_handler(dev, skb);
 		else
@@ -378,8 +372,8 @@ static void handle_failed_resolution(struct t3cdev *dev, struct sk_buff *arpq)
  */
 void t3_l2t_update(struct t3cdev *dev, struct neighbour *neigh)
 {
+	struct sk_buff_head arpq;
 	struct l2t_entry *e;
-	struct sk_buff *arpq = NULL;
 	struct l2t_data *d = L2DATA(dev);
 	u32 addr = *(u32 *) neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
@@ -395,6 +389,8 @@ void t3_l2t_update(struct t3cdev *dev, struct neighbour *neigh)
 	return;
 
 found:
+	__skb_queue_head_init(&arpq);
+
 	read_unlock(&d->lock);
 	if (atomic_read(&e->refcnt)) {
 		if (neigh != e->neigh)
@@ -402,8 +398,7 @@ found:
 
 		if (e->state == L2T_STATE_RESOLVING) {
 			if (neigh->nud_state & NUD_FAILED) {
-				arpq = e->arpq_head;
-				e->arpq_head = e->arpq_tail = NULL;
+				skb_queue_splice_init(&e->arpq, &arpq);
 			} else if (neigh->nud_state & (NUD_CONNECTED|NUD_STALE))
 				setup_l2e_send_pending(dev, NULL, e);
 		} else {
@@ -415,8 +410,8 @@ found:
 	}
 	spin_unlock_bh(&e->lock);
 
-	if (arpq)
-		handle_failed_resolution(dev, arpq);
+	if (!skb_queue_empty(&arpq))
+		handle_failed_resolution(dev, &arpq);
 }
 
 struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
diff --git a/drivers/net/cxgb3/l2t.h b/drivers/net/cxgb3/l2t.h
index d790013..42ce65f 100644
--- a/drivers/net/cxgb3/l2t.h
+++ b/drivers/net/cxgb3/l2t.h
@@ -64,8 +64,7 @@ struct l2t_entry {
 	struct neighbour *neigh;	/* associated neighbour */
 	struct l2t_entry *first;	/* start of hash chain */
 	struct l2t_entry *next;	/* next l2t_entry on chain */
-	struct sk_buff *arpq_head;	/* queue of packets awaiting resolution */
-	struct sk_buff *arpq_tail;
+	struct sk_buff_head arpq;	/* queue of packets awaiting resolution */
 	spinlock_t lock;
 	atomic_t refcnt;	/* entry reference count */
 	u8 dmac[6];		/* neighbour's MAC address */
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 1b0861d..6990c0d 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1704,16 +1704,15 @@ int t3_offload_tx(struct t3cdev *tdev, struct sk_buff *skb)
  */
 static inline void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
 {
-	skb->next = skb->prev = NULL;
-	if (q->rx_tail)
-		q->rx_tail->next = skb;
-	else {
+	int was_empty = skb_queue_empty(&q->rx_queue);
+
+	__skb_queue_tail(&q->rx_queue, skb);
+
+	if (was_empty) {
 		struct sge_qset *qs = rspq_to_qset(q);
 
 		napi_schedule(&qs->napi);
-		q->rx_head = skb;
 	}
-	q->rx_tail = skb;
 }
 
 /**
@@ -1754,26 +1753,29 @@ static int ofld_poll(struct napi_struct *napi, int budget)
 	int work_done = 0;
 
 	while (work_done < budget) {
-		struct sk_buff *head, *tail, *skbs[RX_BUNDLE_SIZE];
+		struct sk_buff *skb, *tmp, *skbs[RX_BUNDLE_SIZE];
+		struct sk_buff_head queue;
 		int ngathered;
 
 		spin_lock_irq(&q->lock);
-		head = q->rx_head;
-		if (!head) {
+		__skb_queue_head_init(&queue);
+		skb_queue_splice_init(&q->rx_queue, &queue);
+		if (skb_queue_empty(&queue)) {
 			napi_complete(napi);
 			spin_unlock_irq(&q->lock);
 			return work_done;
 		}
-
-		tail = q->rx_tail;
-		q->rx_head = q->rx_tail = NULL;
 		spin_unlock_irq(&q->lock);
 
-		for (ngathered = 0; work_done < budget && head; work_done++) {
-			prefetch(head->data);
-			skbs[ngathered] = head;
-			head = head->next;
-			skbs[ngathered]->next = NULL;
+		ngathered = 0;
+		skb_queue_walk_safe(&queue, skb, tmp) {
+			if (work_done >= budget)
+				break;
+			work_done++;
+
+			__skb_unlink(skb, &queue);
+			prefetch(skb->data);
+			skbs[ngathered] = skb;
 			if (++ngathered == RX_BUNDLE_SIZE) {
 				q->offload_bundles++;
 				adapter->tdev.recv(&adapter->tdev, skbs,
@@ -1781,12 +1783,10 @@ static int ofld_poll(struct napi_struct *napi, int budget)
 				ngathered = 0;
 			}
 		}
-		if (head) {	/* splice remaining packets back onto Rx queue */
+		if (!skb_queue_empty(&queue)) {
+			/* splice remaining packets back onto Rx queue */
 			spin_lock_irq(&q->lock);
-			tail->next = q->rx_head;
-			if (!q->rx_head)
-				q->rx_tail = tail;
-			q->rx_head = head;
+			skb_queue_splice(&queue, &q->rx_queue);
 			spin_unlock_irq(&q->lock);
 		}
 		deliver_partial_bundle(&adapter->tdev, q, skbs, ngathered);
@@ -2934,6 +2934,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->rspq.gen = 1;
 	q->rspq.size = p->rspq_size;
 	spin_lock_init(&q->rspq.lock);
+	skb_queue_head_init(&q->rspq.rx_queue);
 
 	q->txq[TXQ_ETH].stop_thres = nports *
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
-- 
1.5.6.5

