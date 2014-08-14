From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix tcp_release_cb() to dispatch via address family for mtu_reduced()
Date: Thu, 14 Aug 2014 12:40:05 -0400
Message-ID: <1408034405-30596-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:47219 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaHNQkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 12:40:15 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so371306pab.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 09:40:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure we use the correct address-family-specific function for
handling MTU reductions from within tcp_release_cb().

Previously AF_INET6 sockets were incorrectly always using the IPv6
code path when sometimes they were handling IPv4 traffic and thus had
an IPv4 dst.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Diagnosed-by: Willem de Bruijn <willemb@google.com>
Fixes: 563d34d057862 ("tcp: dont drop MTU reduction indications")
---
 include/net/inet_connection_sock.h | 1 +
 include/net/sock.h                 | 1 -
 include/net/tcp.h                  | 1 +
 net/ipv4/tcp_ipv4.c                | 5 +++--
 net/ipv4/tcp_output.c              | 2 +-
 net/ipv6/tcp_ipv6.c                | 3 ++-
 6 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 7a43138..5fbe656 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -62,6 +62,7 @@ struct inet_connection_sock_af_ops {
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
 	int	    (*bind_conflict)(const struct sock *sk,
 				     const struct inet_bind_bucket *tb, bool relax);
+	void	    (*mtu_reduced)(struct sock *sk);
 };
 
 /** inet_connection_sock - INET connection oriented sock
diff --git a/include/net/sock.h b/include/net/sock.h
index 38805fa..7f2ab72 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -987,7 +987,6 @@ struct proto {
 						struct sk_buff *skb);
 
 	void		(*release_cb)(struct sock *sk);
-	void		(*mtu_reduced)(struct sock *sk);
 
 	/* Keeping track of sk's, looking them up, and port selection methods. */
 	void			(*hash)(struct sock *sk);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index dafa1cb..2486915 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -448,6 +448,7 @@ const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
  */
 
 void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
+void tcp_v4_mtu_reduced(struct sock *sk);
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 struct sock *tcp_create_openreq_child(struct sock *sk,
 				      struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index dceff5f..cd17f00 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -271,7 +271,7 @@ EXPORT_SYMBOL(tcp_v4_connect);
  * It can be called through tcp_release_cb() if socket was owned by user
  * at the time tcp_v4_err() was called to handle ICMP message.
  */
-static void tcp_v4_mtu_reduced(struct sock *sk)
+void tcp_v4_mtu_reduced(struct sock *sk)
 {
 	struct dst_entry *dst;
 	struct inet_sock *inet = inet_sk(sk);
@@ -302,6 +302,7 @@ static void tcp_v4_mtu_reduced(struct sock *sk)
 		tcp_simple_retransmit(sk);
 	} /* else let the usual retransmit timer handle it */
 }
+EXPORT_SYMBOL(tcp_v4_mtu_reduced);
 
 static void do_redirect(struct sk_buff *skb, struct sock *sk)
 {
@@ -1787,6 +1788,7 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.compat_setsockopt = compat_ip_setsockopt,
 	.compat_getsockopt = compat_ip_getsockopt,
 #endif
+	.mtu_reduced	   = tcp_v4_mtu_reduced,
 };
 EXPORT_SYMBOL(ipv4_specific);
 
@@ -2406,7 +2408,6 @@ struct proto tcp_prot = {
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v4_do_rcv,
 	.release_cb		= tcp_release_cb,
-	.mtu_reduced		= tcp_v4_mtu_reduced,
 	.hash			= inet_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ef4a051..ce955d5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -800,7 +800,7 @@ void tcp_release_cb(struct sock *sk)
 		__sock_put(sk);
 	}
 	if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED)) {
-		sk->sk_prot->mtu_reduced(sk);
+		inet_csk(sk)->icsk_af_ops->mtu_reduced(sk);
 		__sock_put(sk);
 	}
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f2ce955..29964c3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1595,6 +1595,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
+	.mtu_reduced	   = tcp_v6_mtu_reduced,
 };
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1625,6 +1626,7 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
+	.mtu_reduced	   = tcp_v4_mtu_reduced,
 };
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -1864,7 +1866,6 @@ struct proto tcpv6_prot = {
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.release_cb		= tcp_release_cb,
-	.mtu_reduced		= tcp_v6_mtu_reduced,
 	.hash			= tcp_v6_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
-- 
2.1.0.rc2.206.gedb03e5
