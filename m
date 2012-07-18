From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/15] ipv4: Kill FLOWI_FLAG_RT_NOCACHE and associated code.
Date: Wed, 18 Jul 2012 11:24:22 -0700 (PDT)
Message-ID: <20120718.112422.557141503506672333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab2GRSYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:24:23 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 25C3B583FC7
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:24:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/flow.h                 |    1 -
 include/net/inet_connection_sock.h |    3 +--
 net/dccp/ipv4.c                    |    2 +-
 net/ipv4/inet_connection_sock.c    |    5 +----
 net/ipv4/route.c                   |    3 ---
 net/ipv4/tcp_ipv4.c                |    4 ++--
 6 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index ce9cb76..e1dd508 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -21,7 +21,6 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_CAN_SLEEP		0x02
-#define FLOWI_FLAG_RT_NOCACHE		0x04
 	__u32	flowic_secid;
 };
 
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 2cf44b4..5ee66f5 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -250,8 +250,7 @@ extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
 					    struct flowi4 *fl4,
-					    const struct request_sock *req,
-					    bool nocache);
+					    const struct request_sock *req);
 extern struct dst_entry* inet_csk_route_child_sock(struct sock *sk,
 						   struct sock *newsk,
 						   const struct request_sock *req);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ab4f44c..25428d0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -508,7 +508,7 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 
-	dst = inet_csk_route_req(sk, &fl4, req, false);
+	dst = inet_csk_route_req(sk, &fl4, req);
 	if (dst == NULL)
 		goto out;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0a290d7..db0cf17 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -368,8 +368,7 @@ EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
 struct dst_entry *inet_csk_route_req(struct sock *sk,
 				     struct flowi4 *fl4,
-				     const struct request_sock *req,
-				     bool nocache)
+				     const struct request_sock *req)
 {
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
@@ -377,8 +376,6 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct net *net = sock_net(sk);
 	int flags = inet_sk_flowi_flags(sk);
 
-	if (nocache)
-		flags |= FLOWI_FLAG_RT_NOCACHE;
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b2f5c33..d4a3c6e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1802,9 +1802,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rt_set_nexthop(rth, res, fnhe, fi, type, 0);
 
-	if (fl4->flowi4_flags & FLOWI_FLAG_RT_NOCACHE)
-		rth->dst.flags |= DST_NOCACHE;
-
 	return rth;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9caf5c..de6969a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -824,7 +824,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	struct sk_buff * skb;
 
 	/* First, grab a route. */
-	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req, nocache)) == NULL)
+	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
 	skb = tcp_make_synack(sk, dst, req, rvp);
@@ -1378,7 +1378,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet_csk_route_req(sk, &fl4, req, want_cookie)) != NULL &&
+		    (dst = inet_csk_route_req(sk, &fl4, req)) != NULL &&
 		    fl4.daddr == saddr) {
 			if (!tcp_peer_is_proven(req, dst, true)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
-- 
1.7.10.4
