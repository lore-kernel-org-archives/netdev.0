From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Pre-COW metrics for TCP.
Date: Thu, 27 Jan 2011 22:27:57 -0800 (PST)
Message-ID: <20110127.222757.193688793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754343Ab1A1G1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 01:27:22 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 80BA324C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 22:27:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TCP is going to record metrics for the connection,
so pre-COW the route metrics at route cache entry
creation time.

This avoids several atomic operations that have to
occur if we COW the metrics after the entry reaches
global visibility.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h      |    3 ++-
 include/net/inet_sock.h |    8 +++++++-
 include/net/route.h     |    4 ++++
 net/ipv4/route.c        |   26 +++++++++++++++++++++++---
 4 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 240b7f3..1ae901f 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -48,7 +48,8 @@ struct flowi {
 
 	__u8	proto;
 	__u8	flags;
-#define FLOWI_FLAG_ANYSRC 0x01
+#define FLOWI_FLAG_ANYSRC		0x01
+#define FLOWI_FLAG_PRECOW_METRICS	0x02
 	union {
 		struct {
 			__be16	sport;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 8181498..6e6dfd7 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -219,7 +219,13 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 
 static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 {
-	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
+	__u8 flags = 0;
+
+	if (inet_sk(sk)->transparent)
+		flags |= FLOWI_FLAG_ANYSRC;
+	if (sk->sk_protocol == IPPROTO_TCP)
+		flags |= FLOWI_FLAG_PRECOW_METRICS;
+	return flags;
 }
 
 #endif	/* _INET_SOCK_H */
diff --git a/include/net/route.h b/include/net/route.h
index 5677cbf..e586465 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -182,6 +182,8 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 
 	if (inet_sk(sk)->transparent)
 		fl.flags |= FLOWI_FLAG_ANYSRC;
+	if (protocol == IPPROTO_TCP)
+		fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
 
 	if (!dst || !src) {
 		err = __ip_route_output_key(net, rp, &fl);
@@ -209,6 +211,8 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 		fl.proto = protocol;
 		if (inet_sk(sk)->transparent)
 			fl.flags |= FLOWI_FLAG_ANYSRC;
+		if (protocol == IPPROTO_TCP)
+			fl.flags |= FLOWI_FLAG_PRECOW_METRICS;
 		ip_rt_put(*rp);
 		*rp = NULL;
 		security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 68cee35..dd57f48 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1857,6 +1857,28 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
+static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
+{
+	if (!(rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)) {
+	no_cow:
+		rt->fi = fi;
+		atomic_inc(&fi->fib_clntref);
+		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+	} else {
+		struct inet_peer *peer;
+
+		if (!rt->peer)
+			rt_bind_peer(rt, 1);
+		peer = rt->peer;
+		if (!peer)
+			goto no_cow;
+		if (inet_metrics_new(peer))
+			memcpy(peer->metrics, fi->fib_metrics,
+			       sizeof(u32) * RTAX_MAX);
+		dst_init_metrics(&rt->dst, peer->metrics, false);
+	}
+}
+
 static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 {
 	struct dst_entry *dst = &rt->dst;
@@ -1866,9 +1888,7 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt->fi = fi;
-		atomic_inc(&fi->fib_clntref);
-		dst_init_metrics(dst, fi->fib_metrics, true);
+		rt_init_metrics(rt, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
-- 
1.7.3.4

