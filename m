From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 -next 4/5] sched: remove qdisc->drop
Date: Thu,  9 Jun 2016 00:27:42 +0200
Message-ID: <1465424863-18456-5-git-send-email-fw@strlen.de>
References: <1465424863-18456-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60739 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756203AbcFHW1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 18:27:39 -0400
In-Reply-To: <1465424863-18456-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after removal of TCA_CBQ_OVL_STRATEGY from cbq scheduler, there are no
more callers of ->drop() outside of other ->drop functions, i.e.
nothing calls them.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h | 36 ------------------------------------
 net/sched/sch_atm.c       | 15 ---------------
 net/sched/sch_cbq.c       | 26 --------------------------
 net/sched/sch_choke.c     | 17 -----------------
 net/sched/sch_drr.c       | 21 ---------------------
 net/sched/sch_dsmark.c    | 18 ------------------
 net/sched/sch_fifo.c      |  3 ---
 net/sched/sch_fq_codel.c  | 10 ----------
 net/sched/sch_gred.c      | 35 -----------------------------------
 net/sched/sch_hfsc.c      | 26 --------------------------
 net/sched/sch_hhf.c       | 10 ----------
 net/sched/sch_htb.c       | 26 --------------------------
 net/sched/sch_multiq.c    | 22 ----------------------
 net/sched/sch_netem.c     | 30 ------------------------------
 net/sched/sch_prio.c      | 19 -------------------
 net/sched/sch_qfq.c       | 47 -----------------------------------------------
 net/sched/sch_red.c       | 20 --------------------
 net/sched/sch_sfq.c       |  1 -
 net/sched/sch_tbf.c       | 13 -------------
 19 files changed, 395 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a9aec63..4dedb7f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -174,7 +174,6 @@ struct Qdisc_ops {
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
-	unsigned int		(*drop)(struct Qdisc *);
 
 	int			(*init)(struct Qdisc *, struct nlattr *arg);
 	void			(*reset)(struct Qdisc *);
@@ -658,22 +657,6 @@ static inline unsigned int qdisc_queue_drop_head(struct Qdisc *sch)
 	return __qdisc_queue_drop_head(sch, &sch->q);
 }
 
-static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
-						   struct sk_buff_head *list)
-{
-	struct sk_buff *skb = __skb_dequeue_tail(list);
-
-	if (likely(skb != NULL))
-		qdisc_qstats_backlog_dec(sch, skb);
-
-	return skb;
-}
-
-static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
-{
-	return __qdisc_dequeue_tail(sch, &sch->q);
-}
-
 static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 {
 	return skb_peek(&sch->q);
@@ -741,25 +724,6 @@ static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
 	return old;
 }
 
-static inline unsigned int __qdisc_queue_drop(struct Qdisc *sch,
-					      struct sk_buff_head *list)
-{
-	struct sk_buff *skb = __qdisc_dequeue_tail(sch, list);
-
-	if (likely(skb != NULL)) {
-		unsigned int len = qdisc_pkt_len(skb);
-		kfree_skb(skb);
-		return len;
-	}
-
-	return 0;
-}
-
-static inline unsigned int qdisc_queue_drop(struct Qdisc *sch)
-{
-	return __qdisc_queue_drop(sch, &sch->q);
-}
-
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 34f8f79..7e6c12d 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -519,20 +519,6 @@ static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
 	return p->link.q->ops->peek(p->link.q);
 }
 
-static unsigned int atm_tc_drop(struct Qdisc *sch)
-{
-	struct atm_qdisc_data *p = qdisc_priv(sch);
-	struct atm_flow_data *flow;
-	unsigned int len;
-
-	pr_debug("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
-	list_for_each_entry(flow, &p->flows, list) {
-		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
-			return len;
-	}
-	return 0;
-}
-
 static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -672,7 +658,6 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
 	.peek		= atm_tc_peek,
-	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
 	.reset		= atm_tc_reset,
 	.destroy	= atm_tc_destroy,
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 7f4d6c5..f2af31b 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1025,31 +1025,6 @@ static void cbq_link_class(struct cbq_class *this)
 	}
 }
 
-static unsigned int cbq_drop(struct Qdisc *sch)
-{
-	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl, *cl_head;
-	int prio;
-	unsigned int len;
-
-	for (prio = TC_CBQ_MAXPRIO; prio >= 0; prio--) {
-		cl_head = q->active[prio];
-		if (!cl_head)
-			continue;
-
-		cl = cl_head;
-		do {
-			if (cl->q->ops->drop && (len = cl->q->ops->drop(cl->q))) {
-				sch->q.qlen--;
-				if (!cl->q->q.qlen)
-					cbq_deactivate_class(cl);
-				return len;
-			}
-		} while ((cl = cl->next_alive) != cl_head);
-	}
-	return 0;
-}
-
 static void
 cbq_reset(struct Qdisc *sch)
 {
@@ -1791,7 +1766,6 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	cbq_drop,
 	.init		=	cbq_init,
 	.reset		=	cbq_reset,
 	.destroy	=	cbq_destroy,
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 0a08c86..04e0b05 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -365,22 +365,6 @@ static struct sk_buff *choke_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static unsigned int choke_drop(struct Qdisc *sch)
-{
-	struct choke_sched_data *q = qdisc_priv(sch);
-	unsigned int len;
-
-	len = qdisc_queue_drop(sch);
-	if (len > 0)
-		q->stats.other++;
-	else {
-		if (!red_is_idling(&q->vars))
-			red_start_of_idle_period(&q->vars);
-	}
-
-	return len;
-}
-
 static void choke_reset(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
@@ -569,7 +553,6 @@ static struct Qdisc_ops choke_qdisc_ops __read_mostly = {
 	.enqueue	=	choke_enqueue,
 	.dequeue	=	choke_dequeue,
 	.peek		=	choke_peek_head,
-	.drop		=	choke_drop,
 	.init		=	choke_init,
 	.destroy	=	choke_destroy,
 	.reset		=	choke_reset,
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 1b7e1a2..2bec94c 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -421,26 +421,6 @@ out:
 	return NULL;
 }
 
-static unsigned int drr_drop(struct Qdisc *sch)
-{
-	struct drr_sched *q = qdisc_priv(sch);
-	struct drr_class *cl;
-	unsigned int len;
-
-	list_for_each_entry(cl, &q->active, alist) {
-		if (cl->qdisc->ops->drop) {
-			len = cl->qdisc->ops->drop(cl->qdisc);
-			if (len > 0) {
-				sch->q.qlen--;
-				if (cl->qdisc->q.qlen == 0)
-					list_del(&cl->alist);
-				return len;
-			}
-		}
-	}
-	return 0;
-}
-
 static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct drr_sched *q = qdisc_priv(sch);
@@ -509,7 +489,6 @@ static struct Qdisc_ops drr_qdisc_ops __read_mostly = {
 	.enqueue	= drr_enqueue,
 	.dequeue	= drr_dequeue,
 	.peek		= qdisc_peek_dequeued,
-	.drop		= drr_drop,
 	.init		= drr_init_qdisc,
 	.reset		= drr_reset_qdisc,
 	.destroy	= drr_destroy_qdisc,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 34b4dda..b9ba5f6 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -320,23 +320,6 @@ static struct sk_buff *dsmark_peek(struct Qdisc *sch)
 	return p->q->ops->peek(p->q);
 }
 
-static unsigned int dsmark_drop(struct Qdisc *sch)
-{
-	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	unsigned int len;
-
-	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
-
-	if (p->q->ops->drop == NULL)
-		return 0;
-
-	len = p->q->ops->drop(p->q);
-	if (len)
-		sch->q.qlen--;
-
-	return len;
-}
-
 static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -489,7 +472,6 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
 	.peek		=	dsmark_peek,
-	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
 	.reset		=	dsmark_reset,
 	.destroy	=	dsmark_destroy,
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 7857f74..dea70e3 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -99,7 +99,6 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
 	.change		=	fifo_init,
@@ -114,7 +113,6 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
 	.change		=	fifo_init,
@@ -129,7 +127,6 @@ struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.enqueue	=	pfifo_tail_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
-	.drop		=	qdisc_queue_drop_head,
 	.init		=	fifo_init,
 	.reset		=	qdisc_reset_queue,
 	.change		=	fifo_init,
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 1daa542..176a7e2 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -184,15 +184,6 @@ static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets)
 	return idx;
 }
 
-static unsigned int fq_codel_qdisc_drop(struct Qdisc *sch)
-{
-	unsigned int prev_backlog;
-
-	prev_backlog = sch->qstats.backlog;
-	fq_codel_drop(sch, 1U);
-	return prev_backlog - sch->qstats.backlog;
-}
-
 static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
@@ -704,7 +695,6 @@ static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.enqueue	=	fq_codel_enqueue,
 	.dequeue	=	fq_codel_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	fq_codel_qdisc_drop,
 	.init		=	fq_codel_init,
 	.reset		=	fq_codel_reset,
 	.destroy	=	fq_codel_destroy,
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 8010510..b5fb63c7 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -276,40 +276,6 @@ static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
-static unsigned int gred_drop(struct Qdisc *sch)
-{
-	struct sk_buff *skb;
-	struct gred_sched *t = qdisc_priv(sch);
-
-	skb = qdisc_dequeue_tail(sch);
-	if (skb) {
-		unsigned int len = qdisc_pkt_len(skb);
-		struct gred_sched_data *q;
-		u16 dp = tc_index_to_dp(skb);
-
-		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
-			net_warn_ratelimited("GRED: Unable to relocate VQ 0x%x while dropping, screwing up backlog\n",
-					     tc_index_to_dp(skb));
-		} else {
-			q->backlog -= len;
-			q->stats.other++;
-
-			if (gred_wred_mode(t)) {
-				if (!sch->qstats.backlog)
-					red_start_of_idle_period(&t->wred_set);
-			} else {
-				if (!q->backlog)
-					red_start_of_idle_period(&q->vars);
-			}
-		}
-
-		qdisc_drop(skb, sch);
-		return len;
-	}
-
-	return 0;
-}
-
 static void gred_reset(struct Qdisc *sch)
 {
 	int i;
@@ -623,7 +589,6 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
 	.peek		=	qdisc_peek_head,
-	.drop		=	gred_drop,
 	.init		=	gred_init,
 	.reset		=	gred_reset,
 	.destroy	=	gred_destroy,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 74813dd..155e3ce 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1677,31 +1677,6 @@ hfsc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
-static unsigned int
-hfsc_drop(struct Qdisc *sch)
-{
-	struct hfsc_sched *q = qdisc_priv(sch);
-	struct hfsc_class *cl;
-	unsigned int len;
-
-	list_for_each_entry(cl, &q->droplist, dlist) {
-		if (cl->qdisc->ops->drop != NULL &&
-		    (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
-			if (cl->qdisc->q.qlen == 0) {
-				update_vf(cl, 0, 0);
-				set_passive(cl);
-			} else {
-				list_move_tail(&cl->dlist, &q->droplist);
-			}
-			cl->qstats.drops++;
-			qdisc_qstats_drop(sch);
-			sch->q.qlen--;
-			return len;
-		}
-	}
-	return 0;
-}
-
 static const struct Qdisc_class_ops hfsc_class_ops = {
 	.change		= hfsc_change_class,
 	.delete		= hfsc_delete_class,
@@ -1728,7 +1703,6 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
 	.peek		= qdisc_peek_dequeued,
-	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
 	.priv_size	= sizeof(struct hfsc_sched),
 	.owner		= THIS_MODULE
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 13d6f83..c517918 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -368,15 +368,6 @@ static unsigned int hhf_drop(struct Qdisc *sch)
 	return bucket - q->buckets;
 }
 
-static unsigned int hhf_qdisc_drop(struct Qdisc *sch)
-{
-	unsigned int prev_backlog;
-
-	prev_backlog = sch->qstats.backlog;
-	hhf_drop(sch);
-	return prev_backlog - sch->qstats.backlog;
-}
-
 static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hhf_sched_data *q = qdisc_priv(sch);
@@ -709,7 +700,6 @@ static struct Qdisc_ops hhf_qdisc_ops __read_mostly = {
 	.enqueue	=	hhf_enqueue,
 	.dequeue	=	hhf_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	hhf_qdisc_drop,
 	.init		=	hhf_init,
 	.reset		=	hhf_reset,
 	.destroy	=	hhf_destroy,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2b05764..b74d066 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -936,31 +936,6 @@ fin:
 	return skb;
 }
 
-/* try to drop from each class (by prio) until one succeed */
-static unsigned int htb_drop(struct Qdisc *sch)
-{
-	struct htb_sched *q = qdisc_priv(sch);
-	int prio;
-
-	for (prio = TC_HTB_NUMPRIO - 1; prio >= 0; prio--) {
-		struct list_head *p;
-		list_for_each(p, q->drops + prio) {
-			struct htb_class *cl = list_entry(p, struct htb_class,
-							  un.leaf.drop_list);
-			unsigned int len;
-			if (cl->un.leaf.q->ops->drop &&
-			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
-				sch->qstats.backlog -= len;
-				sch->q.qlen--;
-				if (!cl->un.leaf.q->q.qlen)
-					htb_deactivate(q, cl);
-				return len;
-			}
-		}
-	}
-	return 0;
-}
-
 /* reset all classes */
 /* always caled under BH & queue lock */
 static void htb_reset(struct Qdisc *sch)
@@ -1600,7 +1575,6 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	htb_drop,
 	.init		=	htb_init,
 	.reset		=	htb_reset,
 	.destroy	=	htb_destroy,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 21e69d2..5ea9330 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -151,27 +151,6 @@ static struct sk_buff *multiq_peek(struct Qdisc *sch)
 
 }
 
-static unsigned int multiq_drop(struct Qdisc *sch)
-{
-	struct multiq_sched_data *q = qdisc_priv(sch);
-	int band;
-	unsigned int len;
-	struct Qdisc *qdisc;
-
-	for (band = q->bands - 1; band >= 0; band--) {
-		qdisc = q->queues[band];
-		if (qdisc->ops->drop) {
-			len = qdisc->ops->drop(qdisc);
-			if (len != 0) {
-				sch->q.qlen--;
-				return len;
-			}
-		}
-	}
-	return 0;
-}
-
-
 static void
 multiq_reset(struct Qdisc *sch)
 {
@@ -416,7 +395,6 @@ static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
 	.enqueue	=	multiq_enqueue,
 	.dequeue	=	multiq_dequeue,
 	.peek		=	multiq_peek,
-	.drop		=	multiq_drop,
 	.init		=	multiq_init,
 	.reset		=	multiq_reset,
 	.destroy	=	multiq_destroy,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 31984c7..9ca7947 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -576,35 +576,6 @@ finish_segs:
 	return NET_XMIT_SUCCESS;
 }
 
-static unsigned int netem_drop(struct Qdisc *sch)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned int len;
-
-	len = qdisc_queue_drop(sch);
-
-	if (!len) {
-		struct rb_node *p = rb_first(&q->t_root);
-
-		if (p) {
-			struct sk_buff *skb = netem_rb_to_skb(p);
-
-			rb_erase(p, &q->t_root);
-			sch->q.qlen--;
-			skb->next = NULL;
-			skb->prev = NULL;
-			qdisc_qstats_backlog_dec(sch, skb);
-			kfree_skb(skb);
-		}
-	}
-	if (!len && q->qdisc && q->qdisc->ops->drop)
-	    len = q->qdisc->ops->drop(q->qdisc);
-	if (len)
-		qdisc_qstats_drop(sch);
-
-	return len;
-}
-
 static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -1143,7 +1114,6 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	netem_drop,
 	.init		=	netem_init,
 	.reset		=	netem_reset,
 	.destroy	=	netem_destroy,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 06eca70..4c77780 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -125,24 +125,6 @@ static struct sk_buff *prio_dequeue(struct Qdisc *sch)
 
 }
 
-static unsigned int prio_drop(struct Qdisc *sch)
-{
-	struct prio_sched_data *q = qdisc_priv(sch);
-	int prio;
-	unsigned int len;
-	struct Qdisc *qdisc;
-
-	for (prio = q->bands-1; prio >= 0; prio--) {
-		qdisc = q->queues[prio];
-		if (qdisc->ops->drop && (len = qdisc->ops->drop(qdisc)) != 0) {
-			sch->q.qlen--;
-			return len;
-		}
-	}
-	return 0;
-}
-
-
 static void
 prio_reset(struct Qdisc *sch)
 {
@@ -379,7 +361,6 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
 	.peek		=	prio_peek,
-	.drop		=	prio_drop,
 	.init		=	prio_init,
 	.reset		=	prio_reset,
 	.destroy	=	prio_destroy,
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 85d4197..cdb3966 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1423,52 +1423,6 @@ static void qfq_qlen_notify(struct Qdisc *sch, unsigned long arg)
 		qfq_deactivate_class(q, cl);
 }
 
-static unsigned int qfq_drop_from_slot(struct qfq_sched *q,
-				       struct hlist_head *slot)
-{
-	struct qfq_aggregate *agg;
-	struct qfq_class *cl;
-	unsigned int len;
-
-	hlist_for_each_entry(agg, slot, next) {
-		list_for_each_entry(cl, &agg->active, alist) {
-
-			if (!cl->qdisc->ops->drop)
-				continue;
-
-			len = cl->qdisc->ops->drop(cl->qdisc);
-			if (len > 0) {
-				if (cl->qdisc->q.qlen == 0)
-					qfq_deactivate_class(q, cl);
-
-				return len;
-			}
-		}
-	}
-	return 0;
-}
-
-static unsigned int qfq_drop(struct Qdisc *sch)
-{
-	struct qfq_sched *q = qdisc_priv(sch);
-	struct qfq_group *grp;
-	unsigned int i, j, len;
-
-	for (i = 0; i <= QFQ_MAX_INDEX; i++) {
-		grp = &q->groups[i];
-		for (j = 0; j < QFQ_MAX_SLOTS; j++) {
-			len = qfq_drop_from_slot(q, &grp->slots[j]);
-			if (len > 0) {
-				sch->q.qlen--;
-				return len;
-			}
-		}
-
-	}
-
-	return 0;
-}
-
 static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
@@ -1563,7 +1517,6 @@ static struct Qdisc_ops qfq_qdisc_ops __read_mostly = {
 	.enqueue	= qfq_enqueue,
 	.dequeue	= qfq_dequeue,
 	.peek		= qdisc_peek_dequeued,
-	.drop		= qfq_drop,
 	.init		= qfq_init_qdisc,
 	.reset		= qfq_reset_qdisc,
 	.destroy	= qfq_destroy_qdisc,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 8c0508c..235942f 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -134,25 +134,6 @@ static struct sk_buff *red_peek(struct Qdisc *sch)
 	return child->ops->peek(child);
 }
 
-static unsigned int red_drop(struct Qdisc *sch)
-{
-	struct red_sched_data *q = qdisc_priv(sch);
-	struct Qdisc *child = q->qdisc;
-	unsigned int len;
-
-	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
-		q->stats.other++;
-		qdisc_qstats_drop(sch);
-		sch->q.qlen--;
-		return len;
-	}
-
-	if (!red_is_idling(&q->vars))
-		red_start_of_idle_period(&q->vars);
-
-	return 0;
-}
-
 static void red_reset(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -361,7 +342,6 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
 	.peek		=	red_peek,
-	.drop		=	red_drop,
 	.init		=	red_init,
 	.reset		=	red_reset,
 	.destroy	=	red_destroy,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 498f0a2..a2e0b85 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -896,7 +896,6 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	sfq_drop,
 	.init		=	sfq_init,
 	.reset		=	sfq_reset,
 	.destroy	=	sfq_destroy,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 801148c..1342e46 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -211,18 +211,6 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
-static unsigned int tbf_drop(struct Qdisc *sch)
-{
-	struct tbf_sched_data *q = qdisc_priv(sch);
-	unsigned int len = 0;
-
-	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
-		sch->q.qlen--;
-		qdisc_qstats_drop(sch);
-	}
-	return len;
-}
-
 static bool tbf_peak_present(const struct tbf_sched_data *q)
 {
 	return q->peak.rate_bytes_ps;
@@ -555,7 +543,6 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	tbf_drop,
 	.init		=	tbf_init,
 	.reset		=	tbf_reset,
 	.destroy	=	tbf_destroy,
-- 
2.7.3
