From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/4] net_sched: mirred: notify user-space when action gets removed
Date: Wed, 18 Dec 2013 16:36:43 -0800
Message-ID: <1387413403-6395-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39858 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab3LSAhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:37:00 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so375373pde.20
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 16:37:00 -0800 (PST)
In-Reply-To: <1387413403-6395-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the mirred action gets removed on device unregister event,
we still need to notify the user-space via a netlink message.
This patch adjusts tcf_del_notify() so that it can be called
in device unregister event notification.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h  | 1 +
 net/sched/act_api.c    | 9 +++++----
 net/sched/act_mirred.c | 5 +++--
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 6b697c0..cd82656 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -133,5 +133,6 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
+int tcf_del_notify(struct net *, struct nlmsghdr *, struct list_head *, u32);
 #endif /* CONFIG_NET_CLS_ACT */
 #endif
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e619982..69bc29c 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -832,7 +832,7 @@ noflush_out:
 	return err;
 }
 
-static int
+int
 tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	       u32 portid)
 {
@@ -843,8 +843,8 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, RTM_DELACTION,
-			 0, 1) <= 0) {
+	if (tca_get_fill(skb, actions, portid, n ? n->nlmsg_seq : 0, 0,
+			 RTM_DELACTION, 0, 1) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -853,11 +853,12 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	tcf_action_destroy(actions, 0);
 
 	ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
-			     n->nlmsg_flags & NLM_F_ECHO);
+			     n ? (n->nlmsg_flags & NLM_F_ECHO) : 0);
 	if (ret > 0)
 		return 0;
 	return ret;
 }
+EXPORT_SYMBOL(tcf_del_notify);
 
 static int
 tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 33a4893..6bf5993 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -234,6 +234,7 @@ static int mirred_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct tcf_mirred *m, *tmp;
+	LIST_HEAD(local);
 
 	if (event == NETDEV_UNREGISTER) {
 		list_for_each_entry_safe(m, tmp, &mirred_list, tcfm_list) {
@@ -241,7 +242,7 @@ static int mirred_device_event(struct notifier_block *unused,
 				struct tcf_common *p = NULL;
 				u32 index = m->common.tcfc_index;
 
-				list_del(&m->tcfm_act->list);
+				list_move(&m->tcfm_act->list, &local);
 				while ((p = tcf_hash_lookup(index, &mirred_hash_info)) != NULL) {
 					list_del_init(&m->tcfm_list);
 					if (m->tcfm_dev) {
@@ -250,7 +251,7 @@ static int mirred_device_event(struct notifier_block *unused,
 					}
 					tcf_hash_destroy(p, &mirred_hash_info);
 				}
-				kfree(m->tcfm_act);
+				tcf_del_notify(dev_net(dev), NULL, &local, 0);
 			}
 		}
 	}
-- 
1.8.3.1
