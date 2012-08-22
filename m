From: John Eaglesham <linux@8192.net>
Subject: [PATCH v8] bonding: support for IPv6 transmit hashing
Date: Tue, 21 Aug 2012 23:43:35 -0700
Message-ID: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345615999.git.linux@8192.net>
References: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345610688.git.linux@8192.net>
Cc: John Eaglesham <linux@8192.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp137.dfw.emailsrvr.com ([67.192.241.137]:40551 "EHLO
	smtp137.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698Ab2HVGo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 02:44:59 -0400
In-Reply-To: <2e01d8f94c42c61af9886683a4c35caf6816bc3d.1345610688.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>

Currently the "bonding" driver does not support load balancing outgoing
traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
are currently supported; this patch adds transmit hashing for IPv6 (and
TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the
bonding driver. In addition, bounds checking has been added to all
transmit hashing functions.

The algorithm chosen (xor'ing the bottom three quads of the source and
destination addresses together, then xor'ing each byte of that result into
the bottom byte, finally xor'ing with the last bytes of the MAC addresses)
was selected after testing almost 400,000 unique IPv6 addresses harvested
from server logs. This algorithm had the most even distribution for both
big- and little-endian architectures while still using few instructions. Its
behavior also attempts to closely match that of the IPv4 algorithm.

The IPv6 flow label was intentionally not included in the hash as it appears
to be unset in the vast majority of IPv6 traffic sampled, and the current
algorithm not using the flow label already offers a very even distribution.

Fragmented IPv6 packets are handled the same way as fragmented IPv4 packets,
ie, they are not balanced based on layer 4 information. Additionally,
IPv6 packets with intermediate headers are not balanced based on layer
4 information. In practice these intermediate headers are not common and
this should not cause any problems, and the alternative (a packet-parsing
loop and look-up table) seemed slow and complicated for little gain.

Tested-by: John Eaglesham <linux@8192.net>
Signed-off-by: John Eaglesham <linux@8192.net>

---

Changes:
v2)
	* Clarify description
	* Add bounds checking to more functions
	* All functions call bond_xmit_hash_policy_l2 rather than re-
          implement the same logic.
v3)
	* Patch against net-next.
	* Style corrections.
v4)
	* Correct indenting.
v5)
	* Squash documentation and code patches into one.
v6)
	* Modify IPv6 hash to behave more like the IPv4 hash, update
	  documentation with modified algorithm.
	* Clean up formatting.
	* Move all variable declaration to the top of the function.
	* Minor change to IPv6 layer 4 hash to match IPv4 hash behavior
	  (mix all hashed address bits together rather than just the
	  bottom 24 bits).
v7)
	* Improve bounds checking code (handle truncated IPv6 header,
	  removed goto, fewer if statements).
	* Re-write pseudocode in documentation to match actual code more
	  closely.
	* Correct indenting, align parentheses, wrap code at <= 80 columns
	  (based on Jay's changes).
v8)
	* Correct patch submission format.

 Documentation/networking/bonding.txt | 30 ++++++++++--
 drivers/net/bonding/bond_main.c      | 89 +++++++++++++++++++++++++-----------
 2 files changed, 88 insertions(+), 31 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 6b1c711..10a015c 100644
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
 
+		The IPv6 formula is
+
+		hash = (source ip quad 2 XOR dest IP quad 2) XOR
+		       (source ip quad 3 XOR dest IP quad 3) XOR
+		       (source ip quad 4 XOR dest IP quad 4)
+
+		(((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
+			XOR (source MAC XOR destination MAC))
+				modulo slave count
+
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.  For non-IP traffic,
 		the formula is the same as for the layer2 transmit
@@ -778,19 +788,29 @@ xmit_hash_policy
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
+		hash = (source port XOR dest port) XOR
+		       ((source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4))
+
+		((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
+			modulo slave count
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
index d95fbc3..4221e57 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3354,56 +3354,93 @@ static struct notifier_block bond_netdev_notifier = {
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
-
-	if (skb->protocol == htons(ETH_P_IP)) {
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	u32 v6hash;
+	__be32 *s, *d;
+
+	if (skb->protocol == htons(ETH_P_IP) &&
+	    skb_network_header_len(skb) >= sizeof(*iph)) {
+		iph = ip_hdr(skb);
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
+		   skb_network_header_len(skb) >= sizeof(*ipv6h)) {
+		ipv6h = ipv6_hdr(skb);
+		s = &ipv6h->saddr.s6_addr32[0];
+		d = &ipv6h->daddr.s6_addr32[0];
+		v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
+		v6hash ^= (v6hash >> 24) ^ (v6hash >> 16) ^ (v6hash >> 8);
+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
 	}
 
-	return (data->h_dest[5] ^ data->h_source[5]) % count;
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
-
-	if (skb->protocol == htons(ETH_P_IP)) {
+	u32 layer4_xor = 0;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	__be32 *s, *d;
+	__be16 *layer4hdr;
+
+	if (skb->protocol == htons(ETH_P_IP) &&
+	    skb_network_header_len(skb) >= sizeof(*iph)) {
+		iph = ip_hdr(skb);
 		if (!ip_is_fragment(iph) &&
 		    (iph->protocol == IPPROTO_TCP ||
-		     iph->protocol == IPPROTO_UDP)) {
-			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
+		     iph->protocol == IPPROTO_UDP) &&
+		    (skb_headlen(skb) - skb_network_offset(skb) >=
+		     iph->ihl * sizeof(u32) + sizeof(*layer4hdr) * 2)) {
+			layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
+			layer4_xor = ntohs(*layer4hdr ^ *(layer4hdr + 1));
 		}
 		return (layer4_xor ^
 			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
+		   skb_network_header_len(skb) >= sizeof(*ipv6h)) {
+		ipv6h = ipv6_hdr(skb);
+		if ((ipv6h->nexthdr == IPPROTO_TCP ||
+		     ipv6h->nexthdr == IPPROTO_UDP) &&
+		    (skb_headlen(skb) - skb_network_offset(skb) >=
+		     sizeof(*ipv6h) + sizeof(*layer4hdr) * 2)) {
+			layer4hdr = (__be16 *)(ipv6h + 1);
+			layer4_xor = ntohs(*layer4hdr ^ *(layer4hdr + 1));
+		}
+		s = &ipv6h->saddr.s6_addr32[0];
+		d = &ipv6h->daddr.s6_addr32[0];
+		layer4_xor ^= (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
+		layer4_xor ^= (layer4_xor >> 24) ^ (layer4_xor >> 16) ^
+			       (layer4_xor >> 8);
+		return layer4_xor % count;
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
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*-------------------------- Device entry points ----------------------------*/
-- 
1.7.11
