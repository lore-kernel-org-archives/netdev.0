From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 05/16] net_sched: use tcf_queue_work() in flow filter
Date: Thu, 26 Oct 2017 18:24:32 -0700
Message-ID: <20171027012443.3306-6-xiyou.wangcong@gmail.com>
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
Received: from mail-pf0-f193.google.com ([209.85.192.193]:49817 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751984AbdJ0BZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 21:25:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so3774636pfe.6
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 18:25:04 -0700 (PDT)
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
 net/sched/cls_flow.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2a3a60ec5b86..67f3a2af6aab 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -57,7 +57,10 @@ struct flow_filter {
 	u32			divisor;
 	u32			baseclass;
 	u32			hashrnd;
-	struct rcu_head		rcu;
+	union {
+		struct work_struct	work;
+		struct rcu_head		rcu;
+	};
 };
 
 static inline u32 addr_fold(void *addr)
@@ -369,14 +372,24 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
-static void flow_destroy_filter(struct rcu_head *head)
+static void flow_destroy_filter_work(struct work_struct *work)
 {
-	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
+	struct flow_filter *f = container_of(work, struct flow_filter, work);
 
+	rtnl_lock();
 	del_timer_sync(&f->perturb_timer);
 	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(&f->ematches);
 	kfree(f);
+	rtnl_unlock();
+}
+
+static void flow_destroy_filter(struct rcu_head *head)
+{
+	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
+
+	INIT_WORK(&f->work, flow_destroy_filter_work);
+	tcf_queue_work(&f->work);
 }
 
 static int flow_change(struct net *net, struct sk_buff *in_skb,
-- 
2.13.0
