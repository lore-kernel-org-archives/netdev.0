From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 22:51:37 -0400
Message-ID: <20111012025137.GB20605@gospo.rdu.redhat.com>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com> <20111011143348.GA20605@gospo.rdu.redhat.com> <23119.1318348739@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Yinglin Sun <Yinglin.Sun@emc.com>, netdev@vger.kernel.org,
	John Eaglesham <johneagl@yahoo-inc.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab1JLCvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 22:51:42 -0400
Content-Disposition: inline
In-Reply-To: <23119.1318348739@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2011 at 08:58:59AM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
> >
> >There have been some attempts to add support for ipv6 hashing this in
> >the past, but none have been committed.  The best one I had seen was one
> >that did some extensive testing one a wide variety of ipv6 traffic and
> >it showed nice traffic distribution.  I'm not sure if it was ever posted
> >upstream, so I will see if I can dig it up.
> >
> >Can you quantify how traffic was distributed with this algorithm?
> 
> 	As I recall, the IPv6 issues had to do with the "layer3+4" hash,
> because the IPv6 TCP or UDP port numbers can be harder to get at than in
> IPv4 (which typically has a fixed size header).  The above is just for
> layer 2, so it only hits the IPv6 addresses, which don't move around.
> 
> 	That said, I believe that many IPv6 addresses are derived from
> the MAC address, the autoconf addresses in particular, so s6_addr32[3]
> may not show a lot more variation than just the MAC address.  I don't
> know for sure though, since I haven't tested it.
> 
> 	I don't recall seeing the patch you mention, Andy, that checks
> ipv6 traffic; can you post it?
> 

I found the patch, cleaned it up, and compile tested it against
net-next.  I traded some emails with John Eaglesham (cc'd) earlier this
year and though he planned to post it, I never followed up.

His comments about this patch were as follows:

"I've attached my patch for IPv6 transmit hashing for the nic bonding
driver.

"The algorithm I chose is based on 273,913 IPv6 client addresses I
gathered from webservers and ran through a test program that implemented
several algorithms. This algorithm provided the most even distribution
while using the fewest instructions.

"I've tested this on 2.6.39-rc4 and a similar patch to 2.6.18 (from
RHEL5 5.4.3) and it has performed as expected in both cases.

"Please let me know if you have any comments, otherwise I suppose the
next step is to propose the patch to LKML."

I would suggest we use this.  John or I could write an official
changelog and post this in it's own thread if it looks good to others.

---
 drivers/net/bonding/bond_main.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6191e63..335cb67 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3368,11 +3368,20 @@ static struct notifier_block bond_inetaddr_notifier = {
 static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
 		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
 			(data->h_dest[5] ^ data->h_source[5])) % count;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		u32 v6hash = (
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
+		);
+		v6hash = (v6hash >> 16) ^ (v6hash >> 8) ^ v6hash;
+		return (v6hash ^ data->h_dest[5] ^ data->h_source[5]) % count;
 	}
 
 	return (data->h_dest[5] ^ data->h_source[5]) % count;
@@ -3386,11 +3395,11 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
-	struct iphdr *iph = ip_hdr(skb);
-	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
-	int layer4_xor = 0;
+	u32 layer4_xor = 0;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+		__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
 		if (!ip_is_fragment(iph) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP)) {
@@ -3398,7 +3407,18 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 		}
 		return (layer4_xor ^
 			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
-
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+		__be16 *layer4hdrv6 = (__be16 *)((u8 *)ipv6h + sizeof(*ipv6h));
+		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
+			layer4_xor = (*layer4hdrv6 ^ *(layer4hdrv6 + 1));
+		}
+		layer4_xor ^= (
+			(ipv6h->saddr.s6_addr32[1] ^ ipv6h->daddr.s6_addr32[1]) ^
+			(ipv6h->saddr.s6_addr32[2] ^ ipv6h->daddr.s6_addr32[2]) ^
+			(ipv6h->saddr.s6_addr32[3] ^ ipv6h->daddr.s6_addr32[3])
+		);
+		return ((layer4_xor >> 16) ^ (layer4_xor >> 8) ^ layer4_xor) % count;
 	}
 
 	return (data->h_dest[5] ^ data->h_source[5]) % count;
