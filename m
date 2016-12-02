From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 2/2] net/sched: cls_flower: Support matching on ICMP type and code
Date: Fri,  2 Dec 2016 10:52:32 +0100
Message-ID: <1480672352-13291-3-git-send-email-simon.horman@netronome.com>
References: <1480672352-13291-1-git-send-email-simon.horman@netronome.com>
Cc: "David S.  Miller" <davem@davemloft.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37241 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758635AbcLBJwr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 04:52:47 -0500
Received: by mail-wm0-f43.google.com with SMTP id t79so10733530wmt.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 01:52:46 -0800 (PST)
In-Reply-To: <1480672352-13291-1-git-send-email-simon.horman@netronome.com>
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
 include/net/flow_dissector.h | 24 ++++++++++++++++++++++--
 include/uapi/linux/pkt_cls.h | 10 ++++++++++
 net/sched/cls_flower.c       | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 8880025914e3..5540dfa18872 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -199,10 +199,30 @@ struct flow_keys_digest {
 void make_flow_keys_digest(struct flow_keys_digest *digest,
 			   const struct flow_keys *flow);
 
+static inline bool flow_protos_are_icmpv4(__be16 n_proto, u8 ip_proto)
+{
+	return n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP;
+}
+
+static inline bool flow_protos_are_icmpv6(__be16 n_proto, u8 ip_proto)
+{
+	return n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6;
+}
+
 static inline bool flow_protos_are_icmp_any(__be16 n_proto, u8 ip_proto)
 {
-	return (n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP) ||
-		(n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6);
+	return flow_protos_are_icmpv4(n_proto, ip_proto) ||
+		flow_protos_are_icmpv6(n_proto, ip_proto);
+}
+
+static inline bool flow_basic_key_is_icmpv4(const struct flow_dissector_key_basic *basic)
+{
+	return flow_protos_are_icmpv4(basic->n_proto, basic->ip_proto);
+}
+
+static inline bool flow_basic_key_is_icmpv6(const struct flow_dissector_key_basic *basic)
+{
+	return flow_protos_are_icmpv6(basic->n_proto, basic->ip_proto);
 }
 
 static inline bool flow_keys_are_icmp_any(const struct flow_keys *keys)
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 86786d45ee66..58160fe80b80 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -457,6 +457,16 @@ enum {
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
index e8dd09af0d0c..412efa7de226 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -355,6 +355,14 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
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
@@ -471,6 +479,20 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_SCTP_DST,
 			       &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
 			       sizeof(key->tp.dst));
+	} else if (flow_basic_key_is_icmpv4(&key->basic)) {
+		fl_set_key_val(tb, &key->tp.type, TCA_FLOWER_KEY_ICMPV4_TYPE,
+			       &mask->tp.type, TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
+			       sizeof(key->tp.type));
+		fl_set_key_val(tb, &key->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->tp.code));
+	} else if (flow_basic_key_is_icmpv6(&key->basic)) {
+		fl_set_key_val(tb, &key->tp.type, TCA_FLOWER_KEY_ICMPV6_TYPE,
+			       &mask->tp.type, TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
+			       sizeof(key->tp.type));
+		fl_set_key_val(tb, &key->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->tp.code));
 	}
 
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
@@ -943,6 +965,26 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
+	else if (flow_basic_key_is_icmpv4(&key->basic) &&
+		 (fl_dump_key_val(skb, &key->tp.type,
+				  TCA_FLOWER_KEY_ICMPV4_TYPE, &mask->tp.type,
+				  TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
+				  sizeof(key->tp.type)) ||
+		  fl_dump_key_val(skb, &key->tp.code,
+				  TCA_FLOWER_KEY_ICMPV4_CODE, &mask->tp.code,
+				  TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+				  sizeof(key->tp.code))))
+		goto nla_put_failure;
+	else if (flow_basic_key_is_icmpv6(&key->basic) &&
+		 (fl_dump_key_val(skb, &key->tp.type,
+				  TCA_FLOWER_KEY_ICMPV6_TYPE, &mask->tp.type,
+				  TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
+				  sizeof(key->tp.type)) ||
+		  fl_dump_key_val(skb, &key->tp.code,
+				  TCA_FLOWER_KEY_ICMPV6_CODE, &mask->tp.code,
+				  TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
+				  sizeof(key->tp.code))))
+		goto nla_put_failure;
 
 	if (key->enc_control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
 	    (fl_dump_key_val(skb, &key->enc_ipv4.src,
-- 
2.7.0.rc3.207.g0ac5344
