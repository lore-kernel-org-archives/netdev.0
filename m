From: weidong <weid@np.css.fujitsu.com>
Subject: (usagi-users 03785) Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
	packets
Date: Wed, 31 Jan 2007 04:29:49 +0000 (UTC)
Message-ID: <1172119906.2658.4.camel__17187.3178835542$1170217789$gmane$org@LINE>
References: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org, davem@davemloft.net
To: yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
Date: Wed, 21 Feb 2007 23:51:45 -0500
In-Reply-To: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
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
