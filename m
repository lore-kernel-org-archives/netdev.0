From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 08/14] pkt_sched: Kill qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 09:54:33 +0000
Message-ID: <20081014095433.GI10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbYJNJyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:54:45 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:54:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------- Original Message --------
Subject: [PATCH 9/9]: pkt_sched: Kill qdisc->ops->requeue().
Date: Mon, 18 Aug 2008 01:37:18 -0700 (PDT)
From: David Miller <davem@davemloft.net>

------------------->
From: David Miller <davem@davemloft.net>
pkt_sched: Kill qdisc->ops->requeue().

It is only used by the qdisc->ops->requeue implementations themselves.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |   16 -----------
 net/sched/sch_api.c       |    7 -----
 net/sched/sch_cbq.c       |   35 ------------------------
 net/sched/sch_dsmark.c    |   21 --------------
 net/sched/sch_fifo.c      |    2 -
 net/sched/sch_generic.c   |   18 ------------
 net/sched/sch_gred.c      |   21 --------------
 net/sched/sch_hfsc.c      |   12 --------
 net/sched/sch_htb.c       |   42 ----------------------------
 net/sched/sch_netem.c     |   16 -----------
 net/sched/sch_prio.c      |   29 -------------------
 net/sched/sch_red.c       |   18 ------------
 net/sched/sch_sfq.c       |   66 ---------------------------------------------
 net/sched/sch_tbf.c       |   14 ---------
 net/sched/sch_teql.c      |   11 -------
 15 files changed, 0 insertions(+), 328 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 00c1309..f3f0b0b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -111,7 +111,6 @@ struct Qdisc_ops
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
-	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
 	int			(*init)(struct Qdisc *, struct nlattr *arg);
@@ -440,21 +439,6 @@ static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
 	return __qdisc_dequeue_tail(sch, &sch->q);
 }
 
-static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
-				  struct sk_buff_head *list)
-{
-	__skb_queue_head(list, skb);
-	sch->qstats.backlog += qdisc_pkt_len(skb);
-	sch->qstats.requeues++;
-
-	return NET_XMIT_SUCCESS;
-}
-
-static inline int qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	return __qdisc_requeue(skb, sch, &sch->q);
-}
-
 static inline void __qdisc_reset_queue(struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1122c95..ff58852 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -97,11 +97,6 @@ static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 
    Auxiliary routines:
 
-   ---requeue
-
-   requeues once dequeued packet. It is used for non-standard or
-   just buggy devices, which can defer output even if netif_queue_stopped()=0.
-
    ---reset
 
    returns qdisc to initial state: purge all buffers, clear all
@@ -147,8 +142,6 @@ int register_qdisc(struct Qdisc_ops *qops)
 
 	if (qops->enqueue == NULL)
 		qops->enqueue = noop_qdisc_ops.enqueue;
-	if (qops->requeue == NULL)
-		qops->requeue = noop_qdisc_ops.requeue;
 	if (qops->dequeue == NULL)
 		qops->dequeue = noop_qdisc_ops.dequeue;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c68e09c..8e0e7b2 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -405,40 +405,6 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-static int
-cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl;
-	int ret;
-
-	if ((cl = q->tx_class) == NULL) {
-		kfree_skb(skb);
-		sch->qstats.drops++;
-		return NET_XMIT_CN;
-	}
-	q->tx_class = NULL;
-
-	cbq_mark_toplevel(q, cl);
-
-#ifdef CONFIG_NET_CLS_ACT
-	q->rx_class = cl;
-	cl->q->__parent = sch;
-#endif
-	if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-		if (!cl->next_alive)
-			cbq_activate_class(cl);
-		return 0;
-	}
-	if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-	}
-	return ret;
-}
-
 /* Overlimit actions */
 
 /* TC_CBQ_OVL_CLASSIC: (default) penalize leaf class by adding offtime */
@@ -2065,7 +2031,6 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct cbq_sched_data),
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
-	.requeue	=	cbq_requeue,
 	.drop		=	cbq_drop,
 	.init		=	cbq_init,
 	.reset		=	cbq_reset,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index c29e9c2..0768b41 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -313,26 +313,6 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	int err;
-
-	pr_debug("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-
-	err = p->q->ops->requeue(skb, p->q);
-	if (err != NET_XMIT_SUCCESS) {
-		if (net_xmit_drop_count(err))
-			sch->qstats.drops++;
-		return err;
-	}
-
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-
-	return NET_XMIT_SUCCESS;
-}
-
 static unsigned int dsmark_drop(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -496,7 +476,6 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct dsmark_qdisc_data),
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
-	.requeue	=	dsmark_requeue,
 	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
 	.reset		=	dsmark_reset,
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 23d258b..3114508 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -83,7 +83,6 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
@@ -98,7 +97,6 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6730bac..9560ea1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -306,21 +306,11 @@ static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
 	return NULL;
 }
 
-static int noop_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
-{
-	if (net_ratelimit())
-		printk(KERN_DEBUG "%s deferred output. It is buggy.\n",
-		       skb->dev->name);
-	kfree_skb(skb);
-	return NET_XMIT_CN;
-}
-
 struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.id		=	"noop",
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
-	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
 
@@ -345,7 +335,6 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
-	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
 
@@ -409,12 +398,6 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	return NULL;
 }
 
-static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
-{
-	qdisc->q.qlen++;
-	return __qdisc_requeue(skb, qdisc, prio2list(skb, qdisc));
-}
-
 static void pfifo_fast_reset(struct Qdisc* qdisc)
 {
 	int prio;
@@ -455,7 +438,6 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
-	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c1ad6b8..8259796 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -240,26 +240,6 @@ congestion_drop:
 	return NET_XMIT_CN;
 }
 
-static int gred_requeue(struct sk_buff *skb, struct Qdisc* sch)
-{
-	struct gred_sched *t = qdisc_priv(sch);
-	struct gred_sched_data *q;
-	u16 dp = tc_index_to_dp(skb);
-
-	if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "GRED: Unable to relocate VQ 0x%x "
-			       "for requeue, screwing up backlog.\n",
-			       tc_index_to_dp(skb));
-	} else {
-		if (red_is_idling(&q->parms))
-			red_end_of_idle_period(&q->parms);
-		q->backlog += qdisc_pkt_len(skb);
-	}
-
-	return qdisc_requeue(skb, sch);
-}
-
 static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
@@ -602,7 +582,6 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct gred_sched),
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
-	.requeue	=	gred_requeue,
 	.drop		=	gred_drop,
 	.init		=	gred_init,
 	.reset		=	gred_reset,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 87da751..5598e73 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1669,17 +1669,6 @@ hfsc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static int
-hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct hfsc_sched *q = qdisc_priv(sch);
-
-	__skb_queue_head(&q->requeue, skb);
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-	return NET_XMIT_SUCCESS;
-}
-
 static unsigned int
 hfsc_drop(struct Qdisc *sch)
 {
@@ -1730,7 +1719,6 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.dump		= hfsc_dump_qdisc,
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
-	.requeue	= hfsc_requeue,
 	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
 	.priv_size	= sizeof(struct hfsc_sched),
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 34c0caf..b2f9e96 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -591,47 +591,6 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
-/* TODO: requeuing packet charges it to policers again !! */
-static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	int ret;
-	struct htb_sched *q = qdisc_priv(sch);
-	struct htb_class *cl = htb_classify(skb, sch, &ret);
-	struct sk_buff *tskb;
-
-	if (cl == HTB_DIRECT) {
-		/* enqueue to helper queue */
-		if (q->direct_queue.qlen < q->direct_qlen) {
-			__skb_queue_head(&q->direct_queue, skb);
-		} else {
-			__skb_queue_head(&q->direct_queue, skb);
-			tskb = __skb_dequeue_tail(&q->direct_queue);
-			kfree_skb(tskb);
-			sch->qstats.drops++;
-			return NET_XMIT_CN;
-		}
-#ifdef CONFIG_NET_CLS_ACT
-	} else if (!cl) {
-		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
-#endif
-	} else if ((ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q)) !=
-		   NET_XMIT_SUCCESS) {
-		if (net_xmit_drop_count(ret)) {
-			sch->qstats.drops++;
-			cl->qstats.drops++;
-		}
-		return ret;
-	} else
-		htb_activate(q, cl);
-
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-	return NET_XMIT_SUCCESS;
-}
-
 /**
  * htb_charge_class - charges amount "bytes" to leaf and ancestors
  *
@@ -1565,7 +1524,6 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct htb_sched),
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
-	.requeue	=	htb_requeue,
 	.drop		=	htb_drop,
 	.init		=	htb_init,
 	.reset		=	htb_reset,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5ca92d9..17d161b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -249,20 +249,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-/* Requeue packets but don't change time stamp */
-static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	int ret;
-
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-	}
-
-	return ret;
-}
-
 static unsigned int netem_drop(struct Qdisc* sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -536,7 +522,6 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	tfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
 	.reset		=	qdisc_reset_queue,
@@ -711,7 +696,6 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
-	.requeue	=	netem_requeue,
 	.drop		=	netem_drop,
 	.init		=	netem_init,
 	.reset		=	netem_reset,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index d527732..657203b 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -93,34 +93,6 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-
-static int
-prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
-{
-	struct Qdisc *qdisc;
-	int ret;
-
-	qdisc = prio_classify(skb, sch, &ret);
-#ifdef CONFIG_NET_CLS_ACT
-	if (qdisc == NULL) {
-		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
-	}
-#endif
-
-	if ((ret = qdisc->ops->requeue(skb, qdisc)) == NET_XMIT_SUCCESS) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-		return NET_XMIT_SUCCESS;
-	}
-	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
-	return ret;
-}
-
-
 static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -421,7 +393,6 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct prio_sched_data),
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
-	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
 	.reset		=	prio_reset,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 3709720..31a556d 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -108,23 +108,6 @@ congestion_drop:
 	return NET_XMIT_CN;
 }
 
-static int red_requeue(struct sk_buff *skb, struct Qdisc* sch)
-{
-	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
-	int ret;
-
-	if (red_is_idling(&q->parms))
-		red_end_of_idle_period(&q->parms);
-
-	ret = child->ops->requeue(skb, child);
-	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->qstats.requeues++;
-		sch->q.qlen++;
-	}
-	return ret;
-}
-
 static struct sk_buff * red_dequeue(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
@@ -361,7 +344,6 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.cl_ops		=	&red_class_ops,
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
-	.requeue	=	red_requeue,
 	.drop		=	red_drop,
 	.init		=	red_init,
 	.reset		=	red_reset,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index fe1508e..a795cb2 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -329,71 +329,6 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_CN;
 }
 
-static int
-sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct sfq_sched_data *q = qdisc_priv(sch);
-	unsigned int hash;
-	sfq_index x;
-	int ret;
-
-	hash = sfq_classify(skb, sch, &ret);
-	if (hash == 0) {
-		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
-	}
-	hash--;
-
-	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
-		q->hash[x] = hash;
-	}
-
-	sch->qstats.backlog += qdisc_pkt_len(skb);
-	__skb_queue_head(&q->qs[x], skb);
-	/* If selected queue has length q->limit+1, this means that
-	 * all another queues are empty and we do simple tail drop.
-	 * This packet is still requeued at head of queue, tail packet
-	 * is dropped.
-	 */
-	if (q->qs[x].qlen > q->limit) {
-		skb = q->qs[x].prev;
-		__skb_unlink(skb, &q->qs[x]);
-		sch->qstats.drops++;
-		sch->qstats.backlog -= qdisc_pkt_len(skb);
-		kfree_skb(skb);
-		return NET_XMIT_CN;
-	}
-
-	sfq_inc(q, x);
-	if (q->qs[x].qlen == 1) {		/* The flow is new */
-		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
-			q->tail = x;
-			q->next[x] = x;
-			q->allot[x] = q->quantum;
-		} else {
-			q->next[x] = q->next[q->tail];
-			q->next[q->tail] = x;
-			q->tail = x;
-		}
-	}
-
-	if (++sch->q.qlen <= q->limit) {
-		sch->qstats.requeues++;
-		return 0;
-	}
-
-	sch->qstats.drops++;
-	sfq_drop(sch);
-	return NET_XMIT_CN;
-}
-
-
-
-
 static struct sk_buff *
 sfq_dequeue(struct Qdisc *sch)
 {
@@ -624,7 +559,6 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
-	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e98aeb9..708e1eb 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -139,19 +139,6 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return 0;
 }
 
-static int tbf_requeue(struct sk_buff *skb, struct Qdisc* sch)
-{
-	struct tbf_sched_data *q = qdisc_priv(sch);
-	int ret;
-
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-	}
-
-	return ret;
-}
-
 static unsigned int tbf_drop(struct Qdisc* sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -464,7 +451,6 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct tbf_sched_data),
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
-	.requeue	=	tbf_requeue,
 	.drop		=	tbf_drop,
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index d35ef05..b3dcda3 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -93,16 +93,6 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return NET_XMIT_DROP;
 }
 
-static int
-teql_requeue(struct sk_buff *skb, struct Qdisc* sch)
-{
-	struct teql_sched_data *q = qdisc_priv(sch);
-
-	__skb_queue_head(&q->q, skb);
-	sch->qstats.requeues++;
-	return 0;
-}
-
 static struct sk_buff *
 teql_dequeue(struct Qdisc* sch)
 {
@@ -433,7 +423,6 @@ static __init void teql_master_setup(struct net_device *dev)
 
 	ops->enqueue	=	teql_enqueue;
 	ops->dequeue	=	teql_dequeue;
-	ops->requeue	=	teql_requeue;
 	ops->init	=	teql_qdisc_init;
 	ops->reset	=	teql_reset;
 	ops->destroy	=	teql_destroy;
-- 
1.5.6.5

