From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 4/5] [TCP]: new LOST marker optimizations
Date: Fri, 16 Mar 2007 16:40:01 +0200
Message-ID: <1174056002151-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11740560023261-git-send-email-ilpo.jarvinen@helsinki.fi> <11740560021077-git-send-email-ilpo.jarvinen@helsinki.fi> <11740560021541-git-send-email-ilpo.jarvinen@helsinki.fi> <11740560022597-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46540 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965574AbXCPOkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 10:40:06 -0400
In-Reply-To: <11740560022597-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) Couple of skb states are mutually exclusive

Skb cannot be in both S and L states at the same time, adding
non-S nor L skb count (below highest sack) to that can be
compared against fackets_out to see if anything below the
current skb can still be marked with L or not. If they're
equal (or fackets_out is smaller), the next skb will have L
set for sure.

2) Create a fastpath for the new LOST marker

The fastpath takes advantage of the fact that the latest ACK
very likely contains the globally highest SACK block. By
verifying that is larger than tp->reordering, whole SACK block
can be skipped while counting for not-to-be marked skbs until
tp->reordering of them is encountered. Since TCP now can know,
that should block exists as highest, the marking can begin right
below it. If the latest ACK does not contain a SACK block that
reaches all the way to the highest_sack (e.g., due to
reordering), a slow path is used.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  133 +++++++++++++++++++++++++++++++++---------=
--------
 1 files changed, 87 insertions(+), 46 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f2b3f68..88d3a4c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -936,7 +936,8 @@ #endif
  * account for retransmits accurately.
  */
 static int
-tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
+tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
+			u32 prior_snd_una, u32 *mark_lost_entry_seq)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -957,7 +958,8 @@ tcp_sacktag_write_queue(struct sock *sk,
 	if (!tp->sacked_out) {
 		tp->fackets_out =3D 0;
 		tp->highest_sack =3D tp->snd_una;
-	}
+	} else
+		*mark_lost_entry_seq =3D tp->highest_sack;
 	prior_fackets =3D tp->fackets_out;
=20
 	/* Check for D-SACK. */
@@ -1212,6 +1214,16 @@ tcp_sacktag_write_queue(struct sock *sk,
 				tp->retransmit_skb_hint =3D NULL;
 			}
 		}
+
+		/* Prepare non-reno LOST marking fast path entry point, the
+		 * last ACK must have the globally highest SACK to use
+		 * fastpath, if the highest SACK block is larger than
+		 * tp->reordering, just skip collecting reord_count from
+		 * it when marking LOSTs later.
+		 */
+		if (!before(end_seq, tp->highest_sack) &&
+		    ((end_seq - start_seq) >=3D tp->reordering * tp->mss_cache))
+			*mark_lost_entry_seq =3D start_seq;
 	}
=20
 	/* Check for lost retransmit. This superb idea is
@@ -1815,7 +1827,7 @@ static void tcp_mark_head_lost_single(st
  *       walk. Basically the entry point will be next skb after highes=
t_sack
  *       or high_seq (if TCP did the skip).
  */
-static void tcp_update_scoreboard_fack(struct sock *sk)
+static void tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	int timedout_continue =3D 1;
@@ -1829,54 +1841,71 @@ static void tcp_update_scoreboard_fack(s
 		not_marked_skb =3D tcp_write_queue_next(sk, not_marked_skb);
=20
 	} else {
-		unsigned int reord_count =3D 0;
+		unsigned int holes_seen =3D 0;
+		int reentry_to_highest_sack =3D 0;
=20
-		skb =3D tcp_write_queue_find(sk, tp->highest_sack);
+		skb =3D tcp_write_queue_find(sk, entry_seq);
 		/* If this ever becomes expensive, it can be delayed */
 		not_marked_skb =3D tcp_write_queue_next(sk, skb);
+		if (entry_seq !=3D tp->highest_sack) {
+			/* Not interested in "the last" SACKed one we got */
+			/* RFC: find_below could help here too */
+			skb =3D tcp_write_queue_prev(sk, skb);
+			/* Delay lookup because it might turn out unnecessary! */
+			reentry_to_highest_sack =3D 1;
+		} else {
+			unsigned int reord_count =3D 0;
=20
-		/* Phase I: Search until TCP can mark */
-		tcp_for_write_queue_backwards_from(skb, sk) {
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
-				break;
+			/* Phase I: Search until TCP can mark */
+			tcp_for_write_queue_backwards_from(skb, sk) {
+				if ((tp->fackets_out <=3D tp->sacked_out +
+							tp->lost_out +
+							holes_seen) ||
+				    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
+					goto backwards_walk_done;
=20
-			if (tcp_skb_timedout(sk, skb))
-				break;
-			else
-				timedout_continue =3D 0;
+				if (tcp_skb_timedout(sk, skb))
+					break;
+				else {
+					timedout_continue =3D 0;
+					reentry_to_highest_sack =3D 0;
+				}
=20
-			/*
-			 * Isn't marked, thus a possible entrypoint (last skb
-			 * before LOST edge but TCP doesn't know for sure yet)
-			 */
-			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-				not_marked_skb =3D skb;
-
-			reord_count +=3D tcp_skb_pcount(skb);
-			if (reord_count > tp->reordering) {
-				if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
-					/* RFC: should we have find_below? */
-					skb =3D tcp_write_queue_find(sk, tp->high_seq);
+				/*
+				 * Isn't marked, thus a possible entrypoint
+				 * (last skb before LOST edge but TCP doesn't
+				 * know for sure yet)
+				 */
+				if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 					not_marked_skb =3D skb;
-					skb =3D tcp_write_queue_prev(sk, skb);
-					/* Timedout top is again uncertain? */
-					if (tcp_skb_timedout(sk, skb))
-						timedout_continue =3D 1;
+					holes_seen +=3D tcp_skb_pcount(skb);
 				}
-				/* ...else:
-				 * RFC: Might have to handle skb fragmentation
-				 * here if reord_count > tp->reordering, which
-				 * can be caused by pcount > 1 in the last
-				 * skb... Original does not handle it, btw.
-				 */
-				break;
+
+				reord_count +=3D tcp_skb_pcount(skb);
+				if (reord_count > tp->reordering)
+					break;
 			}
 		}
=20
+		if (!tcp_skb_timedout(sk, skb) &&
+		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+			/* RFC: should we have find_below? */
+			skb =3D tcp_write_queue_find(sk, tp->high_seq);
+			not_marked_skb =3D skb;
+			skb =3D tcp_write_queue_prev(sk, skb);
+			/* Timedout top is again uncertain? */
+			if (tcp_skb_timedout(sk, skb))
+				timedout_continue =3D 1;
+		}
+		/* RFC: ...else if (!tcp_skb_timedout) do skb fragmentation? */
+
 		/* Phase II: Marker */
 		tcp_for_write_queue_backwards_from(skb, sk) {
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
-				break;
+			if ((tp->fackets_out <=3D tp->sacked_out + tp->lost_out +
+						holes_seen) ||
+			    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
+				goto backwards_walk_done;
+
 			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 				tp->lost_out +=3D tcp_skb_pcount(skb);
@@ -1887,6 +1916,13 @@ static void tcp_update_scoreboard_fack(s
 		/* Phase III: Nothing is still marked?, mark head then */
 		if (!tp->lost_out)
 			tcp_mark_head_lost_single(sk);
+
+backwards_walk_done:
+		if (timedout_continue && reentry_to_highest_sack) {
+			/* ...do the delayed lookup */
+			skb =3D tcp_write_queue_find(sk, tp->highest_sack);
+			not_marked_skb =3D tcp_write_queue_next(sk, skb);
+		}
 	}
=20
 	/* Continue with timedout work */
@@ -1897,10 +1933,11 @@ static void tcp_update_scoreboard_fack(s
 }
=20
 /* Account newly detected lost packet(s) */
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp=
)
+static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp=
,
+				  u32 sack_entry_seq)
 {
 	if (!IsReno(tp))
-		tcp_update_scoreboard_fack(sk);
+		tcp_update_scoreboard_fack(sk, sack_entry_seq);
 	else
 		tcp_mark_head_lost_single(sk);
 }
@@ -2170,7 +2207,7 @@ static void tcp_mtup_probe_success(struc
  */
 static void
 tcp_fastretrans_alert(struct sock *sk, u32 prior_snd_una,
-		      int prior_packets, int flag)
+		      int prior_packets, int flag, u32 mark_lost_entry_seq)
 {
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2198,7 +2235,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-	    	tcp_update_scoreboard_fack(sk);
+	    	tcp_update_scoreboard_fack(sk, mark_lost_entry_seq);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
@@ -2324,7 +2361,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	}
=20
 	if (is_dupack || tcp_head_timedout(sk, tp))
-		tcp_update_scoreboard(sk, tp);
+		tcp_update_scoreboard(sk, tp, mark_lost_entry_seq);
 	tcp_cwnd_down(sk);
 	tcp_xmit_retransmit_queue(sk);
 }
@@ -2810,6 +2847,7 @@ static int tcp_ack(struct sock *sk, stru
 	u32 ack_seq =3D TCP_SKB_CB(skb)->seq;
 	u32 ack =3D TCP_SKB_CB(skb)->ack_seq;
 	u32 prior_in_flight;
+	u32 mark_lost_entry_seq =3D tp->snd_una;
 	s32 seq_rtt;
 	int prior_packets;
 	int frto_cwnd =3D 0;
@@ -2852,7 +2890,8 @@ static int tcp_ack(struct sock *sk, stru
 		flag |=3D tcp_ack_update_window(sk, tp, skb, ack, ack_seq);
=20
 		if (TCP_SKB_CB(skb)->sacked)
-			flag |=3D tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+			flag |=3D tcp_sacktag_write_queue(sk, skb, prior_snd_una,
+							&mark_lost_entry_seq);
=20
 		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb)))
 			flag |=3D FLAG_ECE;
@@ -2882,7 +2921,8 @@ static int tcp_ack(struct sock *sk, stru
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack,  seq_rtt, prior_in_flight, 0);
-		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
+		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag,
+				      mark_lost_entry_seq);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, seq_rtt, prior_in_flight, 1);
@@ -2906,7 +2946,8 @@ no_queue:
=20
 old_ack:
 	if (TCP_SKB_CB(skb)->sacked)
-		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+		tcp_sacktag_write_queue(sk, skb, prior_snd_una,
+					&mark_lost_entry_seq);
=20
 uninteresting_ack:
 	SOCK_DEBUG(sk, "Ack %u out of %u:%u\n", ack, tp->snd_una, tp->snd_nxt=
);
--=20
1.4.2

