From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 8/8] Use nested compat attributes to pass parameters.
Date: Mon, 29 Oct 2007 00:23:07 -0700
Message-ID: <1193642587-32657-9-git-send-email-bugfood-ml@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Cc: Corey Hickey <bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50328 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbXJ2HXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:23:16 -0400
In-Reply-To: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the ambiguity between, for example:
tc qdisc change ... perturb 0
tc qdisc change ...

Without this patch, there is no way for SFQ to differentiate between
a parameter specified to be 0 and a parameter that was omitted.

Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
---
 include/linux/pkt_sched.h |   13 ++++++++
 net/sched/sch_sfq.c       |   69 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 66 insertions(+), 16 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 14a08ad..b1a1a52 100644
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
index 2764a54..5c25b05 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -456,6 +456,29 @@ sfq_copy_parameters(struct sfq_sched_data *dst, struct sfq_sched_data *src)
 	dst->depth          = src->depth;
 }
 
+/* SFQ parameters exist as individual rtattr attributes, with a nested
+ * "struct tc_sfq_qopt" for compatibility with older userspace tools. If an
+ * individual attribute is set, we want to use it; otherwise, fall back to the
+ * nested struct.
+ * There is one caveat: if a member of the nested struct is 0, we cannot
+ * determine if that parameter is supposed to be 0 or if it is merely unset.
+ * So, only set a parameter if the corresponding struct member (u32 compat) is
+ * nonzero. When setting a parameter to 0, it is necessary to use the
+ * individual attribute. */
+static inline int
+sfq_get_parameter(u32 *dst, struct rtattr *tb[TCA_SFQ_MAX], int attr,
+		  u32 compat)
+{
+	struct rtattr *rta = tb[(attr - 1)];
+	if (rta)
+		*dst = RTA_GET_U32(rta);
+	else if (compat)
+		*dst = compat;
+
+	rtattr_failure:
+		return -EINVAL;
+}
+	
 static int
 sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 {
@@ -465,21 +488,24 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
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
+		struct tc_sfq_qopt *ctl;
+		struct rtattr *tb[TCA_SFQ_MAX];
+
+		if (rtattr_parse_nested_compat(tb, TCA_SFQ_MAX, opt, ctl,
+				sizeof(*ctl)))
+			goto rtattr_failure;
+
+		if (sfq_get_parameter(&(q->quantum),        tb, TCA_SFQ_QUANTUM,
+				ctl->quantum)        ||
+		    sfq_get_parameter(&(q->perturb_period), tb, TCA_SFQ_PERTURB,
+				ctl->perturb_period) ||
+		    sfq_get_parameter(&(q->hash_divisor),   tb, TCA_SFQ_DIVISOR,
+				ctl->divisor)        ||
+		    sfq_get_parameter(&(q->depth),          tb, TCA_SFQ_FLOWS,
+				ctl->flows)          ||
+		    sfq_get_parameter(&(q->limit),          tb, TCA_SFQ_LIMIT,
+				ctl->limit))
+			goto rtattr_failure;
 
 		if (q->depth        > SFQ_MAX_DEPTH ||
 		    q->hash_divisor > SFQ_MAX_DIVISOR)
@@ -519,6 +545,8 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
 	for (i=0; i < q->depth; i++)
 		sfq_link(q, i);
 	return 0;
+rtattr_failure:
+	return -EINVAL;
 err_case:
 	sfq_q_destroy(q);
 	return -ENOBUFS;
@@ -602,17 +630,26 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
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
1.5.3.4

