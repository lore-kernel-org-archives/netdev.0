From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static inline
Date: Fri, 17 May 2013 08:21:30 +0800
Message-ID: <1368750099-14086-3-git-send-email-amwang@redhat.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913Ab3EQAVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 20:21:53 -0400
In-Reply-To: <1368750099-14086-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It will be used by vxlan module, so move it from ipv6 module
to core kernel. I think it is small enough to be inlined.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ip6_route.h |   23 +++++++++++++++++++++--
 net/ipv6/route.c        |   19 -------------------
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 260f83f..7e9192e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -21,6 +21,7 @@ struct route_info {
 #include <net/flow.h>
 #include <net/ip6_fib.h>
 #include <net/sock.h>
+#include <net/addrconf.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/route.h>
@@ -112,8 +113,6 @@ extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					   const struct in6_addr *addr,
 					   bool anycast);
 
-extern int			ip6_dst_hoplimit(struct dst_entry *dst);
-
 /*
  *	support functions for ND
  *
@@ -201,4 +200,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
 	return dest;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int ip6_dst_hoplimit(struct dst_entry *dst)
+{
+	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
+	if (hoplimit == 0) {
+		struct net_device *dev = dst->dev;
+		struct inet6_dev *idev;
+
+		rcu_read_lock();
+		idev = __in6_dev_get(dev);
+		if (idev)
+			hoplimit = idev->cnf.hop_limit;
+		else
+			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
+		rcu_read_unlock();
+	}
+	return hoplimit;
+}
+#endif
+
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad0aa6b..0d9c531 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1310,25 +1310,6 @@ out:
 	return entries > rt_max_size;
 }
 
-int ip6_dst_hoplimit(struct dst_entry *dst)
-{
-	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
-	if (hoplimit == 0) {
-		struct net_device *dev = dst->dev;
-		struct inet6_dev *idev;
-
-		rcu_read_lock();
-		idev = __in6_dev_get(dev);
-		if (idev)
-			hoplimit = idev->cnf.hop_limit;
-		else
-			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
-		rcu_read_unlock();
-	}
-	return hoplimit;
-}
-EXPORT_SYMBOL(ip6_dst_hoplimit);
-
 /*
  *
  */
-- 
1.7.7.6
