From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: refactor out tcf_exts
Date: Fri,  3 Oct 2014 15:51:49 -0700
Message-ID: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34458 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272AbaJCWvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:51:54 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so307837pdb.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:51:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Jamal pointed it out, tcf_exts is really unnecessary,
we can definitely refactor it out without losing any functionality.
This could also remove an indirect layer which makes the code
much easier to read.

This patch:

1) moves exts->action and exts->police into tp->ops, since they
are statically assigned

2) moves exts->actions list head out

3) removes exts->type, act->type does the same thing

4) renames tcf_exts_*() functions to tcf_act_*()

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h     | 80 ++++++++++++++++++-----------------------------
 include/net/sch_generic.h |  2 ++
 net/sched/act_api.c       |  9 ++++--
 net/sched/cls_api.c       | 77 ++++++++++++++++++++++++---------------------
 net/sched/cls_basic.c     | 23 +++++++-------
 net/sched/cls_bpf.c       | 23 +++++++-------
 net/sched/cls_cgroup.c    | 24 +++++++-------
 net/sched/cls_flow.c      | 23 +++++++-------
 net/sched/cls_fw.c        | 27 ++++++++--------
 net/sched/cls_route.c     | 25 ++++++++-------
 net/sched/cls_rsvp.h      | 27 ++++++++--------
 net/sched/cls_tcindex.c   | 36 ++++++++++-----------
 net/sched/cls_u32.c       | 26 +++++++--------
 13 files changed, 198 insertions(+), 204 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index ef44ad9..24bc41f 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -56,88 +56,68 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
 
-struct tcf_exts {
-#ifdef CONFIG_NET_CLS_ACT
-	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
-	struct list_head actions;
-#endif
-	/* Map to export classifier specific extension TLV types to the
-	 * generic extensions API. Unsupported extensions must be set to 0.
-	 */
-	int action;
-	int police;
-};
-
-static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
-{
-#ifdef CONFIG_NET_CLS_ACT
-	exts->type = 0;
-	INIT_LIST_HEAD(&exts->actions);
-#endif
-	exts->action = action;
-	exts->police = police;
-}
-
 /**
- * tcf_exts_is_predicative - check if a predicative extension is present
- * @exts: tc filter extensions handle
+ * tcf_act_is_predicative - check if a predicative action is present
+ * @actions: tc filter actions
  *
- * Returns 1 if a predicative extension is present, i.e. an extension which
+ * Returns 1 if a predicative action is present, i.e. an action which
  * might cause further actions and thus overrule the regular tcf_result.
  */
 static inline int
-tcf_exts_is_predicative(struct tcf_exts *exts)
+tcf_act_is_predicative(struct list_head *actions)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return !list_empty(&exts->actions);
+	return !list_empty(actions);
 #else
 	return 0;
 #endif
 }
 
 /**
- * tcf_exts_is_available - check if at least one extension is present
- * @exts: tc filter extensions handle
+ * tcf_act_is_available - check if at least one action is present
+ * @actions: tc filter actions
  *
- * Returns 1 if at least one extension is present.
+ * Returns 1 if at least one action is present.
  */
 static inline int
-tcf_exts_is_available(struct tcf_exts *exts)
+tcf_act_is_available(struct list_head *actions)
 {
-	/* All non-predicative extensions must be added here. */
-	return tcf_exts_is_predicative(exts);
+	/* All non-predicative actions must be added here. */
+	return tcf_act_is_predicative(actions);
 }
 
 /**
- * tcf_exts_exec - execute tc filter extensions
+ * tcf_act_exec - execute tc filter actions
  * @skb: socket buffer
- * @exts: tc filter extensions handle
+ * @actions: list of actions
  * @res: desired result
  *
- * Executes all configured extensions. Returns 0 on a normal execution,
+ * Executes all configured actions. Returns 0 on a normal execution,
  * a negative number if the filter must be considered unmatched or
  * a positive action code (TC_ACT_*) which must be returned to the
  * underlying layer.
  */
-static inline int
-tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
-	       struct tcf_result *res)
-{
 #ifdef CONFIG_NET_CLS_ACT
-	if (!list_empty(&exts->actions))
-		return tcf_action_exec(skb, &exts->actions, res);
-#endif
+int tcf_act_exec(struct sk_buff *skb, struct list_head *actions,
+		 struct tcf_result *res);
+#else
+static inline
+int tcf_act_exec(struct sk_buff *skb, struct list_head *actions,
+		 struct tcf_result *res)
+{
 	return 0;
 }
+#endif
 
-int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
+int tcf_act_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
-		      struct tcf_exts *exts, bool ovr);
-void tcf_exts_destroy(struct tcf_exts *exts);
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src);
-int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
-int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
+		      struct list_head *actions, bool ovr);
+void tcf_act_destroy(struct list_head *actions);
+void tcf_act_change(struct tcf_proto *tp, struct list_head *dst,
+		     struct list_head *src);
+int tcf_act_dump(struct sk_buff *skb, const struct tcf_proto *tp,
+		 struct list_head *actions);
+int tcf_act_dump_stats(struct sk_buff *skb, struct list_head *actions);
 
 /**
  * struct tcf_pkt_info - packet information
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d17ed6f..3d9fac9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -211,6 +211,8 @@ struct tcf_result {
 struct tcf_proto_ops {
 	struct list_head	head;
 	char			kind[IFNAMSIZ];
+	int			action;
+	int			police;
 
 	int			(*classify)(struct sk_buff *,
 					    const struct tcf_proto *,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3d43e49..a350598 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -378,12 +378,15 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 	return res;
 }
 
-int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
-		    struct tcf_result *res)
+int tcf_act_exec(struct sk_buff *skb, const struct list_head *actions,
+		 struct tcf_result *res)
 {
 	const struct tc_action *a;
 	int ret = -1;
 
+	if (list_empty(actions))
+		return 0;
+
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
 		ret = TC_ACT_OK;
@@ -405,7 +408,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 exec_done:
 	return ret;
 }
-EXPORT_SYMBOL(tcf_action_exec);
+EXPORT_SYMBOL(tcf_act_exec);
 
 int tcf_action_destroy(struct list_head *actions, int bind)
 {
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 77147c8..d6f0059 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -496,89 +496,94 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void tcf_exts_destroy(struct tcf_exts *exts)
+void tcf_act_destroy(struct list_head *actions)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	tcf_action_destroy(&exts->actions, TCA_ACT_UNBIND);
-	INIT_LIST_HEAD(&exts->actions);
+	tcf_action_destroy(actions, TCA_ACT_UNBIND);
+	INIT_LIST_HEAD(actions);
 #endif
 }
-EXPORT_SYMBOL(tcf_exts_destroy);
+EXPORT_SYMBOL(tcf_act_destroy);
 
-int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
-		  struct nlattr *rate_tlv, struct tcf_exts *exts, bool ovr)
+int tcf_act_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
+		     struct nlattr *rate_tlv, struct list_head *actions,
+		     bool ovr)
 {
+	int police = tp->ops->police;
+	int action = tp->ops->action;
+
 #ifdef CONFIG_NET_CLS_ACT
 	{
 		struct tc_action *act;
 
-		INIT_LIST_HEAD(&exts->actions);
-		if (exts->police && tb[exts->police]) {
-			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
+		INIT_LIST_HEAD(actions);
+		if (police && tb[police]) {
+			act = tcf_action_init_1(net, tb[police], rate_tlv,
 						"police", ovr,
 						TCA_ACT_BIND);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
-			act->type = exts->type = TCA_OLD_COMPAT;
-			list_add(&act->list, &exts->actions);
-		} else if (exts->action && tb[exts->action]) {
+			act->type = TCA_OLD_COMPAT;
+			list_add(&act->list, actions);
+		} else if (action && tb[action]) {
 			int err;
-			err = tcf_action_init(net, tb[exts->action], rate_tlv,
+			err = tcf_action_init(net, tb[action], rate_tlv,
 					      NULL, ovr,
-					      TCA_ACT_BIND, &exts->actions);
+					      TCA_ACT_BIND, actions);
 			if (err)
 				return err;
 		}
 	}
 #else
-	if ((exts->action && tb[exts->action]) ||
-	    (exts->police && tb[exts->police]))
+	if ((action && tb[action]) ||
+	    (police && tb[police]))
 		return -EOPNOTSUPP;
 #endif
 
 	return 0;
 }
-EXPORT_SYMBOL(tcf_exts_validate);
+EXPORT_SYMBOL(tcf_act_validate);
 
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src)
+void tcf_act_change(struct tcf_proto *tp, struct list_head *dst,
+		    struct list_head *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	LIST_HEAD(tmp);
 	tcf_tree_lock(tp);
-	list_splice_init(&dst->actions, &tmp);
-	list_splice(&src->actions, &dst->actions);
+	list_splice_init(dst, &tmp);
+	list_splice(src, dst);
 	tcf_tree_unlock(tp);
 	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
 #endif
 }
-EXPORT_SYMBOL(tcf_exts_change);
+EXPORT_SYMBOL(tcf_act_change);
 
-#define tcf_exts_first_act(ext) \
-		list_first_entry(&(exts)->actions, struct tc_action, list)
+#define tcf_act_first_act(actions) \
+		list_first_entry(actions, struct tc_action, list)
 
-int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
+int tcf_act_dump(struct sk_buff *skb, const struct tcf_proto *tp,
+		 struct list_head *actions)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct nlattr *nest;
 
-	if (exts->action && !list_empty(&exts->actions)) {
+	if (tp->ops->action && !list_empty(actions)) {
+		struct tc_action *act = tcf_act_first_act(actions);
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
-		if (exts->type != TCA_OLD_COMPAT) {
-			nest = nla_nest_start(skb, exts->action);
+		if (act->type != TCA_OLD_COMPAT) {
+			nest = nla_nest_start(skb, tp->ops->action);
 			if (nest == NULL)
 				goto nla_put_failure;
-			if (tcf_action_dump(skb, &exts->actions, 0, 0) < 0)
+			if (tcf_action_dump(skb, actions, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
-		} else if (exts->police) {
-			struct tc_action *act = tcf_exts_first_act(exts);
-			nest = nla_nest_start(skb, exts->police);
+		} else if (tp->ops->police) {
+			nest = nla_nest_start(skb, tp->ops->police);
 			if (nest == NULL || !act)
 				goto nla_put_failure;
 			if (tcf_action_dump_old(skb, act, 0, 0) < 0)
@@ -595,19 +600,19 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 	return 0;
 #endif
 }
-EXPORT_SYMBOL(tcf_exts_dump);
+EXPORT_SYMBOL(tcf_act_dump);
 
 
-int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
+int tcf_act_dump_stats(struct sk_buff *skb, struct list_head *actions)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	struct tc_action *a = tcf_exts_first_act(exts);
+	struct tc_action *a = tcf_act_first_act(actions);
 	if (tcf_action_copy_stats(skb, a, 1) < 0)
 		return -1;
 #endif
 	return 0;
 }
-EXPORT_SYMBOL(tcf_exts_dump_stats);
+EXPORT_SYMBOL(tcf_act_dump_stats);
 
 static int __init tc_filter_init(void)
 {
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index fe20826..09c8db6 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -29,7 +29,7 @@ struct basic_head {
 
 struct basic_filter {
 	u32			handle;
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_result	res;
 	struct tcf_proto	*tp;
@@ -48,7 +48,7 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		if (!tcf_em_tree_match(skb, &f->ematches, NULL))
 			continue;
 		*res = f->res;
-		r = tcf_exts_exec(skb, &f->exts, res);
+		r = tcf_act_exec(skb, &f->actions, res);
 		if (r < 0)
 			continue;
 		return r;
@@ -94,7 +94,7 @@ static void basic_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(&f->exts);
+	tcf_act_destroy(&f->actions);
 	tcf_em_tree_destroy(tp, &f->ematches);
 	kfree(f);
 }
@@ -138,11 +138,10 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 			   struct nlattr *est, bool ovr)
 {
 	int err;
-	struct tcf_exts e;
 	struct tcf_ematch_tree t;
+	struct list_head actions;
 
-	tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_act_validate(net, tp, tb, est, &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -155,13 +154,13 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_act_change(tp, &f->actions, &actions);
 	tcf_em_tree_change(tp, &f->ematches, &t);
 	f->tp = tp;
 
 	return 0;
 errout:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -193,7 +192,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (fnew == NULL)
 		goto errout;
 
-	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	INIT_LIST_HEAD(&fnew->actions);
 	err = -EINVAL;
 	if (handle) {
 		fnew->handle = handle;
@@ -270,13 +269,13 @@ static int basic_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_BASIC_CLASSID, f->res.classid))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts) < 0 ||
+	if (tcf_act_dump(skb, tp, &f->actions) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_act_dump_stats(skb, &f->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -288,6 +287,8 @@ static int basic_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.kind		=	"basic",
+	.police		=	TCA_BASIC_POLICE,
+	.action		=	TCA_BASIC_ACT,
 	.classify	=	basic_classify,
 	.init		=	basic_init,
 	.destroy	=	basic_destroy,
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 4318d06..dbdf38c 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -33,7 +33,7 @@ struct cls_bpf_head {
 struct cls_bpf_prog {
 	struct bpf_prog *filter;
 	struct sock_filter *bpf_ops;
-	struct tcf_exts exts;
+	struct list_head actions;
 	struct tcf_result res;
 	struct list_head link;
 	u32 handle;
@@ -66,7 +66,7 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		if (filter_res != -1)
 			res->classid = filter_res;
 
-		ret = tcf_exts_exec(skb, &prog->exts, res);
+		ret = tcf_act_exec(skb, &prog->actions, res);
 		if (ret < 0)
 			continue;
 
@@ -93,7 +93,7 @@ static int cls_bpf_init(struct tcf_proto *tp)
 static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	tcf_unbind_filter(tp, &prog->res);
-	tcf_exts_destroy(&prog->exts);
+	tcf_act_destroy(&prog->actions);
 
 	bpf_prog_destroy(prog->filter);
 
@@ -167,7 +167,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 				   struct nlattr *est, bool ovr)
 {
 	struct sock_filter *bpf_ops;
-	struct tcf_exts exts;
+	struct list_head actions;
 	struct sock_fprog_kern tmp;
 	struct bpf_prog *fp;
 	u16 bpf_size, bpf_len;
@@ -177,8 +177,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if (!tb[TCA_BPF_OPS_LEN] || !tb[TCA_BPF_OPS] || !tb[TCA_BPF_CLASSID])
 		return -EINVAL;
 
-	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
+	ret = tcf_act_validate(net, tp, tb, est, &actions, ovr);
 	if (ret < 0)
 		return ret;
 
@@ -211,13 +210,13 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	prog->res.classid = classid;
 
 	tcf_bind_filter(tp, &prog->res, base);
-	tcf_exts_change(tp, &prog->exts, &exts);
+	tcf_act_change(tp, &prog->actions, &actions);
 
 	return 0;
 errout_free:
 	kfree(bpf_ops);
 errout:
-	tcf_exts_destroy(&exts);
+	tcf_act_destroy(&actions);
 	return ret;
 }
 
@@ -258,7 +257,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (!prog)
 		return -ENOBUFS;
 
-	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+	INIT_LIST_HEAD(&prog->actions);
 
 	if (oldprog) {
 		if (handle && oldprog->handle != handle) {
@@ -322,12 +321,12 @@ static int cls_bpf_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
 
-	if (tcf_exts_dump(skb, &prog->exts) < 0)
+	if (tcf_act_dump(skb, tp, &prog->actions) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &prog->exts) < 0)
+	if (tcf_act_dump_stats(skb, &prog->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -356,6 +355,8 @@ static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 
 static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.kind		=	"bpf",
+	.action		=	TCA_BPF_ACT,
+	.police		=	TCA_BPF_POLICE,
 	.owner		=	THIS_MODULE,
 	.classify	=	cls_bpf_classify,
 	.init		=	cls_bpf_init,
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3409f16..9640b20 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -20,7 +20,7 @@
 
 struct cls_cgroup_head {
 	u32			handle;
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_proto	*tp;
 	struct rcu_head		rcu;
@@ -59,7 +59,7 @@ static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 	res->classid = classid;
 	res->class = 0;
-	return tcf_exts_exec(skb, &head->exts, res);
+	return tcf_act_exec(skb, &head->actions, res);
 }
 
 static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)
@@ -86,7 +86,7 @@ static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 						    struct cls_cgroup_head,
 						    rcu);
 
-	tcf_exts_destroy(&head->exts);
+	tcf_act_destroy(&head->actions);
 	tcf_em_tree_destroy(head->tp, &head->ematches);
 	kfree(head);
 }
@@ -100,7 +100,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 	struct cls_cgroup_head *new;
 	struct tcf_ematch_tree t;
-	struct tcf_exts e;
+	struct list_head actions;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -116,7 +116,6 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!new)
 		return -ENOBUFS;
 
-	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	if (head)
 		new->handle = head->handle;
 	else
@@ -128,18 +127,17 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_act_validate(net, tp, tb, tca[TCA_RATE], &actions, ovr);
 	if (err < 0)
 		goto errout;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
 	if (err < 0) {
-		tcf_exts_destroy(&e);
+		tcf_act_destroy(&actions);
 		goto errout;
 	}
 
-	tcf_exts_change(tp, &new->exts, &e);
+	tcf_act_change(tp, &new->actions, &actions);
 	tcf_em_tree_change(tp, &new->ematches, &t);
 
 	rcu_assign_pointer(tp->root, new);
@@ -156,7 +154,7 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (head) {
-		tcf_exts_destroy(&head->exts);
+		tcf_act_destroy(&head->actions);
 		tcf_em_tree_destroy(tp, &head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
 		kfree_rcu(head, rcu);
@@ -196,13 +194,13 @@ static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &head->exts) < 0 ||
+	if (tcf_act_dump(skb, tp, &head->actions) < 0 ||
 	    tcf_em_tree_dump(skb, &head->ematches, TCA_CGROUP_EMATCHES) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &head->exts) < 0)
+	if (tcf_act_dump_stats(skb, &head->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -214,6 +212,8 @@ static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long
 
 static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 	.kind		=	"cgroup",
+	.action		=	TCA_CGROUP_ACT,
+	.police		=	TCA_CGROUP_POLICE,
 	.init		=	cls_cgroup_init,
 	.change		=	cls_cgroup_change,
 	.classify	=	cls_cgroup_classify,
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index f18d27f7..5cbc556 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -39,7 +39,7 @@ struct flow_head {
 
 struct flow_filter {
 	struct list_head	list;
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	struct tcf_ematch_tree	ematches;
 	struct tcf_proto	*tp;
 	struct timer_list	perturb_timer;
@@ -317,7 +317,7 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		res->class   = 0;
 		res->classid = TC_H_MAKE(f->baseclass, f->baseclass + classid);
 
-		r = tcf_exts_exec(skb, &f->exts, res);
+		r = tcf_act_exec(skb, &f->actions, res);
 		if (r < 0)
 			continue;
 		return r;
@@ -354,7 +354,7 @@ static void flow_destroy_filter(struct rcu_head *head)
 	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
 
 	del_timer_sync(&f->perturb_timer);
-	tcf_exts_destroy(&f->exts);
+	tcf_act_destroy(&f->actions);
 	tcf_em_tree_destroy(f->tp, &f->ematches);
 	kfree(f);
 }
@@ -368,7 +368,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	struct flow_filter *fold, *fnew;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FLOW_MAX + 1];
-	struct tcf_exts e;
+	struct list_head actions;
 	struct tcf_ematch_tree t;
 	unsigned int nkeys = 0;
 	unsigned int perturb_period = 0;
@@ -405,8 +405,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_act_validate(net, tp, tb, tca[TCA_RATE], &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -483,14 +482,14 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		fnew->mask  = ~0U;
 		fnew->tp = tp;
 		get_random_bytes(&fnew->hashrnd, 4);
-		tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+		INIT_LIST_HEAD(&fnew->actions);
 	}
 
 	fnew->perturb_timer.function = flow_perturbation;
 	fnew->perturb_timer.data = (unsigned long)fnew;
 	init_timer_deferrable(&fnew->perturb_timer);
 
-	tcf_exts_change(tp, &fnew->exts, &e);
+	tcf_act_change(tp, &fnew->actions, &actions);
 	tcf_em_tree_change(tp, &fnew->ematches, &t);
 
 	if (tb[TCA_FLOW_KEYS]) {
@@ -533,7 +532,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	tcf_em_tree_destroy(tp, &t);
 	kfree(fnew);
 err1:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -628,7 +627,7 @@ static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_FLOW_PERTURB, f->perturb_period / HZ))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts) < 0)
+	if (tcf_act_dump(skb, tp, &f->actions) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_NET_EMATCH
 	if (f->ematches.hdr.nmatches &&
@@ -637,7 +636,7 @@ static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 #endif
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_act_dump_stats(skb, &f->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -666,6 +665,8 @@ static void flow_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 
 static struct tcf_proto_ops cls_flow_ops __read_mostly = {
 	.kind		= "flow",
+	.action		= TCA_FLOW_ACT,
+	.police		= TCA_FLOW_POLICE,
 	.classify	= flow_classify,
 	.init		= flow_init,
 	.destroy	= flow_destroy,
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index da805ae..ba955c4 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -44,7 +44,7 @@ struct fw_filter {
 #ifdef CONFIG_NET_CLS_IND
 	int			ifindex;
 #endif /* CONFIG_NET_CLS_IND */
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	struct tcf_proto	*tp;
 	struct rcu_head		rcu;
 };
@@ -75,7 +75,7 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 				if (!tcf_match_indev(skb, f->ifindex))
 					continue;
 #endif /* CONFIG_NET_CLS_IND */
-				r = tcf_exts_exec(skb, &f->exts, res);
+				r = tcf_act_exec(skb, &f->actions, res);
 				if (r < 0)
 					continue;
 
@@ -126,7 +126,7 @@ static void fw_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(&f->exts);
+	tcf_act_destroy(&f->actions);
 	kfree(f);
 }
 
@@ -185,12 +185,11 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	struct nlattr **tb, struct nlattr **tca, unsigned long base, bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
-	struct tcf_exts e;
+	struct list_head actions;
 	u32 mask;
 	int err;
 
-	tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_act_validate(net, tp, tb, tca[TCA_RATE], &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -219,11 +218,11 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	} else if (head->mask != 0xFFFFFFFF)
 		goto errout;
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_act_change(tp, &f->actions, &actions);
 
 	return 0;
 errout:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -264,7 +263,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 #endif /* CONFIG_NET_CLS_IND */
 		fnew->tp = f->tp;
 
-		tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
+		INIT_LIST_HEAD(&fnew->actions);
 
 		err = fw_change_attrs(net, tp, fnew, tb, tca, base, ovr);
 		if (err < 0) {
@@ -306,7 +305,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		return -ENOBUFS;
 
-	tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
+	INIT_LIST_HEAD(&f->actions);
 	f->id = handle;
 	f->tp = tp;
 
@@ -367,7 +366,7 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	t->tcm_handle = f->id;
 
-	if (!f->res.classid && !tcf_exts_is_available(&f->exts))
+	if (!f->res.classid && !tcf_act_is_available(&f->actions))
 		return skb->len;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
@@ -389,12 +388,12 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_FW_MASK, head->mask))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts) < 0)
+	if (tcf_act_dump(skb, tp, &f->actions) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_act_dump_stats(skb, &f->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -406,6 +405,8 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.kind		=	"fw",
+	.action		=	TCA_FW_ACT,
+	.police		=	TCA_FW_POLICE,
 	.classify	=	fw_classify,
 	.init		=	fw_init,
 	.destroy	=	fw_destroy,
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index b665aee..03b6e20 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -53,7 +53,7 @@ struct route4_filter {
 	int			iif;
 
 	struct tcf_result	res;
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	u32			handle;
 	struct route4_bucket	*bkt;
 	struct tcf_proto	*tp;
@@ -113,8 +113,8 @@ static inline int route4_hash_wild(void)
 #define ROUTE4_APPLY_RESULT()					\
 {								\
 	*res = f->res;						\
-	if (tcf_exts_is_available(&f->exts)) {			\
-		int r = tcf_exts_exec(skb, &f->exts, res);	\
+	if (tcf_act_is_available(&f->actions)) {		\
+		int r = tcf_act_exec(skb, &f->actions, res);	\
 		if (r < 0) {					\
 			dont_cache = 1;				\
 			continue;				\
@@ -272,7 +272,7 @@ route4_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(&f->exts);
+	tcf_act_destroy(&f->actions);
 	kfree(f);
 }
 
@@ -377,10 +377,9 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 	struct route4_filter *fp;
 	unsigned int h1;
 	struct route4_bucket *b;
-	struct tcf_exts e;
+	struct list_head actions;
 
-	tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_act_validate(net, tp, tb, est, &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -452,11 +451,11 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_act_change(tp, &f->actions, &actions);
 
 	return 0;
 errout:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -499,7 +498,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (!f)
 		goto errout;
 
-	tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
+	INIT_LIST_HEAD(&f->actions);
 	if (fold) {
 		f->id = fold->id;
 		f->iif = fold->iif;
@@ -625,12 +624,12 @@ static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_ROUTE4_CLASSID, f->res.classid))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts) < 0)
+	if (tcf_act_dump(skb, tp, &f->actions) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_act_dump_stats(skb, &f->actions) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
@@ -642,6 +641,8 @@ static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.kind		=	"route",
+	.action		=	TCA_ROUTE4_ACT,
+	.police		=	TCA_ROUTE4_POLICE,
 	.classify	=	route4_classify,
 	.init		=	route4_init,
 	.destroy	=	route4_destroy,
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 6bb55f2..64e5b31 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -93,7 +93,7 @@ struct rsvp_filter {
 	u8				tunnelhdr;
 
 	struct tcf_result		res;
-	struct tcf_exts			exts;
+	struct list_head		actions;
 
 	u32				handle;
 	struct rsvp_session		*sess;
@@ -121,7 +121,7 @@ static inline unsigned int hash_src(__be32 *src)
 
 #define RSVP_APPLY_RESULT()				\
 {							\
-	int r = tcf_exts_exec(skb, &f->exts, res);	\
+	int r = tcf_act_exec(skb, &f->actions, res);	\
 	if (r < 0)					\
 		continue;				\
 	else if (r > 0)					\
@@ -291,7 +291,7 @@ static void
 rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(&f->exts);
+	tcf_act_destroy(&f->actions);
 	kfree_rcu(f, rcu);
 }
 
@@ -461,7 +461,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	struct tc_rsvp_pinfo *pinfo = NULL;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_RSVP_MAX + 1];
-	struct tcf_exts e;
+	struct list_head actions;
 	unsigned int h1, h2;
 	__be32 *dst;
 	int err;
@@ -473,8 +473,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
+	err = tcf_act_validate(net, tp, tb, tca[TCA_RATE], &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -492,14 +491,14 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			goto errout2;
 		}
 
-		tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+		INIT_LIST_HEAD(&n->actions);
 
 		if (tb[TCA_RSVP_CLASSID]) {
 			n->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID]);
 			tcf_bind_filter(tp, &n->res, base);
 		}
 
-		tcf_exts_change(tp, &n->exts, &e);
+		tcf_act_change(tp, &n->actions, &actions);
 		rsvp_replace(tp, n, handle);
 		return 0;
 	}
@@ -516,7 +515,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout2;
 
-	tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+	INIT_LIST_HEAD(&f->actions);
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
@@ -570,7 +569,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			if (f->tunnelhdr == 0)
 				tcf_bind_filter(tp, &f->res, base);
 
-			tcf_exts_change(tp, &f->exts, &e);
+			tcf_act_change(tp, &f->actions, &actions);
 
 			fp = &s->ht[h2];
 			for (nfp = rtnl_dereference(*fp); nfp;
@@ -615,7 +614,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 errout:
 	kfree(f);
 errout2:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -688,12 +687,12 @@ static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put(skb, TCA_RSVP_SRC, sizeof(f->src), f->src))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts) < 0)
+	if (tcf_act_dump(skb, tp, &f->actions) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
+	if (tcf_act_dump_stats(skb, &f->actions) < 0)
 		goto nla_put_failure;
 	return skb->len;
 
@@ -704,6 +703,8 @@ static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.kind		=	RSVP_ID,
+	.action		=	TCA_RSVP_ACT,
+	.police		=	TCA_RSVP_POLICE,
 	.classify	=	rsvp_classify,
 	.init		=	rsvp_init,
 	.destroy	=	rsvp_destroy,
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 30f10fb..c584195 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -25,7 +25,7 @@
 
 
 struct tcindex_filter_result {
-	struct tcf_exts		exts;
+	struct list_head	actions;
 	struct tcf_result	res;
 };
 
@@ -52,7 +52,7 @@ struct tcindex_data {
 static inline int
 tcindex_filter_is_set(struct tcindex_filter_result *r)
 {
-	return tcf_exts_is_predicative(&r->exts) || r->res.classid;
+	return tcf_act_is_predicative(&r->actions) || r->res.classid;
 }
 
 static struct tcindex_filter_result *
@@ -100,7 +100,7 @@ static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	*res = f->res;
 	pr_debug("map 0x%x\n", res->classid);
 
-	return tcf_exts_exec(skb, &f->exts, res);
+	return tcf_act_exec(skb, &f->actions, res);
 }
 
 
@@ -169,7 +169,7 @@ tcindex_delete(struct tcf_proto *tp, unsigned long arg)
 		rcu_assign_pointer(*walk, rtnl_dereference(f->next));
 	}
 	tcf_unbind_filter(tp, &r->res);
-	tcf_exts_destroy(&r->exts);
+	tcf_act_destroy(&r->actions);
 	if (f)
 		kfree_rcu(f, rcu);
 	return 0;
@@ -208,7 +208,7 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 static void tcindex_filter_result_init(struct tcindex_filter_result *r)
 {
 	memset(r, 0, sizeof(*r));
-	tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+	INIT_LIST_HEAD(&r->actions);
 }
 
 static void __tcindex_partial_destroy(struct rcu_head *head)
@@ -230,10 +230,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	struct tcindex_filter_result cr;
 	struct tcindex_data *cp, *oldp;
 	struct tcindex_filter *f = NULL; /* make gcc behave */
-	struct tcf_exts e;
+	struct list_head actions;
 
-	tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_act_validate(net, tp, tb, est, &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -261,8 +260,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		if (!cp->perfect)
 			goto errout;
 		for (i = 0; i < cp->hash; i++)
-			tcf_exts_init(&cp->perfect[i].exts,
-				      TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+			INIT_LIST_HEAD(&cp->perfect[i].actions);
 		balloc = 1;
 	}
 	cp->h = p->h;
@@ -330,9 +328,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 			if (!cp->perfect)
 				goto errout_alloc;
 			for (i = 0; i < cp->hash; i++)
-				tcf_exts_init(&cp->perfect[i].exts,
-					      TCA_TCINDEX_ACT,
-					      TCA_TCINDEX_POLICE);
+				INIT_LIST_HEAD(&cp->perfect[i].actions);
 			balloc = 1;
 		} else {
 			struct tcindex_filter __rcu **hash;
@@ -369,9 +365,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 
 	if (old_r)
-		tcf_exts_change(tp, &r->exts, &e);
+		tcf_act_change(tp, &r->actions, &actions);
 	else
-		tcf_exts_change(tp, &cr.exts, &e);
+		tcf_act_change(tp, &cr.actions, &actions);
 
 	if (old_r && old_r != r)
 		tcindex_filter_result_init(old_r);
@@ -384,7 +380,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		struct tcindex_filter *nfp;
 		struct tcindex_filter __rcu **fp;
 
-		tcf_exts_change(tp, &f->result.exts, &r->exts);
+		tcf_act_change(tp, &f->result.actions, &r->actions);
 
 		fp = cp->h + (handle % cp->hash);
 		for (nfp = rtnl_dereference(*fp);
@@ -406,7 +402,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		kfree(cp->h);
 errout:
 	kfree(cp);
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -539,11 +535,11 @@ static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		    nla_put_u32(skb, TCA_TCINDEX_CLASSID, r->res.classid))
 			goto nla_put_failure;
 
-		if (tcf_exts_dump(skb, &r->exts) < 0)
+		if (tcf_act_dump(skb, tp, &r->actions) < 0)
 			goto nla_put_failure;
 		nla_nest_end(skb, nest);
 
-		if (tcf_exts_dump_stats(skb, &r->exts) < 0)
+		if (tcf_act_dump_stats(skb, &r->actions) < 0)
 			goto nla_put_failure;
 	}
 
@@ -556,6 +552,8 @@ static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.kind		=	"tcindex",
+	.action		=	TCA_TCINDEX_ACT,
+	.police		=	TCA_TCINDEX_POLICE,
 	.classify	=	tcindex_classify,
 	.init		=	tcindex_init,
 	.destroy	=	tcindex_destroy,
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 0472909..973e7f3 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -48,7 +48,7 @@ struct tc_u_knode {
 	struct tc_u_knode __rcu	*next;
 	u32			handle;
 	struct tc_u_hnode __rcu	*ht_up;
-	struct tcf_exts		exts;
+	struct list_head	actions;
 #ifdef CONFIG_NET_CLS_IND
 	int			ifindex;
 #endif
@@ -173,7 +173,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 #ifdef CONFIG_CLS_U32_PERF
 				__this_cpu_inc(n->pf->rhit);
 #endif
-				r = tcf_exts_exec(skb, &n->exts, res);
+				r = tcf_act_exec(skb, &n->actions, res);
 				if (r < 0) {
 					n = rcu_dereference_bh(n->next);
 					goto next_knode;
@@ -358,7 +358,7 @@ static int u32_destroy_key(struct tcf_proto *tp,
 			   struct tc_u_knode *n,
 			   bool free_pf)
 {
-	tcf_exts_destroy(&n->exts);
+	tcf_act_destroy(&n->actions);
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
@@ -560,10 +560,9 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 			 struct nlattr *est, bool ovr)
 {
 	int err;
-	struct tcf_exts e;
+	struct list_head actions;
 
-	tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_act_validate(net, tp, tb, est, &actions, ovr);
 	if (err < 0)
 		return err;
 
@@ -603,11 +602,11 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 		n->ifindex = ret;
 	}
 #endif
-	tcf_exts_change(tp, &n->exts, &e);
+	tcf_act_change(tp, &n->actions, &actions);
 
 	return 0;
 errout:
-	tcf_exts_destroy(&e);
+	tcf_act_destroy(&actions);
 	return err;
 }
 
@@ -681,8 +680,7 @@ static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
 #endif
 	new->tp = tp;
 	memcpy(&new->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
-
-	tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	INIT_LIST_HEAD(&new->actions);
 
 	return new;
 }
@@ -810,7 +808,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	RCU_INIT_POINTER(n->ht_up, ht);
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
-	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	INIT_LIST_HEAD(&n->actions);
 	n->tp = tp;
 
 #ifdef CONFIG_CLS_U32_MARK
@@ -965,7 +963,7 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		}
 #endif
 
-		if (tcf_exts_dump(skb, &n->exts) < 0)
+		if (tcf_act_dump(skb, tp, &n->actions) < 0)
 			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
@@ -1006,7 +1004,7 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	nla_nest_end(skb, nest);
 
 	if (TC_U32_KEY(n->handle))
-		if (tcf_exts_dump_stats(skb, &n->exts) < 0)
+		if (tcf_act_dump_stats(skb, &n->actions) < 0)
 			goto nla_put_failure;
 	return skb->len;
 
@@ -1017,6 +1015,8 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.kind		=	"u32",
+	.action		=	TCA_U32_ACT,
+	.police		=	TCA_U32_POLICE,
 	.classify	=	u32_classify,
 	.init		=	u32_init,
 	.destroy	=	u32_destroy,
-- 
1.8.3.1
