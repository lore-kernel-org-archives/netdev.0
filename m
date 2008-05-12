From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 stateless address autoconfiguration
Date: Tue, 13 May 2008 02:17:36 +0900 (JST)
Message-ID: <20080513.021736.125105716.yoshfuji@linux-ipv6.org>
References: <20080513.004620.117676648.yoshfuji@linux-ipv6.org>
	<OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com, Joseph.Bonitch@xerox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40063 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554AbYELRRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 13:17:20 -0400
In-Reply-To: <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com> (at Mon, 12 May 2008 10:00:21 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > +         } else if (~rt_expires) {
> > +            /* not infinity */
> > +            rt->rt6i_expires = jiffies + rt_expires;
> > +            rt->rt6i_flags |= RTF_EXPIRES;
> 
>         rt_expires is "unsigned long" -- won't the high-order
> bits be set on 64-bit machines?
>         Also, don't you need to check before the divide by
> USER_HZ?

Oops, I'm afraid I sent a wrong file, sorry.

This is the correct version.
(...and I plan to come up with more fixes
for real application on top of the net tree.)

Sighed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..0e2de23 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1769,7 +1769,9 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	   but it would require division in fib gc, that it
 	   not good.
 	 */
-	if (valid_lft >= 0x7FFFFFFF/HZ)
+	if (valid_lft == 0xFFFFFFFF)
+		rt_expires = ~0UL;
+	else if (valid_lft >= 0x7FFFFFFF/HZ)
 		rt_expires = 0x7FFFFFFF - (0x7FFFFFFF % HZ);
 	else
 		rt_expires = valid_lft * HZ;
@@ -1779,7 +1781,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	 * Avoid arithmetic overflow there as well.
 	 * Overflow can happen only if HZ < USER_HZ.
 	 */
-	if (HZ < USER_HZ && rt_expires > 0x7FFFFFFF / USER_HZ)
+	if (HZ < USER_HZ &&
+	    ~rt_expires && rt_expires > 0x7FFFFFFF / USER_HZ)
 		rt_expires = 0x7FFFFFFF / USER_HZ;
 
 	if (pinfo->onlink) {
@@ -1787,18 +1790,29 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
-			if (rt->rt6i_flags&RTF_EXPIRES) {
-				if (valid_lft == 0) {
-					ip6_del_rt(rt);
-					rt = NULL;
-				} else {
-					rt->rt6i_expires = jiffies + rt_expires;
-				}
+		if (rt && (rt->rt6i_flags & (RTF_ADDRCONF | RTF_PREFIX_RT)) == (RTF_ADDRCONF | RTF_PREFIX_RT)) {
+			/* Autoconf prefix route */
+			if (valid_lft == 0) {
+				ip6_del_rt(rt);
+				rt = NULL;
+			} else if (~rt_expires) {
+				/* not infinity */
+				rt->rt6i_expires = jiffies + rt_expires;
+				rt->rt6i_flags |= RTF_EXPIRES;
+			} else {
+				rt->rt6i_flags &= ~RTF_EXPIRES;
+				rt->rt6i_expires = 0;
 			}
 		} else if (valid_lft) {
+			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
+			clock_t expires = 0;
+			if (~rt_expires) {
+				/* not infinity */
+				flags |= RTF_EXPIRES;
+				expires = jiffies_to_clock_t(rt_expires);
+			}
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-					      dev, jiffies_to_clock_t(rt_expires), RTF_ADDRCONF|RTF_EXPIRES|RTF_PREFIX_RT);
+					      dev, expires, flags);
 		}
 		if (rt)
 			dst_release(&rt->u.dst);


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
