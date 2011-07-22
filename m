From: David Miller <davem@davemloft.net>
Subject: Re: icmp_route_lookup returns wrong source address information
Date: Fri, 22 Jul 2011 06:23:02 -0700 (PDT)
Message-ID: <20110722.062302.350752564450519025.davem@davemloft.net>
References: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab1GVNXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 09:23:07 -0400
In-Reply-To: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 20 Jul 2011 21:22:58 +0200

> Problem is that xfrm_decode_session_reverse() may rebuild fl4 from scratch.
> 
> In my setup, "goto relookup_failed" will be hit a bit later on, and fl4->saddr will
> be set to iph->daddr...

Indeed, we can't use this new fl4 until we commit to using 'rt2'.

Please give this patch a try:

--------------------
icmp: Fix regression in nexthop resolution during replies.

icmp_route_lookup() uses the wrong flow parameters if the reverse
session route lookup isn't used.

So do not commit to the re-decoded flow until we actually make a
final decision to use a real route saved in 'rt2'.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5395e45..23ef31b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -380,6 +380,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 					struct icmp_bxm *param)
 {
 	struct rtable *rt, *rt2;
+	struct flowi4 fl4_dec;
 	int err;
 
 	memset(fl4, 0, sizeof(*fl4));
@@ -408,19 +409,19 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	} else
 		return rt;
 
-	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(fl4), AF_INET);
+	err = xfrm_decode_session_reverse(skb_in, flowi4_to_flowi(&fl4_dec), AF_INET);
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type(net, fl4->saddr) == RTN_LOCAL) {
-		rt2 = __ip_route_output_key(net, fl4);
+	if (inet_addr_type(net, fl4_dec.saddr) == RTN_LOCAL) {
+		rt2 = __ip_route_output_key(net, &fl4_dec);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
 	} else {
 		struct flowi4 fl4_2 = {};
 		unsigned long orefdst;
 
-		fl4_2.daddr = fl4->saddr;
+		fl4_2.daddr = fl4_dec.saddr;
 		rt2 = ip_route_output_key(net, &fl4_2);
 		if (IS_ERR(rt2)) {
 			err = PTR_ERR(rt2);
@@ -428,7 +429,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 		}
 		/* Ugh! */
 		orefdst = skb_in->_skb_refdst; /* save old refdst */
-		err = ip_route_input(skb_in, fl4->daddr, fl4->saddr,
+		err = ip_route_input(skb_in, fl4_dec.daddr, fl4_dec.saddr,
 				     RT_TOS(tos), rt2->dst.dev);
 
 		dst_release(&rt2->dst);
@@ -440,10 +441,11 @@ static struct rtable *icmp_route_lookup(struct net *net,
 		goto relookup_failed;
 
 	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
-					    flowi4_to_flowi(fl4), NULL,
+					    flowi4_to_flowi(&fl4_dec), NULL,
 					    XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(rt2)) {
 		dst_release(&rt->dst);
+		memcpy(fl4, &fl4_dec, sizeof(*fl4));
 		rt = rt2;
 	} else if (PTR_ERR(rt2) == -EPERM) {
 		if (rt)
-- 
1.7.6

