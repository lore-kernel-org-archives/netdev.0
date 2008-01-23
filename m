From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 12/15]: Use nla_policy for attribute validation in packet schedulers
Date: Wed, 23 Jan 2008 17:36:52 +0100 (MET)
Message-ID: <20080123163612.6459.61449.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49748 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbYAWQgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:54 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use nla_policy for attribute validation in packet schedulers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 76c3c24283fa9f78d8dc30c8eb73e0f11934bf69
tree bcc9baf4eae9086d377efff17fbd37a360ac64b7
parent b21f31e516f993016f8a1ade331bcaf71576b4e2
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:57 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:57 +0100

 net/sched/sch_atm.c    |   12 ++++++++----
 net/sched/sch_cbq.c    |   47 +++++++++++++----------------------------------
 net/sched/sch_dsmark.c |   33 +++++++++++++++------------------
 net/sched/sch_gred.c   |   16 ++++++++++------
 net/sched/sch_hfsc.c   |   14 +++++++-------
 net/sched/sch_htb.c    |   17 +++++++++++------
 net/sched/sch_netem.c  |   19 ++++++++-----------
 net/sched/sch_red.c    |   11 +++++++----
 net/sched/sch_tbf.c    |   11 ++++++++---
 9 files changed, 87 insertions(+), 93 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0c71f2e..3352734 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -195,6 +195,11 @@ static const u8 llc_oui_ip[] = {
 	0x08, 0x00
 };				/* Ethertype IP (0800) */
 
+static const struct nla_policy atm_policy[TCA_ATM_MAX + 1] = {
+	[TCA_ATM_FD]		= { .type = NLA_U32 },
+	[TCA_ATM_EXCESS]	= { .type = NLA_U32 },
+};
+
 static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			 struct nlattr **tca, unsigned long *arg)
 {
@@ -225,11 +230,12 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		return -EBUSY;
 	if (opt == NULL)
 		return -EINVAL;
-	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, NULL);
+
+	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, atm_policy);
 	if (error < 0)
 		return error;
 
-	if (!tb[TCA_ATM_FD] || nla_len(tb[TCA_ATM_FD]) < sizeof(fd))
+	if (!tb[TCA_ATM_FD])
 		return -EINVAL;
 	fd = nla_get_u32(tb[TCA_ATM_FD]);
 	pr_debug("atm_tc_change: fd %d\n", fd);
@@ -243,8 +249,6 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	if (!tb[TCA_ATM_EXCESS])
 		excess = NULL;
 	else {
-		if (nla_len(tb[TCA_ATM_EXCESS]) != sizeof(u32))
-			return -EINVAL;
 		excess = (struct atm_flow_data *)
 			atm_tc_get(sch, nla_get_u32(tb[TCA_ATM_EXCESS]));
 		if (!excess)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index da0f6c0..09969c1 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1377,6 +1377,16 @@ static int cbq_set_fopt(struct cbq_class *cl, struct tc_cbq_fopt *fopt)
 	return 0;
 }
 
+static const struct nla_policy cbq_policy[TCA_CBQ_MAX + 1] = {
+	[TCA_CBQ_LSSOPT]	= { .len = sizeof(struct tc_cbq_lssopt) },
+	[TCA_CBQ_WRROPT]	= { .len = sizeof(struct tc_cbq_wrropt) },
+	[TCA_CBQ_FOPT]		= { .len = sizeof(struct tc_cbq_fopt) },
+	[TCA_CBQ_OVL_STRATEGY]	= { .len = sizeof(struct tc_cbq_ovl) },
+	[TCA_CBQ_RATE]		= { .len = sizeof(struct tc_ratespec) },
+	[TCA_CBQ_RTAB]		= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+	[TCA_CBQ_POLICE]	= { .len = sizeof(struct tc_cbq_police) },
+};
+
 static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -1384,16 +1394,11 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_ratespec *r;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_CBQ_RTAB] == NULL || tb[TCA_CBQ_RATE] == NULL ||
-	    nla_len(tb[TCA_CBQ_RATE]) < sizeof(struct tc_ratespec))
-		return -EINVAL;
-
-	if (tb[TCA_CBQ_LSSOPT] &&
-	    nla_len(tb[TCA_CBQ_LSSOPT]) < sizeof(struct tc_cbq_lssopt))
+	if (tb[TCA_CBQ_RTAB] == NULL || tb[TCA_CBQ_RATE] == NULL)
 		return -EINVAL;
 
 	r = nla_data(tb[TCA_CBQ_RATE]);
@@ -1771,36 +1776,10 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_CBQ_OVL_STRATEGY] &&
-	    nla_len(tb[TCA_CBQ_OVL_STRATEGY]) < sizeof(struct tc_cbq_ovl))
-		return -EINVAL;
-
-	if (tb[TCA_CBQ_FOPT] &&
-	    nla_len(tb[TCA_CBQ_FOPT]) < sizeof(struct tc_cbq_fopt))
-		return -EINVAL;
-
-	if (tb[TCA_CBQ_RATE] &&
-	    nla_len(tb[TCA_CBQ_RATE]) < sizeof(struct tc_ratespec))
-			return -EINVAL;
-
-	if (tb[TCA_CBQ_LSSOPT] &&
-	    nla_len(tb[TCA_CBQ_LSSOPT]) < sizeof(struct tc_cbq_lssopt))
-			return -EINVAL;
-
-	if (tb[TCA_CBQ_WRROPT] &&
-	    nla_len(tb[TCA_CBQ_WRROPT]) < sizeof(struct tc_cbq_wrropt))
-			return -EINVAL;
-
-#ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_CBQ_POLICE] &&
-	    nla_len(tb[TCA_CBQ_POLICE]) < sizeof(struct tc_cbq_police))
-			return -EINVAL;
-#endif
-
 	if (cl) {
 		/* Check parent */
 		if (parentid) {
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index f1d0a08..0df911f 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -99,6 +99,14 @@ static void dsmark_put(struct Qdisc *sch, unsigned long cl)
 {
 }
 
+static const struct nla_policy dsmark_policy[TCA_DSMARK_MAX + 1] = {
+	[TCA_DSMARK_INDICES]		= { .type = NLA_U16 },
+	[TCA_DSMARK_DEFAULT_INDEX]	= { .type = NLA_U16 },
+	[TCA_DSMARK_SET_TC_INDEX]	= { .type = NLA_FLAG },
+	[TCA_DSMARK_MASK]		= { .type = NLA_U8 },
+	[TCA_DSMARK_VALUE]		= { .type = NLA_U8 },
+};
+
 static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 			 struct nlattr **tca, unsigned long *arg)
 {
@@ -119,21 +127,15 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 	if (!opt)
 		goto errout;
 
-	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy);
 	if (err < 0)
-		return err;
+		goto errout;
 
-	err = -EINVAL;
-	if (tb[TCA_DSMARK_MASK]) {
-		if (nla_len(tb[TCA_DSMARK_MASK]) < sizeof(u8))
-			goto errout;
+	if (tb[TCA_DSMARK_MASK])
 		mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
-	}
-	if (tb[TCA_DSMARK_VALUE]) {
-		if (nla_len(tb[TCA_DSMARK_VALUE]) < sizeof(u8))
-			goto errout;
+
+	if (tb[TCA_DSMARK_VALUE])
 		p->value[*arg-1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
-	}
 
 	if (tb[TCA_DSMARK_MASK])
 		p->mask[*arg-1] = mask;
@@ -359,23 +361,18 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		goto errout;
 
-	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy);
 	if (err < 0)
 		goto errout;
 
 	err = -EINVAL;
-	if (nla_len(tb[TCA_DSMARK_INDICES]) < sizeof(u16))
-		goto errout;
 	indices = nla_get_u16(tb[TCA_DSMARK_INDICES]);
 
 	if (hweight32(indices) != 1)
 		goto errout;
 
-	if (tb[TCA_DSMARK_DEFAULT_INDEX]) {
-		if (nla_len(tb[TCA_DSMARK_DEFAULT_INDEX]) < sizeof(u16))
-			goto errout;
+	if (tb[TCA_DSMARK_DEFAULT_INDEX])
 		default_index = nla_get_u16(tb[TCA_DSMARK_DEFAULT_INDEX]);
-	}
 
 	mask = kmalloc(indices * 2, GFP_KERNEL);
 	if (mask == NULL) {
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 365c7d8..3a9d226 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -356,7 +356,7 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 	struct tc_gred_sopt *sopt;
 	int i;
 
-	if (dps == NULL || nla_len(dps) < sizeof(*sopt))
+	if (dps == NULL)
 		return -EINVAL;
 
 	sopt = nla_data(dps);
@@ -425,6 +425,12 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 	return 0;
 }
 
+static const struct nla_policy gred_policy[TCA_GRED_MAX + 1] = {
+	[TCA_GRED_PARMS]	= { .len = sizeof(struct tc_gred_qopt) },
+	[TCA_GRED_STAB]		= { .len = 256 },
+	[TCA_GRED_DPS]		= { .len = sizeof(struct tc_gred_sopt) },
+};
+
 static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct gred_sched *table = qdisc_priv(sch);
@@ -436,7 +442,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
 	if (err < 0)
 		return err;
 
@@ -444,9 +450,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 		return gred_change_table_def(sch, opt);
 
 	if (tb[TCA_GRED_PARMS] == NULL ||
-	    nla_len(tb[TCA_GRED_PARMS]) < sizeof(*ctl) ||
-	    tb[TCA_GRED_STAB] == NULL ||
-	    nla_len(tb[TCA_GRED_STAB]) < 256)
+	    tb[TCA_GRED_STAB] == NULL)
 		return -EINVAL;
 
 	err = -EINVAL;
@@ -499,7 +503,7 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 54c3e90..94bf186 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -986,6 +986,12 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
 	cl->cl_flags |= HFSC_USC;
 }
 
+static const struct nla_policy hfsc_policy[TCA_HFSC_MAX + 1] = {
+	[TCA_HFSC_RSC]	= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_FSC]	= { .len = sizeof(struct tc_service_curve) },
+	[TCA_HFSC_USC]	= { .len = sizeof(struct tc_service_curve) },
+};
+
 static int
 hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		  struct nlattr **tca, unsigned long *arg)
@@ -1002,29 +1008,23 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy);
 	if (err < 0)
 		return err;
 
 	if (tb[TCA_HFSC_RSC]) {
-		if (nla_len(tb[TCA_HFSC_RSC]) < sizeof(*rsc))
-			return -EINVAL;
 		rsc = nla_data(tb[TCA_HFSC_RSC]);
 		if (rsc->m1 == 0 && rsc->m2 == 0)
 			rsc = NULL;
 	}
 
 	if (tb[TCA_HFSC_FSC]) {
-		if (nla_len(tb[TCA_HFSC_FSC]) < sizeof(*fsc))
-			return -EINVAL;
 		fsc = nla_data(tb[TCA_HFSC_FSC]);
 		if (fsc->m1 == 0 && fsc->m2 == 0)
 			fsc = NULL;
 	}
 
 	if (tb[TCA_HFSC_USC]) {
-		if (nla_len(tb[TCA_HFSC_USC]) < sizeof(*usc))
-			return -EINVAL;
 		usc = nla_data(tb[TCA_HFSC_USC]);
 		if (usc->m1 == 0 && usc->m2 == 0)
 			usc = NULL;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 69fac32..e1a579e 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -992,6 +992,13 @@ static void htb_reset(struct Qdisc *sch)
 		INIT_LIST_HEAD(q->drops + i);
 }
 
+static const struct nla_policy htb_policy[TCA_HTB_MAX + 1] = {
+	[TCA_HTB_PARMS]	= { .len = sizeof(struct tc_htb_opt) },
+	[TCA_HTB_INIT]	= { .len = sizeof(struct tc_htb_glob) },
+	[TCA_HTB_CTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+	[TCA_HTB_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+};
+
 static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct htb_sched *q = qdisc_priv(sch);
@@ -1003,12 +1010,11 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HTB_INIT, opt, NULL);
+	err = nla_parse_nested(tb, TCA_HTB_INIT, opt, htb_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_HTB_INIT] == NULL ||
-	    nla_len(tb[TCA_HTB_INIT]) < sizeof(*gopt)) {
+	if (tb[TCA_HTB_INIT] == NULL) {
 		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
 		return -EINVAL;
 	}
@@ -1319,13 +1325,12 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	if (!opt)
 		goto failure;
 
-	err = nla_parse_nested(tb, TCA_HTB_RTAB, opt, NULL);
+	err = nla_parse_nested(tb, TCA_HTB_RTAB, opt, htb_policy);
 	if (err < 0)
 		goto failure;
 
 	err = -EINVAL;
-	if (tb[TCA_HTB_PARMS] == NULL ||
-	    nla_len(tb[TCA_HTB_PARMS]) < sizeof(*hopt))
+	if (tb[TCA_HTB_PARMS] == NULL)
 		goto failure;
 
 	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1a75579..c9c649b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -368,9 +368,6 @@ static int get_correlation(struct Qdisc *sch, const struct nlattr *attr)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corr *c = nla_data(attr);
 
-	if (nla_len(attr) != sizeof(*c))
-		return -EINVAL;
-
 	init_crandom(&q->delay_cor, c->delay_corr);
 	init_crandom(&q->loss_cor, c->loss_corr);
 	init_crandom(&q->dup_cor, c->dup_corr);
@@ -382,9 +379,6 @@ static int get_reorder(struct Qdisc *sch, const struct nlattr *attr)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_reorder *r = nla_data(attr);
 
-	if (nla_len(attr) != sizeof(*r))
-		return -EINVAL;
-
 	q->reorder = r->probability;
 	init_crandom(&q->reorder_cor, r->correlation);
 	return 0;
@@ -395,14 +389,17 @@ static int get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	const struct tc_netem_corrupt *r = nla_data(attr);
 
-	if (nla_len(attr) != sizeof(*r))
-		return -EINVAL;
-
 	q->corrupt = r->probability;
 	init_crandom(&q->corrupt_cor, r->correlation);
 	return 0;
 }
 
+static const struct nla_policy netem_policy[TCA_NETEM_MAX + 1] = {
+	[TCA_NETEM_CORR]	= { .len = sizeof(struct tc_netem_corr) },
+	[TCA_NETEM_REORDER]	= { .len = sizeof(struct tc_netem_reorder) },
+	[TCA_NETEM_CORRUPT]	= { .len = sizeof(struct tc_netem_corrupt) },
+};
+
 /* Parse netlink message to set options */
 static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 {
@@ -414,8 +411,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	ret = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, NULL, qopt,
-				      sizeof(*qopt));
+	ret = nla_parse_nested_compat(tb, TCA_NETEM_MAX, opt, netem_policy,
+				      qopt, sizeof(*qopt));
 	if (ret < 0)
 		return ret;
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index dcf6afc..3dcd493 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -201,6 +201,11 @@ static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 	return NULL;
 }
 
+static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
+	[TCA_RED_PARMS]	= { .len = sizeof(struct tc_red_qopt) },
+	[TCA_RED_STAB]	= { .len = RED_STAB_SIZE },
+};
+
 static int red_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -212,14 +217,12 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_RED_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_RED_MAX, opt, red_policy);
 	if (err < 0)
 		return err;
 
 	if (tb[TCA_RED_PARMS] == NULL ||
-	    nla_len(tb[TCA_RED_PARMS]) < sizeof(*ctl) ||
-	    tb[TCA_RED_STAB] == NULL ||
-	    nla_len(tb[TCA_RED_STAB]) < RED_STAB_SIZE)
+	    tb[TCA_RED_STAB] == NULL)
 		return -EINVAL;
 
 	ctl = nla_data(tb[TCA_RED_PARMS]);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index b7a185d..0b7d78f 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -270,6 +270,12 @@ static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 	return NULL;
 }
 
+static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
+	[TCA_TBF_PARMS]	= { .len = sizeof(struct tc_tbf_qopt) },
+	[TCA_TBF_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+};
+
 static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 {
 	int err;
@@ -281,13 +287,12 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	struct Qdisc *child = NULL;
 	int max_size,n;
 
-	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, NULL);
+	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, tbf_policy);
 	if (err < 0)
 		return err;
 
 	err = -EINVAL;
-	if (tb[TCA_TBF_PARMS] == NULL ||
-	    nla_len(tb[TCA_TBF_PARMS]) < sizeof(*qopt))
+	if (tb[TCA_TBF_PARMS] == NULL)
 		goto done;
 
 	qopt = nla_data(tb[TCA_TBF_PARMS]);
