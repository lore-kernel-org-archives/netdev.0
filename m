From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 6/6] net_sched: switch to RCU API for act_mirred
Date: Thu,  1 Sep 2016 22:57:20 -0700
Message-ID: <1472795840-31901-7-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36190 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbcIBF5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:51 -0400
Received: by mail-pf0-f194.google.com with SMTP id a143so2068123pfa.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:51 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6038c85..90a024c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -60,6 +60,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
+	struct tc_action *n;
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
 	struct net_device *dev;
@@ -108,44 +109,40 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			ok_push = 1;
 			break;
 		}
-	} else {
-		dev = NULL;
+	} else if (!exists) {
+		return -EINVAL;
+	}
+
+	if (exists && !ovr) {
+		tcf_hash_release(*a, bind);
+		return -EEXIST;
 	}
 
-	if (!exists) {
-		if (dev == NULL)
-			return -EINVAL;
-		ret = tcf_hash_create(tn, parm->index, est, a,
-				      &act_mirred_ops, bind, true);
-		if (ret)
-			return ret;
-		ret = ACT_P_CREATED;
-	} else {
+	ret = tcf_hash_create(tn, parm->index, est, &n,
+			      &act_mirred_ops, bind, true);
+	if (ret) {
 		tcf_hash_release(*a, bind);
-		if (!ovr)
-			return -EEXIST;
+		return ret;
 	}
-	m = to_mirred(*a);
+
+	tcf_hash_copy(n, *a);
+	m = to_mirred(n);
 
 	ASSERT_RTNL();
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
 	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
-		if (ret != ACT_P_CREATED)
-			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
 		dev_hold(dev);
 		rcu_assign_pointer(m->tcfm_dev, dev);
 		m->tcfm_ok_push = ok_push;
 	}
 
-	if (ret == ACT_P_CREATED) {
-		spin_lock_bh(&mirred_list_lock);
-		list_add(&m->tcfm_list, &mirred_list);
-		spin_unlock_bh(&mirred_list_lock);
-		tcf_hash_insert(tn, *a);
-	}
+	spin_lock_bh(&mirred_list_lock);
+	list_add(&m->tcfm_list, &mirred_list);
+	spin_unlock_bh(&mirred_list_lock);
 
+	tcf_hash_replace(tn, a, n, bind);
 	return ret;
 }
 
-- 
2.1.0
