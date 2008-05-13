From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 stateless address autoconfiguration
Date: Tue, 13 May 2008 10:42:15 +0900 (JST)
Message-ID: <20080513.104215.82952085.yoshfuji@linux-ipv6.org>
References: <OFEAF0762D.B7C9C8DD-ON88257447.005CE64E-88257447.005D6A63@us.ibm.com>
	<20080513.021736.125105716.yoshfuji@linux-ipv6.org>
	<BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Joseph.Bonitch@xerox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40078 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669AbYEMBmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 21:42:00 -0400
In-Reply-To: <BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <BECE1C148A85274EB554378A3E0EDF4906388E17@USA0300MS02.na.xerox.net> (at Mon, 12 May 2008 15:36:57 -0400), "Bonitch, Joseph" <Joseph.Bonitch@xerox.com> says:

> I did some testing with the second patch.  My router is still configured
> to send RA's with prefix information valid_lft = preferred_lft = 0xffffffff.
> It works except for one thing: the initial prefix route (after the first RA)
> shows an expire time when using
>    ip -6 route list
> If I keep checking I can see the expires time counting down.  After some
> minutes the expires field disappeares from the ip -6 route list output.
> I tracked it down and it looks like when a subsequent RA is received
> with the same prefix is when the expires time stops showing up.

Thanks.  I had missed sevral other users of addrconf_prefix_route().
Please try this.

----
[IPV6] ADDRCONF: Allow infinite prefix lifetime.

We need to handle infinite prefix lifetime specially.
Issue reported by "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   73 ++++++++++++++++++++++++++++++++++----------------
 1 files changed, 49 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..3a78021 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1764,14 +1764,16 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	 *	2) Configure prefixes with the auto flag set
 	 */
 
-	/* Avoid arithmetic overflow. Really, we could
-	   save rt_expires in seconds, likely valid_lft,
-	   but it would require division in fib gc, that it
-	   not good.
-	 */
-	if (valid_lft >= 0x7FFFFFFF/HZ)
+	if (valid_lft == INFINITY_LIFE_TIME)
+		rt_expires = ~0UL;
+	else if (valid_lft >= 0x7FFFFFFF/HZ) {
+		/* Avoid arithmetic overflow. Really, we could
+		 * save rt_expires in seconds, likely valid_lft,
+		 * but it would require division in fib gc, that it
+		 * not good.
+		 */
 		rt_expires = 0x7FFFFFFF - (0x7FFFFFFF % HZ);
-	else
+	} else
 		rt_expires = valid_lft * HZ;
 
 	/*
@@ -1779,7 +1781,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	 * Avoid arithmetic overflow there as well.
 	 * Overflow can happen only if HZ < USER_HZ.
 	 */
-	if (HZ < USER_HZ && rt_expires > 0x7FFFFFFF / USER_HZ)
+	if (HZ < USER_HZ && ~rt_expires && rt_expires > 0x7FFFFFFF / USER_HZ)
 		rt_expires = 0x7FFFFFFF / USER_HZ;
 
 	if (pinfo->onlink) {
@@ -1788,17 +1790,28 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 				dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
-			if (rt->rt6i_flags&RTF_EXPIRES) {
-				if (valid_lft == 0) {
-					ip6_del_rt(rt);
-					rt = NULL;
-				} else {
-					rt->rt6i_expires = jiffies + rt_expires;
-				}
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
@@ -2021,7 +2034,8 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	struct inet6_dev *idev;
 	struct net_device *dev;
 	int scope;
-	u32 flags = RTF_EXPIRES;
+	u32 flags;
+	clock_t expires;
 
 	ASSERT_RTNL();
 
@@ -2041,8 +2055,13 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	if (valid_lft == INFINITY_LIFE_TIME) {
 		ifa_flags |= IFA_F_PERMANENT;
 		flags = 0;
-	} else if (valid_lft >= 0x7FFFFFFF/HZ)
-		valid_lft = 0x7FFFFFFF/HZ;
+		expires = 0;
+	} else {
+		if (valid_lft >= 0x7FFFFFFF/HZ)
+			valid_lft = 0x7FFFFFFF/HZ;
+		flags = RTF_EXPIRES;
+		expires = jiffies_to_clock_t(valid_lft * HZ);
+	}
 
 	if (prefered_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
@@ -2060,7 +2079,7 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 		spin_unlock_bh(&ifp->lock);
 
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
-				      jiffies_to_clock_t(valid_lft * HZ), flags);
+				      expires, flags);
 		/*
 		 * Note that section 3.1 of RFC 4429 indicates
 		 * that the Optimistic flag should not be set for
@@ -3148,7 +3167,8 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 			     u32 prefered_lft, u32 valid_lft)
 {
-	u32 flags = RTF_EXPIRES;
+	u32 flags;
+	clock_t expires;
 
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
@@ -3156,8 +3176,13 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 	if (valid_lft == INFINITY_LIFE_TIME) {
 		ifa_flags |= IFA_F_PERMANENT;
 		flags = 0;
-	} else if (valid_lft >= 0x7FFFFFFF/HZ)
-		valid_lft = 0x7FFFFFFF/HZ;
+		expires = 0;
+	} else {
+		if (valid_lft >= 0x7FFFFFFF/HZ)
+			valid_lft = 0x7FFFFFFF/HZ;
+		flags = RTF_EXPIRES;
+		expires = jiffies_to_clock_t(valid_lft * HZ);
+	}
 
 	if (prefered_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
@@ -3176,7 +3201,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 		ipv6_ifa_notify(0, ifp);
 
 	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
-			      jiffies_to_clock_t(valid_lft * HZ), flags);
+			      expires, flags);
 	addrconf_verify(0);
 
 	return 0;
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
