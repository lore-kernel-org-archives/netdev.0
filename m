From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 4/4 net-next] tcp: use RTT from SACK for RTO
Date: Sat, 20 Jul 2013 22:39:30 -0700
Message-ID: <1374385170-358-4-git-send-email-ycheng@google.com>
References: <1374385170-358-1-git-send-email-ycheng@google.com>
Cc: nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:64714 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab3GUFjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 01:39:51 -0400
Received: by mail-yh0-f74.google.com with SMTP id f73so155973yha.3
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 22:39:50 -0700 (PDT)
In-Reply-To: <1374385170-358-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If RTT is not available because Karn's check has failed or no
new packet is acked, use the RTT measured from SACK to estimate
the RTO. The sender can continue to estimate the RTO during loss
recovery or reordering event upon receiving non-partial ACKs.

This also changes when the RTO is re-armed. Previously it is
only re-armed when some data is cummulatively acknowledged (i.e.,
SND.UNA advances), but now it is re-armed whenever RTT estimator
is updated. This feature is particularly useful to reduce spurious
timeout for buffer bloat including cellular carriers [1], and
RTT estimation on reordering events.

[1] "An In-depth Study of LTE: Effect of Network Protocol and
 Application Behavior on Performance", In Proc. of SIGCOMM 2013

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 46aeef1..8d2f712 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2798,8 +2798,8 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	tcp_xmit_retransmit_queue(sk);
 }
 
-static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
-				      s32 seq_rtt)
+static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
+				      s32 seq_rtt, s32 sack_rtt)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2811,6 +2811,9 @@ static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
 	if (flag & FLAG_RETRANS_DATA_ACKED)
 		seq_rtt = -1;
 
+	if (seq_rtt < 0)
+		seq_rtt = sack_rtt;
+
 	/* RTTM Rule: A TSecr value received in a segment is used to
 	 * update the averaged RTT measurement only if the segment
 	 * acknowledges some new data, i.e., only if it advances the
@@ -2821,13 +2824,14 @@ static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
 		seq_rtt = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
 
 	if (seq_rtt < 0)
-		return;
+		return false;
 
 	tcp_rtt_estimator(sk, seq_rtt);
 	tcp_set_rto(sk);
 
 	/* RFC6298: only reset backoff on valid RTT measurement. */
 	inet_csk(sk)->icsk_backoff = 0;
+	return true;
 }
 
 /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
@@ -2838,7 +2842,7 @@ static void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
 
 	if (tp->lsndtime && !tp->total_retrans)
 		seq_rtt = tcp_time_stamp - tp->lsndtime;
-	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt);
+	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt, -1);
 }
 
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
@@ -2927,7 +2931,7 @@ static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
  * arrived at the other end.
  */
 static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
-			       u32 prior_snd_una)
+			       u32 prior_snd_una, s32 sack_rtt)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -3017,6 +3021,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
+	if (tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt) ||
+	    (flag & FLAG_ACKED))
+		tcp_rearm_rto(sk);
+
 	if (flag & FLAG_ACKED) {
 		const struct tcp_congestion_ops *ca_ops
 			= inet_csk(sk)->icsk_ca_ops;
@@ -3026,9 +3034,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			tcp_mtup_probe_success(sk);
 		}
 
-		tcp_ack_update_rtt(sk, flag, seq_rtt);
-		tcp_rearm_rto(sk);
-
 		if (tcp_is_reno(tp)) {
 			tcp_remove_reno_sacks(sk, pkts_acked);
 		} else {
@@ -3337,7 +3342,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	/* See if we can take anything off of the retransmit queue. */
 	acked = tp->packets_out;
-	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
+	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, sack_rtt);
 	acked -= tp->packets_out;
 
 	if (tcp_ack_is_dubious(sk, flag)) {
-- 
1.8.3
