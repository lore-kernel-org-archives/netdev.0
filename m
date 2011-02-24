From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Rearrange how ip_route_newports() gets port keys.
Date: Thu, 24 Feb 2011 13:42:41 -0800 (PST)
Message-ID: <20110224.134241.71126743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056Ab1BXVmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 16:42:06 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2EA3924C088
	for <netdev@vger.kernel.org>; Thu, 24 Feb 2011 13:42:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip_route_newports() is the only place in the entire kernel that
cares about the port members in the routing cache entry's lookup
flow key.

Therefore the only reason we store an entire flow inside of the
struct rtentry is for this one special case.

Rewrite ip_route_newports() such that:

1) The caller passes in the original port values, so we don't need
   to use the rth->fl.fl_ip_{s,d}port values to remember them.

2) The lookup flow is constructed by hand instead of being copied
   from the routing cache entry's flow.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |   19 +++++++++++--------
 net/dccp/ipv4.c     |   10 +++++++---
 net/ipv4/tcp_ipv4.c |    6 +++++-
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index bf790c1..b3f89ad 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -200,16 +200,19 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
+				    __be16 orig_sport, __be16 orig_dport,
 				    __be16 sport, __be16 dport, struct sock *sk)
 {
-	if (sport != (*rp)->fl.fl_ip_sport ||
-	    dport != (*rp)->fl.fl_ip_dport) {
-		struct flowi fl;
-
-		memcpy(&fl, &(*rp)->fl, sizeof(fl));
-		fl.fl_ip_sport = sport;
-		fl.fl_ip_dport = dport;
-		fl.proto = protocol;
+	if (sport != orig_sport || dport != orig_dport) {
+		struct flowi fl = { .oif = (*rp)->fl.oif,
+				    .mark = (*rp)->fl.mark,
+				    .fl4_dst = (*rp)->fl.fl4_dst,
+				    .fl4_src = (*rp)->fl.fl4_src,
+				    .fl4_tos = (*rp)->fl.fl4_tos,
+				    .proto = (*rp)->fl.proto,
+				    .fl_ip_sport = sport,
+				    .fl_ip_dport = dport };
+
 		if (inet_sk(sk)->transparent)
 			fl.flags |= FLOWI_FLAG_ANYSRC;
 		if (protocol == IPPROTO_TCP)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 45a434f..9379891 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -43,6 +43,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
+	__be16 orig_sport, orig_dport;
 	struct rtable *rt;
 	__be32 daddr, nexthop;
 	int tmp;
@@ -63,10 +64,12 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		nexthop = inet->opt->faddr;
 	}
 
+	orig_sport = inet->inet_sport;
+	orig_dport = usin->sin_port;
 	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_DCCP,
-			       inet->inet_sport, usin->sin_port, sk, 1);
+			       orig_sport, orig_dport, sk, 1);
 	if (tmp < 0)
 		return tmp;
 
@@ -99,8 +102,9 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err != 0)
 		goto failure;
 
-	err = ip_route_newports(&rt, IPPROTO_DCCP, inet->inet_sport,
-				inet->inet_dport, sk);
+	err = ip_route_newports(&rt, IPPROTO_DCCP,
+				orig_sport, orig_dport,
+				inet->inet_sport, inet->inet_dport, sk);
 	if (err != 0)
 		goto failure;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef5a90b..27a0cc8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -149,6 +149,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
+	__be16 orig_sport, orig_dport;
 	struct rtable *rt;
 	__be32 daddr, nexthop;
 	int tmp;
@@ -167,10 +168,12 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		nexthop = inet->opt->faddr;
 	}
 
+	orig_sport = inet->inet_sport;
+	orig_dport = usin->sin_port;
 	tmp = ip_route_connect(&rt, nexthop, inet->inet_saddr,
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
-			       inet->inet_sport, usin->sin_port, sk, 1);
+			       orig_sport, orig_dport, sk, 1);
 	if (tmp < 0) {
 		if (tmp == -ENETUNREACH)
 			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
@@ -234,6 +237,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		goto failure;
 
 	err = ip_route_newports(&rt, IPPROTO_TCP,
+				orig_sport, orig_dport,
 				inet->inet_sport, inet->inet_dport, sk);
 	if (err)
 		goto failure;
-- 
1.7.4.1

