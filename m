From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Tue, 21 Aug 2012 12:19:55 -0700
Message-ID: <11100.1345576795@death.nxdomain>
References: <4FF27CA0.7030708@8192.net> <20120702.221425.418792617776598841.davem@davemloft.net> <4FF2853D.9070707@8192.net> <20120702.224351.1587084404665143719.davem@davemloft.net> <CAPc2XZDHBPKEM+WsWTL+9N_sfgVhOZAoiY3LU=v-QTCb9eQObQ@mail.gmail.com>
Cc: linux@8192.net, netdev@vger.kernel.org
To: Jeremy Brookman <jeremy.brookman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51730 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab2HUTVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 15:21:32 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 21 Aug 2012 13:21:31 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D185919D803C
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 13:21:03 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7LJK0c5084030
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 13:20:10 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7LJLHQ1029967
	for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 13:21:18 -0600
In-reply-to: <CAPc2XZDHBPKEM+WsWTL+9N_sfgVhOZAoiY3LU=v-QTCb9eQObQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Brookman <jeremy.brookman@gmail.com> wrote:

>> You should use a mix of tabs, as necessary, to get things to line up
>> how I told you they need to line up.
>
>Unless I'm missing something, this change doesn't seem to have made it
>through to the kernel tip, but we could really use this bugfix. Is it
>in a repository I didn't notice, or not yet through the review?  If
>it's not through the review, is any help needed to get it there?

	The submitter (John Eaglesham) never posted an updated version
that addressed the various comments, nor did his original patch
submission include a Signed-off-by.

	I went ahead and updated the patch to address the comments; I've
only compile tested this.  Are you (Jeremy or John) able to test this to
confirm that it will hash ipv6 traffic as expected (I can test it, but
it won't be today)?

	John, can you post a Signed-off-by for your patch (really, this
updated version of your patch)?

	If John signs off and somebody tests this, I'll post a formal
submssion with the full commit message.

	-J

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 6b1c711..834c919 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -752,12 +752,23 @@ xmit_hash_policy
 		protocol information to generate the hash.
 
 		Uses XOR of hardware MAC addresses and IP addresses to
-		generate the hash.  The formula is
+		generate the hash.  The IPv4 formula is
 
 		(((source IP XOR dest IP) AND 0xffff) XOR
 			( source MAC XOR destination MAC ))
 				modulo slave count
 
+		The IPv6 formula is
+
+		hash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		(((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
+			XOR (source MAC XOR destination MAC))
+				modulo slave count
+
 		This algorithm will place all traffic to a particular
 		network peer on the same slave.  For non-IP traffic,
 		the formula is the same as for the layer2 transmit
@@ -778,19 +789,30 @@ xmit_hash_policy
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
+		hash =
+			(source ip quad 2 XOR dest IP quad 2) XOR
+			(source ip quad 3 XOR dest IP quad 3) XOR
+			(source ip quad 4 XOR dest IP quad 4)
+
+		((source port XOR dest port) XOR
+			(hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
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
index d95fbc3..4dfe7e3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3354,56 +3354,99 @@ static struct notifier_block bond_netdev_notifier = {
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
+		skb_network_header_len(skb) >= sizeof(struct iphdr)) {
+		iph = ip_hdr(skb);
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
+		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
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
+	u32 layer4_xor = 0;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	__be32 *s, *d;
+	__be16 *layer4hdr;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		iph = ip_hdr(skb);
 		if (!ip_is_fragment(iph) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP)) {
+			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
+			    skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
+			layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
+		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
+			goto short_header;
 		}
 		return (layer4_xor ^
 			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		ipv6h = ipv6_hdr(skb);
+		if (ipv6h->nexthdr == IPPROTO_TCP ||
+		    ipv6h->nexthdr == IPPROTO_UDP) {
+			layer4hdr = (__be16 *)(ipv6h + 1);
+			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
+				skb_headlen(skb) - skb_network_offset(skb))
+				goto short_header;
+			layer4_xor = (*layer4hdr ^ *(layer4hdr + 1));
+		} else if (skb_network_header_len(skb) <
+			   sizeof(struct ipv6hdr)) {
+			goto short_header;
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
+short_header:
+	return bond_xmit_hash_policy_l2(skb, count);
 }
 
 /*-------------------------- Device entry points ----------------------------*/


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
