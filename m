From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Thu, 28 Jun 2012 18:45:00 -0700 (PDT)
Message-ID: <20120628.184500.114483408843364230.davem@davemloft.net>
References: <20120628.035946.1026666621448892198.davem@davemloft.net>
	<alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303Ab2F2BpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 21:45:02 -0400
In-Reply-To: <alpine.LFD.2.00.1206282309340.1722@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Fri, 29 Jun 2012 02:16:25 +0300 (EEST)

> 	This is bad for looped m/b-cast: ip_mc_output calls
> ip_dev_loopback_xmit where pkt_type is set to PACKET_LOOPBACK.
> May be we have to check skb_dst as below.

Agreed, for many reasons the pkt_type check is bogus.

> 	It is not clear to me why ip_route_input_mc and
> ip_route_input_slow (brd_input) call fib_validate_source()
> with arg oif=0. How would fib_rule_match match flowi_iif
> for such traffic then?
> 
> 	May be iif should be always set just like in
> ip_route_output_slow because now we do output lookup to
> unicast target?:
> 
> 	fl4.flowi4_iif = net->loopback_dev->ifindex;

Ok.  I am not brave enough to adjust what broadcast and
multicast code do in route.c :-)

> 	Here only 0 is allowed for m/b-cast daddr, we are not
> going to use ip_hdr(skb)->daddr, so no need to provide it:
> 
> 	fl4.saddr = 0;

Agreed.

> 	What about providing ip_hdr(skb)->saddr as
> 2nd argument here (it is validated by input routing
> to be unicast or 0.0.0.0):
 ...
> 	By this way we will prefer local address from the
> same subnet as iph->saddr. Also, we should not call
> fib_lookup if ipv4_is_zeronet(ip_hdr(skb)->saddr), we
> should use RT_SCOPE_LINK for inet_select_addr in this case.
> By this way we will prefer addresses with scope link for
> target 0.0.0.0. There is such logic that uses RT_SCOPE_LINK in
> ip_route_input_mc() and ip_route_input_slow().

Also agreed.

> 	If we use rt_flags above I'm not sure whether
> ip_options_compile is called with valid rt_flags from the
> bridging code.

It will not be the first time we need to fix bridging from
sending up garbage.

Here's what I committed based upon your feedback, thanks!

====================
ipv4: Fix bugs in fib_compute_spec_dst().

Based upon feedback from Julian Anastasov.

1) Use route flags to determine multicast/broadcast, not the
   packet flags.

2) Leave saddr unspecified in flow key.

3) Adjust how we invoke inet_select_addr().  Pass ip_hdr(skb)->saddr as
   second arg, and if it was zeronet use link scope.

4) Use loopback as input interface in flow key.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_frontend.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 63b11ca..1d13217 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -185,28 +185,36 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev;
 	struct fib_result res;
+	struct rtable *rt;
 	struct flowi4 fl4;
 	struct net *net;
+	int scope;
 
-	if (skb->pkt_type != PACKET_BROADCAST &&
-	    skb->pkt_type != PACKET_MULTICAST)
+	rt = skb_rtable(skb);
+	if (!(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)))
 		return ip_hdr(skb)->daddr;
 
 	in_dev = __in_dev_get_rcu(dev);
 	BUG_ON(!in_dev);
-	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = 0;
-	fl4.daddr = ip_hdr(skb)->saddr;
-	fl4.saddr = ip_hdr(skb)->daddr;
-	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
-	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
-	fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
 
 	net = dev_net(dev);
-	if (!fib_lookup(net, &fl4, &res))
-		return FIB_RES_PREFSRC(net, res);
-	else
-		return inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
+
+	scope = RT_SCOPE_UNIVERSE;
+	if (!ipv4_is_zeronet(ip_hdr(skb)->saddr)) {
+		fl4.flowi4_oif = 0;
+		fl4.flowi4_iif = net->loopback_dev->ifindex;
+		fl4.daddr = ip_hdr(skb)->saddr;
+		fl4.saddr = 0;
+		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
+		fl4.flowi4_scope = scope;
+		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
+		if (!fib_lookup(net, &fl4, &res))
+			return FIB_RES_PREFSRC(net, res);
+	} else {
+		scope = RT_SCOPE_LINK;
+	}
+
+	return inet_select_addr(dev, ip_hdr(skb)->saddr, scope);
 }
 
 /* Given (packet source, input interface) and optional (dst, oif, tos):
-- 
1.7.10
