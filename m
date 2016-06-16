From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] net: ipv6: Move ip6_route_get_saddr to inline
Date: Thu, 16 Jun 2016 16:24:24 -0700
Message-ID: <1466119466-3144-2-git-send-email-dsa@cumulusnetworks.com>
References: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34451 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbcFPXYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:24:35 -0400
Received: by mail-pa0-f51.google.com with SMTP id bz2so22338773pad.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 16:24:34 -0700 (PDT)
In-Reply-To: <1466119466-3144-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRF driver needs access to ip6_route_get_saddr code. Since it does
little beyond ipv6_dev_get_saddr and ipv6_dev_get_saddr is already
exported for modules move ip6_route_get_saddr to the header as an
inline.

Code move only; no functional change.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip6_route.h | 21 ++++++++++++++++++---
 net/ipv6/route.c        | 17 -----------------
 2 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f55bf3d294aa..d97305d0e71f 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -18,6 +18,7 @@ struct route_info {
 	__u8			prefix[0];	/* 0,8 or 16 */
 };
 
+#include <net/addrconf.h>
 #include <net/flow.h>
 #include <net/ip6_fib.h>
 #include <net/sock.h>
@@ -88,9 +89,23 @@ int ip6_route_add(struct fib6_config *cfg);
 int ip6_ins_rt(struct rt6_info *);
 int ip6_del_rt(struct rt6_info *);
 
-int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
-			const struct in6_addr *daddr, unsigned int prefs,
-			struct in6_addr *saddr);
+static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
+				      const struct in6_addr *daddr,
+				      unsigned int prefs,
+				      struct in6_addr *saddr)
+{
+	struct inet6_dev *idev =
+			rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
+	int err = 0;
+
+	if (rt && rt->rt6i_prefsrc.plen)
+		*saddr = rt->rt6i_prefsrc.addr;
+	else
+		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					 daddr, prefs, saddr);
+
+	return err;
+}
 
 struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int flags);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9e1516785dac..08b77f421268 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2586,23 +2586,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	return rt;
 }
 
-int ip6_route_get_saddr(struct net *net,
-			struct rt6_info *rt,
-			const struct in6_addr *daddr,
-			unsigned int prefs,
-			struct in6_addr *saddr)
-{
-	struct inet6_dev *idev =
-		rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
-	int err = 0;
-	if (rt && rt->rt6i_prefsrc.plen)
-		*saddr = rt->rt6i_prefsrc.addr;
-	else
-		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-					 daddr, prefs, saddr);
-	return err;
-}
-
 /* remove deleted ip from prefsrc entries */
 struct arg_dev_net_ip {
 	struct net_device *dev;
-- 
2.1.4
