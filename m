From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] netem: correlated loss generation (v3)
Date: Mon, 17 May 2010 20:56:21 -0700
Message-ID: <20100517205621.036a06e0@nehalam>
References: <4BD84428.30904@uniroma2.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Fabio Ludovici <fabio.ludovici@yahoo.it>, netdev@vger.kernel.org,
	netem@lists.linuxfoundation.org
To: Stefano Salsano <stefano.salsano@uniroma2.it>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58478 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab0ERD41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 23:56:27 -0400
In-Reply-To: <4BD84428.30904@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: netem - revised correlated loss generator

This is a patch originated with Stefano Salsano and Fabio Ludovici.
It provides several alternative loss models for use with netem.
There are two state machine based models and one table driven model.

To simplify the original code:
   * eliminated the debugging messages and statistics
   * reformatted for clarity
   * changed API to nested attribute relating to loss
   * changed the table to always loop across bits
   * only allocate parameters needed

Still untested, for comment only...
Should have tested version before 2.6.35 merge window closes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/pkt_sched.h |   26 ++++
 net/sched/sch_netem.c     |  287 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 307 insertions(+), 6 deletions(-)

--- a/net/sched/sch_netem.c	2010-05-17 20:51:43.753304581 -0700
+++ b/net/sched/sch_netem.c	2010-05-17 20:51:46.423325162 -0700
@@ -47,6 +47,21 @@
 	 layering other disciplines.  It does not need to do bandwidth
 	 control either since that can be handled by using token
 	 bucket or other rate control.
+
+     Correlated Loss Generator models
+
+	Added generation of correlated loss according to the
+	"Gilbert-Elliot" model, a 4-state markov model and to a deterministic
+	loss pattern that can be given as input.
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
@@ -64,6 +79,28 @@ struct netem_sched_data {
 	u32 reorder;
 	u32 corrupt;
 
+	enum netem_clg_model loss_model;
+
+	/* data for Correlated Loss Generation models */
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
+	} *clg;
+
+	/* Deterministic loss generator */
+	struct dlgtable {
+		u32 index;	/* current place in sequence */
+		u32 length;	/* length of the sequence (in bits) */
+		unsigned long sequence[0];
+	} *dlg;
+
 	struct crndstate {
 		u32 last;
 		u32 rho;
@@ -115,6 +152,139 @@ static u32 get_crandom(struct crndstate 
 	return answer;
 }
 
+/* get_loss_pattern_element - deterministic loss generator
+ * Extracts an element (1 means loss event, 0 means transmission)
+ * from the current loss pattern.
+ */
+static int get_loss_pattern_element(struct netem_sched_data *q)
+{
+	struct dlgtable *dlg = q->dlg;
+	u32 val = dlg->sequence[BIT_WORD(dlg->index)] & BIT_MASK(dlg->index);
+
+	if (++dlg->index >= dlg->length)
+		dlg->index = 0;
+
+	return val != 0;
+}
+
+/* get_loss_4state_element - 4-state model loss generator
+ * Generates losses according to the 4-state Markov chain adopted in
+ * the GI (General and Intuitive) loss model.
+ * returns 1 the next packet will be lost,
+ *         0 it will be transmitted.
+ */
+static int get_loss_4state_element(struct netem_sched_data *q)
+{
+	struct clgstate *clg = q->clg;
+	u32 rnd = net_random();
+
+	/*
+	 * Makes a comparison between rnd and the transition
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
+			return 1;
+		} else if (clg->a4 < rnd && rnd < clg->a1) {
+			clg->state = 3;
+			return 1;
+		} else if (clg->a1 < rnd)
+			clg->state = 1;
+
+		break;
+	case 2:
+		if (rnd < clg->a5) {
+			clg->state = 3;
+			return 1;
+		} else
+			clg->state = 2;
+
+		break;
+	case 3:
+		if (rnd < clg->a3)
+			clg->state = 2;
+		else if (clg->a3 < rnd && rnd < clg->a2 + clg->a3) {
+			clg->state = 1;
+			return 1;
+		} else if (clg->a2 + clg->a3 < rnd) {
+			clg->state = 3;
+			return 1;
+		}
+		break;
+	case 4:
+		clg->state = 1;
+		break;
+	}
+
+	return 0;
+}
+
+/* get_loss_gilb_ell_element - Gilbert-Elliot model loss generator
+ * Generates losses according to the Gilbert-Elliot loss model or
+ * its special cases  (Gilbert or Simple Gilbert)
+ *
+ * Makes a comparison between random_gilb_ell and the transition
+ * probabilities outgoing from the current state, then decides the
+ * next state. A second random number is extracted and the comparison
+ * with the loss probability of the current state decides if the next
+ * packet will be transmitted or lost.
+ */
+static int get_loss_gilb_ell_element(struct netem_sched_data *q)
+{
+	struct clgstate *clg = q->clg;
+
+	switch (clg->state) {
+	case 1:
+		if (net_random() < clg->a1)
+			clg->state = 2;
+		if (net_random() < clg->a4)
+			return 1;
+	case 2:
+		if (net_random() < clg->a2)
+			clg->state = 1;
+		if (clg->a3 > net_random())
+			return 1;
+	}
+
+	return 0;
+}
+
+static int get_loss_event(struct netem_sched_data *q)
+{
+	switch (q->loss_model) {
+	case CLG_DETERMIN:
+		return get_loss_pattern_element(q);
+
+	case CLG_4_STATES:
+		/* 4state loss model algorithm (used also for GI model)
+		* Extracts a value from the markov 4 state loss generator,
+		* if it is 1 drops a packet and if needed writes the event in
+		* the kernel logs
+		*/
+		return get_loss_4state_element(q);
+
+	case CLG_GILB_ELL:
+		/* Gilbert-Elliot loss model algorithm
+		* Extracts a value from the Gilbert-Elliot loss generator,
+		* if it is 1 drops a packet and if needed writes the event in
+		* the kernel logs
+		*/
+		return get_loss_gilb_ell_element(q);
+
+	default:
+		return 0;
+	}
+}
+
+
 /* tabledist - return a pseudo-randomly distributed value with mean mu and
  * std deviation sigma.  Uses table lookup to approximate the desired
  * distribution, and a uniformly-distributed pseudo-random source.
@@ -171,6 +341,10 @@ static int netem_enqueue(struct sk_buff 
 	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
 		--count;
 
+	/* Deterministic loss pattern algorithm */
+	if (q->loss_model != CLG_NONE && get_loss_event(q))
+		--count;
+
 	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
@@ -370,10 +544,91 @@ static void get_corrupt(struct Qdisc *sc
 	init_crandom(&q->corrupt_cor, r->correlation);
 }
 
+
+static const struct nla_policy netem_loss_nest[NETEM_LOSS_MAX + 1] = {
+	[NETEM_LOSS_MODEL]	= { .type = NLA_U8, },
+	[NETEM_LOSS_STATE]	= { .len = sizeof(struct tc_netem_loss_state) },
+};
+
+static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct nlattr *loss[NETEM_LOSS_MAX + 1];
+	enum netem_clg_model model;
+	int ret;
+
+	ret = nla_parse_nested(loss, NETEM_LOSS_MAX,
+			       attr, netem_loss_nest);
+	if (ret)
+		return ret;
+
+	if (!loss[NETEM_LOSS_MODEL]) {
+		pr_info("netem: missing loss model\n");
+		return -EINVAL;
+	}
+
+	model = nla_get_u8(loss[NETEM_LOSS_MODEL]);
+	switch (model) {
+	case CLG_GILB_ELL:
+	case CLG_4_STATES:
+		if (!loss[NETEM_LOSS_STATE]) {
+			pr_info("netem: missing state information for loss model\n");
+			return -EINVAL;
+		}
+		break;
+	case CLG_DETERMIN:
+		if (!loss[NETEM_LOSS_SEQUENCE]) {
+			pr_info("netem: missing sequence information for loss model\n");
+			return -EINVAL;
+		}
+		break;
+
+	default:
+		pr_info("netem: unknown loss model: %u\n",
+			(unsigned) model);
+		return -EINVAL;
+	}
+
+	sch_tree_lock(sch);
+	if (loss[NETEM_LOSS_STATE]) {
+		if (!q->clg) {
+			q->clg = kmalloc(sizeof(struct clgstate), GFP_KERNEL);
+			if (!q->clg)
+				goto nomem;
+		}
+		memcpy(q->clg, nla_data(loss[NETEM_LOSS_STATE]),
+		       sizeof(struct clgstate));
+	}
+	if (loss[NETEM_LOSS_SEQUENCE]) {
+		struct dlgtable *dlg;
+		size_t len = nla_len(loss[NETEM_LOSS_SEQUENCE]);
+
+		dlg = kmalloc(sizeof(*dlg) + len, GFP_KERNEL);
+		if (dlg)
+			goto nomem;
+
+		dlg->length = len * BITS_PER_LONG;
+		dlg->index = 0;
+		memcpy(dlg->sequence, nla_data(loss[NETEM_LOSS_SEQUENCE]), len);
+
+		kfree(q->dlg);
+		q->dlg = dlg;
+	}
+
+	q->loss_model = model;
+	sch_tree_unlock(sch);
+
+	return 0;
+ nomem:
+	sch_tree_unlock(sch);
+	return -ENOMEM;
+}
+
 static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
 	[TCA_NETEM_CORR]	= { .len = sizeof(struct tc_netem_corr) },
 	[TCA_NETEM_REORDER]	= { .len = sizeof(struct tc_netem_reorder) },
 	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
+	[TCA_NETEM_LOSS]	= { .type = NLA_NESTED },
 };
 
 static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
@@ -441,6 +696,9 @@ static int netem_change(struct Qdisc *sc
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
 
+	if (tb[TCA_NETEM_LOSS])
+		get_loss_clg(sch, tb[TCA_NETEM_LOSS]);
+
 	return 0;
 }
 
@@ -538,6 +796,7 @@ static int netem_init(struct Qdisc *sch,
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
+	q->loss_model = CLG_NONE;
 	q->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				     &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
@@ -561,13 +820,14 @@ static void netem_destroy(struct Qdisc *
 	qdisc_watchdog_cancel(&q->watchdog);
 	qdisc_destroy(q->qdisc);
 	kfree(q->delay_dist);
+	kfree(q->clg);
+	kfree(q->dlg);
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	const struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
-	struct nlattr *nla = (struct nlattr *) b;
+	struct nlattr *nla = (struct nlattr *) skb_tail_pointer(skb);
 	struct tc_netem_qopt qopt;
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
@@ -594,13 +854,28 @@ static int netem_dump(struct Qdisc *sch,
 	corrupt.correlation = q->corrupt_cor.rho;
 	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
-	nla->nla_len = skb_tail_pointer(skb) - b;
+	if (q->loss_model != CLG_NONE) {
+		struct nlattr *nest = nla_nest_start(skb, NETEM_LOSS_MAX);
+
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		NLA_PUT_U8(skb, NETEM_LOSS_MODEL, q->loss_model);
+		if (q->clg)
+			NLA_PUT(skb, NETEM_LOSS_STATE,
+				sizeof(struct tc_netem_loss_state), q->clg);
+		/*
+		 * Don't bother dumping loss sequence map since it can be large
+		 * and hard to display
+		 */
+		nla_nest_end(skb, nest);
+	}
 
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
+	nlmsg_trim(skb, nla);
+	return -EMSGSIZE;
 }
 
 static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
--- a/include/linux/pkt_sched.h	2010-05-17 20:51:43.763328095 -0700
+++ b/include/linux/pkt_sched.h	2010-05-17 20:52:10.263123961 -0700
@@ -435,6 +435,7 @@ enum {
 	TCA_NETEM_DELAY_DIST,
 	TCA_NETEM_REORDER,
 	TCA_NETEM_CORRUPT,
+	TCA_NETEM_LOSS,
 	__TCA_NETEM_MAX,
 };
 
@@ -465,6 +466,31 @@ struct tc_netem_corrupt {
 	__u32	correlation;
 };
 
+enum {
+	NETEM_LOSS_MODEL,
+	NETEM_LOSS_STATE,
+	NETEM_LOSS_SEQUENCE,
+	__NETEM_LOSS_MAX
+};
+#define NETEM_LOSS_MAX (__NETEM_LOSS_MAX - 1)
+
+/* definition of models for Correlated Loss Generation */
+enum netem_clg_model {
+	CLG_NONE = 0,
+	CLG_GILB_ELL,
+	CLG_4_STATES,
+	CLG_DETERMIN,
+};
+
+/* Correlated Loss Model parameters - GI and Gilbert-Elliot models */
+struct tc_netem_loss_state {
+	__u32	a1;	/* p13 for GI or p for Gilbert-Elliot */
+	__u32	a2;	/* p31 for GI or r for Gilbert-Elliot */
+	__u32	a3;	/* p32 for GI or h for Gilbert-Elliot */
+	__u32	a4;	/* p14 for GI or 1-k for Gilbert-Elliot */
+	__u32	a5;	/* p23 used only in GI */
+};
+
 #define NETEM_DIST_SCALE	8192
 
 /* DRR */
