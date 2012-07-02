From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Mon, 02 Jul 2012 16:33:30 -0700
Message-ID: <18390.1341272010@death.nxdomain>
References: <c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net> <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net>
Cc: netdev@vger.kernel.org
To: John Eaglesham <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33675 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932473Ab2GBXeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 19:34:22 -0400
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 2 Jul 2012 19:34:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1CA7738C8052
	for <netdev@vger.kernel.org>; Mon,  2 Jul 2012 19:33:32 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62NXV5K429220
	for <netdev@vger.kernel.org>; Mon, 2 Jul 2012 19:33:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q62NXVnL026656
	for <netdev@vger.kernel.org>; Mon, 2 Jul 2012 20:33:31 -0300
In-reply-to: <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Eaglesham <linux@8192.net> wrote:

>Currently the "bonding" driver does not support load balancing outgoing
>traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
>are currently supported; this patch adds transmit hashing for IPv6 (and
>TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the
>bonding driver.
>
>The algorithm chosen (xor'ing the bottom three quads of the source and
>destination addresses together, then xor'ing each byte of that result into
>the bottom byte, finally xor'ing with the last bytes of the MAC addresses)
>was selected after testing almost 400,000 unique IPv6 addresses harvested
>from server logs. This algorithm had the most even distribution for both
>big- and little-endian architectures while still using few instructions. Its
>behavior also attempts to closely match that of the IPv4 algorithm.
>
>The IPv6 flow label was intentionally not included in the hash as it appears
>to be unset in the vast majority of IPv6 traffic sampled, and the current
>algorithm not using the flow label already offers a very even distribution.
>
>Fragmented IPv6 packets are handled the same way as fragmented IPv4 packets,
>ie, they are not balanced based on layer 4 information. Additionally,
>IPv6 packets with intermediate headers are not balanced based on layer
>4 information. In practice these intermediate headers are not common and
>this should not cause any problems, and the alternative (a packet-parsing
>loop and look-up table) seemed slow and complicated for little gain.
>
>This is an update to prior patches I submitted. This version includes:
>* Updated and clarified description
>* IPv6 algorithm more closely matches that of IPv4
>* Thorough bounds checking on all xmit functions
>* Consolidate layer 2 hashing logic into one function
>* Update style as per Jay Vosburgh and David Miller
>* Patches against net-next as one patch
>
>Patch has been tested and performs as expected.
>
>John Eaglesham
>
>---
> Documentation/networking/bonding.txt | 32 +++++++++++--
> drivers/net/bonding/bond_main.c      | 91 +++++++++++++++++++++++++-----------
> 2 files changed, 92 insertions(+), 31 deletions(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index bfea8a3..3851dad 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -752,12 +752,23 @@ xmit_hash_policy
> 		protocol information to generate the hash.
>
> 		Uses XOR of hardware MAC addresses and IP addresses to
>-		generate the hash.  The formula is
>+		generate the hash.  The IPv4 formula is
>
> 		(((source IP XOR dest IP) AND 0xffff) XOR
> 			( source MAC XOR destination MAC ))
> 				modulo slave count
>
>+		The IPv6 formula is
>+
>+		hash =
>+			(source ip quad 2 XOR dest IP quad 2) XOR
>+			(source ip quad 3 XOR dest IP quad 3) XOR
>+			(source ip quad 4 XOR dest IP quad 4)
>+
>+		(((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
>+			(source MAC XOR destination MAC))
>+				modulo slave count

	This seems to be missing an XOR, between the end of "XOR hash)"
and the start of "(source MAC".

>+
> 		This algorithm will place all traffic to a particular
> 		network peer on the same slave.  For non-IP traffic,
> 		the formula is the same as for the layer2 transmit
>@@ -778,19 +789,30 @@ xmit_hash_policy
> 		slaves, although a single connection will not span
> 		multiple slaves.
>
>-		The formula for unfragmented TCP and UDP packets is
>+		The formula for unfragmented IPv4 TCP and UDP packets is
>
> 		((source port XOR dest port) XOR
> 			 ((source IP XOR dest IP) AND 0xffff)
> 				modulo slave count
>
>-		For fragmented TCP or UDP packets and all other IP
>-		protocol traffic, the source and destination port
>+		The formula for unfragmented IPv6 TCP and UDP packets is
>+
>+		hash =
>+			(source ip quad 2 XOR dest IP quad 2) XOR
>+			(source ip quad 3 XOR dest IP quad 3) XOR
>+			(source ip quad 4 XOR dest IP quad 4)
>+
>+		((source port XOR dest port) XOR
>+			(hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
>+				modulo slave count
>+
>+		For fragmented TCP or UDP packets and all other IPv4 and
>+		IPv6 protocol traffic, the source and destination port
> 		information is omitted.  For non-IP traffic, the
> 		formula is the same as for the layer2 transmit hash
> 		policy.
>
>-		This policy is intended to mimic the behavior of
>+		The IPv4 policy is intended to mimic the behavior of
> 		certain switches, notably Cisco switches with PFC2 as
> 		well as some Foundry and IBM products.
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index f5a40b9..c733d55 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3345,56 +3345,95 @@ static struct notifier_block bond_netdev_notifier = {
> /*---------------------------- Hashing Policies -----------------------------*/
>
> /*
>+ * Hash for the output device based upon layer 2 data
>+ */
>+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
>+{
>+	struct ethhdr *data = (struct ethhdr *)skb->data;
>+
>+	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
>+		return (data->h_dest[5] ^ data->h_source[5]) % count;
>+
>+	return 0;
>+}
>+
>+/*
>  * Hash for the output device based upon layer 2 and layer 3 data. If
>- * the packet is not IP mimic bond_xmit_hash_policy_l2()
>+ * the packet is not IP, fall back on bond_xmit_hash_policy_l2()
>  */
> static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
> {
> 	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>-
>-	if (skb->protocol == htons(ETH_P_IP)) {
>+	struct iphdr *iph;
>+	struct ipv6hdr *ipv6h;
>+	u32 v6hash;
>+	__be32 *s, *d;
>+
>+	if (skb->protocol == htons(ETH_P_IP) &&
>+		skb_network_header_len(skb) >= sizeof(struct iphdr)) {
>+		iph = ip_hdr(skb);
> 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
> 			(data->h_dest[5] ^ data->h_source[5])) % count;
>+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
>+		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
>+		ipv6h = ipv6_hdr(skb);
>+		s = &ipv6h->saddr.s6_addr32[0];
>+		d = &ipv6h->daddr.s6_addr32[0];
>+		v6hash = (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
>+		v6hash ^= (v6hash >> 24) ^ (v6hash >> 16) ^ (v6hash >> 8);
>+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
> 	}
>
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>+	return bond_xmit_hash_policy_l2(skb, count);
> }
>
> /*
>  * Hash for the output device based upon layer 3 and layer 4 data. If
>  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
>- * altogether not IP, mimic bond_xmit_hash_policy_l2()
>+ * altogether not IP, fall back on bond_xmit_hash_policy_l2()
>  */
> static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
> {
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>-	int layer4_xor = 0;
>+	u32 layer4_xor = 0;
>+	struct iphdr *iph;
>+	struct ipv6hdr *ipv6h;
>+	__be32 *s, *d;
>+	__be16 *layer4hdr;
>
> 	if (skb->protocol == htons(ETH_P_IP)) {
>+		iph = ip_hdr(skb);
> 		if (!ip_is_fragment(iph) &&
>-		    (iph->protocol == IPPROTO_TCP ||
>-		     iph->protocol == IPPROTO_UDP)) {
>+			(iph->protocol == IPPROTO_TCP ||
>+			iph->protocol == IPPROTO_UDP)) {

	Why did these two lines change?

>+			layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>+			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
>+				skb_headlen(skb) - skb_network_offset(skb))
>+				goto short_header;
> 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
>+		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
>+			goto short_header;
> 		}
>-		return (layer4_xor ^
>-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>-
>+		return (layer4_xor ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;

	This line runs past 80 columns.  There are a few more of these
further down.

>+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>+		ipv6h = ipv6_hdr(skb);
>+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
>+			layer4hdr = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));

	Could this be written as

			layer4hdr = (__be16 *)(ipv6h + 1);

	instead?

	-J

>+			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
>+				skb_headlen(skb) - skb_network_offset(skb))
>+				goto short_header;
>+			layer4_xor = (*layer4hdr ^ *(layer4hdr + 1));
>+		} else if (skb_network_header_len(skb) < sizeof(struct ipv6hdr)) {
>+			goto short_header;
>+		}
>+		s = &ipv6h->saddr.s6_addr32[0];
>+		d = &ipv6h->daddr.s6_addr32[0];
>+		layer4_xor ^= (s[1] ^ d[1]) ^ (s[2] ^ d[2]) ^ (s[3] ^ d[3]);
>+		layer4_xor ^= (layer4_xor >> 24) ^ (layer4_xor >> 16) ^ (layer4_xor >> 8);
>+		return layer4_xor % count;
> 	}
>
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>-}
>-
>-/*
>- * Hash for the output device based upon layer 2 data
>- */
>-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
>-{
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>+short_header:
>+	return bond_xmit_hash_policy_l2(skb, count);
> }
>
> /*-------------------------- Device entry points ----------------------------*/
>-- 
>1.7.11

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
