From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 04/16] net_sched: use tcf_queue_work() in cgroup filter
Date: Thu, 26 Oct 2017 18:24:31 -0700
Message-ID: <20171027012443.3306-5-xiyou.wangcong@gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Cc: Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45018 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751961AbdJ0BZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id x7so3784151pfa.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:03 -0700 (PDT)
In-Reply-To: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defer the tcf_exts_destroy() in RCU callback to
tc filter workqueue and get RTNL lock.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_cgroup.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index d48452f87975..a97e069bee89 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -23,7 +23,10 @@ struct cls_cgroup_head {
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -57,15 +60,26 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
 
+static void cls_cgroup_destroy_work(struct work_struct *work)
+{
+	struct cls_cgroup_head *head = container_of(work,
+						    struct cls_cgroup_head,
+						    work);
+	rtnl_lock();
+	tcf_exts_destroy(&head->exts);
+	tcf_em_tree_destroy(&head->ematches);
+	kfree(head);
+	rtnl_unlock();
+}
+
 static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 {
 	struct cls_cgroup_head *head = container_of(root,
 						    struct cls_cgroup_head,
 						    rcu);
 
-	tcf_exts_destroy(&head->exts);
-	tcf_em_tree_destroy(&head->ematches);
-	kfree(head);
+	INIT_WORK(&head->work, cls_cgroup_destroy_work);
+	tcf_queue_work(&head->work);
 }
 
 static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
-- 
2.13.0
