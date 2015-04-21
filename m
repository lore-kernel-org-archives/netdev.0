From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC 3/3] tc: cleanup tc_classify
Date: Tue, 21 Apr 2015 12:27:56 -0700
Message-ID: <1429644476-8914-4-git-send-email-ast@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34638 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982AbbDUT2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 15:28:14 -0400
Received: by pdbqa5 with SMTP id qa5so250676740pdb.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 12:28:13 -0700 (PDT)
In-Reply-To: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce tc_classify_act() and qdisc_drop_bypass() helper functions to reduce
copy-paste among different qdiscs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/net/pkt_sched.h   |    2 ++
 include/net/sch_generic.h |    7 +++++++
 net/sched/sch_api.c       |   20 ++++++++++++++++++++
 net/sched/sch_choke.c     |   16 +++-------------
 net/sched/sch_drr.c       |   17 +++--------------
 net/sched/sch_fq_codel.c  |   24 ++++++------------------
 net/sched/sch_qfq.c       |   15 ++-------------
 net/sched/sch_sfb.c       |   16 +++-------------
 net/sched/sch_sfq.c       |   25 ++++++-------------------
 9 files changed, 52 insertions(+), 90 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2342bf12cb78..7c73cbe95169 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -114,6 +114,8 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res);
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		struct tcf_result *res);
+int tc_classify_act(struct sk_buff *skb, const struct tcf_proto *tp,
+		    struct tcf_result *res, int *qerr);
 
 static inline __be16 tc_skb_protocol(const struct sk_buff *skb)
 {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6d778efcfdfd..9a50bad24b1d 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -715,6 +715,13 @@ static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_DROP;
 }
 
+static inline void qdisc_drop_bypass(struct sk_buff *skb, struct Qdisc *sch, int err)
+{
+	if (err & __NET_XMIT_BYPASS)
+		qdisc_qstats_drop(sch);
+	kfree_skb(skb);
+}
+
 static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
 	qdisc_qstats_drop(sch);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f7950327bb22..c7c4a672eb35 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1860,6 +1860,26 @@ reclassify:
 }
 EXPORT_SYMBOL(tc_classify);
 
+int tc_classify_act(struct sk_buff *skb, const struct tcf_proto *tp,
+		    struct tcf_result *res, int *qerr)
+{
+	int result;
+
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	result = tc_classify(skb, tp, res);
+
+#ifdef CONFIG_NET_CLS_ACT
+	switch (result) {
+	case TC_ACT_STOLEN:
+		*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+	case TC_ACT_SHOT:
+		return -1;
+	}
+#endif
+	return result;
+}
+EXPORT_SYMBOL(tc_classify_act);
+
 bool tcf_destroy(struct tcf_proto *tp, bool force)
 {
 	if (tp->ops->destroy(tp, force)) {
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index a3bc7cf151d3..8d8ad5303497 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -207,16 +207,8 @@ static bool choke_classify(struct sk_buff *skb,
 	int result;
 
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify_act(skb, fl, &res, qerr);
 	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return false;
-		}
-#endif
 		choke_set_classid(skb, TC_H_MIN(res.classid));
 		return true;
 	}
@@ -268,9 +260,9 @@ static bool choke_match_random(const struct choke_sched_data *q,
 
 static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	struct choke_sched_data *q = qdisc_priv(sch);
 	const struct red_parms *p = &q->parms;
+	int ret;
 
 	if (rcu_access_pointer(q->filter_list)) {
 		/* If using external classifiers, get result and record it. */
@@ -343,9 +335,7 @@ congestion_drop:
 	return NET_XMIT_CN;
 
 other_drop:
-	if (ret & __NET_XMIT_BYPASS)
-		qdisc_qstats_drop(sch);
-	kfree_skb(skb);
+	qdisc_drop_bypass(skb, sch, ret);
 	return ret;
 }
 
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 1051c5d4e85b..36ab69375c79 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -329,18 +329,9 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return cl;
 	}
 
-	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify_act(skb, fl, &res, qerr);
 	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return NULL;
-		}
-#endif
 		cl = (struct drr_class *)res.class;
 		if (cl == NULL)
 			cl = drr_find_class(sch, res.classid);
@@ -353,13 +344,11 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct drr_sched *q = qdisc_priv(sch);
 	struct drr_class *cl;
-	int err = 0;
+	int err;
 
 	cl = drr_classify(skb, sch, &err);
 	if (cl == NULL) {
-		if (err & __NET_XMIT_BYPASS)
-			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		qdisc_drop_bypass(skb, sch, err);
 		return err;
 	}
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 4d00ece3243d..84094637807f 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -98,20 +98,10 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 	if (!filter)
 		return fq_codel_hash(q, skb) + 1;
 
-	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, filter, &res);
-	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return 0;
-		}
-#endif
-		if (TC_H_MIN(res.classid) <= q->flows_cnt)
-			return TC_H_MIN(res.classid);
-	}
+	result = tc_classify_act(skb, filter, &res, qerr);
+	if (result >= 0 && TC_H_MIN(res.classid) <= q->flows_cnt)
+		return TC_H_MIN(res.classid);
+
 	return 0;
 }
 
@@ -174,13 +164,11 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	unsigned int idx;
 	struct fq_codel_flow *flow;
-	int uninitialized_var(ret);
+	int ret;
 
 	idx = fq_codel_classify(skb, sch, &ret);
 	if (idx == 0) {
-		if (ret & __NET_XMIT_BYPASS)
-			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		qdisc_drop_bypass(skb, sch, ret);
 		return ret;
 	}
 	idx--;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 9d1e43ea0ccb..7bed6b5bc500 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -717,18 +717,9 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return cl;
 	}
 
-	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify_act(skb, fl, &res, qerr);
 	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return NULL;
-		}
-#endif
 		cl = (struct qfq_class *)res.class;
 		if (cl == NULL)
 			cl = qfq_find_class(sch, res.classid);
@@ -1227,9 +1218,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	cl = qfq_classify(skb, sch, &err);
 	if (cl == NULL) {
-		if (err & __NET_XMIT_BYPASS)
-			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		qdisc_drop_bypass(skb, sch, err);
 		return err;
 	}
 	pr_debug("qfq_enqueue: cl = %x\n", cl->common.classid);
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 61e18108d0d3..c36c596ba56b 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -259,16 +259,8 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify_act(skb, fl, &res, qerr);
 	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return false;
-		}
-#endif
 		*salt = TC_H_MIN(res.classid);
 		return true;
 	}
@@ -285,7 +277,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	u32 p_min = ~0;
 	u32 minqlen = ~0;
 	u32 r, slot, salt, sfbhash;
-	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	int ret;
 	struct flow_keys keys;
 
 	if (unlikely(sch->q.qlen >= q->limit)) {
@@ -418,9 +410,7 @@ drop:
 	qdisc_drop(skb, sch);
 	return NET_XMIT_CN;
 other_drop:
-	if (ret & __NET_XMIT_BYPASS)
-		qdisc_qstats_drop(sch);
-	kfree_skb(skb);
+	qdisc_drop_bypass(skb, sch, ret);
 	return ret;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b508ff655da3..7d9ad84bc8f9 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -201,20 +201,10 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return sfq_hash(q, skb) + 1;
 	}
 
-	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, fl, &res);
-	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return 0;
-		}
-#endif
-		if (TC_H_MIN(res.classid) <= q->divisor)
-			return TC_H_MIN(res.classid);
-	}
+	result = tc_classify_act(skb, fl, &res, qerr);
+	if (result >= 0 && TC_H_MIN(res.classid) <= q->divisor)
+		return TC_H_MIN(res.classid);
+
 	return 0;
 }
 
@@ -371,15 +361,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	unsigned int hash;
 	sfq_index x, qlen;
 	struct sfq_slot *slot;
-	int uninitialized_var(ret);
 	struct sk_buff *head;
-	int delta;
+	int delta, ret;
 
 	hash = sfq_classify(skb, sch, &ret);
 	if (hash == 0) {
-		if (ret & __NET_XMIT_BYPASS)
-			qdisc_qstats_drop(sch);
-		kfree_skb(skb);
+		qdisc_drop_bypass(skb, sch, ret);
 		return ret;
 	}
 	hash--;
-- 
1.7.9.5
