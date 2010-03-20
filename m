From: David Miller <davem@davemloft.net>
Subject: [PATCH] Fix bug in addrconf hlist conversion
Date: Sat, 20 Mar 2010 16:19:25 -0700 (PDT)
Message-ID: <20100320.161925.52172552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59372
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515Ab0CTXTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:19:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Committed to net-next-2.6

ipv6: Fix bug in ipv6_chk_same_addr().

hlist_for_each_entry(p...) will not necessarily initialize 'p'
to anything if the hlist is empty.  GCC notices this and emits
a warning.

Just return true explicitly when we hit a match, and return
false is we fall out of the loop without one.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/addrconf.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7d7d4b1..68e5809 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -155,8 +155,8 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 				struct prefix_info *pinfo);
-static int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
-			      struct net_device *dev);
+static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
+			       struct net_device *dev);
 
 static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
 
@@ -1295,23 +1295,22 @@ int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 
-static
-int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
-		       struct net_device *dev)
+static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
+			       struct net_device *dev)
 {
+	unsigned int hash = ipv6_addr_hash(addr);
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
-	unsigned int hash = ipv6_addr_hash(addr);
 
 	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
-				break;
+				return true;
 		}
 	}
-	return ifp != NULL;
+	return false;
 }
 
 int ipv6_chk_prefix(struct in6_addr *addr, struct net_device *dev)
-- 
1.6.6.1

