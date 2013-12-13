From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next v2 4/6] net_sched: cls: refactor out struct tcf_ext_map
Date: Thu, 12 Dec 2013 20:56:42 -0800
Message-ID: <1386910604-1870-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:59152 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab3LME5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 23:57:06 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so1778427pdj.37
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 20:57:06 -0800 (PST)
In-Reply-To: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These information can be saved in tcf_exts, and this will
simplify the code.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h   | 34 ++++++++++++++++------------------
 net/sched/cls_api.c     | 32 +++++++++++++-------------------
 net/sched/cls_basic.c   | 14 +++++---------
 net/sched/cls_bpf.c     | 14 +++++---------
 net/sched/cls_cgroup.c  | 15 +++++----------
 net/sched/cls_flow.c    | 14 +++++---------
 net/sched/cls_fw.c      | 14 +++++---------
 net/sched/cls_route.c   | 14 +++++---------
 net/sched/cls_rsvp.h    | 14 +++++---------
 net/sched/cls_tcindex.c | 16 ++++++----------
 net/sched/cls_u32.c     | 14 +++++---------
 11 files changed, 75 insertions(+), 120 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index a85264b..367f9d3 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -65,16 +65,23 @@ struct tcf_exts {
 	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
 	struct list_head head;
 #endif
-};
-
-/* Map to export classifier specific extension TLV types to the
- * generic extensions API. Unsupported extensions must be set to 0.
- */
-struct tcf_ext_map {
+	/* Map to export classifier specific extension TLV types to the
+	 * generic extensions API. Unsupported extensions must be set to 0.
+	 */
 	int action;
 	int police;
 };
 
+static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	exts->type = 0;
+	INIT_LIST_HEAD(&exts->head);
+#endif
+	exts->action = action;
+	exts->police = police;
+}
+
 /**
  * tcf_exts_is_predicative - check if a predicative extension is present
  * @exts: tc filter extensions handle
@@ -92,12 +99,6 @@ tcf_exts_is_predicative(struct tcf_exts *exts)
 #endif
 }
 
-static inline void tcf_exts_init(struct tcf_exts *exts)
-{
-#ifdef CONFIG_NET_CLS_ACT
-	INIT_LIST_HEAD(&exts->head);
-#endif
-}
 /**
  * tcf_exts_is_available - check if at least one extension is present
  * @exts: tc filter extensions handle
@@ -135,15 +136,12 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
-		      struct tcf_exts *exts,
-		      const struct tcf_ext_map *map);
+		      struct tcf_exts *exts);
 void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
 void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src);
-int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
-		  const struct tcf_ext_map *map);
-int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-			const struct tcf_ext_map *map);
+int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
+int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
 
 /**
  * struct tcf_pkt_info - packet information
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 7e5f296..e673bb1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -507,18 +507,14 @@ void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
 EXPORT_SYMBOL(tcf_exts_destroy);
 
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
-		  struct nlattr *rate_tlv, struct tcf_exts *exts,
-		  const struct tcf_ext_map *map)
+		  struct nlattr *rate_tlv, struct tcf_exts *exts)
 {
-	memset(exts, 0, sizeof(*exts));
-
 #ifdef CONFIG_NET_CLS_ACT
 	{
 		struct tc_action *act;
 
-		INIT_LIST_HEAD(&exts->head);
-		if (map->police && tb[map->police]) {
-			act = tcf_action_init_1(net, tb[map->police], rate_tlv,
+		if (exts->police && tb[exts->police]) {
+			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
 						"police", TCA_ACT_NOREPLACE,
 						TCA_ACT_BIND);
 			if (IS_ERR(act))
@@ -526,9 +522,9 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 
 			act->type = exts->type = TCA_OLD_COMPAT;
 			list_add(&act->list, &exts->head);
-		} else if (map->action && tb[map->action]) {
+		} else if (exts->action && tb[exts->action]) {
 			int err;
-			err = tcf_action_init(net, tb[map->action], rate_tlv,
+			err = tcf_action_init(net, tb[exts->action], rate_tlv,
 					      NULL, TCA_ACT_NOREPLACE,
 					      TCA_ACT_BIND, &exts->head);
 			if (err)
@@ -536,8 +532,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 		}
 	}
 #else
-	if ((map->action && tb[map->action]) ||
-	    (map->police && tb[map->police]))
+	if ((exts->action && tb[exts->action]) ||
+	    (exts->police && tb[exts->police]))
 		return -EOPNOTSUPP;
 #endif
 
@@ -564,11 +560,10 @@ EXPORT_SYMBOL(tcf_exts_change);
 #define tcf_exts_first_act(ext) \
 		list_first_entry(&(exts)->head, struct tc_action, list)
 
-int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
-		  const struct tcf_ext_map *map)
+int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (map->action && !list_empty(&exts->head)) {
+	if (exts->action && !list_empty(&exts->head)) {
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
@@ -576,15 +571,15 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
 		 */
 		struct nlattr *nest;
 		if (exts->type != TCA_OLD_COMPAT) {
-			nest = nla_nest_start(skb, map->action);
+			nest = nla_nest_start(skb, exts->action);
 			if (nest == NULL)
 				goto nla_put_failure;
 			if (tcf_action_dump(skb, &exts->head, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
-		} else if (map->police) {
+		} else if (exts->police) {
 			struct tc_action *act = tcf_exts_first_act(exts);
-			nest = nla_nest_start(skb, map->police);
+			nest = nla_nest_start(skb, exts->police);
 			if (nest == NULL)
 				goto nla_put_failure;
 			if (tcf_action_dump_old(skb, act, 0, 0) < 0)
@@ -600,8 +595,7 @@ nla_put_failure: __attribute__ ((unused))
 EXPORT_SYMBOL(tcf_exts_dump);
 
 
-int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-			const struct tcf_ext_map *map)
+int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tc_action *a = tcf_exts_first_act(exts);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 7b9b460..b655203 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -34,11 +34,6 @@ struct basic_filter {
 	struct list_head	link;
 };
 
-static const struct tcf_ext_map basic_ext_map = {
-	.action = TCA_BASIC_ACT,
-	.police = TCA_BASIC_POLICE
-};
-
 static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			  struct tcf_result *res)
 {
@@ -141,7 +136,8 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 
-	err = tcf_exts_validate(net, tp, tb, est, &e, &basic_ext_map);
+	tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &e);
 	if (err < 0)
 		return err;
 
@@ -191,7 +187,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout;
 
-	tcf_exts_init(&f->exts);
+	tcf_exts_init(&f->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	err = -EINVAL;
 	if (handle)
 		f->handle = handle;
@@ -264,13 +260,13 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_BASIC_CLASSID, f->res.classid))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
+	if (tcf_exts_dump(skb, &f->exts) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &basic_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 90fe275..00a5a58 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -46,11 +46,6 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
 };
 
-static const struct tcf_ext_map bpf_ext_map = {
-	.action = TCA_BPF_ACT,
-	.police = TCA_BPF_POLICE,
-};
-
 static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
@@ -174,7 +169,8 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if (!tb[TCA_BPF_OPS_LEN] || !tb[TCA_BPF_OPS] || !tb[TCA_BPF_CLASSID])
 		return -EINVAL;
 
-	ret = tcf_exts_validate(net, tp, tb, est, &exts, &bpf_ext_map);
+	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+	ret = tcf_exts_validate(net, tp, tb, est, &exts);
 	if (ret < 0)
 		return ret;
 
@@ -271,7 +267,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (prog == NULL)
 		return -ENOBUFS;
 
-	tcf_exts_init(&prog->exts);
+	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
 	if (handle == 0)
 		prog->handle = cls_bpf_grab_new_handle(tp, head);
 	else
@@ -326,12 +322,12 @@ static int cls_bpf_dump(struct tcf_proto *tp, unsigned long fh,
 
 	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
 
-	if (tcf_exts_dump(skb, &prog->exts, &bpf_ext_map) < 0)
+	if (tcf_exts_dump(skb, &prog->exts) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &prog->exts, &bpf_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &prog->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index e4fae03..f9d21258 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -172,11 +172,6 @@ static int cls_cgroup_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static const struct tcf_ext_map cgroup_ext_map = {
-	.action = TCA_CGROUP_ACT,
-	.police = TCA_CGROUP_POLICE,
-};
-
 static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
 	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
 };
@@ -203,7 +198,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		if (head == NULL)
 			return -ENOBUFS;
 
-		tcf_exts_init(&head->exts);
+		tcf_exts_init(&head->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 		head->handle = handle;
 
 		tcf_tree_lock(tp);
@@ -219,8 +214,8 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e,
-				&cgroup_ext_map);
+	tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e);
 	if (err < 0)
 		return err;
 
@@ -278,13 +273,13 @@ static int cls_cgroup_dump(struct tcf_proto *tp, unsigned long fh,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &head->exts, &cgroup_ext_map) < 0 ||
+	if (tcf_exts_dump(skb, &head->exts) < 0 ||
 	    tcf_em_tree_dump(skb, &head->ematches, TCA_CGROUP_EMATCHES) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &head->exts, &cgroup_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &head->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 411e0d8..f9c8b05 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -56,11 +56,6 @@ struct flow_filter {
 	u32			hashrnd;
 };
 
-static const struct tcf_ext_map flow_ext_map = {
-	.action	= TCA_FLOW_ACT,
-	.police	= TCA_FLOW_POLICE,
-};
-
 static inline u32 addr_fold(void *addr)
 {
 	unsigned long a = (unsigned long)addr;
@@ -397,7 +392,8 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
+	tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e);
 	if (err < 0)
 		return err;
 
@@ -455,7 +451,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 
 		f->handle = handle;
 		f->mask	  = ~0U;
-		tcf_exts_init(&f->exts);
+		tcf_exts_init(&f->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 
 		get_random_bytes(&f->hashrnd, 4);
 		f->perturb_timer.function = flow_perturbation;
@@ -609,7 +605,7 @@ static int flow_dump(struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_FLOW_PERTURB, f->perturb_period / HZ))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts, &flow_ext_map) < 0)
+	if (tcf_exts_dump(skb, &f->exts) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_NET_EMATCH
 	if (f->ematches.hdr.nmatches &&
@@ -618,7 +614,7 @@ static int flow_dump(struct tcf_proto *tp, unsigned long fh,
 #endif
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &flow_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index d1cebad..3f9cece 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -46,11 +46,6 @@ struct fw_filter {
 	struct tcf_exts		exts;
 };
 
-static const struct tcf_ext_map fw_ext_map = {
-	.action = TCA_FW_ACT,
-	.police = TCA_FW_POLICE
-};
-
 static inline int fw_hash(u32 handle)
 {
 	if (HTSIZE == 4096)
@@ -200,7 +195,8 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	u32 mask;
 	int err;
 
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &fw_ext_map);
+	tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e);
 	if (err < 0)
 		return err;
 
@@ -280,7 +276,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		return -ENOBUFS;
 
-	tcf_exts_init(&f->exts);
+	tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
 	f->id = handle;
 
 	err = fw_change_attrs(net, tp, f, tb, tca, base);
@@ -360,12 +356,12 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_FW_MASK, head->mask))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
+	if (tcf_exts_dump(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index f1f1dfd..2473953 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -59,11 +59,6 @@ struct route4_filter {
 
 #define ROUTE4_FAILURE ((struct route4_filter *)(-1L))
 
-static const struct tcf_ext_map route_ext_map = {
-	.police = TCA_ROUTE4_POLICE,
-	.action = TCA_ROUTE4_ACT
-};
-
 static inline int route4_fastmap_hash(u32 id, int iif)
 {
 	return id & 0xF;
@@ -347,7 +342,8 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 	struct route4_bucket *b;
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(net, tp, tb, est, &e, &route_ext_map);
+	tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &e);
 	if (err < 0)
 		return err;
 
@@ -481,7 +477,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout;
 
-	tcf_exts_init(&f->exts);
+	tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
 	err = route4_set_parms(net, tp, base, f, handle, head, tb,
 		tca[TCA_RATE], 1);
 	if (err < 0)
@@ -590,12 +586,12 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_ROUTE4_CLASSID, f->res.classid))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
+	if (tcf_exts_dump(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	return skb->len;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b1d3ce5..4f25c2a 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -116,11 +116,6 @@ static inline unsigned int hash_src(__be32 *src)
 	return h & 0xF;
 }
 
-static struct tcf_ext_map rsvp_ext_map = {
-	.police = TCA_RSVP_POLICE,
-	.action = TCA_RSVP_ACT
-};
-
 #define RSVP_APPLY_RESULT()				\
 {							\
 	int r = tcf_exts_exec(skb, &f->exts, res);	\
@@ -440,7 +435,8 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, &rsvp_ext_map);
+	tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e);
 	if (err < 0)
 		return err;
 
@@ -471,7 +467,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout2;
 
-	tcf_exts_init(&f->exts);
+	tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
@@ -634,12 +630,12 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	    nla_put(skb, TCA_RSVP_SRC, sizeof(f->src), f->src))
 		goto nla_put_failure;
 
-	if (tcf_exts_dump(skb, &f->exts, &rsvp_ext_map) < 0)
+	if (tcf_exts_dump(skb, &f->exts) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &rsvp_ext_map) < 0)
+	if (tcf_exts_dump_stats(skb, &f->exts) < 0)
 		goto nla_put_failure;
 	return skb->len;
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index c39bbfc..ffad187 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -50,11 +50,6 @@ struct tcindex_data {
 	int fall_through;	/* 0: only classify if explicit match */
 };
 
-static const struct tcf_ext_map tcindex_ext_map = {
-	.police = TCA_TCINDEX_POLICE,
-	.action = TCA_TCINDEX_ACT
-};
-
 static inline int
 tcindex_filter_is_set(struct tcindex_filter_result *r)
 {
@@ -209,19 +204,20 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	struct tcindex_filter *f = NULL; /* make gcc behave */
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(net, tp, tb, est, &e, &tcindex_ext_map);
+	tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &e);
 	if (err < 0)
 		return err;
 
 	memcpy(&cp, p, sizeof(cp));
 	memset(&new_filter_result, 0, sizeof(new_filter_result));
-	tcf_exts_init(&new_filter_result.exts);
+	tcf_exts_init(&new_filter_result.exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 
 	if (old_r)
 		memcpy(&cr, r, sizeof(cr));
 	else {
 		memset(&cr, 0, sizeof(cr));
-		tcf_exts_init(&cr.exts);
+		tcf_exts_init(&cr.exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 	}
 
 	if (tb[TCA_TCINDEX_HASH])
@@ -471,11 +467,11 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 		    nla_put_u32(skb, TCA_TCINDEX_CLASSID, r->res.classid))
 			goto nla_put_failure;
 
-		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
+		if (tcf_exts_dump(skb, &r->exts) < 0)
 			goto nla_put_failure;
 		nla_nest_end(skb, nest);
 
-		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
+		if (tcf_exts_dump_stats(skb, &r->exts) < 0)
 			goto nla_put_failure;
 	}
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 492d9a6..20f2fb7 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -79,11 +79,6 @@ struct tc_u_common {
 	u32			hgenerator;
 };
 
-static const struct tcf_ext_map u32_ext_map = {
-	.action = TCA_U32_ACT,
-	.police = TCA_U32_POLICE
-};
-
 static inline unsigned int u32_hash_fold(__be32 key,
 					 const struct tc_u32_sel *sel,
 					 u8 fshift)
@@ -496,7 +491,8 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 	int err;
 	struct tcf_exts e;
 
-	err = tcf_exts_validate(net, tp, tb, est, &e, &u32_ext_map);
+	tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &e);
 	if (err < 0)
 		return err;
 
@@ -646,7 +642,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->ht_up = ht;
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
-	tcf_exts_init(&n->exts);
+	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
 
 #ifdef CONFIG_CLS_U32_MARK
 	if (tb[TCA_U32_MARK]) {
@@ -760,7 +756,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 #endif
 
-		if (tcf_exts_dump(skb, &n->exts, &u32_ext_map) < 0)
+		if (tcf_exts_dump(skb, &n->exts) < 0)
 			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
@@ -779,7 +775,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 	nla_nest_end(skb, nest);
 
 	if (TC_U32_KEY(n->handle))
-		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
+		if (tcf_exts_dump_stats(skb, &n->exts) < 0)
 			goto nla_put_failure;
 	return skb->len;
 
-- 
1.8.1.4
