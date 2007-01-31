From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Wed, 31 Jan 2007 10:08:32 +0900 (JST)
Message-ID: <20070131.100832.42510960.yoshfuji@linux-ipv6.org>
References: <001501c7444d$ed731020$ccb1220a@ZhaoleiSOTEC>
	<1172069832.2682.18.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47554 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbXAaBHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 20:07:18 -0500
In-Reply-To: <1172069832.2682.18.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1172069832.2682.18.camel@LINE> (at Wed, 21 Feb 2007 09:57:12 -0500), weidong <weid@np.css.fujitsu.com> says:

> The following is the figure.
:
> Host eth0: fe80::200:ff:fe00:100
> Router eth0: fe80::20c:29ff:fe24:fa0a
> Router eth1: fe80::20c:29ff:fe24:fa14

 Other network
      |
      | eth1
 +----+----+
 | Router  |
 +----+----+
      | eth0
      |
      | eth0
 +----+----+
 |  Host   |
 +---------+

> We ping6 from host's eth0 to Router's eth1. Echo Request's src addr =
> fe80::200:ff:fe00:100, dst addr = fe80::20c:29ff:fe24:fa14. And Kernel
> just send ICMPv6 redirect packet and then forward the Echo Request to
> router's eth0. If we run tcpdump on Host eth0, we can receive the ICMPv6
> Redirect packet. And if we send NA which advertises

This is correct, and intended behavior.

> fe80::20c:29ff:fe24:fa14 MAC address(this is very easy for v6eval tool),
> we also can receive the forwarded Echo Request(src:fe80::200:ff:fe00:100
> dst is fe80::20c:29ff:fe24:fa14). 

Well, this is known issue, actually.

While this cannot happen in normal operation, we should NOT accept
such traffic. :-)

Here is the (untested) fix.

-----
[IPV6] ROUTE: Do not accept traffic for link-local address on different interface.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5f0043c..a7468e0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -311,12 +311,19 @@ static inline void rt6_probe(struct rt6_info *rt)
 static int inline rt6_check_dev(struct rt6_info *rt, int oif)
 {
 	struct net_device *dev = rt->rt6i_dev;
+	int ret = 0;
+
+	if (dev->flags & IFF_LOOPBACK) {
+		if (!WARN_ON(rt->rt6i_idev == NULL) &&
+		    rt->rt6i_idev->dev->ifindex == oif)
+			ret = 1;
+		else
+			return 0;
+	}
 	if (!oif || dev->ifindex == oif)
 		return 2;
-	if ((dev->flags & IFF_LOOPBACK) &&
-	    rt->rt6i_idev && rt->rt6i_idev->dev->ifindex == oif)
-		return 1;
-	return 0;
+
+	return ret;
 }
 
 static int inline rt6_check_neigh(struct rt6_info *rt)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
