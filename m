From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/4] net/sched: cls_flower: add support for matching on ip tos and ttl
Date: Thu, 25 May 2017 16:24:37 +0300
Message-ID: <1495718679-20693-3-git-send-email-ogerlitz@mellanox.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53816 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750988AbdEYNYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 09:24:51 -0400
In-Reply-To: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from the support of ip header fields dissection and
allow users to set rules matching on ipv4 tos and ttl or
ipv6 traffic-class and hoplimit.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  5 +++++
 net/sched/cls_flower.c       | 39 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index c6e8cf5..edf43dd 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -454,6 +454,11 @@ enum {
 	TCA_FLOWER_KEY_TCP_FLAGS,	/* be16 */
 	TCA_FLOWER_KEY_TCP_FLAGS_MASK,	/* be16 */
 
+	TCA_FLOWER_KEY_IP_TOS,		/* u8 */
+	TCA_FLOWER_KEY_IP_TOS_MASK,	/* u8 */
+	TCA_FLOWER_KEY_IP_TTL,		/* u8 */
+	TCA_FLOWER_KEY_IP_TTL_MASK,	/* u8 */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index fb74a47..33feaee 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -50,6 +50,7 @@ struct fl_flow_key {
 	struct flow_dissector_key_ports enc_tp;
 	struct flow_dissector_key_mpls mpls;
 	struct flow_dissector_key_tcp tcp;
+	struct flow_dissector_key_ip ip;
 } __aligned(BITS_PER_LONG / 8); /* Ensure that we can do comparisons as longs. */
 
 struct fl_flow_mask_range {
@@ -427,6 +428,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_MPLS_LABEL]	= { .type = NLA_U32 },
 	[TCA_FLOWER_KEY_TCP_FLAGS]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_TCP_FLAGS_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_IP_TOS]		= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_IP_TOS_MASK]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_IP_TTL]		= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_IP_TTL_MASK]	= { .type = NLA_U8 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -528,6 +533,19 @@ static int fl_set_key_flags(struct nlattr **tb,
 	return 0;
 }
 
+static void fl_set_key_ip(struct nlattr **tb,
+			  struct flow_dissector_key_ip *key,
+			  struct flow_dissector_key_ip *mask)
+{
+		fl_set_key_val(tb, &key->tos, TCA_FLOWER_KEY_IP_TOS,
+			       &mask->tos, TCA_FLOWER_KEY_IP_TOS_MASK,
+			       sizeof(key->tos));
+
+		fl_set_key_val(tb, &key->ttl, TCA_FLOWER_KEY_IP_TTL,
+			       &mask->ttl, TCA_FLOWER_KEY_IP_TTL_MASK,
+			       sizeof(key->ttl));
+}
+
 static int fl_set_key(struct net *net, struct nlattr **tb,
 		      struct fl_flow_key *key, struct fl_flow_key *mask)
 {
@@ -570,6 +588,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		fl_set_key_val(tb, &key->basic.ip_proto, TCA_FLOWER_KEY_IP_PROTO,
 			       &mask->basic.ip_proto, TCA_FLOWER_UNSPEC,
 			       sizeof(key->basic.ip_proto));
+		fl_set_key_ip(tb, &key->ip, &mask->ip);
 	}
 
 	if (tb[TCA_FLOWER_KEY_IPV4_SRC] || tb[TCA_FLOWER_KEY_IPV4_DST]) {
@@ -773,6 +792,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_IP, ip);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_TCP, tcp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ICMP, icmp);
@@ -1082,6 +1103,19 @@ static int fl_dump_key_mpls(struct sk_buff *skb,
 	return 0;
 }
 
+static int fl_dump_key_ip(struct sk_buff *skb,
+			  struct flow_dissector_key_ip *key,
+			  struct flow_dissector_key_ip *mask)
+{
+	if (fl_dump_key_val(skb, &key->tos, TCA_FLOWER_KEY_IP_TOS, &mask->tos,
+			    TCA_FLOWER_KEY_IP_TOS_MASK, sizeof(key->tos)) ||
+	    fl_dump_key_val(skb, &key->ttl, TCA_FLOWER_KEY_IP_TTL, &mask->ttl,
+			    TCA_FLOWER_KEY_IP_TTL_MASK, sizeof(key->ttl)))
+		return -1;
+
+	return 0;
+}
+
 static int fl_dump_key_vlan(struct sk_buff *skb,
 			    struct flow_dissector_key_vlan *vlan_key,
 			    struct flow_dissector_key_vlan *vlan_mask)
@@ -1195,9 +1229,10 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if ((key->basic.n_proto == htons(ETH_P_IP) ||
 	     key->basic.n_proto == htons(ETH_P_IPV6)) &&
-	    fl_dump_key_val(skb, &key->basic.ip_proto, TCA_FLOWER_KEY_IP_PROTO,
+	    (fl_dump_key_val(skb, &key->basic.ip_proto, TCA_FLOWER_KEY_IP_PROTO,
 			    &mask->basic.ip_proto, TCA_FLOWER_UNSPEC,
-			    sizeof(key->basic.ip_proto)))
+			    sizeof(key->basic.ip_proto)) ||
+	    fl_dump_key_ip(skb, &key->ip, &mask->ip)))
 		goto nla_put_failure;
 
 	if (key->control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
-- 
2.3.7
