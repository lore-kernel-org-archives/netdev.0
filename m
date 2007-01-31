From: weidong <weid@np.css.fujitsu.com>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
	packets
Date: Wed, 31 Jan 2007 04:11:53 +0000 (UTC)
Message-ID: <1172119906.2658.4.camel@LINE>
References: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	davem@davemloft.net
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:46574 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbXAaELd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 23:11:33 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l0V4BUDW020705
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Wed, 31 Jan 2007 13:11:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB8D62AC127
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 13:11:30 +0900 (JST)
Received: from s12.gw.fujitsu.co.jp (s12.gw.fujitsu.co.jp [10.0.50.82])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A37B212C066
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 13:11:30 +0900 (JST)
Received: from s12.gw.fujitsu.co.jp (s12 [127.0.0.1])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CEED161C007
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 13:11:30 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 14F62161C00A
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 13:11:30 +0900 (JST)
In-Reply-To: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
Date: Wed, 21 Feb 2007 23:51:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Mr yoshfuji
	Thanks for your patch. I think maybe we checking oif first is better,
and WARN_ON in function rt6_score_route().
The following is my patch

Signed-off-by: Wei Dong <weid@np.css.fujitsu.com>

diff -ruN old/net/ipv6/route.c new/net/ipv6/route.c
--- old/net/ipv6/route.c	2007-02-16 13:46:33.000000000 -0500
+++ new/net/ipv6/route.c	2007-02-16 13:44:27.000000000 -0500
@@ -309,12 +309,21 @@
 static int inline rt6_check_dev(struct rt6_info *rt, int oif)
 {
 	struct net_device *dev = rt->rt6i_dev;
-	if (!oif || dev->ifindex == oif)
+	int ret = 0;
+
+	if (!oif)
 		return 2;
+
 	if ((dev->flags & IFF_LOOPBACK) &&
 	    rt->rt6i_idev && rt->rt6i_idev->dev->ifindex == oif)
-		return 1;
-	return 0;
+		ret = 1;
+	else
+		return 0;
+
+	if (dev->ifindex == oif)
+		return 2;
+
+	return ret;
 }
 
 static int inline rt6_check_neigh(struct rt6_info *rt)
@@ -339,8 +348,11 @@
 	int m, n;
 		
 	m = rt6_check_dev(rt, oif);
-	if (!m && (strict & RT6_LOOKUP_F_IFACE))
+	if (!m && (strict & RT6_LOOKUP_F_IFACE)) {
+		WARN_ON(rt->rt6i_dev->flags & IFF_LOOPBACK);
 		return -1;
+	}
+
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
 #endif


On Wed, 2007-01-31 at 13:00 +0900, Wei Dong wrote:
> In article <1172069832.2682.18.camel@LINE> (at Wed, 21 Feb 2007 
> 09:57:12 -0500), weidong <weid@np.css.fujitsu.com> says:
> 
> > The following is the figure.
> :
> > Host eth0: fe80::200:ff:fe00:100
> > Router eth0: fe80::20c:29ff:fe24:fa0a
> > Router eth1: fe80::20c:29ff:fe24:fa14
> 
>  Other network
>       |
>       | eth1
>  +----+----+
>  | Router  |
>  +----+----+
>       | eth0
>       |
>       | eth0
>  +----+----+
>  |  Host   |
>  +---------+
> 
> > We ping6 from host's eth0 to Router's eth1. Echo Request's src addr =
> > fe80::200:ff:fe00:100, dst addr = fe80::20c:29ff:fe24:fa14. And Kernel
> > just send ICMPv6 redirect packet and then forward the Echo Request to
> > router's eth0. If we run tcpdump on Host eth0, we can receive the ICMPv6
> > Redirect packet. And if we send NA which advertises
> 
> This is correct, and intended behavior.
> 
> > fe80::20c:29ff:fe24:fa14 MAC address(this is very easy for v6eval tool),
> > we also can receive the forwarded Echo Request(src:fe80::200:ff:fe00:100
> > dst is fe80::20c:29ff:fe24:fa14).
> 
> Well, this is known issue, actually.
> 
> While this cannot happen in normal operation, we should NOT accept
> such traffic. :-)
> 
> Here is the (untested) fix.
> 
> -----
> [IPV6] ROUTE: Do not accept traffic for link-local address on different 
> interface.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> --- 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 5f0043c..a7468e0 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -311,12 +311,19 @@ static inline void rt6_probe(struct rt6_info *rt)
>  static int inline rt6_check_dev(struct rt6_info *rt, int oif)
>  {
>   struct net_device *dev = rt->rt6i_dev;
> + int ret = 0;
> +
> + if (dev->flags & IFF_LOOPBACK) {
> + if (!WARN_ON(rt->rt6i_idev == NULL) &&
> +     rt->rt6i_idev->dev->ifindex == oif)
> + ret = 1;
> + else
> + return 0;
> + }
>   if (!oif || dev->ifindex == oif)
>   return 2;
> - if ((dev->flags & IFF_LOOPBACK) &&
> -     rt->rt6i_idev && rt->rt6i_idev->dev->ifindex == oif)
> - return 1;
> - return 0;
> +
> + return ret;
>  }
> 
>  static int inline rt6_check_neigh(struct rt6_info *rt)
> 

