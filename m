From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/4] net_sched: mirred: remove action when the target device is gone
Date: Wed, 18 Dec 2013 16:36:42 -0800
Message-ID: <1387413403-6395-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:40797 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3LSAg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:36:59 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so385932pbc.39
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:36:58 -0800 (PST)
In-Reply-To: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the target device is removed, the mirred action is
still there but with the dev pointer setting to NULL.
This makes the output from 'tc filter' ugly. There is no
reason to keep it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tc_act/tc_mirred.h |  1 +
 net/sched/act_mirred.c         | 27 ++++++++++++++++++---------
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index cfe2943..374be24 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -10,6 +10,7 @@ struct tcf_mirred {
 	int			tcfm_ok_push;
 	struct net_device	*tcfm_dev;
 	struct list_head	tcfm_list;
+	struct tc_action	*tcfm_act;
 };
 #define to_mirred(pc) \
 	container_of(pc, struct tcf_mirred, common)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index a6a0af9..33a4893 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -128,6 +128,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev_hold(dev);
 		m->tcfm_dev = dev;
 		m->tcfm_ok_push = ok_push;
+		m->tcfm_act = a;
 	}
 	spin_unlock_bh(&m->tcf_lock);
 	if (ret == ACT_P_CREATED) {
@@ -161,10 +162,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&m->tcf_bstats, skb);
 
 	dev = m->tcfm_dev;
-	if (!dev) {
-		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
-		goto out;
-	}
 
 	if (!(dev->flags & IFF_UP)) {
 		net_notice_ratelimited("tc mirred to Houston: device %s is down\n",
@@ -236,15 +233,27 @@ static int mirred_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct tcf_mirred *m;
+	struct tcf_mirred *m, *tmp;
 
-	if (event == NETDEV_UNREGISTER)
-		list_for_each_entry(m, &mirred_list, tcfm_list) {
+	if (event == NETDEV_UNREGISTER) {
+		list_for_each_entry_safe(m, tmp, &mirred_list, tcfm_list) {
 			if (m->tcfm_dev == dev) {
-				dev_put(dev);
-				m->tcfm_dev = NULL;
+				struct tcf_common *p = NULL;
+				u32 index = m->common.tcfc_index;
+
+				list_del(&m->tcfm_act->list);
+				while ((p = tcf_hash_lookup(index, &mirred_hash_info)) != NULL) {
+					list_del_init(&m->tcfm_list);
+					if (m->tcfm_dev) {
+						dev_put(m->tcfm_dev);
+						m->tcfm_dev = NULL;
+					}
+					tcf_hash_destroy(p, &mirred_hash_info);
+				}
+				kfree(m->tcfm_act);
 			}
 		}
+	}
 
 	return NOTIFY_DONE;
 }
-- 
1.8.3.1
