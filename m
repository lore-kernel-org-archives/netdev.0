From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: add network namespace support for tc actions
Date: Fri, 19 Feb 2016 16:43:14 -0800
Message-ID: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35461 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1428903AbcBTAnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:43:51 -0500
Received: by mail-pf0-f182.google.com with SMTP id c10so61351725pfc.2
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 16:43:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tc actions are stored in a per-module hashtable,
therefore are visible to all network namespaces. This is
probably the last part of the tc subsystem which is not
aware of netns now. This patch makes them per-netns,
several tc action API's need to be adjusted for this.

The tc action API code is ugly due to historical reasons,
we need to refactor that code in the future.

Also this patch is on top of my other patch
"net_sched: fix memory leaks when rmmod tc action modules",
therefore should be applied after -net is merged into
net-next.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h    |  28 +++++---
 net/sched/act_api.c      |  88 ++++++++++-------------
 net/sched/act_bpf.c      |  71 +++++++++++++++++--
 net/sched/act_connmark.c |  73 +++++++++++++++++--
 net/sched/act_csum.c     |  78 +++++++++++++++++++--
 net/sched/act_gact.c     |  74 ++++++++++++++++++--
 net/sched/act_ipt.c      | 178 +++++++++++++++++++++++++++++++++++++++++++----
 net/sched/act_mirred.c   |  75 ++++++++++++++++++--
 net/sched/act_nat.c      |  73 +++++++++++++++++--
 net/sched/act_pedit.c    |  73 +++++++++++++++++--
 net/sched/act_police.c   |  69 ++++++++++++++++--
 net/sched/act_simple.c   |  76 ++++++++++++++++++--
 net/sched/act_skbedit.c  |  73 +++++++++++++++++--
 net/sched/act_vlan.c     |  73 +++++++++++++++++--
 14 files changed, 969 insertions(+), 133 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 8c4e3ff..af74406 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -7,6 +7,8 @@
 
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 struct tcf_common {
 	struct hlist_node		tcfc_head;
@@ -87,31 +89,36 @@ struct tc_action {
 	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32			order;
 	struct list_head	list;
+	struct tcf_hashinfo	*hinfo;
 };
 
 struct tc_action_ops {
 	struct list_head head;
-	struct tcf_hashinfo *hinfo;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	void	(*cleanup)(struct tc_action *, int bind);
-	int     (*lookup)(struct tc_action *, u32);
+	int     (*lookup)(struct net *, struct tc_action *, u32);
 	int     (*init)(struct net *net, struct nlattr *nla,
 			struct nlattr *est, struct tc_action *act, int ovr,
 			int bind);
-	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
+	int     (*walk)(struct net *, struct sk_buff *,
+			struct netlink_callback *, int, struct tc_action *);
 };
 
-int tcf_hash_search(struct tc_action *a, u32 index);
+int tcf_generic_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+		       struct netlink_callback *cb, int type,
+		       struct tc_action *a);
+int tcf_hash_search(struct tcf_hashinfo *hinfo, struct tc_action *a, u32 index);
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
-int tcf_hash_check(u32 index, struct tc_action *a, int bind);
-int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
-		    int size, int bind, bool cpustats);
+int tcf_hash_check(struct tcf_hashinfo *hinfo, u32 index, struct tc_action *a,
+		   int bind);
+int tcf_hash_create(struct tcf_hashinfo *hinfo, u32 index, struct nlattr *est,
+		    struct tc_action *a, int size, int bind, bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
-void tcf_hash_insert(struct tc_action *a);
+void tcf_hash_insert(struct tcf_hashinfo *hinfo, struct tc_action *a);
 
 int __tcf_hash_release(struct tc_action *a, bool bind, bool strict);
 
@@ -120,7 +127,10 @@ static inline int tcf_hash_release(struct tc_action *a, bool bind)
 	return __tcf_hash_release(a, bind, false);
 }
 
-int tcf_register_action(struct tc_action_ops *a, unsigned int mask);
+void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
+			  struct tcf_hashinfo *hinfo);
+
+int tcf_register_action(struct tc_action_ops *a);
 int tcf_unregister_action(struct tc_action_ops *a);
 int tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index acafaf7..ad3339c 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -36,10 +36,9 @@ static void free_tcf(struct rcu_head *head)
 	kfree(p);
 }
 
-static void tcf_hash_destroy(struct tc_action *a)
+static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfc_head);
@@ -68,7 +67,7 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
 			if (a->ops->cleanup)
 				a->ops->cleanup(a, bind);
-			tcf_hash_destroy(a);
+			tcf_hash_destroy(a->hinfo, a);
 			ret = ACT_P_DELETED;
 		}
 	}
@@ -77,10 +76,9 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 }
 EXPORT_SYMBOL(__tcf_hash_release);
 
-static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
-			   struct tc_action *a)
+static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+			   struct netlink_callback *cb, struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
@@ -126,9 +124,9 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 	goto done;
 }
 
-static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
+static int tcf_del_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+			  struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct hlist_head *head;
 	struct hlist_node *n;
 	struct tcf_common *p;
@@ -163,18 +161,22 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 	return ret;
 }
 
-static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
-			      int type, struct tc_action *a)
+int tcf_generic_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
+		       struct netlink_callback *cb, int type,
+		       struct tc_action *a)
 {
+	a->hinfo = hinfo;
+
 	if (type == RTM_DELACTION) {
-		return tcf_del_walker(skb, a);
+		return tcf_del_walker(hinfo, skb, a);
 	} else if (type == RTM_GETACTION) {
-		return tcf_dump_walker(skb, cb, a);
+		return tcf_dump_walker(hinfo, skb, cb, a);
 	} else {
 		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
 	}
 }
+EXPORT_SYMBOL(tcf_generic_walker);
 
 static struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
@@ -205,28 +207,29 @@ u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
-int tcf_hash_search(struct tc_action *a, u32 index)
+int tcf_hash_search(struct tcf_hashinfo *hinfo, struct tc_action *a, u32 index)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
 
 	if (p) {
 		a->priv = p;
+		a->hinfo = hinfo;
 		return 1;
 	}
 	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_search);
 
-int tcf_hash_check(u32 index, struct tc_action *a, int bind)
+int tcf_hash_check(struct tcf_hashinfo *hinfo, u32 index, struct tc_action *a,
+		   int bind)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = NULL;
 	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
 		if (bind)
 			p->tcfc_bindcnt++;
 		p->tcfc_refcnt++;
 		a->priv = p;
+		a->hinfo = hinfo;
 		return 1;
 	}
 	return 0;
@@ -243,10 +246,9 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 }
 EXPORT_SYMBOL(tcf_hash_cleanup);
 
-int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
-		    int size, int bind, bool cpustats)
+int tcf_hash_create(struct tcf_hashinfo *hinfo, u32 index, struct nlattr *est,
+		    struct tc_action *a, int size, int bind, bool cpustats)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 	int err = -ENOMEM;
 
@@ -286,14 +288,14 @@ int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 	}
 
 	a->priv = (void *) p;
+	a->hinfo = hinfo;
 	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_create);
 
-void tcf_hash_insert(struct tc_action *a)
+void tcf_hash_insert(struct tcf_hashinfo *hinfo, struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
 	spin_lock_bh(&hinfo->lock);
@@ -302,11 +304,12 @@ void tcf_hash_insert(struct tc_action *a)
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
-static void tcf_hashinfo_destroy(const struct tc_action_ops *ops)
+void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
+			  struct tcf_hashinfo *hinfo)
 {
-	struct tcf_hashinfo *hinfo = ops->hinfo;
 	struct tc_action a = {
 		.ops = ops,
+		.hinfo = hinfo,
 	};
 	int i;
 
@@ -327,40 +330,22 @@ static void tcf_hashinfo_destroy(const struct tc_action_ops *ops)
 	}
 	kfree(hinfo->htab);
 }
+EXPORT_SYMBOL(tcf_hashinfo_destroy);
 
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
 
-int tcf_register_action(struct tc_action_ops *act, unsigned int mask)
+int tcf_register_action(struct tc_action_ops *act)
 {
 	struct tc_action_ops *a;
-	int err;
 
-	/* Must supply act, dump and init */
-	if (!act->act || !act->dump || !act->init)
+	if (!act->act || !act->dump || !act->init || !act->walk || !act->lookup)
 		return -EINVAL;
 
-	/* Supply defaults */
-	if (!act->lookup)
-		act->lookup = tcf_hash_search;
-	if (!act->walk)
-		act->walk = tcf_generic_walker;
-
-	act->hinfo = kmalloc(sizeof(struct tcf_hashinfo), GFP_KERNEL);
-	if (!act->hinfo)
-		return -ENOMEM;
-	err = tcf_hashinfo_init(act->hinfo, mask);
-	if (err) {
-		kfree(act->hinfo);
-		return err;
-	}
-
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
-			tcf_hashinfo_destroy(act);
-			kfree(act->hinfo);
 			return -EEXIST;
 		}
 	}
@@ -379,8 +364,6 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
 			list_del(&act->head);
-			tcf_hashinfo_destroy(act);
-			kfree(act->hinfo);
 			err = 0;
 			break;
 		}
@@ -747,8 +730,8 @@ static struct tc_action *create_a(int i)
 	return act;
 }
 
-static struct tc_action *
-tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
+static struct tc_action *tcf_action_get_1(struct net *net, struct nlattr *nla,
+					  struct nlmsghdr *n, u32 portid)
 {
 	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct tc_action *a;
@@ -775,7 +758,7 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 	if (a->ops == NULL) /* could happen in batch of actions */
 		goto err_free;
 	err = -ENOENT;
-	if (a->ops->lookup(a, index) == 0)
+	if (a->ops->lookup(net, a, index) == 0)
 		goto err_mod;
 
 	module_put(a->ops->owner);
@@ -845,7 +828,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (nest == NULL)
 		goto out_module_put;
 
-	err = a.ops->walk(skb, &dcb, RTM_DELACTION, &a);
+	err = a.ops->walk(net, skb, &dcb, RTM_DELACTION, &a);
 	if (err < 0)
 		goto out_module_put;
 	if (err == 0)
@@ -923,7 +906,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	}
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_get_1(tb[i], n, portid);
+		act = tcf_action_get_1(net, tb[i], n, portid);
 		if (IS_ERR(act)) {
 			ret = PTR_ERR(act);
 			goto err;
@@ -1070,6 +1053,7 @@ find_dump_kind(const struct nlmsghdr *n)
 static int
 tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
@@ -1104,7 +1088,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (nest == NULL)
 		goto out_module_put;
 
-	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
+	ret = a_o->walk(net, skb, cb, RTM_GETACTION, &a);
 	if (ret < 0)
 		goto out_module_put;
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 0bc6f91..f04ef8c 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -33,6 +33,13 @@ struct tcf_bpf_cfg {
 	bool is_ebpf;
 };
 
+static int bpf_net_id;
+
+struct bpf_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		   struct tcf_result *res)
 {
@@ -275,6 +282,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 			struct nlattr *est, struct tc_action *act,
 			int replace, int bind)
 {
+	struct bpf_net *bn = net_generic(net, bpf_net_id);
 	struct nlattr *tb[TCA_ACT_BPF_MAX + 1];
 	struct tcf_bpf_cfg cfg, old;
 	struct tc_act_bpf *parm;
@@ -294,8 +302,8 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
 
-	if (!tcf_hash_check(parm->index, act, bind)) {
-		ret = tcf_hash_create(parm->index, est, act,
+	if (!tcf_hash_check(bn->hinfo, parm->index, act, bind)) {
+		ret = tcf_hash_create(bn->hinfo, parm->index, est, act,
 				      sizeof(*prog), bind, true);
 		if (ret < 0)
 			return ret;
@@ -344,7 +352,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	rcu_assign_pointer(prog->filter, cfg.filter);
 
 	if (res == ACT_P_CREATED) {
-		tcf_hash_insert(act);
+		tcf_hash_insert(bn->hinfo, act);
 	} else {
 		/* make sure the program being replaced is no longer executing */
 		synchronize_rcu();
@@ -367,6 +375,22 @@ static void tcf_bpf_cleanup(struct tc_action *act, int bind)
 	tcf_bpf_cfg_cleanup(&tmp);
 }
 
+static int tcf_bpf_walker(struct net *net, struct sk_buff *skb,
+			  struct netlink_callback *cb, int type,
+			  struct tc_action *a)
+{
+	struct bpf_net *bn = net_generic(net, bpf_net_id);
+
+	return tcf_generic_walker(bn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_bpf_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct bpf_net *bn = net_generic(net, bpf_net_id);
+
+	return tcf_hash_search(bn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_bpf_ops __read_mostly = {
 	.kind		=	"bpf",
 	.type		=	TCA_ACT_BPF,
@@ -375,16 +399,55 @@ static struct tc_action_ops act_bpf_ops __read_mostly = {
 	.dump		=	tcf_bpf_dump,
 	.cleanup	=	tcf_bpf_cleanup,
 	.init		=	tcf_bpf_init,
+	.walk		=	tcf_bpf_walker,
+	.lookup		=	tcf_bpf_search,
+};
+
+static __net_init int bpf_init_net(struct net *net)
+{
+	struct bpf_net *bn = net_generic(net, bpf_net_id);
+	int err;
+
+	bn->hinfo = kmalloc(sizeof(*bn->hinfo), GFP_KERNEL);
+	if (!bn->hinfo)
+		return -ENOMEM;
+	bn->ops = &act_bpf_ops;
+	err = tcf_hashinfo_init(bn->hinfo, BPF_TAB_MASK);
+	if (err) {
+		kfree(bn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit bpf_exit_net(struct net *net)
+{
+	struct bpf_net *bn = net_generic(net, bpf_net_id);
+
+	tcf_hashinfo_destroy(bn->ops, bn->hinfo);
+}
+
+static struct pernet_operations bpf_net_ops = {
+	.init = bpf_init_net,
+	.exit = bpf_exit_net,
+	.id   = &bpf_net_id,
+	.size = sizeof(struct bpf_net),
 };
 
 static int __init bpf_init_module(void)
 {
-	return tcf_register_action(&act_bpf_ops, BPF_TAB_MASK);
+	int err = register_pernet_subsys(&bpf_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_bpf_ops);
 }
 
 static void __exit bpf_cleanup_module(void)
 {
 	tcf_unregister_action(&act_bpf_ops);
+	unregister_pernet_subsys(&bpf_net_ops);
 }
 
 module_init(bpf_init_module);
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index bb41699..cc2e648 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -30,6 +30,13 @@
 
 #define CONNMARK_TAB_MASK     3
 
+static int connmark_net_id;
+
+struct connmark_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 			struct tcf_result *res)
 {
@@ -97,6 +104,7 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 			     struct nlattr *est, struct tc_action *a,
 			     int ovr, int bind)
 {
+	struct connmark_net *cn = net_generic(net, connmark_net_id);
 	struct nlattr *tb[TCA_CONNMARK_MAX + 1];
 	struct tcf_connmark_info *ci;
 	struct tc_connmark *parm;
@@ -111,9 +119,9 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_CONNMARK_PARMS]);
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*ci),
-				      bind, false);
+	if (!tcf_hash_check(cn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(cn->hinfo, parm->index, est, a,
+				      sizeof(*ci), bind, false);
 		if (ret)
 			return ret;
 
@@ -122,7 +130,7 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 		ci->net = net;
 		ci->zone = parm->zone;
 
-		tcf_hash_insert(a);
+		tcf_hash_insert(cn->hinfo, a);
 		ret = ACT_P_CREATED;
 	} else {
 		ci = to_connmark(a);
@@ -169,6 +177,22 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_connmark_walker(struct net *net, struct sk_buff *skb,
+			       struct netlink_callback *cb, int type,
+			       struct tc_action *a)
+{
+	struct connmark_net *cn = net_generic(net, connmark_net_id);
+
+	return tcf_generic_walker(cn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_connmark_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct connmark_net *cn = net_generic(net, connmark_net_id);
+
+	return tcf_hash_search(cn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_connmark_ops = {
 	.kind		=	"connmark",
 	.type		=	TCA_ACT_CONNMARK,
@@ -176,16 +200,55 @@ static struct tc_action_ops act_connmark_ops = {
 	.act		=	tcf_connmark,
 	.dump		=	tcf_connmark_dump,
 	.init		=	tcf_connmark_init,
+	.walk		=	tcf_connmark_walker,
+	.lookup		=	tcf_connmark_search,
+};
+
+static __net_init int connmark_init_net(struct net *net)
+{
+	struct connmark_net *cn = net_generic(net, connmark_net_id);
+	int err;
+
+	cn->hinfo = kmalloc(sizeof(*cn->hinfo), GFP_KERNEL);
+	if (!cn->hinfo)
+		return -ENOMEM;
+	cn->ops = &act_connmark_ops;
+	err = tcf_hashinfo_init(cn->hinfo, CONNMARK_TAB_MASK);
+	if (err) {
+		kfree(cn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit connmark_exit_net(struct net *net)
+{
+	struct connmark_net *cn = net_generic(net, connmark_net_id);
+
+	tcf_hashinfo_destroy(cn->ops, cn->hinfo);
+}
+
+static struct pernet_operations connmark_net_ops = {
+	.init = connmark_init_net,
+	.exit = connmark_exit_net,
+	.id   = &connmark_net_id,
+	.size = sizeof(struct connmark_net),
 };
 
 static int __init connmark_init_module(void)
 {
-	return tcf_register_action(&act_connmark_ops, CONNMARK_TAB_MASK);
+	int err = register_pernet_subsys(&connmark_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_connmark_ops);
 }
 
 static void __exit connmark_cleanup_module(void)
 {
 	tcf_unregister_action(&act_connmark_ops);
+	unregister_pernet_subsys(&connmark_net_ops);
 }
 
 module_init(connmark_init_module);
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index b07c535..71dbbfa 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -42,9 +42,18 @@ static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
 };
 
-static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
-			 struct tc_action *a, int ovr, int bind)
+static int csum_net_id;
+
+struct csum_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
+static int tcf_csum_init(struct net *net, struct nlattr *nla,
+			 struct nlattr *est, struct tc_action *a, int ovr,
+			 int bind)
 {
+	struct csum_net *cn = net_generic(net, csum_net_id);
 	struct nlattr *tb[TCA_CSUM_MAX + 1];
 	struct tc_csum *parm;
 	struct tcf_csum *p;
@@ -61,9 +70,9 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_CSUM_PARMS]);
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
-				      bind, false);
+	if (!tcf_hash_check(cn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(cn->hinfo, parm->index, est, a,
+				      sizeof(*p), bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -82,7 +91,7 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(cn->hinfo, a);
 
 	return ret;
 }
@@ -559,6 +568,22 @@ static int tcf_csum_dump(struct sk_buff *skb,
 	return -1;
 }
 
+static int tcf_csum_walker(struct net *net, struct sk_buff *skb,
+			   struct netlink_callback *cb, int type,
+			   struct tc_action *a)
+{
+	struct csum_net *cn = net_generic(net, csum_net_id);
+
+	return tcf_generic_walker(cn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_csum_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct csum_net *cn = net_generic(net, csum_net_id);
+
+	return tcf_hash_search(cn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_csum_ops = {
 	.kind		= "csum",
 	.type		= TCA_ACT_CSUM,
@@ -566,6 +591,40 @@ static struct tc_action_ops act_csum_ops = {
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
 	.init		= tcf_csum_init,
+	.walk		= tcf_csum_walker,
+	.lookup		= tcf_csum_search,
+};
+
+static __net_init int csum_init_net(struct net *net)
+{
+	struct csum_net *cn = net_generic(net, csum_net_id);
+	int err;
+
+	cn->hinfo = kmalloc(sizeof(*cn->hinfo), GFP_KERNEL);
+	if (!cn->hinfo)
+		return -ENOMEM;
+	cn->ops = &act_csum_ops;
+	err = tcf_hashinfo_init(cn->hinfo, CSUM_TAB_MASK);
+	if (err) {
+		kfree(cn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit csum_exit_net(struct net *net)
+{
+	struct csum_net *cn = net_generic(net, csum_net_id);
+
+	tcf_hashinfo_destroy(cn->ops, cn->hinfo);
+}
+
+static struct pernet_operations csum_net_ops = {
+	.init = csum_init_net,
+	.exit = csum_exit_net,
+	.id   = &csum_net_id,
+	.size = sizeof(struct csum_net),
 };
 
 MODULE_DESCRIPTION("Checksum updating actions");
@@ -573,12 +632,17 @@ MODULE_LICENSE("GPL");
 
 static int __init csum_init_module(void)
 {
-	return tcf_register_action(&act_csum_ops, CSUM_TAB_MASK);
+	int err = register_pernet_subsys(&csum_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_csum_ops);
 }
 
 static void __exit csum_cleanup_module(void)
 {
 	tcf_unregister_action(&act_csum_ops);
+	unregister_pernet_subsys(&csum_net_ops);
 }
 
 module_init(csum_init_module);
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 5c1b051..4f59ed7 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -25,6 +25,13 @@
 
 #define GACT_TAB_MASK	15
 
+static int gact_net_id;
+
+struct gact_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
 {
@@ -57,6 +64,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 			 struct nlattr *est, struct tc_action *a,
 			 int ovr, int bind)
 {
+	struct gact_net *gn = net_generic(net, gact_net_id);
 	struct nlattr *tb[TCA_GACT_MAX + 1];
 	struct tc_gact *parm;
 	struct tcf_gact *gact;
@@ -88,9 +96,9 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*gact),
-				      bind, true);
+	if (!tcf_hash_check(gn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(gn->hinfo, parm->index, est, a,
+				      sizeof(*gact), bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -118,7 +126,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(gn->hinfo, a);
 	return ret;
 }
 
@@ -183,6 +191,22 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	return -1;
 }
 
+static int tcf_gact_walker(struct net *net, struct sk_buff *skb,
+			   struct netlink_callback *cb, int type,
+			   struct tc_action *a)
+{
+	struct gact_net *gn = net_generic(net, gact_net_id);
+
+	return tcf_generic_walker(gn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_gact_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct gact_net *gn = net_generic(net, gact_net_id);
+
+	return tcf_hash_search(gn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_gact_ops = {
 	.kind		=	"gact",
 	.type		=	TCA_ACT_GACT,
@@ -190,6 +214,40 @@ static struct tc_action_ops act_gact_ops = {
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
 	.init		=	tcf_gact_init,
+	.walk		=	tcf_gact_walker,
+	.lookup		=	tcf_gact_search,
+};
+
+static __net_init int gact_init_net(struct net *net)
+{
+	struct gact_net *gn = net_generic(net, gact_net_id);
+	int err;
+
+	gn->hinfo = kmalloc(sizeof(*gn->hinfo), GFP_KERNEL);
+	if (!gn->hinfo)
+		return -ENOMEM;
+	gn->ops = &act_gact_ops;
+	err = tcf_hashinfo_init(gn->hinfo, GACT_TAB_MASK);
+	if (err) {
+		kfree(gn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit gact_exit_net(struct net *net)
+{
+	struct gact_net *gn = net_generic(net, gact_net_id);
+
+	tcf_hashinfo_destroy(gn->ops, gn->hinfo);
+}
+
+static struct pernet_operations gact_net_ops = {
+	.init = gact_init_net,
+	.exit = gact_exit_net,
+	.id   = &gact_net_id,
+	.size = sizeof(struct gact_net),
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
@@ -198,17 +256,23 @@ MODULE_LICENSE("GPL");
 
 static int __init gact_init_module(void)
 {
+	int err;
 #ifdef CONFIG_GACT_PROB
 	pr_info("GACT probability on\n");
 #else
 	pr_info("GACT probability NOT on\n");
 #endif
-	return tcf_register_action(&act_gact_ops, GACT_TAB_MASK);
+
+	err = register_pernet_subsys(&gact_net_ops);
+	if (err)
+		return err;
+	return tcf_register_action(&act_gact_ops);
 }
 
 static void __exit gact_cleanup_module(void)
 {
 	tcf_unregister_action(&act_gact_ops);
+	unregister_pernet_subsys(&gact_net_ops);
 }
 
 module_init(gact_init_module);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d058696..c47c325 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -30,6 +30,20 @@
 
 #define IPT_TAB_MASK     15
 
+static int ipt_net_id;
+
+struct ipt_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
+static int xt_net_id;
+
+struct xt_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
 {
 	struct xt_tgchk_param par;
@@ -83,8 +97,9 @@ static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
 	[TCA_IPT_TARG]	= { .len = sizeof(struct xt_entry_target) },
 };
 
-static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
-			struct tc_action *a, int ovr, int bind)
+static int __tcf_ipt_init(struct tcf_hashinfo *hinfo, struct nlattr *nla,
+			  struct nlattr *est, struct tc_action *a, int ovr,
+			  int bind)
 {
 	struct nlattr *tb[TCA_IPT_MAX + 1];
 	struct tcf_ipt *ipt;
@@ -113,8 +128,9 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	if (tb[TCA_IPT_INDEX] != NULL)
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
-	if (!tcf_hash_check(index, a, bind) ) {
-		ret = tcf_hash_create(index, est, a, sizeof(*ipt), bind, false);
+	if (!tcf_hash_check(hinfo, index, a, bind)) {
+		ret = tcf_hash_create(hinfo, index, est, a, sizeof(*ipt), bind,
+				      false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -157,7 +173,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	ipt->tcfi_hook  = hook;
 	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(hinfo, a);
 	return ret;
 
 err3:
@@ -170,6 +186,24 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	return err;
 }
 
+static int tcf_ipt_init(struct net *net, struct nlattr *nla,
+			struct nlattr *est, struct tc_action *a, int ovr,
+			int bind)
+{
+	struct ipt_net *in = net_generic(net, xt_net_id);
+
+	return __tcf_ipt_init(in->hinfo, nla, est, a, ovr, bind);
+}
+
+static int tcf_xt_init(struct net *net, struct nlattr *nla,
+		       struct nlattr *est, struct tc_action *a, int ovr,
+		       int bind)
+{
+	struct xt_net *xn = net_generic(net, xt_net_id);
+
+	return __tcf_ipt_init(xn->hinfo, nla, est, a, ovr, bind);
+}
+
 static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
@@ -260,6 +294,22 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	return -1;
 }
 
+static int tcf_ipt_walker(struct net *net, struct sk_buff *skb,
+			  struct netlink_callback *cb, int type,
+			  struct tc_action *a)
+{
+	struct ipt_net *in = net_generic(net, ipt_net_id);
+
+	return tcf_generic_walker(in->hinfo, skb, cb, type, a);
+}
+
+static int tcf_ipt_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct ipt_net *in = net_generic(net, ipt_net_id);
+
+	return tcf_hash_search(in->hinfo, a, index);
+}
+
 static struct tc_action_ops act_ipt_ops = {
 	.kind		=	"ipt",
 	.type		=	TCA_ACT_IPT,
@@ -268,8 +318,58 @@ static struct tc_action_ops act_ipt_ops = {
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_release,
 	.init		=	tcf_ipt_init,
+	.walk		=	tcf_ipt_walker,
+	.lookup		=	tcf_ipt_search,
 };
 
+static __net_init int ipt_init_net(struct net *net)
+{
+	struct ipt_net *in = net_generic(net, ipt_net_id);
+	int err;
+
+	in->hinfo = kmalloc(sizeof(*in->hinfo), GFP_KERNEL);
+	if (!in->hinfo)
+		return -ENOMEM;
+	in->ops = &act_ipt_ops;
+	err = tcf_hashinfo_init(in->hinfo, IPT_TAB_MASK);
+	if (err) {
+		kfree(in->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit ipt_exit_net(struct net *net)
+{
+	struct ipt_net *in = net_generic(net, ipt_net_id);
+
+	tcf_hashinfo_destroy(in->ops, in->hinfo);
+}
+
+static struct pernet_operations ipt_net_ops = {
+	.init = ipt_init_net,
+	.exit = ipt_exit_net,
+	.id   = &ipt_net_id,
+	.size = sizeof(struct ipt_net),
+};
+
+static int tcf_xt_walker(struct net *net, struct sk_buff *skb,
+			 struct netlink_callback *cb, int type,
+			 struct tc_action *a)
+{
+	struct xt_net *xn = net_generic(net, xt_net_id);
+
+	return tcf_generic_walker(xn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_xt_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct xt_net *xn = net_generic(net, xt_net_id);
+
+	return tcf_hash_search(xn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_xt_ops = {
 	.kind		=	"xt",
 	.type		=	TCA_ACT_XT,
@@ -277,7 +377,41 @@ static struct tc_action_ops act_xt_ops = {
 	.act		=	tcf_ipt,
 	.dump		=	tcf_ipt_dump,
 	.cleanup	=	tcf_ipt_release,
-	.init		=	tcf_ipt_init,
+	.init		=	tcf_xt_init,
+	.walk		=	tcf_xt_walker,
+	.lookup		=	tcf_xt_search,
+};
+
+static __net_init int xt_init_net(struct net *net)
+{
+	struct xt_net *in = net_generic(net, xt_net_id);
+	int err;
+
+	in->hinfo = kmalloc(sizeof(*in->hinfo), GFP_KERNEL);
+	if (!in->hinfo)
+		return -ENOMEM;
+	in->ops = &act_xt_ops;
+	err = tcf_hashinfo_init(in->hinfo, IPT_TAB_MASK);
+	if (err) {
+		kfree(in->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit xt_exit_net(struct net *net)
+{
+	struct xt_net *in = net_generic(net, xt_net_id);
+
+	tcf_hashinfo_destroy(in->ops, in->hinfo);
+}
+
+static struct pernet_operations xt_net_ops = {
+	.init = xt_init_net,
+	.exit = xt_exit_net,
+	.id   = &xt_net_id,
+	.size = sizeof(struct xt_net),
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-13)");
@@ -289,12 +423,28 @@ static int __init ipt_init_module(void)
 {
 	int ret1, ret2;
 
-	ret1 = tcf_register_action(&act_xt_ops, IPT_TAB_MASK);
-	if (ret1 < 0)
-		printk("Failed to load xt action\n");
-	ret2 = tcf_register_action(&act_ipt_ops, IPT_TAB_MASK);
-	if (ret2 < 0)
-		printk("Failed to load ipt action\n");
+	ret1 = register_pernet_subsys(&xt_net_ops);
+	if (ret1)
+		return ret1;
+	ret1 = tcf_register_action(&act_xt_ops);
+	if (ret1 < 0) {
+		pr_err("Failed to load xt action\n");
+		unregister_pernet_subsys(&xt_net_ops);
+	}
+
+	ret2 = register_pernet_subsys(&ipt_net_ops);
+	if (ret2) {
+		tcf_unregister_action(&act_xt_ops);
+		unregister_pernet_subsys(&xt_net_ops);
+	}
+
+	ret2 = tcf_register_action(&act_ipt_ops);
+	if (ret2 < 0) {
+		pr_err("Failed to load ipt action\n");
+		unregister_pernet_subsys(&ipt_net_ops);
+		tcf_unregister_action(&act_xt_ops);
+		unregister_pernet_subsys(&xt_net_ops);
+	}
 
 	if (ret1 < 0 && ret2 < 0) {
 		return ret1;
@@ -304,8 +454,10 @@ static int __init ipt_init_module(void)
 
 static void __exit ipt_cleanup_module(void)
 {
-	tcf_unregister_action(&act_xt_ops);
 	tcf_unregister_action(&act_ipt_ops);
+	unregister_pernet_subsys(&ipt_net_ops);
+	tcf_unregister_action(&act_xt_ops);
+	unregister_pernet_subsys(&xt_net_ops);
 }
 
 module_init(ipt_init_module);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 32fcdec..10c4c5c0 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -50,10 +50,18 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
 };
 
+static int mirred_net_id;
+
+struct mirred_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 			   struct nlattr *est, struct tc_action *a, int ovr,
 			   int bind)
 {
+	struct mirred_net *mn = net_generic(net, mirred_net_id);
 	struct nlattr *tb[TCA_MIRRED_MAX + 1];
 	struct tc_mirred *parm;
 	struct tcf_mirred *m;
@@ -96,11 +104,11 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev = NULL;
 	}
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
+	if (!tcf_hash_check(mn->hinfo, parm->index, a, bind)) {
 		if (dev == NULL)
 			return -EINVAL;
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*m),
-				      bind, true);
+		ret = tcf_hash_create(mn->hinfo, parm->index, est, a,
+				      sizeof(*m), bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -130,7 +138,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
 		spin_unlock_bh(&mirred_list_lock);
-		tcf_hash_insert(a);
+		tcf_hash_insert(mn->hinfo, a);
 	}
 
 	return ret;
@@ -221,6 +229,22 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	return -1;
 }
 
+static int tcf_mirred_walker(struct net *net, struct sk_buff *skb,
+			     struct netlink_callback *cb, int type,
+			     struct tc_action *a)
+{
+	struct mirred_net *mn = net_generic(net, mirred_net_id);
+
+	return tcf_generic_walker(mn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_mirred_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct mirred_net *mn = net_generic(net, mirred_net_id);
+
+	return tcf_hash_search(mn->hinfo, a, index);
+}
+
 static int mirred_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
@@ -257,6 +281,40 @@ static struct tc_action_ops act_mirred_ops = {
 	.dump		=	tcf_mirred_dump,
 	.cleanup	=	tcf_mirred_release,
 	.init		=	tcf_mirred_init,
+	.walk		=	tcf_mirred_walker,
+	.lookup		=	tcf_mirred_search,
+};
+
+static __net_init int mirred_init_net(struct net *net)
+{
+	struct mirred_net *mn = net_generic(net, mirred_net_id);
+	int err;
+
+	mn->hinfo = kmalloc(sizeof(*mn->hinfo), GFP_KERNEL);
+	if (!mn->hinfo)
+		return -ENOMEM;
+	mn->ops = &act_mirred_ops;
+	err = tcf_hashinfo_init(mn->hinfo, MIRRED_TAB_MASK);
+	if (err) {
+		kfree(mn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit mirred_exit_net(struct net *net)
+{
+	struct mirred_net *mn = net_generic(net, mirred_net_id);
+
+	tcf_hashinfo_destroy(mn->ops, mn->hinfo);
+}
+
+static struct pernet_operations mirred_net_ops = {
+	.init = mirred_init_net,
+	.exit = mirred_exit_net,
+	.id   = &mirred_net_id,
+	.size = sizeof(struct mirred_net),
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002)");
@@ -269,13 +327,20 @@ static int __init mirred_init_module(void)
 	if (err)
 		return err;
 
+	err = register_pernet_subsys(&mirred_net_ops);
+	if (err) {
+		unregister_netdevice_notifier(&mirred_device_notifier);
+		return err;
+	}
+
 	pr_info("Mirror/redirect action on\n");
-	return tcf_register_action(&act_mirred_ops, MIRRED_TAB_MASK);
+	return tcf_register_action(&act_mirred_ops);
 }
 
 static void __exit mirred_cleanup_module(void)
 {
 	tcf_unregister_action(&act_mirred_ops);
+	unregister_pernet_subsys(&mirred_net_ops);
 	unregister_netdevice_notifier(&mirred_device_notifier);
 }
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index b7c4ead..f590eb6 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -31,6 +31,13 @@
 
 #define NAT_TAB_MASK	15
 
+static int nat_net_id;
+
+struct nat_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
 };
@@ -38,6 +45,7 @@ static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
+	struct nat_net *nn = net_generic(net, nat_net_id);
 	struct nlattr *tb[TCA_NAT_MAX + 1];
 	struct tc_nat *parm;
 	int ret = 0, err;
@@ -54,9 +62,9 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
-				      bind, false);
+	if (!tcf_hash_check(nn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(nn->hinfo, parm->index, est, a,
+				      sizeof(*p), bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -79,7 +87,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(nn->hinfo, a);
 
 	return ret;
 }
@@ -282,6 +290,22 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_nat_walker(struct net *net, struct sk_buff *skb,
+			  struct netlink_callback *cb, int type,
+			  struct tc_action *a)
+{
+	struct nat_net *nn = net_generic(net, nat_net_id);
+
+	return tcf_generic_walker(nn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_nat_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct nat_net *nn = net_generic(net, nat_net_id);
+
+	return tcf_hash_search(nn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_nat_ops = {
 	.kind		=	"nat",
 	.type		=	TCA_ACT_NAT,
@@ -289,6 +313,40 @@ static struct tc_action_ops act_nat_ops = {
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
 	.init		=	tcf_nat_init,
+	.walk		=	tcf_nat_walker,
+	.lookup		=	tcf_nat_search,
+};
+
+static __net_init int nat_init_net(struct net *net)
+{
+	struct nat_net *tn = net_generic(net, nat_net_id);
+	int err;
+
+	tn->hinfo = kmalloc(sizeof(*tn->hinfo), GFP_KERNEL);
+	if (!tn->hinfo)
+		return -ENOMEM;
+	tn->ops = &act_nat_ops;
+	err = tcf_hashinfo_init(tn->hinfo, NAT_TAB_MASK);
+	if (err) {
+		kfree(tn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit nat_exit_net(struct net *net)
+{
+	struct nat_net *tn = net_generic(net, nat_net_id);
+
+	tcf_hashinfo_destroy(tn->ops, tn->hinfo);
+}
+
+static struct pernet_operations nat_net_ops = {
+	.init = nat_init_net,
+	.exit = nat_exit_net,
+	.id   = &nat_net_id,
+	.size = sizeof(struct nat_net),
 };
 
 MODULE_DESCRIPTION("Stateless NAT actions");
@@ -296,12 +354,17 @@ MODULE_LICENSE("GPL");
 
 static int __init nat_init_module(void)
 {
-	return tcf_register_action(&act_nat_ops, NAT_TAB_MASK);
+	int err = register_pernet_subsys(&nat_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_nat_ops);
 }
 
 static void __exit nat_cleanup_module(void)
 {
 	tcf_unregister_action(&act_nat_ops);
+	unregister_pernet_subsys(&nat_net_ops);
 }
 
 module_init(nat_init_module);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index e38a770..ac0e3cf 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -25,6 +25,13 @@
 
 #define PEDIT_TAB_MASK	15
 
+static int pedit_net_id;
+
+struct pedit_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
 };
@@ -33,6 +40,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 			  struct nlattr *est, struct tc_action *a,
 			  int ovr, int bind)
 {
+	struct pedit_net *pn = net_generic(net, pedit_net_id);
 	struct nlattr *tb[TCA_PEDIT_MAX + 1];
 	struct tc_pedit *parm;
 	int ret = 0, err;
@@ -54,11 +62,11 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
+	if (!tcf_hash_check(pn->hinfo, parm->index, a, bind)) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
-				      bind, false);
+		ret = tcf_hash_create(pn->hinfo, parm->index, est, a,
+				      sizeof(*p), bind, false);
 		if (ret)
 			return ret;
 		p = to_pedit(a);
@@ -93,7 +101,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	memcpy(p->tcfp_keys, parm->keys, ksize);
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(pn->hinfo, a);
 	return ret;
 }
 
@@ -211,6 +219,22 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_pedit_walker(struct net *net, struct sk_buff *skb,
+			    struct netlink_callback *cb, int type,
+			    struct tc_action *a)
+{
+	struct pedit_net *pn = net_generic(net, pedit_net_id);
+
+	return tcf_generic_walker(pn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_pedit_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct pedit_net *pn = net_generic(net, pedit_net_id);
+
+	return tcf_hash_search(pn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_pedit_ops = {
 	.kind		=	"pedit",
 	.type		=	TCA_ACT_PEDIT,
@@ -219,6 +243,40 @@ static struct tc_action_ops act_pedit_ops = {
 	.dump		=	tcf_pedit_dump,
 	.cleanup	=	tcf_pedit_cleanup,
 	.init		=	tcf_pedit_init,
+	.walk		=	tcf_pedit_walker,
+	.lookup		=	tcf_pedit_search,
+};
+
+static __net_init int pedit_init_net(struct net *net)
+{
+	struct pedit_net *pn = net_generic(net, pedit_net_id);
+	int err;
+
+	pn->hinfo = kmalloc(sizeof(*pn->hinfo), GFP_KERNEL);
+	if (!pn->hinfo)
+		return -ENOMEM;
+	pn->ops = &act_pedit_ops;
+	err = tcf_hashinfo_init(pn->hinfo, PEDIT_TAB_MASK);
+	if (err) {
+		kfree(pn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit pedit_exit_net(struct net *net)
+{
+	struct pedit_net *pn = net_generic(net, pedit_net_id);
+
+	tcf_hashinfo_destroy(pn->ops, pn->hinfo);
+}
+
+static struct pernet_operations pedit_net_ops = {
+	.init = pedit_init_net,
+	.exit = pedit_exit_net,
+	.id   = &pedit_net_id,
+	.size = sizeof(struct pedit_net),
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
@@ -227,12 +285,17 @@ MODULE_LICENSE("GPL");
 
 static int __init pedit_init_module(void)
 {
-	return tcf_register_action(&act_pedit_ops, PEDIT_TAB_MASK);
+	int err = register_pernet_subsys(&pedit_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_pedit_ops);
 }
 
 static void __exit pedit_cleanup_module(void)
 {
 	tcf_unregister_action(&act_pedit_ops);
+	unregister_pernet_subsys(&pedit_net_ops);
 }
 
 module_init(pedit_init_module);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 9a1c42a..47b7d22 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -55,10 +55,19 @@ struct tc_police_compat {
 
 /* Each policer is serialized by its individual spinlock */
 
-static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
-			      int type, struct tc_action *a)
+static int police_net_id;
+
+struct police_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
+static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
+				 struct netlink_callback *cb, int type,
+				 struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct police_net *pn = net_generic(net, police_net_id);
+	struct tcf_hashinfo *hinfo = pn->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
@@ -121,7 +130,8 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	struct tc_police *parm;
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct police_net *pn = net_generic(net, police_net_id);
+	struct tcf_hashinfo *hinfo = pn->hinfo;
 	int size;
 
 	if (nla == NULL)
@@ -139,7 +149,7 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_POLICE_TBF]);
 
 	if (parm->index) {
-		if (tcf_hash_search(a, parm->index)) {
+		if (tcf_hash_search(hinfo, a, parm->index)) {
 			police = to_police(a->priv);
 			if (bind) {
 				police->tcf_bindcnt += 1;
@@ -342,6 +352,13 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	return -1;
 }
 
+static int tcf_police_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct police_net *pn = net_generic(net, police_net_id);
+
+	return tcf_hash_search(pn->hinfo, a, index);
+}
+
 MODULE_AUTHOR("Alexey Kuznetsov");
 MODULE_DESCRIPTION("Policing actions");
 MODULE_LICENSE("GPL");
@@ -353,19 +370,57 @@ static struct tc_action_ops act_police_ops = {
 	.act		=	tcf_act_police,
 	.dump		=	tcf_act_police_dump,
 	.init		=	tcf_act_police_locate,
-	.walk		=	tcf_act_police_walker
+	.walk		=	tcf_act_police_walker,
+	.lookup		=	tcf_police_search,
+};
+
+static __net_init int police_init_net(struct net *net)
+{
+	struct police_net *pn = net_generic(net, police_net_id);
+	int err;
+
+	pn->hinfo = kmalloc(sizeof(*pn->hinfo), GFP_KERNEL);
+	if (!pn->hinfo)
+		return -ENOMEM;
+	pn->ops = &act_police_ops;
+	err = tcf_hashinfo_init(pn->hinfo, POL_TAB_MASK);
+	if (err) {
+		kfree(pn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit police_exit_net(struct net *net)
+{
+	struct police_net *pn = net_generic(net, police_net_id);
+
+	tcf_hashinfo_destroy(pn->ops, pn->hinfo);
+}
+
+static struct pernet_operations police_net_ops = {
+	.init = police_init_net,
+	.exit = police_exit_net,
+	.id   = &police_net_id,
+	.size = sizeof(struct police_net),
 };
 
 static int __init
 police_init_module(void)
 {
-	return tcf_register_action(&act_police_ops, POL_TAB_MASK);
+	int err = register_pernet_subsys(&police_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_police_ops);
 }
 
 static void __exit
 police_cleanup_module(void)
 {
 	tcf_unregister_action(&act_police_ops);
+	unregister_pernet_subsys(&police_net_ops);
 }
 
 module_init(police_init_module);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index d6b708d..4b53e9d 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -26,6 +26,13 @@
 
 #define SIMP_TAB_MASK     7
 
+static int simp_net_id;
+
+struct simp_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 #define SIMP_MAX_DATA	32
 static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
@@ -80,6 +87,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 			 struct nlattr *est, struct tc_action *a,
 			 int ovr, int bind)
 {
+	struct simp_net *sn = net_generic(net, simp_net_id);
 	struct nlattr *tb[TCA_DEF_MAX + 1];
 	struct tc_defact *parm;
 	struct tcf_defact *d;
@@ -102,9 +110,9 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_DEF_PARMS]);
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*d),
-				      bind, false);
+	if (!tcf_hash_check(sn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(sn->hinfo, parm->index, est, a,
+				      sizeof(*d), bind, false);
 		if (ret)
 			return ret;
 
@@ -129,7 +137,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(sn->hinfo, a);
 	return ret;
 }
 
@@ -161,6 +169,22 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_simp_walker(struct net *net, struct sk_buff *skb,
+			   struct netlink_callback *cb, int type,
+			   struct tc_action *a)
+{
+	struct simp_net *sn = net_generic(net, simp_net_id);
+
+	return tcf_generic_walker(sn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_simp_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct simp_net *sn = net_generic(net, simp_net_id);
+
+	return tcf_hash_search(sn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_simp_ops = {
 	.kind		=	"simple",
 	.type		=	TCA_ACT_SIMP,
@@ -169,6 +193,40 @@ static struct tc_action_ops act_simp_ops = {
 	.dump		=	tcf_simp_dump,
 	.cleanup	=	tcf_simp_release,
 	.init		=	tcf_simp_init,
+	.walk		=	tcf_simp_walker,
+	.lookup		=	tcf_simp_search,
+};
+
+static __net_init int simp_init_net(struct net *net)
+{
+	struct simp_net *sn = net_generic(net, simp_net_id);
+	int err;
+
+	sn->hinfo = kmalloc(sizeof(*sn->hinfo), GFP_KERNEL);
+	if (!sn->hinfo)
+		return -ENOMEM;
+	sn->ops = &act_simp_ops;
+	err = tcf_hashinfo_init(sn->hinfo, SIMP_TAB_MASK);
+	if (err) {
+		kfree(sn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit simp_exit_net(struct net *net)
+{
+	struct simp_net *sn = net_generic(net, simp_net_id);
+
+	tcf_hashinfo_destroy(sn->ops, sn->hinfo);
+}
+
+static struct pernet_operations simp_net_ops = {
+	.init = simp_init_net,
+	.exit = simp_exit_net,
+	.id   = &simp_net_id,
+	.size = sizeof(struct simp_net),
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2005)");
@@ -177,16 +235,22 @@ MODULE_LICENSE("GPL");
 
 static int __init simp_init_module(void)
 {
-	int ret;
-	ret = tcf_register_action(&act_simp_ops, SIMP_TAB_MASK);
+	int ret = register_pernet_subsys(&simp_net_ops);
+
+	if (ret)
+		return ret;
+	ret = tcf_register_action(&act_simp_ops);
 	if (!ret)
 		pr_info("Simple TC action Loaded\n");
+	else
+		unregister_pernet_subsys(&simp_net_ops);
 	return ret;
 }
 
 static void __exit simp_cleanup_module(void)
 {
 	tcf_unregister_action(&act_simp_ops);
+	unregister_pernet_subsys(&simp_net_ops);
 }
 
 module_init(simp_init_module);
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 6751b5f..f8ded6f 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -29,6 +29,13 @@
 
 #define SKBEDIT_TAB_MASK     15
 
+static int skbedit_net_id;
+
+struct skbedit_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
 {
@@ -61,6 +68,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 			    struct nlattr *est, struct tc_action *a,
 			    int ovr, int bind)
 {
+	struct skbedit_net *sn = net_generic(net, skbedit_net_id);
 	struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
@@ -98,9 +106,9 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*d),
-				      bind, false);
+	if (!tcf_hash_check(sn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(sn->hinfo, parm->index, est, a,
+				      sizeof(*d), bind, false);
 		if (ret)
 			return ret;
 
@@ -130,7 +138,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&d->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(sn->hinfo, a);
 	return ret;
 }
 
@@ -173,6 +181,22 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_skbedit_walker(struct net *net, struct sk_buff *skb,
+			      struct netlink_callback *cb, int type,
+			      struct tc_action *a)
+{
+	struct skbedit_net *sn = net_generic(net, skbedit_net_id);
+
+	return tcf_generic_walker(sn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_skbedit_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct skbedit_net *sn = net_generic(net, skbedit_net_id);
+
+	return tcf_hash_search(sn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_skbedit_ops = {
 	.kind		=	"skbedit",
 	.type		=	TCA_ACT_SKBEDIT,
@@ -180,6 +204,40 @@ static struct tc_action_ops act_skbedit_ops = {
 	.act		=	tcf_skbedit,
 	.dump		=	tcf_skbedit_dump,
 	.init		=	tcf_skbedit_init,
+	.walk		=	tcf_skbedit_walker,
+	.lookup		=	tcf_skbedit_search,
+};
+
+static __net_init int skbedit_init_net(struct net *net)
+{
+	struct skbedit_net *sn = net_generic(net, skbedit_net_id);
+	int err;
+
+	sn->hinfo = kmalloc(sizeof(*sn->hinfo), GFP_KERNEL);
+	if (!sn->hinfo)
+		return -ENOMEM;
+	sn->ops = &act_skbedit_ops;
+	err = tcf_hashinfo_init(sn->hinfo, SKBEDIT_TAB_MASK);
+	if (err) {
+		kfree(sn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit skbedit_exit_net(struct net *net)
+{
+	struct skbedit_net *sn = net_generic(net, skbedit_net_id);
+
+	tcf_hashinfo_destroy(sn->ops, sn->hinfo);
+}
+
+static struct pernet_operations skbedit_net_ops = {
+	.init = skbedit_init_net,
+	.exit = skbedit_exit_net,
+	.id   = &skbedit_net_id,
+	.size = sizeof(struct skbedit_net),
 };
 
 MODULE_AUTHOR("Alexander Duyck, <alexander.h.duyck@intel.com>");
@@ -188,12 +246,17 @@ MODULE_LICENSE("GPL");
 
 static int __init skbedit_init_module(void)
 {
-	return tcf_register_action(&act_skbedit_ops, SKBEDIT_TAB_MASK);
+	int err = register_pernet_subsys(&skbedit_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_skbedit_ops);
 }
 
 static void __exit skbedit_cleanup_module(void)
 {
 	tcf_unregister_action(&act_skbedit_ops);
+	unregister_pernet_subsys(&skbedit_net_ops);
 }
 
 module_init(skbedit_init_module);
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 796785e..b9fc886 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -21,6 +21,13 @@
 
 #define VLAN_TAB_MASK     15
 
+static int vlan_net_id;
+
+struct vlan_net {
+	struct tcf_hashinfo *hinfo;
+	struct tc_action_ops *ops;
+};
+
 static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
@@ -68,6 +75,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 			 struct nlattr *est, struct tc_action *a,
 			 int ovr, int bind)
 {
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	struct nlattr *tb[TCA_VLAN_MAX + 1];
 	struct tc_vlan *parm;
 	struct tcf_vlan *v;
@@ -115,9 +123,9 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	}
 	action = parm->v_action;
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*v),
-				      bind, false);
+	if (!tcf_hash_check(vn->hinfo, parm->index, a, bind)) {
+		ret = tcf_hash_create(vn->hinfo, parm->index, est, a,
+				      sizeof(*v), bind, false);
 		if (ret)
 			return ret;
 
@@ -143,7 +151,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&v->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(vn->hinfo, a);
 	return ret;
 }
 
@@ -181,6 +189,22 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 	return -1;
 }
 
+static int tcf_vlan_walker(struct net *net, struct sk_buff *skb,
+			   struct netlink_callback *cb, int type,
+			   struct tc_action *a)
+{
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+
+	return tcf_generic_walker(vn->hinfo, skb, cb, type, a);
+}
+
+static int tcf_vlan_search(struct net *net, struct tc_action *a, u32 index)
+{
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+
+	return tcf_hash_search(vn->hinfo, a, index);
+}
+
 static struct tc_action_ops act_vlan_ops = {
 	.kind		=	"vlan",
 	.type		=	TCA_ACT_VLAN,
@@ -188,16 +212,55 @@ static struct tc_action_ops act_vlan_ops = {
 	.act		=	tcf_vlan,
 	.dump		=	tcf_vlan_dump,
 	.init		=	tcf_vlan_init,
+	.walk		=	tcf_vlan_walker,
+	.lookup		=	tcf_vlan_search,
+};
+
+static __net_init int vlan_init_net(struct net *net)
+{
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+	int err;
+
+	vn->hinfo = kmalloc(sizeof(*vn->hinfo), GFP_KERNEL);
+	if (!vn->hinfo)
+		return -ENOMEM;
+	vn->ops = &act_vlan_ops;
+	err = tcf_hashinfo_init(vn->hinfo, VLAN_TAB_MASK);
+	if (err) {
+		kfree(vn->hinfo);
+		return err;
+	}
+
+	return 0;
+}
+
+static void __net_exit vlan_exit_net(struct net *net)
+{
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+
+	tcf_hashinfo_destroy(vn->ops, vn->hinfo);
+}
+
+static struct pernet_operations vlan_net_ops = {
+	.init = vlan_init_net,
+	.exit = vlan_exit_net,
+	.id   = &vlan_net_id,
+	.size = sizeof(struct vlan_net),
 };
 
 static int __init vlan_init_module(void)
 {
-	return tcf_register_action(&act_vlan_ops, VLAN_TAB_MASK);
+	int err = register_pernet_subsys(&vlan_net_ops);
+
+	if (err)
+		return err;
+	return tcf_register_action(&act_vlan_ops);
 }
 
 static void __exit vlan_cleanup_module(void)
 {
 	tcf_unregister_action(&act_vlan_ops);
+	unregister_pernet_subsys(&vlan_net_ops);
 }
 
 module_init(vlan_init_module);
-- 
2.1.0
