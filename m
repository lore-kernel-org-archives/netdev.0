From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 2/4] bond: add IPV6 layer3 hash policy support
Date: Thu, 04 Feb 2010 09:11:20 -0800
Message-ID: <20100204171241.319788071@vyatta.com>
References: <20100204171118.917737392@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45531 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0BDRQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 12:16:15 -0500
Content-Disposition: inline; filename=bond-ipv6.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add IPV6 support to Layer 3 and Layer 3+4 hash policies.
Code take fron SFQ.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2010-02-04 08:58:54.617692952 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-02-04 09:08:00.447069200 -0800
@@ -3601,13 +3601,24 @@ static u16 bond_xmit_hash_policy_l23(con
 {
 	const struct ethhdr *data = eth_hdr(skb);
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+	{
 		const struct iphdr *iph = ip_hdr(skb);
 		return ntohl(iph->saddr ^ iph->daddr) ^
 			(data->h_dest[5] ^ data->h_source[5]);
 	}
+	case htons(ETH_P_IPV6):
+	{
+		const struct ipv6hdr *iph = ipv6_hdr(skb);
+		return ntohl(iph->saddr.s6_addr32[3] ^
+			     iph->daddr.s6_addr32[3]) ^
+			(data->h_dest[5] ^ data->h_source[5]);
 
-	return bond_xmit_hash_policy_l2(skb);
+	}
+	default:
+		return bond_xmit_hash_policy_l2(skb);
+	}
 }
 
 /*
@@ -3617,9 +3628,9 @@ static u16 bond_xmit_hash_policy_l23(con
  */
 static u16 bond_xmit_hash_policy_l34(const struct sk_buff *skb)
 {
-	const struct ethhdr *data = eth_hdr(skb);
-
-	if (skb->protocol == htons(ETH_P_IP)) {
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+	{
 		const struct iphdr *iph = ip_hdr(skb);
 		const __be16 *layer4hdr
 			= ((const void *)iph + iph->ihl);
@@ -3627,14 +3638,28 @@ static u16 bond_xmit_hash_policy_l34(con
 
 		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP)) {
+		     iph->protocol == IPPROTO_UDP))
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
-		}
+
 		return layer4_xor ^ ntohl(iph->saddr ^ iph->daddr);
+	}
+	case htons(ETH_P_IPV6):
+	{
+		const struct ipv6hdr *iph = ipv6_hdr(skb);
+		const __be16 *layer4hdr = (const __be16 *) (iph + 1);
+		u32 layer4_xor = 0;
 
+		if (iph->nexthdr == IPPROTO_TCP ||
+		     iph->nexthdr == IPPROTO_UDP)
+			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
+
+		return layer4_xor ^
+			ntohl(iph->saddr.s6_addr32[3] ^ iph->daddr.s6_addr32[3]);
+	}
+	default:
+		return bond_xmit_hash_policy_l2(skb);
 	}
 
-	return bond_xmit_hash_policy_l2(skb);
 }
 
 

-- 

