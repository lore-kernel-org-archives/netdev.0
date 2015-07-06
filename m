From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 7/7] net_sched: act_mirred: remove spinlock in fast path
Date: Mon,  6 Jul 2015 05:18:09 -0700
Message-ID: <1436185089-18268-8-git-send-email-edumazet@google.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33370 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbbGFMSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:18:42 -0400
Received: by igh16 with SMTP id 16so23109161igh.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:18:42 -0700 (PDT)
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like act_gact, act_mirred can be lockless in packet processing

1) Use percpu stats
2) update lastuse only every clock tick to avoid false sharing
3) use rcu to protect tcfm_dev
4) Remove spinlock usage, as it is no longer needed.

Next step : add multi queue capability to ifb device

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
---
 include/net/tc_act/tc_mirred.h |  2 +-
 net/sched/act_mirred.c         | 57 ++++++++++++++++++++++--------------------
 2 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 4dd77a1c106b..dae96bae1c19 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -8,7 +8,7 @@ struct tcf_mirred {
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
 	int			tcfm_ok_push;
-	struct net_device	*tcfm_dev;
+	struct net_device __rcu	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
 #define to_mirred(a) \
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 002cd6c83dc6..19cd8904efa0 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -35,9 +35,11 @@ static LIST_HEAD(mirred_list);
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
 	struct tcf_mirred *m = to_mirred(a);
+	struct net_device *dev = rcu_dereference_protected(m->tcfm_dev, 1);
+
 	list_del(&m->tcfm_list);
-	if (m->tcfm_dev)
-		dev_put(m->tcfm_dev);
+	if (dev)
+		dev_put(dev);
 }
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
@@ -94,7 +96,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		if (dev == NULL)
 			return -EINVAL;
 		ret = tcf_hash_create(parm->index, est, a, sizeof(*m),
-				      bind, false);
+				      bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -106,18 +108,18 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	}
 	m = to_mirred(a);
 
-	spin_lock_bh(&m->tcf_lock);
+	ASSERT_RTNL();
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
 	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
 		if (ret != ACT_P_CREATED)
-			dev_put(m->tcfm_dev);
+			dev_put(rcu_dereference_protected(m->tcfm_dev, 1));
 		dev_hold(dev);
-		m->tcfm_dev = dev;
+		rcu_assign_pointer(m->tcfm_dev, dev);
 		m->tcfm_ok_push = ok_push;
 	}
-	spin_unlock_bh(&m->tcf_lock);
+
 	if (ret == ACT_P_CREATED) {
 		list_add(&m->tcfm_list, &mirred_list);
 		tcf_hash_insert(a);
@@ -132,20 +134,22 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_mirred *m = a->priv;
 	struct net_device *dev;
 	struct sk_buff *skb2;
+	int retval, err;
 	u32 at;
-	int retval, err = 1;
 
-	spin_lock(&m->tcf_lock);
-	m->tcf_tm.lastuse = jiffies;
-	bstats_update(&m->tcf_bstats, skb);
+	tcf_lastuse_update(&m->tcf_tm);
+
+	bstats_cpu_update(this_cpu_ptr(m->common.cpu_bstats), skb);
 
-	dev = m->tcfm_dev;
-	if (!dev) {
-		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
+	rcu_read_lock();
+	retval = READ_ONCE(m->tcf_action);
+	dev = rcu_dereference(m->tcfm_dev);
+	if (unlikely(!dev)) {
+		pr_notice_once("tc mirred: target device is gone\n");
 		goto out;
 	}
 
-	if (!(dev->flags & IFF_UP)) {
+	if (unlikely(!(dev->flags & IFF_UP))) {
 		net_notice_ratelimited("tc mirred to Houston: device %s is down\n",
 				       dev->name);
 		goto out;
@@ -153,7 +157,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	at = G_TC_AT(skb->tc_verd);
 	skb2 = skb_clone(skb, GFP_ATOMIC);
-	if (skb2 == NULL)
+	if (!skb2)
 		goto out;
 
 	if (!(at & AT_EGRESS)) {
@@ -169,16 +173,13 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	skb2->dev = dev;
 	err = dev_queue_xmit(skb2);
 
-out:
 	if (err) {
-		m->tcf_qstats.overlimits++;
+out:
+		qstats_overlimit_inc(this_cpu_ptr(m->common.cpu_qstats));
 		if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
 			retval = TC_ACT_SHOT;
-		else
-			retval = m->tcf_action;
-	} else
-		retval = m->tcf_action;
-	spin_unlock(&m->tcf_lock);
+	}
+	rcu_read_unlock();
 
 	return retval;
 }
@@ -217,14 +218,16 @@ static int mirred_device_event(struct notifier_block *unused,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct tcf_mirred *m;
 
+	ASSERT_RTNL();
 	if (event == NETDEV_UNREGISTER)
 		list_for_each_entry(m, &mirred_list, tcfm_list) {
-			spin_lock_bh(&m->tcf_lock);
-			if (m->tcfm_dev == dev) {
+			if (rcu_access_pointer(m->tcfm_dev) == dev) {
 				dev_put(dev);
-				m->tcfm_dev = NULL;
+				/* Note : no rcu grace period necessary, as
+				 * net_device are already rcu protected.
+				 */
+				RCU_INIT_POINTER(m->tcfm_dev, NULL);
 			}
-			spin_unlock_bh(&m->tcf_lock);
 		}
 
 	return NOTIFY_DONE;
-- 
2.4.3.573.g4eafbef
