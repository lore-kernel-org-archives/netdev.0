From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v2 2/6] net_sched: act: use standard struct list_head
Date: Thu, 12 Dec 2013 20:56:40 -0800
Message-ID: <1386910604-1870-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:57430 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861Ab3LME5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 23:57:03 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so1856408pbb.14
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 20:57:03 -0800 (PST)
In-Reply-To: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently actions are chained by a singly linked list,
therefore it is a bit hard to add and remove a specific
entry. Convert it to struct list_head so that in the
latter patch we can remove an action without finding
its head.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  12 +++---
 include/net/pkt_cls.h   |  15 +++++--
 net/sched/act_api.c     | 105 +++++++++++++++++++++---------------------------
 net/sched/cls_api.c     |  54 ++++++++++++-------------
 net/sched/cls_basic.c   |   1 +
 net/sched/cls_bpf.c     |   1 +
 net/sched/cls_cgroup.c  |   1 +
 net/sched/cls_flow.c    |   1 +
 net/sched/cls_fw.c      |   1 +
 net/sched/cls_route.c   |   1 +
 net/sched/cls_rsvp.h    |   1 +
 net/sched/cls_tcindex.c |   5 ++-
 net/sched/cls_u32.c     |   1 +
 13 files changed, 100 insertions(+), 99 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 04c6825..ebaf4b5 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -60,7 +60,7 @@ struct tc_action {
 	const struct tc_action_ops	*ops;
 	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32			order;
-	struct tc_action	*next;
+	struct list_head	list;
 };
 
 #define TCA_CAP_NONE 0
@@ -99,16 +99,16 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 
 int tcf_register_action(struct tc_action_ops *a);
 int tcf_unregister_action(struct tc_action_ops *a);
-void tcf_action_destroy(struct tc_action *a, int bind);
-int tcf_action_exec(struct sk_buff *skb, const struct tc_action *a,
+void tcf_action_destroy(struct list_head *head, int bind);
+int tcf_action_exec(struct sk_buff *skb, const struct list_head *head,
 		    struct tcf_result *res);
-struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
+int tcf_action_init(struct net *net, struct nlattr *nla,
 				  struct nlattr *est, char *n, int ovr,
-				  int bind);
+				  int bind, struct list_head *);
 struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 				    struct nlattr *est, char *n, int ovr,
 				    int bind);
-int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
+int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2ebef77..a85264b 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -62,7 +62,8 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 
 struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
-	struct tc_action *action;
+	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
+	struct list_head head;
 #endif
 };
 
@@ -85,12 +86,18 @@ static inline int
 tcf_exts_is_predicative(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return !!exts->action;
+	return list_empty(&exts->head);
 #else
 	return 0;
 #endif
 }
 
+static inline void tcf_exts_init(struct tcf_exts *exts)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	INIT_LIST_HEAD(&exts->head);
+#endif
+}
 /**
  * tcf_exts_is_available - check if at least one extension is present
  * @exts: tc filter extensions handle
@@ -120,8 +127,8 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	       struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (exts->action)
-		return tcf_action_exec(skb, exts->action, res);
+	if (!list_empty(&exts->head))
+		return tcf_action_exec(skb, &exts->head, res);
 #endif
 	return 0;
 }
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 51e28f7..88b5087 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -379,7 +379,7 @@ static struct tc_action_ops *tc_lookup_action_id(u32 type)
 }
 #endif
 
-int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
+int tcf_action_exec(struct sk_buff *skb, const struct list_head *head,
 		    struct tcf_result *res)
 {
 	const struct tc_action *a;
@@ -390,7 +390,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct tc_action *act,
 		ret = TC_ACT_OK;
 		goto exec_done;
 	}
-	while ((a = act) != NULL) {
+	list_for_each_entry(a, head, list) {
 repeat:
 		if (a->ops) {
 			ret = a->ops->act(skb, a, res);
@@ -404,27 +404,26 @@ repeat:
 			if (ret != TC_ACT_PIPE)
 				goto exec_done;
 		}
-		act = a->next;
 	}
 exec_done:
 	return ret;
 }
 EXPORT_SYMBOL(tcf_action_exec);
 
-void tcf_action_destroy(struct tc_action *act, int bind)
+void tcf_action_destroy(struct list_head *head, int bind)
 {
-	struct tc_action *a;
+	struct tc_action *a, *tmp;
 
-	for (a = act; a; a = act) {
+	list_for_each_entry_safe(a, tmp, head, list) {
 		if (a->ops) {
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
-			act = act->next;
+			list_del(&a->list);
 			kfree(a);
 		} else {
 			/*FIXME: Remove later - catch insertion bugs*/
 			WARN(1, "tcf_action_destroy: BUG? destroying NULL ops\n");
-			act = act->next;
+			list_del(&a->list);
 			kfree(a);
 		}
 	}
@@ -470,14 +469,13 @@ nla_put_failure:
 EXPORT_SYMBOL(tcf_action_dump_1);
 
 int
-tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
+tcf_action_dump(struct sk_buff *skb, struct list_head *head, int bind, int ref)
 {
 	struct tc_action *a;
 	int err = -EINVAL;
 	struct nlattr *nest;
 
-	while ((a = act) != NULL) {
-		act = a->next;
+	list_for_each_entry(a, head, list) {
 		nest = nla_nest_start(skb, a->order);
 		if (nest == NULL)
 			goto nla_put_failure;
@@ -552,6 +550,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (a == NULL)
 		goto err_mod;
 
+	INIT_LIST_HEAD(&a->list);
 	/* backward compatibility for policer */
 	if (name == NULL)
 		err = a_o->init(net, tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
@@ -578,37 +577,33 @@ err_out:
 	return ERR_PTR(err);
 }
 
-struct tc_action *tcf_action_init(struct net *net, struct nlattr *nla,
+int tcf_action_init(struct net *net, struct nlattr *nla,
 				  struct nlattr *est, char *name, int ovr,
-				  int bind)
+				  int bind, struct list_head *head)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
-	struct tc_action *head = NULL, *act, *act_prev = NULL;
+	struct tc_action *act;
 	int err;
 	int i;
 
 	err = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
 	if (err < 0)
-		return ERR_PTR(err);
+		return err;
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);
-		if (IS_ERR(act))
+		if (IS_ERR(act)) {
+			err = PTR_ERR(act);
 			goto err;
+		}
 		act->order = i;
-
-		if (head == NULL)
-			head = act;
-		else
-			act_prev->next = act;
-		act_prev = act;
+		list_add_tail(&act->list, head);
 	}
-	return head;
+	return 0;
 
 err:
-	if (head != NULL)
-		tcf_action_destroy(head, bind);
-	return act;
+	tcf_action_destroy(head, bind);
+	return err;
 }
 
 int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
@@ -653,7 +648,7 @@ errout:
 }
 
 static int
-tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 portid, u32 seq,
+tca_get_fill(struct sk_buff *skb, struct list_head *head, u32 portid, u32 seq,
 	     u16 flags, int event, int bind, int ref)
 {
 	struct tcamsg *t;
@@ -673,7 +668,7 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 portid, u32 seq,
 	if (nest == NULL)
 		goto out_nlmsg_trim;
 
-	if (tcf_action_dump(skb, a, bind, ref) < 0)
+	if (tcf_action_dump(skb, head, bind, ref) < 0)
 		goto out_nlmsg_trim;
 
 	nla_nest_end(skb, nest);
@@ -688,14 +683,14 @@ out_nlmsg_trim:
 
 static int
 act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
-	       struct tc_action *a, int event)
+	       struct list_head *head, int event)
 {
 	struct sk_buff *skb;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
-	if (tca_get_fill(skb, a, portid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
+	if (tca_get_fill(skb, head, portid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -726,6 +721,7 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 	if (a == NULL)
 		goto err_out;
 
+	INIT_LIST_HEAD(&a->list);
 	err = -EINVAL;
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
 	if (a->ops == NULL)
@@ -745,12 +741,12 @@ err_out:
 	return ERR_PTR(err);
 }
 
-static void cleanup_a(struct tc_action *act)
+static void cleanup_a(struct list_head *head)
 {
-	struct tc_action *a;
+	struct tc_action *a, *tmp;
 
-	for (a = act; a; a = act) {
-		act = a->next;
+	list_for_each_entry_safe(a, tmp, head, list) {
+		list_del(&a->list);
 		kfree(a);
 	}
 }
@@ -765,6 +761,7 @@ static struct tc_action *create_a(int i)
 		return NULL;
 	}
 	act->order = i;
+	INIT_LIST_HEAD(&act->list);
 	return act;
 }
 
@@ -852,7 +849,8 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 {
 	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
-	struct tc_action *head = NULL, *act, *act_prev = NULL;
+	struct tc_action *act;
+	LIST_HEAD(head);
 
 	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
 	if (ret < 0)
@@ -872,16 +870,11 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 			goto err;
 		}
 		act->order = i;
-
-		if (head == NULL)
-			head = act;
-		else
-			act_prev->next = act;
-		act_prev = act;
+		list_add_tail(&act->list, &head);
 	}
 
 	if (event == RTM_GETACTION)
-		ret = act_get_notify(net, portid, n, head, event);
+		ret = act_get_notify(net, portid, n, &head, event);
 	else { /* delete */
 		struct sk_buff *skb;
 
@@ -891,7 +884,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 			goto err;
 		}
 
-		if (tca_get_fill(skb, head, portid, n->nlmsg_seq, 0, event,
+		if (tca_get_fill(skb, &head, portid, n->nlmsg_seq, 0, event,
 				 0, 1) <= 0) {
 			kfree_skb(skb);
 			ret = -EINVAL;
@@ -899,7 +892,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 		}
 
 		/* now do the delete */
-		tcf_action_destroy(head, 0);
+		tcf_action_destroy(&head, 0);
 		ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 				     n->nlmsg_flags & NLM_F_ECHO);
 		if (ret > 0)
@@ -907,11 +900,11 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 		return ret;
 	}
 err:
-	cleanup_a(head);
+	cleanup_a(&head);
 	return ret;
 }
 
-static int tcf_add_notify(struct net *net, struct tc_action *a,
+static int tcf_add_notify(struct net *net, struct list_head *head,
 			  u32 portid, u32 seq, int event, u16 flags)
 {
 	struct tcamsg *t;
@@ -939,7 +932,7 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 	if (nest == NULL)
 		goto out_kfree_skb;
 
-	if (tcf_action_dump(skb, a, 0, 0) < 0)
+	if (tcf_action_dump(skb, head, 0, 0) < 0)
 		goto out_kfree_skb;
 
 	nla_nest_end(skb, nest);
@@ -963,26 +956,18 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	       u32 portid, int ovr)
 {
 	int ret = 0;
-	struct tc_action *act;
-	struct tc_action *a;
+	LIST_HEAD(head);
 	u32 seq = n->nlmsg_seq;
 
-	act = tcf_action_init(net, nla, NULL, NULL, ovr, 0);
-	if (act == NULL)
-		goto done;
-	if (IS_ERR(act)) {
-		ret = PTR_ERR(act);
+	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &head);
+	if (ret)
 		goto done;
-	}
 
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
 	 */
-	ret = tcf_add_notify(net, act, portid, seq, RTM_NEWACTION, n->nlmsg_flags);
-	for (a = act; a; a = act) {
-		act = a->next;
-		kfree(a);
-	}
+	ret = tcf_add_notify(net, &head, portid, seq, RTM_NEWACTION, n->nlmsg_flags);
+	cleanup_a(&head);
 done:
 	return ret;
 }
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8e118af..7e5f296 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -500,10 +500,8 @@ out:
 void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (exts->action) {
-		tcf_action_destroy(exts->action, TCA_ACT_UNBIND);
-		exts->action = NULL;
-	}
+	tcf_action_destroy(&exts->head, TCA_ACT_UNBIND);
+	INIT_LIST_HEAD(&exts->head);
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
@@ -518,6 +516,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 	{
 		struct tc_action *act;
 
+		INIT_LIST_HEAD(&exts->head);
 		if (map->police && tb[map->police]) {
 			act = tcf_action_init_1(net, tb[map->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
@@ -525,16 +524,15 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
-			act->type = TCA_OLD_COMPAT;
-			exts->action = act;
+			act->type = exts->type = TCA_OLD_COMPAT;
+			list_add(&act->list, &exts->head);
 		} else if (map->action && tb[map->action]) {
-			act = tcf_action_init(net, tb[map->action], rate_tlv,
+			int err;
+			err = tcf_action_init(net, tb[map->action], rate_tlv,
 					      NULL, TCA_ACT_NOREPLACE,
-					      TCA_ACT_BIND);
-			if (IS_ERR(act))
-				return PTR_ERR(act);
-
-			exts->action = act;
+					      TCA_ACT_BIND, &exts->head);
+			if (err)
+				return err;
 		}
 	}
 #else
@@ -551,43 +549,45 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (src->action) {
-		struct tc_action *act;
+	if (!list_empty(&src->head)) {
+		LIST_HEAD(tmp);
 		tcf_tree_lock(tp);
-		act = dst->action;
-		dst->action = src->action;
+		list_splice_init(&dst->head, &tmp);
+		list_splice(&src->head, &dst->head);
 		tcf_tree_unlock(tp);
-		if (act)
-			tcf_action_destroy(act, TCA_ACT_UNBIND);
+		tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 	}
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_change);
 
+#define tcf_exts_first_act(ext) \
+		list_first_entry(&(exts)->head, struct tc_action, list)
+
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 		  const struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (map->action && exts->action) {
+	if (map->action && !list_empty(&exts->head)) {
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
 		struct nlattr *nest;
-
-		if (exts->action->type != TCA_OLD_COMPAT) {
+		if (exts->type != TCA_OLD_COMPAT) {
 			nest = nla_nest_start(skb, map->action);
 			if (nest == NULL)
 				goto nla_put_failure;
-			if (tcf_action_dump(skb, exts->action, 0, 0) < 0)
+			if (tcf_action_dump(skb, &exts->head, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
 		} else if (map->police) {
+			struct tc_action *act = tcf_exts_first_act(exts);
 			nest = nla_nest_start(skb, map->police);
 			if (nest == NULL)
 				goto nla_put_failure;
-			if (tcf_action_dump_old(skb, exts->action, 0, 0) < 0)
+			if (tcf_action_dump_old(skb, act, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
 		}
@@ -604,13 +604,11 @@ int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 			const struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (exts->action)
-		if (tcf_action_copy_stats(skb, exts->action, 1) < 0)
-			goto nla_put_failure;
+	struct tc_action *a = tcf_exts_first_act(exts);
+	if (tcf_action_copy_stats(skb, a, 1) < 0)
+		return -1;
 #endif
 	return 0;
-nla_put_failure: __attribute__ ((unused))
-	return -1;
 }
 EXPORT_SYMBOL(tcf_exts_dump_stats);
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 636d913..7b9b460 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -191,6 +191,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout;
 
+	tcf_exts_init(&f->exts);
 	err = -EINVAL;
 	if (handle)
 		f->handle = handle;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d7c72be..90fe275 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -271,6 +271,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (prog == NULL)
 		return -ENOBUFS;
 
+	tcf_exts_init(&prog->exts);
 	if (handle == 0)
 		prog->handle = cls_bpf_grab_new_handle(tp, head);
 	else
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 16006c9..e4fae03 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -203,6 +203,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		if (head == NULL)
 			return -ENOBUFS;
 
+		tcf_exts_init(&head->exts);
 		head->handle = handle;
 
 		tcf_tree_lock(tp);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 7881e2f..411e0d8 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -455,6 +455,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 
 		f->handle = handle;
 		f->mask	  = ~0U;
+		tcf_exts_init(&f->exts);
 
 		get_random_bytes(&f->hashrnd, 4);
 		f->perturb_timer.function = flow_perturbation;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 9b97172..d1cebad 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -280,6 +280,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		return -ENOBUFS;
 
+	tcf_exts_init(&f->exts);
 	f->id = handle;
 
 	err = fw_change_attrs(net, tp, f, tb, tca, base);
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 37da567..f1f1dfd 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -481,6 +481,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout;
 
+	tcf_exts_init(&f->exts);
 	err = route4_set_parms(net, tp, base, f, handle, head, tb,
 		tca[TCA_RATE], 1);
 	if (err < 0)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 252d8b0..b1d3ce5 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -471,6 +471,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout2;
 
+	tcf_exts_init(&f->exts);
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index b86535a..c39bbfc 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -215,11 +215,14 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 
 	memcpy(&cp, p, sizeof(cp));
 	memset(&new_filter_result, 0, sizeof(new_filter_result));
+	tcf_exts_init(&new_filter_result.exts);
 
 	if (old_r)
 		memcpy(&cr, r, sizeof(cr));
-	else
+	else {
 		memset(&cr, 0, sizeof(cr));
+		tcf_exts_init(&cr.exts);
+	}
 
 	if (tb[TCA_TCINDEX_HASH])
 		cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 59e546c..492d9a6 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -646,6 +646,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->ht_up = ht;
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
+	tcf_exts_init(&n->exts);
 
 #ifdef CONFIG_CLS_U32_MARK
 	if (tb[TCA_U32_MARK]) {
-- 
1.8.1.4
