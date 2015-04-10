From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 16:33:12 -0700
Message-ID: <1428708792-5872-2-git-send-email-ast@plumgrid.com>
References: <1428708792-5872-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35764 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbbDJXd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 19:33:27 -0400
Received: by pddn5 with SMTP id n5so37263009pdd.2
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 16:33:27 -0700 (PDT)
In-Reply-To: <1428708792-5872-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC classifers and actions attached to ingress and egress qdiscs see
inconsistent skb->data. For ingress L2 header is already pulled, whereas
for egress it's present. Introduce an optional flag for ingress qdisc
which if set will cause ingress to push L2 header before calling
into classifiers/actions and pull L2 back afterwards.

The cls_bpf/act_bpf are now marked as 'needs_l2'. The users can use them
on ingress qdisc created with 'needs_l2' flag and on any egress qdisc.
The use of them with vanilla ingress is disallowed.

The ingress_l2 qdisc can only be attached to devices that provide headers_ops.

When ingress is not enabled static_key avoids *(skb->dev->ingress_queue)

When ingress is enabled the difference old vs new to reach qdisc spinlock:
old:
*(skb->dev->ingress_queue), if, *(rxq->qdisc), if, *(rxq->qdisc), if
new:
*(skb->dev->ingress_queue), if, *(rxq->qdisc), if, if

This patch provides a foundation to use ingress_l2+cls_bpf to filter
interesting traffic and mirror small part of it to a different netdev for
capturing. This approach is significantly faster than traditional af_packet,
since skb_clone is called after filtering. dhclient and other tap-based tools
may consider switching to this style.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

This patch is on top of Daniel's static_key patch:
http://patchwork.ozlabs.org/patch/460228/

V3->V4:
. drop skb_share_check() for ingress_l2, since it's called before taps
. drop 'needs_l2' marks in other cls/acts (only cls_bpf/act_bpf are marked)
. use static_key
. add dev->header_ops check to avoid attaching ingress_l2 to devices that
  don't support pushing of L2

 include/net/act_api.h          |    9 ++++---
 include/net/sch_generic.h      |    3 +++
 include/uapi/linux/pkt_sched.h |   10 +++++++
 net/core/dev.c                 |   57 +++++++++++++++++++++++++++++-----------
 net/sched/act_api.c            |   21 ++++++++++-----
 net/sched/act_bpf.c            |    1 +
 net/sched/cls_api.c            |   20 ++++++++++++--
 net/sched/cls_bpf.c            |    1 +
 net/sched/sch_api.c            |    5 ++++
 net/sched/sch_ingress.c        |   21 +++++++++++++++
 samples/bpf/tcbpf1_kern.c      |    6 -----
 11 files changed, 121 insertions(+), 33 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 3ee4c92afd1b..c52bd98b7dd9 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -95,6 +95,8 @@ struct tc_action_ops {
 			struct nlattr *est, struct tc_action *act, int ovr,
 			int bind);
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
+	u32	flags;
+#define TCA_NEEDS_L2	1
 };
 
 int tcf_hash_search(struct tc_action *a, u32 index);
@@ -112,12 +114,11 @@ int tcf_unregister_action(struct tc_action_ops *a);
 int tcf_action_destroy(struct list_head *actions, int bind);
 int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 		    struct tcf_result *res);
-int tcf_action_init(struct net *net, struct nlattr *nla,
-				  struct nlattr *est, char *n, int ovr,
-				  int bind, struct list_head *);
+int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
+		    char *n, int ovr, int bind, struct list_head *, bool);
 struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 				    struct nlattr *est, char *n, int ovr,
-				    int bind);
+				    int bind, bool qdisc_has_l2);
 int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6d778efcfdfd..e755cc50a037 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -61,6 +61,7 @@ struct Qdisc {
 				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
 #define TCQ_F_CPUSTATS		0x20 /* run using percpu statistics */
+#define TCQ_F_EARLY_INGRESS_L2	0x40 /* ingress qdisc with L2 header */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
@@ -228,6 +229,8 @@ struct tcf_proto_ops {
 					struct sk_buff *skb, struct tcmsg*);
 
 	struct module		*owner;
+	u32			flags;
+#define TCF_NEEDS_L2	1
 };
 
 struct tcf_proto {
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 534b84710745..1076c56e6458 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -845,4 +845,14 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* INGRESS section */
+
+enum {
+	TCA_INGRESS_UNSPEC,
+	TCA_INGRESS_NEEDS_L2,
+	__TCA_INGRESS_MAX,
+};
+
+#define TCA_INGRESS_MAX (__TCA_INGRESS_MAX - 1)
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index af4a1b0adc10..91f62e5b6105 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3529,12 +3529,11 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
  * the ingress scheduler, you just can't add policies on ingress.
  *
  */
-static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
+static int ing_filter(struct sk_buff *skb, struct Qdisc *q)
 {
 	struct net_device *dev = skb->dev;
 	u32 ttl = G_TC_RTTL(skb->tc_verd);
 	int result = TC_ACT_OK;
-	struct Qdisc *q;
 
 	if (unlikely(MAX_RED_LOOP < ttl++)) {
 		net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
@@ -3545,24 +3544,20 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	q = rcu_dereference(rxq->qdisc);
-	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
-		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
-			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
-	}
+	spin_lock(qdisc_lock(q));
+	if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
+		result = qdisc_enqueue_root(skb, q);
+	spin_unlock(qdisc_lock(q));
 
 	return result;
 }
 
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
+					 int *ret, struct net_device *orig_dev,
+					 struct Qdisc *q)
 {
-	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
-
-	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+	if (q->flags != TCQ_F_INGRESS) /* this check includes q == &noop_qdisc */
 		return skb;
 
 	if (*pt_prev) {
@@ -3570,7 +3565,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
+	switch (ing_filter(skb, q)) {
 	case TC_ACT_SHOT:
 	case TC_ACT_STOLEN:
 		kfree_skb(skb);
@@ -3579,6 +3574,27 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 
 	return skb;
 }
+
+static inline struct sk_buff *handle_early_ing(struct sk_buff *skb, struct Qdisc *q)
+{
+	u32 hard_header_len;
+
+	if (q->flags != (TCQ_F_INGRESS | TCQ_F_EARLY_INGRESS_L2))
+		return skb;
+
+	hard_header_len = skb->dev->hard_header_len;
+	skb_push(skb, hard_header_len);
+	skb_postpush_rcsum(skb, skb->data, hard_header_len);
+
+	switch (ing_filter(skb, q)) {
+	case TC_ACT_SHOT:
+	case TC_ACT_STOLEN:
+		kfree_skb(skb);
+		return NULL;
+	}
+	skb_pull_rcsum(skb, hard_header_len);
+	return skb;
+}
 #endif
 
 /**
@@ -3658,6 +3674,8 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	rx_handler_func_t *rx_handler;
 	struct net_device *orig_dev;
 	bool deliver_exact = false;
+	struct Qdisc *qdisc = &noop_qdisc;
+	struct netdev_queue *rxq;
 	int ret = NET_RX_DROP;
 	__be16 type;
 
@@ -3693,6 +3711,15 @@ another_round:
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
 		goto ncls;
 	}
+	if (static_key_false(&ingress_needed)) {
+		rxq = rcu_dereference(skb->dev->ingress_queue);
+		if (rxq)
+			qdisc = rcu_dereference(rxq->qdisc);
+
+		skb = handle_early_ing(skb, qdisc);
+		if (!skb)
+			goto unlock;
+	}
 #endif
 
 	if (pfmemalloc)
@@ -3713,7 +3740,7 @@ another_round:
 skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	if (static_key_false(&ingress_needed)) {
-		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+		skb = handle_ing(skb, &pt_prev, &ret, orig_dev, qdisc);
 		if (!skb)
 			goto unlock;
 	}
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3d43e4979f27..0fe93a60c59b 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -484,7 +484,7 @@ errout:
 
 struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 				    struct nlattr *est, char *name, int ovr,
-				    int bind)
+				    int bind, bool qdisc_has_l2)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
@@ -533,6 +533,14 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 		goto err_out;
 	}
 
+	if ((a_o->flags & TCA_NEEDS_L2) && !qdisc_has_l2) {
+		/* actions that require L2 cannot be attached
+		 * to vanilla ingress qdisc
+		 */
+		err = -EINVAL;
+		goto err_mod;
+	}
+
 	err = -ENOMEM;
 	a = kzalloc(sizeof(*a), GFP_KERNEL);
 	if (a == NULL)
@@ -565,9 +573,9 @@ err_out:
 	return ERR_PTR(err);
 }
 
-int tcf_action_init(struct net *net, struct nlattr *nla,
-				  struct nlattr *est, char *name, int ovr,
-				  int bind, struct list_head *actions)
+int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
+		    char *name, int ovr, int bind, struct list_head *actions,
+		    bool qdisc_has_l2)
 {
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
 	struct tc_action *act;
@@ -579,7 +587,8 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
 		return err;
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind);
+		act = tcf_action_init_1(net, tb[i], est, name, ovr, bind,
+					qdisc_has_l2);
 		if (IS_ERR(act)) {
 			err = PTR_ERR(act);
 			goto err;
@@ -931,7 +940,7 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	int ret = 0;
 	LIST_HEAD(actions);
 
-	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
+	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions, true);
 	if (ret)
 		goto done;
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 4d2cede17468..8f89d97dfa4a 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -339,6 +339,7 @@ static struct tc_action_ops act_bpf_ops __read_mostly = {
 	.dump		=	tcf_bpf_dump,
 	.cleanup	=	tcf_bpf_cleanup,
 	.init		=	tcf_bpf_init,
+	.flags		=	TCA_NEEDS_L2,
 };
 
 static int __init bpf_init_module(void)
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8b0470e418dc..3bbb033af864 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -111,6 +111,11 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 	return first;
 }
 
+static bool qdisc_has_l2(const struct Qdisc *q)
+{
+	return !(q->flags & TCQ_F_INGRESS) || (q->flags & TCQ_F_EARLY_INGRESS_L2);
+}
+
 /* Add/change/delete/get a filter node */
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
@@ -257,6 +262,15 @@ replay:
 			kfree(tp);
 			goto errout;
 		}
+		if ((tp_ops->flags & TCF_NEEDS_L2) && !qdisc_has_l2(q)) {
+			/* classifiers that need L2 header cannot be
+			 * attached to vanilla ingress qdisc
+			 */
+			err = -EINVAL;
+			module_put(tp_ops->owner);
+			kfree(tp);
+			goto errout;
+		}
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
 		tp->prio = nprio ? :
@@ -522,7 +536,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 		if (exts->police && tb[exts->police]) {
 			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
 						"police", ovr,
-						TCA_ACT_BIND);
+						TCA_ACT_BIND,
+						qdisc_has_l2(tp->q));
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
@@ -532,7 +547,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			int err;
 			err = tcf_action_init(net, tb[exts->action], rate_tlv,
 					      NULL, ovr,
-					      TCA_ACT_BIND, &exts->actions);
+					      TCA_ACT_BIND, &exts->actions,
+					      qdisc_has_l2(tp->q));
 			if (err)
 				return err;
 		}
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 5c4171c5d2bd..b99e677e2800 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -476,6 +476,7 @@ static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.delete		=	cls_bpf_delete,
 	.walk		=	cls_bpf_walk,
 	.dump		=	cls_bpf_dump,
+	.flags		=	TCF_NEEDS_L2,
 };
 
 static int __init cls_bpf_init_mod(void)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ad9eed70bc8f..521499bf610a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -987,6 +987,11 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out4;
 		}
 
+		if ((sch->flags & TCQ_F_EARLY_INGRESS_L2) && !dev->header_ops) {
+			err = -EINVAL;
+			goto err_out4;
+		}
+
 		qdisc_list_add(sch);
 
 		return sch;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 4cdbfb85686a..6bdbb6cc3f49 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -88,8 +88,29 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 /* ------------------------------------------------------------- */
 
+static const struct nla_policy ingress_policy[TCA_INGRESS_MAX + 1] = {
+	[TCA_INGRESS_NEEDS_L2]	= { .type = NLA_U32 },
+};
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
+	struct nlattr *tb[TCA_INGRESS_MAX + 1];
+	int err;
+
+	if (!opt)
+		goto out;
+
+	err = nla_parse_nested(tb, TCA_INGRESS_MAX, opt, ingress_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_INGRESS_NEEDS_L2]) {
+		if (nla_get_u32(tb[TCA_INGRESS_NEEDS_L2]))
+			sch->flags |= TCQ_F_EARLY_INGRESS_L2;
+		else
+			sch->flags &= ~TCQ_F_EARLY_INGRESS_L2;
+	}
+out:
 	net_inc_ingress_queue();
 
 	return 0;
diff --git a/samples/bpf/tcbpf1_kern.c b/samples/bpf/tcbpf1_kern.c
index 7cf3f42a6e39..76cdaab63058 100644
--- a/samples/bpf/tcbpf1_kern.c
+++ b/samples/bpf/tcbpf1_kern.c
@@ -14,12 +14,6 @@ static inline void set_dst_mac(struct __sk_buff *skb, char *mac)
 	bpf_skb_store_bytes(skb, 0, mac, ETH_ALEN, 1);
 }
 
-/* use 1 below for ingress qdisc and 0 for egress */
-#if 0
-#undef ETH_HLEN
-#define ETH_HLEN 0
-#endif
-
 #define IP_CSUM_OFF (ETH_HLEN + offsetof(struct iphdr, check))
 #define TOS_OFF (ETH_HLEN + offsetof(struct iphdr, tos))
 
-- 
1.7.9.5
