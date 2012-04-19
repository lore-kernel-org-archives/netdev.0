From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: move duplicate code from tcp_v4_init_sock()/tcp_v6_init_sock()
Date: Thu, 19 Apr 2012 15:55:21 -0400
Message-ID: <1334865321-20288-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	maze@google.com, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:47971 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932360Ab2DSURl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:17:41 -0400
Received: by wgbdt11 with SMTP id dt11so479414wgb.1
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 13:17:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit moves the (substantial) common code shared between
tcp_v4_init_sock() and tcp_v6_init_sock() to a new address-family
independent function, tcp_init_sock().

Centralizing this functionality should help avoid drift issues,
e.g. where the IPv4 side is updated without a corresponding update to
IPv6. There was already some drift: IPv4 initialized snd_cwnd to
TCP_INIT_CWND, while the IPv6 side was still initializing snd_cwnd to
2 (in this case it should not matter, since snd_cwnd is also
initialized in tcp_init_metrics(), but the general risks and
maintenance overhead remain).

When diffing the old and new code, note that new tcp_init_sock()
function uses the order of steps from the tcp_v4_init_sock()
implementation (the order is slightly different in
tcp_v6_init_sock()).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h   |    1 +
 net/ipv4/tcp.c      |   64 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c |   52 +---------------------------------------
 net/ipv6/tcp_ipv6.c |   50 +---------------------------------------
 4 files changed, 68 insertions(+), 99 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d5984e3..eff4249 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -395,6 +395,7 @@ extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
 extern void tcp_close(struct sock *sk, long timeout);
+extern void tcp_init_sock(struct sock *sk);
 extern unsigned int tcp_poll(struct file * file, struct socket *sock,
 			     struct poll_table_struct *wait);
 extern int tcp_getsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c53e8a8..f87bebf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -363,6 +363,70 @@ static int retrans_to_secs(u8 retrans, int timeout, int rto_max)
 	return period;
 }
 
+/* Address-family independent initialization for a tcp_sock.
+ *
+ * NOTE: A lot of things set to zero explicitly by call to
+ *       sk_alloc() so need not be done here.
+ */
+void tcp_init_sock(struct sock *sk)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	skb_queue_head_init(&tp->out_of_order_queue);
+	tcp_init_xmit_timers(sk);
+	tcp_prequeue_init(tp);
+
+	icsk->icsk_rto = TCP_TIMEOUT_INIT;
+	tp->mdev = TCP_TIMEOUT_INIT;
+
+	/* So many TCP implementations out there (incorrectly) count the
+	 * initial SYN frame in their delayed-ACK and congestion control
+	 * algorithms that we must have the following bandaid to talk
+	 * efficiently to them.  -DaveM
+	 */
+	tp->snd_cwnd = TCP_INIT_CWND;
+
+	/* See draft-stevens-tcpca-spec-01 for discussion of the
+	 * initialization of these values.
+	 */
+	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
+	tp->snd_cwnd_clamp = ~0;
+	tp->mss_cache = TCP_MSS_DEFAULT;
+
+	tp->reordering = sysctl_tcp_reordering;
+	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
+
+	sk->sk_state = TCP_CLOSE;
+
+	sk->sk_write_space = sk_stream_write_space;
+	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
+
+	icsk->icsk_sync_mss = tcp_sync_mss;
+
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data_payload. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
+	sk->sk_sndbuf = sysctl_tcp_wmem[1];
+	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
+
+	local_bh_disable();
+	sock_update_memcg(sk);
+	sk_sockets_allocated_inc(sk);
+	local_bh_enable();
+}
+EXPORT_SYMBOL(tcp_init_sock);
+
 /*
  *	Wait for a TCP event.
  *
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0cb86ce..abfbeec 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1877,62 +1877,14 @@ static int tcp_v4_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	skb_queue_head_init(&tp->out_of_order_queue);
-	tcp_init_xmit_timers(sk);
-	tcp_prequeue_init(tp);
-
-	icsk->icsk_rto = TCP_TIMEOUT_INIT;
-	tp->mdev = TCP_TIMEOUT_INIT;
-
-	/* So many TCP implementations out there (incorrectly) count the
-	 * initial SYN frame in their delayed-ACK and congestion control
-	 * algorithms that we must have the following bandaid to talk
-	 * efficiently to them.  -DaveM
-	 */
-	tp->snd_cwnd = TCP_INIT_CWND;
-
-	/* See draft-stevens-tcpca-spec-01 for discussion of the
-	 * initialization of these values.
-	 */
-	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
-	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache = TCP_MSS_DEFAULT;
-
-	tp->reordering = sysctl_tcp_reordering;
-	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
-
-	sk->sk_state = TCP_CLOSE;
-
-	sk->sk_write_space = sk_stream_write_space;
-	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
+	tcp_init_sock(sk);
 
 	icsk->icsk_af_ops = &ipv4_specific;
-	icsk->icsk_sync_mss = tcp_sync_mss;
+
 #ifdef CONFIG_TCP_MD5SIG
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
-	/* TCP Cookie Transactions */
-	if (sysctl_tcp_cookie_size > 0) {
-		/* Default, cookies without s_data_payload. */
-		tp->cookie_values =
-			kzalloc(sizeof(*tp->cookie_values),
-				sk->sk_allocation);
-		if (tp->cookie_values != NULL)
-			kref_init(&tp->cookie_values->kref);
-	}
-	/* Presumed zeroed, in order of appearance:
-	 *	cookie_in_always, cookie_out_never,
-	 *	s_data_constant, s_data_in, s_data_out
-	 */
-	sk->sk_sndbuf = sysctl_tcp_wmem[1];
-	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
-
-	local_bh_disable();
-	sock_update_memcg(sk);
-	sk_sockets_allocated_inc(sk);
-	local_bh_enable();
-
 	return 0;
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 86cfe60..a73dff0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1831,62 +1831,14 @@ static int tcp_v6_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	skb_queue_head_init(&tp->out_of_order_queue);
-	tcp_init_xmit_timers(sk);
-	tcp_prequeue_init(tp);
-
-	icsk->icsk_rto = TCP_TIMEOUT_INIT;
-	tp->mdev = TCP_TIMEOUT_INIT;
-
-	/* So many TCP implementations out there (incorrectly) count the
-	 * initial SYN frame in their delayed-ACK and congestion control
-	 * algorithms that we must have the following bandaid to talk
-	 * efficiently to them.  -DaveM
-	 */
-	tp->snd_cwnd = 2;
-
-	/* See draft-stevens-tcpca-spec-01 for discussion of the
-	 * initialization of these values.
-	 */
-	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
-	tp->snd_cwnd_clamp = ~0;
-	tp->mss_cache = TCP_MSS_DEFAULT;
-
-	tp->reordering = sysctl_tcp_reordering;
-
-	sk->sk_state = TCP_CLOSE;
+	tcp_init_sock(sk);
 
 	icsk->icsk_af_ops = &ipv6_specific;
-	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
-	icsk->icsk_sync_mss = tcp_sync_mss;
-	sk->sk_write_space = sk_stream_write_space;
-	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 #ifdef CONFIG_TCP_MD5SIG
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
-	/* TCP Cookie Transactions */
-	if (sysctl_tcp_cookie_size > 0) {
-		/* Default, cookies without s_data_payload. */
-		tp->cookie_values =
-			kzalloc(sizeof(*tp->cookie_values),
-				sk->sk_allocation);
-		if (tp->cookie_values != NULL)
-			kref_init(&tp->cookie_values->kref);
-	}
-	/* Presumed zeroed, in order of appearance:
-	 *	cookie_in_always, cookie_out_never,
-	 *	s_data_constant, s_data_in, s_data_out
-	 */
-	sk->sk_sndbuf = sysctl_tcp_wmem[1];
-	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
-
-	local_bh_disable();
-	sock_update_memcg(sk);
-	sk_sockets_allocated_inc(sk);
-	local_bh_enable();
-
 	return 0;
 }
 
-- 
1.7.7.3
