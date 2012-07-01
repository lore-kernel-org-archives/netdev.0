From: John Eaglesham <linux@8192.net>
Subject: [PATCH v5] bonding support for IPv6 transmit hashing
Date: Sun,  1 Jul 2012 01:07:43 -0700
Message-ID: <c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net>
References: <cover.1341125875.git.linux@8192.net>
Cc: John Eaglesham <linux@8192.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.dfw.emailsrvr.com ([67.192.241.191]:38788 "EHLO
	smtp191.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab2GAIIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 04:08:54 -0400
In-Reply-To: <cover.1341125875.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "bonding" driver does not support load balancing outgoing
traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
are currently supported; this patch adds transmit hashing for IPv6 (and
TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the
bonding driver.

The algorithm chosen (xor'ing the bottom three quads and then xor'ing
the bottom three bytes of that) was chosen after testing almost 400,000
unique IPv6 addresses harvested from server logs. This algorithm had the
most even distribution for both big- and little-endian architectures while
still using few instructions.

The IPv6 flow label was intentionally not included in the hash as it appears
to be unset in the vast majority of IPv6 traffic sampled, and the current
algorithm not using the flow label already offers a very even distribution.

Fragmented IPv6 packets are handled the same way as fragmented IPv4 packets,
ie, they are not balanced based on layer 4 information. Additionally,
IPv6 packets with intermediate headers are not balanced based on layer
4 information. In practice these intermediate headers are not common and
this should not cause any problems, and the alternative (a packet-parsing
loop and look-up table) seemed slow and complicated for little gain.

This is an update to a prior patch I submitted. This version includes
a clarified description, thorough bounds checking, updates functions to
call bond_xmit_hash_policy_l2 rather than re-implement the same logic,
incorporates Jay's style suggestions, patches against net-next, and
squashes the documentation and code patch into one. Patch has been tested
and performs as expected.

John Eaglesham

---
 Documentation/networking/bonding.txt | 31 ++++++++++--
 drivers/net/bonding/bond_main.c      | 91 +++++++++++++++++++++++++-----------
 2 files changed, 90 insertions(+), 32 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index bfea8a3..5db14fe 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -752,12 +752,22 @@ xmit_hash_policy
 		protocol information to generate the hash.
 
 		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The formula is
+		generate the hash.  The IPv4 formula is
 
 		(((source IP XOR dest IP) AND 0xffff) XOR
 			( source MAC XOR destination MAC ))
 				modulo slave count
 
+		The IPv6 forumla is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((iphash >> 16) XOR (iphash >> 8) XOR iphash)
+			modulo slave count
+
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.  For non-IP traffic,
 		the formula is the same as for the layer2 transmit
@@ -778,19 +788,30 @@ xmit_hash_policy
 		slaves, although a single connection will not span
 		multiple slaves.
 
-		The formula for unfragmented TCP and UDP packets is
+		The formula for unfragmented IPv4 TCP and UDP packets is
 
 		((source port XOR dest port) XOR
 			 ((source IP XOR dest IP) AND 0xffff)
 				modulo slave count
 
-		For fragmented TCP or UDP packets and all other IP
-		protocol traffic, the source and destination port
+		The formula for unfragmented IPv6 TCP and UDP packets is
+
+		iphash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((source port XOR dest port) XOR
+			(iphash >> 16) XOR (iphash >> 8) XOR iphash)
+				modulo slave count
+
+		For fragmented TCP or UDP packets and all other IPv4 and
+		IPv6 protocol traffic, the source and destination port
 		information is omitted.  For non-IP traffic, the
 		formula is the same as for the layer2 transmit hash
 		policy.
 
-		This policy is intended to mimic the behavior of
+		The IPv4 policy is intended to mimic the behavior of
 		certain switches, notably Cisco switches with PFC2 as
 		well as some Foundry and IBM products.
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f5a40b9..b138d84 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3345,56 +3345,93 @@ static struct notifier_block bond_netdev_notifier = {
 /*---------------------------- Hashing Policies -----------------------------*/
 
 /*
+ * Hash for the output device based upon layer 2 data
+ */
+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
+{
+	struct ethhdr *data = (struct ethhdr *)skb->data;
+
+	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
+		return (data->h_dest[5] ^ data->h_source[5]) % count;
+
+	return 0;
+}
+
+/*
  * Hash for the output device based upon layer 2 and layer 3 data. If
- * the packet is not IP mimic bond_xmit_hash_policy_l2()
+ * the packet is not IP, fall back on bond_xmit_hash_policy_l2()
  */
 static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	u32 v6hash;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (skb->protocol == htons(ETH_P_IP) &&
+		skb_network_header_len(skb) >= sizeof(struct iphdr)) {
+		iph = ip_hdr(skb);
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
-	}
-
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
+		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
+		ipv6h = ipv6_hdr(skb);
+		v6hash =
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
+	}
+
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*
  * Hash for the output device based upon layer 3 and layer 4 data. If
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
- * altogether not IP, mimic bond_xmit_hash_policy_l2()
+ * altogether not IP, fall back on bond_xmit_hash_policy_l2()
  */
 static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-	int layer4_xor = 0;
+	u32 layer4_xor = 0;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		iph = ip_hdr(skb);
 		if (!ip_is_fragment(iph) &&
-		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP)) {
+			(iph->protocol == IPPROTO_TCP ||
+			iph->protocol == IPPROTO_UDP)) {
+			__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
+			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
+				skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
+		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
+			goto short_header;
 		}
-		return (layer4_xor ^
-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+		return (layer4_xor ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		ipv6h = ipv6_hdr(skb);
+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
+			__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));
+			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
+				skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
+		} else if (skb_network_header_len(skb) < sizeof(struct ipv6hdr)) {
+			goto short_header;
+		}
+		layer4_xor ^=
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
 	}
 
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
-}
-
-/*
- * Hash for the output device based upon layer 2 data
- */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
-{
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
+short_header:
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*-------------------------- Device entry points ----------------------------*/
-- 
1.7.11
