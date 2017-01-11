From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 2/2] net/sched: cls_flower: Support matching on ARP
Date: Wed, 11 Jan 2017 14:05:43 +0100
Message-ID: <1484139943-18199-3-git-send-email-simon.horman@netronome.com>
References: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:35950 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966463AbdAKNGQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:06:16 -0500
Received: by mail-wj0-f175.google.com with SMTP id ew7so88136988wjc.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 05:06:15 -0800 (PST)
In-Reply-To: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on ARP operation, and hardware and protocol addresses
for Ethernet hardware and IPv4 protocol addresses.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol arp parent ffff: flower indev eth0 \
	arp_op request arp_sip 10.0.0.1 action drop
tc filter add dev eth0 protocol rarp parent ffff: flower indev eth0 \
	arp_op reply arp_tha 52:54:3f:00:00:00/24 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/pkt_cls.h | 11 ++++++++++
 net/sched/cls_flower.c       | 51 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index a081efbd61a2..1e5e1ddfdaca 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -416,6 +416,17 @@ enum {
 	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
 	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
 
+	TCA_FLOWER_KEY_ARP_SIP,		/* be32 */
+	TCA_FLOWER_KEY_ARP_SIP_MASK,	/* be32 */
+	TCA_FLOWER_KEY_ARP_TIP,		/* be32 */
+	TCA_FLOWER_KEY_ARP_TIP_MASK,	/* be32 */
+	TCA_FLOWER_KEY_ARP_OP,		/* u8 */
+	TCA_FLOWER_KEY_ARP_OP_MASK,	/* u8 */
+	TCA_FLOWER_KEY_ARP_SHA,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_SHA_MASK,	/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 970db7a41684..a3bfda3091a4 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -40,6 +40,7 @@ struct fl_flow_key {
 	};
 	struct flow_dissector_key_ports tp;
 	struct flow_dissector_key_icmp icmp;
+	struct flow_dissector_key_arp arp;
 	struct flow_dissector_key_keyid enc_key_id;
 	union {
 		struct flow_dissector_key_ipv4_addrs enc_ipv4;
@@ -401,6 +402,16 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ICMPV6_TYPE_MASK] = { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_ICMPV6_CODE]	= { .type = NLA_U8 },
 	[TCA_FLOWER_KEY_ICMPV6_CODE_MASK] = { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ARP_SIP]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ARP_SIP_MASK]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ARP_TIP]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ARP_TIP_MASK]	= { .type = NLA_U32 },
+	[TCA_FLOWER_KEY_ARP_OP]		= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ARP_OP_MASK]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_ARP_SHA]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ARP_SHA_MASK]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ARP_THA]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ARP_THA_MASK]	= { .len = ETH_ALEN },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -572,6 +583,23 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->icmp.code,
 			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
 			       sizeof(key->icmp.code));
+	} else if (key->basic.n_proto == htons(ETH_P_ARP) ||
+		   key->basic.n_proto == htons(ETH_P_RARP)) {
+		fl_set_key_val(tb, &key->arp.sip, TCA_FLOWER_KEY_ARP_SIP,
+			       &mask->arp.sip, TCA_FLOWER_KEY_ARP_SIP_MASK,
+			       sizeof(key->arp.sip));
+		fl_set_key_val(tb, &key->arp.tip, TCA_FLOWER_KEY_ARP_TIP,
+			       &mask->arp.tip, TCA_FLOWER_KEY_ARP_TIP_MASK,
+			       sizeof(key->arp.tip));
+		fl_set_key_val(tb, &key->arp.op, TCA_FLOWER_KEY_ARP_OP,
+			       &mask->arp.op, TCA_FLOWER_KEY_ARP_OP_MASK,
+			       sizeof(key->arp.op));
+		fl_set_key_val(tb, key->arp.sha, TCA_FLOWER_KEY_ARP_SHA,
+			       mask->arp.sha, TCA_FLOWER_KEY_ARP_SHA_MASK,
+			       sizeof(key->arp.sha));
+		fl_set_key_val(tb, key->arp.tha, TCA_FLOWER_KEY_ARP_THA,
+			       mask->arp.tha, TCA_FLOWER_KEY_ARP_THA_MASK,
+			       sizeof(key->arp.tha));
 	}
 
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
@@ -689,6 +717,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ICMP, icmp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ARP, arp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
@@ -1112,6 +1142,27 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
 				  sizeof(key->icmp.code))))
 		goto nla_put_failure;
+	else if ((key->basic.n_proto == htons(ETH_P_ARP) ||
+		  key->basic.n_proto == htons(ETH_P_RARP)) &&
+		 (fl_dump_key_val(skb, &key->arp.sip,
+				  TCA_FLOWER_KEY_ARP_SIP, &mask->arp.sip,
+				  TCA_FLOWER_KEY_ARP_SIP_MASK,
+				  sizeof(key->arp.sip)) ||
+		  fl_dump_key_val(skb, &key->arp.tip,
+				  TCA_FLOWER_KEY_ARP_TIP, &mask->arp.tip,
+				  TCA_FLOWER_KEY_ARP_TIP_MASK,
+				  sizeof(key->arp.tip)) ||
+		  fl_dump_key_val(skb, &key->arp.op,
+				  TCA_FLOWER_KEY_ARP_OP, &mask->arp.op,
+				  TCA_FLOWER_KEY_ARP_OP_MASK,
+				  sizeof(key->arp.op)) ||
+		  fl_dump_key_val(skb, key->arp.sha, TCA_FLOWER_KEY_ARP_SHA,
+				  mask->arp.sha, TCA_FLOWER_KEY_ARP_SHA_MASK,
+				  sizeof(key->arp.sha)) ||
+		  fl_dump_key_val(skb, key->arp.tha, TCA_FLOWER_KEY_ARP_THA,
+				  mask->arp.tha, TCA_FLOWER_KEY_ARP_THA_MASK,
+				  sizeof(key->arp.tha))))
+		goto nla_put_failure;
 
 	if (key->enc_control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
 	    (fl_dump_key_val(skb, &key->enc_ipv4.src,
-- 
2.7.0.rc3.207.g0ac5344
