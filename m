From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v5 1/5 RFC] TCPCT part 1a: add request_values
 parameter for sending SYNACK
Date: Mon, 09 Nov 2009 11:12:14 -0500
Message-ID: <4AF83F5E.6000109@gmail.com>
References: <4AF83E2D.1050401@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050702050903070708080000"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:40460 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756435AbZKIQMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:12:14 -0500
Received: by fxm21 with SMTP id 21so304292fxm.21
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 08:12:19 -0800 (PST)
In-Reply-To: <4AF83E2D.1050401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050702050903070708080000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Add optional function parameters associated with sending SYNACK.
These parameters are not needed after sending SYNACK, and are not
used for retransmission.  Avoids extending struct tcp_request_sock,
and avoids allocating kernel memory.

Also affects DCCP as it uses common struct request_sock_ops,
but this parameter is currently reserved for future use.

Signed-off-by: William.Allen.Simpson@gmail.com
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
  include/net/request_sock.h      |    8 +++++++-
  include/net/tcp.h               |    1 +
  net/dccp/ipv4.c                 |    5 +++--
  net/dccp/ipv6.c                 |    5 +++--
  net/dccp/minisocks.c            |    2 +-
  net/ipv4/inet_connection_sock.c |    2 +-
  net/ipv4/tcp_ipv4.c             |   17 ++++++++++-------
  net/ipv4/tcp_minisocks.c        |    2 +-
  net/ipv4/tcp_output.c           |    1 +
  net/ipv6/tcp_ipv6.c             |   28 +++++++++++++---------------
  10 files changed, 41 insertions(+), 30 deletions(-)

--------------050702050903070708080000
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1a5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1a5.patch"

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c719084..c9b50eb 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -27,13 +27,19 @@ struct sk_buff;
 struct dst_entry;
 struct proto;
 
+/* empty to "strongly type" an otherwise void parameter.
+ */
+struct request_values {
+};
+
 struct request_sock_ops {
 	int		family;
 	int		obj_size;
 	struct kmem_cache	*slab;
 	char		*slab_name;
 	int		(*rtx_syn_ack)(struct sock *sk,
-				       struct request_sock *req);
+				       struct request_sock *req,
+				       struct request_values *rvp);
 	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index bf20f88..25bf3ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -443,6 +443,7 @@ extern int			tcp_connect(struct sock *sk);
 
 extern struct sk_buff *		tcp_make_synack(struct sock *sk,
 						struct dst_entry *dst,
+						struct request_values *rvp,
 						struct request_sock *req);
 
 extern int			tcp_disconnect(struct sock *sk, int flags);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2423a08..efbcfdc 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -477,7 +477,8 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	return &rt->u.dst;
 }
 
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
+				 struct request_values *rv_unused)
 {
 	int err = -1;
 	struct sk_buff *skb;
@@ -626,7 +627,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
 	dreq->dreq_service = service;
 
-	if (dccp_v4_send_response(sk, req))
+	if (dccp_v4_send_response(sk, req, NULL))
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 50ea91a..6574215 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -241,7 +241,8 @@ out:
 }
 
 
-static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
+static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
+				 struct request_values *rv_unused)
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
index 26fb50e..ad098d6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -531,7 +531,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 					       &expire, &resend);
 				if (!expire &&
 				    (!resend ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req) ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
 				     inet_rsk(req)->acked)) {
 					unsigned long timeo;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 657ae33..f83ac91 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -743,7 +743,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	socket.
  */
 static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
-				struct dst_entry *dst)
+				struct dst_entry *dst,
+				struct request_values *rvp)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int err = -1;
@@ -753,7 +754,7 @@ static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 	if (!dst && (dst = inet_csk_route_req(sk, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req);
+	skb = tcp_make_synack(sk, dst, rvp, req);
 
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
@@ -774,9 +775,10 @@ static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 	return err;
 }
 
-static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req)
+static int tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
+			      struct request_values *rvp)
 {
-	return __tcp_v4_send_synack(sk, req, NULL);
+	return __tcp_v4_send_synack(sk, req, NULL, rvp);
 }
 
 /*
@@ -1211,13 +1213,13 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct inet_request_sock *ireq;
 	struct tcp_options_received tmp_opt;
 	struct request_sock *req;
+	struct inet_request_sock *ireq;
+	struct dst_entry *dst = NULL;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
-	struct dst_entry *dst = NULL;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1337,7 +1339,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, req, dst) || want_cookie)
+	if (__tcp_v4_send_synack(sk, req, dst, NULL)
+	 || want_cookie)
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a9d34e2..fb68bab 100644
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
index 616c686..784e6ee 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2224,6 +2224,7 @@ int tcp_send_synack(struct sock *sk)
 
 /* Prepare a SYN-ACK. */
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
+				struct request_values *rvp,
 				struct request_sock *req)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 696a22f..6951827 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -461,7 +461,8 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
+static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
+			      struct request_values *rvp)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -499,7 +500,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 	if ((err = xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req);
+	skb = tcp_make_synack(sk, dst, rvp, req);
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
 
@@ -1161,13 +1162,13 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_options_received tmp_opt;
+	struct request_sock *req;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct tcp_options_received tmp_opt;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct request_sock *req = NULL;
-	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = __sk_dst_get(sk);
+	__u32 isn = TCP_SKB_CB(skb)->when;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
 #else
@@ -1239,23 +1240,20 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 		isn = tcp_v6_init_sequence(skb);
 	}
-
 	tcp_rsk(req)->snt_isn = isn;
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req))
-		goto drop;
+	if (tcp_v6_send_synack(sk, req, NULL)
+	 || want_cookie)
+		goto drop_and_free;
 
-	if (!want_cookie) {
-		inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-		return 0;
-	}
+	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	return 0;
 
+drop_and_free:
+	reqsk_free(req);
 drop:
-	if (req)
-		reqsk_free(req);
-
 	return 0; /* don't send reset */
 }
 
-- 
1.6.3.3


--------------050702050903070708080000--
