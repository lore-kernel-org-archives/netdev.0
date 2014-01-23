From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 4/5] net_sched: act: refuse to remove bound action outside
Date: Thu, 23 Jan 2014 14:35:24 -0800
Message-ID: <1390516525-8556-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41511 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbaAWWfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:35:37 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so2460815pad.11
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 14:35:36 -0800 (PST)
In-Reply-To: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an action is bonnd to a filter, there is no point to
remove it outside. Currently we just silently decrease the refcnt,
we should reject this explicitly with EPERM.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  2 +-
 net/sched/act_api.c   | 26 ++++++++++++++++++++------
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 0974543..9f29706 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -109,7 +109,7 @@ void tcf_hash_insert(struct tc_action *a);
 
 int tcf_register_action(struct tc_action_ops *a, unsigned int mask);
 int tcf_unregister_action(struct tc_action_ops *a);
-void tcf_action_destroy(struct list_head *actions, int bind);
+int tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 		    struct tcf_result *res);
 int tcf_action_init(struct net *net, struct nlattr *nla,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index af4345c..4640ad3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -53,6 +53,8 @@ int tcf_hash_release(struct tc_action *a, int bind)
 	if (p) {
 		if (bind)
 			p->tcfc_bindcnt--;
+		else if (p->tcfc_bindcnt > 0)
+			return -EPERM;
 
 		p->tcfc_refcnt--;
 		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
@@ -123,6 +125,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 	struct tcf_common *p;
 	struct nlattr *nest;
 	int i = 0, n_i = 0;
+	int ret = -EINVAL;
 
 	nest = nla_nest_start(skb, a->order);
 	if (nest == NULL)
@@ -133,10 +136,12 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
 			a->priv = p;
-			if (ACT_P_DELETED == tcf_hash_release(a, 0)) {
+			ret = tcf_hash_release(a, 0);
+			if (ret == ACT_P_DELETED) {
 				module_put(a->ops->owner);
 				n_i++;
-			}
+			} else if (ret < 0)
+				goto nla_put_failure;
 		}
 	}
 	if (nla_put_u32(skb, TCA_FCNT, n_i))
@@ -146,7 +151,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 	return n_i;
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
-	return -EINVAL;
+	return ret;
 }
 
 static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
@@ -393,16 +398,21 @@ exec_done:
 }
 EXPORT_SYMBOL(tcf_action_exec);
 
-void tcf_action_destroy(struct list_head *actions, int bind)
+int tcf_action_destroy(struct list_head *actions, int bind)
 {
 	struct tc_action *a, *tmp;
+	int ret = 0;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
-		if (tcf_hash_release(a, bind) == ACT_P_DELETED)
+		ret = tcf_hash_release(a, bind);
+		if (ret == ACT_P_DELETED)
 			module_put(a->ops->owner);
+		else if (ret < 0)
+			return ret;
 		list_del(&a->list);
 		kfree(a);
 	}
+	return ret;
 }
 
 int
@@ -830,7 +840,11 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	}
 
 	/* now do the delete */
-	tcf_action_destroy(actions, 0);
+	ret = tcf_action_destroy(actions, 0);
+	if (ret < 0) {
+		kfree_skb(skb);
+		return ret;
+	}
 
 	ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			     n->nlmsg_flags & NLM_F_ECHO);
-- 
1.8.3.1
