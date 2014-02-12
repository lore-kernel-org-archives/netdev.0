From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v3 3/5] net_sched: act: move tcf_hashinfo_init() into tcf_register_action()
Date: Tue, 11 Feb 2014 17:07:33 -0800
Message-ID: <1392167255-21744-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45520 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbaBLBHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:07:47 -0500
Received: by mail-pa0-f47.google.com with SMTP id kp14so8374621pab.6
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 17:07:47 -0800 (PST)
In-Reply-To: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  2 +-
 net/sched/act_api.c     | 16 +++++++++++++++-
 net/sched/act_csum.c    |  8 +-------
 net/sched/act_gact.c    |  8 +-------
 net/sched/act_ipt.c     | 14 +++-----------
 net/sched/act_mirred.c  | 10 +---------
 net/sched/act_nat.c     |  9 +--------
 net/sched/act_pedit.c   |  9 +--------
 net/sched/act_police.c  | 13 ++-----------
 net/sched/act_simple.c  | 14 ++------------
 net/sched/act_skbedit.c |  8 +-------
 11 files changed, 29 insertions(+), 82 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 3d22f42..969cac6 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -107,7 +107,7 @@ int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action *a);
 
-int tcf_register_action(struct tc_action_ops *a);
+int tcf_register_action(struct tc_action_ops *a, unsigned int mask);
 int tcf_unregister_action(struct tc_action_ops *a);
 void tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index a5bf935..c88d382 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -275,9 +275,10 @@ EXPORT_SYMBOL(tcf_hash_insert);
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
 
-int tcf_register_action(struct tc_action_ops *act)
+int tcf_register_action(struct tc_action_ops *act, unsigned int mask)
 {
 	struct tc_action_ops *a;
+	int err;
 
 	/* Must supply act, dump and init */
 	if (!act->act || !act->dump || !act->init)
@@ -289,10 +290,21 @@ int tcf_register_action(struct tc_action_ops *act)
 	if (!act->walk)
 		act->walk = tcf_generic_walker;
 
+	act->hinfo = kmalloc(sizeof(struct tcf_hashinfo), GFP_KERNEL);
+	if (!act->hinfo)
+		return -ENOMEM;
+	err = tcf_hashinfo_init(act->hinfo, mask);
+	if (err) {
+		kfree(act->hinfo);
+		return err;
+	}
+
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
+			tcf_hashinfo_destroy(act->hinfo);
+			kfree(act->hinfo);
 			return -EEXIST;
 		}
 	}
@@ -311,6 +323,8 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
 			list_del(&act->head);
+			tcf_hashinfo_destroy(act->hinfo);
+			kfree(act->hinfo);
 			err = 0;
 			break;
 		}
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 8df3060..edbf40d 100644
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
 	.owner		= THIS_MODULE,
 	.act		= tcf_csum,
@@ -574,11 +572,7 @@ MODULE_LICENSE("GPL");
 
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
index 094a1b5..d6bcbd9 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_gact,
@@ -194,21 +192,17 @@ MODULE_LICENSE("GPL");
 
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
index 71f29f1..8a64a07 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
@@ -273,7 +271,6 @@ static struct tc_action_ops act_ipt_ops = {
 
 static struct tc_action_ops act_xt_ops = {
 	.kind		=	"xt",
-	.hinfo		=	&ipt_hash_info,
 	.type		=	TCA_ACT_XT,
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_ipt,
@@ -289,20 +286,16 @@ MODULE_ALIAS("act_xt");
 
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
@@ -312,7 +305,6 @@ static void __exit ipt_cleanup_module(void)
 {
 	tcf_unregister_action(&act_xt_ops);
 	tcf_unregister_action(&act_ipt_ops);
-	tcf_hashinfo_destroy(&ipt_hash_info);
 }
 
 module_init(ipt_init_module);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 0f00eb9..4f912c0 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_mirred,
@@ -253,19 +251,13 @@ static int __init mirred_init_module(void)
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
index 9a3cb1d..270a030 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_nat,
@@ -297,16 +294,12 @@ MODULE_LICENSE("GPL");
 
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
index 8aa795b..5f9bcb2 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_pedit,
@@ -233,15 +230,11 @@ MODULE_LICENSE("GPL");
 
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
index 7ff7bef..0566e46 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -41,7 +41,6 @@ struct tcf_police {
 	container_of(pc, struct tcf_police, common)
 
 #define POL_TAB_MASK     15
-static struct tcf_hashinfo police_hash_info;
 
 /* old policer structure from before tc actions */
 struct tc_police_compat {
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_act_police,
@@ -361,19 +359,12 @@ static struct tc_action_ops act_police_ops = {
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
index 14b5e36..992c231 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_simp,
@@ -178,23 +176,15 @@ MODULE_LICENSE("GPL");
 
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
index 9f91928..fcfeeaf 100644
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
 	.owner		=	THIS_MODULE,
 	.act		=	tcf_skbedit,
@@ -189,15 +187,11 @@ MODULE_LICENSE("GPL");
 
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
