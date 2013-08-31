From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v12 01/11] ipv6: move ip6_dst_hoplimit() into core kernel
Date: Sat, 31 Aug 2013 13:44:28 +0800
Message-ID: <1377927878-23975-2-git-send-email-amwang@redhat.com>
References: <1377927878-23975-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260Ab3HaFot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 01:44:49 -0400
In-Reply-To: <1377927878-23975-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It will be used by vxlan, and may not be inlined.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/ip6_route.h |    2 --
 include/net/ipv6.h      |    2 ++
 net/ipv6/output_core.c  |   22 ++++++++++++++++++++++
 net/ipv6/route.c        |   19 -------------------
 4 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f667248..f525e70 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -112,8 +112,6 @@ extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					   const struct in6_addr *addr,
 					   bool anycast);
 
-extern int			ip6_dst_hoplimit(struct dst_entry *dst);
-
 /*
  *	support functions for ND
  *
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7bdff04..bbf1c8f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -658,6 +658,8 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 
 extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 
+extern int ip6_dst_hoplimit(struct dst_entry *dst);
+
 /*
  *	Header manipulation
  */
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index ab92a36..53a0621 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -5,6 +5,7 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+#include <net/addrconf.h>
 
 void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 {
@@ -75,3 +76,24 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 	return offset;
 }
 EXPORT_SYMBOL(ip6_find_1stfragopt);
+
+#if IS_ENABLED(CONFIG_IPV6)
+int ip6_dst_hoplimit(struct dst_entry *dst)
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
+EXPORT_SYMBOL(ip6_dst_hoplimit);
+#endif
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
