From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v4 5/8] net_sched: init struct tcf_hashinfo at register time
Date: Sun, 15 Dec 2013 20:15:08 -0800
Message-ID: <1387167311-14763-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:53793 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab3LPEPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 23:15:32 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so2414182pab.29
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 20:15:31 -0800 (PST)
In-Reply-To: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks weird to store the lock out of the struct but
still points to a static variable. Just move them into the struct.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   | 18 +++++++++++++++++-
 net/sched/act_api.c     | 16 ++++++++--------
 net/sched/act_csum.c    | 13 +++++--------
 net/sched/act_gact.c    | 13 +++++--------
 net/sched/act_ipt.c     | 21 ++++++++++-----------
 net/sched/act_mirred.c  | 16 +++++++---------
 net/sched/act_nat.c     | 12 +++++-------
 net/sched/act_pedit.c   | 12 +++++-------
 net/sched/act_police.c  | 38 +++++++++++++++++++-------------------
 net/sched/act_simple.c  | 20 +++++++++++---------
 net/sched/act_skbedit.c | 13 +++++--------
 11 files changed, 97 insertions(+), 95 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index a726426..2b5ec5a 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -38,7 +38,7 @@ struct tcf_common {
 struct tcf_hashinfo {
 	struct tcf_common	**htab;
 	unsigned int		hmask;
-	rwlock_t		*lock;
+	rwlock_t		lock;
 };
 
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
@@ -46,6 +46,22 @@ static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
 	return index & hmask;
 }
 
+static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
+{
+	rwlock_init(&hf->lock);
+	hf->hmask = mask;
+	hf->htab = kzalloc((mask + 1) * sizeof(struct tcf_common *),
+			   GFP_KERNEL);
+	if (!hf->htab)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void tcf_hashinfo_destroy(struct tcf_hashinfo *hf)
+{
+	kfree(hf->htab);
+}
+
 #ifdef CONFIG_NET_CLS_ACT
 
 #define ACT_P_CREATED 1
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 7d84183..125673d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -34,9 +34,9 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 
 	for (p1p = &hinfo->htab[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
 		if (*p1p == p) {
-			write_lock_bh(hinfo->lock);
+			write_lock_bh(&hinfo->lock);
 			*p1p = p->tcfc_next;
-			write_unlock_bh(hinfo->lock);
+			write_unlock_bh(&hinfo->lock);
 			gen_kill_estimator(&p->tcfc_bstats,
 					   &p->tcfc_rate_est);
 			/*
@@ -77,7 +77,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	read_lock_bh(hinfo->lock);
+	read_lock_bh(&hinfo->lock);
 
 	s_i = cb->args[0];
 
@@ -107,7 +107,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 		}
 	}
 done:
-	read_unlock_bh(hinfo->lock);
+	read_unlock_bh(&hinfo->lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -170,13 +170,13 @@ struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p;
 
-	read_lock_bh(hinfo->lock);
+	read_lock_bh(&hinfo->lock);
 	for (p = hinfo->htab[tcf_hash(index, hinfo->hmask)]; p;
 	     p = p->tcfc_next) {
 		if (p->tcfc_index == index)
 			break;
 	}
-	read_unlock_bh(hinfo->lock);
+	read_unlock_bh(&hinfo->lock);
 
 	return p;
 }
@@ -257,10 +257,10 @@ void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
 	unsigned int h = tcf_hash(p->tcfc_index, hinfo->hmask);
 
-	write_lock_bh(hinfo->lock);
+	write_lock_bh(&hinfo->lock);
 	p->tcfc_next = hinfo->htab[h];
 	hinfo->htab[h] = p;
-	write_unlock_bh(hinfo->lock);
+	write_unlock_bh(&hinfo->lock);
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 5c5edf5..5d350c5 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -37,15 +37,8 @@
 #include <net/tc_act/tc_csum.h>
 
 #define CSUM_TAB_MASK 15
-static struct tcf_common *tcf_csum_ht[CSUM_TAB_MASK + 1];
 static u32 csum_idx_gen;
-static DEFINE_RWLOCK(csum_lock);
-
-static struct tcf_hashinfo csum_hash_info = {
-	.htab	= tcf_csum_ht,
-	.hmask	= CSUM_TAB_MASK,
-	.lock	= &csum_lock,
-};
+static struct tcf_hashinfo csum_hash_info;
 
 static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
@@ -593,6 +586,10 @@ MODULE_LICENSE("GPL");
 
 static int __init csum_init_module(void)
 {
+	int err = tcf_hashinfo_init(&csum_hash_info, CSUM_TAB_MASK+1);
+	if (err)
+		return err;
+
 	return tcf_register_action(&act_csum_ops);
 }
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 5645a4d..1e6e0e7 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -24,15 +24,8 @@
 #include <net/tc_act/tc_gact.h>
 
 #define GACT_TAB_MASK	15
-static struct tcf_common *tcf_gact_ht[GACT_TAB_MASK + 1];
 static u32 gact_idx_gen;
-static DEFINE_RWLOCK(gact_lock);
-
-static struct tcf_hashinfo gact_hash_info = {
-	.htab	=	tcf_gact_ht,
-	.hmask	=	GACT_TAB_MASK,
-	.lock	=	&gact_lock,
-};
+static struct tcf_hashinfo gact_hash_info;
 
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
@@ -215,6 +208,9 @@ MODULE_LICENSE("GPL");
 
 static int __init gact_init_module(void)
 {
+	int err = tcf_hashinfo_init(&gact_hash_info, GACT_TAB_MASK+1);
+	if (err)
+		return err;
 #ifdef CONFIG_GACT_PROB
 	pr_info("GACT probability on\n");
 #else
@@ -226,6 +222,7 @@ static int __init gact_init_module(void)
 static void __exit gact_cleanup_module(void)
 {
 	tcf_unregister_action(&act_gact_ops);
+	tcf_hashinfo_destroy(&gact_hash_info);
 }
 
 module_init(gact_init_module);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 882a897..8344380 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -29,15 +29,8 @@
 
 
 #define IPT_TAB_MASK     15
-static struct tcf_common *tcf_ipt_ht[IPT_TAB_MASK + 1];
 static u32 ipt_idx_gen;
-static DEFINE_RWLOCK(ipt_lock);
-
-static struct tcf_hashinfo ipt_hash_info = {
-	.htab	=	tcf_ipt_ht,
-	.hmask	=	IPT_TAB_MASK,
-	.lock	=	&ipt_lock,
-};
+static struct tcf_hashinfo ipt_hash_info;
 
 static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
 {
@@ -320,7 +313,11 @@ MODULE_ALIAS("act_xt");
 
 static int __init ipt_init_module(void)
 {
-	int ret1, ret2;
+	int ret1, ret2, err;
+	err = tcf_hashinfo_init(&ipt_hash_info, IPT_TAB_MASK+1);
+	if (err)
+		return err;
+
 	ret1 = tcf_register_action(&act_xt_ops);
 	if (ret1 < 0)
 		printk("Failed to load xt action\n");
@@ -328,9 +325,10 @@ static int __init ipt_init_module(void)
 	if (ret2 < 0)
 		printk("Failed to load ipt action\n");
 
-	if (ret1 < 0 && ret2 < 0)
+	if (ret1 < 0 && ret2 < 0) {
+		tcf_hashinfo_destroy(&ipt_hash_info);
 		return ret1;
-	else
+	} else
 		return 0;
 }
 
@@ -338,6 +336,7 @@ static void __exit ipt_cleanup_module(void)
 {
 	tcf_unregister_action(&act_xt_ops);
 	tcf_unregister_action(&act_ipt_ops);
+	tcf_hashinfo_destroy(&ipt_hash_info);
 }
 
 module_init(ipt_init_module);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index c26bfe5..d92cbab 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -30,16 +30,9 @@
 #include <linux/if_arp.h>
 
 #define MIRRED_TAB_MASK     7
-static struct tcf_common *tcf_mirred_ht[MIRRED_TAB_MASK + 1];
 static u32 mirred_idx_gen;
-static DEFINE_RWLOCK(mirred_lock);
 static LIST_HEAD(mirred_list);
-
-static struct tcf_hashinfo mirred_hash_info = {
-	.htab	=	tcf_mirred_ht,
-	.hmask	=	MIRRED_TAB_MASK,
-	.lock	=	&mirred_lock,
-};
+static struct tcf_hashinfo mirred_hash_info;
 
 static int tcf_mirred_release(struct tcf_mirred *m, int bind)
 {
@@ -260,7 +253,6 @@ static struct notifier_block mirred_device_notifier = {
 	.notifier_call = mirred_device_event,
 };
 
-
 static struct tc_action_ops act_mirred_ops = {
 	.kind		=	"mirred",
 	.hinfo		=	&mirred_hash_info,
@@ -283,6 +275,11 @@ static int __init mirred_init_module(void)
 	if (err)
 		return err;
 
+	err = tcf_hashinfo_init(&mirred_hash_info, MIRRED_TAB_MASK+1);
+	if (err) {
+		unregister_netdevice_notifier(&mirred_device_notifier);
+		return err;
+	}
 	pr_info("Mirror/redirect action on\n");
 	return tcf_register_action(&act_mirred_ops);
 }
@@ -290,6 +287,7 @@ static int __init mirred_init_module(void)
 static void __exit mirred_cleanup_module(void)
 {
 	unregister_netdevice_notifier(&mirred_device_notifier);
+	tcf_hashinfo_destroy(&mirred_hash_info);
 	tcf_unregister_action(&act_mirred_ops);
 }
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 6a15ace..409fe71 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -30,15 +30,9 @@
 
 
 #define NAT_TAB_MASK	15
-static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
 static u32 nat_idx_gen;
-static DEFINE_RWLOCK(nat_lock);
 
-static struct tcf_hashinfo nat_hash_info = {
-	.htab	=	tcf_nat_ht,
-	.hmask	=	NAT_TAB_MASK,
-	.lock	=	&nat_lock,
-};
+static struct tcf_hashinfo nat_hash_info;
 
 static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
 	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
@@ -316,12 +310,16 @@ MODULE_LICENSE("GPL");
 
 static int __init nat_init_module(void)
 {
+	int err = tcf_hashinfo_init(&nat_hash_info, NAT_TAB_MASK+1);
+	if (err)
+		return err;
 	return tcf_register_action(&act_nat_ops);
 }
 
 static void __exit nat_cleanup_module(void)
 {
 	tcf_unregister_action(&act_nat_ops);
+	tcf_hashinfo_destroy(&nat_hash_info);
 }
 
 module_init(nat_init_module);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 03b6767..aa5347c 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -24,15 +24,9 @@
 #include <net/tc_act/tc_pedit.h>
 
 #define PEDIT_TAB_MASK	15
-static struct tcf_common *tcf_pedit_ht[PEDIT_TAB_MASK + 1];
 static u32 pedit_idx_gen;
-static DEFINE_RWLOCK(pedit_lock);
 
-static struct tcf_hashinfo pedit_hash_info = {
-	.htab	=	tcf_pedit_ht,
-	.hmask	=	PEDIT_TAB_MASK,
-	.lock	=	&pedit_lock,
-};
+static struct tcf_hashinfo pedit_hash_info;
 
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
@@ -252,11 +246,15 @@ MODULE_LICENSE("GPL");
 
 static int __init pedit_init_module(void)
 {
+	int err = tcf_hashinfo_init(&pedit_hash_info, PEDIT_TAB_MASK+1);
+	if (err)
+		return err;
 	return tcf_register_action(&act_pedit_ops);
 }
 
 static void __exit pedit_cleanup_module(void)
 {
+	tcf_hashinfo_destroy(&pedit_hash_info);
 	tcf_unregister_action(&act_pedit_ops);
 }
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 16a62c3..f201576 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -41,15 +41,8 @@ struct tcf_police {
 	container_of(pc, struct tcf_police, common)
 
 #define POL_TAB_MASK     15
-static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
 static u32 police_idx_gen;
-static DEFINE_RWLOCK(police_lock);
-
-static struct tcf_hashinfo police_hash_info = {
-	.htab	=	tcf_police_ht,
-	.hmask	=	POL_TAB_MASK,
-	.lock	=	&police_lock,
-};
+static struct tcf_hashinfo police_hash_info;
 
 /* old policer structure from before tc actions */
 struct tc_police_compat {
@@ -71,12 +64,12 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 	int err = 0, index = -1, i = 0, s_i = 0, n_i = 0;
 	struct nlattr *nest;
 
-	read_lock_bh(&police_lock);
+	read_lock_bh(&police_hash_info.lock);
 
 	s_i = cb->args[0];
 
 	for (i = 0; i < (POL_TAB_MASK + 1); i++) {
-		p = tcf_police_ht[tcf_hash(i, POL_TAB_MASK)];
+		p = police_hash_info.htab[tcf_hash(i, POL_TAB_MASK)];
 
 		for (; p; p = p->tcfc_next) {
 			index++;
@@ -101,7 +94,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 		}
 	}
 done:
-	read_unlock_bh(&police_lock);
+	read_unlock_bh(&police_hash_info.lock);
 	if (n_i)
 		cb->args[0] += n_i;
 	return n_i;
@@ -116,11 +109,11 @@ static void tcf_police_destroy(struct tcf_police *p)
 	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
 	struct tcf_common **p1p;
 
-	for (p1p = &tcf_police_ht[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
+	for (p1p = &police_hash_info.htab[h]; *p1p; p1p = &(*p1p)->tcfc_next) {
 		if (*p1p == &p->common) {
-			write_lock_bh(&police_lock);
+			write_lock_bh(&police_hash_info.lock);
 			*p1p = p->tcf_next;
-			write_unlock_bh(&police_lock);
+			write_unlock_bh(&police_hash_info.lock);
 			gen_kill_estimator(&p->tcf_bstats,
 					   &p->tcf_rate_est);
 			/*
@@ -266,10 +259,10 @@ override:
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
-	write_lock_bh(&police_lock);
-	police->tcf_next = tcf_police_ht[h];
-	tcf_police_ht[h] = &police->common;
-	write_unlock_bh(&police_lock);
+	write_lock_bh(&police_hash_info.lock);
+	police->tcf_next = police_hash_info.htab[h];
+	police_hash_info.htab[h] = &police->common;
+	write_unlock_bh(&police_hash_info.lock);
 
 	a->priv = police;
 	return ret;
@@ -414,12 +407,19 @@ static struct tc_action_ops act_police_ops = {
 static int __init
 police_init_module(void)
 {
-	return tcf_register_action(&act_police_ops);
+	int err = tcf_hashinfo_init(&police_hash_info, POL_TAB_MASK+1);
+	if (err)
+		return err;
+	err = tcf_register_action(&act_police_ops);
+	if (err)
+		tcf_hashinfo_destroy(&police_hash_info);
+	return err;
 }
 
 static void __exit
 police_cleanup_module(void)
 {
+	tcf_hashinfo_destroy(&police_hash_info);
 	tcf_unregister_action(&act_police_ops);
 }
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 31157d3..2d7a0eb 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -25,15 +25,8 @@
 #include <net/tc_act/tc_defact.h>
 
 #define SIMP_TAB_MASK     7
-static struct tcf_common *tcf_simp_ht[SIMP_TAB_MASK + 1];
 static u32 simp_idx_gen;
-static DEFINE_RWLOCK(simp_lock);
-
-static struct tcf_hashinfo simp_hash_info = {
-	.htab	=	tcf_simp_ht,
-	.hmask	=	SIMP_TAB_MASK,
-	.lock	=	&simp_lock,
-};
+static struct tcf_hashinfo simp_hash_info;
 
 #define SIMP_MAX_DATA	32
 static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
@@ -209,14 +202,23 @@ MODULE_LICENSE("GPL");
 
 static int __init simp_init_module(void)
 {
-	int ret = tcf_register_action(&act_simp_ops);
+	int err, ret;
+	err = tcf_hashinfo_init(&simp_hash_info, SIMP_TAB_MASK+1);
+	if (err)
+		return err;
+
+	ret = tcf_register_action(&act_simp_ops);
 	if (!ret)
 		pr_info("Simple TC action Loaded\n");
+	else
+		tcf_hashinfo_destroy(&simp_hash_info);
+
 	return ret;
 }
 
 static void __exit simp_cleanup_module(void)
 {
+	tcf_hashinfo_destroy(&simp_hash_info);
 	tcf_unregister_action(&act_simp_ops);
 }
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index cf20add..90ed04a 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -28,15 +28,8 @@
 #include <net/tc_act/tc_skbedit.h>
 
 #define SKBEDIT_TAB_MASK     15
-static struct tcf_common *tcf_skbedit_ht[SKBEDIT_TAB_MASK + 1];
 static u32 skbedit_idx_gen;
-static DEFINE_RWLOCK(skbedit_lock);
-
-static struct tcf_hashinfo skbedit_hash_info = {
-	.htab	=	tcf_skbedit_ht,
-	.hmask	=	SKBEDIT_TAB_MASK,
-	.lock	=	&skbedit_lock,
-};
+static struct tcf_hashinfo skbedit_hash_info;
 
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 		       struct tcf_result *res)
@@ -210,11 +203,15 @@ MODULE_LICENSE("GPL");
 
 static int __init skbedit_init_module(void)
 {
+	int err = tcf_hashinfo_init(&skbedit_hash_info, SKBEDIT_TAB_MASK+1);
+	if (err)
+		return err;
 	return tcf_register_action(&act_skbedit_ops);
 }
 
 static void __exit skbedit_cleanup_module(void)
 {
+	tcf_hashinfo_destroy(&skbedit_hash_info);
 	tcf_unregister_action(&act_skbedit_ops);
 }
 
-- 
1.8.1.4
