From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 34/34] net: sched: allow ingress and clsact qdiscs to share filter blocks
Date: Thu, 12 Oct 2017 19:18:23 +0200
Message-ID: <20171012171823.1431-35-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:52023 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755797AbdJLRS5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so15297961wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:56 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the previously introduced shared filter blocks
infrastructure and allow ingress and clsact qdisc instances to share
filter blocks. The block index is coming from userspace as qdisc option.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_sched.h | 12 ++++++
 net/sched/sch_ingress.c        | 89 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 100 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf55..a684087 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -871,4 +871,16 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* Ingress/clsact */
+
+enum {
+	TCA_CLSACT_UNSPEC,
+	TCA_CLSACT_INGRESS_BLOCK,
+	TCA_CLSACT_EGRESS_BLOCK,
+	__TCA_CLSACT_MAX
+};
+
+#define TCA_CLSACT_MAX	(__TCA_CLSACT_MAX - 1)
+
 #endif
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index b599db2..59625e8 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -54,12 +54,40 @@ static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
 	return q->block;
 }
 
+static const struct nla_policy ingress_policy[TCA_CLSACT_MAX + 1] = {
+	[TCA_CLSACT_INGRESS_BLOCK]	= { .type = NLA_U32 },
+};
+
+static int ingress_parse_opt(struct nlattr *opt, u32 *p_ingress_block_index)
+{
+	struct nlattr *tb[TCA_CLSACT_MAX + 1];
+	int err;
+
+	*p_ingress_block_index = 0;
+
+	if (!opt)
+		return 0;
+	err = nla_parse_nested(tb, TCA_CLSACT_MAX, opt, ingress_policy, NULL);
+	if (err)
+		return err;
+
+	if (tb[TCA_CLSACT_INGRESS_BLOCK])
+		*p_ingress_block_index =
+			nla_get_u32(tb[TCA_CLSACT_INGRESS_BLOCK]);
+	return 0;
+}
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
+	err = ingress_parse_opt(opt, &q->block_info.block_index);
+	if (err)
+		return err;
+
+	q->block_info.shareable = true;
 	q->block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
 
 	err = tcf_block_get_ext(&q->block, &dev->ingress_cl_list,
@@ -85,11 +113,14 @@ static void ingress_destroy(struct Qdisc *sch)
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct ingress_sched_data *q = qdisc_priv(sch);
 	struct nlattr *nest;
 
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
+	if (nla_put_u32(skb, TCA_CLSACT_INGRESS_BLOCK, q->block->index))
+		goto nla_put_failure;
 
 	return nla_nest_end(skb, nest);
 
@@ -155,12 +186,47 @@ static struct tcf_block *clsact_tcf_block(struct Qdisc *sch, unsigned long cl)
 	}
 }
 
+static const struct nla_policy clsact_policy[TCA_CLSACT_MAX + 1] = {
+	[TCA_CLSACT_INGRESS_BLOCK]	= { .type = NLA_U32 },
+	[TCA_CLSACT_EGRESS_BLOCK]	= { .type = NLA_U32 },
+};
+
+static int clsact_parse_opt(struct nlattr *opt, u32 *p_ingress_block_index,
+			    u32 *p_egress_block_index)
+{
+	struct nlattr *tb[TCA_CLSACT_MAX + 1];
+	int err;
+
+	*p_ingress_block_index = 0;
+	*p_egress_block_index = 0;
+
+	if (!opt)
+		return 0;
+	err = nla_parse_nested(tb, TCA_CLSACT_MAX, opt, clsact_policy, NULL);
+	if (err)
+		return err;
+
+	if (tb[TCA_CLSACT_INGRESS_BLOCK])
+		*p_ingress_block_index =
+			nla_get_u32(tb[TCA_CLSACT_INGRESS_BLOCK]);
+	if (tb[TCA_CLSACT_EGRESS_BLOCK])
+		*p_egress_block_index =
+			nla_get_u32(tb[TCA_CLSACT_EGRESS_BLOCK]);
+	return 0;
+}
+
 static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
+	err = clsact_parse_opt(opt, &q->ingress_block_info.block_index,
+			       &q->egress_block_info.block_index);
+	if (err)
+		return err;
+
+	q->ingress_block_info.shareable = true;
 	q->ingress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
 
 	err = tcf_block_get_ext(&q->ingress_block, &dev->ingress_cl_list,
@@ -168,6 +234,7 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	if (err)
 		return err;
 
+	q->egress_block_info.shareable = true;
 	q->egress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS;
 
 	err = tcf_block_get_ext(&q->egress_block, &dev->egress_cl_list,
@@ -202,6 +269,26 @@ static void clsact_destroy(struct Qdisc *sch)
 	net_dec_egress_queue();
 }
 
+static int clsact_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct clsact_sched_data *q = qdisc_priv(sch);
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (!nest)
+		goto nla_put_failure;
+	if (nla_put_u32(skb, TCA_CLSACT_INGRESS_BLOCK, q->ingress_block->index))
+		goto nla_put_failure;
+	if (nla_put_u32(skb, TCA_CLSACT_EGRESS_BLOCK, q->egress_block->index))
+		goto nla_put_failure;
+
+	return nla_nest_end(skb, nest);
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
 static const struct Qdisc_class_ops clsact_class_ops = {
 	.leaf		=	ingress_leaf,
 	.find		=	clsact_find,
@@ -217,7 +304,7 @@ static struct Qdisc_ops clsact_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct clsact_sched_data),
 	.init		=	clsact_init,
 	.destroy	=	clsact_destroy,
-	.dump		=	ingress_dump,
+	.dump		=	clsact_dump,
 	.owner		=	THIS_MODULE,
 };
 
-- 
2.9.5
