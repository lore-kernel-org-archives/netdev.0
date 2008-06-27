From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-users 04056) Re: ping6 is sent out from wrong interface
Date: Sat, 28 Jun 2008 04:14:04 +0900 (JST)
Message-ID: <20080628.041404.82719082.yoshfuji@linux-ipv6.org>
References: <4861ED72.6080100@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org
To: usagi-users@ml.linux-ipv6.org, nooiwa@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60308 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756842AbYF0TNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 15:13:05 -0400
In-Reply-To: <4861ED72.6080100@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4861ED72.6080100@miraclelinux.com> (at Wed, 25 Jun 2008 16:02:10 +0900), Naohiro Ooiwa <nooiwa@miraclelinux.com> says:

> Hi YOSHIFUJI-san
> 
> Thank you for your reply.
> 
> > -I does not specify interface strictly but source address.
> > Which means, if you just specify an address, interface is unspecified.
> > You can give "-I eth1", too.
> 
> I'm not convinced yet.
> I don't think it's correct that kernel or ping6 arbitrarily decides outgoing interface.
> 
> Is this really an expected behaviour?
> Could you explain to me the reason of it, too?

I have to agree it is rather strange (or not natural), but, I do not
agree with the solution.

In theory, outgoing interface must be selected by routing, if unspecified.
So, I'd propose something like this (not tested, not for real patch).

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d1f3e19..81ddf9a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -239,17 +239,28 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
 static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
+						    struct in6_addr *saddr,
 						    int oif,
 						    int strict)
 {
 	struct rt6_info *local = NULL;
 	struct rt6_info *sprt;
 
-	if (oif) {
-		for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
-			struct net_device *dev = sprt->rt6i_dev;
+	if (!oif && ipv6_addr_any(saddr))
+		saddr = NULL;
+
+	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+		struct net_device *dev = sprt->rt6i_dev;
+
+		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
+		} else {
+			if (saddr && ipv6_chk_addr(net, saddr, dev, strict))
+				return sprt;
+		}
+
+		if (oif) {
 			if (dev->flags & IFF_LOOPBACK) {
 				if (sprt->rt6i_idev == NULL ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
@@ -261,13 +272,13 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 				}
 				local = sprt;
 			}
-		}
 
-		if (local)
-			return local;
+			if (local)
+				return local;
 
-		if (strict)
-			return net->ipv6.ip6_null_entry;
+			if (strict)
+				return net->ipv6.ip6_null_entry;
+		}
 	}
 	return rt;
 }
@@ -541,7 +552,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, fl->oif, flags);
+	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->oif, flags);
 	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_use(&rt->u.dst, jiffies);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
