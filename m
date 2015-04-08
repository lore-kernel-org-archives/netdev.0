From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Wed,  8 Apr 2015 16:26:15 -0700
Message-ID: <1428535575-7736-2-git-send-email-ast@plumgrid.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36632 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454AbbDHX0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 19:26:24 -0400
Received: by pdea3 with SMTP id a3so131435117pde.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 16:26:23 -0700 (PDT)
In-Reply-To: <1428535575-7736-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC classifers and actions attached to ingress and egress qdiscs see
inconsistent skb->data. For ingress L2 header is already pulled, whereas
for egress it's present. Introduce an optional flag for ingress qdisc
which if set will cause ingress to push L2 header before calling
into classifiers/actions and pull L2 back afterwards.

The following cls/act assume L2 and now marked as 'needs_l2':
cls_bpf, act_bpf, cls_rsvp, act_csum, act_nat.
The users can use them on ingress qdisc created with 'needs_l2' flag and
on any egress qdisc. The use of them with vanilla ingress is disallowed.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
V2->V3: rewrite to use optional flag for ingress qdisc and corresponding
flags for classifers and actions

cls_bpf/act_bpf will always require L2.

cls_rsvp, act_csum, act_nat are doing pskb_may_pull/skb_clone_writable
assuming that skb->data is pointing to L2. Should be fixable.

Everything that calls into ematch is also potentially broken on ingress.
Like em_canid does:
  struct can_frame *cf = (struct can_frame *)skb->data;
and other em-s do:
  case TCF_LAYER_LINK:
    return skb->data;
Should be fixable as well.

skb_share_check() can be costly when taps are used. In my use cases of
tc+bpf that doesn't happen, so I'm not worried at the moment.
If tc+bpf usage changes in the future, we can add 'early_ingress_l2' flag
that will bypass taps and avoid skb_share_check. This early_handle_ing() hook
can be wrapped with static_key as well.

 include/net/act_api.h          |    9 +++++----
 include/net/sch_generic.h      |    3 +++
 include/uapi/linux/pkt_sched.h |   10 ++++++++++
 net/core/dev.c                 |   22 ++++++++++++++++++++--
 net/sched/act_api.c            |   21 +++++++++++++++------
 net/sched/act_bpf.c            |    1 +
 net/sched/act_csum.c           |    2 ++
 net/sched/act_nat.c            |    2 ++
 net/sched/cls_api.c            |   21 +++++++++++++++++++--
 net/sched/cls_bpf.c            |    1 +
 net/sched/cls_rsvp.h           |    2 ++
 net/sched/sch_ingress.c        |   27 +++++++++++++++++++++++++++
 samples/bpf/tcbpf1_kern.c      |    6 ------
 13 files changed, 107 insertions(+), 20 deletions(-)

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
index 6d778efcfdfd..5f0efa556a35 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -61,6 +61,7 @@ struct Qdisc {
 				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
 #define TCQ_F_CPUSTATS		0x20 /* run using percpu statistics */
+#define TCQ_F_INGRESS_L2	0x40 /* ingress qdisc with L2 header */
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
index b2775f06c710..957a31ef25ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3513,10 +3513,13 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
  * the ingress scheduler, you just can't add policies on ingress.
  *
  */
-static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
+static int ing_filter(struct sk_buff **pskb, struct netdev_queue *rxq)
 {
+	struct sk_buff *skb = *pskb;
 	struct net_device *dev = skb->dev;
+	u32 hard_header_len = dev->hard_header_len;
 	u32 ttl = G_TC_RTTL(skb->tc_verd);
+	u32 needs_l2;
 	int result = TC_ACT_OK;
 	struct Qdisc *q;
 
@@ -3531,10 +3534,25 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
+		needs_l2 = q->flags & TCQ_F_INGRESS_L2;
+		if (needs_l2) {
+			*pskb = skb = skb_share_check(skb, GFP_ATOMIC);
+
+			if (unlikely(!skb))
+				/* original skb was freed by skb_share_check */
+				return TC_ACT_UNSPEC;
+
+			skb_push(skb, hard_header_len);
+			skb_postpush_rcsum(skb, skb->data, hard_header_len);
+		}
+
 		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
 			result = qdisc_enqueue_root(skb, q);
 		spin_unlock(qdisc_lock(q));
+
+		if (needs_l2)
+			skb_pull_rcsum(skb, hard_header_len);
 	}
 
 	return result;
@@ -3554,7 +3572,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
+	switch (ing_filter(&skb, rxq)) {
 	case TC_ACT_SHOT:
 	case TC_ACT_STOLEN:
 		kfree_skb(skb);
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
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 4cd5cf1aedf8..887033fbdfa6 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -565,6 +565,8 @@ static struct tc_action_ops act_csum_ops = {
 	.act		= tcf_csum,
 	.dump		= tcf_csum_dump,
 	.init		= tcf_csum_init,
+	/* todo: fix pskb_may_pull in tcf_csum to not assume L2 */
+	.flags		= TCA_NEEDS_L2,
 };
 
 MODULE_DESCRIPTION("Checksum updating actions");
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 270a030d5fd0..de83aa016302 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -287,6 +287,8 @@ static struct tc_action_ops act_nat_ops = {
 	.act		=	tcf_nat,
 	.dump		=	tcf_nat_dump,
 	.init		=	tcf_nat_init,
+	/* todo: fix pskb_may_pull in tcf_nat to not assume L2 */
+	.flags		=	TCA_NEEDS_L2,
 };
 
 MODULE_DESCRIPTION("Stateless NAT actions");
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 8b0470e418dc..ae1b1b769136 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -257,6 +257,17 @@ replay:
 			kfree(tp);
 			goto errout;
 		}
+		if ((tp_ops->flags & TCF_NEEDS_L2) &&
+		    (q->flags & TCQ_F_INGRESS) &&
+		    !(q->flags & TCQ_F_INGRESS_L2)) {
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
@@ -517,12 +528,17 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 #ifdef CONFIG_NET_CLS_ACT
 	{
 		struct tc_action *act;
+		bool qdisc_has_l2 = true;
+
+		if ((tp->q->flags & TCQ_F_INGRESS) &&
+		    !(tp->q->flags & TCQ_F_INGRESS_L2))
+			qdisc_has_l2 = false;
 
 		INIT_LIST_HEAD(&exts->actions);
 		if (exts->police && tb[exts->police]) {
 			act = tcf_action_init_1(net, tb[exts->police], rate_tlv,
 						"police", ovr,
-						TCA_ACT_BIND);
+						TCA_ACT_BIND, qdisc_has_l2);
 			if (IS_ERR(act))
 				return PTR_ERR(act);
 
@@ -532,7 +548,8 @@ int tcf_exts_validate(struct net *net, struct tcf_proto *tp, struct nlattr **tb,
 			int err;
 			err = tcf_action_init(net, tb[exts->action], rate_tlv,
 					      NULL, ovr,
-					      TCA_ACT_BIND, &exts->actions);
+					      TCA_ACT_BIND, &exts->actions,
+					      qdisc_has_l2);
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
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 02fa82792dab..9f1ff1e19f20 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -716,6 +716,8 @@ static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.walk		=	rsvp_walk,
 	.dump		=	rsvp_dump,
 	.owner		=	THIS_MODULE,
+	/* todo: fix pskb_network_may_pull in rsvp_classify to not assume L2 */
+	.flags		=	TCF_NEEDS_L2,
 };
 
 static int __init init_rsvp(void)
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index eb5b8445fef9..431ae6ffd142 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -109,6 +109,32 @@ nla_put_failure:
 	return -1;
 }
 
+static const struct nla_policy ingress_policy[TCA_INGRESS_MAX + 1] = {
+	[TCA_INGRESS_NEEDS_L2]	= { .type = NLA_U32 },
+};
+
+/* NEEDS_L2 flag can only be set at init time */
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct nlattr *tb[TCA_INGRESS_MAX + 1];
+	int err;
+
+	if (!opt)
+		return 0;
+
+	err = nla_parse_nested(tb, TCA_INGRESS_MAX, opt, ingress_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_INGRESS_NEEDS_L2]) {
+		if (nla_get_u32(tb[TCA_INGRESS_NEEDS_L2]))
+			sch->flags |= TCQ_F_INGRESS_L2;
+		else
+			sch->flags &= ~TCQ_F_INGRESS_L2;
+	}
+	return 0;
+}
+
 static const struct Qdisc_class_ops ingress_class_ops = {
 	.leaf		=	ingress_leaf,
 	.get		=	ingress_get,
@@ -123,6 +149,7 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 	.cl_ops		=	&ingress_class_ops,
 	.id		=	"ingress",
 	.priv_size	=	sizeof(struct ingress_qdisc_data),
+	.init		=	ingress_init,
 	.enqueue	=	ingress_enqueue,
 	.destroy	=	ingress_destroy,
 	.dump		=	ingress_dump,
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
