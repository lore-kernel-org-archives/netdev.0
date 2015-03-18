From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/6] inet: add sk_listener argument to inet_reqsk_alloc()
Date: Tue, 17 Mar 2015 18:32:26 -0700
Message-ID: <1426642351-26098-2-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:33454 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbbCRBcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:32:53 -0400
Received: by oiba3 with SMTP id a3so1720312oib.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:32:52 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

listener socket can be used to set net pointer, and will
be later used to hold a reference on listener.

Add a const qualifier to first argument (struct request_sock_ops *),
and factorize all write_pnet(&ireq->ireq_net, sock_net(sk));

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 9 ++++++---
 net/dccp/ipv4.c         | 3 +--
 net/dccp/ipv6.c         | 3 +--
 net/ipv4/syncookies.c   | 3 +--
 net/ipv4/tcp_input.c    | 3 +--
 net/ipv6/syncookies.c   | 3 +--
 6 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index c9ed91891887..cf7abb00941b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -244,16 +244,19 @@ static inline unsigned int __inet_ehashfn(const __be32 laddr,
 			    initval);
 }
 
-static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops)
+static inline struct request_sock *
+inet_reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 {
 	struct request_sock *req = reqsk_alloc(ops);
-	struct inet_request_sock *ireq = inet_rsk(req);
 
-	if (req != NULL) {
+	if (req) {
+		struct inet_request_sock *ireq = inet_rsk(req);
+
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
+		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
 
 		/* Following is temporary. It is coupled with debugging
 		 * helpers in reqsk_put() & reqsk_free()
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7f6456afbaec..bf897829f4f0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -624,7 +624,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet_reqsk_alloc(&dccp_request_sock_ops);
+	req = inet_reqsk_alloc(&dccp_request_sock_ops, sk);
 	if (req == NULL)
 		goto drop;
 
@@ -641,7 +641,6 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_loc_addr = ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
-	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET;
 	ireq->ir_iif = sk->sk_bound_dev_if;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5166b0043f95..d7e7c7b0a3f1 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -386,7 +386,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet_reqsk_alloc(&dccp6_request_sock_ops);
+	req = inet_reqsk_alloc(&dccp6_request_sock_ops, sk);
 	if (req == NULL)
 		goto drop;
 
@@ -403,7 +403,6 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
-	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET6;
 
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5ae0c49f5e2e..eb940750bb1b 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -325,7 +325,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ret = NULL;
-	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
+	req = inet_reqsk_alloc(&tcp_request_sock_ops, sk); /* for safety */
 	if (!req)
 		goto out;
 
@@ -346,7 +346,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->listener		= NULL;
-	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET;
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7257eb206c07..2a480f6811ea 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6004,7 +6004,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop;
 	}
 
-	req = inet_reqsk_alloc(rsk_ops);
+	req = inet_reqsk_alloc(rsk_ops, sk);
 	if (!req)
 		goto drop;
 
@@ -6020,7 +6020,6 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
-	write_pnet(&inet_rsk(req)->ireq_net, sock_net(sk));
 
 	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
 	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 58875ce8e178..039e74dd29fe 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -189,14 +189,13 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ret = NULL;
-	req = inet_reqsk_alloc(&tcp6_request_sock_ops);
+	req = inet_reqsk_alloc(&tcp6_request_sock_ops, sk);
 	if (!req)
 		goto out;
 
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
 	treq->listener = NULL;
-	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET6;
 
 	if (security_inet_conn_request(sk, skb, req))
-- 
2.2.0.rc0.207.ga3a616c
