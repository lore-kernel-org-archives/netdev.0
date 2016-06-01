From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_hfsc: always keep backlog updated
Date: Wed,  1 Jun 2016 16:15:15 -0700
Message-ID: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35587 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbcFAXPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:15:41 -0400
Received: by mail-pa0-f68.google.com with SMTP id gp3so1587849pac.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:15:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hfsc updates backlog lazily, that is only when we
dump the stats. This is problematic after we begin to
update backlog in qdisc_tree_reduce_backlog().

Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Tested-by: Stas Nichiporovich <stasn77@gmail.com>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_hfsc.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d783d7c..1ac9f9f 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1529,6 +1529,7 @@ hfsc_reset_qdisc(struct Qdisc *sch)
 	q->eligible = RB_ROOT;
 	INIT_LIST_HEAD(&q->droplist);
 	qdisc_watchdog_cancel(&q->watchdog);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 }
 
@@ -1559,14 +1560,6 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	struct hfsc_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_hfsc_qopt qopt;
-	struct hfsc_class *cl;
-	unsigned int i;
-
-	sch->qstats.backlog = 0;
-	for (i = 0; i < q->clhash.hashsize; i++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
-			sch->qstats.backlog += cl->qdisc->qstats.backlog;
-	}
 
 	qopt.defcls = q->defcls;
 	if (nla_put(skb, TCA_OPTIONS, sizeof(qopt), &qopt))
@@ -1604,6 +1597,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (cl->qdisc->q.qlen == 1)
 		set_active(cl, qdisc_pkt_len(skb));
 
+	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1672,6 +1666,7 @@ hfsc_dequeue(struct Qdisc *sch)
 
 	qdisc_unthrottled(sch);
 	qdisc_bstats_update(sch, skb);
+	qdisc_qstats_backlog_dec(sch, skb);
 	sch->q.qlen--;
 
 	return skb;
@@ -1695,6 +1690,7 @@ hfsc_drop(struct Qdisc *sch)
 			}
 			cl->qstats.drops++;
 			qdisc_qstats_drop(sch);
+			sch->qstats.backlog -= len;
 			sch->q.qlen--;
 			return len;
 		}
-- 
2.1.0
