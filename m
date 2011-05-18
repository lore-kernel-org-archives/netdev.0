From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] IPv6 transmit hashing for bonding driver
Date: Tue, 17 May 2011 17:57:36 -0700
Message-ID: <26860.1305680256@death>
References: <4DD30AF2.1090707@8192.net>
Cc: netdev@vger.kernel.org
To: John <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:53368 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474Ab1ERA5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 20:57:48 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4I0soBD023212
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 18:54:50 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4I0wx86129986
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 18:58:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HIvehx003729
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 12:57:41 -0600
In-reply-to: <4DD30AF2.1090707@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John <linux@8192.net> wrote:

>Currently the "bonding" driver does not support load balancing outgoing
>traffic in LACP mode for IPv6 traffic. IPv4 (and TCP over IPv4) are
>currently supported; this patch adds transmit hashing for IPv6 (and TCP
>over IPv6), bringing IPv6 up to par with IPv4 support in the bonding
>driver.
>
>The algorithm chosen (xor'ing the bottom three quads and then xor'ing that
>down into the bottom byte) was chosen after testing almost 400,000 unique
>IPv6 addresses harvested from server logs. This algorithm had the most
>even distribution for both big- and little-endian architectures while
>still using few instructions.
>
>This patch also adds missing configuration information the MODULE_PARM_DESC.
>
>Patch has been tested on various machines and performs as expected. Thanks
>to Stephen Hemminger and Andy Gospodarek for advice and guidance.

	This looks reasonable at first glance, with a few comments
below.  You'll need to supply a Signed-Off-By at some point.

	It would also be useful to include an update bonding.txt to
describe the IPv6 algorithm; I'd word that something like the following
(filling in the missing bits) for the layer3+4 section, applying similar
changes to the layer2+3 section:

--- net-next-2.6/Documentation/networking/bonding.txt	2011-05-09 17:53:03.000000000 -0700
+++ net-next-2.6/Documentation/networking/bonding.txt.new	2011-05-17 17:53:46.000000000 -0700
@@ -733,21 +733,26 @@
 		slaves, although a single connection will not span
 		multiple slaves.
 
-		The formula for unfragmented TCP and UDP packets is
+		The formula for unfragmented IPv4 TCP and UDP packets is
 
 		((source port XOR dest port) XOR
 			 ((source IP XOR dest IP) AND 0xffff)
 				modulo slave count
 
-		For fragmented TCP or UDP packets and all other IP
+		The formula for unfragmented IPv6 TCP and UDP packets is
+
+		[ your formula here ]
+
+		For fragmented TCP or UDP packets and all other IP or IPv6
 		protocol traffic, the source and destination port
-		information is omitted.  For non-IP traffic, the
+		information is omitted.  For non-IP/IPv6 traffic, the
 		formula is the same as for the layer2 transmit hash
 		policy.
 
-		This policy is intended to mimic the behavior of
-		certain switches, notably Cisco switches with PFC2 as
-		well as some Foundry and IBM products.
+		The IPv4 behavior is intended to mimic the behavior of
+		certain switches, notably Cisco switches with PFC2 as well
+		as some Foundry and IBM products.  The IPv6 behavior was
+		determined by [ your rationale here ].
 
 		This algorithm is not fully 802.3ad compliant.  A
 		single TCP or UDP conversation containing both


>John
>
>--- drivers/net/bonding/bond_main.c.orig	2011-04-18 17:23:09.202894000 -0700
>+++ drivers/net/bonding/bond_main.c	2011-04-19 18:12:30.287929000 -0700
>@@ -152,7 +152,7 @@
> MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
> module_param(xmit_hash_policy, charp, 0);
> MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
>-				   ", 1 for layer 3+4");
>+				   ", 1 for layer 3+4, 2 for layer 2+3");
> module_param(arp_interval, int, 0);
> MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
> module_param_array(arp_ip_target, charp, NULL, 0);
>@@ -3720,11 +3720,20 @@
> static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
> {
> 	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>
> 	if (skb->protocol == htons(ETH_P_IP)) {
>+		struct iphdr *iph = ip_hdr(skb);
> 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
> 			(data->h_dest[5] ^ data->h_source[5])) % count;
>+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>+		u32 v6hash = (
>+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
>+		);

	Style nit: I don't believe the outermost parentheses are
necessary.  Since you do this twice, perhaps make a small inline
function to handle it.

>+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
>+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
> 	}
>
> 	return (data->h_dest[5] ^ data->h_source[5]) % count;
>@@ -3738,11 +3747,11 @@
> static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
> {
> 	struct ethhdr *data = (struct ethhdr *)skb->data;
>-	struct iphdr *iph = ip_hdr(skb);
>-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>-	int layer4_xor = 0;
>+	u32 layer4_xor = 0;
>
> 	if (skb->protocol == htons(ETH_P_IP)) {
>+		struct iphdr *iph = ip_hdr(skb);
>+		__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
> 		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
> 		    (iph->protocol == IPPROTO_TCP ||
> 		     iph->protocol == IPPROTO_UDP)) {
>@@ -3750,7 +3759,18 @@
> 		}
> 		return (layer4_xor ^
> 			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>-
>+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>+		__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(*ipv6h));
>+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {

	For fragmented datagrams, the above will keep all fragments
together, which is good, but are there other header types that should be
skipped over to find the UDP/TCP header for hashing purposes?

>+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
>+		}
>+		layer4_xor ^= (
>+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
>+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
>+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
>+		);

	Parentheses / maybe inline again.

>+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
> 	}
>
> 	return (data->h_dest[5] ^ data->h_source[5]) % count;

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
