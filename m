From: Chris Mi <chrism@mellanox.com>
Subject: [patch net v2 2/4] net/sched: Use action array instead of action list as parameter
Date: Mon, 16 Oct 2017 07:18:36 -0400
Message-ID: <1508152718-28726-3-git-send-email-chrism@mellanox.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, lucasb@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39076 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751501AbdJPLS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 07:18:56 -0400
In-Reply-To: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When destroying filters, actions should be destroyed first.
The pointers of each action are saved in an array. TC doesn't
use the array directly, but put all actions in a doubly linked
list and use that list as parameter.

There is no problem if each filter has its own actions. But if
some filters share the same action, when these filters are
destroyed, RCU callback fl_destroy_filter() may be called at the
same time. That means the same action's 'struct list_head list'
could be manipulated at the same time. It may point to an invalid
address so that system will panic.

This patch uses the action array directly to fix this issue.

Fixes commit in pre-git era.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chris Mi <chrism@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h |   7 ++--
 net/sched/act_api.c   | 103 +++++++++++++++++++++++++++++++-------------------
 net/sched/cls_api.c   |  18 +++------
 3 files changed, 75 insertions(+), 53 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index a469ab6..081a313 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -148,16 +148,17 @@ static inline int tcf_idr_release(struct tc_action *a, bool bind)
 int tcf_register_action(struct tc_action_ops *a, struct pernet_operations *ops);
 int tcf_unregister_action(struct tc_action_ops *a,
 			  struct pernet_operations *ops);
-int tcf_action_destroy(struct list_head *actions, int bind);
+int tcf_action_destroy(struct tc_action **actions, int nr, int bind);
 int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		    int nr_actions, struct tcf_result *res);
 int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
 		    struct nlattr *est, char *name, int ovr, int bind,
-		    struct list_head *actions);
+		    struct tc_action **actions, int *nr);
 struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
 				    struct nlattr *nla, struct nlattr *est,
 				    char *name, int ovr, int bind);
-int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
+int tcf_action_dump(struct sk_buff *skb, struct tc_action **actions, int nr,
+		    int bind, int ref);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 9c0224d..391d560 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -513,13 +513,15 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 }
 EXPORT_SYMBOL(tcf_action_exec);
 
-int tcf_action_destroy(struct list_head *actions, int bind)
+int tcf_action_destroy(struct tc_action **actions, int nr, int bind)
 {
 	const struct tc_action_ops *ops;
-	struct tc_action *a, *tmp;
+	struct tc_action *a;
 	int ret = 0;
+	int i;
 
-	list_for_each_entry_safe(a, tmp, actions, list) {
+	for (i = 0; i < nr; i++) {
+		a = actions[i];
 		ops = a->ops;
 		ret = __tcf_idr_release(a, bind, true);
 		if (ret == ACT_P_DELETED)
@@ -568,14 +570,16 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 }
 EXPORT_SYMBOL(tcf_action_dump_1);
 
-int tcf_action_dump(struct sk_buff *skb, struct list_head *actions,
+int tcf_action_dump(struct sk_buff *skb, struct tc_action **actions, int nr,
 		    int bind, int ref)
 {
 	struct tc_action *a;
-	int err = -EINVAL;
 	struct nlattr *nest;
+	int err = -EINVAL;
+	int i;
 
-	list_for_each_entry(a, actions, list) {
+	for (i = 0; i < nr; i++) {
+		a = actions[i];
 		nest = nla_nest_start(skb, a->order);
 		if (nest == NULL)
 			goto nla_put_failure;
@@ -700,10 +704,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
 	if (TC_ACT_EXT_CMP(a->tcfa_action, TC_ACT_GOTO_CHAIN)) {
 		err = tcf_action_goto_chain_init(a, tp);
 		if (err) {
-			LIST_HEAD(actions);
-
-			list_add_tail(&a->list, &actions);
-			tcf_action_destroy(&actions, bind);
+			tcf_action_destroy(&a, 1, bind);
 			return ERR_PTR(err);
 		}
 	}
@@ -720,23 +721,27 @@ struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
 	return ERR_PTR(err);
 }
 
-static void cleanup_a(struct list_head *actions, int ovr)
+static void cleanup_a(struct tc_action **actions, int nr, int ovr)
 {
 	struct tc_action *a;
+	int i;
 
 	if (!ovr)
 		return;
 
-	list_for_each_entry(a, actions, list)
+	for (i = 0; i < nr; i++) {
+		a = actions[i];
 		atomic_dec(&a->tcfa_refcnt);
+	}
 }
 
 int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
 		    struct nlattr *est, char *name, int ovr, int bind,
-		    struct list_head *actions)
+		    struct tc_action **actions, int *nr)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *act;
+	int n = 0;
 	int err;
 	int i;
 
@@ -753,17 +758,19 @@ int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
 		act->order = i;
 		if (ovr)
 			atomic_inc(&act->tcfa_refcnt);
-		list_add_tail(&act->list, actions);
+		actions[n++] = act;
 	}
+	*nr = n;
 
 	/* Remove the temp refcnt which was necessary to protect against
 	 * destroying an existing action which was being replaced
 	 */
-	cleanup_a(actions, ovr);
+	cleanup_a(actions, n, ovr);
 	return 0;
 
 err:
-	tcf_action_destroy(actions, bind);
+	tcf_action_destroy(actions, n, bind);
+	*nr = 0;
 	return err;
 }
 
@@ -811,9 +818,9 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *p,
 	return -1;
 }
 
-static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
-			u32 portid, u32 seq, u16 flags, int event, int bind,
-			int ref)
+static int tca_get_fill(struct sk_buff *skb, struct tc_action **actions,
+			int nr, u32 portid, u32 seq, u16 flags, int event,
+			int bind, int ref)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
@@ -832,7 +839,7 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
 	if (nest == NULL)
 		goto out_nlmsg_trim;
 
-	if (tcf_action_dump(skb, actions, bind, ref) < 0)
+	if (tcf_action_dump(skb, actions, nr, bind, ref) < 0)
 		goto out_nlmsg_trim;
 
 	nla_nest_end(skb, nest);
@@ -847,14 +854,14 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
 
 static int
 tcf_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
-	       struct list_head *actions, int event)
+	       struct tc_action **actions, int nr, int event)
 {
 	struct sk_buff *skb;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
-	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, event,
+	if (tca_get_fill(skb, actions, nr, portid, n->nlmsg_seq, 0, event,
 			 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -968,7 +975,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 }
 
 static int
-tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
+tcf_del_notify(struct net *net, struct nlmsghdr *n,
+	       struct tc_action **actions, int nr,
 	       u32 portid)
 {
 	int ret;
@@ -978,14 +986,14 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, 0, RTM_DELACTION,
-			 0, 1) <= 0) {
+	if (tca_get_fill(skb, actions, nr, portid, n->nlmsg_seq, 0,
+			 RTM_DELACTION, 0, 1) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
 
 	/* now do the delete */
-	ret = tcf_action_destroy(actions, 0);
+	ret = tcf_action_destroy(actions, nr, 0);
 	if (ret < 0) {
 		kfree_skb(skb);
 		return ret;
@@ -1002,10 +1010,11 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	      u32 portid, int event)
 {
-	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
+	struct tc_action **actions;
 	struct tc_action *act;
-	LIST_HEAD(actions);
+	int i, ret;
+	int nr = 0;
 
 	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL, NULL);
 	if (ret < 0)
@@ -1018,6 +1027,11 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 			return -EINVAL;
 	}
 
+	actions = kcalloc(TCA_ACT_MAX_PRIO, sizeof(struct tc_action *),
+			  GFP_KERNEL);
+	if (!actions)
+		return -ENOMEM;
+
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_get_1(net, tb[i], n, portid);
 		if (IS_ERR(act)) {
@@ -1025,25 +1039,28 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 			goto err;
 		}
 		act->order = i;
-		list_add_tail(&act->list, &actions);
+		actions[nr++] = act;
 	}
 
 	if (event == RTM_GETACTION)
-		ret = tcf_get_notify(net, portid, n, &actions, event);
+		ret = tcf_get_notify(net, portid, n, actions, nr, event);
 	else { /* delete */
-		ret = tcf_del_notify(net, n, &actions, portid);
+		ret = tcf_del_notify(net, n, actions, nr, portid);
 		if (ret)
 			goto err;
+		kfree(actions);
 		return ret;
 	}
 err:
 	if (event != RTM_GETACTION)
-		tcf_action_destroy(&actions, 0);
+		tcf_action_destroy(actions, nr, 0);
+	kfree(actions);
 	return ret;
 }
 
 static int
-tcf_add_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
+tcf_add_notify(struct net *net, struct nlmsghdr *n,
+	       struct tc_action **actions, int nr,
 	       u32 portid)
 {
 	struct sk_buff *skb;
@@ -1053,7 +1070,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tca_get_fill(skb, actions, portid, n->nlmsg_seq, n->nlmsg_flags,
+	if (tca_get_fill(skb, actions, nr, portid, n->nlmsg_seq, n->nlmsg_flags,
 			 RTM_NEWACTION, 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
@@ -1069,14 +1086,24 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 static int tcf_action_add(struct net *net, struct nlattr *nla,
 			  struct nlmsghdr *n, u32 portid, int ovr)
 {
+	struct tc_action **actions;
 	int ret = 0;
-	LIST_HEAD(actions);
+	int nr;
 
-	ret = tcf_action_init(net, NULL, nla, NULL, NULL, ovr, 0, &actions);
+	actions = kcalloc(TCA_ACT_MAX_PRIO, sizeof(struct tc_action *),
+			  GFP_KERNEL);
+	if (!actions)
+		return -ENOMEM;
+
+	ret = tcf_action_init(net, NULL, nla, NULL, NULL, ovr, 0,
+			      actions, &nr);
 	if (ret)
-		return ret;
+		goto out;
 
-	return tcf_add_notify(net, n, &actions, portid);
+	ret = tcf_add_notify(net, n, actions, nr, portid);
+out:
+	kfree(actions);
+	return ret;
 }
 
 static u32 tcaa_root_flags_allowed = TCA_FLAG_LARGE_DUMP_ON;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0b2219a..acaa0c6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -879,8 +879,7 @@ void tcf_exts_destroy(struct tcf_exts *exts)
 #ifdef CONFIG_NET_CLS_ACT
 	LIST_HEAD(actions);
 
-	tcf_exts_to_list(exts, &actions);
-	tcf_action_destroy(&actions, TCA_ACT_UNBIND);
+	tcf_action_destroy(exts->actions, exts->nr_actions, TCA_ACT_UNBIND);
 	kfree(exts->actions);
 	exts->nr_actions = 0;
 #endif
@@ -905,17 +904,14 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			exts->actions[0] = act;
 			exts->nr_actions = 1;
 		} else if (exts->action && tb[exts->action]) {
-			LIST_HEAD(actions);
-			int err, i = 0;
+			int err;
 
 			err = tcf_action_init(net, tp, tb[exts->action],
 					      rate_tlv, NULL, ovr, TCA_ACT_BIND,
-					      &actions);
+					      exts->actions,
+					      &exts->nr_actions);
 			if (err)
 				return err;
-			list_for_each_entry(act, &actions, list)
-				exts->actions[i++] = act;
-			exts->nr_actions = i;
 		}
 	}
 #else
@@ -961,14 +957,12 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 		 * tc data even if iproute2  was newer - jhs
 		 */
 		if (exts->type != TCA_OLD_COMPAT) {
-			LIST_HEAD(actions);
-
 			nest = nla_nest_start(skb, exts->action);
 			if (nest == NULL)
 				goto nla_put_failure;
 
-			tcf_exts_to_list(exts, &actions);
-			if (tcf_action_dump(skb, &actions, 0, 0) < 0)
+			if (tcf_action_dump(skb, exts->actions,
+					    exts->nr_actions, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
 		} else if (exts->police) {
-- 
1.8.3.1
