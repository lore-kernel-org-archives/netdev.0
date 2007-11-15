From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 07/10] [TCP]: Create tcp_sacktag_one().
Date: Thu, 15 Nov 2007 15:37:31 +0200
Message-ID: <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59401 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757440AbXKONhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:38 -0500
In-Reply-To: <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Worker function that implements the main logic of
the inner-most loop of tcp_sacktag_write_queue().

Idea was originally presented by David S. Miller.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  192 +++++++++++++++++++++++++-----------------=
--------
 1 files changed, 96 insertions(+), 96 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 29fff81..b301abb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1240,6 +1240,99 @@ static int tcp_match_skb_to_sack(struct sock *sk=
, struct sk_buff *skb,
 	return in_sack;
 }
=20
+static int tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
+			   int *reord, int dup_sack, int fack_count)
+{
+	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
+	int flag =3D 0;
+
+	/* Account D-SACK for retransmitted packet. */
+	if (dup_sack && (sacked & TCPCB_RETRANS)) {
+		if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
+			tp->undo_retrans--;
+		if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una) &&
+		    (sacked & TCPCB_SACKED_ACKED))
+			*reord =3D min(fack_count, *reord);
+	}
+
+	/* Nothing to do; acked frame is about to be dropped (was ACKed). */
+	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
+		return flag;
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
+			if (!(sacked & TCPCB_RETRANS)) {
+				/* New sack for not retransmitted frame,
+				 * which was in hole. It is reordering.
+				 */
+				if (before(TCP_SKB_CB(skb)->seq,
+					   tcp_highest_sack_seq(tp)))
+					*reord =3D min(fack_count, *reord);
+
+				/* SACK enhanced F-RTO (RFC4138; Appendix B) */
+				if (!after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark))
+					flag |=3D FLAG_ONLY_ORIG_SACKED;
+			}
+
+			if (sacked & TCPCB_LOST) {
+				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
+				tp->lost_out -=3D tcp_skb_pcount(skb);
+
+				/* clear lost hint */
+				tp->retransmit_skb_hint =3D NULL;
+			}
+		}
+
+		TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
+		flag |=3D FLAG_DATA_SACKED;
+		tp->sacked_out +=3D tcp_skb_pcount(skb);
+
+		fack_count +=3D tcp_skb_pcount(skb);
+
+		/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
+		if (!tcp_is_fack(tp) && (tp->lost_skb_hint !=3D NULL) &&
+		    before(TCP_SKB_CB(skb)->seq,
+			   TCP_SKB_CB(tp->lost_skb_hint)->seq))
+			tp->lost_cnt_hint +=3D tcp_skb_pcount(skb);
+
+		if (fack_count > tp->fackets_out)
+			tp->fackets_out =3D fack_count;
+
+		if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+			tp->highest_sack =3D skb;
+
+	} else {
+		if (dup_sack && (sacked & TCPCB_RETRANS))
+			*reord =3D min(fack_count, *reord);
+	}
+
+	/* D-SACK. We can detect redundant retransmission in S|R and plain R
+	 * frames and clear it. undo_retrans is decreased above, L|R frames
+	 * are accounted above as well.
+	 */
+	if (dup_sack && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)) {
+		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
+		tp->retrans_out -=3D tcp_skb_pcount(skb);
+		tp->retransmit_skb_hint =3D NULL;
+	}
+
+	return flag;
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
 {
@@ -1375,7 +1468,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 		tcp_for_write_queue_from(skb, sk) {
 			int in_sack =3D 0;
-			u8 sacked;
=20
 			if (skb =3D=3D tcp_send_head(sk))
 				break;
@@ -1413,102 +1505,10 @@ tcp_sacktag_write_queue(struct sock *sk, struc=
t sk_buff *ack_skb, u32 prior_snd_
 			if (unlikely(in_sack < 0))
 				break;
=20
-			if (!in_sack) {
-				fack_count +=3D tcp_skb_pcount(skb);
-				continue;
-			}
-
-			sacked =3D TCP_SKB_CB(skb)->sacked;
-
-			/* Account D-SACK for retransmitted packet. */
-			if (dup_sack && (sacked & TCPCB_RETRANS)) {
-				if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
-					tp->undo_retrans--;
-				if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una) &&
-				    (sacked & TCPCB_SACKED_ACKED))
-					reord =3D min(fack_count, reord);
-			}
-
-
-			/* Nothing to do; acked frame is about to be dropped (was ACKed). *=
/
-			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
-				fack_count +=3D tcp_skb_pcount(skb);
-				continue;
-			}
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
-					if (!(sacked & TCPCB_RETRANS)) {
-						/* New sack for not retransmitted frame,
-						 * which was in hole. It is reordering.
-						 */
-						if (before(TCP_SKB_CB(skb)->seq,
-							   tcp_highest_sack_seq(tp)))
-							reord =3D min(fack_count, reord);
-
-						/* SACK enhanced F-RTO (RFC4138; Appendix B) */
-						if (!after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark))
-							flag |=3D FLAG_ONLY_ORIG_SACKED;
-					}
-
-					if (sacked & TCPCB_LOST) {
-						TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
-						tp->lost_out -=3D tcp_skb_pcount(skb);
-
-						/* clear lost hint */
-						tp->retransmit_skb_hint =3D NULL;
-					}
-				}
-
-				TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
-				flag |=3D FLAG_DATA_SACKED;
-				tp->sacked_out +=3D tcp_skb_pcount(skb);
-
-				fack_count +=3D tcp_skb_pcount(skb);
-
-				/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
-				if (!tcp_is_fack(tp) && (tp->lost_skb_hint !=3D NULL) &&
-				    before(TCP_SKB_CB(skb)->seq,
-					   TCP_SKB_CB(tp->lost_skb_hint)->seq))
-					tp->lost_cnt_hint +=3D tcp_skb_pcount(skb);
-
-				if (fack_count > tp->fackets_out)
-					tp->fackets_out =3D fack_count;
+			if (in_sack)
+				flag |=3D tcp_sacktag_one(skb, tp, &reord, dup_sack, fack_count);
=20
-				if (after(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-					tp->highest_sack =3D skb;
-
-			} else {
-				if (dup_sack && (sacked&TCPCB_RETRANS))
-					reord =3D min(fack_count, reord);
-
-				fack_count +=3D tcp_skb_pcount(skb);
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
+			fack_count +=3D tcp_skb_pcount(skb);
 		}
=20
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
--=20
1.5.0.6

