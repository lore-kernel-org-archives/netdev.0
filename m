From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/4 net-next] tcp: consolidate PRR packet accounting
Date: Wed, 29 May 2013 17:20:11 -0700
Message-ID: <1369873214-29502-1-git-send-email-ycheng@google.com>
Cc: aterzis@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:46085 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967257Ab3E3AUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:20:36 -0400
Received: by mail-qe0-f74.google.com with SMTP id 1so1012059qec.3
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:20:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fix an undo bug in fast recovery: the sender
mistakenly undos the cwnd too early but continue fast retransmits
until all pending data are acked. This also multiplicates the SNMP
stat PARTIALUNDO events by the degree of the network reordering.

The first patch prepares the fix by consolidating the accounting
of newly_acked_sacked in tcp_cwnd_reduction(), instead of updating
newly_acked_sacked everytime sacked_out is adjusted.  Also pass
acked and prior_unsacked as const type because they are readonly
in the rest of recovery processing.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 45 ++++++++++++++++++++-------------------------
 1 file changed, 20 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9579e1a..86b5fa7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2430,12 +2430,14 @@ static void tcp_init_cwnd_reduction(struct sock *sk, const bool set_ssthresh)
 	TCP_ECN_queue_cwr(tp);
 }
 
-static void tcp_cwnd_reduction(struct sock *sk, int newly_acked_sacked,
+static void tcp_cwnd_reduction(struct sock *sk, const int prior_unsacked,
 			       int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int sndcnt = 0;
 	int delta = tp->snd_ssthresh - tcp_packets_in_flight(tp);
+	int newly_acked_sacked = prior_unsacked -
+				 (tp->packets_out - tp->sacked_out);
 
 	tp->prr_delivered += newly_acked_sacked;
 	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
@@ -2492,7 +2494,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	}
 }
 
-static void tcp_try_to_open(struct sock *sk, int flag, int newly_acked_sacked)
+static void tcp_try_to_open(struct sock *sk, int flag, const int prior_unsacked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2509,7 +2511,7 @@ static void tcp_try_to_open(struct sock *sk, int flag, int newly_acked_sacked)
 		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
 			tcp_moderate_cwnd(tp);
 	} else {
-		tcp_cwnd_reduction(sk, newly_acked_sacked, 0);
+		tcp_cwnd_reduction(sk, prior_unsacked, 0);
 	}
 }
 
@@ -2678,15 +2680,14 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
  * It does _not_ decide what to send, it is made in function
  * tcp_xmit_retransmit_queue().
  */
-static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
-				  int prior_sacked, int prior_packets,
+static void tcp_fastretrans_alert(struct sock *sk, const int acked,
+				  const int prior_unsacked,
 				  bool is_dupack, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
-	int newly_acked_sacked = 0;
 	int fast_rexmit = 0;
 
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
@@ -2739,9 +2740,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			if (tcp_is_reno(tp) && is_dupack)
 				tcp_add_reno_sack(sk);
 		} else
-			do_lost = tcp_try_undo_partial(sk, pkts_acked);
-		newly_acked_sacked = prior_packets - tp->packets_out +
-				     tp->sacked_out - prior_sacked;
+			do_lost = tcp_try_undo_partial(sk, acked);
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack);
@@ -2755,14 +2754,12 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			if (is_dupack)
 				tcp_add_reno_sack(sk);
 		}
-		newly_acked_sacked = prior_packets - tp->packets_out +
-				     tp->sacked_out - prior_sacked;
 
 		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
 
 		if (!tcp_time_to_recover(sk, flag)) {
-			tcp_try_to_open(sk, flag, newly_acked_sacked);
+			tcp_try_to_open(sk, flag, prior_unsacked);
 			return;
 		}
 
@@ -2784,7 +2781,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 
 	if (do_lost)
 		tcp_update_scoreboard(sk, fast_rexmit);
-	tcp_cwnd_reduction(sk, newly_acked_sacked, fast_rexmit);
+	tcp_cwnd_reduction(sk, prior_unsacked, fast_rexmit);
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -3268,9 +3265,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets = tp->packets_out;
-	int prior_sacked = tp->sacked_out;
-	int pkts_acked = 0;
-	int previous_packets_out = 0;
+	const int prior_unsacked = tp->packets_out - tp->sacked_out;
+	int acked = 0; /* Number of packets newly acked */
 
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
@@ -3345,18 +3341,17 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		goto no_queue;
 
 	/* See if we can take anything off of the retransmit queue. */
-	previous_packets_out = tp->packets_out;
+	acked = tp->packets_out;
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
-
-	pkts_acked = previous_packets_out - tp->packets_out;
+	acked -= tp->packets_out;
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
 		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
-		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      prior_packets, is_dupack, flag);
+		tcp_fastretrans_alert(sk, acked, prior_unsacked,
+				      is_dupack, flag);
 	} else {
 		if (flag & FLAG_DATA_ACKED)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
@@ -3378,8 +3373,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 no_queue:
 	/* If data was DSACKed, see if we can undo a cwnd reduction. */
 	if (flag & FLAG_DSACKING_ACK)
-		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      prior_packets, is_dupack, flag);
+		tcp_fastretrans_alert(sk, acked, prior_unsacked,
+				      is_dupack, flag);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
@@ -3401,8 +3396,8 @@ old_ack:
 	 */
 	if (TCP_SKB_CB(skb)->sacked) {
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
-		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      prior_packets, is_dupack, flag);
+		tcp_fastretrans_alert(sk, acked, prior_unsacked,
+				      is_dupack, flag);
 	}
 
 	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
1.8.2.1
