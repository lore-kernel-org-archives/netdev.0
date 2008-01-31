From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/04]: sch_sfq: add support for external classifiers
Date: Thu, 31 Jan 2008 18:58:05 +0100 (MET)
Message-ID: <20080131175801.25151.8282.sendpatchset@localhost.localdomain>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55148 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbYAaR6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:58:06 -0500
In-Reply-To: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: sch_sfq: add support for external classifiers

Add support for external classifiers to allow using different flow hash
functions similar to ESFQ. When no classifier is attached the built-in
hash is used as before.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6049892cc4acca9af393e134e4cdaf6b3e1ccad9
tree 9a8347d45808de2aef14486e5792fcab58baf3fe
parent 12e33ddf57910b685501df10bd92223ea9b98fd6
author Patrick McHardy <kaber@trash.net> Wed, 30 Jan 2008 21:59:27 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 18:52:55 +0100

 net/sched/sch_sfq.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 91 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 91af539..d818d19 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -95,6 +95,7 @@ struct sfq_sched_data
 	int		limit;
 
 /* Variables */
+	struct tcf_proto *filter_list;
 	struct timer_list perturb_timer;
 	u32		perturbation;
 	sfq_index	tail;		/* Index of current slot in round */
@@ -155,6 +156,39 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
 	return sfq_fold_hash(q, h, h2);
 }
 
+static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
+				 int *qerr)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	if (TC_H_MAJ(skb->priority) == sch->handle &&
+	    TC_H_MIN(skb->priority) > 0 &&
+	    TC_H_MIN(skb->priority) <= SFQ_HASH_DIVISOR)
+		return TC_H_MIN(skb->priority);
+
+	if (!q->filter_list)
+		return sfq_hash(q, skb) + 1;
+
+	*qerr = NET_XMIT_BYPASS;
+	result = tc_classify(skb, q->filter_list, &res);
+	if (result >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			return 0;
+		}
+#endif
+		if (TC_H_MIN(res.classid) <= SFQ_HASH_DIVISOR)
+			return TC_H_MIN(res.classid);
+	}
+	return 0;
+}
+
 static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
@@ -245,8 +279,18 @@ static int
 sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	unsigned hash = sfq_hash(q, skb);
+	unsigned int hash;
 	sfq_index x;
+	int ret;
+
+	hash = sfq_classify(skb, sch, &ret);
+	if (hash == 0) {
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+	hash--;
 
 	x = q->ht[hash];
 	if (x == SFQ_DEPTH) {
@@ -289,8 +333,18 @@ static int
 sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	unsigned hash = sfq_hash(q, skb);
+	unsigned int hash;
 	sfq_index x;
+	int ret;
+
+	hash = sfq_classify(skb, sch, &ret);
+	if (hash == 0) {
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+	hash--;
 
 	x = q->ht[hash];
 	if (x == SFQ_DEPTH) {
@@ -465,6 +519,8 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(q->filter_list);
 	del_timer(&q->perturb_timer);
 }
 
@@ -490,9 +546,40 @@ nla_put_failure:
 	return -1;
 }
 
+static int sfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct nlattr **tca, unsigned long *arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
+{
+	return 0;
+}
+
+static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	return;
+}
+
+static const struct Qdisc_class_ops sfq_class_ops = {
+	.get		=	sfq_get,
+	.change		=	sfq_change_class,
+	.tcf_chain	=	sfq_find_tcf,
+	.walk		=	sfq_walk,
+};
+
 static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
-	.next		=	NULL,
-	.cl_ops		=	NULL,
+	.cl_ops		=	&sfq_class_ops,
 	.id		=	"sfq",
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
