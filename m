From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.26] [INET]: Remove struct dst_entry *dst from request_sock_ops.rtx_syn_ack.
Date: Fri, 29 Feb 2008 18:32:16 +0300
Message-ID: <1204299136-12294-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:58802 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753643AbYB2Pb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 10:31:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like dst parameter is used in this API due to historical reasons.
Actually, it is really used in the direct call to tcp_v4_send_synack only.
So, create a wrapper for tcp_v4_send_synack and remove dst from rtx_syn_ack.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/request_sock.h      |    3 +--
 net/dccp/ipv4.c                 |   11 +++++------
 net/dccp/ipv6.c                 |   38 ++++++++++++++++++--------------------
 net/dccp/minisocks.c            |    2 +-
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/tcp_ipv4.c             |   14 +++++++++-----
 net/ipv4/tcp_minisocks.c        |    2 +-
 net/ipv6/tcp_ipv6.c             |   36 +++++++++++++++++-------------------
 8 files changed, 53 insertions(+), 55 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index cff4608..040780a 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -31,8 +31,7 @@ struct request_sock_ops {
 	int		obj_size;
 	struct kmem_cache	*slab;
 	int		(*rtx_syn_ack)(struct sock *sk,
-				       struct request_sock *req,
-				       struct dst_entry *dst);
+				       struct request_sock *req);
 	void		(*send_ack)(struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 474075a..514a40b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -471,15 +471,14 @@ static struct dst_entry* dccp_v4_route_skb(struct sock *sk,
 	return &rt->u.dst;
 }
 
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
-				 struct dst_entry *dst)
+static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
 {
 	int err = -1;
 	struct sk_buff *skb;
+	struct dst_entry *dst;
 
-	/* First, grab a route. */
-
-	if (dst == NULL && (dst = inet_csk_route_req(sk, req)) == NULL)
+	dst = inet_csk_route_req(sk, req);
+	if (dst == NULL)
 		goto out;
 
 	skb = dccp_make_response(sk, dst, req);
@@ -620,7 +619,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v4_send_response(sk, req, NULL))
+	if (dccp_v4_send_response(sk, req))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 490333d..1a5e50b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -224,8 +224,7 @@ out:
 }
 
 
-static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
-				 struct dst_entry *dst)
+static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 {
 	struct inet6_request_sock *ireq6 = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -234,6 +233,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	struct in6_addr *final_p = NULL, final;
 	struct flowi fl;
 	int err = -1;
+	struct dst_entry *dst;
 
 	memset(&fl, 0, sizeof(fl));
 	fl.proto = IPPROTO_DCCP;
@@ -245,28 +245,26 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	fl.fl_ip_sport = inet_sk(sk)->sport;
 	security_req_classify_flow(req, &fl);
 
-	if (dst == NULL) {
-		opt = np->opt;
+	opt = np->opt;
 
-		if (opt != NULL && opt->srcrt != NULL) {
-			const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
+	if (opt != NULL && opt->srcrt != NULL) {
+		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
 
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
+		ipv6_addr_copy(&final, &fl.fl6_dst);
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
+	}
 
-		err = ip6_dst_lookup(sk, &dst, &fl);
-		if (err)
-			goto done;
+	err = ip6_dst_lookup(sk, &dst, &fl);
+	if (err)
+		goto done;
 
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
 
-		err = xfrm_lookup(&dst, &fl, sk, 0);
-		if (err < 0)
-			goto done;
-	}
+	err = xfrm_lookup(&dst, &fl, sk, 0);
+	if (err < 0)
+		goto done;
 
 	skb = dccp_make_response(sk, dst, req);
 	if (skb != NULL) {
@@ -448,7 +446,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_iss	   = dccp_v6_init_sequence(skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v6_send_response(sk, req, NULL))
+	if (dccp_v6_send_response(sk, req))
 		goto drop_and_free;
 
 	inet6_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 027d181..33ad483 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -216,7 +216,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			 * counter (backoff, monitored by dccp_response_timer).
 			 */
 			req->retrans++;
-			req->rsk_ops->rtx_syn_ack(sk, req, NULL);
+			req->rsk_ops->rtx_syn_ack(sk, req);
 		}
 		/* Network Duplicate, discard packet */
 		return NULL;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b189278..c0e0fa0 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -463,7 +463,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 			if (time_after_eq(now, req->expires)) {
 				if ((req->retrans < thresh ||
 				     (inet_rsk(req)->acked && req->retrans < max_retries))
-				    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
+				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 256032a..3b26f95 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -723,8 +723,8 @@ static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
  *	This still operates on a request_sock only, not on a big
  *	socket.
  */
-static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
-			      struct dst_entry *dst)
+static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
+				struct dst_entry *dst)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int err = -1;
@@ -732,7 +732,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 
 	/* First, grab a route. */
 	if (!dst && (dst = inet_csk_route_req(sk, req)) == NULL)
-		goto out;
+		return -1;
 
 	skb = tcp_make_synack(sk, dst, req);
 
@@ -751,11 +751,15 @@ static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 		err = net_xmit_eval(err);
 	}
 
-out:
 	dst_release(dst);
 	return err;
 }
 
+static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req)
+{
+	return __tcp_v4_send_synack(sk, req, NULL);
+}
+
 /*
  *	IPv4 request_sock destructor.
  */
@@ -1380,7 +1384,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (tcp_v4_send_synack(sk, req, dst))
+	if (__tcp_v4_send_synack(sk, req, dst))
 		goto drop_and_free;
 
 	if (want_cookie) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b61b768..0fdd1db 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -536,7 +536,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		 * Enforce "SYN-ACK" according to figure 8, figure 6
 		 * of RFC793, fixed by RFC1122.
 		 */
-		req->rsk_ops->rtx_syn_ack(sk, req, NULL);
+		req->rsk_ops->rtx_syn_ack(sk, req);
 		return NULL;
 	}
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 12750f2..1cbbb87 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -455,8 +455,7 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
-			      struct dst_entry *dst)
+static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -464,6 +463,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	struct ipv6_txoptions *opt = NULL;
 	struct in6_addr * final_p = NULL, final;
 	struct flowi fl;
+	struct dst_entry *dst;
 	int err = -1;
 
 	memset(&fl, 0, sizeof(fl));
@@ -476,24 +476,22 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	fl.fl_ip_sport = inet_sk(sk)->sport;
 	security_req_classify_flow(req, &fl);
 
-	if (dst == NULL) {
-		opt = np->opt;
-		if (opt && opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
-
-		err = ip6_dst_lookup(sk, &dst, &fl);
-		if (err)
-			goto done;
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
-			goto done;
+	opt = np->opt;
+	if (opt && opt->srcrt) {
+		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
 	}
 
+	err = ip6_dst_lookup(sk, &dst, &fl);
+	if (err)
+		goto done;
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+	if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0)
+		goto done;
+
 	skb = tcp_make_synack(sk, dst, req);
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
@@ -1294,7 +1292,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req, NULL))
+	if (tcp_v6_send_synack(sk, req))
 		goto drop;
 
 	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-- 
1.5.3.rc5

