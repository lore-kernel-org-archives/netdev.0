From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 3/3] tcp: use PRR to reduce cwin in CWR state
Date: Sun,  2 Sep 2012 20:38:04 -0700
Message-ID: <1346643484-12947-3-git-send-email-ycheng@google.com>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
Cc: mattmathis@google.com, edumazet@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:46822 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab2ICDiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:38:22 -0400
Received: by eekd4 with SMTP id d4so244796eek.1
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 20:38:20 -0700 (PDT)
In-Reply-To: <1346643484-12947-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proportional rate reduction (PRR) algorithm to reduce cwnd in CWR state,
in addition to Recovery state. Retire the current rate-halving in CWR.
When losses are detected via ACKs in CWR state, the sender enters Recovery
state but the cwnd reduction continues and does not restart.

Rename and refactor cwnd reduction functions since both CWR and Recovery
use the same algorithm:
tcp_init_cwnd_reduction() is new and initiates reduction state variables.
tcp_cwnd_reduction() is previously tcp_update_cwnd_in_recovery().
tcp_ends_cwnd_reduction() is previously  tcp_complete_cwr().

The rate halving functions and logic such as tcp_cwnd_down(), tcp_min_cwnd(),
and the cwnd moderation inside tcp_enter_cwr() are removed. The unused
parameter, flag, in tcp_cwnd_reduction() is also removed.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |   10 +++-
 net/ipv4/tcp_input.c  |  119 +++++++++++++++++--------------------------------
 net/ipv4/tcp_output.c |    6 +-
 3 files changed, 52 insertions(+), 83 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1421b02..a8cb00c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -913,15 +913,21 @@ static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
 	return tp->snd_ssthresh >= TCP_INFINITE_SSTHRESH;
 }
 
+static inline bool tcp_in_cwnd_reduction(const struct sock *sk)
+{
+	return (TCPF_CA_CWR | TCPF_CA_Recovery) &
+	       (1 << inet_csk(sk)->icsk_ca_state);
+}
+
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
- * The exception is rate halving phase, when cwnd is decreasing towards
+ * The exception is cwnd reduction phase, when cwnd is decreasing towards
  * ssthresh.
  */
 static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
-	if ((1 << inet_csk(sk)->icsk_ca_state) & (TCPF_CA_CWR | TCPF_CA_Recovery))
+	if (tcp_in_cwnd_reduction(sk))
 		return tp->snd_ssthresh;
 	else
 		return max(tp->snd_ssthresh,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 38589e4..e2bec81 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2470,35 +2470,6 @@ static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-/* Lower bound on congestion window is slow start threshold
- * unless congestion avoidance choice decides to overide it.
- */
-static inline u32 tcp_cwnd_min(const struct sock *sk)
-{
-	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
-
-	return ca_ops->min_cwnd ? ca_ops->min_cwnd(sk) : tcp_sk(sk)->snd_ssthresh;
-}
-
-/* Decrease cwnd each second ack. */
-static void tcp_cwnd_down(struct sock *sk, int flag)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	int decr = tp->snd_cwnd_cnt + 1;
-
-	if ((flag & (FLAG_ANY_PROGRESS | FLAG_DSACKING_ACK)) ||
-	    (tcp_is_reno(tp) && !(flag & FLAG_NOT_DUP))) {
-		tp->snd_cwnd_cnt = decr & 1;
-		decr >>= 1;
-
-		if (decr && tp->snd_cwnd > tcp_cwnd_min(sk))
-			tp->snd_cwnd -= decr;
-
-		tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp) + 1);
-		tp->snd_cwnd_stamp = tcp_time_stamp;
-	}
-}
-
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
@@ -2700,9 +2671,8 @@ static bool tcp_try_undo_loss(struct sock *sk)
 	return false;
 }
 
-/* This function implements the PRR algorithm, specifcally the PRR-SSRB
- * (proportional rate reduction with slow start reduction bound) as described in
- * http://www.ietf.org/id/draft-mathis-tcpm-proportional-rate-reduction-01.txt.
+/* The cwnd reduction in CWR and Recovery use the PRR algorithm
+ * https://datatracker.ietf.org/doc/draft-ietf-tcpm-proportional-rate-reduction/
  * It computes the number of packets to send (sndcnt) based on packets newly
  * delivered:
  *   1) If the packets in flight is larger than ssthresh, PRR spreads the
@@ -2711,13 +2681,29 @@ static bool tcp_try_undo_loss(struct sock *sk)
  *	losses and/or application stalls), do not perform any further cwnd
  *	reductions, but instead slow start up to ssthresh.
  */
-static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
-					int fast_rexmit, int flag)
+static void tcp_init_cwnd_reduction(struct sock *sk, const bool set_ssthresh)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tp->high_seq = tp->snd_nxt;
+	tp->bytes_acked = 0;
+	tp->snd_cwnd_cnt = 0;
+	tp->prior_cwnd = tp->snd_cwnd;
+	tp->prr_delivered = 0;
+	tp->prr_out = 0;
+	if (set_ssthresh)
+		tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
+	TCP_ECN_queue_cwr(tp);
+}
+
+static void tcp_cwnd_reduction(struct sock *sk, int newly_acked_sacked,
+			       int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int sndcnt = 0;
 	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
 
+	tp->prr_delivered += newly_acked_sacked;
 	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
 		u64 dividend = (u64)tp->snd_ssthresh * tp->prr_delivered +
 			       tp->prior_cwnd - 1;
@@ -2732,43 +2718,29 @@ static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + sndcnt;
 }
 
-static inline void tcp_complete_cwr(struct sock *sk)
+static inline void tcp_end_cwnd_reduction(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	/* Do not moderate cwnd if it's already undone in cwr or recovery. */
-	if (tp->undo_marker) {
-		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR) {
-			tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
-			tp->snd_cwnd_stamp = tcp_time_stamp;
-		} else if (tp->snd_ssthresh < TCP_INFINITE_SSTHRESH) {
-			/* PRR algorithm. */
-			tp->snd_cwnd = tp->snd_ssthresh;
-			tp->snd_cwnd_stamp = tcp_time_stamp;
-		}
+	/* Reset cwnd to ssthresh in CWR or Recovery (unless it's undone) */
+	if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR ||
+	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
+		tp->snd_cwnd = tp->snd_ssthresh;
+		tp->snd_cwnd_stamp = tcp_time_stamp;
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
 
-/* Set slow start threshold and cwnd not falling to slow start */
+/* Enter CWR state. Disable cwnd undo since congestion is proven with ECN */
 void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	tp->prior_ssthresh = 0;
 	tp->bytes_acked = 0;
-	if (icsk->icsk_ca_state < TCP_CA_CWR) {
+	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		tp->undo_marker = 0;
-		if (set_ssthresh)
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-		tp->snd_cwnd = min(tp->snd_cwnd,
-				   tcp_packets_in_flight(tp) + 1U);
-		tp->snd_cwnd_cnt = 0;
-		tp->high_seq = tp->snd_nxt;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
-		TCP_ECN_queue_cwr(tp);
-
+		tcp_init_cwnd_reduction(sk, set_ssthresh);
 		tcp_set_ca_state(sk, TCP_CA_CWR);
 	}
 }
@@ -2787,7 +2759,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	}
 }
 
-static void tcp_try_to_open(struct sock *sk, int flag)
+static void tcp_try_to_open(struct sock *sk, int flag, int newly_acked_sacked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2804,7 +2776,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
 			tcp_moderate_cwnd(tp);
 	} else {
-		tcp_cwnd_down(sk, flag);
+		tcp_cwnd_reduction(sk, newly_acked_sacked, 0);
 	}
 }
 
@@ -2898,7 +2870,6 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 
 	NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
-	tp->high_seq = tp->snd_nxt;
 	tp->prior_ssthresh = 0;
 	tp->undo_marker = tp->snd_una;
 	tp->undo_retrans = tp->retrans_out;
@@ -2906,15 +2877,8 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		if (!ece_ack)
 			tp->prior_ssthresh = tcp_current_ssthresh(sk);
-		tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
-		TCP_ECN_queue_cwr(tp);
+		tcp_init_cwnd_reduction(sk, true);
 	}
-
-	tp->bytes_acked = 0;
-	tp->snd_cwnd_cnt = 0;
-	tp->prior_cwnd = tp->snd_cwnd;
-	tp->prr_delivered = 0;
-	tp->prr_out = 0;
 	tcp_set_ca_state(sk, TCP_CA_Recovery);
 }
 
@@ -2974,7 +2938,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			/* CWR is to be held something *above* high_seq
 			 * is ACKed for CWR bit to reach receiver. */
 			if (tp->snd_una != tp->high_seq) {
-				tcp_complete_cwr(sk);
+				tcp_end_cwnd_reduction(sk);
 				tcp_set_ca_state(sk, TCP_CA_Open);
 			}
 			break;
@@ -2984,7 +2948,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 				tcp_reset_reno_sack(tp);
 			if (tcp_try_undo_recovery(sk))
 				return;
-			tcp_complete_cwr(sk);
+			tcp_end_cwnd_reduction(sk);
 			break;
 		}
 	}
@@ -3025,7 +2989,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			tcp_try_undo_dsack(sk);
 
 		if (!tcp_time_to_recover(sk, flag)) {
-			tcp_try_to_open(sk, flag);
+			tcp_try_to_open(sk, flag, newly_acked_sacked);
 			return;
 		}
 
@@ -3047,8 +3011,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 
 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
-	tp->prr_delivered += newly_acked_sacked;
-	tcp_update_cwnd_in_recovery(sk, newly_acked_sacked, fast_rexmit, flag);
+	tcp_cwnd_reduction(sk, newly_acked_sacked, fast_rexmit);
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -3394,7 +3357,7 @@ static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return (!(flag & FLAG_ECE) || tp->snd_cwnd < tp->snd_ssthresh) &&
-		!((1 << inet_csk(sk)->icsk_ca_state) & (TCPF_CA_Recovery | TCPF_CA_CWR));
+		!tcp_in_cwnd_reduction(sk);
 }
 
 /* Check that window update is acceptable.
@@ -3462,9 +3425,9 @@ static void tcp_conservative_spur_to_response(struct tcp_sock *tp)
 }
 
 /* A conservative spurious RTO response algorithm: reduce cwnd using
- * rate halving and continue in congestion avoidance.
+ * PRR and continue in congestion avoidance.
  */
-static void tcp_ratehalving_spur_to_response(struct sock *sk)
+static void tcp_cwr_spur_to_response(struct sock *sk)
 {
 	tcp_enter_cwr(sk, 0);
 }
@@ -3472,7 +3435,7 @@ static void tcp_ratehalving_spur_to_response(struct sock *sk)
 static void tcp_undo_spur_to_response(struct sock *sk, int flag)
 {
 	if (flag & FLAG_ECE)
-		tcp_ratehalving_spur_to_response(sk);
+		tcp_cwr_spur_to_response(sk);
 	else
 		tcp_undo_cwr(sk, true);
 }
@@ -3579,7 +3542,7 @@ static bool tcp_process_frto(struct sock *sk, int flag)
 			tcp_conservative_spur_to_response(tp);
 			break;
 		default:
-			tcp_ratehalving_spur_to_response(sk);
+			tcp_cwr_spur_to_response(sk);
 			break;
 		}
 		tp->frto_counter = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9383b51..cfe6ffe 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2037,10 +2037,10 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		if (push_one)
 			break;
 	}
-	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Recovery)
-		tp->prr_out += sent_pkts;
 
 	if (likely(sent_pkts)) {
+		if (tcp_in_cwnd_reduction(sk))
+			tp->prr_out += sent_pkts;
 		tcp_cwnd_validate(sk);
 		return false;
 	}
@@ -2542,7 +2542,7 @@ begin_fwd:
 		}
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
-		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Recovery)
+		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += tcp_skb_pcount(skb);
 
 		if (skb == tcp_write_queue_head(sk))
-- 
1.7.7.3
