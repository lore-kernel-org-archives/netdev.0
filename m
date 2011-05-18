From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] ipv4: Make caller provide flowi4 key to
 inet_csk_route_req().
Date: Wed, 18 May 2011 18:56:32 -0400 (EDT)
Message-ID: <20110518.185632.2298667001480851576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab1ERW4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:56:34 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4IMuXnG017373
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:56:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This way the caller can get at the fully resolved fl4->{daddr,saddr}
etc.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    1 +
 net/dccp/ipv4.c                    |    3 ++-
 net/ipv4/inet_connection_sock.c    |   10 +++++-----
 net/ipv4/tcp_ipv4.c                |    6 ++++--
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 96546ca..e6db62e 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -249,6 +249,7 @@ extern int inet_csk_bind_conflict(const struct sock *sk,
 extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
+					    struct flowi4 *fl4,
 					    const struct request_sock *req);
 extern struct dst_entry* inet_csk_route_child_sock(struct sock *sk,
 						   struct sock *newsk,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 46b15e9..8c36adf 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -497,8 +497,9 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 	int err = -1;
 	struct sk_buff *skb;
 	struct dst_entry *dst;
+	struct flowi4 fl4;
 
-	dst = inet_csk_route_req(sk, req);
+	dst = inet_csk_route_req(sk, &fl4, req);
 	if (dst == NULL)
 		goto out;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3a2ba56..61fac4c 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -350,24 +350,24 @@ void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
 struct dst_entry *inet_csk_route_req(struct sock *sk,
+				     struct flowi4 *fl4,
 				     const struct request_sock *req)
 {
 	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options_rcu *opt = inet_rsk(req)->opt;
 	struct net *net = sock_net(sk);
-	struct flowi4 fl4;
 
-	flowi4_init_output(&fl4, sk->sk_bound_dev_if, sk->sk_mark,
+	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
 			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
-	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_flow(net, &fl4, sk);
+	security_req_classify_flow(req, flowi4_to_flowi(fl4));
+	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && fl4.daddr != rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
 		goto route_err;
 	return &rt->dst;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f67fb34..7e0bc60 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -769,11 +769,12 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_values *rvp)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
+	struct flowi4 fl4;
 	int err = -1;
 	struct sk_buff * skb;
 
 	/* First, grab a route. */
-	if (!dst && (dst = inet_csk_route_req(sk, req)) == NULL)
+	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
 	skb = tcp_make_synack(sk, dst, req, rvp);
@@ -1338,6 +1339,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		req->cookie_ts = tmp_opt.tstamp_ok;
 	} else if (!isn) {
 		struct inet_peer *peer = NULL;
+		struct flowi4 fl4;
 
 		/* VJ's idea. We save last timestamp seen
 		 * from the destination in peer table, when entering
@@ -1350,7 +1352,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (tmp_opt.saw_tstamp &&
 		    tcp_death_row.sysctl_tw_recycle &&
-		    (dst = inet_csk_route_req(sk, req)) != NULL &&
+		    (dst = inet_csk_route_req(sk, &fl4, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->daddr.addr.a4 == saddr) {
 			inet_peer_refcheck(peer);
-- 
1.7.4.4

