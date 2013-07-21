From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/4 net-next] tcp: prefer packet timing to TS-ECR for RTT
Date: Sat, 20 Jul 2013 22:39:28 -0700
Message-ID: <1374385170-358-2-git-send-email-ycheng@google.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
Cc: nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:52042 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3GUFjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 01:39:51 -0400
Received: by mail-gg0-f202.google.com with SMTP id h3so513302gge.3
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 22:39:50 -0700 (PDT)
In-Reply-To: <1374385170-358-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefer packet timings to TS-ecr for RTT measurements when both
sources are available. That's because broken middle-boxes and remote
peer can return packets with corrupted TS ECR fields. Similarly most
congestion controls that require RTT signals favor timing-based
sources as well. Also check for bad TS ECR values to avoid RTT
blow-ups. It has happened on production Web servers.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h    |  1 -
 net/ipv4/tcp_input.c | 67 ++++++++++++++--------------------------------------
 2 files changed, 18 insertions(+), 50 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f9777db..c586847 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -591,7 +591,6 @@ extern void tcp_initialize_rcv_mss(struct sock *sk);
 extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
 extern int tcp_mss_to_mtu(struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
-extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);
 extern void tcp_init_buffer_space(struct sock *sk);
 
 static inline void tcp_bound_rto(const struct sock *sk)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 988e816..b6357ec 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2792,65 +2792,36 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	tcp_xmit_retransmit_queue(sk);
 }
 
-void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
+static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
+				      s32 seq_rtt)
 {
-	tcp_rtt_estimator(sk, seq_rtt);
-	tcp_set_rto(sk);
-	inet_csk(sk)->icsk_backoff = 0;
-}
-EXPORT_SYMBOL(tcp_valid_rtt_meas);
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	/* Prefer RTT measured from ACK's timing to TS-ECR. This is because
+	 * broken middle-boxes or peers may corrupt TS-ECR fields. But
+	 * Karn's algorithm forbids taking RTT if some retransmitted data
+	 * is acked (RFC6298).
+	 */
+	if (flag & FLAG_RETRANS_DATA_ACKED)
+		seq_rtt = -1;
 
-/* Read draft-ietf-tcplw-high-performance before mucking
- * with this code. (Supersedes RFC1323)
- */
-static void tcp_ack_saw_tstamp(struct sock *sk, int flag)
-{
 	/* RTTM Rule: A TSecr value received in a segment is used to
 	 * update the averaged RTT measurement only if the segment
 	 * acknowledges some new data, i.e., only if it advances the
 	 * left edge of the send window.
-	 *
 	 * See draft-ietf-tcplw-high-performance-00, section 3.3.
-	 * 1998/04/10 Andrey V. Savochkin <saw@msu.ru>
-	 *
-	 * Changed: reset backoff as soon as we see the first valid sample.
-	 * If we do not, we get strongly overestimated rto. With timestamps
-	 * samples are accepted even from very old segments: f.e., when rtt=1
-	 * increases to 8, we retransmit 5 times and after 8 seconds delayed
-	 * answer arrives rto becomes 120 seconds! If at least one of segments
-	 * in window is lost... Voila.	 			--ANK (010210)
 	 */
-	struct tcp_sock *tp = tcp_sk(sk);
+	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
+		seq_rtt = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
 
-	tcp_valid_rtt_meas(sk, tcp_time_stamp - tp->rx_opt.rcv_tsecr);
-}
-
-static void tcp_ack_no_tstamp(struct sock *sk, u32 seq_rtt, int flag)
-{
-	/* We don't have a timestamp. Can only use
-	 * packets that are not retransmitted to determine
-	 * rtt estimates. Also, we must not reset the
-	 * backoff for rto until we get a non-retransmitted
-	 * packet. This allows us to deal with a situation
-	 * where the network delay has increased suddenly.
-	 * I.e. Karn's algorithm. (SIGCOMM '87, p5.)
-	 */
-
-	if (flag & FLAG_RETRANS_DATA_ACKED)
+	if (seq_rtt < 0)
 		return;
 
-	tcp_valid_rtt_meas(sk, seq_rtt);
-}
+	tcp_rtt_estimator(sk, seq_rtt);
+	tcp_set_rto(sk);
 
-static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
-				      const s32 seq_rtt)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	/* Note that peer MAY send zero echo. In this case it is ignored. (rfc1323) */
-	if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
-		tcp_ack_saw_tstamp(sk, flag);
-	else if (seq_rtt >= 0)
-		tcp_ack_no_tstamp(sk, seq_rtt, flag);
+	/* RFC6298: only reset backoff on valid RTT measurement. */
+	inet_csk(sk)->icsk_backoff = 0;
 }
 
 /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
@@ -2989,8 +2960,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -= acked_pcount;
 			flag |= FLAG_RETRANS_DATA_ACKED;
-			ca_seq_rtt = -1;
-			seq_rtt = -1;
 		} else {
 			ca_seq_rtt = now - scb->when;
 			last_ackt = skb->tstamp;
-- 
1.8.3
