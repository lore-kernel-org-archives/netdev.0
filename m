From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 11/13] [RFC] [IPV6] Merge ipv6_dev_get_saddr() and ipv6_get_saddr().
Date: Tue, 17 Oct 2006 03:24:22 +0300
Message-ID: <453422B6.7060507@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:16146 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422979AbWJQAYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:24:24 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The split into ipv6_get_saddr() and ipv6_dev_get_saddr() isn't necessary
anymore, so they can be merged into just the function ipv6_get_saddr().

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 include/net/addrconf.h |    5 +----
 net/ipv6/addrconf.c    |   21 ++++++---------------
 net/ipv6/ndisc.c       |    2 +-
 net/ipv6/route.c       |    5 +++--
 4 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 44f1b67..d075693 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -67,10 +67,7 @@ #endif
 extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
 						struct net_device *dev,
 						int strict);
-extern int			ipv6_get_saddr(struct dst_entry *dst,
-					       struct in6_addr *daddr,
-					       struct in6_addr *saddr);
-extern int			ipv6_dev_get_saddr(struct net_device *dev,
+extern int			ipv6_get_saddr(int pref_if,
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
 extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c186763..09a22c8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -904,8 +904,7 @@ static int inline ipv6_saddr_label(const
 	return 1;
 }

-int ipv6_dev_get_saddr(struct net_device *daddr_dev,
-		       struct in6_addr *daddr, struct in6_addr *saddr)
+int ipv6_get_saddr(int pref_if, struct in6_addr *daddr, struct in6_addr *saddr)
 {
 	struct ipv6_saddr_score hiscore;
 	struct inet6_ifaddr *ifa_result = NULL;
@@ -937,7 +936,7 @@ int ipv6_dev_get_saddr(struct net_device
 		 */
 		if ((daddr_type & IPV6_ADDR_MULTICAST ||
 		     daddr_scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
-		    daddr_dev && dev != daddr_dev)
+		    pref_if && dev->ifindex != pref_if)
 			continue;

 		idev = __in6_dev_get(dev);
@@ -1062,13 +1061,13 @@ #endif

 			/* Rule 5: Prefer outgoing interface */
 			if (hiscore.rule < 5) {
-				if (daddr_dev == NULL ||
-				    daddr_dev == ifa_result->idev->dev)
+				if (!pref_if ||
+				    pref_if == ifa_result->idev->dev->ifindex)
 					hiscore.attrs |= IPV6_SADDR_SCORE_OIF;
 				hiscore.rule++;
 			}
-			if (daddr_dev == NULL ||
-			    daddr_dev == ifa->idev->dev) {
+			if (!pref_if ||
+			    pref_if == ifa->idev->dev->ifindex) {
 				score.attrs |= IPV6_SADDR_SCORE_OIF;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_OIF)) {
 					score.rule = 5;
@@ -1158,14 +1157,6 @@ record_it:
 	return 0;
 }

-
-int ipv6_get_saddr(struct dst_entry *dst,
-		   struct in6_addr *daddr, struct in6_addr *saddr)
-{
-	return ipv6_dev_get_saddr(dst ? ((struct rt6_info *)dst)->rt6i_idev->dev : NULL, daddr, saddr);
-}
-
-
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0304b5f..3ac4e12 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -449,7 +449,7 @@ static void ndisc_send_na(struct net_dev
 		src_addr = solicited_addr;
 		in6_ifa_put(ifp);
 	} else {
-		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
+		if (ipv6_get_saddr(dev->ifindex, daddr, &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b7b8148..7cd7747 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -748,8 +748,9 @@ restart:
 	read_unlock_bh(&table->tb6_lock);

 	if (!has_saddr) {
+		int oif = rt->rt6i_dev->ifindex;
 		/* policy rule doesn't restrict source address */
-		if (ipv6_get_saddr(&rt->u.dst, &fl->fl6_dst, &saddr))
+		if (ipv6_get_saddr(oif, &fl->fl6_dst, &saddr))
 			goto no_saddr;
 		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
 		ipv6_addr_copy(&fl->fl6_src, &saddr);
@@ -2051,7 +2052,7 @@ #endif
 		NLA_PUT_U32(skb, RTA_IIF, iif);
 	else if (dst) {
 		struct in6_addr saddr_buf;
-		if (!ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf))
+		if (!ipv6_get_saddr(rt->rt6i_dev->ifindex, dst, &saddr_buf))
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}

-- 
1.4.2.3

