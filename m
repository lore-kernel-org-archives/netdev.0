From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: close another race condition in tcf_mirred_release()
Date: Mon, 16 May 2016 15:11:18 -0700
Message-ID: <1463436678-20254-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35289 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbcEPWLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:11:31 -0400
Received: by mail-pa0-f52.google.com with SMTP id gj5so11078562pac.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 15:11:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We saw the following extra refcount release on veth device:

  kernel: [7957821.463992] unregister_netdevice: waiting for mesos50284 to become free. Usage count = -1

Since we heavily use mirred action to redirect packets to veth, I think
this is caused by the following race condition:

CPU0:
tcf_mirred_release(): (in RCU callback)
	struct net_device *dev = rcu_dereference_protected(m->tcfm_dev, 1);

CPU1:
mirred_device_event():
        spin_lock_bh(&mirred_list_lock);
        list_for_each_entry(m, &mirred_list, tcfm_list) {
                if (rcu_access_pointer(m->tcfm_dev) == dev) {
                        dev_put(dev);
                        /* Note : no rcu grace period necessary, as
                         * net_device are already rcu protected.
                         */
                        RCU_INIT_POINTER(m->tcfm_dev, NULL);
                }
        }
        spin_unlock_bh(&mirred_list_lock);

CPU0:
tcf_mirred_release():
        spin_lock_bh(&mirred_list_lock);
        list_del(&m->tcfm_list);
        spin_unlock_bh(&mirred_list_lock);
        if (dev)               // <======== Stil refers to the old m->tcfm_dev
                dev_put(dev);  // <======== dev_put() is called on it again

The action init code path is good because it is impossible to modify
an action that is being removed.

So, fix this by moving everything under the spinlock.

Fixes: 2ee22a90c7af ("net_sched: act_mirred: remove spinlock in fast path")
Fixes: 6bd00b850635 ("act_mirred: fix a race condition on mirred_list")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_mirred.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 8f3948d..78db6d4 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -36,14 +36,15 @@ static DEFINE_SPINLOCK(mirred_list_lock);
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
-	struct net_device *dev = rcu_dereference_protected(m->tcfm_dev, 1);
+	struct net_device *dev;
 
 	/* We could be called either in a RCU callback or with RTNL lock held. */
 	spin_lock_bh(&mirred_list_lock);
 	list_del(&m->tcfm_list);
-	spin_unlock_bh(&mirred_list_lock);
+	dev = rcu_dereference_protected(m->tcfm_dev, 1);
 	if (dev)
 		dev_put(dev);
+	spin_unlock_bh(&mirred_list_lock);
 }
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
-- 
2.1.0
