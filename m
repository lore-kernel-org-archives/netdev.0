From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] inet: fill request sock ir_iif for IPv4
Date: Fri, 13 Mar 2015 13:19:16 -0700
Message-ID: <1426277958-9772-2-git-send-email-edumazet@google.com>
References: <1426277958-9772-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:33820 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbCMUTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 16:19:35 -0400
Received: by igqa13 with SMTP id a13so2161912igq.1
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 13:19:35 -0700 (PDT)
In-Reply-To: <1426277958-9772-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once request socks will be in ehash table, they will need to have
a valid ir_iff field.

This is currently true only for IPv6. This patch extends support
for IPv4 as well.

This means inet_diag_fill_req() can now properly use ir_iif,
which is better for IPv6 link locals anyway, as request sockets
and established sockets will propagate consistent netlink idiag_if.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv4.c       | 1 +
 net/ipv4/inet_diag.c  | 2 +-
 net/ipv4/syncookies.c | 2 ++
 net/ipv4/tcp_input.c  | 3 +++
 net/ipv6/tcp_ipv6.c   | 2 --
 5 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8f6f4004daac..7f6456afbaec 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -643,6 +643,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_rmt_addr = ip_hdr(skb)->saddr;
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET;
+	ireq->ir_iif = sk->sk_bound_dev_if;
 
 	/*
 	 * Step 3: Process LISTEN state
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 43789c99031f..e1e4d8c0384a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -733,7 +733,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_timer = 1;
 	r->idiag_retrans = req->num_retrans;
 
-	r->id.idiag_if = sk->sk_bound_dev_if;
+	r->id.idiag_if = ireq->ir_iif;
 
 	BUILD_BUG_ON(offsetof(struct inet_request_sock, ir_cookie) !=
 		     offsetof(struct sock, sk_cookie));
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 0c432730c7b4..f17db898ed26 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -349,6 +349,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	write_pnet(&ireq->ireq_net, sock_net(sk));
 	ireq->ireq_family = AF_INET;
 
+	ireq->ir_iif = sk->sk_bound_dev_if;
+
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
 	 */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index da61a8e75f68..717d437b6ce1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5967,6 +5967,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_openreq_init(req, &tmp_opt, skb, sk);
 	write_pnet(&inet_rsk(req)->ireq_net, sock_net(sk));
 
+	/* Note: tcp_v6_init_req() might override ir_iif for link locals */
+	inet_rsk(req)->ir_iif = sk->sk_bound_dev_if;
+
 	af_ops->init_req(req, sk, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c5fc6a5e4adc..d89f028dc8c4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -734,8 +734,6 @@ static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 
-	ireq->ir_iif = sk->sk_bound_dev_if;
-
 	/* So that link locals have meaning */
 	if (!sk->sk_bound_dev_if &&
 	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
-- 
2.2.0.rc0.207.ga3a616c
