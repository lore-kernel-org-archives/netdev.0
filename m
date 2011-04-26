From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] ipv4: Sanitize and simplify
 ip_route_{connect,newports}()
Date: Tue, 26 Apr 2011 15:12:02 -0700 (PDT)
Message-ID: <20110426.151202.245387083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758444Ab1DZWMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:12:35 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A932D24C088
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These functions are used together as a unit for route resolution
during connect().  They address the chicken-and-egg problem that
exists when ports need to be allocated during connect() processing,
yet such port allocations require addressing information from the
routing code.

It's currently more heavy handed than it needs to be, and in
particular we allocate and initialize a flow object twice.

Let the callers provide the on-stack flow object.  That way we only
need to initialize it once in the ip_route_connect() call.

Later, if ip_route_newports() needs to do anything, it re-uses that
flow object as-is except for the ports which it updates before the
route re-lookup.

Also, describe why this set of facilities are needed and how it works
in a big comment.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |   88 ++++++++++++++++++++++++++++++++------------------
 net/dccp/ipv4.c     |   10 +++---
 net/ipv4/af_inet.c  |    3 +-
 net/ipv4/datagram.c |    3 +-
 net/ipv4/tcp_ipv4.c |   10 +++---
 net/l2tp/l2tp_ip.c  |    8 ++--
 6 files changed, 74 insertions(+), 48 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 3684c3e..79530da 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -217,17 +217,37 @@ static inline char rt_tos2priority(u8 tos)
 	return ip_tos2prio[IPTOS_TOS(tos)>>1];
 }
 
-static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
-					      int oif, u8 protocol,
-					      __be16 sport, __be16 dport,
-					      struct sock *sk, bool can_sleep)
+/* ip_route_connect() and ip_route_newports() work in tandem whilst
+ * binding a socket for a new outgoing connection.
+ *
+ * In order to use IPSEC properly, we must, in the end, have a
+ * route that was looked up using all available keys including source
+ * and destination ports.
+ *
+ * However, if a source port needs to be allocated (the user specified
+ * a wildcard source port) we need to obtain addressing information
+ * in order to perform that allocation.
+ *
+ * So ip_route_connect() looks up a route using wildcarded source and
+ * destination ports in the key, simply so that we can get a pair of
+ * addresses to use for port allocation.
+ *
+ * Later, once the ports are allocated, ip_route_newports() will make
+ * another route lookup if needed to make sure we catch any IPSEC
+ * rules keyed on the port information.
+ *
+ * The callers allocate the flow key on their stack, and must pass in
+ * the same flowi4 object to both the ip_route_connect() and the
+ * ip_route_newports() calls.
+ */
+
+static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32 src,
+					 u32 tos, int oif, u8 protocol,
+					 __be16 sport, __be16 dport,
+					 struct sock *sk, bool can_sleep)
 {
-	struct net *net = sock_net(sk);
-	struct rtable *rt;
-	struct flowi4 fl4;
-	__u8 flow_flags;
+	__u8 flow_flags = 0;
 
-	flow_flags = 0;
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 	if (protocol == IPPROTO_TCP)
@@ -235,41 +255,45 @@ static inline struct rtable *ip_route_connect(__be32 dst, __be32 src, u32 tos,
 	if (can_sleep)
 		flow_flags |= FLOWI_FLAG_CAN_SLEEP;
 
-	flowi4_init_output(&fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
+	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
+}
+
+static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
+					      __be32 dst, __be32 src, u32 tos,
+					      int oif, u8 protocol,
+					      __be16 sport, __be16 dport,
+					      struct sock *sk, bool can_sleep)
+{
+	struct net *net = sock_net(sk);
+	struct rtable *rt;
+
+	ip_route_connect_init(fl4, dst, src, tos, oif, protocol,
+			      sport, dport, sk, can_sleep);
 
 	if (!dst || !src) {
-		rt = __ip_route_output_key(net, &fl4);
+		rt = __ip_route_output_key(net, fl4);
 		if (IS_ERR(rt))
 			return rt;
-		fl4.daddr = rt->rt_dst;
-		fl4.saddr = rt->rt_src;
+		fl4->daddr = rt->rt_dst;
+		fl4->saddr = rt->rt_src;
 		ip_rt_put(rt);
 	}
-	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	return ip_route_output_flow(net, &fl4, sk);
+	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
+	return ip_route_output_flow(net, fl4, sk);
 }
 
-static inline struct rtable *ip_route_newports(struct rtable *rt,
-					       u8 protocol, __be16 orig_sport,
-					       __be16 orig_dport, __be16 sport,
-					       __be16 dport, struct sock *sk)
+static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable *rt,
+					       __be16 orig_sport, __be16 orig_dport,
+					       __be16 sport, __be16 dport,
+					       struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
-		struct flowi4 fl4;
-		__u8 flow_flags;
-
-		flow_flags = 0;
-		if (inet_sk(sk)->transparent)
-			flow_flags |= FLOWI_FLAG_ANYSRC;
-		if (protocol == IPPROTO_TCP)
-			flow_flags |= FLOWI_FLAG_PRECOW_METRICS;
-		flowi4_init_output(&fl4, rt->rt_oif, rt->rt_mark, rt->rt_tos,
-				   RT_SCOPE_UNIVERSE, protocol, flow_flags,
-				   rt->rt_dst, rt->rt_src, dport, sport);
+		fl4->fl4_dport = dport;
+		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
-		security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-		return ip_route_output_flow(sock_net(sk), &fl4, sk);
+		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
+		return ip_route_output_flow(sock_net(sk), fl4, sk);
 	}
 	return rt;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ae451c6..b92ab65 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -40,12 +40,13 @@
 
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
+	const struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	struct inet_sock *inet = inet_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	const struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	__be16 orig_sport, orig_dport;
-	struct rtable *rt;
 	__be32 daddr, nexthop;
+	struct flowi4 fl4;
+	struct rtable *rt;
 	int err;
 
 	dp->dccps_role = DCCP_ROLE_CLIENT;
@@ -65,7 +66,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	rt = ip_route_connect(nexthop, inet->inet_saddr,
+	rt = ip_route_connect(&fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_DCCP,
 			      orig_sport, orig_dport, sk, true);
@@ -101,8 +102,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err != 0)
 		goto failure;
 
-	rt = ip_route_newports(rt, IPPROTO_DCCP,
-			       orig_sport, orig_dport,
+	rt = ip_route_newports(&fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
 		rt = NULL;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cae75ef..0413af3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1103,6 +1103,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	__be32 old_saddr = inet->inet_saddr;
 	__be32 daddr = inet->inet_daddr;
+	struct flowi4 fl4;
 	struct rtable *rt;
 	__be32 new_saddr;
 
@@ -1110,7 +1111,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 		daddr = inet->opt->faddr;
 
 	/* Query new route. */
-	rt = ip_route_connect(daddr, 0, RT_CONN_FLAGS(sk),
+	rt = ip_route_connect(&fl4, daddr, 0, RT_CONN_FLAGS(sk),
 			      sk->sk_bound_dev_if, sk->sk_protocol,
 			      inet->inet_sport, inet->inet_dport, sk, false);
 	if (IS_ERR(rt))
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 85bd24c..216ba23 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -24,6 +24,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *usin = (struct sockaddr_in *) uaddr;
+	struct flowi4 fl4;
 	struct rtable *rt;
 	__be32 saddr;
 	int oif;
@@ -46,7 +47,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		if (!saddr)
 			saddr = inet->mc_addr;
 	}
-	rt = ip_route_connect(usin->sin_addr.s_addr, saddr,
+	rt = ip_route_connect(&fl4, usin->sin_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      sk->sk_protocol,
 			      inet->inet_sport, usin->sin_port, sk, true);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index edf18bd..310454c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -146,12 +146,13 @@ EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
+	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sockaddr_in *usin = (struct sockaddr_in *)uaddr;
 	__be16 orig_sport, orig_dport;
-	struct rtable *rt;
 	__be32 daddr, nexthop;
+	struct flowi4 fl4;
+	struct rtable *rt;
 	int err;
 
 	if (addr_len < sizeof(struct sockaddr_in))
@@ -169,7 +170,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	orig_sport = inet->inet_sport;
 	orig_dport = usin->sin_port;
-	rt = ip_route_connect(nexthop, inet->inet_saddr,
+	rt = ip_route_connect(&fl4, nexthop, inet->inet_saddr,
 			      RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			      IPPROTO_TCP,
 			      orig_sport, orig_dport, sk, true);
@@ -236,8 +237,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (err)
 		goto failure;
 
-	rt = ip_route_newports(rt, IPPROTO_TCP,
-			       orig_sport, orig_dport,
+	rt = ip_route_newports(&fl4, rt, orig_sport, orig_dport,
 			       inet->inet_sport, inet->inet_dport, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index fce9bd3..cc67367 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -296,12 +296,12 @@ out_in_use:
 
 static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
-	int rc;
-	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_l2tpip *lsa = (struct sockaddr_l2tpip *) uaddr;
+	struct inet_sock *inet = inet_sk(sk);
+	struct flowi4 fl4;
 	struct rtable *rt;
 	__be32 saddr;
-	int oif;
+	int oif, rc;
 
 	rc = -EINVAL;
 	if (addr_len < sizeof(*lsa))
@@ -320,7 +320,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
 		goto out;
 
-	rt = ip_route_connect(lsa->l2tp_addr.s_addr, saddr,
+	rt = ip_route_connect(&fl4, lsa->l2tp_addr.s_addr, saddr,
 			      RT_CONN_FLAGS(sk), oif,
 			      IPPROTO_L2TP,
 			      0, 0, sk, true);
-- 
1.7.4.5

