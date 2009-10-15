From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH 1/4] TCPCT part 1: initial SYN exchange with
 SYNACK data
Date: Thu, 15 Oct 2009 01:28:59 -0400
Message-ID: <4AD6B31B.3060402@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070702020003000802040303"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:48115 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbZJOF3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:29:38 -0400
Received: by ywh6 with SMTP id 6so520376ywh.4
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 22:29:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070702020003000802040303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Pass optional function parameters associated with sending SYNACK.
These parameters are not needed after sending SYNACK, and are not
used for retransmission.  Avoids extending struct tcp_request_sock,
and avoids allocating kernel memory.
---
  include/net/request_sock.h      |    3 ++-
  include/net/tcp.h               |    3 ++-
  net/dccp/ipv4.c                 |    5 +++--
  net/dccp/ipv6.c                 |    5 +++--
  net/dccp/minisocks.c            |    2 +-
  net/ipv4/inet_connection_sock.c |    2 +-
  net/ipv4/tcp_ipv4.c             |   12 +++++++-----
  net/ipv4/tcp_minisocks.c        |    2 +-
  net/ipv4/tcp_output.c           |    2 +-
  net/ipv6/tcp_ipv6.c             |   14 +++++++-------
  10 files changed, 28 insertions(+), 22 deletions(-)


--------------070702020003000802040303
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1-1.patch"

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c719084..cdd9e8b 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -33,7 +33,8 @@ struct request_sock_ops {
 	struct kmem_cache	*slab;
 	char		*slab_name;
 	int		(*rtx_syn_ack)(struct sock *sk,
-				       struct request_sock *req);
+				       struct request_sock *req,
+				       void *extend_values);
 	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..28bcaf7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -443,7 +443,8 @@ extern int			tcp_connect(struct sock *sk);
 
 extern struct sk_buff *		tcp_make_synack(struct sock *sk,
 						struct dst_entry *dst,
-						struct request_sock *req);
+						struct request_sock *req,
+						void *extend_values);
 
 extern int			tcp_disconnect(struct sock *sk, int flags);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7302e14..6fc9ea3 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -473,7 +473,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	return &rt->u.dst;
 }
 
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
+				 void *extend_unused)
 {
 	int err = -1;
 	struct sk_buff *skb;
@@ -622,7 +623,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v4_send_response(sk, req))
+	if (dccp_v4_send_response(sk, req, NULL))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index a2afb55..63fb189 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -241,7 +241,8 @@ out:
 }
 
 
-static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
+				 void *extend_unused)
 {
 	struct inet6_request_sock *ireq6 = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -468,7 +469,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_iss	   = dccp_v6_init_sequence(skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v6_send_response(sk, req))
+	if (dccp_v6_send_response(sk, req, NULL))
 		goto drop_and_free;
 
 	inet6_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5ca49ce..af226a0 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -184,7 +184,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			 * counter (backoff, monitored by dccp_response_timer).
 			 */
 			req->retrans++;
-			req->rsk_ops->rtx_syn_ack(sk, req);
+			req->rsk_ops->rtx_syn_ack(sk, req, NULL);
 		}
 		/* Network Duplicate, discard packet */
 		return NULL;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 9139e8f..b7314f2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -504,7 +504,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 			if (time_after_eq(now, req->expires)) {
 				if ((req->retrans < thresh ||
 				     (inet_rsk(req)->acked && req->retrans < max_retries))
-				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
+				    && !req->rsk_ops->rtx_syn_ack(parent, req, NULL)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9971870..2d25bd4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -742,7 +742,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	socket.
  */
 static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
-				struct dst_entry *dst)
+				struct dst_entry *dst, void *extend_values)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int err = -1;
@@ -752,7 +752,7 @@ static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 	if (!dst && (dst = inet_csk_route_req(sk, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req);
+	skb = tcp_make_synack(sk, dst, req, extend_values);
 
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
@@ -773,9 +773,10 @@ static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 	return err;
 }
 
-static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req)
+static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
+			      void *extend_values)
 {
-	return __tcp_v4_send_synack(sk, req, NULL);
+	return __tcp_v4_send_synack(sk, req, NULL, extend_values);
 }
 
 /*
@@ -1333,7 +1334,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, req, dst) || want_cookie)
+	if (__tcp_v4_send_synack(sk, req, dst, NULL) ||
+	    want_cookie)
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e320afe..8819882 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -537,7 +537,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		 * Enforce "SYN-ACK" according to figure 8, figure 6
 		 * of RFC793, fixed by RFC1122.
 		 */
-		req->rsk_ops->rtx_syn_ack(sk, req);
+		req->rsk_ops->rtx_syn_ack(sk, req, NULL);
 		return NULL;
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..765d80f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2219,7 +2219,7 @@ int tcp_send_synack(struct sock *sk)
 
 /* Prepare a SYN-ACK. */
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
-				struct request_sock *req)
+				struct request_sock *req, void *extend_values)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4517630..3b3d7b3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -460,7 +460,8 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
+static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
+			      void *extend_values)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -498,7 +499,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 	if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req);
+	skb = tcp_make_synack(sk, dst, req, extend_values);
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
 
@@ -1242,13 +1243,12 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req))
+	if (tcp_v6_send_synack(sk, req, NULL) ||
+	    want_cookie)
 		goto drop;
 
-	if (!want_cookie) {
-		inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-		return 0;
-	}
+	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	return 0;
 
 drop:
 	if (req)
-- 
1.6.0.4


--------------070702020003000802040303--
