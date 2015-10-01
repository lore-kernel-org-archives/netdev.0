From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] act_mirred: fix a race condition on mirred_list
Date: Thu,  1 Oct 2015 11:37:42 -0700
Message-ID: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35327 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066AbbJASiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 14:38:14 -0400
Received: by pacfv12 with SMTP id fv12so83609556pac.2
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 11:38:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1ce87720d456 ("net: sched: make cls_u32 lockless")
we began to release tc actions in a RCU callback. However,
mirred action relies on RTNL lock to protect the global
mirred_list, therefore we could have a race condition
between RCU callback and netdevice event, which caused
a list corruption as reported by Vinson.

Instead of relying on RTNL lock, introduce a spinlock to
protect this list.

Note, in non-bind case, it is still called with RTNL lock,
therefore should disable BH too.

Reported-by: Vinson Lee <vlee@twopensource.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 2d1be4a..3e7c51a 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -31,13 +31,17 @@
 
 #define MIRRED_TAB_MASK     7
 static LIST_HEAD(mirred_list);
+static DEFINE_SPINLOCK(mirred_list_lock);
 
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
 	struct net_device *dev = rcu_dereference_protected(m->tcfm_dev, 1);
 
+	/* We could be called either in a RCU callback or with RTNL lock held. */
+	spin_lock_bh(&mirred_list_lock);
 	list_del(&m->tcfm_list);
+	spin_unlock_bh(&mirred_list_lock);
 	if (dev)
 		dev_put(dev);
 }
@@ -123,7 +127,9 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED) {
+		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
+		spin_unlock_bh(&mirred_list_lock);
 		tcf_hash_insert(a);
 	}
 
@@ -221,7 +227,8 @@ static int mirred_device_event(struct notifier_block *unused,
 	struct tcf_mirred *m;
 
 	ASSERT_RTNL();
-	if (event == NETDEV_UNREGISTER)
+	if (event == NETDEV_UNREGISTER) {
+		spin_lock_bh(&mirred_list_lock);
 		list_for_each_entry(m, &mirred_list, tcfm_list) {
 			if (rcu_access_pointer(m->tcfm_dev) == dev) {
 				dev_put(dev);
@@ -231,6 +238,8 @@ static int mirred_device_event(struct notifier_block *unused,
 				RCU_INIT_POINTER(m->tcfm_dev, NULL);
 			}
 		}
+		spin_unlock_bh(&mirred_list_lock);
+	}
 
 	return NOTIFY_DONE;
 }
-- 
1.8.3.1
