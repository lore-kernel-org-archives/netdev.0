From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next] mpls: Infer payload of packet from via address family.
Date: Wed, 11 Mar 2015 12:58:22 +0000
Message-ID: <1426078702-23246-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:3165 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752301AbbCKM6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 08:58:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures that if a routing protocol incorrectly advertises a label
for a prefix whose address-family is inconsistent with that of the
nexthop, then the traffic will be dropped, rather than the issue being
silently worked around.

The accessible skb length should also be validated prior to the IPv4
or IPv6 headers being accessed, since only the label header will have
previously been validated.

Rename mpls_egress to mpls_egress_to_ip to make it more obvious that
the function is used for traffic going out as IP, not for labeled
traffic (or for the not-yet-implemented pseudo-wires).

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 91 ++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 68 insertions(+), 23 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0ad8f7141..d1074b8 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -81,35 +81,81 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 	return true;
 }
 
-static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
-			struct mpls_entry_decoded dec)
+static int mpls_pkt_determine_af(struct sk_buff *skb)
 {
-	/* RFC4385 and RFC5586 encode other packets in mpls such that
-	 * they don't conflict with the ip version number, making
-	 * decoding by examining the ip version correct in everything
-	 * except for the strangest cases.
-	 *
-	 * The strange cases if we choose to support them will require
-	 * manual configuration.
+	if (!pskb_may_pull(skb, sizeof(struct iphdr))) {
+		return AF_PACKET;
+	}
+
+	/* At the moment, this is only used at the end of the LSP when
+	 * the payload is expected to be IP. More comprehensive checks
+	 * will be required if this is to be used where pseudo-wire
+	 * traffic not using RFC4385/RFC5586 encap could be present.
 	 */
-	struct iphdr *hdr4 = ip_hdr(skb);
+
+	switch (ip_hdr(skb)->version) {
+	case 4:
+		return AF_INET;
+	case 6:
+		return AF_INET6;
+	default:
+		return AF_PACKET;
+	}
+}
+
+static bool mpls_egress_to_ip(struct mpls_route *rt, struct sk_buff *skb,
+			struct mpls_entry_decoded dec)
+{
 	bool success = true;
+	int af;
+
+	switch (rt->rt_via_table) {
+	case NEIGH_ARP_TABLE:
+		af = AF_INET;
+		break;
+	case NEIGH_ND_TABLE:
+		af = AF_INET6;
+		break;
+	case NEIGH_LINK_TABLE:
+		af = mpls_pkt_determine_af(skb);
+		break;
+	default:
+		/* Unexpected rt_via_table value */
+		WARN_ON(true);
+		af = AF_PACKET;
+		break;
+	}
 
-	if (hdr4->version == 4) {
-		skb->protocol = htons(ETH_P_IP);
-		csum_replace2(&hdr4->check,
-			      htons(hdr4->ttl << 8),
-			      htons(dec.ttl << 8));
-		hdr4->ttl = dec.ttl;
+	switch (af) {
+	case AF_INET: {
+		struct iphdr *hdr4 = ip_hdr(skb);
+		if (pskb_may_pull(skb, sizeof(struct iphdr)) &&
+			hdr4->version == 4) {
+			skb->protocol = htons(ETH_P_IP);
+			csum_replace2(&hdr4->check,
+				htons(hdr4->ttl << 8),
+				htons(dec.ttl << 8));
+			hdr4->ttl = dec.ttl;
+		} else {
+			success = false;
+		}
+		break;
 	}
-	else if (hdr4->version == 6) {
+	case AF_INET6: {
 		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
-		skb->protocol = htons(ETH_P_IPV6);
-		hdr6->hop_limit = dec.ttl;
+		if (pskb_may_pull(skb, sizeof(struct ipv6hdr)) &&
+			hdr6->version == 6) {
+			skb->protocol = htons(ETH_P_IPV6);
+			hdr6->hop_limit = dec.ttl;
+		} else {
+			success = false;
+		}
+		break;
 	}
-	else
-		/* version 0 and version 1 are used by pseudo wires */
+	default:
 		success = false;
+		break;
+	}
 	return success;
 }
 
@@ -184,8 +230,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	skb->protocol = htons(ETH_P_MPLS_UC);
 
 	if (unlikely(!new_header_size && dec.bos)) {
-		/* Penultimate hop popping */
-		if (!mpls_egress(rt, skb, dec))
+		if (!mpls_egress_to_ip(rt, skb, dec))
 			goto drop;
 	} else {
 		bool bos;
-- 
2.1.4
