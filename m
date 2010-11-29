From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] ipv6: Add infrastructure to bind inet_peer objects to
 routes.
Date: Mon, 29 Nov 2010 13:44:06 -0800 (PST)
Message-ID: <20101129.134406.245410194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51853
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753083Ab0K2Vnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 16:43:39 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6FEEA24C088
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 13:44:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are only allowed on cached ipv6 routes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h  |   10 ++++++++++
 include/net/ip6_fib.h   |    2 ++
 include/net/ip6_route.h |    3 +++
 net/ipv4/inetpeer.c     |    2 ++
 net/ipv6/route.c        |   18 ++++++++++++++++++
 5 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 834f045..fb8aeb1 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/spinlock.h>
+#include <net/ipv6.h>
 #include <asm/atomic.h>
 
 typedef struct {
@@ -61,6 +62,15 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 	return inet_getpeer(&daddr, create);
 }
 
+static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int create)
+{
+	inet_peer_address_t daddr;
+
+	ipv6_addr_copy((struct in6_addr *)daddr.a6, v6daddr);
+	daddr.family = AF_INET6;
+	return inet_getpeer(&daddr, create);
+}
+
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
 
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 062a823..708ff7c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -21,6 +21,7 @@
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/netlink.h>
+#include <net/inetpeer.h>
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB6_TABLE_HASHSZ 256
@@ -109,6 +110,7 @@ struct rt6_info {
 	u32				rt6i_metric;
 
 	struct inet6_dev		*rt6i_idev;
+	struct inet_peer		*rt6i_peer;
 
 #ifdef CONFIG_XFRM
 	u32				rt6i_flow_cache_genid;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 278312c..23fed28 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -56,6 +56,9 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
 	return (flags >> 3) & 7;
 }
 
+extern void			rt6_bind_peer(struct rt6_info *rt,
+					      int create);
+
 extern void			ip6_route_input(struct sk_buff *skb);
 
 extern struct dst_entry *	ip6_route_output(struct net *net,
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 39f18c5..a442e99 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -533,6 +533,7 @@ struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 
 	return p;
 }
+EXPORT_SYMBOL_GPL(inet_getpeer);
 
 /* Called with local BH disabled. */
 static void peer_check_expire(unsigned long dummy)
@@ -576,3 +577,4 @@ void inet_putpeer(struct inet_peer *p)
 
 	local_bh_enable();
 }
+EXPORT_SYMBOL_GPL(inet_putpeer);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a0c4ad1..026caef 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -188,11 +188,29 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
+	struct inet_peer *peer = rt->rt6i_peer;
 
 	if (idev != NULL) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
+	if (peer) {
+		BUG_ON(!(rt->rt6i_flags & RTF_CACHE));
+		rt->rt6i_peer = NULL;
+		inet_putpeer(peer);
+	}
+}
+
+void rt6_bind_peer(struct rt6_info *rt, int create)
+{
+	struct inet_peer *peer;
+
+	if (WARN_ON(!(rt->rt6i_flags & RTF_CACHE)))
+		return;
+
+	peer = inet_getpeer_v6(&rt->rt6i_dst.addr, create);
+	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
+		inet_putpeer(peer);
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-- 
1.7.3.2

