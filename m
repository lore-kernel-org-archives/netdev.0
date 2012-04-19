From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/6] tcp: Move code around
Date: Thu, 19 Apr 2012 17:40:01 +0400
Message-ID: <4F9015B1.8030005@parallels.com>
References: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44212 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100Ab2DSNkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:40:08 -0400
In-Reply-To: <4F901572.4040009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just the preparation patch, which makes the needed for
TCP repair code ready for use.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/net/tcp.h     |    3 ++
 net/ipv4/tcp.c        |    2 +-
 net/ipv4/tcp_input.c  |   81 +++++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_output.c |    4 +-
 4 files changed, 54 insertions(+), 36 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d5984e3..633fde2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -435,6 +435,9 @@ extern struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 					struct request_values *rvp);
 extern int tcp_disconnect(struct sock *sk, int flags);
 
+void tcp_connect_init(struct sock *sk);
+void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
+void tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c53e8a8..bb4200f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -919,7 +919,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int iovlen, flags, err, copied;
-	int mss_now, size_goal;
+	int mss_now = 0, size_goal;
 	bool sg;
 	long timeo;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99448f0..37e1c5c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5325,6 +5325,14 @@ discard:
 	return 0;
 }
 
+void tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen)
+{
+	__skb_pull(skb, hdrlen);
+	__skb_queue_tail(&sk->sk_receive_queue, skb);
+	skb_set_owner_r(skb, sk);
+	tcp_sk(sk)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+}
+
 /*
  *	TCP receive function for the ESTABLISHED state.
  *
@@ -5490,10 +5498,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
 
 				/* Bulk data transfer: receiver */
-				__skb_pull(skb, tcp_header_len);
-				__skb_queue_tail(&sk->sk_receive_queue, skb);
-				skb_set_owner_r(skb, sk);
-				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+				tcp_queue_rcv(sk, skb, tcp_header_len);
 			}
 
 			tcp_event_data_recv(sk, skb);
@@ -5559,6 +5564,44 @@ discard:
 }
 EXPORT_SYMBOL(tcp_rcv_established);
 
+void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	tcp_set_state(sk, TCP_ESTABLISHED);
+
+	if (skb != NULL)
+		security_inet_conn_established(sk, skb);
+
+	/* Make sure socket is routed, for correct metrics.  */
+	icsk->icsk_af_ops->rebuild_header(sk);
+
+	tcp_init_metrics(sk);
+
+	tcp_init_congestion_control(sk);
+
+	/* Prevent spurious tcp_cwnd_restart() on first data
+	 * packet.
+	 */
+	tp->lsndtime = tcp_time_stamp;
+
+	tcp_init_buffer_space(sk);
+
+	if (sock_flag(sk, SOCK_KEEPOPEN))
+		inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
+
+	if (!tp->rx_opt.snd_wscale)
+		__tcp_fast_path_on(tp, tp->snd_wnd);
+	else
+		tp->pred_flags = 0;
+
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		sk->sk_state_change(sk);
+		sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
+	}
+}
+
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 const struct tcphdr *th, unsigned int len)
 {
@@ -5691,36 +5734,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		}
 
 		smp_mb();
-		tcp_set_state(sk, TCP_ESTABLISHED);
-
-		security_inet_conn_established(sk, skb);
-
-		/* Make sure socket is routed, for correct metrics.  */
-		icsk->icsk_af_ops->rebuild_header(sk);
-
-		tcp_init_metrics(sk);
 
-		tcp_init_congestion_control(sk);
-
-		/* Prevent spurious tcp_cwnd_restart() on first data
-		 * packet.
-		 */
-		tp->lsndtime = tcp_time_stamp;
-
-		tcp_init_buffer_space(sk);
-
-		if (sock_flag(sk, SOCK_KEEPOPEN))
-			inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
-
-		if (!tp->rx_opt.snd_wscale)
-			__tcp_fast_path_on(tp, tp->snd_wnd);
-		else
-			tp->pred_flags = 0;
-
-		if (!sock_flag(sk, SOCK_DEAD)) {
-			sk->sk_state_change(sk);
-			sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
-		}
+		tcp_finish_connect(sk, skb);
 
 		if (sk->sk_write_pending ||
 		    icsk->icsk_accept_queue.rskq_defer_accept ||
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de8790c..db126a6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2561,7 +2561,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 EXPORT_SYMBOL(tcp_make_synack);
 
 /* Do all connect socket setups that can be done AF independent. */
-static void tcp_connect_init(struct sock *sk)
+void tcp_connect_init(struct sock *sk)
 {
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2616,6 +2616,7 @@ static void tcp_connect_init(struct sock *sk)
 	tp->snd_una = tp->write_seq;
 	tp->snd_sml = tp->write_seq;
 	tp->snd_up = tp->write_seq;
+	tp->snd_nxt = tp->write_seq;
 	tp->rcv_nxt = 0;
 	tp->rcv_wup = 0;
 	tp->copied_seq = 0;
@@ -2641,7 +2642,6 @@ int tcp_connect(struct sock *sk)
 	/* Reserve space for headers. */
 	skb_reserve(buff, MAX_TCP_HEADER);
 
-	tp->snd_nxt = tp->write_seq;
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
 	TCP_ECN_send_syn(sk, buff);
 
-- 
1.5.5.6
