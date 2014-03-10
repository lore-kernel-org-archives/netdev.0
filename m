From: John Fastabend <john.fastabend@gmail.com>
Subject: [RCU PATCH 12/14] net: sched: make tc_action safe to walk under RCU
Date: Mon, 10 Mar 2014 10:08:16 -0700
Message-ID: <20140310170815.3011.31710.stgit@nitbit.x32>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:63504 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbaCJRIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:08:31 -0400
Received: by mail-oa0-f44.google.com with SMTP id n16so7312243oag.3
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:08:31 -0700 (PDT)
In-Reply-To: <20140310170008.3011.73599.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes tc_actions safe to walk from classifiers under RCU.
Notice that each action act() callback defined in each act_*.c
already does its own locking. This is needed even in the current
infrastructure for the case where users add/remove actions via
'tc actions' and reference them via index from the classifiers.

There are a couple interesting pieces here (i.e. need careful review)
In tcf_exts_exec() the call to tcf_action_exec follows a list_empty
check. However although this is occurring under RCU there is no
guarantee that the list is not empty when tcf_action_exec is called.
This patch fixes up return values from tcf_action_exec() so that
packets wont be dropped on the floor when this occurs. Hopefully
its rare and by using RCU we sort of make this assumption.

Second there is a suspect usage of list_splice_init_rcu() in the
tcf_exts_change() routine. Notice how it is used twice in succession
and the second init works on the src tcf_exts. There is probably a
better way to accomplish that.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/act_api.h |    1 +
 include/net/pkt_cls.h |   12 ++++++++++--
 net/sched/act_api.c   |   14 +++++++-------
 net/sched/cls_api.c   |   15 ++++++++-------
 4 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 3ee4c92..ddd0c5a 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -79,6 +79,7 @@ struct tc_action {
 	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32			order;
 	struct list_head	list;
+	struct rcu_head		rcu;
 };
 
 struct tc_action_ops {
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index a2441fb..9cfc8cb 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -63,7 +63,7 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
 	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
-	struct list_head actions;
+	struct list_head __rcu actions;
 #endif
 	/* Map to export classifier specific extension TLV types to the
 	 * generic extensions API. Unsupported extensions must be set to 0.
@@ -76,7 +76,7 @@ static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	exts->type = 0;
-	INIT_LIST_HEAD(&exts->actions);
+	INIT_LIST_HEAD_RCU(&exts->actions);
 #endif
 	exts->action = action;
 	exts->police = police;
@@ -88,6 +88,8 @@ static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
  *
  * Returns 1 if a predicative extension is present, i.e. an extension which
  * might cause further actions and thus overrule the regular tcf_result.
+ *
+ * This check is only valid if done under RTNL.
  */
 static inline int
 tcf_exts_is_predicative(struct tcf_exts *exts)
@@ -128,6 +130,12 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	       struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
+	/* This check is racy but this is OK, if the list is emptied
+	 * before walking the chain of actions the return value has
+	 * been updated to return zero. This way packets will not be
+	 * dropped when action list deletion occurs after the empty
+	 * check but before execution
+	 */ 
 	if (!list_empty(&exts->actions))
 		return tcf_action_exec(skb, &exts->actions, res);
 #endif
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8a5ba5a..d73a546 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -381,14 +381,14 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 		    struct tcf_result *res)
 {
 	const struct tc_action *a;
-	int ret = -1;
+	int ret = 0;
 
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
-	list_for_each_entry(a, actions, list) {
+	list_for_each_entry_rcu(a, actions, list) {
 repeat:
 		ret = a->ops->act(skb, a, res);
 		if (TC_MUNGED & skb->tc_verd) {
@@ -417,8 +417,8 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 			module_put(a->ops->owner);
 		else if (ret < 0)
 			return ret;
-		list_del(&a->list);
-		kfree(a);
+		list_del_rcu(&a->list);
+		kfree_rcu(a, rcu);
 	}
 	return ret;
 }
@@ -584,7 +584,7 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
 			goto err;
 		}
 		act->order = i;
-		list_add_tail(&act->list, actions);
+		list_add_tail_rcu(&act->list, actions);
 	}
 	return 0;
 
@@ -746,8 +746,8 @@ static void cleanup_a(struct list_head *actions)
 	struct tc_action *a, *tmp;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
-		list_del(&a->list);
-		kfree(a);
+		list_del_rcu(&a->list);
+		kfree_rcu(a, rcu);
 	}
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 4f0e25c..258506c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -497,7 +497,7 @@ void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	tcf_action_destroy(&exts->actions, TCA_ACT_UNBIND);
-	INIT_LIST_HEAD(&exts->actions);
+	INIT_LIST_HEAD_RCU(&exts->actions);
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
@@ -509,7 +509,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 	{
 		struct tc_action *act;
 
-		INIT_LIST_HEAD(&exts->actions);
+		INIT_LIST_HEAD_RCU(&exts->actions);
 		if (exts->police && tb[exts->police]) {
 			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
@@ -518,7 +518,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 				return PTR_ERR(act);
 
 			act->type = exts->type = TCA_OLD_COMPAT;
-			list_add(&act->list, &exts->actions);
+			list_add_rcu(&act->list, &exts->actions);
 		} else if (exts->action && tb[exts->action]) {
 			int err;
 			err = tcf_action_init(net, tb[exts->action], rate_tlv,
@@ -538,16 +538,17 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 }
 EXPORT_SYMBOL(tcf_exts_validate);
 
+/* It is not safe to use src->actions after this due to _init_rcu usage
+ * INIT_LIST_HEAD_RCU() is called on src->actions
+ */
 void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (!list_empty(&src->actions)) {
 		LIST_HEAD(tmp);
-		tcf_tree_lock(tp);
-		list_splice_init(&dst->actions, &tmp);
-		list_splice(&src->actions, &dst->actions);
-		tcf_tree_unlock(tp);
+		list_splice_init_rcu(&dst->actions, &tmp, synchronize_rcu);
+		list_splice_init_rcu(&src->actions, &dst->actions, synchronize_rcu);
 		tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 	}
 #endif
