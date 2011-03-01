From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Consolidate route lookup sequences.
Date: Tue, 01 Mar 2011 12:36:40 -0800 (PST)
Message-ID: <20110301.123640.59675298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757148Ab1CAUgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 15:36:03 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2A5BF24C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 12:36:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Route lookups follow a general pattern in the ipv6 code wherein
we first find the non-IPSEC route, potentially override the
flow destination address due to ipv6 options settings, and then
finally make an IPSEC search using either xfrm_lookup() or
__xfrm_lookup().

__xfrm_lookup() is used when we want to generate a blackhole route
if the key manager needs to resolve the IPSEC rules (in this case
-EREMOTE is returned and the original 'dst' is left unchanged).

Otherwise plain xfrm_lookup() is used and when asynchronous IPSEC
resolution is necessary, we simply fail the lookup completely.

All of these cases are encapsulated into two routines,
ip6_dst_lookup_flow and ip6_sk_dst_lookup_flow.  The latter of which
handles unconnected UDP datagram sockets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ipv6.h               |   11 ++++-
 net/ipv6/af_inet6.c              |   17 ++------
 net/ipv6/datagram.c              |   15 ++-----
 net/ipv6/inet6_connection_sock.c |    9 +---
 net/ipv6/ip6_output.c            |   80 ++++++++++++++++++++++++++++++++-----
 net/ipv6/raw.c                   |   15 +------
 net/ipv6/syncookies.c            |    7 +--
 net/ipv6/tcp_ipv6.c              |   57 ++++++++++-----------------
 net/ipv6/udp.c                   |   15 ++-----
 9 files changed, 118 insertions(+), 108 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4a3cd2c..1fc5631 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -512,12 +512,17 @@ extern void			ip6_flush_pending_frames(struct sock *sk);
 extern int			ip6_dst_lookup(struct sock *sk,
 					       struct dst_entry **dst,
 					       struct flowi *fl);
+extern struct dst_entry *	ip6_dst_lookup_flow(struct sock *sk,
+						    struct flowi *fl,
+						    const struct in6_addr *final_dst,
+						    bool want_blackhole);
+extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
+						       struct flowi *fl,
+						       const struct in6_addr *final_dst,
+						       bool want_blackhole);
 extern int			ip6_dst_blackhole(struct sock *sk,
 						  struct dst_entry **dst,
 						  struct flowi *fl);
-extern int			ip6_sk_dst_lookup(struct sock *sk,
-						  struct dst_entry **dst,
-						  struct flowi *fl);
 
 /*
  *	skb processing functions
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3194aa9..a88b2e9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -644,9 +644,8 @@ EXPORT_SYMBOL(inet6_unregister_protosw);
 
 int inet6_sk_rebuild_header(struct sock *sk)
 {
-	int err;
-	struct dst_entry *dst;
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct dst_entry *dst;
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
 
@@ -668,17 +667,11 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 		final_p = fl6_update_dst(&fl, np->opt, &final);
 
-		err = ip6_dst_lookup(sk, &dst, &fl);
-		if (err) {
+		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		if (IS_ERR(dst)) {
 			sk->sk_route_caps = 0;
-			return err;
-		}
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-		if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0) {
-			sk->sk_err_soft = -err;
-			return err;
+			sk->sk_err_soft = -PTR_ERR(dst);
+			return PTR_ERR(dst);
 		}
 
 		__ip6_dst_store(sk, dst, NULL, NULL);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 320bdb8..be3a781 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -162,18 +162,11 @@ ipv4_connected:
 	opt = flowlabel ? flowlabel->opt : np->opt;
 	final_p = fl6_update_dst(&fl, opt, &final);
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	err = 0;
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
 		goto out;
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
-	if (err < 0) {
-		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, &fl);
-		if (err < 0)
-			goto out;
 	}
 
 	/* source address lookup done in ip6_dst_lookup */
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index d144e62..235ac19 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -74,13 +74,8 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	fl.fl_ip_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
 
-	if (ip6_dst_lookup(sk, &dst, &fl))
-		return NULL;
-
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
+	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+	if (IS_ERR(dst))
 		return NULL;
 
 	return dst;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 065b3f7..13d3cb0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1002,29 +1002,87 @@ int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl)
 EXPORT_SYMBOL_GPL(ip6_dst_lookup);
 
 /**
- *	ip6_sk_dst_lookup - perform socket cached route lookup on flow
+ *	ip6_dst_lookup_flow - perform route lookup on flow with ipsec
+ *	@sk: socket which provides route info
+ *	@fl: flow to lookup
+ *	@final_dst: final destination address for ipsec lookup
+ *	@want_blackhole: IPSEC blackhole handling desired
+ *
+ *	This function performs a route lookup on the given flow.
+ *
+ *	It returns a valid dst pointer on success, or a pointer encoded
+ *	error code.
+ */
+struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
+				      const struct in6_addr *final_dst,
+				      bool want_blackhole)
+{
+	struct dst_entry *dst = NULL;
+	int err;
+
+	err = ip6_dst_lookup_tail(sk, &dst, fl);
+	if (err)
+		return ERR_PTR(err);
+	if (final_dst)
+		ipv6_addr_copy(&fl->fl6_dst, final_dst);
+	if (want_blackhole) {
+		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, fl);
+		if (err)
+			return ERR_PTR(err);
+	} else {
+		err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
+		if (err)
+			return ERR_PTR(err);
+	}
+	return dst;
+}
+EXPORT_SYMBOL_GPL(ip6_dst_lookup_flow);
+
+/**
+ *	ip6_sk_dst_lookup_flow - perform socket cached route lookup on flow
  *	@sk: socket which provides the dst cache and route info
- *	@dst: pointer to dst_entry * for result
  *	@fl: flow to lookup
+ *	@final_dst: final destination address for ipsec lookup
+ *	@want_blackhole: IPSEC blackhole handling desired
  *
  *	This function performs a route lookup on the given flow with the
  *	possibility of using the cached route in the socket if it is valid.
  *	It will take the socket dst lock when operating on the dst cache.
  *	As a result, this function can only be used in process context.
  *
- *	It returns zero on success, or a standard errno code on error.
+ *	It returns a valid dst pointer on success, or a pointer encoded
+ *	error code.
  */
-int ip6_sk_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi *fl)
+struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
+					 const struct in6_addr *final_dst,
+					 bool want_blackhole)
 {
-	*dst = NULL;
-	if (sk) {
-		*dst = sk_dst_check(sk, inet6_sk(sk)->dst_cookie);
-		*dst = ip6_sk_dst_check(sk, *dst, fl);
-	}
+	struct dst_entry *dst = sk_dst_check(sk, inet6_sk(sk)->dst_cookie);
+	int err;
 
-	return ip6_dst_lookup_tail(sk, dst, fl);
+	dst = ip6_sk_dst_check(sk, dst, fl);
+
+	err = ip6_dst_lookup_tail(sk, &dst, fl);
+	if (err)
+		return ERR_PTR(err);
+	if (final_dst)
+		ipv6_addr_copy(&fl->fl6_dst, final_dst);
+	if (want_blackhole) {
+		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, XFRM_LOOKUP_WAIT);
+		if (err == -EREMOTE)
+			err = ip6_dst_blackhole(sk, &dst, fl);
+		if (err)
+			return ERR_PTR(err);
+	} else {
+		err = xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
+		if (err)
+			return ERR_PTR(err);
+	}
+	return dst;
 }
-EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup);
+EXPORT_SYMBOL_GPL(ip6_sk_dst_lookup_flow);
 
 static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 364e866..dc29b07 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -856,20 +856,11 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		fl.oif = np->mcast_oif;
 	security_sk_classify_flow(sk, &fl);
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
 		goto out;
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
-	if (err < 0) {
-		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, &fl);
-		if (err < 0)
-			goto out;
 	}
-
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
 			hlimit = np->mcast_hops;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 09fd34f..0b4cf35 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -243,12 +243,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->inet_sport;
 		security_req_classify_flow(req, &fl);
-		if (ip6_dst_lookup(sk, &dst, &fl))
-			goto out_free;
 
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-		if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
+		dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+		if (IS_ERR(dst))
 			goto out_free;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1d0ab55..e59a31c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -255,18 +255,10 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	security_sk_classify_flow(sk, &fl);
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup_flow(sk, &fl, final_p, true);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
 		goto failure;
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
-	if (err < 0) {
-		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, &fl);
-		if (err < 0)
-			goto failure;
 	}
 
 	if (saddr == NULL) {
@@ -385,7 +377,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	np = inet6_sk(sk);
 
 	if (type == ICMPV6_PKT_TOOBIG) {
-		struct dst_entry *dst = NULL;
+		struct dst_entry *dst;
 
 		if (sock_owned_by_user(sk))
 			goto out;
@@ -413,13 +405,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			fl.fl_ip_sport = inet->inet_sport;
 			security_skb_classify_flow(skb, &fl);
 
-			if ((err = ip6_dst_lookup(sk, &dst, &fl))) {
-				sk->sk_err_soft = -err;
-				goto out;
-			}
-
-			if ((err = xfrm_lookup(net, &dst, &fl, sk, 0)) < 0) {
-				sk->sk_err_soft = -err;
+			dst = ip6_dst_lookup_flow(sk, &fl, NULL, false);
+			if (IS_ERR(dst)) {
+				sk->sk_err_soft = -PTR_ERR(dst);
 				goto out;
 			}
 
@@ -496,7 +484,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	struct in6_addr * final_p, final;
 	struct flowi fl;
 	struct dst_entry *dst;
-	int err = -1;
+	int err;
 
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_TCP;
@@ -512,15 +500,13 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	opt = np->opt;
 	final_p = fl6_update_dst(&fl, opt, &final);
 
-	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_dst_lookup_flow(sk, &fl, final_p, false);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
 		goto done;
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-	if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
-		goto done;
-
+	}
 	skb = tcp_make_synack(sk, dst, req, rvp);
+	err = -ENOMEM;
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
@@ -1079,15 +1065,14 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	 * Underlying function will use this to retrieve the network
 	 * namespace
 	 */
-	if (!ip6_dst_lookup(ctl_sk, &dst, &fl)) {
-		if (xfrm_lookup(net, &dst, &fl, NULL, 0) >= 0) {
-			skb_dst_set(buff, dst);
-			ip6_xmit(ctl_sk, buff, &fl, NULL);
-			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-			if (rst)
-				TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
-			return;
-		}
+	dst = ip6_dst_lookup_flow(ctl_sk, &fl, NULL, false);
+	if (!IS_ERR(dst)) {
+		skb_dst_set(buff, dst);
+		ip6_xmit(ctl_sk, buff, &fl, NULL);
+		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+		if (rst)
+			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
+		return;
 	}
 
 	kfree_skb(buff);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a419a78..d86d7f6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1125,18 +1125,11 @@ do_udp_sendmsg:
 
 	security_sk_classify_flow(sk, &fl);
 
-	err = ip6_sk_dst_lookup(sk, &dst, &fl);
-	if (err)
+	dst = ip6_sk_dst_lookup_flow(sk, &fl, final_p, true);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
+		dst = NULL;
 		goto out;
-	if (final_p)
-		ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-	err = __xfrm_lookup(sock_net(sk), &dst, &fl, sk, XFRM_LOOKUP_WAIT);
-	if (err < 0) {
-		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, &fl);
-		if (err < 0)
-			goto out;
 	}
 
 	if (hlimit < 0) {
-- 
1.7.4.1

