From: fgao@ikuai8.com
Subject: [PATCH 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Thu, 28 Jul 2016 15:14:41 +0800
Message-ID: <1469690081-32122-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, philipp@redfish-solutions.com,
	stephen@networkplumber.org, pshelar@nicira.com,
	tom@herbertland.com, aduyck@mirantis.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG179.QQ.COM ([119.147.194.222]:54599 "EHLO
	smtpbg179.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1163139AbcG1HYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 03:24:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The PPTP is encapsulated by GRE header with that GRE_VERSION bits
must contain one. But current GRE RPS needs the GRE_VERSION must be
zero. So RPS does not work for PPTP traffic.

In my test environment, there are four MIPS cores, and all traffic
are passed through by PPTP. As a result, only one core is 100% busy
while other three cores are very idle. After this patch, the usage
of four cores are balanced well.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Update according to Tom and Philp's advice. 
     1) Consolidate the codes with GRE version 0 path;
     2) Use PPP_PROTOCOL to get ppp protol;
     3) Set the FLOW_DIS_ENCAPSULATION flag;
 v1: Initial patch 

 include/uapi/linux/if_tunnel.h |   5 +-
 net/core/flow_dissector.c      | 146 ++++++++++++++++++++++++++---------------
 2 files changed, 97 insertions(+), 54 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 1046f55..dda4e4b 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -24,9 +24,12 @@
 #define GRE_SEQ		__cpu_to_be16(0x1000)
 #define GRE_STRICT	__cpu_to_be16(0x0800)
 #define GRE_REC		__cpu_to_be16(0x0700)
-#define GRE_FLAGS	__cpu_to_be16(0x00F8)
+#define GRE_ACK		__cpu_to_be16(0x0080)
+#define GRE_FLAGS	__cpu_to_be16(0x0078)
 #define GRE_VERSION	__cpu_to_be16(0x0007)
 
+#define GRE_PROTO_PPP	__cpu_to_be16(0x880b)
+
 struct ip_tunnel_parm {
 	char			name[IFNAMSIZ];
 	int			link;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 61ad43f..33e957b 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -346,63 +346,103 @@ ip_proto_again:
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			goto out_bad;
-		/*
-		 * Only look inside GRE if version zero and no
-		 * routing
-		 */
-		if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
-			break;
-
-		proto = hdr->proto;
-		nhoff += 4;
-		if (hdr->flags & GRE_CSUM)
-			nhoff += 4;
-		if (hdr->flags & GRE_KEY) {
-			const __be32 *keyid;
-			__be32 _keyid;
-
-			keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
-						     data, hlen, &_keyid);
 
-			if (!keyid)
-				goto out_bad;
+		/* Only look inside GRE without routing */
+		if (!(hdr->flags & GRE_ROUTING)) {
+			proto = hdr->proto;
+
+			if (hdr->flags & GRE_VERSION) {
+				/* It should be the PPTP in GRE */
+				u8 _ppp_hdr[PPP_HDRLEN];
+				u8 *ppp_hdr;
+				int offset = 0;
+
+				/* Check the flags according to RFC 2637*/
+				if (!(proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY) &&
+				      !(hdr->flags & (GRE_CSUM | GRE_STRICT | GRE_REC | GRE_FLAGS)))) {
+					break;
+				}
+
+				/* Skip GRE header */
+				offset += 4;
+				/* Skip payload length and call id */
+				offset += 4;
+
+				if (hdr->flags & GRE_SEQ)
+					offset += 4;
+
+				if (hdr->flags & GRE_ACK)
+					offset += 4;
+
+				ppp_hdr = skb_header_pointer(skb, nhoff + offset, sizeof(_ppp_hdr), _ppp_hdr);
+				if (!ppp_hdr)
+					goto out_bad;
+				proto = PPP_PROTOCOL(ppp_hdr);
+				if (proto == PPP_IP) {
+					nhoff += (PPP_HDRLEN + offset);
+					proto = htons(ETH_P_IP);
+					key_control->flags |= FLOW_DIS_ENCAPSULATION;
+					goto again;
+				} else if (proto == PPP_IPV6) {
+					nhoff += (PPP_HDRLEN + offset);
+					proto = htons(ETH_P_IPV6);
+					key_control->flags |= FLOW_DIS_ENCAPSULATION;
+					goto again;
+				}
+			} else {
+				/* Original GRE */
+				nhoff += 4;
+				if (hdr->flags & GRE_CSUM)
+					nhoff += 4;
+				if (hdr->flags & GRE_KEY) {
+					const __be32 *keyid;
+					__be32 _keyid;
+
+					keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
+								     data, hlen, &_keyid);
+
+					if (!keyid)
+						goto out_bad;
+
+					if (dissector_uses_key(flow_dissector,
+							       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+						key_keyid = skb_flow_dissector_target(flow_dissector,
+										      FLOW_DISSECTOR_KEY_GRE_KEYID,
+										      target_container);
+						key_keyid->keyid = *keyid;
+					}
+					nhoff += 4;
+				}
+				if (hdr->flags & GRE_SEQ)
+					nhoff += 4;
+				if (proto == htons(ETH_P_TEB)) {
+					const struct ethhdr *eth;
+					struct ethhdr _eth;
+
+					eth = __skb_header_pointer(skb, nhoff,
+								   sizeof(_eth),
+								   data, hlen, &_eth);
+					if (!eth)
+						goto out_bad;
+					proto = eth->h_proto;
+					nhoff += sizeof(*eth);
+
+					/* Cap headers that we access via pointers at the
+					 * end of the Ethernet header as our maximum alignment
+					 * at that point is only 2 bytes.
+					 */
+					if (NET_IP_ALIGN)
+						hlen = nhoff;
+				}
+
+				key_control->flags |= FLOW_DIS_ENCAPSULATION;
+				if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+					goto out_good;
 
-			if (dissector_uses_key(flow_dissector,
-					       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
-				key_keyid = skb_flow_dissector_target(flow_dissector,
-								      FLOW_DISSECTOR_KEY_GRE_KEYID,
-								      target_container);
-				key_keyid->keyid = *keyid;
+				goto again;
 			}
-			nhoff += 4;
-		}
-		if (hdr->flags & GRE_SEQ)
-			nhoff += 4;
-		if (proto == htons(ETH_P_TEB)) {
-			const struct ethhdr *eth;
-			struct ethhdr _eth;
-
-			eth = __skb_header_pointer(skb, nhoff,
-						   sizeof(_eth),
-						   data, hlen, &_eth);
-			if (!eth)
-				goto out_bad;
-			proto = eth->h_proto;
-			nhoff += sizeof(*eth);
-
-			/* Cap headers that we access via pointers at the
-			 * end of the Ethernet header as our maximum alignment
-			 * at that point is only 2 bytes.
-			 */
-			if (NET_IP_ALIGN)
-				hlen = nhoff;
 		}
-
-		key_control->flags |= FLOW_DIS_ENCAPSULATION;
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
-			goto out_good;
-
-		goto again;
+		break;
 	}
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
-- 
1.9.1
