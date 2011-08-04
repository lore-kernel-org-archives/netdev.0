From: David Miller <davem@davemloft.net>
Subject: Re: return of ip_rt_bug()
Date: Thu, 04 Aug 2011 00:23:49 -0700 (PDT)
Message-ID: <20110804.002349.1087773132617097833.davem@davemloft.net>
References: <20110802170942.GA17164@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@gmail.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab1HDHXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 03:23:55 -0400
In-Reply-To: <20110802170942.GA17164@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 2 Aug 2011 13:09:42 -0400

> all the traces he's hit so far seem to be caused by udp, and they all seem to be
> going from 192.168.2.5 -> 255.255.255.255
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=712632 is his full report with similar traces.

It should have been fixed by the patch below, but apparently not:

--------------------
>From ed6e4ef836d425bc35e33bf20fcec95e68203afa Mon Sep 17 00:00:00 2001
From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 18 Jun 2011 07:53:59 +0000
Subject: [PATCH] netfilter: Fix ip_route_me_harder triggering ip_rt_bug

	Avoid creating input routes with ip_route_me_harder.
It does not work for locally generated packets. Instead,
restrict sockets to provide valid saddr for output route (or
unicast saddr for transparent proxy). For other traffic
allow saddr to be unicast or local but if callers forget
to check saddr type use 0 for the output route.

	The resulting handling should be:

- REJECT TCP:
	- in INPUT we can provide addr_type = RTN_LOCAL but
	better allow rejecting traffic delivered with
	local route (no IP address => use RTN_UNSPEC to
	allow also RTN_UNICAST).
	- FORWARD: RTN_UNSPEC => allow RTN_LOCAL/RTN_UNICAST
	saddr, add fix to ignore RTN_BROADCAST and RTN_MULTICAST
	- OUTPUT: RTN_UNSPEC

- NAT, mangle, ip_queue, nf_ip_reroute: RTN_UNSPEC in LOCAL_OUT

- IPVS:
	- use RTN_LOCAL in LOCAL_OUT and FORWARD after SNAT
	to restrict saddr to be local

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter.c            |   60 ++++++++++++++------------------------
 net/ipv4/netfilter/ipt_REJECT.c |   14 ++------
 2 files changed, 26 insertions(+), 48 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 4614bab..2e97e3e 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -17,51 +17,35 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
-	unsigned long orefdst;
+	__be32 saddr = iph->saddr;
+	__u8 flags = 0;
 	unsigned int hh_len;
-	unsigned int type;
 
-	type = inet_addr_type(net, iph->saddr);
-	if (skb->sk && inet_sk(skb->sk)->transparent)
-		type = RTN_LOCAL;
-	if (addr_type == RTN_UNSPEC)
-		addr_type = type;
+	if (!skb->sk && addr_type != RTN_LOCAL) {
+		if (addr_type == RTN_UNSPEC)
+			addr_type = inet_addr_type(net, saddr);
+		if (addr_type == RTN_LOCAL || addr_type == RTN_UNICAST)
+			flags |= FLOWI_FLAG_ANYSRC;
+		else
+			saddr = 0;
+	}
 
 	/* some non-standard hacks like ipt_REJECT.c:send_reset() can cause
 	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
 	 */
-	if (addr_type == RTN_LOCAL) {
-		fl4.daddr = iph->daddr;
-		if (type == RTN_LOCAL)
-			fl4.saddr = iph->saddr;
-		fl4.flowi4_tos = RT_TOS(iph->tos);
-		fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
-		fl4.flowi4_mark = skb->mark;
-		fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			return -1;
-
-		/* Drop old route. */
-		skb_dst_drop(skb);
-		skb_dst_set(skb, &rt->dst);
-	} else {
-		/* non-local src, find valid iif to satisfy
-		 * rp-filter when calling ip_route_input. */
-		fl4.daddr = iph->saddr;
-		rt = ip_route_output_key(net, &fl4);
-		if (IS_ERR(rt))
-			return -1;
+	fl4.daddr = iph->daddr;
+	fl4.saddr = saddr;
+	fl4.flowi4_tos = RT_TOS(iph->tos);
+	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : flags;
+	rt = ip_route_output_key(net, &fl4);
+	if (IS_ERR(rt))
+		return -1;
 
-		orefdst = skb->_skb_refdst;
-		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->dst.dev) != 0) {
-			dst_release(&rt->dst);
-			return -1;
-		}
-		dst_release(&rt->dst);
-		refdst_drop(orefdst);
-	}
+	/* Drop old route. */
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
 
 	if (skb_dst(skb)->error)
 		return -1;
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 1ff79e5..51f13f8 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -40,7 +40,6 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	struct iphdr *niph;
 	const struct tcphdr *oth;
 	struct tcphdr _otcph, *tcph;
-	unsigned int addr_type;
 
 	/* IP header checks: fragment. */
 	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
@@ -55,6 +54,9 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	if (oth->rst)
 		return;
 
+	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return;
+
 	/* Check checksum */
 	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
 		return;
@@ -101,19 +103,11 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	nskb->csum_start = (unsigned char *)tcph - nskb->head;
 	nskb->csum_offset = offsetof(struct tcphdr, check);
 
-	addr_type = RTN_UNSPEC;
-	if (hook != NF_INET_FORWARD
-#ifdef CONFIG_BRIDGE_NETFILTER
-	    || (nskb->nf_bridge && nskb->nf_bridge->mask & BRNF_BRIDGED)
-#endif
-	   )
-		addr_type = RTN_LOCAL;
-
 	/* ip_route_me_harder expects skb->dst to be set */
 	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
 	nskb->protocol = htons(ETH_P_IP);
-	if (ip_route_me_harder(nskb, addr_type))
+	if (ip_route_me_harder(nskb, RTN_UNSPEC))
 		goto free_nskb;
 
 	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
-- 
1.7.6

