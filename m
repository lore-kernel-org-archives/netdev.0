From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: choke: remove dead filter classify code
Date: Thu, 23 Mar 2017 17:02:16 +0100
Message-ID: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33497 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965377AbdCWQCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 12:02:20 -0400
Received: by mail-wm0-f68.google.com with SMTP id n11so12998wma.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:02:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

sch_choke is classless qdisc so it does not define cl_ops. Therefore
filter_list cannot be ever changed, being NULL all the time.
Reason is this check in tc_ctl_tfilter:

	/* Is it classful? */
	cops = q->ops->cl_ops;
	if (!cops)
		return -EINVAL;

So remove this dead code.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/sch_choke.c | 51 ---------------------------------------------------
 1 file changed, 51 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 3b86a97..03ce895 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -58,7 +58,6 @@ struct choke_sched_data {
 
 /* Variables */
 	struct red_vars  vars;
-	struct tcf_proto __rcu *filter_list;
 	struct {
 		u32	prob_drop;	/* Early probability drops */
 		u32	prob_mark;	/* Early probability marks */
@@ -152,11 +151,6 @@ static inline void choke_set_classid(struct sk_buff *skb, u16 classid)
 	choke_skb_cb(skb)->classid = classid;
 }
 
-static u16 choke_get_classid(const struct sk_buff *skb)
-{
-	return choke_skb_cb(skb)->classid;
-}
-
 /*
  * Compare flow of two packets
  *  Returns true only if source and destination address and port match.
@@ -188,40 +182,6 @@ static bool choke_match_flow(struct sk_buff *skb1,
 }
 
 /*
- * Classify flow using either:
- *  1. pre-existing classification result in skb
- *  2. fast internal classification
- *  3. use TC filter based classification
- */
-static bool choke_classify(struct sk_buff *skb,
-			   struct Qdisc *sch, int *qerr)
-
-{
-	struct choke_sched_data *q = qdisc_priv(sch);
-	struct tcf_result res;
-	struct tcf_proto *fl;
-	int result;
-
-	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res, false);
-	if (result >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-		switch (result) {
-		case TC_ACT_STOLEN:
-		case TC_ACT_QUEUED:
-			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
-		case TC_ACT_SHOT:
-			return false;
-		}
-#endif
-		choke_set_classid(skb, TC_H_MIN(res.classid));
-		return true;
-	}
-
-	return false;
-}
-
-/*
  * Select a packet at random from queue
  * HACK: since queue can have holes from previous deletion; retry several
  *   times to find a random skb but then just give up and return the head
@@ -257,9 +217,6 @@ static bool choke_match_random(const struct choke_sched_data *q,
 		return false;
 
 	oskb = choke_peek_random(q, pidx);
-	if (rcu_access_pointer(q->filter_list))
-		return choke_get_classid(nskb) == choke_get_classid(oskb);
-
 	return choke_match_flow(oskb, nskb);
 }
 
@@ -270,12 +227,6 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	struct choke_sched_data *q = qdisc_priv(sch);
 	const struct red_parms *p = &q->parms;
 
-	if (rcu_access_pointer(q->filter_list)) {
-		/* If using external classifiers, get result and record it. */
-		if (!choke_classify(skb, sch, &ret))
-			goto other_drop;	/* Packet was eaten by filter */
-	}
-
 	choke_skb_cb(skb)->keys_valid = 0;
 	/* Compute average queue usage (see RED) */
 	q->vars.qavg = red_calc_qavg(p, &q->vars, sch->q.qlen);
@@ -340,7 +291,6 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	qdisc_drop(skb, sch, to_free);
 	return NET_XMIT_CN;
 
-other_drop:
 	if (ret & __NET_XMIT_BYPASS)
 		qdisc_qstats_drop(sch);
 	__qdisc_drop(skb, to_free);
@@ -538,7 +488,6 @@ static void choke_destroy(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(&q->filter_list);
 	choke_free(q->tab);
 }
 
-- 
2.7.4
