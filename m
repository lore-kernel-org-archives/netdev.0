From: Vimalkumar <j.vimal@gmail.com>
Subject: [PATCH net-next V3] htb: improved accuracy at high rates
Date: Wed, 31 Oct 2012 09:04:11 -0700
Message-ID: <1351699451-79317-1-git-send-email-j.vimal@gmail.com>
Cc: Vimalkumar <j.vimal@gmail.com>
To: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59138 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422946Ab2JaQEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:04:40 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so1061912pad.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 09:04:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current HTB (and TBF) uses rate table computed by the "tc"
userspace program, which has the following issue:

The rate table has 256 entries to map packet lengths
to token (time units).  With TSO sized packets, the
256 entry granularity leads to loss/gain of rate,
making the token bucket inaccurate.

Thus, instead of relying on rate table, this patch
explicitly computes the time and accounts for packet
transmission times with nanosecond granularity.

This greatly improves accuracy of HTB with a wide
range of packet sizes.

Example:

tc qdisc add dev $dev root handle 1: \
        htb default 1

tc class add dev $dev classid 1:1 parent 1: \
        rate 5Gbit mtu 64k

Here is an example of inaccuracy:

$ iperf -c host -t 10 -i 1

With old htb:
eth4:   34.76 Mb/s In  5827.98 Mb/s Out -  65836.0 p/s In  481273.0 p/s Out
[SUM]  9.0-10.0 sec   669 MBytes  5.61 Gbits/sec
[SUM]  0.0-10.0 sec  6.50 GBytes  5.58 Gbits/sec

With new htb:
eth4:   28.36 Mb/s In  5208.06 Mb/s Out -  53704.0 p/s In  430076.0 p/s Out
[SUM]  9.0-10.0 sec   594 MBytes  4.98 Gbits/sec
[SUM]  0.0-10.0 sec  5.80 GBytes  4.98 Gbits/sec

The bits per second on the wire is still 5200Mb/s with new HTB
because qdisc accounts for packet length using skb->len, which
is smaller than total bytes on the wire if GSO is used.  But
that is for another patch regardless of how time is accounted.

Many thanks to Eric Dumazet for review and feedback.

Signed-off-by: Vimalkumar <j.vimal@gmail.com>
---
 net/sched/sch_htb.c |  128 ++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 90 insertions(+), 38 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9d75b77..32a8097 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -71,6 +71,12 @@ enum htb_cmode {
 	HTB_CAN_SEND		/* class can send */
 };
 
+struct htb_rate_cfg {
+	u64 rate_bps;
+	u32 mult;
+	u32 shift;
+};
+
 /* interior & leaf nodes; props specific to leaves are marked L: */
 struct htb_class {
 	struct Qdisc_class_common common;
@@ -118,11 +124,11 @@ struct htb_class {
 	int filter_cnt;
 
 	/* token bucket parameters */
-	struct qdisc_rate_table *rate;	/* rate table of the class itself */
-	struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
-	long buffer, cbuffer;	/* token bucket depth/rate */
+	struct htb_rate_cfg rate;
+	struct htb_rate_cfg ceil;
+	s64 buffer, cbuffer;	/* token bucket depth/rate */
 	psched_tdiff_t mbuffer;	/* max wait time */
-	long tokens, ctokens;	/* current number of tokens */
+	s64 tokens, ctokens;	/* current number of tokens */
 	psched_time_t t_c;	/* checkpoint time */
 };
 
@@ -162,6 +168,45 @@ struct htb_sched {
 	struct work_struct work;
 };
 
+static u64 l2t_ns(struct htb_rate_cfg *r, unsigned int len)
+{
+	return ((u64)len * r->mult) >> r->shift;
+}
+
+static void htb_precompute_ratedata(struct htb_rate_cfg *r)
+{
+	u64 factor;
+	u64 mult;
+	int shift;
+
+	r->shift = 0;
+	r->mult = 1;
+	/*
+	 * Calibrate mult, shift so that token counting is accurate
+	 * for smallest packet size (64 bytes).  Token (time in ns) is
+	 * computed as (bytes * 8) * NSEC_PER_SEC / rate_bps.  It will
+	 * work as long as the smallest packet transfer time can be
+	 * accurately represented in nanosec.
+	 */
+	if (r->rate_bps > 0) {
+		/*
+		 * Higher shift gives better accuracy.  Find the largest
+		 * shift such that mult fits in 32 bits.
+		 */
+		for (shift = 0; shift < 16; shift++) {
+			r->shift = shift;
+			factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
+			mult = div64_u64(factor, r->rate_bps);
+			if (mult > UINT_MAX)
+				break;
+		}
+
+		r->shift = shift - 1;
+		factor = 8LLU * NSEC_PER_SEC * (1 << r->shift);
+		r->mult = div64_u64(factor, r->rate_bps);
+	}
+}
+
 /* find class in global hash table using given handle */
 static inline struct htb_class *htb_find(u32 handle, struct Qdisc *sch)
 {
@@ -273,7 +318,7 @@ static void htb_add_to_id_tree(struct rb_root *root,
  * already in the queue.
  */
 static void htb_add_to_wait_tree(struct htb_sched *q,
-				 struct htb_class *cl, long delay)
+				 struct htb_class *cl, s64 delay)
 {
 	struct rb_node **p = &q->wait_pq[cl->level].rb_node, *parent = NULL;
 
@@ -441,14 +486,14 @@ static void htb_deactivate_prios(struct htb_sched *q, struct htb_class *cl)
 		htb_remove_class_from_row(q, cl, mask);
 }
 
-static inline long htb_lowater(const struct htb_class *cl)
+static inline s64 htb_lowater(const struct htb_class *cl)
 {
 	if (htb_hysteresis)
 		return cl->cmode != HTB_CANT_SEND ? -cl->cbuffer : 0;
 	else
 		return 0;
 }
-static inline long htb_hiwater(const struct htb_class *cl)
+static inline s64 htb_hiwater(const struct htb_class *cl)
 {
 	if (htb_hysteresis)
 		return cl->cmode == HTB_CAN_SEND ? -cl->buffer : 0;
@@ -469,9 +514,9 @@ static inline long htb_hiwater(const struct htb_class *cl)
  * mode transitions per time unit. The speed gain is about 1/6.
  */
 static inline enum htb_cmode
-htb_class_mode(struct htb_class *cl, long *diff)
+htb_class_mode(struct htb_class *cl, s64 *diff)
 {
-	long toks;
+	s64 toks;
 
 	if ((toks = (cl->ctokens + *diff)) < htb_lowater(cl)) {
 		*diff = -toks;
@@ -495,7 +540,7 @@ htb_class_mode(struct htb_class *cl, long *diff)
  * to mode other than HTB_CAN_SEND (see htb_add_to_wait_tree).
  */
 static void
-htb_change_class_mode(struct htb_sched *q, struct htb_class *cl, long *diff)
+htb_change_class_mode(struct htb_sched *q, struct htb_class *cl, s64 *diff)
 {
 	enum htb_cmode new_mode = htb_class_mode(cl, diff);
 
@@ -581,26 +626,26 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
-static inline void htb_accnt_tokens(struct htb_class *cl, int bytes, long diff)
+static inline void htb_accnt_tokens(struct htb_class *cl, int bytes, s64 diff)
 {
-	long toks = diff + cl->tokens;
+	s64 toks = diff + cl->tokens;
 
 	if (toks > cl->buffer)
 		toks = cl->buffer;
-	toks -= (long) qdisc_l2t(cl->rate, bytes);
+	toks -= (s64) l2t_ns(&cl->rate, bytes);
 	if (toks <= -cl->mbuffer)
 		toks = 1 - cl->mbuffer;
 
 	cl->tokens = toks;
 }
 
-static inline void htb_accnt_ctokens(struct htb_class *cl, int bytes, long diff)
+static inline void htb_accnt_ctokens(struct htb_class *cl, int bytes, s64 diff)
 {
-	long toks = diff + cl->ctokens;
+	s64 toks = diff + cl->ctokens;
 
 	if (toks > cl->cbuffer)
 		toks = cl->cbuffer;
-	toks -= (long) qdisc_l2t(cl->ceil, bytes);
+	toks -= (s64) l2t_ns(&cl->ceil, bytes);
 	if (toks <= -cl->mbuffer)
 		toks = 1 - cl->mbuffer;
 
@@ -623,10 +668,10 @@ static void htb_charge_class(struct htb_sched *q, struct htb_class *cl,
 {
 	int bytes = qdisc_pkt_len(skb);
 	enum htb_cmode old_mode;
-	long diff;
+	s64 diff;
 
 	while (cl) {
-		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
+		diff = min_t(s64, q->now - cl->t_c, cl->mbuffer);
 		if (cl->level >= level) {
 			if (cl->level == level)
 				cl->xstats.lends++;
@@ -673,7 +718,7 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 	unsigned long stop_at = start + 2;
 	while (time_before(jiffies, stop_at)) {
 		struct htb_class *cl;
-		long diff;
+		s64 diff;
 		struct rb_node *p = rb_first(&q->wait_pq[level]);
 
 		if (!p)
@@ -684,7 +729,7 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 			return cl->pq_key;
 
 		htb_safe_rb_erase(p, q->wait_pq + level);
-		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
+		diff = min_t(s64, q->now - cl->t_c, cl->mbuffer);
 		htb_change_class_mode(q, cl, &diff);
 		if (cl->cmode != HTB_CAN_SEND)
 			htb_add_to_wait_tree(q, cl, diff);
@@ -834,7 +879,6 @@ next:
 	} while (cl != start);
 
 	if (likely(skb != NULL)) {
-		bstats_update(&cl->bstats, skb);
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->quantum;
@@ -871,10 +915,10 @@ ok:
 
 	if (!sch->q.qlen)
 		goto fin;
-	q->now = psched_get_time();
+	q->now = ktime_to_ns(ktime_get());
 	start_at = jiffies;
 
-	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
+	next_event = q->now + 5 * NSEC_PER_SEC;
 
 	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
 		/* common case optimization - skip event handler quickly */
@@ -884,7 +928,7 @@ ok:
 		if (q->now >= q->near_ev_cache[level]) {
 			event = htb_do_events(q, level, start_at);
 			if (!event)
-				event = q->now + PSCHED_TICKS_PER_SEC;
+				event = q->now + NSEC_PER_SEC;
 			q->near_ev_cache[level] = event;
 		} else
 			event = q->near_ev_cache[level];
@@ -903,10 +947,17 @@ ok:
 		}
 	}
 	sch->qstats.overlimits++;
-	if (likely(next_event > q->now))
-		qdisc_watchdog_schedule(&q->watchdog, next_event);
-	else
+	if (likely(next_event > q->now)) {
+		if (!test_bit(__QDISC_STATE_DEACTIVATED,
+			      &qdisc_root_sleeping(q->watchdog.qdisc)->state)) {
+			ktime_t time = ns_to_ktime(next_event);
+			qdisc_throttled(q->watchdog.qdisc);
+			hrtimer_start(&q->watchdog.timer, time,
+				      HRTIMER_MODE_ABS);
+		}
+	} else {
 		schedule_work(&q->work);
+	}
 fin:
 	return skb;
 }
@@ -1082,9 +1133,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 
 	memset(&opt, 0, sizeof(opt));
 
-	opt.rate = cl->rate->rate;
+	opt.rate.rate = cl->rate.rate_bps >> 3;
 	opt.buffer = cl->buffer;
-	opt.ceil = cl->ceil->rate;
+	opt.ceil.rate = cl->ceil.rate_bps >> 3;
 	opt.cbuffer = cl->cbuffer;
 	opt.quantum = cl->quantum;
 	opt.prio = cl->prio;
@@ -1203,9 +1254,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
-	qdisc_put_rtab(cl->rate);
-	qdisc_put_rtab(cl->ceil);
-
 	tcf_destroy_chain(&cl->filter_list);
 	kfree(cl);
 }
@@ -1460,12 +1508,16 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 	cl->buffer = hopt->buffer;
 	cl->cbuffer = hopt->cbuffer;
-	if (cl->rate)
-		qdisc_put_rtab(cl->rate);
-	cl->rate = rtab;
-	if (cl->ceil)
-		qdisc_put_rtab(cl->ceil);
-	cl->ceil = ctab;
+
+	cl->rate.rate_bps = (u64)rtab->rate.rate << 3;
+	cl->ceil.rate_bps = (u64)ctab->rate.rate << 3;
+
+	htb_precompute_ratedata(&cl->rate);
+	htb_precompute_ratedata(&cl->ceil);
+
+	cl->buffer = hopt->buffer << PSCHED_SHIFT;
+	cl->cbuffer = hopt->buffer << PSCHED_SHIFT;
+
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_grow(sch, &q->clhash);
-- 
1.7.5.3
