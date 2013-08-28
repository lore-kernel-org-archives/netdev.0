From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 01/11] ipv6: make ip6_dst_hoplimit() static inline
Date: Wed, 28 Aug 2013 13:22:49 +0800
Message-ID: <1377667379-2315-2-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942Ab3H1FXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:25 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It will be used by vxlan.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ip6_route.h |   23 +++++++++++++++++++++--
 net/ipv6/route.c        |   19 -------------------
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f667248..2afcd0d 100644
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
@@ -203,4 +202,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
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
index 55236a8..b770085 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1354,25 +1354,6 @@ out:
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
