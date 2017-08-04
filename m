From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 01/20] net: sched: sch_atm: use Qdisc_class_common structure
Date: Fri,  4 Aug 2017 14:28:56 +0200
Message-ID: <20170804122915.15177-2-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37578 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdHDM3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id t138so5520128wmt.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:19 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Even if it is only for classid now, use this common struct a be aligned
with the rest of the classful qdiscs.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_atm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 572fe25..0af4b1c 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -41,6 +41,7 @@
 #define VCC2FLOW(vcc) ((struct atm_flow_data *) ((vcc)->user_back))
 
 struct atm_flow_data {
+	struct Qdisc_class_common common;
 	struct Qdisc		*q;	/* FIFO, TBF, etc. */
 	struct tcf_proto __rcu	*filter_list;
 	struct tcf_block	*block;
@@ -49,7 +50,6 @@ struct atm_flow_data {
 					   struct sk_buff *skb); /* chaining */
 	struct atm_qdisc_data	*parent;	/* parent qdisc */
 	struct socket		*sock;		/* for closing */
-	u32			classid;	/* x:y type ID */
 	int			ref;		/* reference count */
 	struct gnet_stats_basic_packed	bstats;
 	struct gnet_stats_queue	qstats;
@@ -75,7 +75,7 @@ static inline struct atm_flow_data *lookup_flow(struct Qdisc *sch, u32 classid)
 	struct atm_flow_data *flow;
 
 	list_for_each_entry(flow, &p->flows, list) {
-		if (flow->classid == classid)
+		if (flow->common.classid == classid)
 			return flow;
 	}
 	return NULL;
@@ -293,7 +293,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	flow->old_pop = flow->vcc->pop;
 	flow->parent = p;
 	flow->vcc->pop = sch_atm_pop;
-	flow->classid = classid;
+	flow->common.classid = classid;
 	flow->ref = 1;
 	flow->excess = excess;
 	list_add(&flow->list, &p->link.list);
@@ -549,7 +549,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 
 	p->link.vcc = NULL;
 	p->link.sock = NULL;
-	p->link.classid = sch->handle;
+	p->link.common.classid = sch->handle;
 	p->link.ref = 1;
 	tasklet_init(&p->task, sch_atm_dequeue, (unsigned long)sch);
 	return 0;
@@ -594,7 +594,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		sch, p, flow, skb, tcm);
 	if (list_empty(&flow->list))
 		return -EINVAL;
-	tcm->tcm_handle = flow->classid;
+	tcm->tcm_handle = flow->common.classid;
 	tcm->tcm_info = flow->q->handle;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
@@ -619,7 +619,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 			goto nla_put_failure;
 	}
 	if (flow->excess) {
-		if (nla_put_u32(skb, TCA_ATM_EXCESS, flow->classid))
+		if (nla_put_u32(skb, TCA_ATM_EXCESS, flow->common.classid))
 			goto nla_put_failure;
 	} else {
 		if (nla_put_u32(skb, TCA_ATM_EXCESS, 0))
-- 
2.9.3
