From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: dont cache output dst for syncookies
Date: Wed, 20 Jun 2012 17:02:19 +0200
Message-ID: <1340204539.4604.1122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56889 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987Ab2FTPCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 11:02:24 -0400
Received: by bkcji2 with SMTP id ji2so6271335bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 08:02:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Don't cache output dst for syncookies, as this adds pressure on IP route
cache and rcu subsystem for no gain.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/flow.h                 |    1 +
 include/net/inet_connection_sock.h |    3 ++-
 net/dccp/ipv4.c                    |    2 +-
 net/ipv4/inet_connection_sock.c    |    8 ++++++--
 net/ipv4/route.c                   |    5 ++++-
 net/ipv4/tcp_ipv4.c                |   12 +++++++-----
 6 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 6c469db..bd524f5 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -22,6 +22,7 @@ struct flowi_common {
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_PRECOW_METRICS	0x02
 #define FLOWI_FLAG_CAN_SLEEP		0x04
+#define FLOWI_FLAG_RT_NOCACHE		0x08
 	__u32	flowic_secid;
 };
 
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index e1b7734..af3c743 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -251,7 +251,8 @@ extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
 					    struct flowi4 *fl4,
-					    const struct request_sock *req);
+					    const struct request_sock *req,
+					    bool nocache);
 extern struct dst_entry* inet_csk_route_child_sock(struct sock *sk,
 						   struct sock *newsk,
 						   const struct request_sock *req);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 07f5579..3eb76b5 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -504,7 +504,7 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 
-	dst = inet_csk_route_req(sk, &fl4, req);
+	dst = inet_csk_route_req(sk, &fl4, req, false);
 	if (dst == NULL)
 		goto out;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f9ee741..034ddbe 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -368,17 +368,21 @@ EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
 struct dst_entry *inet_csk_route_req(struct sock *sk,
 				     struct flowi4 *fl4,
-				     const struct request_sock *req)
+				     const struct request_sock *req,
+				     bool nocache)
 {
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options_rcu *opt = inet_rsk(req)->opt;
 	struct net *net = sock_net(sk);
+	int flags = inet_sk_flowi_flags(sk) & ~FLOWI_FLAG_PRECOW_METRICS;
 
+	if (nocache)
+		flags |= FLOWI_FLAG_RT_NOCACHE;
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol,
-			   inet_sk_flowi_flags(sk) & ~FLOWI_FLAG_PRECOW_METRICS,
+			   flags,
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
 			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a91f6d3..8d62d85 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1156,7 +1156,7 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	if (!rt_caching(dev_net(rt->dst.dev))) {
+	if (!rt_caching(dev_net(rt->dst.dev)) || (rt->dst.flags & DST_NOCACHE)) {
 		/*
 		 * If we're not caching, just tell the caller we
 		 * were successful and don't touch the route.  The
@@ -2582,6 +2582,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rt_set_nexthop(rth, fl4, res, fi, type, 0);
 
+	if (fl4->flowi4_flags & FLOWI_FLAG_RT_NOCACHE)
+		rth->dst.flags |= DST_NOCACHE;
+
 	return rth;
 }
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 13857df..6abc0fd 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -825,7 +825,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
 			      struct request_values *rvp,
-			      u16 queue_mapping)
+			      u16 queue_mapping,
+			      bool nocache)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -833,7 +834,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	struct sk_buff * skb;
 
 	/* First, grab a route. */
-	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
+	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req, nocache)) == NULL)
 		return -1;
 
 	skb = tcp_make_synack(sk, dst, req, rvp);
@@ -855,7 +856,7 @@ static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
 			      struct request_values *rvp)
 {
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v4_send_synack(sk, NULL, req, rvp, 0);
+	return tcp_v4_send_synack(sk, NULL, req, rvp, 0, false);
 }
 
 /*
@@ -1388,7 +1389,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet_csk_route_req(sk, &fl4, req)) != NULL &&
+		    (dst = inet_csk_route_req(sk, &fl4, req, want_cookie)) != NULL &&
 		    fl4.daddr == saddr &&
 		    (peer = rt_get_peer((struct rtable *)dst, fl4.daddr)) != NULL) {
 			inet_peer_refcheck(peer);
@@ -1424,7 +1425,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (tcp_v4_send_synack(sk, dst, req,
 			       (struct request_values *)&tmp_ext,
-			       skb_get_queue_mapping(skb)) ||
+			       skb_get_queue_mapping(skb),
+			       want_cookie) ||
 	    want_cookie)
 		goto drop_and_free;
 
