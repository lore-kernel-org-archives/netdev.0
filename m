From: Nandita Dukkipati <nanditad@google.com>
Subject: [PATCH v2] tcp: bug fix in proportional rate reduction.
Date: Tue, 21 May 2013 18:12:07 -0700
Message-ID: <1369185127-27255-1-git-send-email-nanditad@google.com>
References: <1369095724-17745-1-git-send-email-nanditad@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:62849 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab3EVBMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 21:12:14 -0400
Received: by mail-qa0-f74.google.com with SMTP id bs12so158260qab.1
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 18:12:13 -0700 (PDT)
In-Reply-To: <1369095724-17745-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a fix for a bug triggering newly_acked_sacked < 0
in tcp_ack(.).

The bug is triggered by sacked_out decreasing relative to prior_sacked,
but packets_out remaining the same as pior_packets. This is because the
snapshot of prior_packets is taken after tcp_sacktag_write_queue() while
prior_sacked is captured before tcp_sacktag_write_queue(). The problem
is: tcp_sacktag_write_queue (tcp_match_skb_to_sack() -> tcp_fragment)
adjusts the pcount for packets_out and sacked_out (MSS change or other
reason). As a result, this delta in pcount is reflected in
(prior_sacked - sacked_out) but not in (prior_packets - packets_out).

This patch does the following:
1) initializes prior_packets at the start of tcp_ack() so as to
capture the delta in packets_out created by tcp_fragment.
2) introduces a new "previous_packets_out" variable that snapshots
packets_out right before tcp_clean_rtx_queue, so pkts_acked can be
correctly computed as before.
3) Computes pkts_acked using previous_packets_out, and computes
newly_acked_sacked using prior_packets.

Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
Changelog since v1:
- Compute newly_acked_sacked using prior_packets.

 net/ipv4/tcp_input.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d7d3694..8230cd6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2679,8 +2679,8 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
  * tcp_xmit_retransmit_queue().
  */
 static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
-				  int prior_sacked, bool is_dupack,
-				  int flag)
+				  int prior_sacked, int prior_packets,
+				  bool is_dupack, int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2740,7 +2740,8 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 				tcp_add_reno_sack(sk);
 		} else
 			do_lost = tcp_try_undo_partial(sk, pkts_acked);
-		newly_acked_sacked = pkts_acked + tp->sacked_out - prior_sacked;
+		newly_acked_sacked = prior_packets - tp->packets_out +
+				     tp->sacked_out - prior_sacked;
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack);
@@ -2754,7 +2755,8 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			if (is_dupack)
 				tcp_add_reno_sack(sk);
 		}
-		newly_acked_sacked = pkts_acked + tp->sacked_out - prior_sacked;
+		newly_acked_sacked = prior_packets - tp->packets_out +
+				     tp->sacked_out - prior_sacked;
 
 		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
@@ -3265,9 +3267,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	bool is_dupack = false;
 	u32 prior_in_flight;
 	u32 prior_fackets;
-	int prior_packets;
+	int prior_packets = tp->packets_out;
 	int prior_sacked = tp->sacked_out;
 	int pkts_acked = 0;
+	int previous_packets_out = 0;
 
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
@@ -3338,14 +3341,14 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	sk->sk_err_soft = 0;
 	icsk->icsk_probes_out = 0;
 	tp->rcv_tstamp = tcp_time_stamp;
-	prior_packets = tp->packets_out;
 	if (!prior_packets)
 		goto no_queue;
 
 	/* See if we can take anything off of the retransmit queue. */
+	previous_packets_out = tp->packets_out;
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
 
-	pkts_acked = prior_packets - tp->packets_out;
+	pkts_acked = previous_packets_out - tp->packets_out;
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
@@ -3353,7 +3356,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      is_dupack, flag);
+				      prior_packets, is_dupack, flag);
 	} else {
 		if (flag & FLAG_DATA_ACKED)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
@@ -3376,7 +3379,7 @@ no_queue:
 	/* If data was DSACKed, see if we can undo a cwnd reduction. */
 	if (flag & FLAG_DSACKING_ACK)
 		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      is_dupack, flag);
+				      prior_packets, is_dupack, flag);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
@@ -3399,7 +3402,7 @@ old_ack:
 	if (TCP_SKB_CB(skb)->sacked) {
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
 		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
-				      is_dupack, flag);
+				      prior_packets, is_dupack, flag);
 	}
 
 	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
1.8.2.1
