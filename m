From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: red: split red_parms into parms and vars
Date: Thu, 05 Jan 2012 13:25:16 +0100
Message-ID: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60743 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755141Ab2AEMZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 07:25:22 -0500
Received: by lahd3 with SMTP id d3so146563lah.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 04:25:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the red_parms structure into two components.

One holding the RED 'constant' parameters, and one containing the
variables.

This permits a size reduction of GRED qdisc, and is a preliminary step
to add an optional RED unit to SFQ. 

SFQRED will have a single red_parms structure shared by all flows, and a
private red_vars per flow.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Dave Taht <dave.taht@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 include/net/red.h     |   98 ++++++++++++++++++++++------------------
 net/sched/sch_choke.c |   40 ++++++++--------
 net/sched/sch_gred.c  |   45 +++++++++---------
 net/sched/sch_red.c   |   29 ++++++-----
 4 files changed, 117 insertions(+), 95 deletions(-)

diff --git a/include/net/red.h b/include/net/red.h
index ef715a1..baab385 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -137,7 +137,9 @@ struct red_parms {
 	u8		Wlog;		/* log(W)		*/
 	u8		Plog;		/* random number bits	*/
 	u8		Stab[RED_STAB_SIZE];
+};
 
+struct red_vars {
 	/* Variables */
 	int		qcount;		/* Number of packets since last random
 					   number generation */
@@ -152,6 +154,16 @@ static inline u32 red_maxp(u8 Plog)
 	return Plog < 32 ? (~0U >> Plog) : ~0U;
 }
 
+static inline void red_set_vars(struct red_vars *v)
+{
+	/* Reset average queue length, the value is strictly bound
+	 * to the parameters below, reseting hurts a bit but leaving
+	 * it might result in an unreasonable qavg for a while. --TGR
+	 */
+	v->qavg		= 0;
+
+	v->qcount	= -1;
+}
 
 static inline void red_set_parms(struct red_parms *p,
 				 u32 qth_min, u32 qth_max, u8 Wlog, u8 Plog,
@@ -160,13 +172,6 @@ static inline void red_set_parms(struct red_parms *p,
 	int delta = qth_max - qth_min;
 	u32 max_p_delta;
 
-	/* Reset average queue length, the value is strictly bound
-	 * to the parameters below, reseting hurts a bit but leaving
-	 * it might result in an unreasonable qavg for a while. --TGR
-	 */
-	p->qavg		= 0;
-
-	p->qcount	= -1;
 	p->qth_min	= qth_min << Wlog;
 	p->qth_max	= qth_max << Wlog;
 	p->Wlog		= Wlog;
@@ -197,31 +202,32 @@ static inline void red_set_parms(struct red_parms *p,
 	memcpy(p->Stab, stab, sizeof(p->Stab));
 }
 
-static inline int red_is_idling(const struct red_parms *p)
+static inline int red_is_idling(const struct red_vars *v)
 {
-	return p->qidlestart.tv64 != 0;
+	return v->qidlestart.tv64 != 0;
 }
 
-static inline void red_start_of_idle_period(struct red_parms *p)
+static inline void red_start_of_idle_period(struct red_vars *v)
 {
-	p->qidlestart = ktime_get();
+	v->qidlestart = ktime_get();
 }
 
-static inline void red_end_of_idle_period(struct red_parms *p)
+static inline void red_end_of_idle_period(struct red_vars *v)
 {
-	p->qidlestart.tv64 = 0;
+	v->qidlestart.tv64 = 0;
 }
 
-static inline void red_restart(struct red_parms *p)
+static inline void red_restart(struct red_vars *v)
 {
-	red_end_of_idle_period(p);
-	p->qavg = 0;
-	p->qcount = -1;
+	red_end_of_idle_period(v);
+	v->qavg = 0;
+	v->qcount = -1;
 }
 
-static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms *p)
+static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms *p,
+							 const struct red_vars *v)
 {
-	s64 delta = ktime_us_delta(ktime_get(), p->qidlestart);
+	s64 delta = ktime_us_delta(ktime_get(), v->qidlestart);
 	long us_idle = min_t(s64, delta, p->Scell_max);
 	int  shift;
 
@@ -248,7 +254,7 @@ static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms
 	shift = p->Stab[(us_idle >> p->Scell_log) & RED_STAB_MASK];
 
 	if (shift)
-		return p->qavg >> shift;
+		return v->qavg >> shift;
 	else {
 		/* Approximate initial part of exponent with linear function:
 		 *
@@ -257,16 +263,17 @@ static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms
 		 * Seems, it is the best solution to
 		 * problem of too coarse exponent tabulation.
 		 */
-		us_idle = (p->qavg * (u64)us_idle) >> p->Scell_log;
+		us_idle = (v->qavg * (u64)us_idle) >> p->Scell_log;
 
-		if (us_idle < (p->qavg >> 1))
-			return p->qavg - us_idle;
+		if (us_idle < (v->qavg >> 1))
+			return v->qavg - us_idle;
 		else
-			return p->qavg >> 1;
+			return v->qavg >> 1;
 	}
 }
 
 static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p,
+						       const struct red_vars *v,
 						       unsigned int backlog)
 {
 	/*
@@ -278,16 +285,17 @@ static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p
 	 *
 	 * --ANK (980924)
 	 */
-	return p->qavg + (backlog - (p->qavg >> p->Wlog));
+	return v->qavg + (backlog - (v->qavg >> p->Wlog));
 }
 
 static inline unsigned long red_calc_qavg(const struct red_parms *p,
+					  const struct red_vars *v,
 					  unsigned int backlog)
 {
-	if (!red_is_idling(p))
-		return red_calc_qavg_no_idle_time(p, backlog);
+	if (!red_is_idling(v))
+		return red_calc_qavg_no_idle_time(p, v, backlog);
 	else
-		return red_calc_qavg_from_idle_time(p);
+		return red_calc_qavg_from_idle_time(p, v);
 }
 
 
@@ -296,7 +304,9 @@ static inline u32 red_random(const struct red_parms *p)
 	return reciprocal_divide(net_random(), p->max_P_reciprocal);
 }
 
-static inline int red_mark_probability(const struct red_parms *p, unsigned long qavg)
+static inline int red_mark_probability(const struct red_parms *p,
+				       const struct red_vars *v,
+				       unsigned long qavg)
 {
 	/* The formula used below causes questions.
 
@@ -314,7 +324,7 @@ static inline int red_mark_probability(const struct red_parms *p, unsigned long
 
 	   Any questions? --ANK (980924)
 	 */
-	return !(((qavg - p->qth_min) >> p->Wlog) * p->qcount < p->qR);
+	return !(((qavg - p->qth_min) >> p->Wlog) * v->qcount < v->qR);
 }
 
 enum {
@@ -323,7 +333,7 @@ enum {
 	RED_ABOVE_MAX_TRESH,
 };
 
-static inline int red_cmp_thresh(struct red_parms *p, unsigned long qavg)
+static inline int red_cmp_thresh(const struct red_parms *p, unsigned long qavg)
 {
 	if (qavg < p->qth_min)
 		return RED_BELOW_MIN_THRESH;
@@ -339,27 +349,29 @@ enum {
 	RED_HARD_MARK,
 };
 
-static inline int red_action(struct red_parms *p, unsigned long qavg)
+static inline int red_action(const struct red_parms *p,
+			     struct red_vars *v,
+			     unsigned long qavg)
 {
 	switch (red_cmp_thresh(p, qavg)) {
 		case RED_BELOW_MIN_THRESH:
-			p->qcount = -1;
+			v->qcount = -1;
 			return RED_DONT_MARK;
 
 		case RED_BETWEEN_TRESH:
-			if (++p->qcount) {
-				if (red_mark_probability(p, qavg)) {
-					p->qcount = 0;
-					p->qR = red_random(p);
+			if (++v->qcount) {
+				if (red_mark_probability(p, v, qavg)) {
+					v->qcount = 0;
+					v->qR = red_random(p);
 					return RED_PROB_MARK;
 				}
 			} else
-				p->qR = red_random(p);
+				v->qR = red_random(p);
 
 			return RED_DONT_MARK;
 
 		case RED_ABOVE_MAX_TRESH:
-			p->qcount = -1;
+			v->qcount = -1;
 			return RED_HARD_MARK;
 	}
 
@@ -367,14 +379,14 @@ static inline int red_action(struct red_parms *p, unsigned long qavg)
 	return RED_DONT_MARK;
 }
 
-static inline void red_adaptative_algo(struct red_parms *p)
+static inline void red_adaptative_algo(struct red_parms *p, struct red_vars *v)
 {
 	unsigned long qavg;
 	u32 max_p_delta;
 
-	qavg = p->qavg;
-	if (red_is_idling(p))
-		qavg = red_calc_qavg_from_idle_time(p);
+	qavg = v->qavg;
+	if (red_is_idling(v))
+		qavg = red_calc_qavg_from_idle_time(p, v);
 
 	/* p->qavg is fixed point number with point at Wlog */
 	qavg >>= p->Wlog;
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index bef00ac..e465064 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -57,6 +57,7 @@ struct choke_sched_data {
 	struct red_parms parms;
 
 /* Variables */
+	struct red_vars  vars;
 	struct tcf_proto *filter_list;
 	struct {
 		u32	prob_drop;	/* Early probability drops */
@@ -265,7 +266,7 @@ static bool choke_match_random(const struct choke_sched_data *q,
 static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
-	struct red_parms *p = &q->parms;
+	const struct red_parms *p = &q->parms;
 	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 
 	if (q->filter_list) {
@@ -276,13 +277,13 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	choke_skb_cb(skb)->keys_valid = 0;
 	/* Compute average queue usage (see RED) */
-	p->qavg = red_calc_qavg(p, sch->q.qlen);
-	if (red_is_idling(p))
-		red_end_of_idle_period(p);
+	q->vars.qavg = red_calc_qavg(p, &q->vars, sch->q.qlen);
+	if (red_is_idling(&q->vars))
+		red_end_of_idle_period(&q->vars);
 
 	/* Is queue small? */
-	if (p->qavg <= p->qth_min)
-		p->qcount = -1;
+	if (q->vars.qavg <= p->qth_min)
+		q->vars.qcount = -1;
 	else {
 		unsigned int idx;
 
@@ -294,8 +295,8 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		}
 
 		/* Queue is large, always mark/drop */
-		if (p->qavg > p->qth_max) {
-			p->qcount = -1;
+		if (q->vars.qavg > p->qth_max) {
+			q->vars.qcount = -1;
 
 			sch->qstats.overlimits++;
 			if (use_harddrop(q) || !use_ecn(q) ||
@@ -305,10 +306,10 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			}
 
 			q->stats.forced_mark++;
-		} else if (++p->qcount) {
-			if (red_mark_probability(p, p->qavg)) {
-				p->qcount = 0;
-				p->qR = red_random(p);
+		} else if (++q->vars.qcount) {
+			if (red_mark_probability(p, &q->vars, q->vars.qavg)) {
+				q->vars.qcount = 0;
+				q->vars.qR = red_random(p);
 
 				sch->qstats.overlimits++;
 				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
@@ -319,7 +320,7 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				q->stats.prob_mark++;
 			}
 		} else
-			p->qR = red_random(p);
+			q->vars.qR = red_random(p);
 	}
 
 	/* Admit new packet */
@@ -353,8 +354,8 @@ static struct sk_buff *choke_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 
 	if (q->head == q->tail) {
-		if (!red_is_idling(&q->parms))
-			red_start_of_idle_period(&q->parms);
+		if (!red_is_idling(&q->vars))
+			red_start_of_idle_period(&q->vars);
 		return NULL;
 	}
 
@@ -377,8 +378,8 @@ static unsigned int choke_drop(struct Qdisc *sch)
 	if (len > 0)
 		q->stats.other++;
 	else {
-		if (!red_is_idling(&q->parms))
-			red_start_of_idle_period(&q->parms);
+		if (!red_is_idling(&q->vars))
+			red_start_of_idle_period(&q->vars);
 	}
 
 	return len;
@@ -388,7 +389,7 @@ static void choke_reset(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 
-	red_restart(&q->parms);
+	red_restart(&q->vars);
 }
 
 static const struct nla_policy choke_policy[TCA_CHOKE_MAX + 1] = {
@@ -482,9 +483,10 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 		      ctl->Plog, ctl->Scell_log,
 		      nla_data(tb[TCA_CHOKE_STAB]),
 		      max_P);
+	red_set_vars(&q->vars);
 
 	if (q->head == q->tail)
-		red_end_of_idle_period(&q->parms);
+		red_end_of_idle_period(&q->vars);
 
 	sch_tree_unlock(sch);
 	choke_free(old);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 53204de..0b15236 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -41,6 +41,7 @@ struct gred_sched_data {
 	u8		prio;		/* the prio of this vq */
 
 	struct red_parms parms;
+	struct red_vars  vars;
 	struct red_stats stats;
 };
 
@@ -55,7 +56,7 @@ struct gred_sched {
 	u32		red_flags;
 	u32 		DPs;
 	u32 		def;
-	struct red_parms wred_set;
+	struct red_vars wred_set;
 };
 
 static inline int gred_wred_mode(struct gred_sched *table)
@@ -125,17 +126,17 @@ static inline u16 tc_index_to_dp(struct sk_buff *skb)
 	return skb->tc_index & GRED_VQ_MASK;
 }
 
-static inline void gred_load_wred_set(struct gred_sched *table,
+static inline void gred_load_wred_set(const struct gred_sched *table,
 				      struct gred_sched_data *q)
 {
-	q->parms.qavg = table->wred_set.qavg;
-	q->parms.qidlestart = table->wred_set.qidlestart;
+	q->vars.qavg = table->wred_set.qavg;
+	q->vars.qidlestart = table->wred_set.qidlestart;
 }
 
 static inline void gred_store_wred_set(struct gred_sched *table,
 				       struct gred_sched_data *q)
 {
-	table->wred_set.qavg = q->parms.qavg;
+	table->wred_set.qavg = q->vars.qavg;
 }
 
 static inline int gred_use_ecn(struct gred_sched *t)
@@ -170,7 +171,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				goto drop;
 		}
 
-		/* fix tc_index? --could be controvesial but needed for
+		/* fix tc_index? --could be controversial but needed for
 		   requeueing */
 		skb->tc_index = (skb->tc_index & ~GRED_VQ_MASK) | dp;
 	}
@@ -181,8 +182,8 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 		for (i = 0; i < t->DPs; i++) {
 			if (t->tab[i] && t->tab[i]->prio < q->prio &&
-			    !red_is_idling(&t->tab[i]->parms))
-				qavg += t->tab[i]->parms.qavg;
+			    !red_is_idling(&t->tab[i]->vars))
+				qavg += t->tab[i]->vars.qavg;
 		}
 
 	}
@@ -193,15 +194,17 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (gred_wred_mode(t))
 		gred_load_wred_set(t, q);
 
-	q->parms.qavg = red_calc_qavg(&q->parms, gred_backlog(t, q, sch));
+	q->vars.qavg = red_calc_qavg(&q->parms,
+				     &q->vars,
+				     gred_backlog(t, q, sch));
 
-	if (red_is_idling(&q->parms))
-		red_end_of_idle_period(&q->parms);
+	if (red_is_idling(&q->vars))
+		red_end_of_idle_period(&q->vars);
 
 	if (gred_wred_mode(t))
 		gred_store_wred_set(t, q);
 
-	switch (red_action(&q->parms, q->parms.qavg + qavg)) {
+	switch (red_action(&q->parms, &q->vars, q->vars.qavg + qavg)) {
 	case RED_DONT_MARK:
 		break;
 
@@ -260,7 +263,7 @@ static struct sk_buff *gred_dequeue(struct Qdisc *sch)
 			q->backlog -= qdisc_pkt_len(skb);
 
 			if (!q->backlog && !gred_wred_mode(t))
-				red_start_of_idle_period(&q->parms);
+				red_start_of_idle_period(&q->vars);
 		}
 
 		return skb;
@@ -293,7 +296,7 @@ static unsigned int gred_drop(struct Qdisc *sch)
 			q->stats.other++;
 
 			if (!q->backlog && !gred_wred_mode(t))
-				red_start_of_idle_period(&q->parms);
+				red_start_of_idle_period(&q->vars);
 		}
 
 		qdisc_drop(skb, sch);
@@ -320,7 +323,7 @@ static void gred_reset(struct Qdisc *sch)
 		if (!q)
 			continue;
 
-		red_restart(&q->parms);
+		red_restart(&q->vars);
 		q->backlog = 0;
 	}
 }
@@ -398,12 +401,12 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 	q->limit = ctl->limit;
 
 	if (q->backlog == 0)
-		red_end_of_idle_period(&q->parms);
+		red_end_of_idle_period(&q->vars);
 
 	red_set_parms(&q->parms,
 		      ctl->qth_min, ctl->qth_max, ctl->Wlog, ctl->Plog,
 		      ctl->Scell_log, stab, max_P);
-
+	red_set_vars(&q->vars);
 	return 0;
 }
 
@@ -563,12 +566,12 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 		opt.bytesin	= q->bytesin;
 
 		if (gred_wred_mode(table)) {
-			q->parms.qidlestart =
-				table->tab[table->def]->parms.qidlestart;
-			q->parms.qavg = table->tab[table->def]->parms.qavg;
+			q->vars.qidlestart =
+				table->tab[table->def]->vars.qidlestart;
+			q->vars.qavg = table->tab[table->def]->vars.qavg;
 		}
 
-		opt.qave = red_calc_qavg(&q->parms, q->parms.qavg);
+		opt.qave = red_calc_qavg(&q->parms, &q->vars, q->vars.qavg);
 
 append_opt:
 		if (nla_append(skb, sizeof(opt), &opt) < 0)
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index ce2256a..a5cc301 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -41,6 +41,7 @@ struct red_sched_data {
 	unsigned char		flags;
 	struct timer_list	adapt_timer;
 	struct red_parms	parms;
+	struct red_vars		vars;
 	struct red_stats	stats;
 	struct Qdisc		*qdisc;
 };
@@ -61,12 +62,14 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct Qdisc *child = q->qdisc;
 	int ret;
 
-	q->parms.qavg = red_calc_qavg(&q->parms, child->qstats.backlog);
+	q->vars.qavg = red_calc_qavg(&q->parms,
+				     &q->vars,
+				     child->qstats.backlog);
 
-	if (red_is_idling(&q->parms))
-		red_end_of_idle_period(&q->parms);
+	if (red_is_idling(&q->vars))
+		red_end_of_idle_period(&q->vars);
 
-	switch (red_action(&q->parms, q->parms.qavg)) {
+	switch (red_action(&q->parms, &q->vars, q->vars.qavg)) {
 	case RED_DONT_MARK:
 		break;
 
@@ -117,8 +120,8 @@ static struct sk_buff *red_dequeue(struct Qdisc *sch)
 		qdisc_bstats_update(sch, skb);
 		sch->q.qlen--;
 	} else {
-		if (!red_is_idling(&q->parms))
-			red_start_of_idle_period(&q->parms);
+		if (!red_is_idling(&q->vars))
+			red_start_of_idle_period(&q->vars);
 	}
 	return skb;
 }
@@ -144,8 +147,8 @@ static unsigned int red_drop(struct Qdisc *sch)
 		return len;
 	}
 
-	if (!red_is_idling(&q->parms))
-		red_start_of_idle_period(&q->parms);
+	if (!red_is_idling(&q->vars))
+		red_start_of_idle_period(&q->vars);
 
 	return 0;
 }
@@ -156,7 +159,7 @@ static void red_reset(struct Qdisc *sch)
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	red_restart(&q->parms);
+	red_restart(&q->vars);
 }
 
 static void red_destroy(struct Qdisc *sch)
@@ -212,17 +215,19 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 		q->qdisc = child;
 	}
 
-	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+	red_set_parms(&q->parms,
+		      ctl->qth_min, ctl->qth_max, ctl->Wlog,
 		      ctl->Plog, ctl->Scell_log,
 		      nla_data(tb[TCA_RED_STAB]),
 		      max_P);
+	red_set_vars(&q->vars);
 
 	del_timer(&q->adapt_timer);
 	if (ctl->flags & TC_RED_ADAPTATIVE)
 		mod_timer(&q->adapt_timer, jiffies + HZ/2);
 
 	if (!q->qdisc->q.qlen)
-		red_start_of_idle_period(&q->parms);
+		red_start_of_idle_period(&q->vars);
 
 	sch_tree_unlock(sch);
 	return 0;
@@ -235,7 +240,7 @@ static inline void red_adaptative_timer(unsigned long arg)
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
-	red_adaptative_algo(&q->parms);
+	red_adaptative_algo(&q->parms, &q->vars);
 	mod_timer(&q->adapt_timer, jiffies + HZ/2);
 	spin_unlock(root_lock);
 }
