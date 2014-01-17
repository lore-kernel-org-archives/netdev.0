From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/6] net_sched: act: move tcf_hashinfo_init() into tcf_register_action()
Date: Fri, 17 Jan 2014 11:37:06 -0800
Message-ID: <1389987427-14085-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59904 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbaAQTh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:27 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so125133pdj.3
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:27 -0800 (PST)
In-Reply-To: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  6 +++---
 net/sched/act_api.c     | 22 ++++++++++++++--------
 net/sched/act_csum.c    |  8 +-------
 net/sched/act_gact.c    |  8 +-------
 net/sched/act_ipt.c     | 14 +++-----------
 net/sched/act_mirred.c  | 10 +---------
 net/sched/act_nat.c     |  9 +--------
 net/sched/act_pedit.c   |  9 +--------
 net/sched/act_police.c  | 17 ++++-------------
 net/sched/act_simple.c  | 14 ++------------
 net/sched/act_skbedit.c |  8 +-------
 11 files changed, 32 insertions(+), 93 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9263ace..3198b0a 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -75,7 +75,7 @@ static inline void tcf_hashinfo_destroy(struct tcf_hashinfo *hf)
 
 struct tc_action {
 	void			*priv;
-	const struct tc_action_ops	*ops;
+	struct tc_action_ops	*ops;
 	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32			order;
 	struct list_head	list;
@@ -84,7 +84,7 @@ struct tc_action {
 #define TCA_CAP_NONE 0
 struct tc_action_ops {
 	struct list_head head;
-	struct tcf_hashinfo *hinfo;
+	struct tcf_hashinfo hinfo;
 	char    kind[IFNAMSIZ];
 	__u32   type; /* TBD to match kind */
 	__u32 	capab;  /* capabilities includes 4 bit version */
@@ -109,7 +109,7 @@ int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action *a);
 
-int tcf_register_action(struct tc_action_ops *a);
+int tcf_register_action(struct tc_action_ops *a, unsigned int mask);
 int tcf_unregister_action(struct tc_action_ops *a);
 void tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 453a47e..5ac0392 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -30,7 +30,7 @@
 void tcf_hash_destroy(struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfc_head);
@@ -69,7 +69,7 @@ EXPORT_SYMBOL(tcf_hash_release);
 static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			   struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
@@ -117,7 +117,7 @@ nla_put_failure:
 
 static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct hlist_head *head;
 	struct hlist_node *n;
 	struct tcf_common *p;
@@ -192,7 +192,7 @@ EXPORT_SYMBOL(tcf_hash_new_index);
 
 int tcf_hash_search(struct tc_action *a, u32 index)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
 
 	if (p) {
@@ -205,7 +205,7 @@ EXPORT_SYMBOL(tcf_hash_search);
 
 int tcf_hash_check(u32 index, struct tc_action *a, int bind)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct tcf_common *p = NULL;
 	if (index && (p = tcf_hash_lookup(index, hinfo)) != NULL) {
 		if (bind)
@@ -231,7 +231,7 @@ EXPORT_SYMBOL(tcf_hash_cleanup);
 int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 		    int size, int bind)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
 	if (unlikely(!p))
@@ -262,7 +262,7 @@ EXPORT_SYMBOL(tcf_hash_create);
 void tcf_hash_insert(struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
 	spin_lock_bh(&hinfo->lock);
@@ -274,9 +274,10 @@ EXPORT_SYMBOL(tcf_hash_insert);
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
 
-int tcf_register_action(struct tc_action_ops *act)
+int tcf_register_action(struct tc_action_ops *act, unsigned int mask)
 {
 	struct tc_action_ops *a;
+	int err;
 
 	/* Must supply act, dump and init */
 	if (!act->act || !act->dump || !act->init)
@@ -288,6 +289,10 @@ int tcf_register_action(struct tc_action_ops *act)
 	if (!act->walk)
 		act->walk = tcf_generic_walker;
 
+	err = tcf_hashinfo_init(&act->hinfo, mask);
+	if (err)
+		return err;
+
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
@@ -310,6 +315,7 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
 			list_del(&act->head);
+			tcf_hashinfo_destroy(&act->hinfo);
 			err = 0;
 			break;
 		}
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 15e6515..93394d5 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -37,7 +37,6 @@
 #include <net/tc_act/tc_csum.h>
 
 #define CSUM_TAB_MASK 15
-static struct tcf_hashinfo csum_hash_info;
 
 static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
@@ -561,7 +560,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_csum_ops = {
 	.kind		= "csum",
-	.hinfo		= &csum_hash_info,
 	.type		= TCA_ACT_CSUM,
 	.capab		= TCA_CAP_NONE,
 	.owner		= THIS_MODULE,
@@ -575,11 +573,7 @@ MODULE_LICENSE("GPL");
 
 static int __init csum_init_module(void)
 {
-	int err = tcf_hashinfo_init(&csum_hash_info, CSUM_TAB_MASK);
-	if (err)
-		return err;
-
-	return tcf_register_action(&act_csum_ops);
+	return tcf_register_action(&act_csum_ops, CSUM_TAB_MASK);
 }
 
 static void __exit csum_cleanup_module(void)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e09b6e5..0002a12 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -24,7 +24,6 @@
 #include <net/tc_act/tc_gact.h>
 
 #define GACT_TAB_MASK	15
-static struct tcf_hashinfo gact_hash_info;
 
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
@@ -180,7 +179,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_gact_ops = {
 	.kind		=	"gact",
-	.hinfo		=	&gact_hash_info,
 	.type		=	TCA_ACT_GACT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -195,21 +193,17 @@ MODULE_LICENSE("GPL");
 
 static int __init gact_init_module(void)
 {
-	int err = tcf_hashinfo_init(&gact_hash_info, GACT_TAB_MASK);
-	if (err)
-		return err;
 #ifdef CONFIG_GACT_PROB
 	pr_info("GACT probability on\n");
 #else
 	pr_info("GACT probability NOT on\n");
 #endif
-	return tcf_register_action(&act_gact_ops);
+	return tcf_register_action(&act_gact_ops, GACT_TAB_MASK);
 }
 
 static void __exit gact_cleanup_module(void)
 {
 	tcf_unregister_action(&act_gact_ops);
-	tcf_hashinfo_destroy(&gact_hash_info);
 }
 
 module_init(gact_init_module);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 6096310..a00a2cb 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -29,7 +29,6 @@
 
 
 #define IPT_TAB_MASK     15
-static struct tcf_hashinfo ipt_hash_info;
 
 static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
 {
@@ -262,7 +261,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_ipt_ops = {
 	.kind		=	"ipt",
-	.hinfo		=	&ipt_hash_info,
 	.type		=	TCA_ACT_IPT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -274,7 +272,6 @@ static struct tc_action_ops act_ipt_ops = {
 
 static struct tc_action_ops act_xt_ops = {
 	.kind		=	"xt",
-	.hinfo		=	&ipt_hash_info,
 	.type		=	TCA_ACT_XT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -291,20 +288,16 @@ MODULE_ALIAS("act_xt");
 
 static int __init ipt_init_module(void)
 {
-	int ret1, ret2, err;
-	err = tcf_hashinfo_init(&ipt_hash_info, IPT_TAB_MASK);
-	if (err)
-		return err;
+	int ret1, ret2;
 
-	ret1 = tcf_register_action(&act_xt_ops);
+	ret1 = tcf_register_action(&act_xt_ops, IPT_TAB_MASK);
 	if (ret1 < 0)
 		printk("Failed to load xt action\n");
-	ret2 = tcf_register_action(&act_ipt_ops);
+	ret2 = tcf_register_action(&act_ipt_ops, IPT_TAB_MASK);
 	if (ret2 < 0)
 		printk("Failed to load ipt action\n");
 
 	if (ret1 < 0 && ret2 < 0) {
-		tcf_hashinfo_destroy(&ipt_hash_info);
 		return ret1;
 	} else
 		return 0;
@@ -314,7 +307,6 @@ static void __exit ipt_cleanup_module(void)
 {
 	tcf_unregister_action(&act_xt_ops);
 	tcf_unregister_action(&act_ipt_ops);
-	tcf_hashinfo_destroy(&ipt_hash_info);
 }
 
 module_init(ipt_init_module);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 93e5209..e7c4e0a 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -31,7 +31,6 @@
 
 #define MIRRED_TAB_MASK     7
 static LIST_HEAD(mirred_list);
-static struct tcf_hashinfo mirred_hash_info;
 
 static void tcf_mirred_release(struct tc_action *a, int bind)
 {
@@ -234,7 +233,6 @@ static struct notifier_block mirred_device_notifier = {
 
 static struct tc_action_ops act_mirred_ops = {
 	.kind		=	"mirred",
-	.hinfo		=	&mirred_hash_info,
 	.type		=	TCA_ACT_MIRRED,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -254,19 +252,13 @@ static int __init mirred_init_module(void)
 	if (err)
 		return err;
 
-	err = tcf_hashinfo_init(&mirred_hash_info, MIRRED_TAB_MASK);
-	if (err) {
-		unregister_netdevice_notifier(&mirred_device_notifier);
-		return err;
-	}
 	pr_info("Mirror/redirect action on\n");
-	return tcf_register_action(&act_mirred_ops);
+	return tcf_register_action(&act_mirred_ops, MIRRED_TAB_MASK);
 }
 
 static void __exit mirred_cleanup_module(void)
 {
 	tcf_unregister_action(&act_mirred_ops);
-	tcf_hashinfo_destroy(&mirred_hash_info);
 	unregister_netdevice_notifier(&mirred_device_notifier);
 }
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index e1ae2e5..6523980 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -31,8 +31,6 @@
 
 #define NAT_TAB_MASK	15
 
-static struct tcf_hashinfo nat_hash_info;
-
 static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
 };
@@ -284,7 +282,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_nat_ops = {
 	.kind		=	"nat",
-	.hinfo		=	&nat_hash_info,
 	.type		=	TCA_ACT_NAT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -298,16 +295,12 @@ MODULE_LICENSE("GPL");
 
 static int __init nat_init_module(void)
 {
-	int err = tcf_hashinfo_init(&nat_hash_info, NAT_TAB_MASK);
-	if (err)
-		return err;
-	return tcf_register_action(&act_nat_ops);
+	return tcf_register_action(&act_nat_ops, NAT_TAB_MASK);
 }
 
 static void __exit nat_cleanup_module(void)
 {
 	tcf_unregister_action(&act_nat_ops);
-	tcf_hashinfo_destroy(&nat_hash_info);
 }
 
 module_init(nat_init_module);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index cd08b3b..22cf016 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -25,8 +25,6 @@
 
 #define PEDIT_TAB_MASK	15
 
-static struct tcf_hashinfo pedit_hash_info;
-
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
 };
@@ -218,7 +216,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_pedit_ops = {
 	.kind		=	"pedit",
-	.hinfo		=	&pedit_hash_info,
 	.type		=	TCA_ACT_PEDIT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -234,15 +231,11 @@ MODULE_LICENSE("GPL");
 
 static int __init pedit_init_module(void)
 {
-	int err = tcf_hashinfo_init(&pedit_hash_info, PEDIT_TAB_MASK);
-	if (err)
-		return err;
-	return tcf_register_action(&act_pedit_ops);
+	return tcf_register_action(&act_pedit_ops, PEDIT_TAB_MASK);
 }
 
 static void __exit pedit_cleanup_module(void)
 {
-	tcf_hashinfo_destroy(&pedit_hash_info);
 	tcf_unregister_action(&act_pedit_ops);
 }
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 143af47..da724b9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -41,7 +41,6 @@ struct tcf_police {
 	container_of(pc, struct tcf_police, common)
 
 #define POL_TAB_MASK     15
-static struct tcf_hashinfo police_hash_info;
 
 /* old policer structure from before tc actions */
 struct tc_police_compat {
@@ -59,7 +58,7 @@ struct tc_police_compat {
 static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			      int type, struct tc_action *a)
 {
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	struct hlist_head *head;
 	struct tcf_common *p;
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
@@ -122,7 +121,7 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	struct tc_police *parm;
 	struct tcf_police *police;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
-	struct tcf_hashinfo *hinfo = a->ops->hinfo;
+	struct tcf_hashinfo *hinfo = &a->ops->hinfo;
 	int size;
 
 	if (nla == NULL)
@@ -234,7 +233,7 @@ override:
 
 	police->tcfp_t_c = ktime_to_ns(ktime_get());
 	police->tcf_index = parm->index ? parm->index :
-		tcf_hash_new_index(a->ops->hinfo);
+		tcf_hash_new_index(hinfo);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	spin_lock_bh(&hinfo->lock);
 	hlist_add_head(&police->tcf_head, &hinfo->htab[h]);
@@ -349,7 +348,6 @@ MODULE_LICENSE("GPL");
 
 static struct tc_action_ops act_police_ops = {
 	.kind		=	"police",
-	.hinfo		=	&police_hash_info,
 	.type		=	TCA_ID_POLICE,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -362,19 +360,12 @@ static struct tc_action_ops act_police_ops = {
 static int __init
 police_init_module(void)
 {
-	int err = tcf_hashinfo_init(&police_hash_info, POL_TAB_MASK);
-	if (err)
-		return err;
-	err = tcf_register_action(&act_police_ops);
-	if (err)
-		tcf_hashinfo_destroy(&police_hash_info);
-	return err;
+	return tcf_register_action(&act_police_ops, POL_TAB_MASK);
 }
 
 static void __exit
 police_cleanup_module(void)
 {
-	tcf_hashinfo_destroy(&police_hash_info);
 	tcf_unregister_action(&act_police_ops);
 }
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index fbdc6eb..29cffff 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -25,7 +25,6 @@
 #include <net/tc_act/tc_defact.h>
 
 #define SIMP_TAB_MASK     7
-static struct tcf_hashinfo simp_hash_info;
 
 #define SIMP_MAX_DATA	32
 static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
@@ -163,7 +162,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_simp_ops = {
 	.kind		=	"simple",
-	.hinfo		=	&simp_hash_info,
 	.type		=	TCA_ACT_SIMP,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -179,23 +177,15 @@ MODULE_LICENSE("GPL");
 
 static int __init simp_init_module(void)
 {
-	int err, ret;
-	err = tcf_hashinfo_init(&simp_hash_info, SIMP_TAB_MASK);
-	if (err)
-		return err;
-
-	ret = tcf_register_action(&act_simp_ops);
+	int ret;
+	ret = tcf_register_action(&act_simp_ops, SIMP_TAB_MASK);
 	if (!ret)
 		pr_info("Simple TC action Loaded\n");
-	else
-		tcf_hashinfo_destroy(&simp_hash_info);
-
 	return ret;
 }
 
 static void __exit simp_cleanup_module(void)
 {
-	tcf_hashinfo_destroy(&simp_hash_info);
 	tcf_unregister_action(&act_simp_ops);
 }
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 2965484..67dfce8 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -28,7 +28,6 @@
 #include <net/tc_act/tc_skbedit.h>
 
 #define SKBEDIT_TAB_MASK     15
-static struct tcf_hashinfo skbedit_hash_info;
 
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
@@ -175,7 +174,6 @@ nla_put_failure:
 
 static struct tc_action_ops act_skbedit_ops = {
 	.kind		=	"skbedit",
-	.hinfo		=	&skbedit_hash_info,
 	.type		=	TCA_ACT_SKBEDIT,
 	.capab		=	TCA_CAP_NONE,
 	.owner		=	THIS_MODULE,
@@ -190,15 +188,11 @@ MODULE_LICENSE("GPL");
 
 static int __init skbedit_init_module(void)
 {
-	int err = tcf_hashinfo_init(&skbedit_hash_info, SKBEDIT_TAB_MASK);
-	if (err)
-		return err;
-	return tcf_register_action(&act_skbedit_ops);
+	return tcf_register_action(&act_skbedit_ops, SKBEDIT_TAB_MASK);
 }
 
 static void __exit skbedit_cleanup_module(void)
 {
-	tcf_hashinfo_destroy(&skbedit_hash_info);
 	tcf_unregister_action(&act_skbedit_ops);
 }
 
-- 
1.8.3.1
