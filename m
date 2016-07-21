From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/2] net_sched: move tc_action into tcf_common
Date: Wed, 20 Jul 2016 22:23:33 -0700
Message-ID: <1469078614-13540-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36028 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbcGUFXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 01:23:51 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so4551499pab.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 22:23:50 -0700 (PDT)
In-Reply-To: <1469078614-13540-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct tc_action is confusing, currently we use it for two purposes:
1) Pass in arguments and carry out results from helper functions
2) A generic representation for tc actions

The first one is error-prone, since we need to make sure we don't
miss anything. This patch aims to get rid of this use, by moving
tc_action into tcf_common, so that they are allocated together
in hashtable and can be cast'ed easily.

And together with the following patch, we could really make
tc_action a generic representation for all tc actions and each
type of action can inherit from it.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h            |  52 ++++++++------
 include/net/tc_act/tc_bpf.h      |   3 +-
 include/net/tc_act/tc_connmark.h |   3 +-
 include/net/tc_act/tc_csum.h     |   3 +-
 include/net/tc_act/tc_defact.h   |   3 +-
 include/net/tc_act/tc_gact.h     |   5 +-
 include/net/tc_act/tc_ife.h      |   3 +-
 include/net/tc_act/tc_ipt.h      |   3 +-
 include/net/tc_act/tc_mirred.h   |   3 +-
 include/net/tc_act/tc_nat.h      |   5 +-
 include/net/tc_act/tc_pedit.h    |   3 +-
 include/net/tc_act/tc_skbedit.h  |   3 +-
 include/net/tc_act/tc_vlan.h     |   3 +-
 net/sched/act_api.c              | 149 ++++++++++++++-------------------------
 net/sched/act_bpf.c              |  26 +++----
 net/sched/act_connmark.c         |  24 ++++---
 net/sched/act_csum.c             |  22 +++---
 net/sched/act_gact.c             |  24 ++++---
 net/sched/act_ife.c              |  38 +++++-----
 net/sched/act_ipt.c              |  48 +++++++------
 net/sched/act_mirred.c           |  26 +++----
 net/sched/act_nat.c              |  22 +++---
 net/sched/act_pedit.c            |  28 ++++----
 net/sched/act_police.c           |  45 ++++++------
 net/sched/act_simple.c           |  29 ++++----
 net/sched/act_skbedit.c          |  26 +++----
 net/sched/act_vlan.c             |  28 ++++----
 27 files changed, 298 insertions(+), 329 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index fb82b5b..504e7e0 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -10,7 +10,26 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
+
+struct tcf_hashinfo {
+	struct hlist_head	*htab;
+	unsigned int		hmask;
+	spinlock_t		lock;
+	u32			index;
+};
+
+struct tc_action_ops;
+
+struct tc_action {
+	const struct tc_action_ops	*ops;
+	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
+	__u32			order;
+	struct list_head	list;
+	struct tcf_hashinfo	*hinfo;
+};
+
 struct tcf_common {
+	struct tc_action		tcfc_act;
 	struct hlist_node		tcfc_head;
 	u32				tcfc_index;
 	int				tcfc_refcnt;
@@ -26,6 +45,7 @@ struct tcf_common {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
 };
+#define tcf_act		common.tcfc_act
 #define tcf_head	common.tcfc_head
 #define tcf_index	common.tcfc_index
 #define tcf_refcnt	common.tcfc_refcnt
@@ -39,13 +59,6 @@ struct tcf_common {
 #define tcf_lock	common.tcfc_lock
 #define tcf_rcu		common.tcfc_rcu
 
-struct tcf_hashinfo {
-	struct hlist_head	*htab;
-	unsigned int		hmask;
-	spinlock_t		lock;
-	u32			index;
-};
-
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
 {
 	return index & hmask;
@@ -88,15 +101,6 @@ static inline void tcf_tm_dump(struct tcf_t *dtm, const struct tcf_t *stm)
 	dtm->expires = jiffies_to_clock_t(stm->expires);
 }
 
-struct tc_action {
-	void			*priv;
-	const struct tc_action_ops	*ops;
-	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
-	__u32			order;
-	struct list_head	list;
-	struct tcf_hashinfo	*hinfo;
-};
-
 #ifdef CONFIG_NET_CLS_ACT
 
 #define ACT_P_CREATED 1
@@ -106,17 +110,18 @@ struct tc_action_ops {
 	struct list_head head;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
+	size_t	size;
 	struct module		*owner;
 	int     (*act)(struct sk_buff *, const struct tc_action *,
 		       struct tcf_result *);
 	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
 	void	(*cleanup)(struct tc_action *, int bind);
-	int     (*lookup)(struct net *, struct tc_action *, u32);
+	int     (*lookup)(struct net *, struct tc_action **, u32);
 	int     (*init)(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action *act, int ovr,
+			struct nlattr *est, struct tc_action **act, int ovr,
 			int bind);
 	int     (*walk)(struct net *, struct sk_buff *,
-			struct netlink_callback *, int, struct tc_action *);
+			struct netlink_callback *, int, const struct tc_action_ops *);
 	void	(*stats_update)(struct tc_action *, u64, u32, u64);
 };
 
@@ -152,13 +157,14 @@ static inline void tc_action_net_exit(struct tc_action_net *tn)
 
 int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
-		       struct tc_action *a);
-int tcf_hash_search(struct tc_action_net *tn, struct tc_action *a, u32 index);
+		       const struct tc_action_ops *ops);
+int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index);
 u32 tcf_hash_new_index(struct tc_action_net *tn);
-bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
+bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		    int bind);
 int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
-		    struct tc_action *a, int size, int bind, bool cpustats);
+		    struct tc_action **a, const struct tc_action_ops *ops, int bind,
+		    bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a);
 
diff --git a/include/net/tc_act/tc_bpf.h b/include/net/tc_act/tc_bpf.h
index 958d69c..80a4d6f 100644
--- a/include/net/tc_act/tc_bpf.h
+++ b/include/net/tc_act/tc_bpf.h
@@ -23,7 +23,6 @@ struct tcf_bpf {
 	struct sock_filter	*bpf_ops;
 	const char		*bpf_name;
 };
-#define to_bpf(a) \
-	container_of(a->priv, struct tcf_bpf, common)
+#define to_bpf(a) ((struct tcf_bpf *)a)
 
 #endif /* __NET_TC_BPF_H */
diff --git a/include/net/tc_act/tc_connmark.h b/include/net/tc_act/tc_connmark.h
index 02caa40..8a66113 100644
--- a/include/net/tc_act/tc_connmark.h
+++ b/include/net/tc_act/tc_connmark.h
@@ -9,7 +9,6 @@ struct tcf_connmark_info {
 	u16 zone;
 };
 
-#define to_connmark(a) \
-	container_of(a->priv, struct tcf_connmark_info, common)
+#define to_connmark(a) ((struct tcf_connmark_info *)a)
 
 #endif /* __NET_TC_CONNMARK_H */
diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
index fa8f5fa..1a9ef15 100644
--- a/include/net/tc_act/tc_csum.h
+++ b/include/net/tc_act/tc_csum.h
@@ -9,7 +9,6 @@ struct tcf_csum {
 
 	u32 update_flags;
 };
-#define to_tcf_csum(a) \
-	container_of(a->priv,struct tcf_csum,common)
+#define to_tcf_csum(a) ((struct tcf_csum *)a)
 
 #endif /* __NET_TC_CSUM_H */
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
index ab9b5d6..e25b4eb 100644
--- a/include/net/tc_act/tc_defact.h
+++ b/include/net/tc_act/tc_defact.h
@@ -8,7 +8,6 @@ struct tcf_defact {
 	u32		tcfd_datalen;
 	void		*tcfd_defdata;
 };
-#define to_defact(a) \
-	container_of(a->priv, struct tcf_defact, common)
+#define to_defact(a) ((struct tcf_defact *)a)
 
 #endif /* __NET_TC_DEF_H */
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 93c520b..119cdb4 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -13,8 +13,7 @@ struct tcf_gact {
 	atomic_t		packets;
 #endif
 };
-#define to_gact(a) \
-	container_of(a->priv, struct tcf_gact, common)
+#define to_gact(a) ((struct tcf_gact *)a)
 
 static inline bool is_tcf_gact_shot(const struct tc_action *a)
 {
@@ -24,7 +23,7 @@ static inline bool is_tcf_gact_shot(const struct tc_action *a)
 	if (a->ops && a->ops->type != TCA_ACT_GACT)
 		return false;
 
-	gact = a->priv;
+	gact = to_gact(a);
 	if (gact->tcf_action == TC_ACT_SHOT)
 		return true;
 
diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index c55facd..7921abe 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -16,8 +16,7 @@ struct tcf_ife_info {
 	/* list of metaids allowed */
 	struct list_head metalist;
 };
-#define to_ife(a) \
-	container_of(a->priv, struct tcf_ife_info, common)
+#define to_ife(a) ((struct tcf_ife_info *)a)
 
 struct tcf_meta_info {
 	const struct tcf_meta_ops *ops;
diff --git a/include/net/tc_act/tc_ipt.h b/include/net/tc_act/tc_ipt.h
index c0f4193..c22ae7a 100644
--- a/include/net/tc_act/tc_ipt.h
+++ b/include/net/tc_act/tc_ipt.h
@@ -11,7 +11,6 @@ struct tcf_ipt {
 	char			*tcfi_tname;
 	struct xt_entry_target	*tcfi_t;
 };
-#define to_ipt(a) \
-	container_of(a->priv, struct tcf_ipt, common)
+#define to_ipt(a) ((struct tcf_ipt *)a)
 
 #endif /* __NET_TC_IPT_H */
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index e891835..de67ca7 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -12,8 +12,7 @@ struct tcf_mirred {
 	struct net_device __rcu	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
-#define to_mirred(a) \
-	container_of(a->priv, struct tcf_mirred, common)
+#define to_mirred(a) ((struct tcf_mirred *)a)
 
 static inline bool is_tcf_mirred_redirect(const struct tc_action *a)
 {
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
index 63d8e9c..a91ad3a 100644
--- a/include/net/tc_act/tc_nat.h
+++ b/include/net/tc_act/tc_nat.h
@@ -13,9 +13,6 @@ struct tcf_nat {
 	u32 flags;
 };
 
-static inline struct tcf_nat *to_tcf_nat(struct tc_action *a)
-{
-	return container_of(a->priv, struct tcf_nat, common);
-}
+#define to_tcf_nat(a) ((struct tcf_nat *)a)
 
 #endif /* __NET_TC_NAT_H */
diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index 5b80998..2cccfba 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -9,7 +9,6 @@ struct tcf_pedit {
 	unsigned char		tcfp_flags;
 	struct tc_pedit_key	*tcfp_keys;
 };
-#define to_pedit(a) \
-	container_of(a->priv, struct tcf_pedit, common)
+#define to_pedit(a) ((struct tcf_pedit *)a)
 
 #endif /* __NET_TC_PED_H */
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index d01a5d4..9e05489 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -30,8 +30,7 @@ struct tcf_skbedit {
 	u16		queue_mapping;
 	u16		ptype;
 };
-#define to_skbedit(a) \
-	container_of(a->priv, struct tcf_skbedit, common)
+#define to_skbedit(a) ((struct tcf_skbedit *)a)
 
 /* Return true iff action is mark */
 static inline bool is_tcf_skbedit_mark(const struct tc_action *a)
diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
index 93b70ad..584b807 100644
--- a/include/net/tc_act/tc_vlan.h
+++ b/include/net/tc_act/tc_vlan.h
@@ -21,7 +21,6 @@ struct tcf_vlan {
 	u16			tcfv_push_vid;
 	__be16			tcfv_push_proto;
 };
-#define to_vlan(a) \
-	container_of(a->priv, struct tcf_vlan, common)
+#define to_vlan(a) ((struct tcf_vlan *)a)
 
 #endif /* __NET_TC_VLAN_H */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 47ec230..d97419f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -38,7 +38,7 @@ static void free_tcf(struct rcu_head *head)
 
 static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *a)
 {
-	struct tcf_common *p = a->priv;
+	struct tcf_common *p = (struct tcf_common *)a;
 
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfc_head);
@@ -54,7 +54,7 @@ static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *a)
 
 int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 {
-	struct tcf_common *p = a->priv;
+	struct tcf_common *p = (struct tcf_common *)a;
 	int ret = 0;
 
 	if (p) {
@@ -67,6 +67,7 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
 			if (a->ops->cleanup)
 				a->ops->cleanup(a, bind);
+			list_del(&a->list);
 			tcf_hash_destroy(a->hinfo, a);
 			ret = ACT_P_DELETED;
 		}
@@ -77,10 +78,8 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 EXPORT_SYMBOL(__tcf_hash_release);
 
 static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
-			   struct netlink_callback *cb, struct tc_action *a)
+			   struct netlink_callback *cb)
 {
-	struct hlist_head *head;
-	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
@@ -89,19 +88,20 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 	s_i = cb->args[0];
 
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
+		struct hlist_head *head;
+		struct tcf_common *p;
+
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
 		hlist_for_each_entry_rcu(p, head, tcfc_head) {
 			index++;
 			if (index < s_i)
 				continue;
-			a->priv = p;
-			a->order = n_i;
 
-			nest = nla_nest_start(skb, a->order);
+			nest = nla_nest_start(skb, n_i);
 			if (nest == NULL)
 				goto nla_put_failure;
-			err = tcf_action_dump_1(skb, a, 0, 0);
+			err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 0);
 			if (err < 0) {
 				index--;
 				nlmsg_trim(skb, nest);
@@ -125,27 +125,27 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 }
 
 static int tcf_del_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
-			  struct tc_action *a)
+			  const struct tc_action_ops *ops)
 {
-	struct hlist_head *head;
-	struct hlist_node *n;
-	struct tcf_common *p;
 	struct nlattr *nest;
 	int i = 0, n_i = 0;
 	int ret = -EINVAL;
 
-	nest = nla_nest_start(skb, a->order);
+	nest = nla_nest_start(skb, 0);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
+	if (nla_put_string(skb, TCA_KIND, ops->kind))
 		goto nla_put_failure;
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
+		struct hlist_head *head;
+		struct hlist_node *n;
+		struct tcf_common *p;
+
 		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
 		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
-			a->priv = p;
-			ret = __tcf_hash_release(a, false, true);
+			ret = __tcf_hash_release((struct tc_action *)p, false, true);
 			if (ret == ACT_P_DELETED) {
-				module_put(a->ops->owner);
+				module_put(p->tcfc_act.ops->owner);
 				n_i++;
 			} else if (ret < 0)
 				goto nla_put_failure;
@@ -163,16 +163,14 @@ static int tcf_del_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
 
 int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,
 		       struct netlink_callback *cb, int type,
-		       struct tc_action *a)
+		       const struct tc_action_ops *ops)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 
-	a->hinfo = hinfo;
-
 	if (type == RTM_DELACTION) {
-		return tcf_del_walker(hinfo, skb, a);
+		return tcf_del_walker(hinfo, skb, ops);
 	} else if (type == RTM_GETACTION) {
-		return tcf_dump_walker(hinfo, skb, cb, a);
+		return tcf_dump_walker(hinfo, skb, cb);
 	} else {
 		WARN(1, "tcf_generic_walker: unknown action %d\n", type);
 		return -EINVAL;
@@ -210,21 +208,20 @@ u32 tcf_hash_new_index(struct tc_action_net *tn)
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
-int tcf_hash_search(struct tc_action_net *tn, struct tc_action *a, u32 index)
+int tcf_hash_search(struct tc_action_net *tn, struct tc_action **a, u32 index)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
 
 	if (p) {
-		a->priv = p;
-		a->hinfo = hinfo;
+		*a = &p->tcfc_act;
 		return 1;
 	}
 	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_search);
 
-bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
+bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action **a,
 		    int bind)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
@@ -233,8 +230,7 @@ bool tcf_hash_check(struct tc_action_net *tn, u32 index, struct tc_action *a,
 		if (bind)
 			p->tcfc_bindcnt++;
 		p->tcfc_refcnt++;
-		a->priv = p;
-		a->hinfo = hinfo;
+		*a = &p->tcfc_act;
 		return true;
 	}
 	return false;
@@ -243,7 +239,7 @@ EXPORT_SYMBOL(tcf_hash_check);
 
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 {
-	struct tcf_common *pc = a->priv;
+	struct tcf_common *pc = (struct tcf_common *)a;
 	if (est)
 		gen_kill_estimator(&pc->tcfc_bstats,
 				   &pc->tcfc_rate_est);
@@ -252,9 +248,10 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 EXPORT_SYMBOL(tcf_hash_cleanup);
 
 int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
-		    struct tc_action *a, int size, int bind, bool cpustats)
+		    struct tc_action **a, const struct tc_action_ops *ops,
+		    int bind, bool cpustats)
 {
-	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
+	struct tcf_common *p = kzalloc(ops->size, GFP_KERNEL);
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 	int err = -ENOMEM;
 
@@ -294,15 +291,17 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		}
 	}
 
-	a->priv = (void *) p;
-	a->hinfo = hinfo;
+	p->tcfc_act.hinfo = hinfo;
+	p->tcfc_act.ops = ops;
+	INIT_LIST_HEAD(&p->tcfc_act.list);
+	*a = &p->tcfc_act;
 	return 0;
 }
 EXPORT_SYMBOL(tcf_hash_create);
 
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
 {
-	struct tcf_common *p = a->priv;
+	struct tcf_common *p = (struct tcf_common *)a;
 	struct tcf_hashinfo *hinfo = tn->hinfo;
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
@@ -315,10 +314,6 @@ EXPORT_SYMBOL(tcf_hash_insert);
 void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
 			  struct tcf_hashinfo *hinfo)
 {
-	struct tc_action a = {
-		.ops = ops,
-		.hinfo = hinfo,
-	};
 	int i;
 
 	for (i = 0; i < hinfo->hmask + 1; i++) {
@@ -328,8 +323,7 @@ void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
 		hlist_for_each_entry_safe(p, n, &hinfo->htab[i], tcfc_head) {
 			int ret;
 
-			a.priv = p;
-			ret = __tcf_hash_release(&a, false, true);
+			ret = __tcf_hash_release((struct tc_action *)p, false, true);
 			if (ret == ACT_P_DELETED)
 				module_put(ops->owner);
 			else if (ret < 0)
@@ -466,8 +460,6 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 			module_put(a->ops->owner);
 		else if (ret < 0)
 			return ret;
-		list_del(&a->list);
-		kfree(a);
 	}
 	return ret;
 }
@@ -581,20 +573,13 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 		goto err_out;
 	}
 
-	err = -ENOMEM;
-	a = kzalloc(sizeof(*a), GFP_KERNEL);
-	if (a == NULL)
-		goto err_mod;
-
-	a->ops = a_o;
-	INIT_LIST_HEAD(&a->list);
 	/* backward compatibility for policer */
 	if (name == NULL)
-		err = a_o->init(net, tb[TCA_ACT_OPTIONS], est, a, ovr, bind);
+		err = a_o->init(net, tb[TCA_ACT_OPTIONS], est, &a, ovr, bind);
 	else
-		err = a_o->init(net, nla, est, a, ovr, bind);
+		err = a_o->init(net, nla, est, &a, ovr, bind);
 	if (err < 0)
-		goto err_free;
+		goto err_mod;
 
 	/* module count goes up only when brand new policy is created
 	 * if it exists and is only bound to in a_o->init() then
@@ -605,8 +590,6 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 
 	return a;
 
-err_free:
-	kfree(a);
 err_mod:
 	module_put(a_o->owner);
 err_out:
@@ -647,7 +630,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 {
 	int err = 0;
 	struct gnet_dump d;
-	struct tcf_common *p = a->priv;
+	struct tcf_common *p = (struct tcf_common *)a;
 
 	if (p == NULL)
 		goto errout;
@@ -740,24 +723,11 @@ act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 	return rtnl_unicast(skb, net, portid);
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
 static struct tc_action *tcf_action_get_1(struct net *net, struct nlattr *nla,
 					  struct nlmsghdr *n, u32 portid)
 {
 	struct nlattr *tb[TCA_ACT_MAX + 1];
+	const struct tc_action_ops *ops;
 	struct tc_action *a;
 	int index;
 	int err;
@@ -772,26 +742,19 @@ static struct tc_action *tcf_action_get_1(struct net *net, struct nlattr *nla,
 		goto err_out;
 	index = nla_get_u32(tb[TCA_ACT_INDEX]);
 
-	err = -ENOMEM;
-	a = create_a(0);
-	if (a == NULL)
-		goto err_out;
-
 	err = -EINVAL;
-	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
-	if (a->ops == NULL) /* could happen in batch of actions */
-		goto err_free;
+	ops = tc_lookup_action(tb[TCA_ACT_KIND]);
+	if (!ops) /* could happen in batch of actions */
+		goto err_out;
 	err = -ENOENT;
-	if (a->ops->lookup(net, a, index) == 0)
+	if (ops->lookup(net, &a, index) == 0)
 		goto err_mod;
 
-	module_put(a->ops->owner);
+	module_put(ops->owner);
 	return a;
 
 err_mod:
-	module_put(a->ops->owner);
-err_free:
-	kfree(a);
+	module_put(ops->owner);
 err_out:
 	return ERR_PTR(err);
 }
@@ -816,8 +779,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	struct netlink_callback dcb;
 	struct nlattr *nest;
 	struct nlattr *tb[TCA_ACT_MAX + 1];
+	const struct tc_action_ops *ops;
 	struct nlattr *kind;
-	struct tc_action a;
 	int err = -ENOMEM;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
@@ -834,10 +797,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	err = -EINVAL;
 	kind = tb[TCA_ACT_KIND];
-	memset(&a, 0, sizeof(struct tc_action));
-	INIT_LIST_HEAD(&a.list);
-	a.ops = tc_lookup_action(kind);
-	if (a.ops == NULL) /*some idjot trying to flush unknown action */
+	ops = tc_lookup_action(kind);
+	if (!ops) /*some idjot trying to flush unknown action */
 		goto err_out;
 
 	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION,
@@ -853,7 +814,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (nest == NULL)
 		goto out_module_put;
 
-	err = a.ops->walk(net, skb, &dcb, RTM_DELACTION, &a);
+	err = ops->walk(net, skb, &dcb, RTM_DELACTION, ops);
 	if (err < 0)
 		goto out_module_put;
 	if (err == 0)
@@ -863,7 +824,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	nlh->nlmsg_flags |= NLM_F_ROOT;
-	module_put(a.ops->owner);
+	module_put(ops->owner);
 	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			     n->nlmsg_flags & NLM_F_ECHO);
 	if (err > 0)
@@ -872,7 +833,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	return err;
 
 out_module_put:
-	module_put(a.ops->owner);
+	module_put(ops->owner);
 err_out:
 noflush_out:
 	kfree_skb(skb);
@@ -1084,7 +1045,6 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 	struct tc_action_ops *a_o;
-	struct tc_action a;
 	int ret = 0;
 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
 	struct nlattr *kind = find_dump_kind(cb->nlh);
@@ -1098,9 +1058,6 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (a_o == NULL)
 		return 0;
 
-	memset(&a, 0, sizeof(struct tc_action));
-	a.ops = a_o;
-
 	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
@@ -1114,7 +1071,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (nest == NULL)
 		goto out_module_put;
 
-	ret = a_o->walk(net, skb, cb, RTM_GETACTION, &a);
+	ret = a_o->walk(net, skb, cb, RTM_GETACTION, a_o);
 	if (ret < 0)
 		goto out_module_put;
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index ef74bff..bfa8707 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -34,11 +34,12 @@ struct tcf_bpf_cfg {
 };
 
 static int bpf_net_id;
+static struct tc_action_ops act_bpf_ops;
 
 static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		   struct tcf_result *res)
 {
-	struct tcf_bpf *prog = act->priv;
+	struct tcf_bpf *prog = to_bpf(act);
 	struct bpf_prog *filter;
 	int action, filter_res;
 	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
@@ -134,7 +135,7 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
 			int bind, int ref)
 {
 	unsigned char *tp = skb_tail_pointer(skb);
-	struct tcf_bpf *prog = act->priv;
+	struct tcf_bpf *prog = to_bpf(act);
 	struct tc_act_bpf opt = {
 		.index   = prog->tcf_index,
 		.refcnt  = prog->tcf_refcnt - ref,
@@ -270,7 +271,7 @@ static void tcf_bpf_prog_fill_cfg(const struct tcf_bpf *prog,
 }
 
 static int tcf_bpf_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action *act,
+			struct nlattr *est, struct tc_action **act,
 			int replace, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
@@ -295,7 +296,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(tn, parm->index, act, bind)) {
 		ret = tcf_hash_create(tn, parm->index, est, act,
-				      sizeof(*prog), bind, true);
+				      &act_bpf_ops, bind, true);
 		if (ret < 0)
 			return ret;
 
@@ -305,7 +306,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		if (bind)
 			return 0;
 
-		tcf_hash_release(act, bind);
+		tcf_hash_release(*act, bind);
 		if (!replace)
 			return -EEXIST;
 	}
@@ -325,7 +326,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	if (ret < 0)
 		goto out;
 
-	prog = to_bpf(act);
+	prog = to_bpf(*act);
 	ASSERT_RTNL();
 
 	if (res != ACT_P_CREATED)
@@ -343,7 +344,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	rcu_assign_pointer(prog->filter, cfg.filter);
 
 	if (res == ACT_P_CREATED) {
-		tcf_hash_insert(tn, act);
+		tcf_hash_insert(tn, *act);
 	} else {
 		/* make sure the program being replaced is no longer executing */
 		synchronize_rcu();
@@ -353,7 +354,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	return res;
 out:
 	if (res == ACT_P_CREATED)
-		tcf_hash_cleanup(act, est);
+		tcf_hash_cleanup(*act, est);
 
 	return ret;
 }
@@ -362,20 +363,20 @@ static void tcf_bpf_cleanup(struct tc_action *act, int bind)
 {
 	struct tcf_bpf_cfg tmp;
 
-	tcf_bpf_prog_fill_cfg(act->priv, &tmp);
+	tcf_bpf_prog_fill_cfg(to_bpf(act), &tmp);
 	tcf_bpf_cfg_cleanup(&tmp);
 }
 
 static int tcf_bpf_walker(struct net *net, struct sk_buff *skb,
 			  struct netlink_callback *cb, int type,
-			  struct tc_action *a)
+			  const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_bpf_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_bpf_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 
@@ -392,6 +393,7 @@ static struct tc_action_ops act_bpf_ops __read_mostly = {
 	.init		=	tcf_bpf_init,
 	.walk		=	tcf_bpf_walker,
 	.lookup		=	tcf_bpf_search,
+	.size		=	sizeof(struct tcf_bpf),
 };
 
 static __net_init int bpf_init_net(struct net *net)
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 35a5270..eae07a2 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -31,6 +31,7 @@
 #define CONNMARK_TAB_MASK     3
 
 static int connmark_net_id;
+static struct tc_action_ops act_connmark_ops;
 
 static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 			struct tcf_result *res)
@@ -38,7 +39,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	const struct nf_conntrack_tuple_hash *thash;
 	struct nf_conntrack_tuple tuple;
 	enum ip_conntrack_info ctinfo;
-	struct tcf_connmark_info *ca = a->priv;
+	struct tcf_connmark_info *ca = to_connmark(a);
 	struct nf_conntrack_zone zone;
 	struct nf_conn *c;
 	int proto;
@@ -96,7 +97,7 @@ static const struct nla_policy connmark_policy[TCA_CONNMARK_MAX + 1] = {
 };
 
 static int tcf_connmark_init(struct net *net, struct nlattr *nla,
-			     struct nlattr *est, struct tc_action *a,
+			     struct nlattr *est, struct tc_action **a,
 			     int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
@@ -116,22 +117,22 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*ci), bind, false);
+				      &act_connmark_ops, bind, false);
 		if (ret)
 			return ret;
 
-		ci = to_connmark(a);
+		ci = to_connmark(*a);
 		ci->tcf_action = parm->action;
 		ci->net = net;
 		ci->zone = parm->zone;
 
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 		ret = ACT_P_CREATED;
 	} else {
-		ci = to_connmark(a);
+		ci = to_connmark(*a);
 		if (bind)
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 		/* replacing action and zone */
@@ -146,7 +147,7 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 				    int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_connmark_info *ci = a->priv;
+	struct tcf_connmark_info *ci = to_connmark(a);
 
 	struct tc_connmark opt = {
 		.index   = ci->tcf_index,
@@ -173,14 +174,14 @@ static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_connmark_walker(struct net *net, struct sk_buff *skb,
 			       struct netlink_callback *cb, int type,
-			       struct tc_action *a)
+			       const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_connmark_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_connmark_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 
@@ -196,6 +197,7 @@ static struct tc_action_ops act_connmark_ops = {
 	.init		=	tcf_connmark_init,
 	.walk		=	tcf_connmark_walker,
 	.lookup		=	tcf_connmark_search,
+	.size		=	sizeof(struct tcf_connmark_info),
 };
 
 static __net_init int connmark_init_net(struct net *net)
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index dcd9aba..b5dbf63 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -43,9 +43,10 @@ static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 };
 
 static int csum_net_id;
+static struct tc_action_ops act_csum_ops;
 
 static int tcf_csum_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action *a, int ovr,
+			 struct nlattr *est, struct tc_action **a, int ovr,
 			 int bind)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
@@ -67,26 +68,26 @@ static int tcf_csum_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*p), bind, false);
+				      &act_csum_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	p = to_tcf_csum(a);
+	p = to_tcf_csum(*a);
 	spin_lock_bh(&p->tcf_lock);
 	p->tcf_action = parm->action;
 	p->update_flags = parm->update_flags;
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 
 	return ret;
 }
@@ -496,7 +497,7 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32 update_flags)
 static int tcf_csum(struct sk_buff *skb,
 		    const struct tc_action *a, struct tcf_result *res)
 {
-	struct tcf_csum *p = a->priv;
+	struct tcf_csum *p = to_tcf_csum(a);
 	int action;
 	u32 update_flags;
 
@@ -534,7 +535,7 @@ static int tcf_csum_dump(struct sk_buff *skb,
 			 struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_csum *p = a->priv;
+	struct tcf_csum *p = to_tcf_csum(a);
 	struct tc_csum opt = {
 		.update_flags = p->update_flags,
 		.index   = p->tcf_index,
@@ -560,14 +561,14 @@ static int tcf_csum_dump(struct sk_buff *skb,
 
 static int tcf_csum_walker(struct net *net, struct sk_buff *skb,
 			   struct netlink_callback *cb, int type,
-			   struct tc_action *a)
+			   const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_csum_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_csum_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 
@@ -583,6 +584,7 @@ static struct tc_action_ops act_csum_ops = {
 	.init		= tcf_csum_init,
 	.walk		= tcf_csum_walker,
 	.lookup		= tcf_csum_search,
+	.size		= sizeof(struct tcf_csum),
 };
 
 static __net_init int csum_init_net(struct net *net)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 19058a7..e24a409 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -26,6 +26,7 @@
 #define GACT_TAB_MASK	15
 
 static int gact_net_id;
+static struct tc_action_ops act_gact_ops;
 
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
@@ -56,7 +57,7 @@ static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
 };
 
 static int tcf_gact_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action *a,
+			 struct nlattr *est, struct tc_action **a,
 			 int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
@@ -93,19 +94,19 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*gact), bind, true);
+				      &act_gact_ops, bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	gact = to_gact(a);
+	gact = to_gact(*a);
 
 	ASSERT_RTNL();
 	gact->tcf_action = parm->action;
@@ -121,14 +122,14 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	}
 #endif
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 }
 
 static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
-	struct tcf_gact *gact = a->priv;
+	struct tcf_gact *gact = to_gact(a);
 	int action = READ_ONCE(gact->tcf_action);
 
 #ifdef CONFIG_GACT_PROB
@@ -151,7 +152,7 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 static void tcf_gact_stats_update(struct tc_action *a, u64 bytes, u32 packets,
 				  u64 lastuse)
 {
-	struct tcf_gact *gact = a->priv;
+	struct tcf_gact *gact = to_gact(a);
 	int action = READ_ONCE(gact->tcf_action);
 	struct tcf_t *tm = &gact->tcf_tm;
 
@@ -166,7 +167,7 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a,
 			 int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_gact *gact = a->priv;
+	struct tcf_gact *gact = to_gact(a);
 	struct tc_gact opt = {
 		.index   = gact->tcf_index,
 		.refcnt  = gact->tcf_refcnt - ref,
@@ -201,14 +202,14 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_gact_walker(struct net *net, struct sk_buff *skb,
 			   struct netlink_callback *cb, int type,
-			   struct tc_action *a)
+			   const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_gact_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_gact_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 
@@ -225,6 +226,7 @@ static struct tc_action_ops act_gact_ops = {
 	.init		=	tcf_gact_init,
 	.walk		=	tcf_gact_walker,
 	.lookup		=	tcf_gact_search,
+	.size		=	sizeof(struct tcf_gact),
 };
 
 static __net_init int gact_init_net(struct net *net)
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 845ab51..141a06e 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -37,6 +37,7 @@
 
 static int ife_net_id;
 static int max_metacnt = IFE_META_MAX + 1;
+static struct tc_action_ops act_ife_ops;
 
 static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
 	[TCA_IFE_PARMS] = { .len = sizeof(struct tc_ife)},
@@ -364,7 +365,7 @@ static int dump_metalist(struct sk_buff *skb, struct tcf_ife_info *ife)
 /* under ife->tcf_lock */
 static void _tcf_ife_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 	struct tcf_meta_info *e, *n;
 
 	list_for_each_entry_safe(e, n, &ife->metalist, metalist) {
@@ -382,7 +383,7 @@ static void _tcf_ife_cleanup(struct tc_action *a, int bind)
 
 static void tcf_ife_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 
 	spin_lock_bh(&ife->tcf_lock);
 	_tcf_ife_cleanup(a, bind);
@@ -417,7 +418,7 @@ static int populate_metalist(struct tcf_ife_info *ife, struct nlattr **tb,
 }
 
 static int tcf_ife_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action *a,
+			struct nlattr *est, struct tc_action **a,
 			int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
@@ -451,25 +452,25 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		**/
 		if (!tb[TCA_IFE_TYPE]) {
 			if (exists)
-				tcf_hash_release(a, bind);
+				tcf_hash_release(*a, bind);
 			pr_info("You MUST pass etherype for encoding\n");
 			return -EINVAL;
 		}
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, parm->index, est, a, sizeof(*ife),
+		ret = tcf_hash_create(tn, parm->index, est, a, &act_ife_ops,
 				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	ife = to_ife(a);
+	ife = to_ife(*a);
 	ife->flags = parm->flags;
 
 	if (parm->flags & IFE_ENCODE) {
@@ -507,9 +508,9 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		if (err) {
 metadata_parse_err:
 			if (exists)
-				tcf_hash_release(a, bind);
+				tcf_hash_release(*a, bind);
 			if (ret == ACT_P_CREATED)
-				_tcf_ife_cleanup(a, bind);
+				_tcf_ife_cleanup(*a, bind);
 
 			if (exists)
 				spin_unlock_bh(&ife->tcf_lock);
@@ -529,7 +530,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		err = use_all_metadata(ife);
 		if (err) {
 			if (ret == ACT_P_CREATED)
-				_tcf_ife_cleanup(a, bind);
+				_tcf_ife_cleanup(*a, bind);
 
 			if (exists)
 				spin_unlock_bh(&ife->tcf_lock);
@@ -541,7 +542,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		spin_unlock_bh(&ife->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 
 	return ret;
 }
@@ -550,7 +551,7 @@ static int tcf_ife_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 			int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 	struct tc_ife opt = {
 		.index = ife->tcf_index,
 		.refcnt = ife->tcf_refcnt - ref,
@@ -623,7 +624,7 @@ struct meta_tlvhdr {
 static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
 	u16 ifehdrln = ifehdr->metalen;
@@ -695,7 +696,7 @@ static int ife_get_sz(struct sk_buff *skb, struct tcf_ife_info *ife)
 static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ethhdr *oethh;	/* outer ether header */
 	struct ethhdr *iethh;	/* inner eth header */
@@ -799,7 +800,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 static int tcf_ife_act(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
 {
-	struct tcf_ife_info *ife = a->priv;
+	struct tcf_ife_info *ife = to_ife(a);
 
 	if (ife->flags & IFE_ENCODE)
 		return tcf_ife_encode(skb, a, res);
@@ -819,14 +820,14 @@ static int tcf_ife_act(struct sk_buff *skb, const struct tc_action *a,
 
 static int tcf_ife_walker(struct net *net, struct sk_buff *skb,
 			  struct netlink_callback *cb, int type,
-			  struct tc_action *a)
+			  const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_ife_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_ife_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 
@@ -843,6 +844,7 @@ static struct tc_action_ops act_ife_ops = {
 	.init = tcf_ife_init,
 	.walk = tcf_ife_walker,
 	.lookup = tcf_ife_search,
+	.size =	sizeof(struct tcf_ife_info),
 };
 
 static __net_init int ife_init_net(struct net *net)
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index b8c5060..378c1c9 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -31,8 +31,10 @@
 #define IPT_TAB_MASK     15
 
 static int ipt_net_id;
+static struct tc_action_ops act_ipt_ops;
 
 static int xt_net_id;
+static struct tc_action_ops act_xt_ops;
 
 static int ipt_init_target(struct xt_entry_target *t, char *table,
 			   unsigned int hook)
@@ -90,8 +92,8 @@ static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
 };
 
 static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
-			  struct nlattr *est, struct tc_action *a, int ovr,
-			  int bind)
+			  struct nlattr *est, struct tc_action **a,
+			  const struct tc_action_ops *ops, int ovr, int bind)
 {
 	struct nlattr *tb[TCA_IPT_MAX + 1];
 	struct tcf_ipt *ipt;
@@ -118,19 +120,19 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 
 	if (tb[TCA_IPT_HOOK] == NULL || tb[TCA_IPT_TARG] == NULL) {
 		if (exists)
-			tcf_hash_release(a, bind);
+			tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 
 	td = (struct xt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
 	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size) {
 		if (exists)
-			tcf_hash_release(a, bind);
+			tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 
 	if (!exists) {
-		ret = tcf_hash_create(tn, index, est, a, sizeof(*ipt), bind,
+		ret = tcf_hash_create(tn, index, est, a, ops, bind,
 				      false);
 		if (ret)
 			return ret;
@@ -138,13 +140,11 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	} else {
 		if (bind)/* dont override defaults */
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 
 		if (!ovr)
 			return -EEXIST;
 	}
-	ipt = to_ipt(a);
-
 	hook = nla_get_u32(tb[TCA_IPT_HOOK]);
 
 	err = -ENOMEM;
@@ -163,6 +163,8 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	if (err < 0)
 		goto err3;
 
+	ipt = to_ipt(*a);
+
 	spin_lock_bh(&ipt->tcf_lock);
 	if (ret != ACT_P_CREATED) {
 		ipt_destroy_target(ipt->tcfi_t);
@@ -174,7 +176,7 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	ipt->tcfi_hook  = hook;
 	spin_unlock_bh(&ipt->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 
 err3:
@@ -183,33 +185,33 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	kfree(tname);
 err1:
 	if (ret == ACT_P_CREATED)
-		tcf_hash_cleanup(a, est);
+		tcf_hash_cleanup(*a, est);
 	return err;
 }
 
 static int tcf_ipt_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action *a, int ovr,
+			struct nlattr *est, struct tc_action **a, int ovr,
 			int bind)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
-	return __tcf_ipt_init(tn, nla, est, a, ovr, bind);
+	return __tcf_ipt_init(tn, nla, est, a, &act_ipt_ops, ovr, bind);
 }
 
 static int tcf_xt_init(struct net *net, struct nlattr *nla,
-		       struct nlattr *est, struct tc_action *a, int ovr,
+		       struct nlattr *est, struct tc_action **a, int ovr,
 		       int bind)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
-	return __tcf_ipt_init(tn, nla, est, a, ovr, bind);
+	return __tcf_ipt_init(tn, nla, est, a, &act_xt_ops, ovr, bind);
 }
 
 static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
 	int ret = 0, result = 0;
-	struct tcf_ipt *ipt = a->priv;
+	struct tcf_ipt *ipt = to_ipt(a);
 	struct xt_action_param par;
 
 	if (skb_unclone(skb, GFP_ATOMIC))
@@ -259,7 +261,7 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 			int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_ipt *ipt = a->priv;
+	struct tcf_ipt *ipt = to_ipt(a);
 	struct xt_entry_target *t;
 	struct tcf_t tm;
 	struct tc_cnt c;
@@ -299,14 +301,14 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 
 static int tcf_ipt_walker(struct net *net, struct sk_buff *skb,
 			  struct netlink_callback *cb, int type,
-			  struct tc_action *a)
+			  const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_ipt_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_ipt_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
@@ -323,6 +325,7 @@ static struct tc_action_ops act_ipt_ops = {
 	.init		=	tcf_ipt_init,
 	.walk		=	tcf_ipt_walker,
 	.lookup		=	tcf_ipt_search,
+	.size		=	sizeof(struct tcf_ipt),
 };
 
 static __net_init int ipt_init_net(struct net *net)
@@ -348,14 +351,14 @@ static struct pernet_operations ipt_net_ops = {
 
 static int tcf_xt_walker(struct net *net, struct sk_buff *skb,
 			 struct netlink_callback *cb, int type,
-			 struct tc_action *a)
+			 const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_xt_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_xt_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
@@ -372,6 +375,7 @@ static struct tc_action_ops act_xt_ops = {
 	.init		=	tcf_xt_init,
 	.walk		=	tcf_xt_walker,
 	.lookup		=	tcf_xt_search,
+	.size		=	sizeof(struct tcf_ipt),
 };
 
 static __net_init int xt_init_net(struct net *net)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 70cfbbf..6038c85 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -52,9 +52,10 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 };
 
 static int mirred_net_id;
+static struct tc_action_ops act_mirred_ops;
 
 static int tcf_mirred_init(struct net *net, struct nlattr *nla,
-			   struct nlattr *est, struct tc_action *a, int ovr,
+			   struct nlattr *est, struct tc_action **a, int ovr,
 			   int bind)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
@@ -84,14 +85,14 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		break;
 	default:
 		if (exists)
-			tcf_hash_release(a, bind);
+			tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 	if (parm->ifindex) {
 		dev = __dev_get_by_index(net, parm->ifindex);
 		if (dev == NULL) {
 			if (exists)
-				tcf_hash_release(a, bind);
+				tcf_hash_release(*a, bind);
 			return -ENODEV;
 		}
 		switch (dev->type) {
@@ -115,16 +116,16 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		if (dev == NULL)
 			return -EINVAL;
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*m), bind, true);
+				      &act_mirred_ops, bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
-	m = to_mirred(a);
+	m = to_mirred(*a);
 
 	ASSERT_RTNL();
 	m->tcf_action = parm->action;
@@ -142,7 +143,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		spin_lock_bh(&mirred_list_lock);
 		list_add(&m->tcfm_list, &mirred_list);
 		spin_unlock_bh(&mirred_list_lock);
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	}
 
 	return ret;
@@ -151,7 +152,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
-	struct tcf_mirred *m = a->priv;
+	struct tcf_mirred *m = to_mirred(a);
 	struct net_device *dev;
 	struct sk_buff *skb2;
 	int retval, err;
@@ -206,7 +207,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_mirred *m = a->priv;
+	struct tcf_mirred *m = to_mirred(a);
 	struct tc_mirred opt = {
 		.index   = m->tcf_index,
 		.action  = m->tcf_action,
@@ -232,14 +233,14 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 
 static int tcf_mirred_walker(struct net *net, struct sk_buff *skb,
 			     struct netlink_callback *cb, int type,
-			     struct tc_action *a)
+			     const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_mirred_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_mirred_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 
@@ -284,6 +285,7 @@ static struct tc_action_ops act_mirred_ops = {
 	.init		=	tcf_mirred_init,
 	.walk		=	tcf_mirred_walker,
 	.lookup		=	tcf_mirred_search,
+	.size		=	sizeof(struct tcf_mirred),
 };
 
 static __net_init int mirred_init_net(struct net *net)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 06ccb03..8e8b0cc 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -32,13 +32,14 @@
 #define NAT_TAB_MASK	15
 
 static int nat_net_id;
+static struct tc_action_ops act_nat_ops;
 
 static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
 };
 
 static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
-			struct tc_action *a, int ovr, int bind)
+			struct tc_action **a, int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 	struct nlattr *tb[TCA_NAT_MAX + 1];
@@ -59,18 +60,18 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*p), bind, false);
+				      &act_nat_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
-	p = to_tcf_nat(a);
+	p = to_tcf_nat(*a);
 
 	spin_lock_bh(&p->tcf_lock);
 	p->old_addr = parm->old_addr;
@@ -82,7 +83,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	spin_unlock_bh(&p->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 
 	return ret;
 }
@@ -90,7 +91,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 		   struct tcf_result *res)
 {
-	struct tcf_nat *p = a->priv;
+	struct tcf_nat *p = to_tcf_nat(a);
 	struct iphdr *iph;
 	__be32 old_addr;
 	__be32 new_addr;
@@ -248,7 +249,7 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 			int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_nat *p = a->priv;
+	struct tcf_nat *p = to_tcf_nat(a);
 	struct tc_nat opt = {
 		.old_addr = p->old_addr,
 		.new_addr = p->new_addr,
@@ -278,14 +279,14 @@ static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_nat_walker(struct net *net, struct sk_buff *skb,
 			  struct netlink_callback *cb, int type,
-			  struct tc_action *a)
+			  const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_nat_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_nat_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 
@@ -301,6 +302,7 @@ static struct tc_action_ops act_nat_ops = {
 	.init		=	tcf_nat_init,
 	.walk		=	tcf_nat_walker,
 	.lookup		=	tcf_nat_search,
+	.size		=	sizeof(struct tcf_nat),
 };
 
 static __net_init int nat_init_net(struct net *net)
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 82d3c14..b54d56d 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -26,13 +26,14 @@
 #define PEDIT_TAB_MASK	15
 
 static int pedit_net_id;
+static struct tc_action_ops act_pedit_ops;
 
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
 };
 
 static int tcf_pedit_init(struct net *net, struct nlattr *nla,
-			  struct nlattr *est, struct tc_action *a,
+			  struct nlattr *est, struct tc_action **a,
 			  int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
@@ -61,23 +62,23 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		if (!parm->nkeys)
 			return -EINVAL;
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*p), bind, false);
+				      &act_pedit_ops, bind, false);
 		if (ret)
 			return ret;
-		p = to_pedit(a);
+		p = to_pedit(*a);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
-			tcf_hash_cleanup(a, est);
+			tcf_hash_cleanup(*a, est);
 			return -ENOMEM;
 		}
 		ret = ACT_P_CREATED;
 	} else {
 		if (bind)
 			return 0;
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
-		p = to_pedit(a);
+		p = to_pedit(*a);
 		if (p->tcfp_nkeys && p->tcfp_nkeys != parm->nkeys) {
 			keys = kmalloc(ksize, GFP_KERNEL);
 			if (keys == NULL)
@@ -96,13 +97,13 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	memcpy(p->tcfp_keys, parm->keys, ksize);
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 }
 
 static void tcf_pedit_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_pedit *p = a->priv;
+	struct tcf_pedit *p = to_pedit(a);
 	struct tc_pedit_key *keys = p->tcfp_keys;
 	kfree(keys);
 }
@@ -110,7 +111,7 @@ static void tcf_pedit_cleanup(struct tc_action *a, int bind)
 static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		     struct tcf_result *res)
 {
-	struct tcf_pedit *p = a->priv;
+	struct tcf_pedit *p = to_pedit(a);
 	int i;
 	unsigned int off;
 
@@ -177,7 +178,7 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 			  int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_pedit *p = a->priv;
+	struct tcf_pedit *p = to_pedit(a);
 	struct tc_pedit *opt;
 	struct tcf_t t;
 	int s;
@@ -216,14 +217,14 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_pedit_walker(struct net *net, struct sk_buff *skb,
 			    struct netlink_callback *cb, int type,
-			    struct tc_action *a)
+			    const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_pedit_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_pedit_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 
@@ -240,6 +241,7 @@ static struct tc_action_ops act_pedit_ops = {
 	.init		=	tcf_pedit_init,
 	.walk		=	tcf_pedit_walker,
 	.lookup		=	tcf_pedit_search,
+	.size		=	sizeof(struct tcf_pedit),
 };
 
 static __net_init int pedit_init_net(struct net *net)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 1e8ede3..28c808d 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -37,8 +37,8 @@ struct tcf_police {
 	struct psched_ratecfg	peak;
 	bool			peak_present;
 };
-#define to_police(pc)	\
-	container_of(pc->priv, struct tcf_police, common)
+
+#define to_police(pc) ((struct tcf_police *)pc)
 
 #define POL_TAB_MASK     15
 
@@ -56,15 +56,14 @@ struct tc_police_compat {
 /* Each policer is serialized by its individual spinlock */
 
 static int police_net_id;
+static struct tc_action_ops act_police_ops;
 
 static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
 				 struct netlink_callback *cb, int type,
-				 struct tc_action *a)
+				 const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
 	struct tcf_hashinfo *hinfo = tn->hinfo;
-	struct hlist_head *head;
-	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
@@ -73,21 +72,22 @@ static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
 	s_i = cb->args[0];
 
 	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
+		struct hlist_head *head;
+		struct tcf_common *p;
+
 		head = &hinfo->htab[tcf_hash(i, POL_TAB_MASK)];
 
 		hlist_for_each_entry_rcu(p, head, tcfc_head) {
 			index++;
 			if (index < s_i)
 				continue;
-			a->priv = p;
-			a->order = index;
-			nest = nla_nest_start(skb, a->order);
+			nest = nla_nest_start(skb, index);
 			if (nest == NULL)
 				goto nla_put_failure;
 			if (type == RTM_DELACTION)
-				err = tcf_action_dump_1(skb, a, 0, 1);
+				err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 1);
 			else
-				err = tcf_action_dump_1(skb, a, 0, 0);
+				err = tcf_action_dump_1(skb, (struct tc_action *)p, 0, 0);
 			if (err < 0) {
 				index--;
 				nla_nest_cancel(skb, nest);
@@ -116,7 +116,7 @@ static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
 };
 
 static int tcf_act_police_init(struct net *net, struct nlattr *nla,
-			       struct nlattr *est, struct tc_action *a,
+			       struct nlattr *est, struct tc_action **a,
 			       int ovr, int bind)
 {
 	int ret = 0, err;
@@ -142,13 +142,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_POLICE_TBF]);
 
 	if (parm->index) {
-		if (tcf_hash_search(tn, a, parm->index)) {
-			police = to_police(a);
-			if (bind) {
-				police->tcf_bindcnt += 1;
-				police->tcf_refcnt += 1;
-				return 0;
-			}
+		if (tcf_hash_check(tn, parm->index, a, bind)) {
 			if (ovr)
 				goto override;
 			/* not replacing */
@@ -156,13 +150,13 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 		}
 	} else {
 		ret = tcf_hash_create(tn, parm->index, NULL, a,
-				      sizeof(*police), bind, false);
+				      &act_police_ops, bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
 	}
 
-	police = to_police(a);
+	police = to_police(*a);
 override:
 	if (parm->rate.rate) {
 		err = -ENOMEM;
@@ -235,7 +229,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 		return ret;
 
 	police->tcfp_t_c = ktime_get_ns();
-	tcf_hash_insert(tn, a);
+	tcf_hash_insert(tn, *a);
 
 	return ret;
 
@@ -245,14 +239,14 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	qdisc_put_rtab(P_tab);
 	qdisc_put_rtab(R_tab);
 	if (ret == ACT_P_CREATED)
-		tcf_hash_cleanup(a, est);
+		tcf_hash_cleanup(*a, est);
 	return err;
 }
 
 static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			  struct tcf_result *res)
 {
-	struct tcf_police *police = a->priv;
+	struct tcf_police *police = to_police(a);
 	s64 now;
 	s64 toks;
 	s64 ptoks = 0;
@@ -311,7 +305,7 @@ static int
 tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_police *police = a->priv;
+	struct tcf_police *police = to_police(a);
 	struct tc_police opt = {
 		.index = police->tcf_index,
 		.action = police->tcf_action,
@@ -349,7 +343,7 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	return -1;
 }
 
-static int tcf_police_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_police_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
 
@@ -369,6 +363,7 @@ static struct tc_action_ops act_police_ops = {
 	.init		=	tcf_act_police_init,
 	.walk		=	tcf_act_police_walker,
 	.lookup		=	tcf_police_search,
+	.size		=	sizeof(struct tcf_police),
 };
 
 static __net_init int police_init_net(struct net *net)
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 318328d3..289af6f 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -27,12 +27,13 @@
 #define SIMP_TAB_MASK     7
 
 static int simp_net_id;
+static struct tc_action_ops act_simp_ops;
 
 #define SIMP_MAX_DATA	32
 static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
-	struct tcf_defact *d = a->priv;
+	struct tcf_defact *d = to_defact(a);
 
 	spin_lock(&d->tcf_lock);
 	tcf_lastuse_update(&d->tcf_tm);
@@ -79,7 +80,7 @@ static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
 };
 
 static int tcf_simp_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action *a,
+			 struct nlattr *est, struct tc_action **a,
 			 int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
@@ -100,7 +101,6 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	if (tb[TCA_DEF_PARMS] == NULL)
 		return -EINVAL;
 
-
 	parm = nla_data(tb[TCA_DEF_PARMS]);
 	exists = tcf_hash_check(tn, parm->index, a, bind);
 	if (exists && bind)
@@ -108,7 +108,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 
 	if (tb[TCA_DEF_DATA] == NULL) {
 		if (exists)
-			tcf_hash_release(a, bind);
+			tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 
@@ -116,22 +116,22 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 
 	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*d), bind, false);
+				      &act_simp_ops, bind, false);
 		if (ret)
 			return ret;
 
-		d = to_defact(a);
+		d = to_defact(*a);
 		ret = alloc_defdata(d, defdata);
 		if (ret < 0) {
-			tcf_hash_cleanup(a, est);
+			tcf_hash_cleanup(*a, est);
 			return ret;
 		}
 		d->tcf_action = parm->action;
 		ret = ACT_P_CREATED;
 	} else {
-		d = to_defact(a);
+		d = to_defact(*a);
 
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 
@@ -139,7 +139,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	}
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 }
 
@@ -147,7 +147,7 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 			 int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_defact *d = a->priv;
+	struct tcf_defact *d = to_defact(a);
 	struct tc_defact opt = {
 		.index   = d->tcf_index,
 		.refcnt  = d->tcf_refcnt - ref,
@@ -172,14 +172,14 @@ static int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_simp_walker(struct net *net, struct sk_buff *skb,
 			   struct netlink_callback *cb, int type,
-			   struct tc_action *a)
+			   const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_simp_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_simp_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 
@@ -196,6 +196,7 @@ static struct tc_action_ops act_simp_ops = {
 	.init		=	tcf_simp_init,
 	.walk		=	tcf_simp_walker,
 	.lookup		=	tcf_simp_search,
+	.size		=	sizeof(struct tcf_defact),
 };
 
 static __net_init int simp_init_net(struct net *net)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 8e573c0..a133dcb 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -30,11 +30,12 @@
 #define SKBEDIT_TAB_MASK     15
 
 static int skbedit_net_id;
+static struct tc_action_ops act_skbedit_ops;
 
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
 {
-	struct tcf_skbedit *d = a->priv;
+	struct tcf_skbedit *d = to_skbedit(a);
 
 	spin_lock(&d->tcf_lock);
 	tcf_lastuse_update(&d->tcf_tm);
@@ -63,7 +64,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 };
 
 static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
-			    struct nlattr *est, struct tc_action *a,
+			    struct nlattr *est, struct tc_action **a,
 			    int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
@@ -114,21 +115,21 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		return 0;
 
 	if (!flags) {
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 
 	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*d), bind, false);
+				      &act_skbedit_ops, bind, false);
 		if (ret)
 			return ret;
 
-		d = to_skbedit(a);
+		d = to_skbedit(*a);
 		ret = ACT_P_CREATED;
 	} else {
-		d = to_skbedit(a);
-		tcf_hash_release(a, bind);
+		d = to_skbedit(*a);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
@@ -150,7 +151,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&d->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 }
 
@@ -158,7 +159,7 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 			    int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_skbedit *d = a->priv;
+	struct tcf_skbedit *d = to_skbedit(a);
 	struct tc_skbedit opt = {
 		.index   = d->tcf_index,
 		.refcnt  = d->tcf_refcnt - ref,
@@ -194,14 +195,14 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_skbedit_walker(struct net *net, struct sk_buff *skb,
 			      struct netlink_callback *cb, int type,
-			      struct tc_action *a)
+			      const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_skbedit_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_skbedit_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 
@@ -217,6 +218,7 @@ static struct tc_action_ops act_skbedit_ops = {
 	.init		=	tcf_skbedit_init,
 	.walk		=	tcf_skbedit_walker,
 	.lookup		=	tcf_skbedit_search,
+	.size		=	sizeof(struct tcf_skbedit),
 };
 
 static __net_init int skbedit_init_net(struct net *net)
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index db9b7ed..691409d 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -22,11 +22,12 @@
 #define VLAN_TAB_MASK     15
 
 static int vlan_net_id;
+static struct tc_action_ops act_vlan_ops;
 
 static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
-	struct tcf_vlan *v = a->priv;
+	struct tcf_vlan *v = to_vlan(a);
 	int action;
 	int err;
 
@@ -67,7 +68,7 @@ static const struct nla_policy vlan_policy[TCA_VLAN_MAX + 1] = {
 };
 
 static int tcf_vlan_init(struct net *net, struct nlattr *nla,
-			 struct nlattr *est, struct tc_action *a,
+			 struct nlattr *est, struct tc_action **a,
 			 int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
@@ -100,13 +101,13 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	case TCA_VLAN_ACT_PUSH:
 		if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
 			if (exists)
-				tcf_hash_release(a, bind);
+				tcf_hash_release(*a, bind);
 			return -EINVAL;
 		}
 		push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
 		if (push_vid >= VLAN_VID_MASK) {
 			if (exists)
-				tcf_hash_release(a, bind);
+				tcf_hash_release(*a, bind);
 			return -ERANGE;
 		}
 
@@ -125,25 +126,25 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 		break;
 	default:
 		if (exists)
-			tcf_hash_release(a, bind);
+			tcf_hash_release(*a, bind);
 		return -EINVAL;
 	}
 	action = parm->v_action;
 
 	if (!exists) {
 		ret = tcf_hash_create(tn, parm->index, est, a,
-				      sizeof(*v), bind, false);
+				      &act_vlan_ops, bind, false);
 		if (ret)
 			return ret;
 
 		ret = ACT_P_CREATED;
 	} else {
-		tcf_hash_release(a, bind);
+		tcf_hash_release(*a, bind);
 		if (!ovr)
 			return -EEXIST;
 	}
 
-	v = to_vlan(a);
+	v = to_vlan(*a);
 
 	spin_lock_bh(&v->tcf_lock);
 
@@ -156,7 +157,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	spin_unlock_bh(&v->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(tn, a);
+		tcf_hash_insert(tn, *a);
 	return ret;
 }
 
@@ -164,7 +165,7 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 			 int bind, int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tcf_vlan *v = a->priv;
+	struct tcf_vlan *v = to_vlan(a);
 	struct tc_vlan opt = {
 		.index    = v->tcf_index,
 		.refcnt   = v->tcf_refcnt - ref,
@@ -195,14 +196,14 @@ static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
 
 static int tcf_vlan_walker(struct net *net, struct sk_buff *skb,
 			   struct netlink_callback *cb, int type,
-			   struct tc_action *a)
+			   const struct tc_action_ops *ops)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 
-	return tcf_generic_walker(tn, skb, cb, type, a);
+	return tcf_generic_walker(tn, skb, cb, type, ops);
 }
 
-static int tcf_vlan_search(struct net *net, struct tc_action *a, u32 index)
+static int tcf_vlan_search(struct net *net, struct tc_action **a, u32 index)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 
@@ -218,6 +219,7 @@ static struct tc_action_ops act_vlan_ops = {
 	.init		=	tcf_vlan_init,
 	.walk		=	tcf_vlan_walker,
 	.lookup		=	tcf_vlan_search,
+	.size		=	sizeof(struct tcf_vlan),
 };
 
 static __net_init int vlan_init_net(struct net *net)
-- 
2.1.0
