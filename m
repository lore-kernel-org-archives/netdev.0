From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 2/2] net/sched: cls_flower: Support matching on ND
Date: Thu,  2 Feb 2017 11:37:35 +0100
Message-ID: <1486031855-10551-3-git-send-email-simon.horman@netronome.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35066 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdBBKhr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:37:47 -0500
Received: by mail-wm0-f49.google.com with SMTP id b65so83784741wmf.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:37:46 -0800 (PST)
In-Reply-To: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow matching on Neighbour Discovery target IP, and source and
destination link-layer addresses for neighbour solicitation and
advertisement messages.

Sample usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 136 code 0 \
	nd_target 2001:470:7eb3:403:201:8eff:fe22:8fea \
	nd_tll 00:01:8e:22:8f:ea action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/pkt_cls.h |  7 +++++++
 net/core/flow_dissector.c    |  6 +++---
 net/sched/cls_flower.c       | 42 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 345551e71410..fc9e9bef726e 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -430,6 +430,13 @@ enum {
 	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
 	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
 
+	TCA_FLOWER_KEY_ND_TARGET,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ND_TARGET_MASK,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ND_SLL,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_SLL_MASK,	/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_TLL,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_TLL_MASK,	/* ETH_ALEN */
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 745e03f180d0..513193825268 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -119,7 +119,7 @@ static bool skb_flow_dissect_nd(const struct sk_buff *skb,
 				int icmp_len)
 {
 	const struct nd_msg *nd;
-	struct nd_msg *_nd;
+	struct nd_msg _nd;
 	int off;
 
 	nd = __skb_header_pointer(skb, nhoff, sizeof(_nd), data, hlen, &_nd);
@@ -131,7 +131,7 @@ static bool skb_flow_dissect_nd(const struct sk_buff *skb,
 	off = sizeof(_nd);
 	while (icmp_len - off >= sizeof(struct nd_opt_hdr) + ETH_ALEN) {
 		const struct nd_opt_hdr *opt_hdr;
-		struct nd_opt_hdr *_opt_hdr;
+		struct nd_opt_hdr _opt_hdr;
 		unsigned char *ll_addr = NULL;
 		int opt_data_len;
 
@@ -704,7 +704,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
 
 		if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) &&
-		    ip_proto == IPPROTO_IPV6 && key_icmp->code == 0 &&
+		    ip_proto == IPPROTO_ICMPV6 && key_icmp->code == 0 &&
 		    (key_icmp->type == NDISC_NEIGHBOUR_SOLICITATION ||
 		     key_icmp->type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
 			key_nd = skb_flow_dissector_target(flow_dissector,
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 23c4d224dcb1..49337091a015 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -40,6 +40,7 @@ struct fl_flow_key {
 	};
 	struct flow_dissector_key_ports tp;
 	struct flow_dissector_key_icmp icmp;
+	struct flow_dissector_key_nd nd;
 	struct flow_dissector_key_arp arp;
 	struct flow_dissector_key_keyid enc_key_id;
 	union {
@@ -418,6 +419,12 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ARP_SHA_MASK]	= { .len = ETH_ALEN },
 	[TCA_FLOWER_KEY_ARP_THA]	= { .len = ETH_ALEN },
 	[TCA_FLOWER_KEY_ARP_THA_MASK]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ND_TARGET]	= { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_ND_TARGET_MASK]	= { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_ND_SLL]		= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ND_SLL_MASK]	= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ND_TLL]		= { .len = ETH_ALEN },
+	[TCA_FLOWER_KEY_ND_TLL_MASK]	= { .len = ETH_ALEN },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -589,6 +596,22 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->icmp.code,
 			       TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
 			       sizeof(key->icmp.code));
+		if (key->icmp.code == 0 && mask->icmp.code == 0xff &&
+		    (key->icmp.type == NDISC_NEIGHBOUR_SOLICITATION ||
+		     key->icmp.type == NDISC_NEIGHBOUR_ADVERTISEMENT) &&
+		    mask->icmp.type == 0xff) {
+			fl_set_key_val(tb, &key->nd.target,
+				       TCA_FLOWER_KEY_ND_TARGET,
+				       &mask->nd.target,
+				       TCA_FLOWER_KEY_ND_TARGET_MASK,
+				       sizeof(key->nd.target));
+			fl_set_key_val(tb, key->nd.sll, TCA_FLOWER_KEY_ND_SLL,
+				       mask->nd.sll, TCA_FLOWER_KEY_ND_SLL_MASK,
+				       sizeof(key->nd.sll));
+			fl_set_key_val(tb, key->nd.tll, TCA_FLOWER_KEY_ND_TLL,
+				       mask->nd.tll, TCA_FLOWER_KEY_ND_TLL_MASK,
+				       sizeof(key->nd.tll));
+		}
 	} else if (key->basic.n_proto == htons(ETH_P_ARP) ||
 		   key->basic.n_proto == htons(ETH_P_RARP)) {
 		fl_set_key_val(tb, &key->arp.sip, TCA_FLOWER_KEY_ARP_SIP,
@@ -725,6 +748,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ARP, arp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ND, nd);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
@@ -1162,7 +1187,22 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		  fl_dump_key_val(skb, &key->icmp.code,
 				  TCA_FLOWER_KEY_ICMPV6_CODE, &mask->icmp.code,
 				  TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
-				  sizeof(key->icmp.code))))
+				  sizeof(key->icmp.code)) ||
+		 (key->icmp.code == 0 && mask->icmp.code == 0xff &&
+		  (key->icmp.type == NDISC_NEIGHBOUR_SOLICITATION ||
+		   key->icmp.type == NDISC_NEIGHBOUR_ADVERTISEMENT) &&
+		  mask->icmp.type == 0xff &&
+		  (fl_dump_key_val(skb, &key->nd.target,
+				   TCA_FLOWER_KEY_ND_TARGET,
+				   &mask->nd.target,
+				   TCA_FLOWER_KEY_ND_TARGET_MASK,
+				   sizeof(key->nd.target)) ||
+		   fl_dump_key_val(skb, key->nd.sll, TCA_FLOWER_KEY_ND_SLL,
+				   mask->nd.sll, TCA_FLOWER_KEY_ND_SLL_MASK,
+				   sizeof(key->nd.sll)) ||
+		   fl_dump_key_val(skb, key->nd.tll, TCA_FLOWER_KEY_ND_TLL,
+				   mask->nd.tll, TCA_FLOWER_KEY_ND_TLL_MASK,
+				   sizeof(key->nd.tll))))))
 		goto nla_put_failure;
 	else if ((key->basic.n_proto == htons(ETH_P_ARP) ||
 		  key->basic.n_proto == htons(ETH_P_RARP)) &&
-- 
2.7.0.rc3.207.g0ac5344
