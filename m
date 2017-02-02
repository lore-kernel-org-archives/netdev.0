From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Thu,  2 Feb 2017 11:37:34 +0100
Message-ID: <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34413 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdBBKhp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:37:45 -0500
Received: by mail-wm0-f46.google.com with SMTP id 196so4010613wmm.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:37:45 -0800 (PST)
In-Reply-To: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow dissection of Neighbour Discovery target IP, and source and
destination link-layer addresses for neighbour solicitation and
advertisement messages.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/flow_dissector.h | 14 ++++++++
 net/core/flow_dissector.c    | 83 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 96 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index ac9703018a3a..b62e6484dd6b 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -140,6 +140,19 @@ struct flow_dissector_key_icmp {
 };
 
 /**
+ * flow_dissector_key_nd:
+ *	@ports: neighbour discovery fields
+ *		target: target IP address
+ *		sll: source link-layer address
+ *		tll: target link-layer address
+ */
+struct flow_dissector_key_nd {
+	struct in6_addr target;
+	unsigned char sll[ETH_ALEN];
+	unsigned char tll[ETH_ALEN];
+};
+
+/**
  * struct flow_dissector_key_eth_addrs:
  * @src: source Ethernet address
  * @dst: destination Ethernet address
@@ -157,6 +170,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_ICMP, /* struct flow_dissector_key_icmp */
+	FLOW_DISSECTOR_KEY_ND, /* struct flow_dissector_key_nd */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 	FLOW_DISSECTOR_KEY_ARP, /* struct flow_dissector_key_arp */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c35aae13c8d2..745e03f180d0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -113,6 +113,68 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
+static bool skb_flow_dissect_nd(const struct sk_buff *skb,
+				struct flow_dissector_key_nd *key_nd,
+				void *data, int nhoff, int hlen,
+				int icmp_len)
+{
+	const struct nd_msg *nd;
+	struct nd_msg *_nd;
+	int off;
+
+	nd = __skb_header_pointer(skb, nhoff, sizeof(_nd), data, hlen, &_nd);
+	if (!nd)
+		return false;
+
+	key_nd->target = nd->target;
+
+	off = sizeof(_nd);
+	while (icmp_len - off >= sizeof(struct nd_opt_hdr) + ETH_ALEN) {
+		const struct nd_opt_hdr *opt_hdr;
+		struct nd_opt_hdr *_opt_hdr;
+		unsigned char *ll_addr = NULL;
+		int opt_data_len;
+
+		opt_hdr = __skb_header_pointer(skb, nhoff + off,
+					       sizeof(_opt_hdr), data,
+					       hlen, &_opt_hdr);
+		if (!opt_hdr)
+			return false;
+		opt_data_len = opt_hdr->nd_opt_len * 8 - sizeof(_opt_hdr);
+		if (opt_data_len < 0)
+			return false;
+		off += sizeof(_opt_hdr);
+
+		if (opt_data_len == ETH_ALEN) {
+			if (opt_hdr->nd_opt_type == ND_OPT_SOURCE_LL_ADDR)
+				ll_addr = key_nd->sll;
+			else if (opt_hdr->nd_opt_type == ND_OPT_TARGET_LL_ADDR)
+				ll_addr = key_nd->tll;
+		}
+
+		if (ll_addr) {
+			const unsigned char *opt_data;
+			unsigned char _opt_data[ETH_ALEN];
+
+			/* Fail if the option is a duplicate */
+			if (!is_zero_ether_addr(ll_addr))
+				return false;
+
+			opt_data = __skb_header_pointer(skb, nhoff + off,
+							opt_data_len, data,
+							hlen, &_opt_data);
+			if (!opt_data)
+				return false;
+
+			ether_addr_copy(ll_addr, opt_data);
+		}
+
+		off += opt_data_len;
+	}
+
+	return true;
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -141,9 +203,11 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_arp *key_arp;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_icmp *key_icmp;
+	struct flow_dissector_key_nd *key_nd;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
 	struct flow_dissector_key_keyid *key_keyid;
+	int ipv6_payload_len = 0;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
 	bool ret;
@@ -232,6 +296,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			goto out_bad;
 
 		ip_proto = iph->nexthdr;
+		ipv6_payload_len = ntohs(iph->payload_len);
 		nhoff += sizeof(struct ipv6hdr);
 
 		if (dissector_uses_key(flow_dissector,
@@ -556,6 +621,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
 	case NEXTHDR_DEST: {
+		int hdr_ext_len;
 		u8 _opthdr[2], *opthdr;
 
 		if (proto != htons(ETH_P_IPV6))
@@ -567,7 +633,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			goto out_bad;
 
 		ip_proto = opthdr[0];
-		nhoff += (opthdr[1] + 1) << 3;
+		hdr_ext_len = (opthdr[1] + 1) << 3;
+		nhoff += hdr_ext_len;
+		ipv6_payload_len -= hdr_ext_len;
 
 		goto ip_proto_again;
 	}
@@ -586,6 +654,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
 		nhoff += sizeof(_fh);
+		ipv6_payload_len -= sizeof(_fh);
 		ip_proto = fh->nexthdr;
 
 		if (!(fh->frag_off & htons(IP6_OFFSET))) {
@@ -633,6 +702,18 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 						     FLOW_DISSECTOR_KEY_ICMP,
 						     target_container);
 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
+
+		if (dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ND) &&
+		    ip_proto == IPPROTO_IPV6 && key_icmp->code == 0 &&
+		    (key_icmp->type == NDISC_NEIGHBOUR_SOLICITATION ||
+		     key_icmp->type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
+			key_nd = skb_flow_dissector_target(flow_dissector,
+							   FLOW_DISSECTOR_KEY_ND,
+							   target_container);
+			if (!(skb_flow_dissect_nd(skb, key_nd, data, nhoff,
+						  hlen, ipv6_payload_len)))
+				goto out_bad;
+		}
 	}
 
 out_good:
-- 
2.7.0.rc3.207.g0ac5344
