From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 12/15] net_sched: remove RCU callbacks in sample action
Date: Mon, 23 Oct 2017 15:03:01 -0700
Message-ID: <20171023220304.2268-13-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Yotam Gigi <yotamg@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:44545 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdJWWDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:46 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so12849026pga.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:46 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->cleanup() now can block, it is okay to change
it to synchronize_rcu(). This could also fix a use-after-free
in module unloading.

Cc: Yotam Gigi <yotamg@mellanox.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tc_act/tc_sample.h |  1 -
 net/sched/act_sample.c         | 12 +++---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/include/net/tc_act/tc_sample.h b/include/net/tc_act/tc_sample.h
index 89e9305be880..eb44804ff5f0 100644
--- a/include/net/tc_act/tc_sample.h
+++ b/include/net/tc_act/tc_sample.h
@@ -13,7 +13,6 @@ struct tcf_sample {
 	struct psample_group __rcu *psample_group;
 	u32 psample_group_num;
 	struct list_head tcfm_list;
-	struct rcu_head rcu;
 };
 #define to_sample(a) ((struct tcf_sample *)a)
 
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index ec986ae52808..b8863e3f6776 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -96,23 +96,17 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 	return ret;
 }
 
-static void tcf_sample_cleanup_rcu(struct rcu_head *rcu)
+static void tcf_sample_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_sample *s = container_of(rcu, struct tcf_sample, rcu);
+	struct tcf_sample *s = to_sample(a);
 	struct psample_group *psample_group;
 
+	synchronize_rcu();
 	psample_group = rcu_dereference_protected(s->psample_group, 1);
 	RCU_INIT_POINTER(s->psample_group, NULL);
 	psample_group_put(psample_group);
 }
 
-static void tcf_sample_cleanup(struct tc_action *a, int bind)
-{
-	struct tcf_sample *s = to_sample(a);
-
-	call_rcu(&s->rcu, tcf_sample_cleanup_rcu);
-}
-
 static bool tcf_sample_dev_ok_push(struct net_device *dev)
 {
 	switch (dev->type) {
-- 
2.13.0
