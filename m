From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 4/4] net: sched: allow ingress and clsact qdiscs to share filter blocks
Date: Mon, 10 Jul 2017 20:51:10 +0200
Message-ID: <20170710185110.3180-5-jiri@resnulli.us>
References: <20170710185110.3180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, stephen@networkplumber.org, jbenc@redhat.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        john.fastabend@gmail.com, alexander.h.duyck@intel.com,
        daniel@iogearbox.net, ogerlitz@mellanox.com, mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35064 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754658AbdGJSvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:51:20 -0400
Received: by mail-wr0-f195.google.com with SMTP id z45so27005379wrb.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:51:20 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the previously introduced shared filter blocks
infrastructure and allow ingress and clsact qdisc instances to share
filter blocks. The block index is coming from userspace as qdisc option.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_sched.h |  12 +++++
 net/sched/sch_ingress.c        | 107 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 112 insertions(+), 7 deletions(-)

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
index d8a9beb..f18b257 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -58,13 +58,42 @@ static struct tcf_block *ingress_tcf_block(struct Qdisc *sch, unsigned long cl)
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
+	u32 ingress_block_index;
 	int err;
 
-	err = tcf_block_get(&q->block, &dev->ingress_cl_list);
+	err = ingress_parse_opt(opt, &ingress_block_index);
+	if (err)
+		return err;
+
+	err = tcf_block_get_shared(&q->block, qdisc_net(sch),
+				   ingress_block_index, &dev->ingress_cl_list);
 	if (err)
 		return err;
 
@@ -77,18 +106,22 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put_shared(q->block, qdisc_net(sch), &dev->ingress_cl_list);
 	net_dec_ingress_queue();
 }
 
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
 
@@ -159,17 +192,54 @@ static struct tcf_block *clsact_tcf_block(struct Qdisc *sch, unsigned long cl)
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
+	u32 ingress_block_index;
+	u32 egress_block_index;
 	int err;
 
-	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list);
+	err = clsact_parse_opt(opt, &ingress_block_index, &egress_block_index);
 	if (err)
 		return err;
 
-	err = tcf_block_get(&q->egress_block, &dev->egress_cl_list);
+	err = tcf_block_get_shared(&q->ingress_block, qdisc_net(sch),
+				   ingress_block_index, &dev->ingress_cl_list);
+	if (err)
+		return err;
+
+	err = tcf_block_get_shared(&q->egress_block, qdisc_net(sch),
+				   egress_block_index, &dev->egress_cl_list);
 	if (err)
 		return err;
 
@@ -184,14 +254,37 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put(q->egress_block);
-	tcf_block_put(q->ingress_block);
+	tcf_block_put_shared(q->egress_block, qdisc_net(sch),
+			     &dev->ingress_cl_list);
+	tcf_block_put_shared(q->ingress_block, qdisc_net(sch),
+			     &dev->egress_cl_list);
 
 	net_dec_ingress_queue();
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
 	.get		=	clsact_get,
@@ -209,7 +302,7 @@ static struct Qdisc_ops clsact_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct clsact_sched_data),
 	.init		=	clsact_init,
 	.destroy	=	clsact_destroy,
-	.dump		=	ingress_dump,
+	.dump		=	clsact_dump,
 	.owner		=	THIS_MODULE,
 };
 
-- 
2.9.3
