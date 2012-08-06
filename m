From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ipv6: fix TCP early demux
Date: Mon, 06 Aug 2012 17:09:33 +0200
Message-ID: <1344265773.26674.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61010 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134Ab2HFPJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 11:09:38 -0400
Received: by bkwj10 with SMTP id j10so1071586bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 08:09:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 needs a cookie in dst_check() call.

We need to add rx_dst_cookie and provide a family independent
sk_rx_dst_set(sk, skb) method to properly support IPv6 TCP early demux.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: we could group sk_rx_dst/rx_dst_ifindex/rx_dst_cookie
in same cache line (in sk)

 include/linux/ipv6.h               |    1 +
 include/net/inet_connection_sock.h |    1 +
 include/net/inet_sock.h            |    9 ---------
 net/ipv4/tcp_input.c               |    4 +++-
 net/ipv4/tcp_ipv4.c                |   13 ++++++++++---
 net/ipv4/tcp_minisocks.c           |    2 +-
 net/ipv6/tcp_ipv6.c                |   27 +++++++++++++++++++++++++--
 7 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 379e433..879db26 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -369,6 +369,7 @@ struct ipv6_pinfo {
 	__u8			rcv_tclass;
 
 	__u32			dst_cookie;
+	__u32			rx_dst_cookie;
 
 	struct ipv6_mc_socklist	__rcu *ipv6_mc_list;
 	struct ipv6_ac_socklist	*ipv6_ac_list;
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 5ee66f5..ba1d361 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -39,6 +39,7 @@ struct inet_connection_sock_af_ops {
 	int	    (*queue_xmit)(struct sk_buff *skb, struct flowi *fl);
 	void	    (*send_check)(struct sock *sk, struct sk_buff *skb);
 	int	    (*rebuild_header)(struct sock *sk);
+	void	    (*sk_rx_dst_set)(struct sock *sk, const struct sk_buff *skb);
 	int	    (*conn_request)(struct sock *sk, struct sk_buff *skb);
 	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 83b567f..613cfa4 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -249,13 +249,4 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return flags;
 }
 
-static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-
-	dst_hold(dst);
-	sk->sk_rx_dst = dst;
-	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-}
-
 #endif	/* _INET_SOCK_H */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2fd2bc9..85308b9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5392,6 +5392,8 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	if (unlikely(sk->sk_rx_dst == NULL))
+		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
 	/*
 	 *	Header prediction.
 	 *	The code loosely follows the one in the famous
@@ -5605,7 +5607,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	tcp_set_state(sk, TCP_ESTABLISHED);
 
 	if (skb != NULL) {
-		inet_sk_rx_dst_set(sk, skb);
+		icsk->icsk_af_ops->sk_rx_dst_set(sk, skb);
 		security_inet_conn_established(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 42b2a6a..272241f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1627,9 +1627,6 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (unlikely(sk->sk_rx_dst == NULL))
-			inet_sk_rx_dst_set(sk, skb);
-
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
@@ -1872,10 +1869,20 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 	.twsk_destructor= tcp_twsk_destructor,
 };
 
+static void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	dst_hold(dst);
+	sk->sk_rx_dst = dst;
+	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+}
+
 const struct inet_connection_sock_af_ops ipv4_specific = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = tcp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
+	.sk_rx_dst_set	   = inet_sk_rx_dst_set,
 	.conn_request	   = tcp_v4_conn_request,
 	.syn_recv_sock	   = tcp_v4_syn_recv_sock,
 	.net_header_len	   = sizeof(struct iphdr),
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 232a90c..d9c9dce 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,7 +387,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
-		inet_sk_rx_dst_set(newsk, skb);
+		newicsk->icsk_af_ops->sk_rx_dst_set(newsk, skb);
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c66b90f..5a439e9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1447,7 +1447,17 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		opt_skb = skb_clone(skb, sk_gfp_atomic(sk, GFP_ATOMIC));
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
+		struct dst_entry *dst = sk->sk_rx_dst;
+
 		sock_rps_save_rxhash(sk, skb);
+		if (dst) {
+			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
+			    dst->ops->check(dst, np->rx_dst_cookie) == NULL) {
+				dst_release(dst);
+				sk->sk_rx_dst = NULL;
+			}
+		}
+
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
 			goto reset;
 		if (opt_skb)
@@ -1705,9 +1715,9 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 			struct dst_entry *dst = sk->sk_rx_dst;
 			struct inet_sock *icsk = inet_sk(sk);
 			if (dst)
-				dst = dst_check(dst, 0);
+				dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
 			if (dst &&
-			    icsk->rx_dst_ifindex == inet6_iif(skb))
+			    icsk->rx_dst_ifindex == skb->skb_iif)
 				skb_dst_set_noref(skb, dst);
 		}
 	}
@@ -1719,10 +1729,23 @@ static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_destructor= tcp_twsk_destructor,
 };
 
+static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	const struct rt6_info *rt = (const struct rt6_info *)dst;
+
+	dst_hold(dst);
+	sk->sk_rx_dst = dst;
+	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	if (rt->rt6i_node)
+		inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
+}
+
 static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = tcp_v6_send_check,
 	.rebuild_header	   = inet6_sk_rebuild_header,
+	.sk_rx_dst_set	   = inet6_sk_rx_dst_set,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
 	.net_header_len	   = sizeof(struct ipv6hdr),
