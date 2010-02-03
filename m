From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: better transmit hash
Date: Wed, 03 Feb 2010 12:09:53 -0800
Message-ID: <27487.1265227793@death.nxdomain.ibm.com>
References: <20100203111337.1085b772@nehalam>
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jpirko@redhat.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56151 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757770Ab0BCUKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 15:10:18 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o13K6ftC009294
	for <netdev@vger.kernel.org>; Wed, 3 Feb 2010 15:06:41 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o13KAF5T127682
	for <netdev@vger.kernel.org>; Wed, 3 Feb 2010 15:10:15 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o13KAE2M031842
	for <netdev@vger.kernel.org>; Wed, 3 Feb 2010 18:10:15 -0200
In-reply-to: <20100203111337.1085b772@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>This is a prototype of improved bonding link hashing. It adds a couple
>of things:
>   * support IPV6 addresses for L3/L4
>   * support other protocols beside TCP/UDP
>   * use all of mac address (not just last byte)
>   * use jhash for better mixing
>   * use skb header field access to handle vlan's etc properly
>
>It no longer is a pure xor, does that matter?

	Maybe.  

	The layer3+4 algorithm in particular was set up to purposely
mimic the algorithm on specific switches.  I'm not sure if there are
users who have dependencies on any of the algorithms being a precise
match for a switch's algorithm (in order to have both directions of a
given flow end up on the same slave).

	Will the jhash preserve 802.3ad packet ordering requirements for
the layer2 and layer2+3 options (this is the property that all packets
for a given flow will be sent over the same slave)?

	How does the computational expense for the jhash compare to the
existing XOR stuff?

	I also noted one line, below, that removes whitespace.

	-J


>--- a/drivers/net/bonding/bond_main.c	2010-02-03 10:42:50.998328499 -0800
>+++ b/drivers/net/bonding/bond_main.c	2010-02-03 11:08:35.034851960 -0800
>@@ -3587,17 +3587,28 @@ void bond_unregister_arp(struct bonding 
>  * Hash for the output device based upon layer 2 and layer 3 data. If
>  * the packet is not IP mimic bond_xmit_hash_policy_l2()
>  */
>-static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
>+static int bond_xmit_hash_policy_l23(const struct sk_buff *skb, int count)
> {
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>+	u32 h;
>
>-	if (skb->protocol == htons(ETH_P_IP)) {
>-		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>-			(data->h_dest[5] ^ data->h_source[5])) % count;
>+	switch (skb->protocol) {
>+	case htons(ETH_P_IP):
>+	{
>+		const struct iphdr *iph = ip_hdr(skb);
>+		h = iph->daddr ^ iph->saddr ^ iph->protocol;
>+		break;
>+	}
>+	case htons(ETH_P_IPV6):
>+	{
>+		const struct ipv6hdr *iph = ipv6_hdr(skb);
>+		h = iph->saddr.s6_addr32[3] ^ iph->daddr.s6_addr32[3];
>+		break;
>+	}
>+	default:
>+		h = skb->protocol;
> 	}
>
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>+	return jhash(eth_hdr(skb), 2*ETH_ALEN, h) % count;
> }
>
> /*
>@@ -3605,35 +3616,55 @@ static int bond_xmit_hash_policy_l23(str
>  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
>  * altogether not IP, mimic bond_xmit_hash_policy_l2()
>  */
>-static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
>+static int bond_xmit_hash_policy_l34(const struct sk_buff *skb, int count)
> {
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>-	int layer4_xor = 0;
>+	u32 h;
>+
>+	switch (skb->protocol) {
>+	case htons(ETH_P_IP):
>+	{
>+		const struct iphdr *iph = ip_hdr(skb);
>+		h = iph->saddr ^ iph->daddr;
>
>-	if (skb->protocol == htons(ETH_P_IP)) {
>-		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
>+		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&

	Why squeeze out the spaces here?

> 		    (iph->protocol == IPPROTO_TCP ||
>-		     iph->protocol == IPPROTO_UDP)) {
>-			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
>-		}
>-		return (layer4_xor ^
>-			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>+		     iph->protocol == IPPROTO_UDP ||
>+		     iph->protocol == IPPROTO_UDPLITE ||
>+		     iph->protocol == IPPROTO_SCTP ||
>+		     iph->protocol == IPPROTO_DCCP ||
>+		     iph->protocol == IPPROTO_ESP))
>+			h ^= *(((u32*)iph) + iph->ihl);
>
>+		break;
>+	}
>+	case htons(ETH_P_IPV6):
>+	{
>+		const struct ipv6hdr *iph = ipv6_hdr(skb);
>+		h = iph->daddr.s6_addr32[3] ^
>+		        iph->saddr.s6_addr32[3] ^ iph->nexthdr;
>+		if (iph->nexthdr == IPPROTO_TCP ||
>+		    iph->nexthdr == IPPROTO_UDP ||
>+		    iph->nexthdr == IPPROTO_UDPLITE ||
>+		    iph->nexthdr == IPPROTO_SCTP ||
>+		    iph->nexthdr == IPPROTO_DCCP ||
>+		    iph->nexthdr == IPPROTO_ESP)
>+			h ^= *(u32*)&iph[1];
>+		break;
>+	}
>+	default:
>+		h = ntohs(skb->protocol);
> 	}
>
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>+	return jhash(eth_hdr(skb), 2*ETH_ALEN, h) % count;
> }
>
> /*
>  * Hash for the output device based upon layer 2 data
>  */
>-static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
>+static int bond_xmit_hash_policy_l2(const struct sk_buff *skb, int count)
> {
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-
>-	return (data->h_dest[5] ^ data->h_source[5]) % count;
>+	return jhash(eth_hdr(skb), 2*ETH_ALEN,
>+		     ntohs(skb->protocol)) % count;
> }
>
> /*-------------------------- Device entry points ----------------------------*/
>--- a/drivers/net/bonding/bonding.h	2010-02-03 11:07:43.694540137 -0800
>+++ b/drivers/net/bonding/bonding.h	2010-02-03 11:07:59.294853950 -0800
>@@ -204,7 +204,7 @@ struct bonding {
> #endif /* CONFIG_PROC_FS */
> 	struct   list_head bond_list;
> 	struct   dev_mc_list *mc_list;
>-	int      (*xmit_hash_policy)(struct sk_buff *, int);
>+	int      (*xmit_hash_policy)(const struct sk_buff *, int);
> 	__be32   master_ip;
> 	u16      flags;
> 	u16      rr_tx_counter;
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
