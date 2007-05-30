From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 01/02]: sch_sfq: add support for external classifiers
Date: Wed, 30 May 2007 11:40:56 +0200 (MEST)
Message-ID: <20070530094021.24073.69313.sendpatchset@localhost.localdomain>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33827 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbXE3Jk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 05:40:58 -0400
In-Reply-To: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_sfq: add support for external classifiers

Add support for external classifiers to allow using different flow hash
functions similar to ESFQ. As long as no classifier is attached the
built-in hash is used as before.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 666e402224e5ca36af0b5a07d424b9c092bce91e
tree f0e020de640693ba9601cc2e4b82daba7bf03689
parent c420bc9f09a0926b708c3edb27eacba434a4f4ba
author Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 11:21:05 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 30 May 2007 11:21:05 +0200

 net/sched/sch_sfq.c |   98 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 94 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 96dfdf7..42cd4fc 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -108,6 +108,7 @@ struct sfq_sched_data
 	int		limit;
 
 /* Variables */
+	struct tcf_proto *filter_list;
 	struct timer_list perturb_timer;
 	int		perturbation;
 	sfq_index	tail;		/* Index of current slot in round */
@@ -172,6 +173,42 @@ static unsigned sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
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
+#elif defined(CONFIG_NET_CLS_POLICE)
+		if (result == TC_POLICE_SHOT)
+			return 0;
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
@@ -262,8 +299,18 @@ static int
 sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
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
@@ -298,8 +345,18 @@ static int
 sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
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
@@ -456,6 +513,8 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(q->filter_list);
 	del_timer(&q->perturb_timer);
 }
 
@@ -481,9 +540,40 @@ rtattr_failure:
 	return -1;
 }
 
+static int sfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct rtattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
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
+static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	return;
+}
+
+static struct Qdisc_class_ops sfq_class_ops = {
+	.get		=	sfq_get,
+	.change		=	sfq_change_class,
+	.tcf_chain	=	sfq_find_tcf,
+	.walk		=	sfq_walk,
+};
+
 static struct Qdisc_ops sfq_qdisc_ops = {
-	.next		=	NULL,
-	.cl_ops		=	NULL,
+	.cl_ops		=	&sfq_class_ops,
 	.id		=	"sfq",
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
