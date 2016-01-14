From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 3/6] tcp: new delivery accounting
Date: Thu, 14 Jan 2016 15:43:31 -0800
Message-ID: <1452815014-601-4-git-send-email-ycheng@google.com>
References: <1452815014-601-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33758 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755855AbcANXoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:44:18 -0500
Received: by mail-pf0-f180.google.com with SMTP id e65so107790408pfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 15:44:18 -0800 (PST)
In-Reply-To: <1452815014-601-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the accounting of how many packets are
newly acked or sacked when the sender receives an ACK.

The current approach basically computes

   newly_acked_sacked = (prior_packets - prior_sacked) -
                        (tp->packets_out - tp->sacked_out)

   where prior_packets and prior_sacked out are snapshot
   at the beginning of the ACK processing.

The new approach tracks the delivery information via a new
TCP state variable "delivered" which monotically increases
as new packets are delivered in order or out-of-order.

The reason for this change is that the current approach is
brittle that produces negative or inaccurate estimate.

   1) For non-SACK connections, an ACK that advances the SND.UNA
   could reset the DUPACK counters (tp->sacked_out) in
   tcp_process_loss() or tcp_fastretrans_alert(). This inflates
   the inflight suddenly and causes under-estimate or even
   negative estimate. Here is a real example:

                   before   after (processing ACK)
   packets_out     75       73
   sacked_out      23        0
   ca state        Loss     Open

   The old approach computes (75-23) - (73 - 0) = -21 delivered
   while the new approach computes 1 delivered since it
   considers the 2nd-24th packets are delivered OOO.

   2) MSS change would re-count packets_out and sacked_out so
   the estimate is in-accurate and can even become negative.
   E.g., the inflight is doubled when MSS is halved.

   3) Spurious retransmission signaled by DSACK is not accounted

The new approach is simpler and more robust. For SACK connections,
tp->delivered increments as packets are being acked or sacked in
SACK and ACK processing.

For non-sack connections, it's done in tcp_remove_reno_sacks() and
tcp_add_reno_sack(). When an ACK advances the SND.UNA, tp->delivered
is incremented by the number of packets ACKed (less the current
number of DUPACKs received plus one packet hole).  Upon receiving
a DUPACK, tp->delivered is incremented assuming one out-of-order
packet is delivered.

Upon receiving a DSACK, tp->delivered is incremtened assuming one
retransmission is delivered in tcp_sacktag_write_queue().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h  |  1 +
 net/ipv4/tcp_input.c | 21 +++++++++++++++------
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b386361..d909fee 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -256,6 +256,7 @@ struct tcp_sock {
 	u32	prr_delivered;	/* Number of newly delivered packets to
 				 * receiver in Recovery. */
 	u32	prr_out;	/* Total number of pkts sent during Recovery. */
+	u32	delivered;	/* Total data packets delivered incl. rexmits */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f2ebe8b..e7a8ce7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1214,6 +1214,7 @@ static u8 tcp_sacktag_one(struct sock *sk,
 		sacked |= TCPCB_SACKED_ACKED;
 		state->flag |= FLAG_DATA_SACKED;
 		tp->sacked_out += pcount;
+		tp->delivered += pcount;  /* Out-of-order packets delivered */
 
 		fack_count += pcount;
 
@@ -1825,8 +1826,12 @@ static void tcp_check_reno_reordering(struct sock *sk, const int addend)
 static void tcp_add_reno_sack(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	u32 prior_sacked = tp->sacked_out;
+
 	tp->sacked_out++;
 	tcp_check_reno_reordering(sk, 0);
+	if (tp->sacked_out > prior_sacked)
+		tp->delivered++; /* Some out-of-order packet is delivered */
 	tcp_verify_left_out(tp);
 }
 
@@ -1838,6 +1843,7 @@ static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
+		tp->delivered += max_t(int, acked - tp->sacked_out, 1);
 		if (acked - 1 >= tp->sacked_out)
 			tp->sacked_out = 0;
 		else
@@ -3158,10 +3164,13 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 				flag |= FLAG_ORIG_SACK_ACKED;
 		}
 
-		if (sacked & TCPCB_SACKED_ACKED)
+		if (sacked & TCPCB_SACKED_ACKED) {
 			tp->sacked_out -= acked_pcount;
-		else if (tcp_is_sack(tp) && !tcp_skb_spurious_retrans(tp, skb))
-			tcp_rack_advance(tp, &skb->skb_mstamp, sacked);
+		} else if (tcp_is_sack(tp)) {
+			tp->delivered += acked_pcount;
+			if (!tcp_skb_spurious_retrans(tp, skb))
+				tcp_rack_advance(tp, &skb->skb_mstamp, sacked);
+		}
 		if (sacked & TCPCB_LOST)
 			tp->lost_out -= acked_pcount;
 
@@ -3543,9 +3552,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	bool is_dupack = false;
 	u32 prior_fackets;
 	int prior_packets = tp->packets_out;
-	const int prior_unsacked = tp->packets_out - tp->sacked_out;
+	u32 prior_delivered = tp->delivered;
 	int acked = 0; /* Number of packets newly acked */
-	int acked_sacked; /* Number of packets newly acked or sacked */
+	u32 acked_sacked; /* Number of packets newly acked or sacked */
 	int rexmit = REXMIT_NONE; /* Flag to (re)transmit to recover losses */
 
 	sack_state.first_sackt.v64 = 0;
@@ -3647,7 +3656,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
 
-	acked_sacked = prior_unsacked - (tp->packets_out - tp->sacked_out);
+	acked_sacked = tp->delivered - prior_delivered;
 	/* Advance cwnd if state allows */
 	if (tcp_in_cwnd_reduction(sk)) {
 		/* Reduce cwnd if state mandates */
-- 
2.6.0.rc2.230.g3dd15c0
