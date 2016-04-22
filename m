From: Michal Kazior <michal.kazior@tieto.com>
Subject: [PATCH 1/2] codel: generalize the implementation
Date: Fri, 22 Apr 2016 14:15:58 +0200
Message-ID: <1461327359-21646-2-git-send-email-michal.kazior@tieto.com>
References: <1461327359-21646-1-git-send-email-michal.kazior@tieto.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	Michal Kazior <michal.kazior@tieto.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35034 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbcDVMOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 08:14:12 -0400
Received: by mail-lb0-f173.google.com with SMTP id os9so42871255lbb.2
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 05:14:11 -0700 (PDT)
In-Reply-To: <1461327359-21646-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This strips out qdisc specific bits from the code
and makes it slightly more reusable. Codel will be
used by wireless/mac80211 in the future.

Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---
 include/net/codel.h      | 64 +++++++++++++++++++++++++++++-------------------
 net/sched/sch_codel.c    | 20 ++++++++++++---
 net/sched/sch_fq_codel.c | 19 +++++++++++---
 3 files changed, 71 insertions(+), 32 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index d168aca115cc..06ac687b4909 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -176,12 +176,10 @@ struct codel_stats {
 
 #define CODEL_DISABLED_THRESHOLD INT_MAX
 
-static void codel_params_init(struct codel_params *params,
-			      const struct Qdisc *sch)
+static void codel_params_init(struct codel_params *params)
 {
 	params->interval = MS2TIME(100);
 	params->target = MS2TIME(5);
-	params->mtu = psched_mtu(qdisc_dev(sch));
 	params->ce_threshold = CODEL_DISABLED_THRESHOLD;
 	params->ecn = false;
 }
@@ -226,28 +224,38 @@ static codel_time_t codel_control_law(codel_time_t t,
 	return t + reciprocal_scale(interval, rec_inv_sqrt << REC_INV_SQRT_SHIFT);
 }
 
+typedef u32 (*codel_skb_len_t)(const struct sk_buff *skb);
+typedef codel_time_t (*codel_skb_time_t)(const struct sk_buff *skb);
+typedef void (*codel_skb_drop_t)(struct sk_buff *skb, void *ctx);
+typedef struct sk_buff * (*codel_skb_dequeue_t)(struct codel_vars *vars,
+						void *ctx);
+
 static bool codel_should_drop(const struct sk_buff *skb,
-			      struct Qdisc *sch,
+			      void *ctx,
 			      struct codel_vars *vars,
 			      struct codel_params *params,
 			      struct codel_stats *stats,
+			      codel_skb_len_t skb_len_func,
+			      codel_skb_time_t skb_time_func,
+			      u32 *backlog,
 			      codel_time_t now)
 {
 	bool ok_to_drop;
+	u32 skb_len;
 
 	if (!skb) {
 		vars->first_above_time = 0;
 		return false;
 	}
 
-	vars->ldelay = now - codel_get_enqueue_time(skb);
-	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	skb_len = skb_len_func(skb);
+	vars->ldelay = now - skb_time_func(skb);
 
-	if (unlikely(qdisc_pkt_len(skb) > stats->maxpacket))
-		stats->maxpacket = qdisc_pkt_len(skb);
+	if (unlikely(skb_len > stats->maxpacket))
+		stats->maxpacket = skb_len;
 
 	if (codel_time_before(vars->ldelay, params->target) ||
-	    sch->qstats.backlog <= params->mtu) {
+	    *backlog <= params->mtu) {
 		/* went below - stay below for at least interval */
 		vars->first_above_time = 0;
 		return false;
@@ -264,16 +272,17 @@ static bool codel_should_drop(const struct sk_buff *skb,
 	return ok_to_drop;
 }
 
-typedef struct sk_buff * (*codel_skb_dequeue_t)(struct codel_vars *vars,
-						struct Qdisc *sch);
-
-static struct sk_buff *codel_dequeue(struct Qdisc *sch,
+static struct sk_buff *codel_dequeue(void *ctx,
+				     u32 *backlog,
 				     struct codel_params *params,
 				     struct codel_vars *vars,
 				     struct codel_stats *stats,
+				     codel_skb_len_t skb_len_func,
+				     codel_skb_time_t skb_time_func,
+				     codel_skb_drop_t drop_func,
 				     codel_skb_dequeue_t dequeue_func)
 {
-	struct sk_buff *skb = dequeue_func(vars, sch);
+	struct sk_buff *skb = dequeue_func(vars, ctx);
 	codel_time_t now;
 	bool drop;
 
@@ -282,7 +291,8 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 		return skb;
 	}
 	now = codel_get_time();
-	drop = codel_should_drop(skb, sch, vars, params, stats, now);
+	drop = codel_should_drop(skb, ctx, vars, params, stats,
+				 skb_len_func, skb_time_func, backlog, now);
 	if (vars->dropping) {
 		if (!drop) {
 			/* sojourn time below target - leave dropping state */
@@ -310,12 +320,15 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 								  vars->rec_inv_sqrt);
 					goto end;
 				}
-				stats->drop_len += qdisc_pkt_len(skb);
-				qdisc_drop(skb, sch);
+				stats->drop_len += skb_len_func(skb);
+				drop_func(skb, ctx);
 				stats->drop_count++;
-				skb = dequeue_func(vars, sch);
-				if (!codel_should_drop(skb, sch,
-						       vars, params, stats, now)) {
+				skb = dequeue_func(vars, ctx);
+				if (!codel_should_drop(skb, ctx,
+						       vars, params, stats,
+						       skb_len_func,
+						       skb_time_func,
+						       backlog, now)) {
 					/* leave dropping state */
 					vars->dropping = false;
 				} else {
@@ -333,13 +346,14 @@ static struct sk_buff *codel_dequeue(struct Qdisc *sch,
 		if (params->ecn && INET_ECN_set_ce(skb)) {
 			stats->ecn_mark++;
 		} else {
-			stats->drop_len += qdisc_pkt_len(skb);
-			qdisc_drop(skb, sch);
+			stats->drop_len += skb_len_func(skb);
+			drop_func(skb, ctx);
 			stats->drop_count++;
 
-			skb = dequeue_func(vars, sch);
-			drop = codel_should_drop(skb, sch, vars, params,
-						 stats, now);
+			skb = dequeue_func(vars, ctx);
+			drop = codel_should_drop(skb, ctx, vars, params,
+						 stats, skb_len_func,
+						 skb_time_func, backlog, now);
 		}
 		vars->dropping = true;
 		/* if min went above target close to when we last went below it
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index 9b7e2980ee5c..512a94abe351 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -64,20 +64,33 @@ struct codel_sched_data {
  * to dequeue a packet from queue. Note: backlog is handled in
  * codel, we dont need to reduce it here.
  */
-static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *sch)
+static struct sk_buff *dequeue_func(struct codel_vars *vars, void *ctx)
 {
+	struct Qdisc *sch = ctx;
 	struct sk_buff *skb = __skb_dequeue(&sch->q);
 
+	if (skb)
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
+
 	prefetch(&skb->end); /* we'll need skb_shinfo() */
 	return skb;
 }
 
+static void drop_func(struct sk_buff *skb, void *ctx)
+{
+	struct Qdisc *sch = ctx;
+
+	qdisc_drop(skb, sch);
+}
+
 static struct sk_buff *codel_qdisc_dequeue(struct Qdisc *sch)
 {
 	struct codel_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = codel_dequeue(sch, &q->params, &q->vars, &q->stats, dequeue);
+	skb = codel_dequeue(sch, &sch->qstats.backlog, &q->params, &q->vars,
+			    &q->stats, qdisc_pkt_len, codel_get_enqueue_time,
+			    drop_func, dequeue_func);
 
 	/* We cant call qdisc_tree_reduce_backlog() if our qlen is 0,
 	 * or HTB crashes. Defer it for next round.
@@ -173,9 +186,10 @@ static int codel_init(struct Qdisc *sch, struct nlattr *opt)
 
 	sch->limit = DEFAULT_CODEL_LIMIT;
 
-	codel_params_init(&q->params, sch);
+	codel_params_init(&q->params);
 	codel_vars_init(&q->vars);
 	codel_stats_init(&q->stats);
+	q->params.mtu = psched_mtu(qdisc_dev(sch));
 
 	if (opt) {
 		int err = codel_change(sch, opt);
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index d3fc8f9dd3d4..dcf7266e6901 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -220,8 +220,9 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
  * to dequeue a packet from queue. Note: backlog is handled in
  * codel, we dont need to reduce it here.
  */
-static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *sch)
+static struct sk_buff *dequeue_func(struct codel_vars *vars, void *ctx)
 {
+	struct Qdisc *sch = ctx;
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	struct fq_codel_flow *flow;
 	struct sk_buff *skb = NULL;
@@ -231,10 +232,18 @@ static struct sk_buff *dequeue(struct codel_vars *vars, struct Qdisc *sch)
 		skb = dequeue_head(flow);
 		q->backlogs[flow - q->flows] -= qdisc_pkt_len(skb);
 		sch->q.qlen--;
+		sch->qstats.backlog -= qdisc_pkt_len(skb);
 	}
 	return skb;
 }
 
+static void drop_func(struct sk_buff *skb, void *ctx)
+{
+	struct Qdisc *sch = ctx;
+
+	qdisc_drop(skb, sch);
+}
+
 static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
@@ -263,8 +272,9 @@ begin:
 	prev_ecn_mark = q->cstats.ecn_mark;
 	prev_backlog = sch->qstats.backlog;
 
-	skb = codel_dequeue(sch, &q->cparams, &flow->cvars, &q->cstats,
-			    dequeue);
+	skb = codel_dequeue(sch, &sch->qstats.backlog, &q->cparams,
+			    &flow->cvars, &q->cstats, qdisc_pkt_len,
+			    codel_get_enqueue_time, drop_func, dequeue_func);
 
 	flow->dropped += q->cstats.drop_count - prev_drop_count;
 	flow->dropped += q->cstats.ecn_mark - prev_ecn_mark;
@@ -423,9 +433,10 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	q->perturbation = prandom_u32();
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
-	codel_params_init(&q->cparams, sch);
+	codel_params_init(&q->cparams);
 	codel_stats_init(&q->cstats);
 	q->cparams.ecn = true;
+	q->cparams.mtu = psched_mtu(qdisc_dev(sch));
 
 	if (opt) {
 		int err = fq_codel_change(sch, opt);
-- 
2.1.4
