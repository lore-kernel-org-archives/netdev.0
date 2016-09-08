From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 08 Sep 2016 08:35:43 -0700
Message-ID: <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
         <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
         <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <57D0FF87.604@gmail.com>
         <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34028 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932165AbcIHPfq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:35:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so2663956pfb.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:35:46 -0700 (PDT)
In-Reply-To: <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As reported by Cong Wang, I was lazy when I did initial RCU conversion
of tc_mirred, as I thought I could avoid allocation/freeing of a
parameter block.

Use an intermediate object so that fast path can get a consistent
snapshot of multiple variables (dev, action, eaction, ok_push)

Fixes: 2ee22a90c7af ("net_sched: act_mirred: remove spinlock in fast path")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Hadar Hen Zion <hadarh@mellanox.com>
Cc: Amir Vadai <amirva@mellanox.com>
---
 include/net/tc_act/tc_mirred.h |   12 +++++-
 net/sched/act_mirred.c         |   54 +++++++++++++++++++++----------
 2 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 62770add15bd..a613b4b9c56e 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -4,12 +4,20 @@
 #include <net/act_api.h>
 #include <linux/tc_act/tc_mirred.h>
 
+
+struct tcf_mirred_params {
+	struct net_device	*dev;
+	int			action;
+	int			eaction;
+	int			ok_push;
+	struct rcu_head		rcu;
+};
+
 struct tcf_mirred {
 	struct tc_action	common;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
-	int			tcfm_ok_push;
-	struct net_device __rcu	*tcfm_dev;
+	struct tcf_mirred_params __rcu *params;
 	struct list_head	tcfm_list;
 };
 #define to_mirred(a) ((struct tcf_mirred *)a)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6038c85d92f5..1dc0b6036180 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -36,15 +36,16 @@ static DEFINE_SPINLOCK(mirred_list_lock);
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
-	struct net_device *dev;
+	struct tcf_mirred_params *params;
 
 	/* We could be called either in a RCU callback or with RTNL lock held. */
 	spin_lock_bh(&mirred_list_lock);
 	list_del(&m->tcfm_list);
-	dev = rcu_dereference_protected(m->tcfm_dev, 1);
-	if (dev)
-		dev_put(dev);
+	params = rcu_dereference_protected(m->params, 1);
+	if (params->dev)
+		dev_put(params->dev);
 	spin_unlock_bh(&mirred_list_lock);
+	kfree_rcu(params, rcu);
 }
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
@@ -60,6 +61,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
+	struct tcf_mirred_params *params_new;
+	struct tcf_mirred_params *params_old;
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
@@ -124,21 +127,33 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
+		ret = 0;
 	}
 	m = to_mirred(*a);
 
 	ASSERT_RTNL();
-	m->tcf_action = parm->action;
-	m->tcfm_eaction = parm->eaction;
+	params_new = kzalloc(sizeof(*params_new), GFP_KERNEL);
+	if (unlikely(!params_new)) {
+		if (ret == ACT_P_CREATED)
+			tcf_hash_release(*a, bind);
+		return -ENOMEM;
+	}
+	params_old = rtnl_dereference(m->params);
+	params_new->action = m->tcf_action = parm->action;
+	params_new->eaction = m->tcfm_eaction = parm->eaction;
 	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
-		if (ret != ACT_P_CREATED)
-			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
 		dev_hold(dev);
-		rcu_assign_pointer(m->tcfm_dev, dev);
-		m->tcfm_ok_push = ok_push;
+		params_new->dev = dev;
+		params_new->ok_push = ok_push;
 	}
 
+	rcu_assign_pointer(m->params, params_new);
+	if (params_old) {
+		if (params_old->dev)
+			dev_put(params_old->dev);
+		kfree_rcu(params_old, rcu);
+	}
 	if (ret == ACT_P_CREATED) {
 		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
@@ -153,6 +168,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
 	struct tcf_mirred *m = to_mirred(a);
+	struct tcf_mirred_params *params;
 	struct net_device *dev;
 	struct sk_buff *skb2;
 	int retval, err;
@@ -162,8 +178,9 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	bstats_cpu_update(this_cpu_ptr(m->common.cpu_bstats), skb);
 
 	rcu_read_lock();
-	retval = READ_ONCE(m->tcf_action);
-	dev = rcu_dereference(m->tcfm_dev);
+	params = rcu_dereference(m->params);
+	retval = params->action;
+	dev = params->dev;
 	if (unlikely(!dev)) {
 		pr_notice_once("tc mirred: target device is gone\n");
 		goto out;
@@ -181,12 +198,12 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		goto out;
 
 	if (!(at & AT_EGRESS)) {
-		if (m->tcfm_ok_push)
+		if (params->ok_push)
 			skb_push_rcsum(skb2, skb->mac_len);
 	}
 
 	/* mirror is always swallowed */
-	if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+	if (params->eaction != TCA_EGRESS_MIRROR)
 		skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
 
 	skb2->skb_iif = skb->dev->ifindex;
@@ -196,7 +213,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	if (err) {
 out:
 		qstats_overlimit_inc(this_cpu_ptr(m->common.cpu_qstats));
-		if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+		if (params->eaction != TCA_EGRESS_MIRROR)
 			retval = TC_ACT_SHOT;
 	}
 	rcu_read_unlock();
@@ -257,12 +274,15 @@ static int mirred_device_event(struct notifier_block *unused,
 	if (event == NETDEV_UNREGISTER) {
 		spin_lock_bh(&mirred_list_lock);
 		list_for_each_entry(m, &mirred_list, tcfm_list) {
-			if (rcu_access_pointer(m->tcfm_dev) == dev) {
+			struct tcf_mirred_params *params;
+
+			params = rtnl_dereference(m->params);
+			if (params->dev == dev) {
 				dev_put(dev);
 				/* Note : no rcu grace period necessary, as
 				 * net_device are already rcu protected.
 				 */
-				RCU_INIT_POINTER(m->tcfm_dev, NULL);
+				params->dev = NULL;
 			}
 		}
 		spin_unlock_bh(&mirred_list_lock);
