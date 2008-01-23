From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 14/15]: Use nla_policy for attribute validation in actions
Date: Wed, 23 Jan 2008 17:36:56 +0100 (MET)
Message-ID: <20080123163615.6459.85395.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49755 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYAWQg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:57 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use nla_policy for attribute validation in actions

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 99302e1c1ed003305e9a0102aa772e2f2d61114c
tree 05286e8f9d74ad273d6a6e12d7bc794a19c4ea4c
parent d177578bdf08849a388f1bc42a1d0566c6a3aded
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:23:07 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:23:07 +0100

 net/sched/act_gact.c   |   15 ++++++++-------
 net/sched/act_ipt.c    |   19 ++++++++++++-------
 net/sched/act_mirred.c |    9 ++++++---
 net/sched/act_nat.c    |    9 ++++++---
 net/sched/act_pedit.c  |    9 ++++++---
 net/sched/act_police.c |   16 ++++++++--------
 net/sched/act_simple.c |    7 +++++--
 7 files changed, 51 insertions(+), 33 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index df214d4..422872c 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -53,6 +53,11 @@ typedef int (*g_rand)(struct tcf_gact *gact);
 static g_rand gact_rand[MAX_RAND]= { NULL, gact_net_rand, gact_determ };
 #endif /* CONFIG_GACT_PROB */
 
+static const struct nla_policy gact_policy[TCA_GACT_MAX + 1] = {
+	[TCA_GACT_PARMS]	= { .len = sizeof(struct tc_gact) },
+	[TCA_GACT_PROB]		= { .len = sizeof(struct tc_gact_p) },
+};
+
 static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 			 struct tc_action *a, int ovr, int bind)
 {
@@ -66,20 +71,16 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GACT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_GACT_MAX, nla, gact_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_GACT_PARMS] == NULL ||
-	    nla_len(tb[TCA_GACT_PARMS]) < sizeof(*parm))
+	if (tb[TCA_GACT_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_GACT_PARMS]);
 
+#ifndef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB] != NULL)
-#ifdef CONFIG_GACT_PROB
-		if (nla_len(tb[TCA_GACT_PROB]) < sizeof(struct tc_gact_p))
-			return -EINVAL;
-#else
 		return -EOPNOTSUPP;
 #endif
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 7ab2419..da696fd 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -92,6 +92,13 @@ static int tcf_ipt_release(struct tcf_ipt *ipt, int bind)
 	return ret;
 }
 
+static const struct nla_policy ipt_policy[TCA_IPT_MAX + 1] = {
+	[TCA_IPT_TABLE]	= { .type = NLA_STRING, .len = IFNAMSIZ },
+	[TCA_IPT_HOOK]	= { .type = NLA_U32 },
+	[TCA_IPT_INDEX]	= { .type = NLA_U32 },
+	[TCA_IPT_TARG]	= { .len = sizeof(struct ipt_entry_target) },
+};
+
 static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
@@ -107,22 +114,20 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, ipt_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_IPT_HOOK] == NULL ||
-	    nla_len(tb[TCA_IPT_HOOK]) < sizeof(u32))
+	if (tb[TCA_IPT_HOOK] == NULL)
 		return -EINVAL;
-	if (tb[TCA_IPT_TARG] == NULL ||
-	    nla_len(tb[TCA_IPT_TARG]) < sizeof(*t))
+	if (tb[TCA_IPT_TARG] == NULL)
 		return -EINVAL;
+
 	td = (struct ipt_entry_target *)nla_data(tb[TCA_IPT_TARG]);
 	if (nla_len(tb[TCA_IPT_TARG]) < td->u.target_size)
 		return -EINVAL;
 
-	if (tb[TCA_IPT_INDEX] != NULL &&
-	    nla_len(tb[TCA_IPT_INDEX]) >= sizeof(u32))
+	if (tb[TCA_IPT_INDEX] != NULL)
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
 	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6cb5e30..1aff005 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -54,6 +54,10 @@ static inline int tcf_mirred_release(struct tcf_mirred *m, int bind)
 	return 0;
 }
 
+static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
+	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
+};
+
 static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 			   struct tc_action *a, int ovr, int bind)
 {
@@ -68,12 +72,11 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_MIRRED_PARMS] == NULL ||
-	    nla_len(tb[TCA_MIRRED_PARMS]) < sizeof(*parm))
+	if (tb[TCA_MIRRED_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 5a512d4..0a3c833 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -40,6 +40,10 @@ static struct tcf_hashinfo nat_hash_info = {
 	.lock	=	&nat_lock,
 };
 
+static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
+	[TCA_NAT_PARMS]	= { .len = sizeof(struct tc_nat) },
+};
+
 static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
 			struct tc_action *a, int ovr, int bind)
 {
@@ -52,12 +56,11 @@ static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_NAT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_NAT_MAX, nla, nat_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_NAT_PARMS] == NULL ||
-	    nla_len(tb[TCA_NAT_PARMS]) < sizeof(*parm))
+	if (tb[TCA_NAT_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 1b9ca45..3cc4cb9 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -33,6 +33,10 @@ static struct tcf_hashinfo pedit_hash_info = {
 	.lock	=	&pedit_lock,
 };
 
+static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
+	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tcf_pedit) },
+};
+
 static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 			  struct tc_action *a, int ovr, int bind)
 {
@@ -47,12 +51,11 @@ static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_PEDIT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_PEDIT_MAX, nla, pedit_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_PEDIT_PARMS] == NULL ||
-	    nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm))
+	if (tb[TCA_PEDIT_PARMS] == NULL)
 		return -EINVAL;
 	parm = nla_data(tb[TCA_PEDIT_PARMS]);
 	ksize = parm->nkeys * sizeof(struct tc_pedit_key);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 62de806..0898120 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -119,6 +119,13 @@ static void tcf_police_destroy(struct tcf_police *p)
 	BUG_TRAP(0);
 }
 
+static const struct nla_policy police_policy[TCA_POLICE_MAX + 1] = {
+	[TCA_POLICE_RATE]	= { .len = TC_RTAB_SIZE },
+	[TCA_POLICE_PEAKRATE]	= { .len = TC_RTAB_SIZE },
+	[TCA_POLICE_AVRATE]	= { .type = NLA_U32 },
+	[TCA_POLICE_RESULT]	= { .type = NLA_U32 },
+};
+
 static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 				 struct tc_action *a, int ovr, int bind)
 {
@@ -133,7 +140,7 @@ static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_POLICE_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_POLICE_MAX, nla, police_policy);
 	if (err < 0)
 		return err;
 
@@ -144,13 +151,6 @@ static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 	parm = nla_data(tb[TCA_POLICE_TBF]);
 
-	if (tb[TCA_POLICE_RESULT] != NULL &&
-	    nla_len(tb[TCA_POLICE_RESULT]) != sizeof(u32))
-		return -EINVAL;
-	if (tb[TCA_POLICE_RESULT] != NULL &&
-	    nla_len(tb[TCA_POLICE_RESULT]) != sizeof(u32))
-		return -EINVAL;
-
 	if (parm->index) {
 		struct tcf_common *pc;
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index cedaadf..fbde461 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -84,6 +84,10 @@ static int realloc_defdata(struct tcf_defact *d, u32 datalen, void *defdata)
 	return alloc_defdata(d, datalen, defdata);
 }
 
+static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
+	[TCA_DEF_PARMS]	= { .len = sizeof(struct tc_defact) },
+};
+
 static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			 struct tc_action *a, int ovr, int bind)
 {
@@ -102,8 +106,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_DEF_PARMS] == NULL ||
-	    nla_len(tb[TCA_DEF_PARMS]) < sizeof(*parm))
+	if (tb[TCA_DEF_PARMS] == NULL)
 		return -EINVAL;
 
 	parm = nla_data(tb[TCA_DEF_PARMS]);
