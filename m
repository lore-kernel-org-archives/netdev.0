From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 05/15] net_sched: remove RCU callbacks in cgroup filter
Date: Mon, 23 Oct 2017 15:02:54 -0700
Message-ID: <20171023220304.2268-6-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:43500 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJWWDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:38 -0400
Received: by mail-pg0-f65.google.com with SMTP id s75so12840293pgs.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:38 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_cgroup.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index d48452f87975..fb001799eca6 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -23,7 +23,6 @@ struct cls_cgroup_head {
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
 };
 
 static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -57,11 +56,8 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
-static void cls_cgroup_destroy_rcu(struct rcu_head *root)
+static void __cls_cgroup_destroy(struct cls_cgroup_head *head)
 {
-	struct cls_cgroup_head *head = container_of(root,
-						    struct cls_cgroup_head,
-						    rcu);
 
 	tcf_exts_destroy(&head->exts);
 	tcf_em_tree_destroy(&head->ematches);
@@ -110,8 +106,10 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	rcu_assign_pointer(tp->root, new);
-	if (head)
-		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
+	if (head) {
+		synchronize_rcu();
+		__cls_cgroup_destroy(head);
+	}
 	return 0;
 errout:
 	tcf_exts_destroy(&new->exts);
@@ -124,8 +122,10 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	/* Head can still be NULL due to cls_cgroup_init(). */
-	if (head)
-		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
+	if (head) {
+		synchronize_rcu();
+		__cls_cgroup_destroy(head);
+	}
 }
 
 static int cls_cgroup_delete(struct tcf_proto *tp, void *arg, bool *last)
-- 
2.13.0
