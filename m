From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Remove qdisc->ops->requeue() etc.
Date: Thu, 13 Nov 2008 11:47:14 +0000
Message-ID: <20081113114714.GA22746@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:55482 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbYKMLrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 06:47:32 -0500
Received: by nf-out-0910.google.com with SMTP id d3so428273nfc.21
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 03:47:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After implementing qdisc->ops->peek() and changing sch_netem into
classless qdisc there are no more qdisc->ops->requeue() users. This
patch removes this method with its wrappers (qdisc_requeue()), and
also unused qdisc->requeue structure. There are a few minor fixes of
warnings (htb_enqueue()) and comments btw.

The idea to kill ->requeue() and a similar patch were first developed
by David S. Miller.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sch_generic.h |   17 ------------
 net/sched/sch_api.c       |    7 -----
 net/sched/sch_atm.c       |   20 +-------------
 net/sched/sch_cbq.c       |   35 -------------------------
 net/sched/sch_dsmark.c    |   21 ---------------
 net/sched/sch_fifo.c      |    2 -
 net/sched/sch_generic.c   |   23 ----------------
 net/sched/sch_gred.c      |   21 ---------------
 net/sched/sch_hfsc.c      |   19 -------------
 net/sched/sch_htb.c       |   44 +------------------------------
 net/sched/sch_multiq.c    |   39 +--------------------------
 net/sched/sch_netem.c     |   16 -----------
 net/sched/sch_prio.c      |   28 --------------------
 net/sched/sch_red.c       |   18 -------------
 net/sched/sch_sfq.c       |   63 ---------------------------------------------
 net/sched/sch_tbf.c       |   14 ----------
 net/sched/sch_teql.c      |   11 --------
 17 files changed, 4 insertions(+), 394 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 64ae1ba..f8c4742 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -53,7 +53,6 @@ struct Qdisc
 	atomic_t		refcnt;
 	unsigned long		state;
 	struct sk_buff		*gso_skb;
-	struct sk_buff_head	requeue;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
 	struct Qdisc		*next_sched;
@@ -112,7 +111,6 @@ struct Qdisc_ops
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
-	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
 	int			(*init)(struct Qdisc *, struct nlattr *arg);
@@ -467,21 +465,6 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 	return skb;
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
index e564661..5bcef13 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -97,11 +97,6 @@ static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
 
    Auxiliary routines:
 
-   ---requeue
-
-   requeues once dequeued packet. It is used for non-standard or
-   just buggy devices, which can defer output even if netif_queue_stopped()=0.
-
    ---peek
 
    like dequeue but without removing a packet from the queue
@@ -151,8 +146,6 @@ int register_qdisc(struct Qdisc_ops *qops)
 
 	if (qops->enqueue == NULL)
 		qops->enqueue = noop_qdisc_ops.enqueue;
-	if (qops->requeue == NULL)
-		qops->requeue = noop_qdisc_ops.requeue;
 	if (qops->peek == NULL) {
 		if (qops->dequeue == NULL) {
 			qops->peek = noop_qdisc_ops.peek;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 6eb9a65..ca90f6e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -62,7 +62,7 @@ struct atm_qdisc_data {
 	struct atm_flow_data	link;		/* unclassified skbs go here */
 	struct atm_flow_data	*flows;		/* NB: "link" is also on this
 						   list */
-	struct tasklet_struct	task;		/* requeue tasklet */
+	struct tasklet_struct	task;		/* dequeue tasklet */
 };
 
 /* ------------------------- Class/flow operations ------------------------- */
@@ -534,23 +534,6 @@ static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
 	return p->link.q->ops->peek(p->link.q);
 }
 
-static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct atm_qdisc_data *p = qdisc_priv(sch);
-	int ret;
-
-	pr_debug("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
-	ret = p->link.q->ops->requeue(skb, p->link.q);
-	if (!ret) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-	} else if (net_xmit_drop_count(ret)) {
-		sch->qstats.drops++;
-		p->link.qstats.drops++;
-	}
-	return ret;
-}
-
 static unsigned int atm_tc_drop(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -707,7 +690,6 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
 	.peek		= atm_tc_peek,
-	.requeue	= atm_tc_requeue,
 	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
 	.reset		= atm_tc_reset,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 63efa70..a99e37e 100644
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
@@ -2067,7 +2033,6 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.requeue	=	cbq_requeue,
 	.drop		=	cbq_drop,
 	.init		=	cbq_init,
 	.reset		=	cbq_reset,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 3e49147..3f9427a 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -322,26 +322,6 @@ static struct sk_buff *dsmark_peek(struct Qdisc *sch)
 	return p->q->ops->peek(p->q);
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
@@ -506,7 +486,6 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
 	.peek		=	dsmark_peek,
-	.requeue	=	dsmark_requeue,
 	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
 	.reset		=	dsmark_reset,
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 8825e88..92cfc9d 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -84,7 +84,6 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
@@ -100,7 +99,6 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 1192da2..80c8f3d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -306,22 +306,12 @@ static struct sk_buff *noop_dequeue(struct Qdisc * qdisc)
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
 	.peek		=	noop_dequeue,
-	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
 
@@ -336,7 +326,6 @@ struct Qdisc noop_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
-	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
 };
@@ -348,7 +337,6 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
 	.peek		=	noop_dequeue,
-	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
 
@@ -364,7 +352,6 @@ static struct Qdisc noqueue_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
-	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.dev_queue	=	&noqueue_netdev_queue,
 };
@@ -426,12 +413,6 @@ static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
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
@@ -473,7 +454,6 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
-	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
@@ -499,7 +479,6 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch->padded = (char *) sch - (char *) p;
 
 	INIT_LIST_HEAD(&sch->list);
-	skb_queue_head_init(&sch->requeue);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
@@ -571,8 +550,6 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb(qdisc->gso_skb);
-	__skb_queue_purge(&qdisc->requeue);
-
 	kfree((char *) qdisc - qdisc->padded);
 }
 EXPORT_SYMBOL(qdisc_destroy);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index cb20ee3..40408d5 100644
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
@@ -603,7 +583,6 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
 	.peek		=	qdisc_peek_head,
-	.requeue	=	gred_requeue,
 	.drop		=	gred_drop,
 	.init		=	gred_init,
 	.reset		=	gred_reset,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d90b165..071c474 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -184,7 +184,6 @@ struct hfsc_sched
 	struct rb_root eligible;		/* eligible tree */
 	struct list_head droplist;		/* active leaf class list (for
 						   dropping) */
-	struct sk_buff_head requeue;		/* requeued packet */
 	struct qdisc_watchdog watchdog;		/* watchdog timer */
 };
 
@@ -1432,7 +1431,6 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 		return err;
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
-	skb_queue_head_init(&q->requeue);
 
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
@@ -1517,7 +1515,6 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 		hlist_for_each_entry(cl, n, &q->clhash.hash[i], cl_common.hnode)
 			hfsc_reset_class(cl);
 	}
-	__skb_queue_purge(&q->requeue);
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -1542,7 +1539,6 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 			hfsc_destroy_class(sch, cl);
 	}
 	qdisc_class_hash_destroy(&q->clhash);
-	__skb_queue_purge(&q->requeue);
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
@@ -1609,8 +1605,6 @@ hfsc_dequeue(struct Qdisc *sch)
 
 	if (sch->q.qlen == 0)
 		return NULL;
-	if ((skb = __skb_dequeue(&q->requeue)))
-		goto out;
 
 	cur_time = psched_get_time();
 
@@ -1659,24 +1653,12 @@ hfsc_dequeue(struct Qdisc *sch)
 		set_passive(cl);
 	}
 
- out:
 	sch->flags &= ~TCQ_F_THROTTLED;
 	sch->q.qlen--;
 
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
@@ -1728,7 +1710,6 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
 	.peek		= qdisc_peek_dequeued,
-	.requeue	= hfsc_requeue,
 	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
 	.priv_size	= sizeof(struct hfsc_sched),
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3fda819..83f5e69 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -551,7 +551,7 @@ static inline void htb_deactivate(struct htb_sched *q, struct htb_class *cl)
 
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	int ret;
+	int uninitialized_var(ret);
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = htb_classify(skb, sch, &ret);
 
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
@@ -1566,7 +1525,6 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.requeue	=	htb_requeue,
 	.drop		=	htb_drop,
 	.init		=	htb_init,
 	.reset		=	htb_reset,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 155648d..f645ac5 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -92,40 +92,6 @@ multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return ret;
 }
 
-
-static int
-multiq_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct Qdisc *qdisc;
-	struct multiq_sched_data *q = qdisc_priv(sch);
-	int ret;
-
-	qdisc = multiq_classify(skb, sch, &ret);
-#ifdef CONFIG_NET_CLS_ACT
-	if (qdisc == NULL) {
-		if (ret & __NET_XMIT_BYPASS)
-			sch->qstats.drops++;
-		kfree_skb(skb);
-		return ret;
-	}
-#endif
-
-	ret = qdisc->ops->requeue(skb, qdisc);
-	if (ret == NET_XMIT_SUCCESS) {
-		sch->q.qlen++;
-		sch->qstats.requeues++;
-		if (q->curband)
-			q->curband--;
-		else
-			q->curband = q->bands - 1;
-		return NET_XMIT_SUCCESS;
-	}
-	if (net_xmit_drop_count(ret))
-		sch->qstats.drops++;
-	return ret;
-}
-
-
 static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
@@ -140,7 +106,7 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 			q->curband = 0;
 
 		/* Check that target subqueue is available before
-		 * pulling an skb to avoid excessive requeues
+		 * pulling an skb to avoid head-of-line blocking.
 		 */
 		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
 			qdisc = q->queues[q->curband];
@@ -170,7 +136,7 @@ static struct sk_buff *multiq_peek(struct Qdisc *sch)
 			curband = 0;
 
 		/* Check that target subqueue is available before
-		 * pulling an skb to avoid excessive requeues
+		 * pulling an skb to avoid head-of-line blocking.
 		 */
 		if (!__netif_subqueue_stopped(qdisc_dev(sch), curband)) {
 			qdisc = q->queues[curband];
@@ -480,7 +446,6 @@ static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
 	.enqueue	=	multiq_enqueue,
 	.dequeue	=	multiq_dequeue,
 	.peek		=	multiq_peek,
-	.requeue	=	multiq_requeue,
 	.drop		=	multiq_drop,
 	.init		=	multiq_init,
 	.reset		=	multiq_reset,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index f69698f..3cbc3ff 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -252,20 +252,6 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
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
@@ -531,7 +517,6 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.enqueue	=	tfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
 	.reset		=	qdisc_reset_queue,
@@ -620,7 +605,6 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.requeue	=	netem_requeue,
 	.drop		=	netem_drop,
 	.init		=	netem_init,
 	.reset		=	netem_reset,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 3651da3..ea65a87 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -93,33 +93,6 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
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
 static struct sk_buff *prio_peek(struct Qdisc *sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -435,7 +408,6 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
 	.peek		=	prio_peek,
-	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
 	.reset		=	prio_reset,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 7abc514..6a0371c 100644
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
@@ -370,7 +353,6 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
 	.peek		=	red_peek,
-	.requeue	=	red_requeue,
 	.drop		=	red_drop,
 	.init		=	red_init,
 	.reset		=	red_reset,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 198b83d..ab8cfee 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -329,68 +329,6 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
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
 static struct sk_buff *
 sfq_peek(struct Qdisc *sch)
 {
@@ -636,7 +574,6 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
 	.peek		=	sfq_peek,
-	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 435076c..bb7783d 100644
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
@@ -468,7 +455,6 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.requeue	=	tbf_requeue,
 	.drop		=	tbf_drop,
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index bf03e7f..cfc8e7c 100644
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
@@ -441,7 +431,6 @@ static __init void teql_master_setup(struct net_device *dev)
 	ops->enqueue	=	teql_enqueue;
 	ops->dequeue	=	teql_dequeue;
 	ops->peek	=	teql_peek;
-	ops->requeue	=	teql_requeue;
 	ops->init	=	teql_qdisc_init;
 	ops->reset	=	teql_reset;
 	ops->destroy	=	teql_destroy;
