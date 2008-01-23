From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 13/15]: Use nla_policy for attribute validation in classifiers
Date: Wed, 23 Jan 2008 17:36:54 +0100 (MET)
Message-ID: <20080123163613.6459.10864.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49751 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289AbYAWQgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:55 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use nla_policy for attribute validation in classifiers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d177578bdf08849a388f1bc42a1d0566c6a3aded
tree 2eda0cf1e0479dab464acda9def525df27bd4307
parent 76c3c24283fa9f78d8dc30c8eb73e0f11934bf69
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:14:08 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:14:08 +0100

 net/sched/cls_basic.c   |   12 +++++++-----
 net/sched/cls_fw.c      |   17 ++++++++---------
 net/sched/cls_route.c   |   19 ++++++++-----------
 net/sched/cls_rsvp.h    |   26 +++++++++++---------------
 net/sched/cls_tcindex.c |   31 +++++++++++++------------------
 net/sched/cls_u32.c     |   22 ++++++++++++----------
 6 files changed, 59 insertions(+), 68 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 0c872a7..bfb4342 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -129,6 +129,11 @@ static int basic_delete(struct tcf_proto *tp, unsigned long arg)
 	return -ENOENT;
 }
 
+static const struct nla_policy basic_policy[TCA_BASIC_MAX + 1] = {
+	[TCA_BASIC_CLASSID]	= { .type = NLA_U32 },
+	[TCA_BASIC_EMATCHES]	= { .type = NLA_NESTED },
+};
+
 static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
 				  unsigned long base, struct nlattr **tb,
 				  struct nlattr *est)
@@ -137,10 +142,6 @@ static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
-	if (tb[TCA_BASIC_CLASSID])
-		if (nla_len(tb[TCA_BASIC_CLASSID]) < sizeof(u32))
-			return err;
-
 	err = tcf_exts_validate(tp, tb, est, &e, &basic_ext_map);
 	if (err < 0)
 		return err;
@@ -174,7 +175,8 @@ static int basic_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS], NULL);
+	err = nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS],
+			       basic_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index b75696d..436a6e7 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -186,6 +186,12 @@ out:
 	return -EINVAL;
 }
 
+static const struct nla_policy fw_policy[TCA_FW_MAX + 1] = {
+	[TCA_FW_CLASSID]	= { .type = NLA_U32 },
+	[TCA_FW_INDEV]		= { .type = NLA_STRING, .len = IFNAMSIZ },
+	[TCA_FW_MASK]		= { .type = NLA_U32 },
+};
+
 static int
 fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	struct nlattr **tb, struct nlattr **tca, unsigned long base)
@@ -201,8 +207,6 @@ fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 
 	err = -EINVAL;
 	if (tb[TCA_FW_CLASSID]) {
-		if (nla_len(tb[TCA_FW_CLASSID]) != sizeof(u32))
-			goto errout;
 		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
@@ -216,8 +220,6 @@ fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 #endif /* CONFIG_NET_CLS_IND */
 
 	if (tb[TCA_FW_MASK]) {
-		if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
-			goto errout;
 		mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
 			goto errout;
@@ -246,7 +248,7 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 	if (!opt)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_FW_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy);
 	if (err < 0)
 		return err;
 
@@ -261,11 +263,8 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 
 	if (head == NULL) {
 		u32 mask = 0xFFFFFFFF;
-		if (tb[TCA_FW_MASK]) {
-			if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
-				return -EINVAL;
+		if (tb[TCA_FW_MASK])
 			mask = nla_get_u32(tb[TCA_FW_MASK]);
-		}
 
 		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
 		if (head == NULL)
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index ae97238..f7e7d39 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -323,6 +323,13 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 	return 0;
 }
 
+static const struct nla_policy route4_policy[TCA_ROUTE4_MAX + 1] = {
+	[TCA_ROUTE4_CLASSID]	= { .type = NLA_U32 },
+	[TCA_ROUTE4_TO]		= { .type = NLA_U32 },
+	[TCA_ROUTE4_FROM]	= { .type = NLA_U32 },
+	[TCA_ROUTE4_IIF]	= { .type = NLA_U32 },
+};
+
 static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	struct route4_filter *f, u32 handle, struct route4_head *head,
 	struct nlattr **tb, struct nlattr *est, int new)
@@ -339,15 +346,9 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 		return err;
 
 	err = -EINVAL;
-	if (tb[TCA_ROUTE4_CLASSID])
-		if (nla_len(tb[TCA_ROUTE4_CLASSID]) < sizeof(u32))
-			goto errout;
-
 	if (tb[TCA_ROUTE4_TO]) {
 		if (new && handle & 0x8000)
 			goto errout;
-		if (nla_len(tb[TCA_ROUTE4_TO]) < sizeof(u32))
-			goto errout;
 		to = nla_get_u32(tb[TCA_ROUTE4_TO]);
 		if (to > 0xFF)
 			goto errout;
@@ -357,15 +358,11 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	if (tb[TCA_ROUTE4_FROM]) {
 		if (tb[TCA_ROUTE4_IIF])
 			goto errout;
-		if (nla_len(tb[TCA_ROUTE4_FROM]) < sizeof(u32))
-			goto errout;
 		id = nla_get_u32(tb[TCA_ROUTE4_FROM]);
 		if (id > 0xFF)
 			goto errout;
 		nhandle |= id << 16;
 	} else if (tb[TCA_ROUTE4_IIF]) {
-		if (nla_len(tb[TCA_ROUTE4_IIF]) < sizeof(u32))
-			goto errout;
 		id = nla_get_u32(tb[TCA_ROUTE4_IIF]);
 		if (id > 0x7FFF)
 			goto errout;
@@ -440,7 +437,7 @@ static int route4_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, route4_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 61286a0..4f2c3f1 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -397,6 +397,15 @@ static u32 gen_tunnel(struct rsvp_head *data)
 	return 0;
 }
 
+static const struct nla_policy rsvp_policy[TCA_RSVP_MAX + 1] = {
+	[TCA_RSVP_CLASSID]	= { .type = NLA_U32 },
+	[TCA_RSVP_DST]		= { .type = NLA_BINARY,
+	 			    .len = RSVP_DST_LEN * sizeof(u32) },
+	[TCA_RSVP_SRC]		= { .type = NLA_BINARY,
+	 			    .len = RSVP_DST_LEN * sizeof(u32) },
+	[TCA_RSVP_PINFO]	= { .len = sizeof(struct tc_rsvp_pinfo) },
+};
+
 static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		       u32 handle,
 		       struct nlattr **tca,
@@ -416,7 +425,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy);
 	if (err < 0)
 		return err;
 
@@ -452,30 +461,17 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC-1]) {
-		err = -EINVAL;
-		if (nla_len(tb[TCA_RSVP_SRC-1]) != sizeof(f->src))
-			goto errout;
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC-1]), sizeof(f->src));
 		h2 = hash_src(f->src);
 	}
 	if (tb[TCA_RSVP_PINFO-1]) {
-		err = -EINVAL;
-		if (nla_len(tb[TCA_RSVP_PINFO-1]) < sizeof(struct tc_rsvp_pinfo))
-			goto errout;
 		pinfo = nla_data(tb[TCA_RSVP_PINFO-1]);
 		f->spi = pinfo->spi;
 		f->tunnelhdr = pinfo->tunnelhdr;
 	}
-	if (tb[TCA_RSVP_CLASSID-1]) {
-		err = -EINVAL;
-		if (nla_len(tb[TCA_RSVP_CLASSID-1]) != 4)
-			goto errout;
+	if (tb[TCA_RSVP_CLASSID-1])
 		f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
-	}
 
-	err = -EINVAL;
-	if (nla_len(tb[TCA_RSVP_DST-1]) != sizeof(f->src))
-		goto errout;
 	dst = nla_data(tb[TCA_RSVP_DST-1]);
 	h1 = hash_dst(dst, pinfo ? pinfo->protocol : 0, pinfo ? pinfo->tunnelid : 0);
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 2809856..ee60b2d 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -193,6 +193,14 @@ valid_perfect_hash(struct tcindex_data *p)
 	return  p->hash > (p->mask >> p->shift);
 }
 
+static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
+	[TCA_TCINDEX_HASH]		= { .type = NLA_U32 },
+	[TCA_TCINDEX_MASK]		= { .type = NLA_U16 },
+	[TCA_TCINDEX_SHIFT]		= { .type = NLA_U32 },
+	[TCA_TCINDEX_FALL_THROUGH]	= { .type = NLA_U32 },
+	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
+};
+
 static int
 tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		  struct tcindex_data *p, struct tcindex_filter_result *r,
@@ -217,24 +225,14 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	else
 		memset(&cr, 0, sizeof(cr));
 
-	err = -EINVAL;
-	if (tb[TCA_TCINDEX_HASH]) {
-		if (nla_len(tb[TCA_TCINDEX_HASH]) < sizeof(u32))
-			goto errout;
+	if (tb[TCA_TCINDEX_HASH])
 		cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
-	}
 
-	if (tb[TCA_TCINDEX_MASK]) {
-		if (nla_len(tb[TCA_TCINDEX_MASK]) < sizeof(u16))
-			goto errout;
+	if (tb[TCA_TCINDEX_MASK])
 		cp.mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
-	}
 
-	if (tb[TCA_TCINDEX_SHIFT]) {
-		if (nla_len(tb[TCA_TCINDEX_SHIFT]) < sizeof(int))
-			goto errout;
+	if (tb[TCA_TCINDEX_SHIFT])
 		cp.shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
-	}
 
 	err = -EBUSY;
 	/* Hash already allocated, make sure that we still meet the
@@ -248,11 +246,8 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 		goto errout;
 
 	err = -EINVAL;
-	if (tb[TCA_TCINDEX_FALL_THROUGH]) {
-		if (nla_len(tb[TCA_TCINDEX_FALL_THROUGH]) < sizeof(u32))
-			goto errout;
+	if (tb[TCA_TCINDEX_FALL_THROUGH])
 		cp.fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
-	}
 
 	if (!cp.hash) {
 		/* Hash not specified, use perfect hash if the upper limit
@@ -358,7 +353,7 @@ tcindex_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (!opt)
 		return 0;
 
-	err = nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, tcindex_policy);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index a4e72e8..e8a7756 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -460,6 +460,16 @@ static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 	return handle|(i>0xFFF ? 0xFFF : i);
 }
 
+static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
+	[TCA_U32_CLASSID]	= { .type = NLA_U32 },
+	[TCA_U32_HASH]		= { .type = NLA_U32 },
+	[TCA_U32_LINK]		= { .type = NLA_U32 },
+	[TCA_U32_DIVISOR]	= { .type = NLA_U32 },
+	[TCA_U32_SEL]		= { .len = sizeof(struct tc_u32_sel) },
+	[TCA_U32_INDEV]		= { .type = NLA_STRING, .len = IFNAMSIZ },
+	[TCA_U32_MARK]		= { .len = sizeof(struct tc_u32_mark) },
+};
+
 static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 			 struct tc_u_hnode *ht,
 			 struct tc_u_knode *n, struct nlattr **tb,
@@ -531,7 +541,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_U32_MAX, opt, NULL);
+	err = nla_parse_nested(tb, TCA_U32_MAX, opt, u32_policy);
 	if (err < 0)
 		return err;
 
@@ -593,8 +603,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	} else
 		handle = gen_new_kid(ht, htid);
 
-	if (tb[TCA_U32_SEL] == NULL ||
-	    nla_len(tb[TCA_U32_SEL]) < sizeof(struct tc_u32_sel))
+	if (tb[TCA_U32_SEL] == NULL)
 		return -EINVAL;
 
 	s = nla_data(tb[TCA_U32_SEL]);
@@ -620,13 +629,6 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (tb[TCA_U32_MARK]) {
 		struct tc_u32_mark *mark;
 
-		if (nla_len(tb[TCA_U32_MARK]) < sizeof(struct tc_u32_mark)) {
-#ifdef CONFIG_CLS_U32_PERF
-			kfree(n->pf);
-#endif
-			kfree(n);
-			return -EINVAL;
-		}
 		mark = nla_data(tb[TCA_U32_MARK]);
 		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
 		n->mark.success = 0;
