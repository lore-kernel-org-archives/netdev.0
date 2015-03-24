From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 5/5] tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()
Date: Tue, 24 Mar 2015 15:58:56 -0700
Message-ID: <1427237936-19030-6-git-send-email-edumazet@google.com>
References: <1427237936-19030-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:34605 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbbCXW7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:59:41 -0400
Received: by obcwp18 with SMTP id wp18so616922obc.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:59:40 -0700 (PDT)
In-Reply-To: <1427237936-19030-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With request socks convergence, we no longer need
different lookup methods. A request socket can
use generic lookup function.

Add const qualifier to 2nd tcp_v[46]_md5_lookup() parameter.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |  8 ++++----
 net/ipv4/tcp_ipv4.c   | 19 +++++--------------
 net/ipv4/tcp_output.c |  2 +-
 net/ipv6/tcp_ipv6.c   | 10 ++--------
 4 files changed, 12 insertions(+), 27 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 992be858c370..42690daa924e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1303,7 +1303,7 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family);
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
-					 struct sock *addr_sk);
+					 const struct sock *addr_sk);
 
 #ifdef CONFIG_TCP_MD5SIG
 struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
@@ -1614,7 +1614,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
-						struct sock *addr_sk);
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
+	struct tcp_md5sig_key *(*req_md5_lookup)(struct sock *sk,
+						 const struct sock *addr_sk);
 	int		(*calc_md5_hash) (char *location,
 					  const struct tcp_md5sig_key *md5,
 					  const struct sock *sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 79d5c641688c..fc8995a702a6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -898,10 +898,10 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
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
@@ -924,24 +924,15 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 EXPORT_SYMBOL(tcp_md5_do_lookup);
 
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
-					 struct sock *addr_sk)
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
index 501cf9d401c3..2e69b8d16e68 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2938,7 +2938,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 #ifdef CONFIG_TCP_MD5SIG
 	rcu_read_lock();
-	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	md5 = tcp_rsk(req)->af_specific->req_md5_lookup(sk, req_to_sk(req));
 #endif
 	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, md5,
 					     foc) + sizeof(*th);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 57d1c41404ec..a9568caf4675 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -486,17 +486,11 @@ static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
 }
 
 static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
-						struct sock *addr_sk)
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
