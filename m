From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 5/5] net_sched: act: clean up tca_action_flush()
Date: Thu, 23 Jan 2014 14:35:25 -0800
Message-ID: <1390516525-8556-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:63420 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaAWWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:35:38 -0500
Received: by mail-pb0-f52.google.com with SMTP id jt11so2443180pbb.11
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 14:35:38 -0800 (PST)
In-Reply-To: <1390516525-8556-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could allocate tc_action on stack in tca_action_flush(),
since it is not large.

Also, we could use create_a() in tcf_action_get_1().

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 53 +++++++++++++++++++++++------------------------------
 1 file changed, 23 insertions(+), 30 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 4640ad3..38b0e36 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -677,6 +677,20 @@ act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 	return rtnl_unicast(skb, net, portid);
 }
 
+static struct tc_action *create_a(int i)
+{
+	struct tc_action *act;
+
+	act = kzalloc(sizeof(*act), GFP_KERNEL);
+	if (act == NULL) {
+		pr_debug("create_a: failed to alloc!\n");
+		return NULL;
+	}
+	act->order = i;
+	INIT_LIST_HEAD(&act->list);
+	return act;
+}
+
 static struct tc_action *
 tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 {
@@ -696,11 +710,10 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 	index = nla_get_u32(tb[TCA_ACT_INDEX]);
 
 	err = -ENOMEM;
-	a = kzalloc(sizeof(struct tc_action), GFP_KERNEL);
+	a = create_a(0);
 	if (a == NULL)
 		goto err_out;
 
-	INIT_LIST_HEAD(&a->list);
 	err = -EINVAL;
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
 	if (a->ops == NULL) /* could happen in batch of actions */
@@ -730,20 +743,6 @@ static void cleanup_a(struct list_head *actions)
 	}
 }
 
-static struct tc_action *create_a(int i)
-{
-	struct tc_action *act;
-
-	act = kzalloc(sizeof(*act), GFP_KERNEL);
-	if (act == NULL) {
-		pr_debug("create_a: failed to alloc!\n");
-		return NULL;
-	}
-	act->order = i;
-	INIT_LIST_HEAD(&act->list);
-	return act;
-}
-
 static int tca_action_flush(struct net *net, struct nlattr *nla,
 			    struct nlmsghdr *n, u32 portid)
 {
@@ -755,18 +754,12 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	struct nlattr *nest;
 	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct nlattr *kind;
-	struct tc_action *a = create_a(0);
+	struct tc_action a;
 	int err = -ENOMEM;
 
-	if (a == NULL) {
-		pr_debug("tca_action_flush: couldnt create tc_action\n");
-		return err;
-	}
-
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
 		pr_debug("tca_action_flush: failed skb alloc\n");
-		kfree(a);
 		return err;
 	}
 
@@ -778,8 +771,10 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	err = -EINVAL;
 	kind = tb[TCA_ACT_KIND];
-	a->ops = tc_lookup_action(kind);
-	if (a->ops == NULL) /*some idjot trying to flush unknown action */
+	memset(&a, 0, sizeof(struct tc_action));
+	INIT_LIST_HEAD(&a.list);
+	a.ops = tc_lookup_action(kind);
+	if (a.ops == NULL) /*some idjot trying to flush unknown action */
 		goto err_out;
 
 	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
@@ -794,7 +789,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (nest == NULL)
 		goto out_module_put;
 
-	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
+	err = a.ops->walk(skb, &dcb, RTM_DELACTION, &a);
 	if (err < 0)
 		goto out_module_put;
 	if (err == 0)
@@ -804,8 +799,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	nlh->nlmsg_flags |= NLM_F_ROOT;
-	module_put(a->ops->owner);
-	kfree(a);
+	module_put(a.ops->owner);
 	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			     n->nlmsg_flags & NLM_F_ECHO);
 	if (err > 0)
@@ -814,11 +808,10 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	return err;
 
 out_module_put:
-	module_put(a->ops->owner);
+	module_put(a.ops->owner);
 err_out:
 noflush_out:
 	kfree_skb(skb);
-	kfree(a);
 	return err;
 }
 
-- 
1.8.3.1
