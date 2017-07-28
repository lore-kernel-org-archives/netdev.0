From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/20] net: sched: convert actions array into rcu list
Date: Fri, 28 Jul 2017 16:40:31 +0200
Message-ID: <20170728144042.6380-10-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34209 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdG1OlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:17 -0400
Received: by mail-wr0-f196.google.com with SMTP id o33so19221352wrb.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:16 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently the actions are stored in array with array size. To traverse
this array in fastpath, tcf_tree_lock is taken to protect it. Convert
the array into a singly linked list, similar to the filter chains style
and allow traversal protected by rcu.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/act_api.h    | 11 +++++++---
 include/net/pkt_cls.h    | 46 ++++++++++++++++++-----------------------
 net/sched/act_api.c      | 16 ++++++++-------
 net/sched/cls_api.c      | 31 ++++++++++++----------------
 net/sched/cls_basic.c    | 10 +++------
 net/sched/cls_bpf.c      | 10 +++------
 net/sched/cls_cgroup.c   | 10 +++------
 net/sched/cls_flow.c     | 10 +++------
 net/sched/cls_flower.c   | 10 +++------
 net/sched/cls_fw.c       | 16 ++++-----------
 net/sched/cls_matchall.c | 11 +++-------
 net/sched/cls_route.c    | 10 +++------
 net/sched/cls_rsvp.h     | 18 +++++-----------
 net/sched/cls_tcindex.c  | 53 ++++++++++++++----------------------------------
 net/sched/cls_u32.c      | 15 ++++----------
 15 files changed, 99 insertions(+), 178 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 26ffd83..74e2657 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -21,6 +21,8 @@ struct tcf_hashinfo {
 struct tc_action_ops;
 
 struct tc_action {
+	/* Fast access part */
+	struct tc_action __rcu		*next;
 	const struct tc_action_ops	*ops;
 	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
 	__u32				order;
@@ -179,15 +181,18 @@ int tcf_register_action(struct tc_action_ops *a, struct pernet_operations *ops);
 int tcf_unregister_action(struct tc_action_ops *a,
 			  struct pernet_operations *ops);
 int tcf_action_destroy(struct list_head *actions, int bind);
-int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
-		    int nr_actions, struct tcf_result *res);
+
+struct tcf_exts;
+
+int tcf_action_exec(struct sk_buff *skb, struct tcf_exts *exts,
+		    struct tcf_result *res);
 int tcf_action_init(struct net *net, struct tcf_proto *tp, struct nlattr *nla,
 		    struct nlattr *est, char *name, int ovr, int bind,
 		    struct list_head *actions);
 struct tc_action *tcf_action_init_1(struct net *net, struct tcf_proto *tp,
 				    struct nlattr *nla, struct nlattr *est,
 				    char *name, int ovr, int bind);
-int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
+int tcf_action_dump(struct sk_buff *skb, struct list_head *actions, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index b8959c9..8257a4e 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -88,8 +88,7 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
 struct tcf_exts {
 #ifdef CONFIG_NET_CLS_ACT
 	__u32	type; /* for backward compat(TCA_OLD_COMPAT) */
-	int nr_actions;
-	struct tc_action **actions;
+	struct tc_action __rcu *action_list;
 #endif
 	/* Map to export classifier specific extension TLV types to the
 	 * generic extensions API. Unsupported extensions must be set to 0.
@@ -98,32 +97,32 @@ struct tcf_exts {
 	int police;
 };
 
-static inline int tcf_exts_init(struct tcf_exts *exts, int action, int police)
+#define tcf_exts_for_each(a, exts)				\
+	for (a = rtnl_dereference(exts->action_list);		\
+	     a; a = rtnl_dereference(a->next))
+
+#define tcf_exts_for_each_rcu_bh(a, exts)			\
+	for (a = rcu_dereference_bh(exts->action_list);		\
+	     a; a = rcu_dereference_bh(a->next))
+
+static inline void tcf_exts_init(struct tcf_exts *exts, int action, int police)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	exts->type = 0;
-	exts->nr_actions = 0;
-	exts->actions = kcalloc(TCA_ACT_MAX_PRIO, sizeof(struct tc_action *),
-				GFP_KERNEL);
-	if (!exts->actions)
-		return -ENOMEM;
+	RCU_INIT_POINTER(exts->action_list, NULL);
 #endif
 	exts->action = action;
 	exts->police = police;
-	return 0;
 }
 
 static inline void tcf_exts_to_list(const struct tcf_exts *exts,
 				    struct list_head *actions)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	int i;
-
-	for (i = 0; i < exts->nr_actions; i++) {
-		struct tc_action *a = exts->actions[i];
+	struct tc_action *a;
 
+	tcf_exts_for_each(a, exts)
 		list_add_tail(&a->list, actions);
-	}
 #endif
 }
 
@@ -132,16 +131,11 @@ tcf_exts_stats_update(const struct tcf_exts *exts,
 		      u64 bytes, u64 packets, u64 lastuse)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	int i;
+	struct tc_action *a;
 
 	preempt_disable();
-
-	for (i = 0; i < exts->nr_actions; i++) {
-		struct tc_action *a = exts->actions[i];
-
+	tcf_exts_for_each(a, exts)
 		tcf_action_stats_update(a, bytes, packets, lastuse);
-	}
-
 	preempt_enable();
 #endif
 }
@@ -155,7 +149,7 @@ tcf_exts_stats_update(const struct tcf_exts *exts,
 static inline bool tcf_exts_has_actions(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return exts->nr_actions;
+	return rtnl_dereference(exts->action_list);
 #else
 	return false;
 #endif
@@ -170,7 +164,8 @@ static inline bool tcf_exts_has_actions(struct tcf_exts *exts)
 static inline bool tcf_exts_has_one_action(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return exts->nr_actions == 1;
+	return rtnl_dereference(exts->action_list) &&
+	       !rtnl_dereference(exts->action_list->next);
 #else
 	return false;
 #endif
@@ -192,7 +187,7 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	      struct tcf_result *res)
 {
 #ifdef CONFIG_NET_CLS_ACT
-	return tcf_action_exec(skb, exts->actions, exts->nr_actions, res);
+	return tcf_action_exec(skb, exts, res);
 #endif
 	return TC_ACT_OK;
 }
@@ -201,8 +196,7 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
 void tcf_exts_destroy(struct tcf_exts *exts);
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src);
+void tcf_exts_change(struct tcf_exts *dst, struct tcf_exts *src);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8d2e506..177b9ab 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -457,21 +457,19 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 
 /*TCA_ACT_MAX_PRIO is 32, there count upto 32 */
 #define TCA_ACT_MAX_PRIO_MASK 0x1FF
-int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
-		    int nr_actions, struct tcf_result *res)
+int tcf_action_exec(struct sk_buff *skb, struct tcf_exts *exts,
+		    struct tcf_result *res)
 {
 	u32 jmp_prgcnt = 0;
 	u32 jmp_ttl = TCA_ACT_MAX_PRIO; /*matches actions per filter */
-	int i;
+	struct tc_action *a;
 	int ret = TC_ACT_OK;
 
 	if (skb_skip_tc_classify(skb))
 		return TC_ACT_OK;
 
 restart_act_graph:
-	for (i = 0; i < nr_actions; i++) {
-		const struct tc_action *a = actions[i];
-
+	tcf_exts_for_each_rcu_bh(a, exts) {
 		if (jmp_prgcnt > 0) {
 			jmp_prgcnt -= 1;
 			continue;
@@ -483,7 +481,7 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 
 		if (TC_ACT_EXT_CMP(ret, TC_ACT_JUMP)) {
 			jmp_prgcnt = ret & TCA_ACT_MAX_PRIO_MASK;
-			if (!jmp_prgcnt || (jmp_prgcnt > nr_actions)) {
+			if (!jmp_prgcnt) {
 				/* faulty opcode, stop pipeline */
 				return TC_ACT_OK;
 			} else {
@@ -501,6 +499,10 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 			break;
 	}
 
+	if (jmp_prgcnt > 0)
+		/* faulty opcode, stop pipeline */
+		return TC_ACT_OK;
+
 	return ret;
 }
 EXPORT_SYMBOL(tcf_action_exec);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 735d556..129f314 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -836,8 +836,6 @@ void tcf_exts_destroy(struct tcf_exts *exts)
 
 	tcf_exts_to_list(exts, &actions);
 	tcf_action_destroy(&actions, TCA_ACT_UNBIND);
-	kfree(exts->actions);
-	exts->nr_actions = 0;
 #endif
 }
 EXPORT_SYMBOL(tcf_exts_destroy);
@@ -857,20 +855,22 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 				return PTR_ERR(act);
 
 			act->type = exts->type = TCA_OLD_COMPAT;
-			exts->actions[0] = act;
-			exts->nr_actions = 1;
+			exts->action_list = act;
 		} else if (exts->action && tb[exts->action]) {
+			struct tc_action **pprev;
 			LIST_HEAD(actions);
-			int err, i = 0;
+			int err;
 
 			err = tcf_action_init(net, tp, tb[exts->action],
 					      rate_tlv, NULL, ovr, TCA_ACT_BIND,
 					      &actions);
 			if (err)
 				return err;
-			list_for_each_entry(act, &actions, list)
-				exts->actions[i++] = act;
-			exts->nr_actions = i;
+			pprev = &exts->action_list;
+			list_for_each_entry(act, &actions, list) {
+				*pprev = act;
+				pprev = &act->next;
+			}
 		}
 	}
 #else
@@ -883,18 +883,16 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 }
 EXPORT_SYMBOL(tcf_exts_validate);
 
-void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
-		     struct tcf_exts *src)
+void tcf_exts_change(struct tcf_exts *dst, struct tcf_exts *src)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_exts old = *dst;
 
-	tcf_tree_lock(tp);
-	dst->nr_actions = src->nr_actions;
-	dst->actions = src->actions;
+	rcu_assign_pointer(dst->action_list,
+			   rtnl_dereference(src->action_list));
 	dst->type = src->type;
-	tcf_tree_unlock(tp);
 
+	synchronize_rcu();
 	tcf_exts_destroy(&old);
 #endif
 }
@@ -903,10 +901,7 @@ EXPORT_SYMBOL(tcf_exts_change);
 #ifdef CONFIG_NET_CLS_ACT
 static struct tc_action *tcf_exts_first_act(struct tcf_exts *exts)
 {
-	if (exts->nr_actions == 0)
-		return NULL;
-	else
-		return exts->actions[0];
+	return exts->action_list;
 }
 #endif
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 979cd26..dc12d79 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -131,9 +131,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 	int err;
 	struct tcf_exts e;
 
-	err = tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -147,7 +145,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(&f->exts, &e);
 	f->tp = tp;
 
 	return 0;
@@ -183,9 +181,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (!fnew)
 		return -ENOBUFS;
 
-	err = tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&fnew->exts, TCA_BASIC_ACT, TCA_BASIC_POLICE);
 
 	err = -EINVAL;
 	if (handle) {
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index f57bd53..49f311a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -397,9 +397,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf))
 		return -EINVAL;
 
-	ret = tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	if (ret < 0)
-		return ret;
+	tcf_exts_init(&exts, TCA_BPF_ACT, TCA_BPF_POLICE);
 	ret = tcf_exts_validate(net, tp, tb, est, &exts, ovr);
 	if (ret < 0)
 		goto errout;
@@ -436,7 +434,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &prog->res, base);
 	}
 
-	tcf_exts_change(tp, &prog->exts, &exts);
+	tcf_exts_change(&prog->exts, &exts);
 	return 0;
 
 errout:
@@ -488,9 +486,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (!prog)
 		return -ENOBUFS;
 
-	ret = tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
-	if (ret < 0)
-		goto errout;
+	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
 
 	if (oldprog) {
 		if (handle && oldprog->handle != handle) {
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index ce7d38b..f6f302a 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -92,9 +92,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!new)
 		return -ENOBUFS;
 
-	err = tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	new->handle = handle;
 	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
@@ -102,9 +100,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0) {
 		tcf_exts_destroy(&e);
@@ -117,7 +113,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 	}
 
-	tcf_exts_change(tp, &new->exts, &e);
+	tcf_exts_change(&new->exts, &e);
 
 	rcu_assign_pointer(tp->root, new);
 	if (head)
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 71fd1af..a2441c0 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -424,9 +424,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	err = tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-	if (err < 0)
-		goto err1;
+	tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0)
 		goto err1;
@@ -440,9 +438,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto err2;
 
-	err = tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-	if (err < 0)
-		goto err3;
+	tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 
 	fold = (struct flow_filter *)*arg;
 	if (fold) {
@@ -510,7 +506,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
 			       (unsigned long)fnew);
 
-	tcf_exts_change(tp, &fnew->exts, &e);
+	tcf_exts_change(&fnew->exts, &e);
 
 	netif_keep_dst(qdisc_dev(tp->q));
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 7832eb9..4bba357 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -855,9 +855,7 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_FLOWER_ACT, 0);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_FLOWER_ACT, 0);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -874,7 +872,7 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 	fl_mask_update_range(mask);
 	fl_set_masked_key(&f->mkey, &f->key, mask);
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(&f->exts, &e);
 
 	return 0;
 errout:
@@ -938,9 +936,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		goto errout_tb;
 	}
 
-	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
 
 	if (!handle) {
 		handle = fl_grab_new_handle(tp, head);
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a53fa75..46a0e32 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -200,9 +200,7 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	u32 mask;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -232,7 +230,7 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 	} else if (head->mask != 0xFFFFFFFF)
 		goto errout;
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(&f->exts, &e);
 
 	return 0;
 errout:
@@ -276,11 +274,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 #endif /* CONFIG_NET_CLS_IND */
 		fnew->tp = f->tp;
 
-		err = tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
-		if (err < 0) {
-			kfree(fnew);
-			return err;
-		}
+		tcf_exts_init(&fnew->exts, TCA_FW_ACT, TCA_FW_POLICE);
 
 		err = fw_change_attrs(net, tp, fnew, tb, tca, base, ovr);
 		if (err < 0) {
@@ -324,9 +318,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		return -ENOBUFS;
 
-	err = tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&f->exts, TCA_FW_ACT, TCA_FW_POLICE);
 	f->id = handle;
 	f->tp = tp;
 
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 9dc26c3..0b77f6e 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -123,9 +123,7 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
-	if (err)
-		return err;
+	tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -135,7 +133,7 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &head->res, base);
 	}
 
-	tcf_exts_change(tp, &head->exts, &e);
+	tcf_exts_change(&head->exts, &e);
 
 	return 0;
 errout:
@@ -176,9 +174,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (!new)
 		return -ENOBUFS;
 
-	err = tcf_exts_init(&new->exts, TCA_MATCHALL_ACT, 0);
-	if (err)
-		goto err_exts_init;
+	tcf_exts_init(&new->exts, TCA_MATCHALL_ACT, 0);
 
 	if (!handle)
 		handle = 1;
@@ -209,7 +205,6 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 err_replace_hw_filter:
 err_set_parms:
 	tcf_exts_destroy(&new->exts);
-err_exts_init:
 	kfree(new);
 	return err;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 26f8636..60be2c4 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -375,9 +375,7 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -450,7 +448,7 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
+	tcf_exts_change(&f->exts, &e);
 
 	return 0;
 errout:
@@ -488,9 +486,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (!f)
 		goto errout;
 
-	err = tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&f->exts, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
 
 	if (fold) {
 		f->id = fold->id;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 0d9d077..2088262 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -486,9 +486,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	err = tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_RSVP_ACT, TCA_RSVP_POLICE);
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0)
 		goto errout2;
@@ -507,18 +505,14 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			goto errout2;
 		}
 
-		err = tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
-		if (err < 0) {
-			kfree(n);
-			goto errout2;
-		}
+		tcf_exts_init(&n->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
 
 		if (tb[TCA_RSVP_CLASSID]) {
 			n->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID]);
 			tcf_bind_filter(tp, &n->res, base);
 		}
 
-		tcf_exts_change(tp, &n->exts, &e);
+		tcf_exts_change(&n->exts, &e);
 		rsvp_replace(tp, n, handle);
 		return 0;
 	}
@@ -535,9 +529,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (f == NULL)
 		goto errout2;
 
-	err = tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&f->exts, TCA_RSVP_ACT, TCA_RSVP_POLICE);
 	h2 = 16;
 	if (tb[TCA_RSVP_SRC]) {
 		memcpy(f->src, nla_data(tb[TCA_RSVP_SRC]), sizeof(f->src));
@@ -591,7 +583,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 			if (f->tunnelhdr == 0)
 				tcf_bind_filter(tp, &f->res, base);
 
-			tcf_exts_change(tp, &f->exts, &e);
+			tcf_exts_change(&f->exts, &e);
 
 			fp = &s->ht[h2];
 			for (nfp = rtnl_dereference(*fp); nfp;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 66924d1..b2d771c 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -223,10 +223,10 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
 	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
 };
 
-static int tcindex_filter_result_init(struct tcindex_filter_result *r)
+static void tcindex_filter_result_init(struct tcindex_filter_result *r)
 {
 	memset(r, 0, sizeof(*r));
-	return tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
+	tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 }
 
 static void __tcindex_partial_destroy(struct rcu_head *head)
@@ -248,25 +248,18 @@ static void tcindex_free_perfect_hash(struct tcindex_data *cp)
 
 static int tcindex_alloc_perfect_hash(struct tcindex_data *cp)
 {
-	int i, err = 0;
+	int i;
 
 	cp->perfect = kcalloc(cp->hash, sizeof(struct tcindex_filter_result),
 			      GFP_KERNEL);
 	if (!cp->perfect)
 		return -ENOMEM;
 
-	for (i = 0; i < cp->hash; i++) {
-		err = tcf_exts_init(&cp->perfect[i].exts,
-				    TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
-		if (err < 0)
-			goto errout;
-	}
+	for (i = 0; i < cp->hash; i++)
+		tcf_exts_init(&cp->perfect[i].exts,
+			      TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 
 	return 0;
-
-errout:
-	tcindex_free_perfect_hash(cp);
-	return err;
 }
 
 static int
@@ -282,9 +275,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	int err, balloc = 0;
 	struct tcf_exts e;
 
-	err = tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -316,12 +307,8 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 	cp->h = p->h;
 
-	err = tcindex_filter_result_init(&new_filter_result);
-	if (err < 0)
-		goto errout1;
-	err = tcindex_filter_result_init(&cr);
-	if (err < 0)
-		goto errout1;
+	tcindex_filter_result_init(&new_filter_result);
+	tcindex_filter_result_init(&cr);
 	if (old_r)
 		cr.res = r->res;
 
@@ -406,11 +393,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 			goto errout_alloc;
 		f->key = handle;
 		f->next = NULL;
-		err = tcindex_filter_result_init(&f->result);
-		if (err < 0) {
-			kfree(f);
-			goto errout_alloc;
-		}
+		tcindex_filter_result_init(&f->result);
 	}
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
@@ -419,17 +402,12 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	}
 
 	if (old_r)
-		tcf_exts_change(tp, &r->exts, &e);
+		tcf_exts_change(&r->exts, &e);
 	else
-		tcf_exts_change(tp, &cr.exts, &e);
+		tcf_exts_change(&cr.exts, &e);
 
-	if (old_r && old_r != r) {
-		err = tcindex_filter_result_init(old_r);
-		if (err < 0) {
-			kfree(f);
-			goto errout_alloc;
-		}
-	}
+	if (old_r && old_r != r)
+		tcindex_filter_result_init(old_r);
 
 	oldp = p;
 	r->res = cr.res;
@@ -439,7 +417,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		struct tcindex_filter *nfp;
 		struct tcindex_filter __rcu **fp;
 
-		tcf_exts_change(tp, &f->result.exts, &r->exts);
+		tcf_exts_change(&f->result.exts, &r->exts);
 
 		fp = cp->h + (handle % cp->hash);
 		for (nfp = rtnl_dereference(*fp);
@@ -459,7 +437,6 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		tcindex_free_perfect_hash(cp);
 	else if (balloc == 2)
 		kfree(cp->h);
-errout1:
 	tcf_exts_destroy(&cr.exts);
 	tcf_exts_destroy(&new_filter_result.exts);
 errout:
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 2d01195..2c834f3 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -726,9 +726,7 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
-	if (err < 0)
-		return err;
+	tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
 		goto errout;
@@ -769,7 +767,7 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 		n->ifindex = ret;
 	}
 #endif
-	tcf_exts_change(tp, &n->exts, &e);
+	tcf_exts_change(&n->exts, &e);
 
 	return 0;
 errout:
@@ -848,10 +846,7 @@ static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
 	new->tp = tp;
 	memcpy(&new->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 
-	if (tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE)) {
-		kfree(new);
-		return NULL;
-	}
+	tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE);
 
 	return new;
 }
@@ -1007,9 +1002,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->flags = flags;
 	n->tp = tp;
 
-	err = tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
-	if (err < 0)
-		goto errout;
+	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
 
 #ifdef CONFIG_CLS_U32_MARK
 	n->pcpu_success = alloc_percpu(u32);
-- 
2.9.3
