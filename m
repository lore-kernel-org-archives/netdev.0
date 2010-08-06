From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] netem - revised correlated loss generator
Date: Fri, 06 Aug 2010 12:35:56 -0700
Message-ID: <20100806193559.194819274@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35718 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761957Ab0HFTiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:04 -0400
Content-Disposition: inline; filename=netem-clg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 8/9] netem: correlated loss genartor

This is a patch originated with Stefano Salsano and Fabio Ludovici.
It provides several alternative loss models for use with netem.
This patch adds two state machine based loss models.

To simplify the original code:
   * elminated the debugging messages and statistics
   * reformatted for clarity
   * changed API to nested attribute relating to loss
   * changed the table to always loop across bits
   * only allocate parameters needed

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/pkt_sched.h |   25 ++++
 net/sched/sch_netem.c     |  262 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 284 insertions(+), 3 deletions(-)

--- a/net/sched/sch_netem.c	2010-08-02 15:03:03.814479429 -0700
+++ b/net/sched/sch_netem.c	2010-08-02 15:03:04.746482821 -0700
@@ -47,6 +47,20 @@
 	 layering other disciplines.  It does not need to do bandwidth
 	 control either since that can be handled by using token
 	 bucket or other rate control.
+
+     Correlated Loss Generator models
+
+	Added generation of correlated loss according to the
+	"Gilbert-Elliot" model, a 4-state markov model.
+
+	References:
+	[1] NetemCLG Home http://netgroup.uniroma2.it/NetemCLG
+	[2] S. Salsano, F. Ludovici, A. Ordine, "Definition of a general
+	and intuitive loss model for packet networks and its implementation
+	in the Netem module in the Linux kernel", available in [1]
+
+	Authors: Stefano Salsano <stefano.salsano at uniroma2.it
+		 Fabio Ludovici <fabio.ludovici at yahoo.it>
 */
 
 struct netem_sched_data {
@@ -73,6 +87,26 @@ struct netem_sched_data {
 		u32  size;
 		s16 table[0];
 	} *delay_dist;
+
+	enum  {
+		CLG_RANDOM,
+		CLG_4_STATES,
+		CLG_GILB_ELL,
+	} loss_model;
+
+	/* Correlated Loss Generation models */
+	struct clgstate {
+		/* state of the Markov chain */
+		u8 state;
+
+		/* 4-states and Gilbert-Elliot models */
+		u32 a1;	/* p13 for 4-states or p for GE */
+		u32 a2;	/* p31 for 4-states or r for GE */
+		u32 a3;	/* p32 for 4-states or h for GE */
+		u32 a4;	/* p14 for 4-states or 1-k for GE */
+		u32 a5; /* p23 used only in 4-states */
+	} clg;
+
 };
 
 /* Time stamp put into socket buffer control block */
@@ -119,6 +153,122 @@ static u32 get_crandom(struct crndstate 
 	return answer;
 }
 
+/* loss_4state - 4-state model loss generator
+ * Generates losses according to the 4-state Markov chain adopted in
+ * the GI (General and Intuitive) loss model.
+ */
+static bool loss_4state(struct netem_sched_data *q)
+{
+	struct clgstate *clg = &q->clg;
+	u32 rnd = net_random();
+
+	/*
+	 * Makes a comparision between rnd and the transition
+	 * probabilities outgoing from the current state, then decides the
+	 * next state and if the next packet has to be transmitted or lost.
+	 * The four states correspond to:
+	 *   1 => successfully transmitted packets within a gap period
+	 *   4 => isolated losses within a gap period
+	 *   3 => lost packets within a burst period
+	 *   2 => successfully transmitted packets within a burst period
+	 */
+	switch (clg->state) {
+	case 1:
+		if (rnd < clg->a4) {
+			clg->state = 4;
+			return true;
+		} else if (clg->a4 < rnd && rnd < clg->a1) {
+			clg->state = 3;
+			return true;
+		} else if (clg->a1 < rnd)
+			clg->state = 1;
+
+		break;
+	case 2:
+		if (rnd < clg->a5) {
+			clg->state = 3;
+			return true;
+		} else
+			clg->state = 2;
+
+		break;
+	case 3:
+		if (rnd < clg->a3)
+			clg->state = 2;
+		else if (clg->a3 < rnd && rnd < clg->a2 + clg->a3) {
+			clg->state = 1;
+			return true;
+		} else if (clg->a2 + clg->a3 < rnd) {
+			clg->state = 3;
+			return true;
+		}
+		break;
+	case 4:
+		clg->state = 1;
+		break;
+	}
+
+	return false;
+}
+
+/* loss_gilb_ell - Gilbert-Elliot model loss generator
+ * Generates losses according to the Gilbert-Elliot loss model or
+ * its special cases  (Gilbert or Simple Gilbert)
+ *
+ * Makes a comparision between random number and the transition
+ * probabilities outgoing from the current state, then decides the
+ * next state. A second random number is extracted and the comparision
+ * with the loss probability of the current state decides if the next
+ * packet will be transmitted or lost.
+ */
+static bool loss_gilb_ell(struct netem_sched_data *q)
+{
+	struct clgstate *clg = &q->clg;
+
+	switch (clg->state) {
+	case 1:
+		if (net_random() < clg->a1)
+			clg->state = 2;
+		if (net_random() < clg->a4)
+			return true;
+	case 2:
+		if (net_random() < clg->a2)
+			clg->state = 1;
+		if (clg->a3 > net_random())
+			return true;
+	}
+
+	return false;
+}
+
+static bool loss_event(struct netem_sched_data *q)
+{
+	switch (q->loss_model) {
+	case CLG_RANDOM:
+		/* Random packet drop 0 => none, ~0 => all */
+		return q->loss && q->loss >= get_crandom(&q->loss_cor);
+
+	case CLG_4_STATES:
+		/* 4state loss model algorithm (used also for GI model)
+		* Extracts a value from the markov 4 state loss generator,
+		* if it is 1 drops a packet and if needed writes the event in
+		* the kernel logs
+		*/
+		return loss_4state(q);
+
+	case CLG_GILB_ELL:
+		/* Gilbert-Elliot loss model algorithm
+		* Extracts a value from the Gilbert-Elliot loss generator,
+		* if it is 1 drops a packet and if needed writes the event in
+		* the kernel logs
+		*/
+		return loss_gilb_ell(q);
+	}
+
+	return false;	/* not reached */
+}
+
+
 /* tabledist - return a pseudo-randomly distributed value with mean mu and
  * std deviation sigma.  Uses table lookup to approximate the desired
  * distribution, and a uniformly-distributed pseudo-random source.
@@ -171,8 +321,8 @@ static int netem_enqueue(struct sk_buff 
 	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
 		++count;
 
-	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
+	/* Drop packet? */
+	if (loss_event(q))
 		--count;
 
 	if (count == 0) {
@@ -370,10 +520,62 @@ static void get_corrupt(struct Qdisc *sc
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
+static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct nlattr *la;
+	int rem;
+
+	nla_for_each_nested(la, attr, rem) {
+		switch(nla_type(la)) {
+		case NETEM_LOSS_GI: {
+			const struct tc_netem_gimodel *gi = nla_data(la);
+
+			if (nla_len(la) != sizeof(struct tc_netem_gimodel)) {
+				pr_info("netem: incorrect gi model size\n");
+				return -EINVAL;
+			}
+
+			q->loss_model = CLG_4_STATES;
+
+			q->clg.state = 1;
+			q->clg.a1 = gi->p13;
+			q->clg.a2 = gi->p31;
+			q->clg.a3 = gi->p32;
+			q->clg.a4 = gi->p14;
+			q->clg.a5 = gi->p23;
+			break;
+		}
+		case NETEM_LOSS_GE: {
+			const struct tc_netem_gemodel *ge = nla_data(la);
+
+			if (nla_len(la) != sizeof(struct tc_netem_gemodel)) {
+				pr_info("netem: incorrect gi model size\n");
+				return -EINVAL;
+			}
+
+			q->loss_model = CLG_GILB_ELL;
+			q->clg.state = 1;
+			q->clg.a1 = ge->p;
+			q->clg.a2 = ge->r;
+			q->clg.a3 = ge->h;
+			q->clg.a4 = ge->k1;
+			break;
+		}
+		default:
+			pr_info("netem: unknown loss element %d\n",
+				nla_type(la));
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
 static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
 	[TCA_NETEM_CORR]	= { .len = sizeof(struct tc_netem_corr) },
 	[TCA_NETEM_REORDER]	= { .len = sizeof(struct tc_netem_reorder) },
 	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
+	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
 };
 
 static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
@@ -441,10 +643,14 @@ static int netem_change(struct Qdisc *sc
 
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
+
+	q->loss_model = CLG_RANDOM;
+	if (tb[TCA_NETEM_LOSS])
+		ret = get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
  out:
 	sch_tree_unlock(sch);
 
-	return 0;
+	return ret;
 }
 
 /*
@@ -542,6 +748,7 @@ static int netem_init(struct Qdisc *sch,
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
+	q->loss_model = CLG_RANDOM;
 	q->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				     ops, TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
@@ -566,6 +773,52 @@ static void netem_destroy(struct Qdisc *
 	vfree(q->delay_dist);
 }
 
+static int dump_loss_model(const struct netem_sched_data *q, struct sk_buff *skb)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, NETEM_LOSS_MAX);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	switch (q->loss_model) {
+	case CLG_RANDOM:
+		nla_nest_cancel(skb, nest);
+		return 0;	/* no data */
+
+	case CLG_4_STATES: {
+		struct tc_netem_gimodel gi = {
+			.p13 = q->clg.a1,
+			.p31 = q->clg.a2,
+			.p32 = q->clg.a3,
+			.p14 = q->clg.a4,
+			.p23 = q->clg.a5,
+		};
+
+		NLA_PUT(skb, NETEM_LOSS_GI, sizeof(gi), &gi);
+		break;
+	}
+	case CLG_GILB_ELL: {
+		struct tc_netem_gemodel ge = {
+			.p = q->clg.a1,
+			.r = q->clg.a2,
+			.h = q->clg.a3,
+			.k1 = q->clg.a4,
+		};
+
+		NLA_PUT(skb, NETEM_LOSS_GE, sizeof(ge), &ge);
+		break;
+	}
+	}
+
+	nla_nest_end(skb, nest);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	const struct netem_sched_data *q = qdisc_priv(sch);
@@ -603,6 +856,9 @@ static int netem_dump(struct Qdisc *sch,
 			d->size * sizeof(__s16), d->table);
 	}
 
+	if (dump_loss_model(q, skb) != 0)
+		goto nla_put_failure;
+
 	return nla_nest_end(skb, nla);
 
 nla_put_failure:
--- a/include/linux/pkt_sched.h	2010-08-02 15:03:03.038476487 -0700
+++ b/include/linux/pkt_sched.h	2010-08-02 15:03:04.746482821 -0700
@@ -435,6 +435,7 @@ enum {
 	TCA_NETEM_DELAY_DIST,
 	TCA_NETEM_REORDER,
 	TCA_NETEM_CORRUPT,
+	TCA_NETEM_LOSS,
 	__TCA_NETEM_MAX,
 };
 
@@ -465,6 +466,30 @@ struct tc_netem_corrupt {
 	__u32	correlation;
 };
 
+enum {
+	NETEM_LOSS_GI,		/* General Intuitive - 4 state model */
+	NETEM_LOSS_GE,		/* Gilbert Elliot models */
+	__NETEM_LOSS_MAX
+};
+#define NETEM_LOSS_MAX (__NETEM_LOSS_MAX - 1)
+
+/* State transition probablities for 4 state model */
+struct tc_netem_gimodel {
+	__u32	p13;
+	__u32	p31;
+	__u32	p32;
+	__u32	p14;
+	__u32	p23;
+};
+
+/* Gilbert-Elliot models */
+struct tc_netem_gemodel {
+	__u32 p;
+	__u32 r;
+	__u32 h;
+	__u32 k1;
+};
+
 #define NETEM_DIST_SCALE	8192
 #define NETEM_DIST_MAX		16384
 


