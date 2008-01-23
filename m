From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/15]: Propagate nla_parse return value
Date: Wed, 23 Jan 2008 17:36:44 +0100 (MET)
Message-ID: <20080123163603.6459.6488.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49730 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbYAWQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:45 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Propagate nla_parse return value

nla_parse() returns more detailed errno codes, propagate them back on error.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f9b5ab497909e836983bc31e5e7ad5065ccba6bc
tree 3b2ca0f7dcf925d113fce3e376cf7f2e995f0b7a
parent 0919ac24aa4bd6978806f35f8daefe32aa997823
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:54 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:54 +0100

 net/sched/act_api.c     |   29 ++++++++++++++++++-----------
 net/sched/act_gact.c    |    7 ++++++-
 net/sched/act_ipt.c     |    6 +++++-
 net/sched/act_mirred.c  |    8 ++++++--
 net/sched/act_nat.c     |    8 ++++++--
 net/sched/act_pedit.c   |    8 ++++++--
 net/sched/act_police.c  |    6 +++++-
 net/sched/act_simple.c  |    8 ++++++--
 net/sched/cls_basic.c   |    7 ++++---
 net/sched/cls_fw.c      |    5 +++--
 net/sched/cls_route.c   |    5 +++--
 net/sched/cls_rsvp.h    |    5 +++--
 net/sched/cls_tcindex.c |    6 ++++--
 net/sched/cls_u32.c     |    5 +++--
 net/sched/em_meta.c     |    6 ++++--
 net/sched/ematch.c      |    6 ++++--
 net/sched/sch_atm.c     |    6 +++++-
 net/sched/sch_cbq.c     |   14 +++++++++++---
 net/sched/sch_dsmark.c  |   14 ++++++++++++--
 net/sched/sch_gred.c    |   16 +++++++++++++---
 net/sched/sch_hfsc.c    |    7 ++++++-
 net/sched/sch_htb.c     |   23 +++++++++++++++++++----
 net/sched/sch_prio.c    |    9 ++++++---
 net/sched/sch_red.c     |    7 ++++++-
 net/sched/sch_tbf.c     |   10 +++++++---
 25 files changed, 171 insertions(+), 60 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ea80f82..87818d7 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -473,17 +473,18 @@ struct tc_action *tcf_action_init_1(struct nlattr *nla, struct nlattr *est,
 	struct nlattr *kind;
 	int err;
 
-	err = -EINVAL;
-
 	if (name == NULL) {
-		if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
+		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+		if (err < 0)
 			goto err_out;
+		err = -EINVAL;
 		kind = tb[TCA_ACT_KIND];
 		if (kind == NULL)
 			goto err_out;
 		if (nla_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
 	} else {
+		err = -EINVAL;
 		if (strlcpy(act_name, name, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
 	}
@@ -548,10 +549,12 @@ struct tc_action *tcf_action_init(struct nlattr *nla, struct nlattr *est,
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
+	int err;
 	int i;
 
-	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0)
-		return ERR_PTR(-EINVAL);
+	err = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
+	if (err < 0)
+		return ERR_PTR(err);
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_init_1(tb[i], est, name, ovr, bind);
@@ -674,10 +677,11 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	int index;
 	int err;
 
-	err = -EINVAL;
-	if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
+	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+	if (err < 0)
 		goto err_out;
 
+	err = -EINVAL;
 	if (tb[TCA_ACT_INDEX] == NULL ||
 	    nla_len(tb[TCA_ACT_INDEX]) < sizeof(index))
 		goto err_out;
@@ -759,9 +763,11 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 
 	b = skb_tail_pointer(skb);
 
-	if (nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL) < 0)
+	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+	if (err < 0)
 		goto err_out;
 
+	err = -EINVAL;
 	kind = tb[TCA_ACT_KIND];
 	a->ops = tc_lookup_action(kind);
 	if (a->ops == NULL)
@@ -804,12 +810,13 @@ err_out:
 static int
 tca_action_gd(struct nlattr *nla, struct nlmsghdr *n, u32 pid, int event)
 {
-	int i, ret = 0;
+	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 
-	if (nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL) < 0)
-		return -EINVAL;
+	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
+	if (ret < 0)
+		return ret;
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
 		if (tb[0] != NULL && tb[1] == NULL)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 5402cf8..df214d4 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -61,10 +61,15 @@ static int tcf_gact_init(struct nlattr *nla, struct nlattr *est,
 	struct tcf_gact *gact;
 	struct tcf_common *pc;
 	int ret = 0;
+	int err;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_GACT_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_GACT_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_GACT_PARMS] == NULL ||
 	    nla_len(tb[TCA_GACT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index fee5282..1269334 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -104,9 +104,13 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	u32 hook = 0;
 	u32 index = 0;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_IPT_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_IPT_HOOK] == NULL ||
 	    nla_len(tb[TCA_IPT_HOOK]) < sizeof(u32))
 		return -EINVAL;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index db943a8..6cb5e30 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -62,12 +62,16 @@ static int tcf_mirred_init(struct nlattr *nla, struct nlattr *est,
 	struct tcf_mirred *m;
 	struct tcf_common *pc;
 	struct net_device *dev = NULL;
-	int ret = 0;
+	int ret = 0, err;
 	int ok_push = 0;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_MIRRED_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_MIRRED_PARMS] == NULL ||
 	    nla_len(tb[TCA_MIRRED_PARMS]) < sizeof(*parm))
 		return -EINVAL;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index be007bb..5a512d4 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -45,13 +45,17 @@ static int tcf_nat_init(struct nlattr *nla, struct nlattr *est,
 {
 	struct nlattr *tb[TCA_NAT_MAX + 1];
 	struct tc_nat *parm;
-	int ret = 0;
+	int ret = 0, err;
 	struct tcf_nat *p;
 	struct tcf_common *pc;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_NAT_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_NAT_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_NAT_PARMS] == NULL ||
 	    nla_len(tb[TCA_NAT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 88d8a15..1b9ca45 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -38,15 +38,19 @@ static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 {
 	struct nlattr *tb[TCA_PEDIT_MAX + 1];
 	struct tc_pedit *parm;
-	int ret = 0;
+	int ret = 0, err;
 	struct tcf_pedit *p;
 	struct tcf_common *pc;
 	struct tc_pedit_key *keys = NULL;
 	int ksize;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_PEDIT_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_PEDIT_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_PEDIT_PARMS] == NULL ||
 	    nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm))
 		return -EINVAL;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3af5759..c0fce9b 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -129,9 +129,13 @@ static int tcf_act_police_locate(struct nlattr *nla, struct nlattr *est,
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 	int size;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_POLICE_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_POLICE_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_POLICE_TBF] == NULL)
 		return -EINVAL;
 	size = nla_len(tb[TCA_POLICE_TBF]);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index d3226e2..cedaadf 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -93,11 +93,15 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 	struct tcf_common *pc;
 	void *defdata;
 	u32 datalen = 0;
-	int ret = 0;
+	int ret = 0, err;
 
-	if (nla == NULL || nla_parse_nested(tb, TCA_DEF_MAX, nla, NULL) < 0)
+	if (nla == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_DEF_PARMS] == NULL ||
 	    nla_len(tb[TCA_DEF_PARMS]) < sizeof(*parm))
 		return -EINVAL;
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 3953da3..524b788 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -166,7 +166,7 @@ errout:
 static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 			struct nlattr **tca, unsigned long *arg)
 {
-	int err = -EINVAL;
+	int err;
 	struct basic_head *head = (struct basic_head *) tp->root;
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *f = (struct basic_filter *) *arg;
@@ -174,8 +174,9 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
 
-	if (nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS], NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS], NULL);
+	if (err < 0)
+		return err;
 
 	if (f != NULL) {
 		if (handle && f->handle != handle)
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index db6e90a..a1a9f4d 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -246,8 +246,9 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 	if (!opt)
 		return handle ? -EINVAL : 0;
 
-	if (nla_parse_nested(tb, TCA_FW_MAX, opt, NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_FW_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
 	if (f != NULL) {
 		if (f->id != handle && handle)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index b1aae84..3aa8109 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -440,8 +440,9 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
 	if ((f = (struct route4_filter*)*arg) != NULL) {
 		if (f->handle != handle && handle)
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 2364c79..5747408 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -416,8 +416,9 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (nla_parse_nested(tb, TCA_RSVP_MAX, opt, NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
 	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &rsvp_ext_map);
 	if (err < 0)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index ed80239..6b84d27 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -350,6 +350,7 @@ tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	struct nlattr *tb[TCA_TCINDEX_MAX + 1];
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) *arg;
+	int err;
 
 	pr_debug("tcindex_change(tp %p,handle 0x%08x,tca %p,arg %p),opt %p,"
 	    "p %p,r %p,*arg 0x%lx\n",
@@ -358,8 +359,9 @@ tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (!opt)
 		return 0;
 
-	if (nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
 	return tcindex_set_parms(tp, base, handle, p, r, tb, tca[TCA_RATE]);
 }
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index aaf5049..3228cc4 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -531,8 +531,9 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	if (nla_parse_nested(tb, TCA_U32_MAX, opt, NULL) < 0)
-		return -EINVAL;
+	err = nla_parse_nested(tb, TCA_U32_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
 	if ((n = (struct tc_u_knode*)*arg) != NULL) {
 		if (TC_U32_KEY(n->handle) == 0)
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 92b6863..dd57236 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -749,14 +749,16 @@ static inline int meta_is_supported(struct meta_value *val)
 static int em_meta_change(struct tcf_proto *tp, void *data, int len,
 			  struct tcf_ematch *m)
 {
-	int err = -EINVAL;
+	int err;
 	struct nlattr *tb[TCA_EM_META_MAX + 1];
 	struct tcf_meta_hdr *hdr;
 	struct meta_match *meta = NULL;
 
-	if (nla_parse(tb, TCA_EM_META_MAX, data, len, NULL) < 0)
+	err = nla_parse(tb, TCA_EM_META_MAX, data, len, NULL);
+	if (err < 0)
 		goto errout;
 
+	err = -EINVAL;
 	if (tb[TCA_EM_META_HDR] == NULL ||
 	    nla_len(tb[TCA_EM_META_HDR]) < sizeof(*hdr))
 		goto errout;
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 72d9b27..d2b480f 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -301,7 +301,7 @@ errout:
 int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 			 struct tcf_ematch_tree *tree)
 {
-	int idx, list_len, matches_len, err = -EINVAL;
+	int idx, list_len, matches_len, err;
 	struct nlattr *tb[TCA_EMATCH_TREE_MAX + 1];
 	struct nlattr *rt_match, *rt_hdr, *rt_list;
 	struct tcf_ematch_tree_hdr *tree_hdr;
@@ -312,9 +312,11 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 		return 0;
 	}
 
-	if (nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, NULL) < 0)
+	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, NULL);
+	if (err < 0)
 		goto errout;
 
+	err = -EINVAL;
 	rt_hdr = tb[TCA_EMATCH_TREE_HDR];
 	rt_list = tb[TCA_EMATCH_TREE_LIST];
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e587391..aaa32a2 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -223,8 +223,12 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	 */
 	if (flow)
 		return -EBUSY;
-	if (opt == NULL || nla_parse_nested(tb, TCA_ATM_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
+	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, NULL);
+	if (error < 0)
+		return error;
+
 	if (!tb[TCA_ATM_FD] || nla_len(tb[TCA_ATM_FD]) < sizeof(fd))
 		return -EINVAL;
 	fd = *(int *)nla_data(tb[TCA_ATM_FD]);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 5c8667e..585f8a6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1382,9 +1382,13 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_CBQ_MAX + 1];
 	struct tc_ratespec *r;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL);
+	if (err < 0)
+		return err;
 
-	if (nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL) < 0 ||
-	    tb[TCA_CBQ_RTAB] == NULL || tb[TCA_CBQ_RATE] == NULL ||
+	if (tb[TCA_CBQ_RTAB] == NULL || tb[TCA_CBQ_RATE] == NULL ||
 	    nla_len(tb[TCA_CBQ_RATE]) < sizeof(struct tc_ratespec))
 		return -EINVAL;
 
@@ -1764,9 +1768,13 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	struct cbq_class *parent;
 	struct qdisc_rate_table *rtab = NULL;
 
-	if (opt==NULL || nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_CBQ_OVL_STRATEGY] &&
 	    nla_len(tb[TCA_CBQ_OVL_STRATEGY]) < sizeof(struct tc_cbq_ovl))
 		return -EINVAL;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index f183ab7..f1d0a08 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -116,9 +116,14 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto errout;
 	}
 
-	if (!opt || nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL))
+	if (!opt)
 		goto errout;
 
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
 	if (tb[TCA_DSMARK_MASK]) {
 		if (nla_len(tb[TCA_DSMARK_MASK]) < sizeof(u8))
 			goto errout;
@@ -351,9 +356,14 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 
 	pr_debug("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 
-	if (!opt || nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL) < 0)
+	if (!opt)
+		goto errout;
+
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL);
+	if (err < 0)
 		goto errout;
 
+	err = -EINVAL;
 	if (nla_len(tb[TCA_DSMARK_INDICES]) < sizeof(u16))
 		goto errout;
 	indices = nla_get_u16(tb[TCA_DSMARK_INDICES]);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index 6b78483..365c7d8 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -430,12 +430,16 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	struct gred_sched *table = qdisc_priv(sch);
 	struct tc_gred_qopt *ctl;
 	struct nlattr *tb[TCA_GRED_MAX + 1];
-	int err = -EINVAL, prio = GRED_DEF_PRIO;
+	int err, prio = GRED_DEF_PRIO;
 	u8 *stab;
 
-	if (opt == NULL || nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_GRED_PARMS] == NULL && tb[TCA_GRED_STAB] == NULL)
 		return gred_change_table_def(sch, opt);
 
@@ -445,6 +449,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	    nla_len(tb[TCA_GRED_STAB]) < 256)
 		return -EINVAL;
 
+	err = -EINVAL;
 	ctl = nla_data(tb[TCA_GRED_PARMS]);
 	stab = nla_data(tb[TCA_GRED_STAB]);
 
@@ -489,10 +494,15 @@ errout:
 static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct nlattr *tb[TCA_GRED_MAX + 1];
+	int err;
 
-	if (opt == NULL || nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_GRED_PARMS] || tb[TCA_GRED_STAB])
 		return -EINVAL;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4e6a164..fcb4826 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -997,10 +997,15 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct nlattr *tb[TCA_HFSC_MAX + 1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
 	u64 cur_time;
+	int err;
 
-	if (opt == NULL || nla_parse_nested(tb, TCA_HFSC_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_HFSC_RSC]) {
 		if (nla_len(tb[TCA_HFSC_RSC]) < sizeof(*rsc))
 			return -EINVAL;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3b3ff64..512df9a 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -997,9 +997,17 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	struct htb_sched *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_HTB_INIT + 1];
 	struct tc_htb_glob *gopt;
+	int err;
 	int i;
-	if (!opt || nla_parse_nested(tb, TCA_HTB_INIT, opt, NULL) ||
-	    tb[TCA_HTB_INIT] == NULL ||
+
+	if (!opt)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_HTB_INIT, opt, NULL);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_HTB_INIT] == NULL ||
 	    nla_len(tb[TCA_HTB_INIT]) < sizeof(*gopt)) {
 		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
 		return -EINVAL;
@@ -1302,8 +1310,15 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
-	if (!opt || nla_parse_nested(tb, TCA_HTB_RTAB, opt, NULL) ||
-	    tb[TCA_HTB_PARMS] == NULL ||
+	if (!opt)
+		goto failure;
+
+	err = nla_parse_nested(tb, TCA_HTB_RTAB, opt, NULL);
+	if (err < 0)
+		goto failure;
+
+	err = -EINVAL;
+	if (tb[TCA_HTB_PARMS] == NULL ||
 	    nla_len(tb[TCA_HTB_PARMS]) < sizeof(*hopt))
 		goto failure;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a4f932d..4aa2b45 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -229,11 +229,14 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
 	struct nlattr *tb[TCA_PRIO_MAX + 1];
+	int err;
 	int i;
 
-	if (nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
-				    sizeof(*qopt)))
-		return -EINVAL;
+	err = nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
+				      sizeof(*qopt));
+	if (err < 0)
+		return err;
+
 	q->bands = qopt->bands;
 	/* If we're multiqueue, make sure the number of incoming bands
 	 * matches the number of queues on the device we're associating with.
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 6ce8da5..dcf6afc 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -207,10 +207,15 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	struct nlattr *tb[TCA_RED_MAX + 1];
 	struct tc_red_qopt *ctl;
 	struct Qdisc *child = NULL;
+	int err;
 
-	if (opt == NULL || nla_parse_nested(tb, TCA_RED_MAX, opt, NULL))
+	if (opt == NULL)
 		return -EINVAL;
 
+	err = nla_parse_nested(tb, TCA_RED_MAX, opt, NULL);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_RED_PARMS] == NULL ||
 	    nla_len(tb[TCA_RED_PARMS]) < sizeof(*ctl) ||
 	    tb[TCA_RED_STAB] == NULL ||
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 6c4ad7e..f9b1543 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -272,7 +272,7 @@ static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 
 static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 {
-	int err = -EINVAL;
+	int err;
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct nlattr *tb[TCA_TBF_PTAB + 1];
 	struct tc_tbf_qopt *qopt;
@@ -281,8 +281,12 @@ static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 	struct Qdisc *child = NULL;
 	int max_size,n;
 
-	if (nla_parse_nested(tb, TCA_TBF_PTAB, opt, NULL) ||
-	    tb[TCA_TBF_PARMS] == NULL ||
+	err = nla_parse_nested(tb, TCA_TBF_PTAB, opt, NULL);
+	if (err < 0)
+		return err;
+
+	err = -EINVAL;
+	if (tb[TCA_TBF_PARMS] == NULL ||
 	    nla_len(tb[TCA_TBF_PARMS]) < sizeof(*qopt))
 		goto done;
 
