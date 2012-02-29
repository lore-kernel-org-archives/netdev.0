From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] tcp: Move code around
Date: Wed, 29 Feb 2012 19:13:40 +0400
Message-ID: <4F4E40A4.2010305@parallels.com>
References: <4F4E4084.9080804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17195 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031093Ab2B2PNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 10:13:51 -0500
In-Reply-To: <4F4E4084.9080804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just the preparation patch, which makes the needed for
TCP repair code ready for use.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/net/tcp.h     |    4 +++
 net/ipv4/tcp_input.c  |   68 ++++++++++++++++++++++++++++---------------------
 net/ipv4/tcp_output.c |   10 ++++++-
 3 files changed, 51 insertions(+), 31 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6b2acfc..547a8fb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -434,6 +434,8 @@ extern struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 					struct request_values *rvp);
 extern int tcp_disconnect(struct sock *sk, int flags);
 
+void tcp_connect_init(struct sock *sk);
+void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
@@ -608,6 +610,8 @@ static inline u32 tcp_receive_window(const struct tcp_sock *tp)
  */
 extern u32 __tcp_select_window(struct sock *sk);
 
+void tcp_send_window_probe(struct sock *sk);
+
 /* TCP timestamps are only 32-bits, this causes a slight
  * complication on 64-bit systems since we store a snapshot
  * of jiffies in the buffer control blocks below.  We decided
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 53c8ce4..1122cce 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5514,6 +5514,44 @@ discard:
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
@@ -5646,36 +5684,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
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
-
-		tcp_init_congestion_control(sk);
 
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
index 364784a..e90d62d 100644
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
@@ -2619,6 +2619,7 @@ static void tcp_connect_init(struct sock *sk)
 	tp->rcv_nxt = 0;
 	tp->rcv_wup = 0;
 	tp->copied_seq = 0;
+	tp->snd_nxt = tp->write_seq;
 
 	inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
 	inet_csk(sk)->icsk_retransmits = 0;
@@ -2641,7 +2642,6 @@ int tcp_connect(struct sock *sk)
 	/* Reserve space for headers. */
 	skb_reserve(buff, MAX_TCP_HEADER);
 
-	tp->snd_nxt = tp->write_seq;
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
 	TCP_ECN_send_syn(sk, buff);
 
@@ -2790,6 +2790,11 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
+void tcp_send_window_probe(struct sock *sk)
+{
+	tcp_xmit_probe_skb(sk, 0);
+}
+
 /* Initiate keepalive or window probe from timer. */
 int tcp_write_wakeup(struct sock *sk)
 {
-- 
1.5.5.6
