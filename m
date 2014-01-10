From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/7] net_sched: act: move idx_gen into struct tcf_hashinfo
Date: Thu,  9 Jan 2014 16:13:59 -0800
Message-ID: <1389312845-10304-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:36453 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaAJAOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:37 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so3710047pbc.20
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:36 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to store the index separatedly
since tcf_hashinfo is allocated statically too.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h   |  7 ++++---
 net/sched/act_api.c     | 10 +++++-----
 net/sched/act_csum.c    |  3 +--
 net/sched/act_gact.c    |  3 +--
 net/sched/act_ipt.c     |  3 +--
 net/sched/act_mirred.c  |  3 +--
 net/sched/act_nat.c     |  3 +--
 net/sched/act_pedit.c   |  3 +--
 net/sched/act_police.c  |  3 +--
 net/sched/act_simple.c  |  3 +--
 net/sched/act_skbedit.c |  3 +--
 11 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index d34e1f4..268f9e6 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -39,6 +39,7 @@ struct tcf_hashinfo {
 	struct hlist_head	*htab;
 	unsigned int		hmask;
 	spinlock_t		lock;
+	u32			index;
 };
 
 static inline unsigned int tcf_hash(u32 index, unsigned int hmask)
@@ -51,6 +52,7 @@ static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
 	int i;
 
 	spin_lock_init(&hf->lock);
+	hf->index = 0;
 	hf->hmask = mask;
 	hf->htab = kzalloc((mask + 1) * sizeof(struct hlist_head),
 			   GFP_KERNEL);
@@ -105,13 +107,12 @@ struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo);
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 int tcf_hash_release(struct tcf_common *p, int bind,
 		     struct tcf_hashinfo *hinfo);
-u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo);
+u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
 struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a,
 				  int bind, struct tcf_hashinfo *hinfo);
 struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 				   struct tc_action *a, int size,
-				   int bind, u32 *idx_gen,
-				   struct tcf_hashinfo *hinfo);
+				   int bind, struct tcf_hashinfo *hinfo);
 void tcf_hash_insert(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 
 int tcf_register_action(struct tc_action_ops *a);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f63e146..74ae3ff 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -173,16 +173,16 @@ struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_lookup);
 
-u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
+u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo)
 {
-	u32 val = *idx_gen;
+	u32 val = hinfo->index;
 
 	do {
 		if (++val == 0)
 			val = 1;
 	} while (tcf_hash_lookup(val, hinfo));
 
-	*idx_gen = val;
+	hinfo->index = val;
 	return val;
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
@@ -215,7 +215,7 @@ EXPORT_SYMBOL(tcf_hash_check);
 
 struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 				   struct tc_action *a, int size, int bind,
-				   u32 *idx_gen, struct tcf_hashinfo *hinfo)
+				   struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
 
@@ -227,7 +227,7 @@ struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est,
 
 	spin_lock_init(&p->tcfc_lock);
 	INIT_HLIST_NODE(&p->tcfc_head);
-	p->tcfc_index = index ? index : tcf_hash_new_index(idx_gen, hinfo);
+	p->tcfc_index = index ? index : tcf_hash_new_index(hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
 	if (est) {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 8b1d657..ee28e1c 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -37,7 +37,6 @@
 #include <net/tc_act/tc_csum.h>
 
 #define CSUM_TAB_MASK 15
-static u32 csum_idx_gen;
 static struct tcf_hashinfo csum_hash_info;
 
 static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
@@ -67,7 +66,7 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 	pc = tcf_hash_check(parm->index, a, bind, &csum_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &csum_idx_gen, &csum_hash_info);
+				     &csum_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index af5641c..f26e6b8 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -24,7 +24,6 @@
 #include <net/tc_act/tc_gact.h>
 
 #define GACT_TAB_MASK	15
-static u32 gact_idx_gen;
 static struct tcf_hashinfo gact_hash_info;
 
 #ifdef CONFIG_GACT_PROB
@@ -90,7 +89,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	pc = tcf_hash_check(parm->index, a, bind, &gact_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*gact),
-				     bind, &gact_idx_gen, &gact_hash_info);
+				     bind, &gact_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 2426369..484bd19 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -29,7 +29,6 @@
 
 
 #define IPT_TAB_MASK     15
-static u32 ipt_idx_gen;
 static struct tcf_hashinfo ipt_hash_info;
 
 static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
@@ -129,7 +128,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(index, est, a, sizeof(*ipt), bind,
-				     &ipt_idx_gen, &ipt_hash_info);
+				     &ipt_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 9dbb8cd..5d05b57 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -30,7 +30,6 @@
 #include <linux/if_arp.h>
 
 #define MIRRED_TAB_MASK     7
-static u32 mirred_idx_gen;
 static LIST_HEAD(mirred_list);
 static struct tcf_hashinfo mirred_hash_info;
 
@@ -107,7 +106,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		if (dev == NULL)
 			return -EINVAL;
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*m), bind,
-				     &mirred_idx_gen, &mirred_hash_info);
+				     &mirred_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 584e655..a49fa23 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -30,7 +30,6 @@
 
 
 #define NAT_TAB_MASK	15
-static u32 nat_idx_gen;
 
 static struct tcf_hashinfo nat_hash_info;
 
@@ -61,7 +60,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	pc = tcf_hash_check(parm->index, a, bind, &nat_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &nat_idx_gen, &nat_hash_info);
+				     &nat_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 7291893..f361e4e 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -24,7 +24,6 @@
 #include <net/tc_act/tc_pedit.h>
 
 #define PEDIT_TAB_MASK	15
-static u32 pedit_idx_gen;
 
 static struct tcf_hashinfo pedit_hash_info;
 
@@ -63,7 +62,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		if (!parm->nkeys)
 			return -EINVAL;
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
-				     &pedit_idx_gen, &pedit_hash_info);
+				     &pedit_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		p = to_pedit(pc);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 9295b86..a719fdf 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -41,7 +41,6 @@ struct tcf_police {
 	container_of(pc, struct tcf_police, common)
 
 #define POL_TAB_MASK     15
-static u32 police_idx_gen;
 static struct tcf_hashinfo police_hash_info;
 
 /* old policer structure from before tc actions */
@@ -251,7 +250,7 @@ override:
 
 	police->tcfp_t_c = ktime_to_ns(ktime_get());
 	police->tcf_index = parm->index ? parm->index :
-		tcf_hash_new_index(&police_idx_gen, &police_hash_info);
+		tcf_hash_new_index(&police_hash_info);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
 	spin_lock_bh(&police_hash_info.lock);
 	hlist_add_head(&police->tcf_head, &police_hash_info.htab[h]);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index b44491e..f7d5406 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -25,7 +25,6 @@
 #include <net/tc_act/tc_defact.h>
 
 #define SIMP_TAB_MASK     7
-static u32 simp_idx_gen;
 static struct tcf_hashinfo simp_hash_info;
 
 #define SIMP_MAX_DATA	32
@@ -118,7 +117,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &simp_idx_gen, &simp_hash_info);
+				     &simp_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 0fa1aad..74af461 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -28,7 +28,6 @@
 #include <net/tc_act/tc_skbedit.h>
 
 #define SKBEDIT_TAB_MASK     15
-static u32 skbedit_idx_gen;
 static struct tcf_hashinfo skbedit_hash_info;
 
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
@@ -104,7 +103,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	pc = tcf_hash_check(parm->index, a, bind, &skbedit_hash_info);
 	if (!pc) {
 		pc = tcf_hash_create(parm->index, est, a, sizeof(*d), bind,
-				     &skbedit_idx_gen, &skbedit_hash_info);
+				     &skbedit_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 
-- 
1.8.3.1
