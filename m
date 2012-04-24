From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH V2 1/2] bonding support for IPv6 transmit hashing
Date: Tue, 24 Apr 2012 15:51:47 -0700
Message-ID: <22560.1335307907@death.nxdomain>
References: <4F8E0A8D.9080803@8192.net>
Cc: netdev@vger.kernel.org
To: John <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:49484 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757346Ab2DXWwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 18:52:45 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 24 Apr 2012 16:52:43 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id EE464C40001
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 16:51:47 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3OMpm1a144552
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 16:51:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3OMpmhN000513
	for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 16:51:48 -0600
In-reply-to: <4F8E0A8D.9080803@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John <linux@8192.net> wrote:

	In principle, I think this is a good idea, but the patch has
some (mostly style) issues, and does not apply to net-next (you don't
say what tree it is based on).

	Can you address the comments noted below, and repost against the
current net-next?

>--- a/drivers/net/bonding/bond_main.c	2012-03-18 16:15:34.000000000 -0700
>+++ b/drivers/net/bonding/bond_main.c	2012-04-14 20:23:26.000000000 -0700
>@@ -3352,56 +3352,87 @@
> /*---------------------------- Hashing Policies -----------------------------*/
>
> /*
>+ * Hash for the output device based upon layer 2 data
>+ */
>+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
>+{
>+	struct ethhdr *data = (struct ethhdr *)skb->data;
>+
>+	if (skb_headlen(skb) >= 6)
>+		return (data->h_dest[5] ^ data->h_source[5]) % count;

	Can skb_headlen ever be less than 6 here?  And why >= 6, anyway?
The offset of ->h_source[5] from skb->data is 11.

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
>
>-	if (skb->protocol == htons(ETH_P_IP)) {
>+	if (skb->protocol == htons(ETH_P_IP) &&
>+		skb_network_header_len(skb) >= sizeof(struct iphdr)) {
>+		struct iphdr *iph = ip_hdr(skb);
> 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
> 			(data->h_dest[5] ^ data->h_source[5])) % count;
>+	} else if (skb->protocol == htons(ETH_P_IPV6) &&
>+		skb_network_header_len(skb) >= sizeof(struct ipv6hdr)) {
>+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>+		u32 v6hash =

	I personally prefer having variables declared at the head of the
function, not inside inner blocks, but if you're going to do this, there
needs to be a blank line after the declaration.

>+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
>+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
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
>
> 	if (skb->protocol == htons(ETH_P_IP)) {
>+		struct iphdr *iph = ip_hdr(skb);
> 		if (!ip_is_fragment(iph) &&

	Blank line after iph declaration.

>-		    (iph->protocol == IPPROTO_TCP ||
>-		     iph->protocol == IPPROTO_UDP)) {
>+			(iph->protocol == IPPROTO_TCP ||
>+			iph->protocol == IPPROTO_UDP)) {
>+			__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);

	Blank line afret the layer4hdr declaration.

>+			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
>+				skb_headlen(skb) - skb_network_offset(skb)) goto SHORT_HEADER;

	The goto needs to be on a separate line.

> 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
>+		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
>+			goto SHORT_HEADER;
> 		}
> 		return (layer4_xor ^
> 			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>-
>+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {

	Blank line after ipv6h.

>+			__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));
>+			if (sizeof(struct ipv6hdr) + sizeof(__be16) * 2 >
>+				skb_headlen(skb) - skb_network_offset(skb)) goto SHORT_HEADER;

	The goto goes on a separate line.

>+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
>+		} else if (skb_network_header_len(skb) < sizeof(struct ipv6hdr)) {
>+			goto SHORT_HEADER;
>+		}
>+		layer4_xor ^=
>+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3]);
>+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
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
>+	SHORT_HEADER:

	This label should be lower case, and not indented at all.

	-J


>+	return bond_xmit_hash_policy_l2(skb, count);
> }
>
> /*-------------------------- Device entry points ----------------------------*/

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
