From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v5 2/2] net/sched: cls_flower: Support matching on ICMP type and code
Date: Wed,  7 Dec 2016 13:14:40 +0100
Message-ID: <1481112880-9801-3-git-send-email-simon.horman@netronome.com>
References: <1481112880-9801-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38103 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbcLGMOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:14:51 -0500
Received: by mail-wm0-f47.google.com with SMTP id f82so163874575wmf.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 04:14:50 -0800 (PST)
In-Reply-To: <1481112880-9801-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on ICMP type and code.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ip parent ffff: flower \
	indev eth0 ip_proto icmp type 8 code 0 action drop

tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 128 code 0 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v5
* Open-code checking for icmp protocols rather than using helpers

v4
* No change

v3
* Use separate dissector key FLOW_DISSECTOR_KEY_ICMP
* Use separate structure to hold icmp fields, this does not share
  storage with ports

v2
* Move helpers to another patch
---
 include/uapi/linux/pkt_cls.h | 10 +++++++++
 net/sched/cls_flower.c       | 53 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 1adc0b654996..884c5aa515c4 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -458,6 +458,16 @@ enum {
 	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
+
+	TCA_FLOWER_KEY_ICMPV4_CODE,	/* u8 */
+	TCA_FLOWER_KEY_ICMPV4_CODE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV4_TYPE,	/* u8 */
+	TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_CODE,	/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_CODE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 29a9e6d9f274..f61f11b3194e 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -39,6 +39,7 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv6_addrs ipv6;
 	};
 	struct flow_dissector_key_ports tp;
+	struct flow_dissector_key_icmp icmp;
 	struct flow_dissector_key_keyid enc_key_id;
 	union {
 		struct flow_dissector_key_ipv4_addrs enc_ipv4;
@@ -386,6 +387,14 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_ICMPV4_TYPE]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV4_TYPE_MASK] = { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV4_CODE]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV4_CODE_MASK] = { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV6_TYPE]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV6_TYPE_MASK] = { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV6_CODE]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ICMPV6_CODE_MASK] = { .type = NLA_U8 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -502,6 +511,26 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_SCTP_DST,
 			       &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
 			       sizeof(key->tp.dst));
+	} else if (key->basic.n_proto == htons(ETH_P_IP) &&
+		   key->basic.ip_proto == IPPROTO_ICMP) {
+		fl_set_key_val(tb, &key->icmp.type, TCA_FLOWER_KEY_ICMPV4_TYPE,
+			       &mask->icmp.type,
+			       TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
+			       sizeof(key->icmp.type));
+		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->icmp.code,
+			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->icmp.code));
+	} else if (key->basic.n_proto == htons(ETH_P_IPV6) &&
+		   key->basic.ip_proto == IPPROTO_ICMPV6) {
+		fl_set_key_val(tb, &key->icmp.type, TCA_FLOWER_KEY_ICMPV6_TYPE,
+			       &mask->icmp.type,
+			       TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
+			       sizeof(key->icmp.type));
+		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->icmp.code,
+			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->icmp.code));
 	}
 
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
@@ -612,6 +641,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ICMP, icmp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
@@ -977,6 +1008,28 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
+	else if (key->basic.n_proto == htons(ETH_P_IP) &&
+		 key->basic.ip_proto == IPPROTO_ICMP &&
+		 (fl_dump_key_val(skb, &key->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV4_TYPE, &mask->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
+				  sizeof(key->icmp.type)) ||
+		  fl_dump_key_val(skb, &key->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV4_CODE, &mask->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+				  sizeof(key->icmp.code))))
+		goto nla_put_failure;
+	else if (key->basic.n_proto == htons(ETH_P_IPV6) &&
+		 key->basic.ip_proto == IPPROTO_ICMPV6 &&
+		 (fl_dump_key_val(skb, &key->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV6_TYPE, &mask->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
+				  sizeof(key->icmp.type)) ||
+		  fl_dump_key_val(skb, &key->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV6_CODE, &mask->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
+				  sizeof(key->icmp.code))))
+		goto nla_put_failure;
 
 	if (key->enc_control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
 	    (fl_dump_key_val(skb, &key->enc_ipv4.src,
-- 
2.7.0.rc3.207.g0ac5344
