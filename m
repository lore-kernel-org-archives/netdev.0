From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] net/sched: flower: add support for matching on tcp flags
Date: Tue, 23 May 2017 16:31:08 +0200
Message-ID: <20170523143110.5006-4-jiri@resnulli.us>
References: <20170523143110.5006-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33041 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936589AbdEWObU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:31:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id b84so24017250wmh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 07:31:20 -0700 (PDT)
In-Reply-To: <20170523143110.5006-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the support of tcp flags dissection and allow user to
insert rules matching on tcp flags.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/cls_flower.c       | 13 ++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 1b9aa9e..c6e8cf5 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -451,6 +451,9 @@ enum {
 	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
 	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
 
+	TCA_FLOWER_KEY_TCP_FLAGS,	/* be16 */
+	TCA_FLOWER_KEY_TCP_FLAGS_MASK,	/* be16 */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index ca526c0..fb74a47 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -49,6 +49,7 @@ struct fl_flow_key {
 	};
 	struct flow_dissector_key_ports enc_tp;
 	struct flow_dissector_key_mpls mpls;
+	struct flow_dissector_key_tcp tcp;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -424,6 +425,8 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_MPLS_BOS]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_MPLS_TC]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_MPLS_LABEL]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_TCP_FLAGS]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_TCP_FLAGS_MASK]	= { .type = NLA_U16 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -596,6 +599,9 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_TCP_DST,
 			       &mask->tp.dst, TCA_FLOWER_KEY_TCP_DST_MASK,
 			       sizeof(key->tp.dst));
+		fl_set_key_val(tb, &key->tcp.flags, TCA_FLOWER_KEY_TCP_FLAGS,
+			       &mask->tcp.flags, TCA_FLOWER_KEY_TCP_FLAGS_MASK,
+			       sizeof(key->tcp.flags));
 	} else if (key->basic.ip_proto == IPPROTO_UDP) {
 		fl_set_key_val(tb, &key->tp.src, TCA_FLOWER_KEY_UDP_SRC,
 			       &mask->tp.src, TCA_FLOWER_KEY_UDP_SRC_MASK,
@@ -767,6 +773,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_TCP, tcp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ICMP, icmp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ARP, arp);
@@ -1215,7 +1223,10 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			     sizeof(key->tp.src)) ||
 	     fl_dump_key_val(skb, &key->tp.dst, TCA_FLOWER_KEY_TCP_DST,
 			     &mask->tp.dst, TCA_FLOWER_KEY_TCP_DST_MASK,
-			     sizeof(key->tp.dst))))
+			     sizeof(key->tp.dst)) ||
+	     fl_dump_key_val(skb, &key->tcp.flags, TCA_FLOWER_KEY_TCP_FLAGS,
+			     &mask->tcp.flags, TCA_FLOWER_KEY_TCP_FLAGS_MASK,
+			     sizeof(key->tcp.flags))))
 		goto nla_put_failure;
 	else if (key->basic.ip_proto == IPPROTO_UDP &&
 		 (fl_dump_key_val(skb, &key->tp.src, TCA_FLOWER_KEY_UDP_SRC,
-- 
2.9.3
