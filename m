From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/2] flow_dissecror: Move ARP dissection into a separate function
Date: Tue, 21 Feb 2017 15:33:18 +0100
Message-ID: <1487687599-5464-1-git-send-email-jiri@resnulli.us>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34742 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbdBUOdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:33:23 -0500
Received: by mail-wr0-f196.google.com with SMTP id 89so8782327wrr.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 06:33:22 -0800 (PST)
In-Reply-To: <20170221143141.GD2694@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the main flow_dissect function a bit smaller and move the ARP
dissection into a separate function. Along with that, do the ARP header
processing only in case the flow dissection user requires it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 111 ++++++++++++++++++++++++----------------------
 1 file changed, 59 insertions(+), 52 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c35aae1..10dc5bb 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -113,6 +113,61 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
+static bool __skb_flow_dissect_arp(const struct sk_buff *skb,
+				   struct flow_dissector *flow_dissector,
+				   void *target_container, void *data,
+				   int nhoff, int hlen)
+{
+	struct flow_dissector_key_arp *key_arp;
+	struct {
+		unsigned char ar_sha[ETH_ALEN];
+		unsigned char ar_sip[4];
+		unsigned char ar_tha[ETH_ALEN];
+		unsigned char ar_tip[4];
+	} *arp_eth, _arp_eth;
+	const struct arphdr *arp;
+	struct arphdr *_arp;
+
+	if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ARP))
+		return true;
+
+	arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
+				   hlen, &_arp);
+	if (!arp)
+		return false;
+
+	if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
+	    arp->ar_pro != htons(ETH_P_IP) ||
+	    arp->ar_hln != ETH_ALEN ||
+	    arp->ar_pln != 4 ||
+	    (arp->ar_op != htons(ARPOP_REPLY) &&
+	     arp->ar_op != htons(ARPOP_REQUEST)))
+		return false;
+
+	arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
+				       sizeof(_arp_eth), data,
+				       hlen, &_arp_eth);
+	if (!arp_eth)
+		return false;
+
+	key_arp = skb_flow_dissector_target(flow_dissector,
+					    FLOW_DISSECTOR_KEY_ARP,
+					    target_container);
+
+	memcpy(&key_arp->sip, arp_eth->ar_sip, sizeof(key_arp->sip));
+	memcpy(&key_arp->tip, arp_eth->ar_tip, sizeof(key_arp->tip));
+
+	/* Only store the lower byte of the opcode;
+	 * this covers ARPOP_REPLY and ARPOP_REQUEST.
+	 */
+	key_arp->op = ntohs(arp->ar_op) & 0xff;
+
+	ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
+	ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
+
+	return true;
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -138,7 +193,6 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_control *key_control;
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
-	struct flow_dissector_key_arp *key_arp;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
@@ -382,59 +436,12 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		goto out_good;
 
 	case htons(ETH_P_ARP):
-	case htons(ETH_P_RARP): {
-		struct {
-			unsigned char ar_sha[ETH_ALEN];
-			unsigned char ar_sip[4];
-			unsigned char ar_tha[ETH_ALEN];
-			unsigned char ar_tip[4];
-		} *arp_eth, _arp_eth;
-		const struct arphdr *arp;
-		struct arphdr *_arp;
-
-		arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
-					   hlen, &_arp);
-		if (!arp)
-			goto out_bad;
-
-		if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
-		    arp->ar_pro != htons(ETH_P_IP) ||
-		    arp->ar_hln != ETH_ALEN ||
-		    arp->ar_pln != 4 ||
-		    (arp->ar_op != htons(ARPOP_REPLY) &&
-		     arp->ar_op != htons(ARPOP_REQUEST)))
+	case htons(ETH_P_RARP):
+		if (!__skb_flow_dissect_arp(skb, flow_dissector,
+					    target_container, data,
+					    nhoff, hlen))
 			goto out_bad;
-
-		arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
-					       sizeof(_arp_eth), data,
-					       hlen,
-					       &_arp_eth);
-		if (!arp_eth)
-			goto out_bad;
-
-		if (dissector_uses_key(flow_dissector,
-				       FLOW_DISSECTOR_KEY_ARP)) {
-
-			key_arp = skb_flow_dissector_target(flow_dissector,
-							    FLOW_DISSECTOR_KEY_ARP,
-							    target_container);
-
-			memcpy(&key_arp->sip, arp_eth->ar_sip,
-			       sizeof(key_arp->sip));
-			memcpy(&key_arp->tip, arp_eth->ar_tip,
-			       sizeof(key_arp->tip));
-
-			/* Only store the lower byte of the opcode;
-			 * this covers ARPOP_REPLY and ARPOP_REQUEST.
-			 */
-			key_arp->op = ntohs(arp->ar_op) & 0xff;
-
-			ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
-			ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
-		}
-
 		goto out_good;
-	}
 
 	default:
 		goto out_bad;
-- 
2.7.4
