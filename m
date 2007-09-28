From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 10/10] Use nested compat attributes to pass parameters.
Date: Fri, 28 Sep 2007 15:52:57 -0700
Message-ID: <11910199782593-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42870 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754255AbXI1WxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:53:08 -0400
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the ambiguity between, for example:
tc qdisc change ... perturb 0
tc qdisc change ...

Without this patch, there is no way for SFQ to differentiate between
a parameter specified to be 0 and a parameter that was omitted.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |   13 +++++++++++
 net/sched/sch_sfq.c       |   53 +++++++++++++++++++++++++++++---------------
 2 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 8559974..aad04eb 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -148,6 +148,19 @@ struct tc_sfq_qopt
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+enum
+{
+	TCA_SFQ_UNSPEC,
+	TCA_SFQ_COMPAT,
+	TCA_SFQ_QUANTUM,
+	TCA_SFQ_PERTURB,
+	TCA_SFQ_LIMIT,
+	TCA_SFQ_DIVISOR,
+	TCA_SFQ_FLOWS,
+	__TCA_SFQ_MAX,
+};
+
+#define TCA_SFQ_MAX (__TCA_SFQ_MAX - 1)
 
 /* RED section */
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 170fd37..36197f6 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -428,25 +428,31 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	 * the previous values (sfq_change). So, overwrite the parameters as
 	 * specified. */
 	if (opt) {
-		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
-
-		if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
-			return -EINVAL;
-
-		if (ctl->quantum)
-			q->quantum = ctl->quantum;
-		if (ctl->perturb_period)
-			q->perturb_period = ctl->perturb_period;
-		if (ctl->divisor)
-			q->hash_divisor = ctl->divisor;
-		if (ctl->flows)
-			q->depth = ctl->flows;
-		if (ctl->limit)
-			q->limit = ctl->limit;
-
+		struct tc_sfq_qopt *ctl;
+		struct rtattr *tb[TCA_SFQ_MAX];
+
+		if (rtattr_parse_nested_compat(tb, TCA_SFQ_MAX, opt, ctl,
+				       sizeof(*ctl)))
+			goto rtattr_failure;
+
+#define GET_PARAM(dst, nest, compat) do { \
+	struct rtattr *rta = tb[(nest) - 1]; \
+	if (rta) \
+		(dst) = RTA_GET_U32(rta); \
+	else if ((compat)) \
+		(dst) = (compat); \
+} while (0)
+
+		GET_PARAM(q->quantum,        TCA_SFQ_QUANTUM, ctl->quantum);
+		GET_PARAM(q->perturb_period, TCA_SFQ_PERTURB,
+				ctl->perturb_period);
+		GET_PARAM(q->hash_divisor,   TCA_SFQ_DIVISOR, ctl->divisor);
+		GET_PARAM(q->depth,          TCA_SFQ_FLOWS,   ctl->flows);
+		GET_PARAM(q->limit,          TCA_SFQ_LIMIT,   ctl->limit);
+		
 		if (q->perturb_period > SFQ_MAX_PERTURB ||
 		    q->depth > SFQ_MAX_DEPTH)
-			return -EINVAL;
+			goto rtattr_failure;
 	}
 	q->limit = min_t(u32, q->limit, q->depth - 2);
 	q->tail = q->depth;
@@ -482,6 +488,8 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	for (i=0; i < q->depth; i++)
 		sfq_link(q, i);
 	return 0;
+rtattr_failure:
+	return -EINVAL;
 err_case:
 	sfq_q_destroy(q);
 	return -ENOBUFS;
@@ -559,17 +567,26 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *nest;
 	struct tc_sfq_qopt opt;
 
 	opt.quantum = q->quantum;
 	opt.perturb_period = q->perturb_period;
-
 	opt.limit = q->limit;
 	opt.divisor = q->hash_divisor;
 	opt.flows = q->depth;
 
+	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+
+	RTA_PUT_U32(skb, TCA_SFQ_QUANTUM, q->quantum);
+	RTA_PUT_U32(skb, TCA_SFQ_PERTURB, q->perturb_period);
+	RTA_PUT_U32(skb, TCA_SFQ_LIMIT,   q->limit);
+	RTA_PUT_U32(skb, TCA_SFQ_DIVISOR, q->hash_divisor);
+	RTA_PUT_U32(skb, TCA_SFQ_FLOWS,   q->depth);
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
+	RTA_NEST_COMPAT_END(skb, nest);
+
 	return skb->len;
 
 rtattr_failure:
-- 
1.5.3

