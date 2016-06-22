From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 12:03:55 +0200
Message-ID: <1466589835-18521-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33073 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751549AbcFVKDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 06:03:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently classification and enqueue is done in a single step.

core acquires the qdisc lock, then calls the ->enqueue() function
of the qdisc.

Its the job of the qdisc and its attached classifiers to figure out what
to do next.

Typically the enqueue function will call tc_classify() to lookup a
child class, then call ->enqueue of the child qdisc.

This can repeat a number of times until a leaf qdisc is reached; this leaf
will do the real enqueue operation (pfifo for example).

While this approach gives qdiscs and the classifier/action subsystem
a lot of control, it has one major drawback:  The root qdisc lock
is held for a prolonged period of time while we recurse through
the qdisc hierarchy from root to leaf.

This (unfinished!) hack splits classification and enqueue into
two steps.

Before enqueueing the packet and *before* acquiring the root qdisc lock,
the new qdisc ->classify() function is invoked.

This function -- much like enqueue in the current scheme -- looks up
a child class and/or determines the next qdisc where the packet needs
to be handled via the classifier action subsystem.
Then it invokes the new ->classify() hook of the child, which can repeat
until the leaf qdisc is reached.

Whenever a classify operation has succeeded, each classify "level"
stores itself (qdisc) and a cookie (typically just a pointer to the
class) in the newly added Qdisc_classify_state struct.

After qdisc_classify returns, this struct contains the path that
the skb is supposed to take through the qdisc hierarchy in *reverse*
order, i.e. starting from the leaf up to the root.

Then, the root qdisc lock is taken and the *leaf* (first entry in
Qdisc_classify_state) ->enqueue function is invoked.

If this succeeds, the kernel will invoke the new ->senqeue
function for all the remaining entries in Qdisc_classify_state.

This function is responsible to perform needed qdisc internal actions,
f.e. scheduling a class for transmit.

This reduces the amount of work done under qdisc root lock.
Very simple test w. hfsc + u32 filter, gso off, 10G link and 20 netperf
TCP_STREAM:

  before: 8.2 GB/s
  after: 9.4 GB/s (same as w. mq+fq_codel)

Known issues with this patch:
 - only converted a few qdiscs
 - qdisc stats will race since they're changed outside of root lock.
 - need to protect vs. class removal during classify ops
 - mirred needs some work for this (but not worse than current situation)
 - use-after-free in some places, need to ensure that skb remains valid
   iff enqueue returns != DROP.
 - senqeue is a horrid name.  It is probably better to split qdiscs
   into leaf and non-leaf ones, where leaf qdiscs implement ->enqueue() and
   the others a notify_enqueue() (which doesn't return a value).

So far I did not see any fundamental issues with this approach.

If you see any, I'd be happy to learn about them before I spend more
cycles on this.  The main work to be done is to convert qstats to
percpu counters and then convert all the qdiscs to this new scheme,
and of course to extend this to all intree schedulers.

If you attend NF workshop in Amsterdam feel free to yell at me in person there.
---
 include/net/sch_generic.h | 50 +++++++++++++++++++++++++++++++++
 net/core/dev.c            | 10 ++++++-
 net/sched/sch_drr.c       | 38 +++++++++++++++++++++++--
 net/sched/sch_fq_codel.c  | 71 +++++++++++++++++++++++++++++++++++++++++++++--
 net/sched/sch_generic.c   | 32 +++++++++++++++++++++
 net/sched/sch_hfsc.c      | 38 +++++++++++++++++++++++--
 6 files changed, 232 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4f7cee8..80e6b91 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -36,6 +36,17 @@ struct qdisc_size_table {
 	u16			data[];
 };
 
+#define QDISC_MAX_CLASS_DEPTH 4
+struct __Qdisc_classify_state {
+	struct Qdisc *qdisc;
+	unsigned long cookie;
+};
+
+struct Qdisc_classify_state {
+	u8 depth;
+	struct __Qdisc_classify_state nodes[QDISC_MAX_CLASS_DEPTH];
+};
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
@@ -160,6 +171,8 @@ struct Qdisc_ops {
 	char			id[IFNAMSIZ];
 	int			priv_size;
 
+	int 			(*senqueue)(struct sk_buff *skb, struct Qdisc *dev, unsigned long cookie);
+	int			(*classify)(struct sk_buff *skb, struct Qdisc *dev, struct Qdisc_classify_state *);
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
@@ -784,4 +797,41 @@ static inline void psched_ratecfg_getrate(struct tc_ratespec *res,
 	res->linklayer = (r->linklayer & TC_LINKLAYER_MASK);
 }
 
+static inline int qdisc_classify_ok(struct Qdisc_classify_state *s, struct Qdisc *q,
+				    unsigned long cookie)
+{
+	if (s->depth >= ARRAY_SIZE(s->nodes))
+		return -ENOSPC;
+
+	s->nodes[s->depth].cookie = cookie;
+	s->nodes[s->depth].qdisc = q;
+
+	s->depth++;
+	return 0;
+}
+
+/* skb is NOT freed */
+
+static inline void qdisc_classify_init(struct Qdisc_classify_state *s)
+{
+	s->depth = 0;
+}
+
+static inline int qdisc_classify(struct sk_buff *skb, struct Qdisc *q,
+				 struct Qdisc_classify_state *s)
+{
+	if (unlikely(q->ops->classify)) {
+		int err = q->ops->classify(skb, q, s);
+
+		/* XXX: needs to be percpu */
+		if (err & __NET_XMIT_BYPASS)
+			qdisc_qstats_drop(q);
+
+		return err;
+	}
+
+	return qdisc_classify_ok(s, q, 0);
+}
+
+int qdisc_enqueue_state(struct sk_buff *skb, const struct Qdisc_classify_state *s);
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index d40593b..1e4eed0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3070,10 +3070,15 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct netdev_queue *txq)
 {
 	spinlock_t *root_lock = qdisc_lock(q);
+	struct Qdisc_classify_state state;
 	bool contended;
 	int rc;
 
 	qdisc_calculate_pkt_len(skb, q);
+
+	qdisc_classify_init(&state);
+	qdisc_classify(skb, q, &state);
+
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
@@ -3109,7 +3114,10 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
-		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
+		if (q->ops->senqueue)
+			rc = qdisc_enqueue_state(skb, &state);
+		else
+			rc = q->enqueue(skb, q) & NET_XMIT_MASK;
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 22609e4..f5f7b32 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -314,7 +314,7 @@ static void drr_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	}
 }
 
-static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
+static struct drr_class *__drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 				      int *qerr)
 {
 	struct drr_sched *q = qdisc_priv(sch);
@@ -350,13 +350,45 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 	return NULL;
 }
 
+static int
+drr_senqueue(struct sk_buff *skb, struct Qdisc *sch, unsigned long cookie)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl = (void *)cookie;
+
+	if (cl->qdisc->q.qlen == 1) {
+		list_add_tail(&cl->alist, &q->active);
+		cl->deficit = cl->quantum;
+	}
+
+	return 0;
+}
+
+static int drr_classify(struct sk_buff *skb, struct Qdisc *sch,
+			struct Qdisc_classify_state *state)
+{
+	struct drr_class *cl;
+	int err;
+
+	cl = __drr_classify(skb, sch, &err);
+	if (cl == NULL)
+		return err;
+
+	err = qdisc_classify(skb, cl->qdisc, state);
+
+	if (err == 0)
+		return qdisc_classify_ok(state, sch, (unsigned long)cl);
+
+	return err;
+}
+
 static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl;
 	int err = 0;
 
-	cl = drr_classify(skb, sch, &err);
+	cl = __drr_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
@@ -490,6 +522,8 @@ static struct Qdisc_ops drr_qdisc_ops __read_mostly = {
 	.id		= "drr",
 	.priv_size	= sizeof(struct drr_sched),
 	.enqueue	= drr_enqueue,
+	.senqueue	= drr_senqueue,
+	.classify	= drr_classify,
 	.dequeue	= drr_dequeue,
 	.peek		= qdisc_peek_dequeued,
 	.init		= drr_init_qdisc,
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 2dc0a84..8876961 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -80,7 +80,7 @@ static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
 	return reciprocal_scale(hash, q->flows_cnt);
 }
 
-static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
+static unsigned int __fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 				      int *qerr)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
@@ -193,7 +193,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	unsigned int pkt_len;
 	bool memory_limited;
 
-	idx = fq_codel_classify(skb, sch, &ret);
+	idx = __fq_codel_classify(skb, sch, &ret);
 	if (idx == 0) {
 		if (ret & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
@@ -250,6 +250,71 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+static int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
+			     struct Qdisc_classify_state *state)
+{
+	int uninitialized_var(ret);
+	unsigned int idx;
+
+	idx = __fq_codel_classify(skb, sch, &ret);
+	if (idx == 0) {
+		if (ret & __NET_XMIT_BYPASS)
+			qdisc_qstats_drop(sch);
+		kfree_skb(skb);
+		return ret;
+	}
+	idx--;
+
+	return qdisc_classify_ok(state, sch, (unsigned long)idx);
+}
+
+static int fq_codel_senqueue(struct sk_buff *skb, struct Qdisc *sch, unsigned long cookie)
+{
+	struct fq_codel_sched_data *q = qdisc_priv(sch);
+	unsigned int idx, prev_backlog, prev_qlen;
+	struct fq_codel_flow *flow;
+	int uninitialized_var(ret);
+	bool memory_limited;
+
+	idx = (unsigned int)cookie;
+
+	codel_set_enqueue_time(skb);
+	flow = &q->flows[idx];
+	flow_queue_add(flow, skb);
+	q->backlogs[idx] += qdisc_pkt_len(skb);
+	qdisc_qstats_backlog_inc(sch, skb);
+
+	if (list_empty(&flow->flowchain)) {
+		list_add_tail(&flow->flowchain, &q->new_flows);
+		q->new_flow_count++;
+		flow->deficit = q->quantum;
+		flow->dropped = 0;
+	}
+	q->memory_usage += skb->truesize;
+	memory_limited = q->memory_usage > q->memory_limit;
+	if (sch->q.qlen < sch->limit && !memory_limited)
+		return NET_XMIT_SUCCESS;
+
+	prev_backlog = sch->qstats.backlog;
+	prev_qlen = sch->q.qlen;
+
+	/* fq_codel_drop() is quite expensive, as it performs a linear search
+	 * in q->backlogs[] to find a fat flow.
+	 * So instead of dropping a single packet, drop half of its backlog
+	 * with a 64 packets limit to not add a too big cpu spike here.
+	 */
+	ret = fq_codel_drop(sch, q->drop_batch_size);
+
+	q->drop_overlimit += prev_qlen - sch->q.qlen;
+	if (memory_limited)
+		q->drop_overmemory += prev_qlen - sch->q.qlen;
+	/* As we dropped packet(s), better let upper stack know this */
+	qdisc_tree_reduce_backlog(sch, prev_qlen - sch->q.qlen,
+				  prev_backlog - sch->qstats.backlog);
+
+	return ret == idx ? NET_XMIT_CN : NET_XMIT_SUCCESS;
+}
+
 /* This is the specific function called from codel_dequeue()
  * to dequeue a packet from queue. Note: backlog is handled in
  * codel, we dont need to reduce it here.
@@ -706,6 +771,8 @@ static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.id		=	"fq_codel",
 	.priv_size	=	sizeof(struct fq_codel_sched_data),
 	.enqueue	=	fq_codel_enqueue,
+	.senqueue	=	fq_codel_senqueue,
+	.classify	=	fq_codel_classify,
 	.dequeue	=	fq_codel_dequeue,
 	.peek		=	qdisc_peek_dequeued,
 	.init		=	fq_codel_init,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 773b632..a9a2fed 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -960,3 +960,35 @@ void psched_ratecfg_precompute(struct psched_ratecfg *r,
 	}
 }
 EXPORT_SYMBOL(psched_ratecfg_precompute);
+
+int qdisc_enqueue_state(struct sk_buff *skb, const struct Qdisc_classify_state *s)
+{
+	int err, i;
+	struct Qdisc *sch;
+
+	for (i = 0; i < s->depth; i++) {
+		sch = s->nodes[i].qdisc;
+
+		if (sch->ops->senqueue == NULL) {
+			BUG_ON(i != 0);
+
+			err = sch->enqueue(skb, sch);
+			if ((err & NET_XMIT_MASK) == NET_XMIT_DROP)
+				return err;
+
+			continue;
+		}
+
+		err = sch->ops->senqueue(skb, sch, s->nodes[i].cookie);
+		if (err) {
+			/* XXX: add error callback...? */
+			/* Better: Generic stats for all */
+			WARN_ON(i);
+			return err;
+		}
+
+		sch->q.qlen++;
+	}
+
+	return 0;
+}
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index bd08c36..fa8fca9 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1150,7 +1150,7 @@ hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 }
 
 static struct hfsc_class *
-hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
+__hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *head, *cl;
@@ -1571,13 +1571,45 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	return -1;
 }
 
+static int hfsc_classify(struct sk_buff *skb, struct Qdisc *sch,
+			 struct Qdisc_classify_state *state)
+{
+	struct hfsc_class *cl;
+	int err;
+
+	cl = __hfsc_classify(skb, sch, &err);
+	if (cl == NULL)
+		return err;
+
+	err = qdisc_classify(skb, cl->qdisc, state);
+
+	if (err == 0)
+		return qdisc_classify_ok(state, sch, (unsigned long)cl);
+
+	return err;
+}
+
+static int
+hfsc_senqueue(struct sk_buff *skb, struct Qdisc *sch, unsigned long cookie)
+{
+	struct hfsc_class *cl;
+	int uninitialized_var(err);
+
+	cl = (void *)cookie;
+
+	if (cl->qdisc->q.qlen == 1)
+		set_active(cl, qdisc_pkt_len(skb));
+
+	return NET_XMIT_SUCCESS;
+}
+
 static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hfsc_class *cl;
 	int uninitialized_var(err);
 
-	cl = hfsc_classify(skb, sch, &err);
+	cl = __hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
 		if (err & __NET_XMIT_BYPASS)
 			qdisc_qstats_drop(sch);
@@ -1695,6 +1727,8 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.destroy	= hfsc_destroy_qdisc,
 	.dump		= hfsc_dump_qdisc,
 	.enqueue	= hfsc_enqueue,
+	.senqueue	= hfsc_senqueue,
+	.classify	= hfsc_classify,
 	.dequeue	= hfsc_dequeue,
 	.peek		= qdisc_peek_dequeued,
 	.cl_ops		= &hfsc_class_ops,
-- 
2.7.3
