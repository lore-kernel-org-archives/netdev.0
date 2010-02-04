From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 3/4] bond: support more Layer 4 protocols
Date: Thu, 04 Feb 2010 09:11:21 -0800
Message-ID: <20100204171241.393163298@vyatta.com>
References: <20100204171118.917737392@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45533 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771Ab0BDRQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 12:16:19 -0500
Content-Disposition: inline; filename=bond-more-proto.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several protocols similar to TCP and UDP which share common L4
header format. Since proto is only one byte, use a map rather than big
conditonal.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2010-02-04 09:08:00.447069200 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-02-04 09:08:42.545818691 -0800
@@ -3621,6 +3621,16 @@ static u16 bond_xmit_hash_policy_l23(con
 	}
 }
 
+/* Map of protocols with standard ports available to include in hash */
+static const bool has_layer4[256] = {
+	[IPPROTO_TCP] = 1,
+	[IPPROTO_UDP] = 1,
+	[IPPROTO_UDPLITE] = 1,
+	[IPPROTO_SCTP] = 1,
+	[IPPROTO_DCCP] = 1,
+	[IPPROTO_ESP] = 1,
+};
+
 /*
  * Hash for the output device based upon layer 3 and layer 4 data. If
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
@@ -3634,11 +3644,10 @@ static u16 bond_xmit_hash_policy_l34(con
 		const struct iphdr *iph = ip_hdr(skb);
 		const __be16 *layer4hdr
 			= ((const void *)iph + iph->ihl);
-		u32 layer4_xor = 0;
+		u16 layer4_xor = 0;
 
 		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
-		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP))
+		    has_layer4[iph->protocol])
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
 
 		return layer4_xor ^ ntohl(iph->saddr ^ iph->daddr);
@@ -3647,10 +3656,9 @@ static u16 bond_xmit_hash_policy_l34(con
 	{
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
 		const __be16 *layer4hdr = (const __be16 *) (iph + 1);
-		u32 layer4_xor = 0;
+		u16 layer4_xor = 0;
 
-		if (iph->nexthdr == IPPROTO_TCP ||
-		     iph->nexthdr == IPPROTO_UDP)
+		if (has_layer4[iph->nexthdr])
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
 
 		return layer4_xor ^

-- 

