From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 5/5] net_sched: convert tcf_exts from list to flex_array
Date: Mon,  8 Aug 2016 13:46:49 -0700
Message-ID: <1470689209-17682-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34317 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbcHHUrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:47:03 -0400
Received: by mail-pa0-f67.google.com with SMTP id hh10so24606061pac.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 13:47:03 -0700 (PDT)
In-Reply-To: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out by Jamal, an action could be shared by
multiple filters, so we can't use list to chain them
any more after we get rid of the original tc_action.
Instead, we could just save pointers to these actions
in tcf_exts, since they are refcount'ed, so convert
the list to a flex array.

The ugly part is the action API still accepts list
as a parameter, I just introduce a helper function to
convert the flex array of pointers to a list.

Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  |  4 +-
 include/net/pkt_cls.h                           | 44 +++++++++++++------
 net/sched/cls_api.c                             | 57 ++++++++++++++++++-------
 5 files changed, 87 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5418c69a..6ac1254 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8390,12 +8390,14 @@ static int parse_tc_actions(struct ixgbe_adapter *adapter,
 			    struct tcf_exts *exts, u64 *action, u8 *queue)
 {
 	const struct tc_action *a;
+	LIST_HEAD(actions);
 	int err;
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
 
-	tc_for_each_action(a, exts) {
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
 
 		/* Drop action */
 		if (is_tcf_gact_shot(a)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 0f19b01..dc8b1cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -318,6 +318,7 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				u32 *action, u32 *flow_tag)
 {
 	const struct tc_action *a;
+	LIST_HEAD(actions);
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
@@ -325,7 +326,8 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	*flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
 	*action = 0;
 
-	tc_for_each_action(a, exts) {
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
 		/* Only support a single action per rule */
 		if (*action)
 			return -EINVAL;
@@ -362,13 +364,15 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				u32 *action, u32 *dest_vport)
 {
 	const struct tc_action *a;
+	LIST_HEAD(actions);
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
 
 	*action = 0;
 
-	tc_for_each_action(a, exts) {
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
 		/* Only support a single action per rule */
 		if (*action)
 			return -EINVAL;
@@ -503,6 +507,7 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 	struct mlx5e_tc_flow *flow;
 	struct tc_action *a;
 	struct mlx5_fc *counter;
+	LIST_HEAD(actions);
 	u64 bytes;
 	u64 packets;
 	u64 lastuse;
@@ -518,7 +523,8 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 
 	mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
 
-	tc_for_each_action(a, f->exts)
+	tcf_exts_to_list(f->exts, &actions);
+	list_for_each_entry(a, &actions, list)
 		tcf_action_stats_update(a, bytes, packets, lastuse);
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c3e6150..df85acd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1149,6 +1149,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  bool ingress)
 {
 	const struct tc_action *a;
+	LIST_HEAD(actions);
 	int err;
 
 	if (!tc_single_action(cls->exts)) {
@@ -1156,7 +1157,8 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -ENOTSUPP;
 	}
 
-	tc_for_each_action(a, cls->exts) {
+	tcf_exts_to_list(cls->exts, &actions);
+	list_for_each_entry(a, &actions, list) {
 		if (!is_tcf_mirred_mirror(a) || protocol != htons(ETH_P_ALL))
 			return -ENOTSUPP;
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f15aa1e..2b6f0ec 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -1,6 +1,7 @@
 #ifndef __NET_PKT_CLS_H
 #define __NET_PKT_CLS_H
 
+#include <linux/flex_array.h>
 #include <linux/pkt_cls.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
@@ -59,7 +60,8 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
 	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
-	struct list_head actions;
+	int nr_actions;
+	struct flex_array *actions;
 #endif
 	/* Map to export classifier specific extension TLV types to the
 	 * generic extensions API. Unsupported extensions must be set to 0.
@@ -72,7 +74,10 @@ static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	exts->type = 0;
-	INIT_LIST_HEAD(&exts->actions);
+	exts->nr_actions = 0;
+	exts->actions = flex_array_alloc(sizeof(struct tc_action *),
+					 TCA_ACT_MAX_PRIO, GFP_KERNEL);
+	WARN_ON(!exts->actions); /* TODO: propagate the error to callers */
 #endif
 	exts->action = action;
 	exts->police = police;
@@ -89,7 +94,7 @@ static inline int
 tcf_exts_is_predicative(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return !list_empty(&exts->actions);
+	return exts->nr_actions;
 #else
 	return 0;
 #endif
@@ -108,6 +113,21 @@ tcf_exts_is_available(struct tcf_exts *exts)
 	return tcf_exts_is_predicative(exts);
 }
 
+static inline void
+tcf_exts_to_list(const struct tcf_exts *exts, struct list_head *actions)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	int i;
+
+	for (i = 0; i < exts->nr_actions; i++) {
+		struct tc_action *a;
+
+		a  = *(struct tc_action **)flex_array_get(exts->actions, i);
+		list_add(&a->list, actions);
+	}
+#endif
+}
+
 /**
  * tcf_exts_exec - execute tc filter extensions
  * @skb: socket buffer
@@ -124,27 +144,23 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	       struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	if (!list_empty(&exts->actions))
-		return tcf_action_exec(skb, &exts->actions, res);
+	LIST_HEAD(actions);
+
+	tcf_exts_to_list(exts, &actions);
+	if (exts->nr_actions)
+		return tcf_action_exec(skb, &actions, res);
 #endif
 	return 0;
 }
 
 #ifdef CONFIG_NET_CLS_ACT
 
-#define tc_no_actions(_exts) \
-	(list_empty(&(_exts)->actions))
-
-#define tc_for_each_action(_a, _exts) \
-	list_for_each_entry(_a, &(_exts)->actions, list)
-
-#define tc_single_action(_exts) \
-	(list_is_singular(&(_exts)->actions))
+#define tc_no_actions(_exts)  (&(_exts)->nr_actions == 0)
+#define tc_single_action(_exts) (&(_exts)->nr_actions == 1)
 
 #else /* CONFIG_NET_CLS_ACT */
 
 #define tc_no_actions(_exts) true
-#define tc_for_each_action(_a, _exts) while ((void)(_a), 0)
 #define tc_single_action(_exts) false
 #define tcf_action_stats_update(a, bytes, packets, lastuse)
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 843a716..e690c3d 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -541,8 +541,12 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 void tcf_exts_destroy(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	tcf_action_destroy(&exts->actions, TCA_ACT_UNBIND);
-	INIT_LIST_HEAD(&exts->actions);
+	LIST_HEAD(actions);
+
+	tcf_exts_to_list(exts, &actions);
+	tcf_action_destroy(&actions, TCA_ACT_UNBIND);
+	flex_array_free(exts->actions);
+	exts->nr_actions = 0;
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
@@ -554,7 +558,6 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 	{
 		struct tc_action *act;
 
-		INIT_LIST_HEAD(&exts->actions);
 		if (exts->police && tb[exts->police]) {
 			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
 						"police", ovr,
@@ -563,14 +566,26 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 				return PTR_ERR(act);
 
 			act->type = exts->type = TCA_OLD_COMPAT;
-			list_add(&act->list, &exts->actions);
+			flex_array_put(exts->actions, 0, &act, GFP_KERNEL);
+			exts->nr_actions = 1;
 		} else if (exts->action && tb[exts->action]) {
-			int err;
+			LIST_HEAD(actions);
+			int err, i = 0;
+
 			err = tcf_action_init(net, tb[exts->action], rate_tlv,
 					      NULL, ovr,
-					      TCA_ACT_BIND, &exts->actions);
+					      TCA_ACT_BIND, &actions);
 			if (err)
 				return err;
+			list_for_each_entry(act, &actions, list) {
+				err = flex_array_put(exts->actions, i++, &act,
+						     GFP_KERNEL);
+				if (err) {
+					tcf_action_destroy(&actions, TCA_ACT_UNBIND);
+					return err;
+				}
+			}
+			exts->nr_actions = i;
 		}
 	}
 #else
@@ -587,37 +602,49 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	LIST_HEAD(tmp);
+	struct tcf_exts old = *dst;
+
 	tcf_tree_lock(tp);
-	list_splice_init(&dst->actions, &tmp);
-	list_splice(&src->actions, &dst->actions);
+	dst->nr_actions = src->nr_actions;
+	dst->actions = src->actions;
 	dst->type = src->type;
 	tcf_tree_unlock(tp);
-	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
+
+	tcf_exts_destroy(&old);
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_change);
 
-#define tcf_exts_first_act(ext)					\
-	list_first_entry_or_null(&(exts)->actions,		\
-				 struct tc_action, list)
+#ifdef CONFIG_NET_CLS_ACT
+static struct tc_action *tcf_exts_first_act(struct tcf_exts *exts)
+{
+	if (exts->nr_actions == 0)
+		return NULL;
+	else
+		return *(struct tc_action **)flex_array_get(exts->actions, 0);
+}
+#endif
 
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct nlattr *nest;
 
-	if (exts->action && !list_empty(&exts->actions)) {
+	if (exts->action && exts->nr_actions) {
 		/*
 		 * again for backward compatible mode - we want
 		 * to work with both old and new modes of entering
 		 * tc data even if iproute2  was newer - jhs
 		 */
 		if (exts->type != TCA_OLD_COMPAT) {
+			LIST_HEAD(actions);
+
 			nest = nla_nest_start(skb, exts->action);
 			if (nest == NULL)
 				goto nla_put_failure;
-			if (tcf_action_dump(skb, &exts->actions, 0, 0) < 0)
+
+			tcf_exts_to_list(exts, &actions);
+			if (tcf_action_dump(skb, &actions, 0, 0) < 0)
 				goto nla_put_failure;
 			nla_nest_end(skb, nest);
 		} else if (exts->police) {
-- 
2.1.0
