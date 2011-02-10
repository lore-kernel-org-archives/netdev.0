From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 3/5] inet: Create a mechanism for upward inetpeer
 propagation into routes.
Date: Wed, 09 Feb 2011 22:13:24 -0800 (PST)
Message-ID: <20110209.221324.59682859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752006Ab1BJGMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:12:49 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 17EBD24C088
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:13:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we didn't have a routing cache, we would not be able to properly
propagate certain kinds of dynamic path attributes, for example
PMTU information and redirects.

The reason is that if we didn't have a routing cache, then there would
be no way to lookup all of the active cached routes hanging off of
sockets, tunnels, IPSEC bundles, etc.

Consider the case where we created a cached route, but no inetpeer
entry existed and also we were not asked to pre-COW the route metrics
and therefore did not force the creation a new inetpeer entry.

If we later get a PMTU message, or a redirect, and store this
information in a new inetpeer entry, there is no way to teach that
cached route about the newly existing inetpeer entry.

The facilities implemented here handle this problem.

First we create a generation ID.  When we create a cached route of any
kind, we remember the generation ID at the time of attachment.  Any
time we force-create an inetpeer entry in response to new path
information, we bump that generation ID.

The dst_ops->check() callback is where the knowledge of this event
is propagated.  If the global generation ID does not equal the one
stored in the cached route, and the cached route has not attached
to an inetpeer yet, we look it up and attach if one is found.  Now
that we've updated the cached route's information, we update the
route's generation ID too.

This clears the way for implementing PMTU and redirects directly in
the inetpeer cache.  There is absolutely no need to consult cached
route information in order to maintain this information.

At this point nothing bumps the inetpeer genids, that comes in the
later changes which handle PMTUs and redirects using inetpeers.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h |    1 +
 include/net/route.h   |    1 +
 net/ipv4/route.c      |   19 ++++++++++++++++++-
 net/ipv6/route.c      |   18 ++++++++++++++++--
 4 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 708ff7c..46a6e8a 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -108,6 +108,7 @@ struct rt6_info {
 	u32				rt6i_flags;
 	struct rt6key			rt6i_src;
 	u32				rt6i_metric;
+	u32				rt6i_peer_genid;
 
 	struct inet6_dev		*rt6i_idev;
 	struct inet_peer		*rt6i_peer;
diff --git a/include/net/route.h b/include/net/route.h
index e586465..bf790c1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -69,6 +69,7 @@ struct rtable {
 
 	/* Miscellaneous cached information */
 	__be32			rt_spec_dst; /* RFC1122 specific destination */
+	u32			rt_peer_genid;
 	struct inet_peer	*peer; /* long-living peer info */
 	struct fib_info		*fi; /* for client ref to shared metrics */
 };
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0455af8..0979e03 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1308,6 +1308,13 @@ skip_hashing:
 	return 0;
 }
 
+static atomic_t __rt_peer_genid = ATOMIC_INIT(0);
+
+static u32 rt_peer_genid(void)
+{
+	return atomic_read(&__rt_peer_genid);
+}
+
 void rt_bind_peer(struct rtable *rt, int create)
 {
 	struct inet_peer *peer;
@@ -1316,6 +1323,8 @@ void rt_bind_peer(struct rtable *rt, int create)
 
 	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
+	else
+		rt->rt_peer_genid = rt_peer_genid();
 }
 
 /*
@@ -1767,8 +1776,16 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	if (rt_is_expired((struct rtable *)dst))
+	struct rtable *rt = (struct rtable *) dst;
+
+	if (rt_is_expired(rt))
 		return NULL;
+	if (rt->rt_peer_genid != rt_peer_genid()) {
+		if (!rt->peer)
+			rt_bind_peer(rt, 0);
+
+		rt->rt_peer_genid = rt_peer_genid();
+	}
 	return dst;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 12ec83d..ad8556e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -240,6 +240,13 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	}
 }
 
+static atomic_t __rt6_peer_genid = ATOMIC_INIT(0);
+
+static u32 rt6_peer_genid(void)
+{
+	return atomic_read(&__rt6_peer_genid);
+}
+
 void rt6_bind_peer(struct rt6_info *rt, int create)
 {
 	struct inet_peer *peer;
@@ -247,6 +254,8 @@ void rt6_bind_peer(struct rt6_info *rt, int create)
 	peer = inet_getpeer_v6(&rt->rt6i_dst.addr, create);
 	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
+	else
+		rt->rt6i_peer_genid = rt6_peer_genid();
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -912,9 +921,14 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt = (struct rt6_info *) dst;
 
-	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
+	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie)) {
+		if (rt->rt6i_peer_genid != rt6_peer_genid()) {
+			if (!rt->rt6i_peer)
+				rt6_bind_peer(rt, 0);
+			rt->rt6i_peer_genid = rt6_peer_genid();
+		}
 		return dst;
-
+	}
 	return NULL;
 }
 
-- 
1.7.4

