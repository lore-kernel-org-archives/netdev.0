From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 1/2] flow_dissector: Cleanup control flow
Date: Fri,  1 Sep 2017 14:04:11 -0700
Message-ID: <20170901210412.2915-2-tom@quantonium.net>
References: <20170901210412.2915-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        alex.popov@linux.com, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36034 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752416AbdIAVEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 17:04:47 -0400
Received: by mail-pg0-f47.google.com with SMTP id r133so3613700pgr.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 14:04:46 -0700 (PDT)
In-Reply-To: <20170901210412.2915-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__skb_flow_dissect is riddled with gotos that make discerning the flow,
debugging, and extending the capability difficult. This patch
reorganizes things so that we only perform goto's after the two main
switch statements (no gotos within the cases now). It also eliminates
several goto labels so that there are only two labels that can be target
for goto.

Reported-by: Alexander Popov <alex.popov@linux.com>
Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/flow_dissector.h |   8 ++
 net/core/flow_dissector.c    | 223 ++++++++++++++++++++++++++++---------------
 2 files changed, 153 insertions(+), 78 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index e2663e900b0a..fc3dce730a6b 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -19,6 +19,14 @@ struct flow_dissector_key_control {
 #define FLOW_DIS_FIRST_FRAG	BIT(1)
 #define FLOW_DIS_ENCAPSULATION	BIT(2)
 
+enum flow_dissect_ret {
+	FLOW_DISSECT_RET_OUT_GOOD,
+	FLOW_DISSECT_RET_OUT_BAD,
+	FLOW_DISSECT_RET_PROTO_AGAIN,
+	FLOW_DISSECT_RET_IPPROTO_AGAIN,
+	FLOW_DISSECT_RET_CONTINUE,
+};
+
 /**
  * struct flow_dissector_key_basic:
  * @thoff: Transport header offset
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e2eaa1ff948d..e0ea17d1c7fc 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -115,12 +115,6 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
-enum flow_dissect_ret {
-	FLOW_DISSECT_RET_OUT_GOOD,
-	FLOW_DISSECT_RET_OUT_BAD,
-	FLOW_DISSECT_RET_OUT_PROTO_AGAIN,
-};
-
 static enum flow_dissect_ret
 __skb_flow_dissect_mpls(const struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
@@ -341,7 +335,7 @@ __skb_flow_dissect_gre(const struct sk_buff *skb,
 	if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 		return FLOW_DISSECT_RET_OUT_GOOD;
 
-	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
+	return FLOW_DISSECT_RET_PROTO_AGAIN;
 }
 
 static void
@@ -431,6 +425,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
+	enum flow_dissect_ret fdret;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
 	bool ret;
@@ -482,14 +477,19 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	}
 
 proto_again:
+	fdret = FLOW_DISSECT_RET_CONTINUE;
+
 	switch (proto) {
 	case htons(ETH_P_IP): {
 		const struct iphdr *iph;
 		struct iphdr _iph;
-ip:
+
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
-		if (!iph || iph->ihl < 5)
-			goto out_bad;
+		if (!iph || iph->ihl < 5) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
+
 		nhoff += iph->ihl * 4;
 
 		ip_proto = iph->protocol;
@@ -509,19 +509,25 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
 			if (iph->frag_off & htons(IP_OFFSET)) {
-				goto out_good;
+				fdret = FLOW_DISSECT_RET_OUT_GOOD;
+				break;
 			} else {
 				key_control->flags |= FLOW_DIS_FIRST_FRAG;
-				if (!(flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG))
-					goto out_good;
+				if (!(flags &
+				      FLOW_DISSECTOR_F_PARSE_1ST_FRAG)) {
+					fdret = FLOW_DISSECT_RET_OUT_GOOD;
+					break;
+				}
 			}
 		}
 
 		__skb_flow_dissect_ipv4(skb, flow_dissector,
 					target_container, data, iph);
 
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
-			goto out_good;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3) {
+			fdret = FLOW_DISSECT_RET_OUT_GOOD;
+			break;
+		}
 
 		break;
 	}
@@ -529,10 +535,11 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
 
-ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
-		if (!iph)
-			goto out_bad;
+		if (!iph) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
 
 		ip_proto = iph->nexthdr;
 		nhoff += sizeof(struct ipv6hdr);
@@ -561,15 +568,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 								     target_container);
 				key_tags->flow_label = ntohl(flow_label);
 			}
-			if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)
-				goto out_good;
+			if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL) {
+				fdret = FLOW_DISSECT_RET_OUT_GOOD;
+				break;
+			}
 		}
 
 		__skb_flow_dissect_ipv6(skb, flow_dissector,
 					target_container, data, iph);
 
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
-			goto out_good;
+			fdret = FLOW_DISSECT_RET_OUT_GOOD;
 
 		break;
 	}
@@ -585,12 +594,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (!vlan_tag_present || eth_type_vlan(skb->protocol)) {
 			vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan),
 						    data, hlen, &_vlan);
-			if (!vlan)
-				goto out_bad;
+			if (!vlan) {
+				fdret = FLOW_DISSECT_RET_OUT_BAD;
+				break;
+			}
+
 			proto = vlan->h_vlan_encapsulated_proto;
 			nhoff += sizeof(*vlan);
-			if (skip_vlan)
-				goto proto_again;
+			if (skip_vlan) {
+				fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+				break;
+			}
 		}
 
 		skip_vlan = true;
@@ -613,7 +627,8 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			}
 		}
 
-		goto proto_again;
+		fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+		break;
 	}
 	case htons(ETH_P_PPP_SES): {
 		struct {
@@ -621,18 +636,27 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			__be16 proto;
 		} *hdr, _hdr;
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
-		if (!hdr)
-			goto out_bad;
+		if (!hdr) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
+
 		proto = hdr->proto;
 		nhoff += PPPOE_SES_HLEN;
 		switch (proto) {
 		case htons(PPP_IP):
-			goto ip;
+			proto = htons(ETH_P_IP);
+			fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+			break;
 		case htons(PPP_IPV6):
-			goto ipv6;
+			proto = htons(ETH_P_IPV6);
+			fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+			break;
 		default:
-			goto out_bad;
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
 		}
+		break;
 	}
 	case htons(ETH_P_TIPC): {
 		struct {
@@ -640,8 +664,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			__be32 srcnode;
 		} *hdr, _hdr;
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
-		if (!hdr)
-			goto out_bad;
+		if (!hdr) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
 
 		if (dissector_uses_key(flow_dissector,
 				       FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
@@ -651,56 +677,62 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			key_addrs->tipcaddrs.srcnode = hdr->srcnode;
 			key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;
 		}
-		goto out_good;
+		fdret = FLOW_DISSECT_RET_OUT_GOOD;
+		break;
 	}
 
 	case htons(ETH_P_MPLS_UC):
 	case htons(ETH_P_MPLS_MC):
-mpls:
-		switch (__skb_flow_dissect_mpls(skb, flow_dissector,
+		fdret = __skb_flow_dissect_mpls(skb, flow_dissector,
 						target_container, data,
-						nhoff, hlen)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-		default:
-			goto out_bad;
-		}
+						nhoff, hlen);
+		break;
 	case htons(ETH_P_FCOE):
-		if ((hlen - nhoff) < FCOE_HEADER_LEN)
-			goto out_bad;
+		if ((hlen - nhoff) < FCOE_HEADER_LEN) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
 
 		nhoff += FCOE_HEADER_LEN;
-		goto out_good;
+		fdret = FLOW_DISSECT_RET_OUT_GOOD;
+		break;
 
 	case htons(ETH_P_ARP):
 	case htons(ETH_P_RARP):
-		switch (__skb_flow_dissect_arp(skb, flow_dissector,
+		fdret = __skb_flow_dissect_arp(skb, flow_dissector,
 					       target_container, data,
-					       nhoff, hlen)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-		default:
-			goto out_bad;
-		}
+					       nhoff, hlen);
+		break;
+
+	default:
+		fdret = FLOW_DISSECT_RET_OUT_BAD;
+		break;
+	}
+
+	/* Process result of proto processing */
+	switch (fdret) {
+	case FLOW_DISSECT_RET_OUT_GOOD:
+		goto out_good;
+	case FLOW_DISSECT_RET_PROTO_AGAIN:
+		goto proto_again;
+	case FLOW_DISSECT_RET_CONTINUE:
+	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
+		break;
+	case FLOW_DISSECT_RET_OUT_BAD:
 	default:
 		goto out_bad;
 	}
 
 ip_proto_again:
+	fdret = FLOW_DISSECT_RET_CONTINUE;
+
 	switch (ip_proto) {
 	case IPPROTO_GRE:
-		switch (__skb_flow_dissect_gre(skb, key_control, flow_dissector,
+		fdret = __skb_flow_dissect_gre(skb, key_control, flow_dissector,
 					       target_container, data,
-					       &proto, &nhoff, &hlen, flags)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-			goto out_bad;
-		case FLOW_DISSECT_RET_OUT_PROTO_AGAIN:
-			goto proto_again;
-		}
+					       &proto, &nhoff, &hlen, flags);
+		break;
+
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
 	case NEXTHDR_DEST: {
@@ -711,13 +743,16 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
 					      data, hlen, &_opthdr);
-		if (!opthdr)
-			goto out_bad;
+		if (!opthdr) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
 
 		ip_proto = opthdr[0];
 		nhoff += (opthdr[1] + 1) << 3;
 
-		goto ip_proto_again;
+		fdret = FLOW_DISSECT_RET_IPPROTO_AGAIN;
+		break;
 	}
 	case NEXTHDR_FRAGMENT: {
 		struct frag_hdr _fh, *fh;
@@ -728,8 +763,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		fh = __skb_header_pointer(skb, nhoff, sizeof(_fh),
 					  data, hlen, &_fh);
 
-		if (!fh)
-			goto out_bad;
+		if (!fh) {
+			fdret = FLOW_DISSECT_RET_OUT_BAD;
+			break;
+		}
 
 		key_control->flags |= FLOW_DIS_IS_FRAGMENT;
 
@@ -738,34 +775,50 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		if (!(fh->frag_off & htons(IP6_OFFSET))) {
 			key_control->flags |= FLOW_DIS_FIRST_FRAG;
-			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG)
-				goto ip_proto_again;
+			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG) {
+				fdret = FLOW_DISSECT_RET_IPPROTO_AGAIN;
+				break;
+			}
 		}
-		goto out_good;
+
+		fdret = FLOW_DISSECT_RET_OUT_GOOD;
+		break;
 	}
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 
 		key_control->flags |= FLOW_DIS_ENCAPSULATION;
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
-			goto out_good;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP) {
+			fdret = FLOW_DISSECT_RET_OUT_GOOD;
+			break;
+		}
+
+		fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+		break;
 
-		goto ip;
 	case IPPROTO_IPV6:
 		proto = htons(ETH_P_IPV6);
 
 		key_control->flags |= FLOW_DIS_ENCAPSULATION;
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
-			goto out_good;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP) {
+			fdret = FLOW_DISSECT_RET_OUT_GOOD;
+			break;
+		}
+
+		fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+		break;
+
 
-		goto ipv6;
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
-		goto mpls;
+		fdret = FLOW_DISSECT_RET_PROTO_AGAIN;
+		break;
+
 	case IPPROTO_TCP:
 		__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
 				       data, nhoff, hlen);
 		break;
+
 	default:
 		break;
 	}
@@ -787,6 +840,20 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data, hlen);
 	}
 
+	/* Process result of IP proto processing */
+	switch (fdret) {
+	case FLOW_DISSECT_RET_PROTO_AGAIN:
+		goto proto_again;
+	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
+		goto ip_proto_again;
+	case FLOW_DISSECT_RET_OUT_GOOD:
+	case FLOW_DISSECT_RET_CONTINUE:
+		break;
+	case FLOW_DISSECT_RET_OUT_BAD:
+	default:
+		goto out_bad;
+	}
+
 out_good:
 	ret = true;
 
-- 
2.11.0
