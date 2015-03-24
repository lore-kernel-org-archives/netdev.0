From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()
Date: Mon, 23 Mar 2015 21:34:26 -0700
Message-ID: <1427171666-30585-5-git-send-email-edumazet@google.com>
References: <1427171666-30585-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33222 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCXEfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 00:35:17 -0400
Received: by ykbq200 with SMTP id q200so7345737ykb.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 21:35:17 -0700 (PDT)
In-Reply-To: <1427171666-30585-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With request socks convergence, we no longer need
different lookup methods. A request socket can
use generic lookup function.

Add const qualifiers to tcp_v4_md5_lookup() arguments.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 16 ++++++++--------
 net/ipv4/tcp_ipv4.c   | 23 +++++++----------------
 net/ipv4/tcp_output.c |  2 +-
 net/ipv6/tcp_ipv6.c   | 16 +++++-----------
 4 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 992be858c370..16869f693ae7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1302,16 +1302,16 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp);
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family);
-struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
-					 struct sock *addr_sk);
+struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
+					 const struct sock *addr_sk);
 
 #ifdef CONFIG_TCP_MD5SIG
-struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family);
 #define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_key)
 #else
-static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+static inline struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family)
 {
@@ -1613,8 +1613,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 /* TCP af-specific functions */
 struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
-						struct sock *addr_sk);
+	struct tcp_md5sig_key	*(*md5_lookup) (const struct sock *sk,
+						const struct sock *addr_sk);
 	int		(*calc_md5_hash)(char *location,
 					 const struct tcp_md5sig_key *md5,
 					 const struct sock *sk,
@@ -1628,8 +1628,8 @@ struct tcp_sock_af_ops {
 struct tcp_request_sock_ops {
 	u16 mss_clamp;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
-						struct request_sock *req);
+	struct tcp_md5sig_key *(*req_md5_lookup)(const struct sock *sk,
+						 const struct sock *addr_sk);
 	int		(*calc_md5_hash) (char *location,
 					  const struct tcp_md5sig_key *md5,
 					  const struct sock *sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 79d5c641688c..942fc9ffc518 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -894,14 +894,14 @@ EXPORT_SYMBOL(tcp_syn_flood_action);
  */
 
 /* Find the Key structure for an address.  */
-struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
 	unsigned int size = sizeof(struct in_addr);
-	struct tcp_md5sig_info *md5sig;
+	const struct tcp_md5sig_info *md5sig;
 
 	/* caller either holds rcu_read_lock() or socket lock */
 	md5sig = rcu_dereference_check(tp->md5sig_info,
@@ -923,25 +923,16 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 }
 EXPORT_SYMBOL(tcp_md5_do_lookup);
 
-struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
-					 struct sock *addr_sk)
+struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
+					 const struct sock *addr_sk)
 {
 	union tcp_md5_addr *addr;
 
-	addr = (union tcp_md5_addr *)&inet_sk(addr_sk)->inet_daddr;
+	addr = (union tcp_md5_addr *)&sk->sk_daddr;
 	return tcp_md5_do_lookup(sk, addr, AF_INET);
 }
 EXPORT_SYMBOL(tcp_v4_md5_lookup);
 
-static struct tcp_md5sig_key *tcp_v4_reqsk_md5_lookup(struct sock *sk,
-						      struct request_sock *req)
-{
-	union tcp_md5_addr *addr;
-
-	addr = (union tcp_md5_addr *)&inet_rsk(req)->ir_rmt_addr;
-	return tcp_md5_do_lookup(sk, addr, AF_INET);
-}
-
 /* This can be called on a newly created socket, from other files */
 int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp)
@@ -1247,7 +1238,7 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.mss_clamp	=	TCP_MSS_DEFAULT,
 #ifdef CONFIG_TCP_MD5SIG
-	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
+	.req_md5_lookup	=	tcp_v4_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 #endif
 	.init_req	=	tcp_v4_init_req,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ab6c714aef2f..66cc3e7325fb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -608,7 +608,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 
 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	*md5 = tcp_rsk(req)->af_specific->req_md5_lookup(sk, req_to_sk(req));
 	if (*md5) {
 		opts->options |= OPTION_MD5;
 		remaining -= TCPOLEN_MD5SIG_ALIGNED;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 57d1c41404ec..e30b63850145 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -82,7 +82,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(const struct sock *sk,
 						   const struct in6_addr *addr)
 {
 	return NULL;
@@ -479,24 +479,18 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 }
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(const struct sock *sk,
 						   const struct in6_addr *addr)
 {
 	return tcp_md5_do_lookup(sk, (union tcp_md5_addr *)addr, AF_INET6);
 }
 
-static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
-						struct sock *addr_sk)
+static struct tcp_md5sig_key *tcp_v6_md5_lookup(const struct sock *sk,
+						const struct sock *addr_sk)
 {
 	return tcp_v6_md5_do_lookup(sk, &addr_sk->sk_v6_daddr);
 }
 
-static struct tcp_md5sig_key *tcp_v6_reqsk_md5_lookup(struct sock *sk,
-						      struct request_sock *req)
-{
-	return tcp_v6_md5_do_lookup(sk, &inet_rsk(req)->ir_v6_rmt_addr);
-}
-
 static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 				 int optlen)
 {
@@ -720,7 +714,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.mss_clamp	=	IPV6_MIN_MTU - sizeof(struct tcphdr) -
 				sizeof(struct ipv6hdr),
 #ifdef CONFIG_TCP_MD5SIG
-	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
+	.req_md5_lookup	=	tcp_v6_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 #endif
 	.init_req	=	tcp_v6_init_req,
-- 
2.2.0.rc0.207.ga3a616c
