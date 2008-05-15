From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 4/4] [IPV6] ADDRCONF: Allow longer lifetime on
 64bit archs.
Date: Thu, 15 May 2008 18:18:26 +0900 (JST)
Message-ID: <20080515.181826.45075746.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44231 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbYEOJSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:18:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow longer lifetimes (>= 0x7fffffff/HZ) on 64bit archs
by using unsigned long.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   22 +++++++++++++++++++---
 net/ipv6/route.c    |    4 +++-
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a78021..0d89370 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -731,8 +731,11 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 						onlink = -1;
 
 					spin_lock(&ifa->lock);
-					lifetime = min_t(unsigned long,
-							 ifa->valid_lft, 0x7fffffffUL/HZ);
+					lifetime = ifa->valid_lft;
+#if BITS_PER_LONG < 64
+					if (lifetime > 0x7FFFFFFFUL/HZ)
+						lifetime = 0x7FFFFFFFUL/HZ;
+#endif
 					if (time_before(expires,
 							ifa->tstamp + lifetime * HZ))
 						expires = ifa->tstamp + lifetime * HZ;
@@ -1766,6 +1769,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 	if (valid_lft == INFINITY_LIFE_TIME)
 		rt_expires = ~0UL;
+#if BITS_PER_LONG < 64
 	else if (valid_lft >= 0x7FFFFFFF/HZ) {
 		/* Avoid arithmetic overflow. Really, we could
 		 * save rt_expires in seconds, likely valid_lft,
@@ -1773,9 +1777,12 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		 * not good.
 		 */
 		rt_expires = 0x7FFFFFFF - (0x7FFFFFFF % HZ);
-	} else
+	}
+#endif
+	else
 		rt_expires = valid_lft * HZ;
 
+#if BITS_PER_LONG < 64
 	/*
 	 * We convert this (in jiffies) to clock_t later.
 	 * Avoid arithmetic overflow there as well.
@@ -1783,6 +1790,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	 */
 	if (HZ < USER_HZ && ~rt_expires && rt_expires > 0x7FFFFFFF / USER_HZ)
 		rt_expires = 0x7FFFFFFF / USER_HZ;
+#endif
 
 	if (pinfo->onlink) {
 		struct rt6_info *rt;
@@ -2057,17 +2065,21 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 		flags = 0;
 		expires = 0;
 	} else {
+#if BITS_PER_LONG < 64
 		if (valid_lft >= 0x7FFFFFFF/HZ)
 			valid_lft = 0x7FFFFFFF/HZ;
+#endif
 		flags = RTF_EXPIRES;
 		expires = jiffies_to_clock_t(valid_lft * HZ);
 	}
 
 	if (prefered_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
+#if BITS_PER_LONG < 64
 	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
 		 (prefered_lft != INFINITY_LIFE_TIME))
 		prefered_lft = 0x7FFFFFFF/HZ;
+#endif
 
 	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
 
@@ -3178,17 +3190,21 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 		flags = 0;
 		expires = 0;
 	} else {
+#if BITS_PER_LONG < 64
 		if (valid_lft >= 0x7FFFFFFF/HZ)
 			valid_lft = 0x7FFFFFFF/HZ;
+#endif
 		flags = RTF_EXPIRES;
 		expires = jiffies_to_clock_t(valid_lft * HZ);
 	}
 
 	if (prefered_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
+#if BITS_PER_LONG < 64
 	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
 		 (prefered_lft != INFINITY_LIFE_TIME))
 		prefered_lft = 0x7FFFFFFF/HZ;
+#endif
 
 	spin_lock_bh(&ifp->lock);
 	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b7a4a87..e35bf90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -446,7 +446,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	struct route_info *rinfo = (struct route_info *) opt;
 	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
-	u32 lifetime;
+	unsigned long lifetime;
 	struct rt6_info *rt;
 
 	if (len < sizeof(struct route_info)) {
@@ -473,12 +473,14 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		pref = ICMPV6_ROUTER_PREF_MEDIUM;
 
 	lifetime = ntohl(rinfo->lifetime);
+#if BITS_PER_LONG < 64
 	if (lifetime == 0xffffffff) {
 		/* infinity */
 	} else if (lifetime > 0x7fffffff/HZ - 1) {
 		/* Avoid arithmetic overflow */
 		lifetime = 0x7fffffff/HZ - 1;
 	}
+#endif
 
 	if (rinfo->length == 3)
 		prefix = (struct in6_addr *)rinfo->prefix;
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
