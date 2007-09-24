From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/5] [TCP]: Create tcp_sacktag_one().
Date: Mon, 24 Sep 2007 13:28:44 +0300
Message-ID: <11906297271155-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297272364-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"David S. Miller" <davem@sunset.davemloft.net>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Tom Quetchenbach <virtualphtn@gmail.com>,
	Baruch Even <bar
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33597 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbXIXK2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 06:28:49 -0400
In-Reply-To: <11906297272364-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David S. Miller <davem@sunset.davemloft.net>

Worker function that implements the main logic of
the inner-most loop of tcp_sacktag_write_queue().

Signed-off-by: David S. Miller <davem@davemloft.net>
Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  213 ++++++++++++++++++++++++++----------------=
--------
 1 files changed, 110 insertions(+), 103 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 04ff465..76e9c9b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1143,6 +1143,114 @@ static int tcp_check_dsack(struct tcp_sock *tp,=
 struct sk_buff *ack_skb,
 	return dup_sack;
 }
=20
+static void tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
+			    struct tcp_sacktag_state *state, int in_sack,
+			    int dup_sack, int fack_count, u32 end_seq)
+{
+	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
+
+	/* Account D-SACK for retransmitted packet. */
+	if ((dup_sack && in_sack) &&
+	    (sacked & TCPCB_RETRANS) &&
+	    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
+		tp->undo_retrans--;
+
+	/* The frame is ACKed. */
+	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
+		if (sacked & TCPCB_RETRANS) {
+			if ((dup_sack && in_sack) &&
+			    (sacked & TCPCB_SACKED_ACKED))
+				state->reord =3D min(fack_count, state->reord);
+		} else {
+			/* If it was in a hole, we detected reordering. */
+			if (fack_count < state->prior_fackets &&
+			    !(sacked & TCPCB_SACKED_ACKED))
+				state->reord =3D min(fack_count, state->reord);
+		}
+
+		/* Nothing to do; acked frame is about to be dropped. */
+		return;
+	}
+
+	if ((sacked & TCPCB_SACKED_RETRANS) &&
+	    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
+	    (!state->lost_retrans || after(end_seq, state->lost_retrans)))
+		state->lost_retrans =3D end_seq;
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
+				TCP_SKB_CB(skb)->sacked &=3D
+					~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+				tp->lost_out -=3D tcp_skb_pcount(skb);
+				tp->retrans_out -=3D tcp_skb_pcount(skb);
+
+				/* clear lost hint */
+				tp->retransmit_skb_hint =3D NULL;
+			}
+		} else {
+			/* New sack for not retransmitted frame,
+			 * which was in hole. It is reordering.
+			 */
+			if (!(sacked & TCPCB_RETRANS) &&
+			    fack_count < state->prior_fackets)
+				state->reord =3D min(fack_count, state->reord);
+
+			if (sacked & TCPCB_LOST) {
+				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
+				tp->lost_out -=3D tcp_skb_pcount(skb);
+
+				/* clear lost hint */
+				tp->retransmit_skb_hint =3D NULL;
+			}
+			/* SACK enhanced F-RTO detection.
+			 * Set flag if and only if non-rexmitted
+			 * segments below frto_highmark are
+			 * SACKed (RFC4138; Appendix B).
+			 * Clearing correct due to in-order walk
+			 */
+			if (after(end_seq, tp->frto_highmark)) {
+				state->flag &=3D ~FLAG_ONLY_ORIG_SACKED;
+			} else {
+				if (!(sacked & TCPCB_RETRANS))
+					state->flag |=3D FLAG_ONLY_ORIG_SACKED;
+			}
+		}
+
+		TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
+		state->flag |=3D FLAG_DATA_SACKED;
+		tp->sacked_out +=3D tcp_skb_pcount(skb);
+
+		if (fack_count > tp->fackets_out)
+			tp->fackets_out =3D fack_count;
+
+		if (after(TCP_SKB_CB(skb)->seq,
+			  tp->highest_sack))
+			tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
+	} else {
+		if (dup_sack && (sacked&TCPCB_RETRANS))
+			state->reord =3D min(fack_count, state->reord);
+	}
+
+	/* D-SACK. We can detect redundant retransmission
+	 * in S|R and plain R frames and clear it.
+	 * undo_retrans is decreased above, L|R frames
+	 * are accounted above as well.
+	 */
+	if (dup_sack && (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
+		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -=3D tcp_skb_pcount(skb);
+		tp->retransmit_skb_hint =3D NULL;
+	}
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
 {
@@ -1274,7 +1382,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 		tcp_for_write_queue_from(skb, sk) {
 			int in_sack, pcount;
-			u8 sacked;
=20
 			if (skb =3D=3D tcp_send_head(sk))
 				break;
@@ -1317,108 +1424,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
=20
 			fack_count +=3D pcount;
=20
-			sacked =3D TCP_SKB_CB(skb)->sacked;
-
-			/* Account D-SACK for retransmitted packet. */
-			if ((dup_sack && in_sack) &&
-			    (sacked & TCPCB_RETRANS) &&
-			    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
-				tp->undo_retrans--;
-
-			/* The frame is ACKed. */
-			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
-				if (sacked&TCPCB_RETRANS) {
-					if ((dup_sack && in_sack) &&
-					    (sacked&TCPCB_SACKED_ACKED))
-						state.reord =3D min(fack_count, state.reord);
-				} else {
-					/* If it was in a hole, we detected reordering. */
-					if (fack_count < state.prior_fackets &&
-					    !(sacked&TCPCB_SACKED_ACKED))
-						state.reord =3D min(fack_count, state.reord);
-				}
-
-				/* Nothing to do; acked frame is about to be dropped. */
-				continue;
-			}
-
-			if ((sacked&TCPCB_SACKED_RETRANS) &&
-			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!state.lost_retrans || after(end_seq, state.lost_retrans)))
-				state.lost_retrans =3D end_seq;
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
-						TCP_SKB_CB(skb)->sacked &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
-						tp->lost_out -=3D tcp_skb_pcount(skb);
-						tp->retrans_out -=3D tcp_skb_pcount(skb);
-
-						/* clear lost hint */
-						tp->retransmit_skb_hint =3D NULL;
-					}
-				} else {
-					/* New sack for not retransmitted frame,
-					 * which was in hole. It is reordering.
-					 */
-					if (!(sacked & TCPCB_RETRANS) &&
-					    fack_count < state.prior_fackets)
-						state.reord =3D min(fack_count, state.reord);
-
-					if (sacked & TCPCB_LOST) {
-						TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
-						tp->lost_out -=3D tcp_skb_pcount(skb);
-
-						/* clear lost hint */
-						tp->retransmit_skb_hint =3D NULL;
-					}
-					/* SACK enhanced F-RTO detection.
-					 * Set flag if and only if non-rexmitted
-					 * segments below frto_highmark are
-					 * SACKed (RFC4138; Appendix B).
-					 * Clearing correct due to in-order walk
-					 */
-					if (after(end_seq, tp->frto_highmark)) {
-						state.flag &=3D ~FLAG_ONLY_ORIG_SACKED;
-					} else {
-						if (!(sacked & TCPCB_RETRANS))
-							state.flag |=3D FLAG_ONLY_ORIG_SACKED;
-					}
-				}
-
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
-				state.flag |=3D FLAG_DATA_SACKED;
-				tp->sacked_out +=3D tcp_skb_pcount(skb);
-
-				if (fack_count > tp->fackets_out)
-					tp->fackets_out =3D fack_count;
-
-				if (after(TCP_SKB_CB(skb)->seq,
-				    tp->highest_sack))
-					tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
-			} else {
-				if (dup_sack && (sacked&TCPCB_RETRANS))
-					state.reord =3D min(fack_count, state.reord);
-			}
-
-			/* D-SACK. We can detect redundant retransmission
-			 * in S|R and plain R frames and clear it.
-			 * undo_retrans is decreased above, L|R frames
-			 * are accounted above as well.
-			 */
-			if (dup_sack &&
-			    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
-				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
-				tp->retrans_out -=3D tcp_skb_pcount(skb);
-				tp->retransmit_skb_hint =3D NULL;
-			}
+			tcp_sacktag_one(skb, tp, &state, in_sack,
+					dup_sack, fack_count, end_seq);
 		}
 	}
=20
--=20
1.5.0.6

