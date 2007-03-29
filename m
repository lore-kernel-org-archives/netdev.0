From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Pull out core sack tagging logic
Date: Wed, 28 Mar 2007 19:36:42 -0700 (PDT)
Message-ID: <20070328.193642.74748105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965913AbXC2Cgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 22:36:43 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8D489AE41A5
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 19:36:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, this is what I was initially trying to do, pull out the
inner-most loop main code into a helper function.

Pushed to net-2.6.22

commit b096b50b4bf3c923bee28751d1ed41e92361a298
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Mar 28 19:35:51 2007 -0700

    [TCP]: Create tcp_sacktag_one().
    
    Worker function that implements the main logic of
    the inner-most loop of tcp_sacktag_write_queue().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 464dc80..97b9be2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -978,6 +978,115 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
 	return dup_sack;
 }
 
+static void tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
+			    struct tcp_sacktag_state *state, int in_sack,
+			    int fack_count, u32 end_seq)
+{
+	u8 sacked = TCP_SKB_CB(skb)->sacked;
+
+	/* Account D-SACK for retransmitted packet. */
+	if ((state->dup_sack && in_sack) &&
+	    (sacked & TCPCB_RETRANS) &&
+	    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
+		tp->undo_retrans--;
+
+	/* The frame is ACKed. */
+	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
+		if (sacked & TCPCB_RETRANS) {
+			if ((state->dup_sack && in_sack) &&
+			    (sacked & TCPCB_SACKED_ACKED))
+				state->reord = min(fack_count, state->reord);
+		} else {
+			/* If it was in a hole, we detected reordering. */
+			if (fack_count < state->prior_fackets &&
+			    !(sacked & TCPCB_SACKED_ACKED))
+				state->reord = min(fack_count, state->reord);
+		}
+
+		/* Nothing to do; acked frame is about to be dropped. */
+		return;
+	}
+
+	if ((sacked & TCPCB_SACKED_RETRANS) &&
+	    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
+	    (!state->lost_retrans || after(end_seq, state->lost_retrans)))
+		state->lost_retrans = end_seq;
+
+	if (!in_sack)
+		return;
+
+	if (!(sacked & TCPCB_SACKED_ACKED)) {
+		if (sacked & TCPCB_SACKED_RETRANS) {
+			/* If the segment is not tagged as lost,
+			 * we do not clear RETRANS, believing
+			 * that retransmission is still in flight.
+			 */
+			if (sacked & TCPCB_LOST) {
+				TCP_SKB_CB(skb)->sacked &=
+					~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+				tp->lost_out -= tcp_skb_pcount(skb);
+				tp->retrans_out -= tcp_skb_pcount(skb);
+
+				/* clear lost hint */
+				tp->retransmit_skb_hint = NULL;
+			}
+		} else {
+			/* New sack for not retransmitted frame,
+			 * which was in hole. It is reordering.
+			 */
+			if (!(sacked & TCPCB_RETRANS) &&
+			    fack_count < state->prior_fackets)
+				state->reord = min(fack_count, state->reord);
+
+			if (sacked & TCPCB_LOST) {
+				TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
+				tp->lost_out -= tcp_skb_pcount(skb);
+
+				/* clear lost hint */
+				tp->retransmit_skb_hint = NULL;
+			}
+			/* SACK enhanced F-RTO detection.
+			 * Set flag if and only if non-rexmitted
+			 * segments below frto_highmark are
+			 * SACKed (RFC4138; Appendix B).
+			 * Clearing correct due to in-order walk
+			 */
+			if (after(end_seq, tp->frto_highmark)) {
+				state->flag &= ~FLAG_ONLY_ORIG_SACKED;
+			} else {
+				if (!(sacked & TCPCB_RETRANS))
+					state->flag |= FLAG_ONLY_ORIG_SACKED;
+			}
+		}
+
+		TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
+		state->flag |= FLAG_DATA_SACKED;
+		tp->sacked_out += tcp_skb_pcount(skb);
+
+		if (fack_count > tp->fackets_out)
+			tp->fackets_out = fack_count;
+
+		if (after(TCP_SKB_CB(skb)->seq,
+			  tp->highest_sack))
+			tp->highest_sack = TCP_SKB_CB(skb)->seq;
+	} else {
+		if (state->dup_sack && (sacked&TCPCB_RETRANS))
+			state->reord = min(fack_count, state->reord);
+	}
+
+	/* D-SACK. We can detect redundant retransmission
+	 * in S|R and plain R frames and clear it.
+	 * undo_retrans is decreased above, L|R frames
+	 * are accounted above as well.
+	 */
+	if (state->dup_sack &&
+	    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
+		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -= tcp_skb_pcount(skb);
+		tp->retransmit_skb_hint = NULL;
+	}
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 			u32 prior_snd_una, u32 *mark_lost_entry_seq)
@@ -1090,7 +1199,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 		tcp_for_write_queue_from(skb, sk) {
 			int in_sack, pcount;
-			u8 sacked;
 
 			if (skb == tcp_send_head(sk))
 				break;
@@ -1133,108 +1241,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 			fack_count += pcount;
 
-			sacked = TCP_SKB_CB(skb)->sacked;
-
-			/* Account D-SACK for retransmitted packet. */
-			if ((state.dup_sack && in_sack) &&
-			    (sacked & TCPCB_RETRANS) &&
-			    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
-				tp->undo_retrans--;
-
-			/* The frame is ACKed. */
-			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
-				if (sacked&TCPCB_RETRANS) {
-					if ((state.dup_sack && in_sack) &&
-					    (sacked&TCPCB_SACKED_ACKED))
-						state.reord = min(fack_count, state.reord);
-				} else {
-					/* If it was in a hole, we detected reordering. */
-					if (fack_count < state.prior_fackets &&
-					    !(sacked&TCPCB_SACKED_ACKED))
-						state.reord = min(fack_count, state.reord);
-				}
-
-				/* Nothing to do; acked frame is about to be dropped. */
-				continue;
-			}
-
-			if ((sacked&TCPCB_SACKED_RETRANS) &&
-			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!state.lost_retrans || after(end_seq, state.lost_retrans)))
-				state.lost_retrans = end_seq;
-
-			if (!in_sack)
-				continue;
-
-			if (!(sacked&TCPCB_SACKED_ACKED)) {
-				if (sacked & TCPCB_SACKED_RETRANS) {
-					/* If the segment is not tagged as lost,
-					 * we do not clear RETRANS, believing
-					 * that retransmission is still in flight.
-					 */
-					if (sacked & TCPCB_LOST) {
-						TCP_SKB_CB(skb)->sacked &= ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
-						tp->lost_out -= tcp_skb_pcount(skb);
-						tp->retrans_out -= tcp_skb_pcount(skb);
-
-						/* clear lost hint */
-						tp->retransmit_skb_hint = NULL;
-					}
-				} else {
-					/* New sack for not retransmitted frame,
-					 * which was in hole. It is reordering.
-					 */
-					if (!(sacked & TCPCB_RETRANS) &&
-					    fack_count < state.prior_fackets)
-						state.reord = min(fack_count, state.reord);
-
-					if (sacked & TCPCB_LOST) {
-						TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
-						tp->lost_out -= tcp_skb_pcount(skb);
-
-						/* clear lost hint */
-						tp->retransmit_skb_hint = NULL;
-					}
-					/* SACK enhanced F-RTO detection.
-					 * Set flag if and only if non-rexmitted
-					 * segments below frto_highmark are
-					 * SACKed (RFC4138; Appendix B).
-					 * Clearing correct due to in-order walk
-					 */
-					if (after(end_seq, tp->frto_highmark)) {
-						state.flag &= ~FLAG_ONLY_ORIG_SACKED;
-					} else {
-						if (!(sacked & TCPCB_RETRANS))
-							state.flag |= FLAG_ONLY_ORIG_SACKED;
-					}
-				}
-
-				TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
-				state.flag |= FLAG_DATA_SACKED;
-				tp->sacked_out += tcp_skb_pcount(skb);
-
-				if (fack_count > tp->fackets_out)
-					tp->fackets_out = fack_count;
-
-				if (after(TCP_SKB_CB(skb)->seq,
-				    tp->highest_sack))
-					tp->highest_sack = TCP_SKB_CB(skb)->seq;
-			} else {
-				if (state.dup_sack && (sacked&TCPCB_RETRANS))
-					state.reord = min(fack_count, state.reord);
-			}
-
-			/* D-SACK. We can detect redundant retransmission
-			 * in S|R and plain R frames and clear it.
-			 * undo_retrans is decreased above, L|R frames
-			 * are accounted above as well.
-			 */
-			if (state.dup_sack &&
-			    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
-				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -= tcp_skb_pcount(skb);
-				tp->retransmit_skb_hint = NULL;
-			}
+			tcp_sacktag_one(skb, tp, &state, in_sack,
+					fack_count, end_seq);
 		}
 
 		/* Prepare non-reno LOST marking fast path entry point, the
