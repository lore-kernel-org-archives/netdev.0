From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Thu, 7 Feb 2013 18:39:09 +0100
Message-ID: <20130207173909.GA1651@minipsycho.orion>
References: <20130102152601.GB1532@minipsycho.orion>
 <1357144482.21409.16876.camel@edumazet-glaptop>
 <20130108133038.GB1621@minipsycho.orion>
 <20130124080536.GA1598@minipsycho.orion>
 <1359036087.12374.2088.camel@edumazet-glaptop>
 <20130129122357.GC7571@minipsycho.orion>
 <1359475983.30177.2.camel@edumazet-glaptop>
 <20130130121447.GB1604@minipsycho.orion>
 <20130207161327.GA1619@minipsycho.brq.redhat.com>
 <1360255175.28557.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:54613 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755851Ab3BGRjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 12:39:15 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so1542598eek.4
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 09:39:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360255175.28557.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 07, 2013 at 05:39:35PM CET, eric.dumazet@gmail.com wrote:
>On Thu, 2013-02-07 at 17:13 +0100, Jiri Pirko wrote:
>
>> >I tried kernel with this patch in. I also ported
>> >56b765b79e9a78dc7d3f8850ba5e5567205a3ecd to tbf. I'm getting always the
>> >similar numbers with iperf. There must be something else needed :/
>> 
>> Any other ideas?
>
>You didn't post any patch, how can I comment on them ?

Okay, sorry, here it is. But as I said, it did not help.

Subject: [patch net-next RFC] tbf: improved accuracy at high rates

Current TBF uses rate table computed by the "tc" userspace program,
which has the following issue:

The rate table has 256 entries to map packet lengths to
token (time units).  With TSO sized packets, the 256 entry granularity
leads to loss/gain of rate, making the token bucket inaccurate.

Thus, instead of relying on rate table, this patch explicitly computes
the time and accounts for packet transmission times with nanosecond
granularity.

This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_tbf.c | 97 +++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 71 insertions(+), 26 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 4b056c15..fdec80b 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -97,25 +97,68 @@
 	changed the limit is not effective anymore.
 */
 
+struct tbf_rate_cfg {
+	u64 rate_bps;
+	u32 mult;
+	u32 shift;
+};
+
 struct tbf_sched_data {
 /* Parameters */
 	u32		limit;		/* Maximal length of backlog: bytes */
 	u32		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
 	u32		mtu;
 	u32		max_size;
-	struct qdisc_rate_table	*R_tab;
-	struct qdisc_rate_table	*P_tab;
+	struct tbf_rate_cfg rate;
+	struct tbf_rate_cfg peek;
+	bool peek_present;
 
 /* Variables */
-	long	tokens;			/* Current number of B tokens */
-	long	ptokens;		/* Current number of P tokens */
+	s64	tokens;			/* Current number of B tokens */
+	s64	ptokens;		/* Current number of P tokens */
 	psched_time_t	t_c;		/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
-#define L2T(q, L)   qdisc_l2t((q)->R_tab, L)
-#define L2T_P(q, L) qdisc_l2t((q)->P_tab, L)
+static u64 l2t_ns(struct tbf_rate_cfg *r, unsigned int len)
+{
+	return ((u64)len * r->mult) >> r->shift;
+}
+
+static void htb_precompute_ratedata(struct tbf_rate_cfg *r)
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
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
@@ -157,23 +200,23 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 
 	if (skb) {
 		psched_time_t now;
-		long toks;
-		long ptoks = 0;
+		s64 toks;
+		s64 ptoks = 0;
 		unsigned int len = qdisc_pkt_len(skb);
 
-		now = psched_get_time();
-		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
+		now = ktime_to_ns(ktime_get());
+		toks = min_t(s64, now - q->t_c, q->buffer);
 
-		if (q->P_tab) {
+		if (q->peek_present) {
 			ptoks = toks + q->ptokens;
 			if (ptoks > (long)q->mtu)
 				ptoks = q->mtu;
-			ptoks -= L2T_P(q, len);
+			ptoks -= (s64) l2t_ns(&q->peek, len);
 		}
 		toks += q->tokens;
 		if (toks > (long)q->buffer)
 			toks = q->buffer;
-		toks -= L2T(q, len);
+		toks -= (s64) l2t_ns(&q->rate, len);
 
 		if ((toks|ptoks) >= 0) {
 			skb = qdisc_dequeue_peeked(q->qdisc);
@@ -214,7 +257,7 @@ static void tbf_reset(struct Qdisc *sch)
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	q->t_c = psched_get_time();
+	q->t_c = ktime_to_ns(ktime_get());
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -299,8 +342,16 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 
-	swap(q->R_tab, rtab);
-	swap(q->P_tab, ptab);
+	q->rate.rate_bps = (u64) rtab->rate.rate << 3;
+	if (ptab) {
+		q->peek.rate_bps = (u64) ptab->rate.rate << 3;
+		q->peek_present = true;
+	} else {
+		q->peek_present = false;
+	}
+
+	htb_precompute_ratedata(&q->rate);
+	htb_precompute_ratedata(&q->peek);
 
 	sch_tree_unlock(sch);
 	err = 0;
@@ -319,7 +370,7 @@ static int tbf_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	q->t_c = psched_get_time();
+	q->t_c = ktime_to_ns(ktime_get());
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
@@ -331,12 +382,6 @@ static void tbf_destroy(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	qdisc_watchdog_cancel(&q->watchdog);
-
-	if (q->P_tab)
-		qdisc_put_rtab(q->P_tab);
-	if (q->R_tab)
-		qdisc_put_rtab(q->R_tab);
-
 	qdisc_destroy(q->qdisc);
 }
 
@@ -352,9 +397,9 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 
 	opt.limit = q->limit;
-	opt.rate = q->R_tab->rate;
-	if (q->P_tab)
-		opt.peakrate = q->P_tab->rate;
+	opt.rate.rate = q->rate.rate_bps >> 3;
+	if (q->peek_present)
+		opt.peakrate.rate = q->peek.rate_bps >> 3;
 	else
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	opt.mtu = q->mtu;
-- 
1.8.1.2
