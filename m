From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: properly handle failure case of tcf_exts_init()
Date: Fri, 19 Aug 2016 12:36:54 -0700
Message-ID: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34285 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750906AbcHSTh3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 15:37:29 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so1886390pfb.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 12:37:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array")
we do dynamic allocation in tcf_exts_init(), therefore we need
to handle the ENOMEM case properly.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h   |  6 ++--
 net/sched/cls_basic.c   | 12 +++++--
 net/sched/cls_bpf.c     | 27 +++++++++------
 net/sched/cls_cgroup.c  | 13 +++++--
 net/sched/cls_flow.c    | 26 ++++++++------
 net/sched/cls_flower.c  | 11 ++++--
 net/sched/cls_fw.c      | 18 +++++++---
 net/sched/cls_route.c   | 14 +++++---
 net/sched/cls_rsvp.h    | 17 +++++++---
 net/sched/cls_tcindex.c | 90 +++++++++++++++++++++++++++++++++++--------------
 net/sched/cls_u32.c     | 21 ++++++++----
 11 files changed, 181 insertions(+), 74 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index c99508d..a459be5 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -69,17 +69,19 @@ struct tcf_exts {
 	int police;
 };
 
-static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
+static inline int tcf_exts_init(struct tcf_exts *exts, int action, int police)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	exts->type = 0;
 	exts->nr_actions = 0;
 	exts->actions = kcalloc(TCA_ACT_MAX_PRIO, sizeof(struct tc_action *),
 				GFP_KERNEL);
-	WARN_ON(!exts->actions); /* TODO: propagate the error to callers */
+	if (!exts->actions)
+		return -ENOMEM;
 #endif
 	exts->action = action;
 	exts->police = police;
+	return 0;
 }
 
 /**
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 0b8c3ac..eb219b7 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -138,10 +138,12 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
-	tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &t);
 	if (err < 0)
@@ -189,7 +191,10 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (!fnew)
 		return -ENOBUFS;
 
-	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	err = tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	if (err < 0)
+		goto errout;
+
 	err = -EINVAL;
 	if (handle) {
 		fnew->handle = handle;
@@ -226,6 +231,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 
 	return 0;
 errout:
+	tcf_exts_destroy(&fnew->exts);
 	kfree(fnew);
 	return err;
 }
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index c3002c2..4742f41 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -311,17 +311,19 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf))
 		return -EINVAL;
 
-	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
+	ret = tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
 	if (ret < 0)
 		return ret;
+	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
+	if (ret < 0)
+		goto errout;
 
 	if (tb[TCA_BPF_FLAGS]) {
 		u32 bpf_flags = nla_get_u32(tb[TCA_BPF_FLAGS]);
 
 		if (bpf_flags & ~TCA_BPF_FLAG_ACT_DIRECT) {
-			tcf_exts_destroy(&exts);
-			return -EINVAL;
+			ret = -EINVAL;
+			goto errout;
 		}
 
 		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
@@ -331,10 +333,8 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
 		       cls_bpf_prog_from_efd(tb, prog, tp);
-	if (ret < 0) {
-		tcf_exts_destroy(&exts);
-		return ret;
-	}
+	if (ret < 0)
+		goto errout;
 
 	if (tb[TCA_BPF_CLASSID]) {
 		prog->res.classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
@@ -343,6 +343,10 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 	tcf_exts_change(tp, &prog->exts, &exts);
 	return 0;
+
+errout:
+	tcf_exts_destroy(&exts);
+	return ret;
 }
 
 static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
@@ -388,7 +392,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (!prog)
 		return -ENOBUFS;
 
-	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+	ret = tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+	if (ret < 0)
+		goto errout;
 
 	if (oldprog) {
 		if (handle && oldprog->handle != handle) {
@@ -420,9 +426,10 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 
 	*arg = (unsigned long) prog;
 	return 0;
+
 errout:
+	tcf_exts_destroy(&prog->exts);
 	kfree(prog);
-
 	return ret;
 }
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 4c85bd3..85233c47 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -93,7 +93,9 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!new)
 		return -ENOBUFS;
 
-	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	err = tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	if (err < 0)
+		goto errout;
 	new->handle = handle;
 	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
@@ -101,10 +103,14 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	if (err < 0)
 		goto errout;
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	if (err < 0) {
+		tcf_exts_destroy(&e);
+		goto errout;
+	}
 
 	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
 	if (err < 0) {
@@ -120,6 +126,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	return 0;
 errout:
+	tcf_exts_destroy(&new->exts);
 	kfree(new);
 	return err;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index fbfec6a..2c1ae54 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -418,10 +418,12 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	err = tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	if (err < 0)
+		goto err1;
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0)
-		return err;
+		goto err1;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &t);
 	if (err < 0)
@@ -432,13 +434,15 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (!fnew)
 		goto err2;
 
-	tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	err = tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	if (err < 0)
+		goto err3;
 
 	fold = (struct flow_filter *)*arg;
 	if (fold) {
 		err = -EINVAL;
 		if (fold->handle != handle && handle)
-			goto err2;
+			goto err3;
 
 		/* Copy fold into fnew */
 		fnew->tp = fold->tp;
@@ -458,31 +462,31 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		if (tb[TCA_FLOW_MODE])
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err2;
+			goto err3;
 
 		if (mode == FLOW_MODE_HASH)
 			perturb_period = fold->perturb_period;
 		if (tb[TCA_FLOW_PERTURB]) {
 			if (mode != FLOW_MODE_HASH)
-				goto err2;
+				goto err3;
 			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
 		}
 	} else {
 		err = -EINVAL;
 		if (!handle)
-			goto err2;
+			goto err3;
 		if (!tb[TCA_FLOW_KEYS])
-			goto err2;
+			goto err3;
 
 		mode = FLOW_MODE_MAP;
 		if (tb[TCA_FLOW_MODE])
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err2;
+			goto err3;
 
 		if (tb[TCA_FLOW_PERTURB]) {
 			if (mode != FLOW_MODE_HASH)
-				goto err2;
+				goto err3;
 			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
 		}
 
@@ -542,6 +546,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		call_rcu(&fold->rcu, flow_destroy_filter);
 	return 0;
 
+err3:
+	tcf_exts_destroy(&fnew->exts);
 err2:
 	tcf_em_tree_destroy(&t);
 	kfree(fnew);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1e11e57..532ab67 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -513,10 +513,12 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	tcf_exts_init(&e, TCA_FLOWER_ACT, 0);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_init(&e, TCA_FLOWER_ACT, 0);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	if (tb[TCA_FLOWER_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FLOWER_CLASSID]);
@@ -585,7 +587,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (!fnew)
 		return -ENOBUFS;
 
-	tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
+	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
+	if (err < 0)
+		goto errout;
 
 	if (!handle) {
 		handle = fl_grab_new_handle(tp, head);
@@ -649,6 +653,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 errout:
+	tcf_exts_destroy(&fnew->exts);
 	kfree(fnew);
 	return err;
 }
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index f23a3b6..cc0bda9 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -195,10 +195,12 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	u32 mask;
 	int err;
 
-	tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	if (tb[TCA_FW_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
@@ -270,10 +272,15 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 #endif /* CONFIG_NET_CLS_IND */
 		fnew->tp = f->tp;
 
-		tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
+		err = tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
+		if (err < 0) {
+			kfree(fnew);
+			return err;
+		}
 
 		err = fw_change_attrs(net, tp, fnew, tb, tca, base, ovr);
 		if (err < 0) {
+			tcf_exts_destroy(&fnew->exts);
 			kfree(fnew);
 			return err;
 		}
@@ -313,7 +320,9 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		return -ENOBUFS;
 
-	tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
+	err = tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
+	if (err < 0)
+		goto errout;
 	f->id = handle;
 	f->tp = tp;
 
@@ -328,6 +337,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 errout:
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 	return err;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 08a3b0a..c91e65d 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -383,17 +383,19 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 			    struct nlattr **tb, struct nlattr *est, int new,
 			    bool ovr)
 {
-	int err;
 	u32 id = 0, to = 0, nhandle = 0x8000;
 	struct route4_filter *fp;
 	unsigned int h1;
 	struct route4_bucket *b;
 	struct tcf_exts e;
+	int err;
 
-	tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	err = -EINVAL;
 	if (tb[TCA_ROUTE4_TO]) {
@@ -503,7 +505,10 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (!f)
 		goto errout;
 
-	tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
+	err = tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
+	if (err < 0)
+		goto errout;
+
 	if (fold) {
 		f->id = fold->id;
 		f->iif = fold->iif;
@@ -557,6 +562,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 errout:
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 	return err;
 }
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index f9c9fc0..4f05a19 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -487,10 +487,12 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	if (err < 0)
+		goto errout2;
 
 	f = (struct rsvp_filter *)*arg;
 	if (f) {
@@ -506,7 +508,11 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			goto errout2;
 		}
 
-		tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+		err = tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+		if (err < 0) {
+			kfree(n);
+			goto errout2;
+		}
 
 		if (tb[TCA_RSVP_CLASSID]) {
 			n->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID]);
@@ -530,7 +536,9 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout2;
 
-	tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+	err = tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+	if (err < 0)
+		goto errout;
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
@@ -627,6 +635,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	goto insert;
 
 errout:
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 errout2:
 	tcf_exts_destroy(&e);
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 944c8ff..d950070 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -219,10 +219,10 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
 };
 
-static void tcindex_filter_result_init(struct tcindex_filter_result *r)
+static int tcindex_filter_result_init(struct tcindex_filter_result *r)
 {
 	memset(r, 0, sizeof(*r));
-	tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+	return tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 }
 
 static void __tcindex_partial_destroy(struct rcu_head *head)
@@ -233,23 +233,57 @@ static void __tcindex_partial_destroy(struct rcu_head *head)
 	kfree(p);
 }
 
+static void tcindex_free_perfect_hash(struct tcindex_data *cp)
+{
+	int i;
+
+	for (i = 0; i < cp->hash; i++)
+		tcf_exts_destroy(&cp->perfect[i].exts);
+	kfree(cp->perfect);
+}
+
+static int tcindex_alloc_perfect_hash(struct tcindex_data *cp)
+{
+	int i, err = 0;
+
+	cp->perfect = kcalloc(cp->hash, sizeof(struct tcindex_filter_result),
+			      GFP_KERNEL);
+	if (!cp->perfect)
+		return -ENOMEM;
+
+	for (i = 0; i < cp->hash; i++) {
+		err = tcf_exts_init(&cp->perfect[i].exts,
+				    TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+		if (err < 0)
+			goto errout;
+	}
+
+	return 0;
+
+errout:
+	tcindex_free_perfect_hash(cp);
+	return err;
+}
+
 static int
 tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		  u32 handle, struct tcindex_data *p,
 		  struct tcindex_filter_result *r, struct nlattr **tb,
 		  struct nlattr *est, bool ovr)
 {
-	int err, balloc = 0;
 	struct tcindex_filter_result new_filter_result, *old_r = r;
 	struct tcindex_filter_result cr;
-	struct tcindex_data *cp, *oldp;
+	struct tcindex_data *cp = NULL, *oldp;
 	struct tcindex_filter *f = NULL; /* make gcc behave */
+	int err, balloc = 0;
 	struct tcf_exts e;
 
-	tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	err = -ENOMEM;
 	/* tcindex_data attributes must look atomic to classifier/lookup so
@@ -270,19 +304,20 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	if (p->perfect) {
 		int i;
 
-		cp->perfect = kmemdup(p->perfect,
-				      sizeof(*r) * cp->hash, GFP_KERNEL);
-		if (!cp->perfect)
+		if (tcindex_alloc_perfect_hash(cp) < 0)
 			goto errout;
 		for (i = 0; i < cp->hash; i++)
-			tcf_exts_init(&cp->perfect[i].exts,
-				      TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+			cp->perfect[i].res = p->perfect[i].res;
 		balloc = 1;
 	}
 	cp->h = p->h;
 
-	tcindex_filter_result_init(&new_filter_result);
-	tcindex_filter_result_init(&cr);
+	err = tcindex_filter_result_init(&new_filter_result);
+	if (err < 0)
+		goto errout1;
+	err = tcindex_filter_result_init(&cr);
+	if (err < 0)
+		goto errout1;
 	if (old_r)
 		cr.res = r->res;
 
@@ -338,15 +373,8 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	err = -ENOMEM;
 	if (!cp->perfect && !cp->h) {
 		if (valid_perfect_hash(cp)) {
-			int i;
-
-			cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
-			if (!cp->perfect)
+			if (tcindex_alloc_perfect_hash(cp) < 0)
 				goto errout_alloc;
-			for (i = 0; i < cp->hash; i++)
-				tcf_exts_init(&cp->perfect[i].exts,
-					      TCA_TCINDEX_ACT,
-					      TCA_TCINDEX_POLICE);
 			balloc = 1;
 		} else {
 			struct tcindex_filter __rcu **hash;
@@ -373,8 +401,12 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		if (!f)
 			goto errout_alloc;
 		f->key = handle;
-		tcindex_filter_result_init(&f->result);
 		f->next = NULL;
+		err = tcindex_filter_result_init(&f->result);
+		if (err < 0) {
+			kfree(f);
+			goto errout_alloc;
+		}
 	}
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
@@ -387,8 +419,13 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	else
 		tcf_exts_change(tp, &cr.exts, &e);
 
-	if (old_r && old_r != r)
-		tcindex_filter_result_init(old_r);
+	if (old_r && old_r != r) {
+		err = tcindex_filter_result_init(old_r);
+		if (err < 0) {
+			kfree(f);
+			goto errout_alloc;
+		}
+	}
 
 	oldp = p;
 	r->res = cr.res;
@@ -415,9 +452,12 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 
 errout_alloc:
 	if (balloc == 1)
-		kfree(cp->perfect);
+		tcindex_free_perfect_hash(cp);
 	else if (balloc == 2)
 		kfree(cp->h);
+errout1:
+	tcf_exts_destroy(&cr.exts);
+	tcf_exts_destroy(&new_filter_result.exts);
 errout:
 	kfree(cp);
 	tcf_exts_destroy(&e);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index ffe593e..a29263a 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -709,13 +709,15 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 			 struct tc_u_knode *n, struct nlattr **tb,
 			 struct nlattr *est, bool ovr)
 {
-	int err;
 	struct tcf_exts e;
+	int err;
 
-	tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
 	if (err < 0)
 		return err;
+	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	if (err < 0)
+		goto errout;
 
 	err = -EINVAL;
 	if (tb[TCA_U32_LINK]) {
@@ -833,7 +835,10 @@ static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
 	new->tp = tp;
 	memcpy(&new->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 
-	tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	if (tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE)) {
+		kfree(new);
+		return NULL;
+	}
 
 	return new;
 }
@@ -985,9 +990,12 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 	n->flags = flags;
-	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
 	n->tp = tp;
 
+	err = tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	if (err < 0)
+		goto errout;
+
 #ifdef CONFIG_CLS_U32_MARK
 	n->pcpu_success = alloc_percpu(u32);
 	if (!n->pcpu_success) {
@@ -1028,9 +1036,10 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 errhw:
 #ifdef CONFIG_CLS_U32_MARK
 	free_percpu(n->pcpu_success);
-errout:
 #endif
 
+errout:
+	tcf_exts_destroy(&n->exts);
 #ifdef CONFIG_CLS_U32_PERF
 	free_percpu(n->pf);
 #endif
-- 
2.1.0
