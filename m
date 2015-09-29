From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/14] tcp/dccp: constify syn_recv_sock() method sock argument
Date: Tue, 29 Sep 2015 07:42:48 -0700
Message-ID: <1443537772-15305-11-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33575 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbbI2Orq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:47:46 -0400
Received: by pacex6 with SMTP id ex6so8500743pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:47:45 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll soon no longer hold listener socket lock, these
functions do not modify the socket in any way.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h | 2 +-
 include/net/tcp.h                  | 2 +-
 net/dccp/dccp.h                    | 2 +-
 net/dccp/ipv4.c                    | 3 ++-
 net/dccp/ipv6.c                    | 5 +++--
 net/ipv4/tcp_ipv4.c                | 2 +-
 net/ipv6/tcp_ipv6.c                | 5 +++--
 7 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 187cef7e56d5..ee54f21a8113 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -41,7 +41,7 @@ struct inet_connection_sock_af_ops {
 	int	    (*rebuild_header)(struct sock *sk);
 	void	    (*sk_rx_dst_set)(struct sock *sk, const struct sk_buff *skb);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
-	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
+	struct sock *(*syn_recv_sock)(const struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
 				      struct dst_entry *dst);
 	u16	    net_header_len;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 85995c1291d0..a1d2f5d6a430 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -454,7 +454,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 				      struct request_sock *req,
 				      struct sk_buff *skb);
 void tcp_ca_openreq_child(struct sock *sk, const struct dst_entry *dst);
-struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req,
 				  struct dst_entry *dst);
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 2409619b7043..e1f823451565 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -276,7 +276,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
 
 int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 
-struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
+struct sock *dccp_v4_request_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				       struct request_sock *req,
 				       struct dst_entry *dst);
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 00a14fa4270a..5b7818c63cec 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -390,7 +390,8 @@ static inline u64 dccp_v4_init_sequence(const struct sk_buff *skb)
  *
  * This is the equivalent of TCP's tcp_v4_syn_recv_sock
  */
-struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
+struct sock *dccp_v4_request_recv_sock(const struct sock *sk,
+				       struct sk_buff *skb,
 				       struct request_sock *req,
 				       struct dst_entry *dst)
 {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0966bc08d362..e8753aa3b7a4 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -408,13 +408,14 @@ drop:
 	return -1;
 }
 
-static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
+static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 					      struct sk_buff *skb,
 					      struct request_sock *req,
 					      struct dst_entry *dst)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
-	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
+	struct ipv6_pinfo *newnp;
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *newinet;
 	struct dccp6_sock *newdp6;
 	struct sock *newsk;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 67c0dc8bddbf..ee0239e190cf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1242,7 +1242,7 @@ EXPORT_SYMBOL(tcp_v4_conn_request);
  * The three way handshake has completed - we got a valid synack -
  * now create the new socket.
  */
-struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req,
 				  struct dst_entry *dst)
 {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 092a23ef1feb..2330c7be6323 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -986,12 +986,13 @@ drop:
 	return 0; /* don't send reset */
 }
 
-static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 					 struct request_sock *req,
 					 struct dst_entry *dst)
 {
 	struct inet_request_sock *ireq;
-	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
+	struct ipv6_pinfo *newnp;
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcp6_sock *newtcp6sk;
 	struct inet_sock *newinet;
 	struct tcp_sock *newtp;
-- 
2.6.0.rc2.230.g3dd15c0
