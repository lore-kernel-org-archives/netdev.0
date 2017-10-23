From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 07/15] net_sched: remove RCU callbacks in flow filter
Date: Mon, 23 Oct 2017 15:02:56 -0700
Message-ID: <20171023220304.2268-8-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:49693 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbdJWWDk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:40 -0400
Received: by mail-pf0-f194.google.com with SMTP id i5so18108587pfe.6
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:40 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu(), except in
flow_destroy() we have to use list_splice_init_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_flow.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2a3a60ec5b86..c33643289fa9 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -35,7 +35,6 @@
 
 struct flow_head {
 	struct list_head	filters;
-	struct rcu_head		rcu;
 };
 
 struct flow_filter {
@@ -57,7 +56,6 @@ struct flow_filter {
 	u32			divisor;
 	u32			baseclass;
 	u32			hashrnd;
-	struct rcu_head		rcu;
 };
 
 static inline u32 addr_fold(void *addr)
@@ -369,10 +367,8 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
-static void flow_destroy_filter(struct rcu_head *head)
+static void flow_destroy_filter(struct flow_filter *f)
 {
-	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
-
 	del_timer_sync(&f->perturb_timer);
 	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(&f->ematches);
@@ -539,8 +535,10 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 
 	*arg = fnew;
 
-	if (fold)
-		call_rcu(&fold->rcu, flow_destroy_filter);
+	if (fold) {
+		synchronize_rcu();
+		flow_destroy_filter(fold);
+	}
 	return 0;
 
 err2:
@@ -557,7 +555,8 @@ static int flow_delete(struct tcf_proto *tp, void *arg, bool *last)
 	struct flow_filter *f = arg;
 
 	list_del_rcu(&f->list);
-	call_rcu(&f->rcu, flow_destroy_filter);
+	synchronize_rcu();
+	flow_destroy_filter(f);
 	*last = list_empty(&head->filters);
 	return 0;
 }
@@ -578,12 +577,15 @@ static void flow_destroy(struct tcf_proto *tp)
 {
 	struct flow_head *head = rtnl_dereference(tp->root);
 	struct flow_filter *f, *next;
+	LIST_HEAD(local);
+
+	list_splice_init_rcu(&head->filters, &local, synchronize_rcu);
 
-	list_for_each_entry_safe(f, next, &head->filters, list) {
+	list_for_each_entry_safe(f, next, &local, list) {
 		list_del_rcu(&f->list);
-		call_rcu(&f->rcu, flow_destroy_filter);
+		flow_destroy_filter(f);
 	}
-	kfree_rcu(head, rcu);
+	kfree(head);
 }
 
 static void *flow_get(struct tcf_proto *tp, u32 handle)
-- 
2.13.0
