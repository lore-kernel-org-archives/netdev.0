From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH net-next] net_sched: gred: add TCA_GRED_LIMIT attribute
Date: Sat,  9 May 2015 22:01:46 -0400
Message-ID: <1431223307-26669-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:62216 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752050AbbEJCG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:06:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a GRED qdisc, if the default "virtual queue" (VQ) does not have drop
parameters configured, then packets for the default VQ are not subjected
to RED and are only dropped if the queue is larger than the net_device's
tx_queue_len. This behavior is useful for WRED mode, since these packets
will still influence the calculated average queue length and (therefore)
the drop probability for all of the other VQs. However, for some drivers
tx_queue_len is zero. In other cases the user may wish to make the limit
the same for all VQs (including the default VQ with no drop parameters).

This change adds a TCA_GRED_LIMIT attribute to set the GRED queue limit,
in bytes, during qdisc setup. (This limit is in bytes to be consistent
with the drop parameters.) The default limit is the same as for a bfifo
queue (tx_queue_len * psched_mtu). If the drop parameters of any VQ are
configured with a smaller limit than the GRED queue limit, that VQ will
still observe the smaller limit instead.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/uapi/linux/pkt_sched.h |    3 ++-
 net/sched/sch_gred.c           |   28 ++++++++++++++++++++++++----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 534b847..700f50a 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -268,7 +268,8 @@ enum {
        TCA_GRED_STAB,
        TCA_GRED_DPS,
        TCA_GRED_MAX_P,
-	   __TCA_GRED_MAX,
+       TCA_GRED_LIMIT,
+       __TCA_GRED_MAX,
 };
 
 #define TCA_GRED_MAX (__TCA_GRED_MAX - 1)
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index a4ca451..826e299 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -165,7 +165,8 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			 * if no default DP has been configured. This
 			 * allows for DP flows to be left untouched.
 			 */
-			if (skb_queue_len(&sch->q) < qdisc_dev(sch)->tx_queue_len)
+			if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <=
+					sch->limit))
 				return qdisc_enqueue_tail(skb, sch);
 			else
 				goto drop;
@@ -397,7 +398,10 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 
 	q->DP = dp;
 	q->prio = prio;
-	q->limit = ctl->limit;
+	if (ctl->limit > sch->limit)
+		q->limit = sch->limit;
+	else
+		q->limit = ctl->limit;
 
 	if (q->backlog == 0)
 		red_end_of_idle_period(&q->vars);
@@ -414,6 +418,7 @@ static const struct nla_policy gred_policy[TCA_GRED_MAX + 1] = {
 	[TCA_GRED_STAB]		= { .len = 256 },
 	[TCA_GRED_DPS]		= { .len = sizeof(struct tc_gred_sopt) },
 	[TCA_GRED_MAX_P]	= { .type = NLA_U32 },
+	[TCA_GRED_LIMIT]	= { .type = NLA_U32 },
 };
 
 static int gred_change(struct Qdisc *sch, struct nlattr *opt)
@@ -433,11 +438,15 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_GRED_PARMS] == NULL && tb[TCA_GRED_STAB] == NULL)
+	if (tb[TCA_GRED_PARMS] == NULL && tb[TCA_GRED_STAB] == NULL) {
+		if (tb[TCA_GRED_LIMIT] != NULL)
+			sch->limit = nla_get_u32(tb[TCA_GRED_LIMIT]);
 		return gred_change_table_def(sch, opt);
+	}
 
 	if (tb[TCA_GRED_PARMS] == NULL ||
-	    tb[TCA_GRED_STAB] == NULL)
+	    tb[TCA_GRED_STAB] == NULL ||
+	    tb[TCA_GRED_LIMIT] != NULL)
 		return -EINVAL;
 
 	max_P = tb[TCA_GRED_MAX_P] ? nla_get_u32(tb[TCA_GRED_MAX_P]) : 0;
@@ -501,6 +510,14 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_GRED_PARMS] || tb[TCA_GRED_STAB])
 		return -EINVAL;
 
+	if (tb[TCA_GRED_LIMIT])
+		sch->limit = nla_get_u32(tb[TCA_GRED_LIMIT]);
+	else {
+		u32 qlen = qdisc_dev(sch)->tx_queue_len ? : 1;
+
+		sch->limit = qlen * psched_mtu(qdisc_dev(sch));
+	}
+
 	return gred_change_table_def(sch, tb[TCA_GRED_DPS]);
 }
 
@@ -531,6 +548,9 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (nla_put(skb, TCA_GRED_MAX_P, sizeof(max_p), max_p))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, TCA_GRED_LIMIT, sch->limit))
+		goto nla_put_failure;
+
 	parms = nla_nest_start(skb, TCA_GRED_PARMS);
 	if (parms == NULL)
 		goto nla_put_failure;
-- 
1.7.1
