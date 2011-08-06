From: Julian Anastasov <ja@ssi.bg>
Subject: Re: return of ip_rt_bug()
Date: Sun, 7 Aug 2011 01:14:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108070104440.1413@ja.ssi.bg>
References: <20110802170942.GA17164@redhat.com> <alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg> <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com> <alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg> <CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
 <CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com> <alpine.LFD.2.00.1108051048160.1494@ja.ssi.bg> <CAFiZG+Wmv_FEx2ZX3qZt0tAr-QVQD_javX1gbRWujr9xyf7nbQ@mail.gmail.com> <CAFiZG+Ve9Y4v9CWCrbGsR+7C79AyoiWncVSVbeqApDuKaPm_jA@mail.gmail.com>
 <CAFiZG+VJ27939BT-dTbvSotxO6+ACbxWiYwQBUT9pC_Fw22O-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Tom London <selinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54658 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753459Ab1HFWJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Aug 2011 18:09:49 -0400
In-Reply-To: <CAFiZG+VJ27939BT-dTbvSotxO6+ACbxWiYwQBUT9pC_Fw22O-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	OK, after a bit of digging here is the problem.
It is evident that ip_rt_bug reports skb->dev = NULL which
is impossible to pass ip_route_input. It means, we got this
input route no matter our skb->dev = NULL. Here is how
that happened.

	For the routing cache compare_keys matches
rt_key_dst, rt_key_src, rt_mark, rt_key_tos, rt_oif, rt_iif

	Consider the following two examples:

1. Received traffic from 0.0.0.0 to 255.255.255.255, one example is DHCP

	ip_route_input_slow caches the things as follows:

	rt_key_dst = 255.255.255.255 (iph->daddr)
	rt_key_src = 0.0.0.0 (iph->saddr)
	rt_mark = 0
	rt_key_tos = 0 (RT TOS from iph->tos)
	rt_oif = 0 (always for input route)
	rt_iif = eth0 (input device)

	not compared by compare_keys:
	rt_route_iif = eth0 (input device)

	use hash chain based on some keys and iif

2. Local traffic from ANY LOCAL IP to 255.255.255.255, our example
	is broadcast for EPSON printer where the socket is not
	bound to source address

	__mkroute_output caches the things as follows:

	rt_key_dst = 255.255.255.255 (orig_daddr)
	rt_key_src = 0.0.0.0 (orig_saddr), because not bound
	rt_mark = 0
	rt_key_tos = 0 (RT TOS from iph->tos)
	rt_oif = 0 (orig_oif), because not bound to output device
	rt_iif = eth0 (orig_oif or dev_out->ifindex), dev_out in our case

	not compared by compare_keys:
	rt_route_iif = 0 (always for output route)

	use hash chain based on some keys and orig_oif

	Now when we put rt_intern_hash in the game, it tries to
reuse existing entries in the cache by using compare_keys.
It is hard to hit the problem because input and output
routes use different hashing based on iif/orig_oif.

	The problem: if we have input route in the cache
it can be returned to callers that request output route.
That is why dst_output points to ip_rt_bug.

	As noted above, compare_keys must consider rt_route_iif.
It must be also considered by ip_route_input_common.

	The appended patch fixes the problem for me. I was
able to reproduce ip_rt_bug by using rhash_entries=1 (resulting
in rt_hash_mask=1) and increasing gc_thresh to 8, so that
I can send these 2 packets with custom programs and the
cache entries to live longer in cache.

===============================================================

[PATCH] ipv4: fix the reusing of routing cache entries

	compare_keys and ip_route_input_common rely on
rt_oif for distinguishing of input and output routes
with same keys values. But sometimes the input route has
also same hash chain (keyed by iif != 0) with the output
routes (keyed by orig_oif=0). Problem visible if running
with small number of rhash_entries.

	Fix them to use rt_route_iif instead. By this way
input route can not be returned to users that request
output route.

	The patch fixes the ip_rt_bug errors that were
reported in ip_local_out context, mostly for 255.255.255.255
destinations.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	This is for 3.0, didn't checked net-next yet.

diff -urp v3.0/linux/net/ipv4/route.c linux/net/ipv4/route.c
--- v3.0/linux/net/ipv4/route.c	2011-07-22 09:43:33.000000000 +0300
+++ linux/net/ipv4/route.c	2011-08-06 18:15:17.841066642 +0300
@@ -725,6 +725,7 @@ static inline int compare_keys(struct rt
 		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
 		(rt1->rt_mark ^ rt2->rt_mark) |
 		(rt1->rt_key_tos ^ rt2->rt_key_tos) |
+		(rt1->rt_route_iif ^ rt2->rt_route_iif) |
 		(rt1->rt_oif ^ rt2->rt_oif) |
 		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
 }
@@ -2281,8 +2282,8 @@ int ip_route_input_common(struct sk_buff
 		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
 		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
 		     (rth->rt_iif ^ iif) |
-		     rth->rt_oif |
 		     (rth->rt_key_tos ^ tos)) == 0 &&
+		    rt_is_input_route(rth) &&
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
