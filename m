From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/8] inet: remove some sk_listener dependencies
Date: Sun, 22 Mar 2015 10:22:20 -0700
Message-ID: <1427044945-32608-4-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33077 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbCVRWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:22:53 -0400
Received: by igjz20 with SMTP id z20so2068269igj.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:22:52 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

listener can be source of false sharing. request sock has some
useful information like : ireq->ir_iif, ireq->ir_num, ireq->ireq_net

This patch does not solve the major problem of having to read
sk->sk_protocol which is sharing a cache line with sk->sk_wmem_alloc.
(This same field is read later in ip_build_and_send_pkt())

One idea would be to move sk_protocol close to sk_family
(using 8 bits instead of 16 for sk_family seems enough)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a12b973164d0..711ab143d4cb 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -403,18 +403,17 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 				     struct flowi4 *fl4,
 				     const struct request_sock *req)
 {
-	struct rtable *rt;
 	const struct inet_request_sock *ireq = inet_rsk(req);
-	struct ip_options_rcu *opt = inet_rsk(req)->opt;
-	struct net *net = sock_net(sk);
-	int flags = inet_sk_flowi_flags(sk);
+	struct net *net = read_pnet(&ireq->ireq_net);
+	struct ip_options_rcu *opt = ireq->opt;
+	struct rtable *rt;
 
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, ireq->ir_mark,
+	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
-			   sk->sk_protocol,
-			   flags,
+			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+			   ireq->ir_loc_addr, ireq->ir_rmt_port,
+			   htons(ireq->ir_num));
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
@@ -436,9 +435,9 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 					    const struct request_sock *req)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
+	struct net *net = read_pnet(&ireq->ireq_net);
 	struct inet_sock *newinet = inet_sk(newsk);
 	struct ip_options_rcu *opt;
-	struct net *net = sock_net(sk);
 	struct flowi4 *fl4;
 	struct rtable *rt;
 
@@ -446,11 +445,12 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 
 	rcu_read_lock();
 	opt = rcu_dereference(newinet->inet_opt);
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, inet_rsk(req)->ir_mark,
+	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
-			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
+			   ireq->ir_loc_addr, ireq->ir_rmt_port,
+			   htons(ireq->ir_num));
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
-- 
2.2.0.rc0.207.ga3a616c
