From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 04/10] tcp: introduce struct tcp_sacktag_state to reduce arg pressure
Date: Fri,  5 Dec 2008 22:58:50 +0200
Message-ID: <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59059 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641AbYLEU67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:59 -0500
In-Reply-To: <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are just too many args to some sacktag functions. This
idea was first proposed by David S. Miller around a year ago,
and the current situation is much worse that what it was back
then.

tcp_sacktag_one can be made a bit simpler by returning the
new sacked (it can be achieved with a single variable though
the previous code "caching" sacked into a local variable and
therefore it is not exactly equal but the results will be the
same).

codiff on x86_64
  tcp_sacktag_one         |  -15
  tcp_shifted_skb         |  -50
  tcp_match_skb_to_sack   |   -1
  tcp_sacktag_walk        |  -64
  tcp_sacktag_write_queue |  -59
  tcp_urg                 |   +1
  tcp_event_data_recv     |   -1
 7 functions changed, 1 bytes added, 190 bytes removed, diff: -189

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  145 +++++++++++++++++++++++++-----------------=
-------
 1 files changed, 74 insertions(+), 71 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21c6701..57134c2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1237,6 +1237,12 @@ static int tcp_check_dsack(struct sock *sk, stru=
ct sk_buff *ack_skb,
 	return dup_sack;
 }
=20
+struct tcp_sacktag_state {
+	int reord;
+	int fack_count;
+	int flag;
+};
+
 /* Check if skb is fully within the SACK block. In presence of GSO skb=
s,
  * the incoming SACK may not exactly match but we can find smaller MSS
  * aligned portion of it that matches. Therefore we might need to frag=
ment
@@ -1290,25 +1296,25 @@ static int tcp_match_skb_to_sack(struct sock *s=
k, struct sk_buff *skb,
 	return in_sack;
 }
=20
-static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
-			   int *reord, int dup_sack, int fack_count,
-			   u8 *sackedto, int pcount)
+static u8 tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
+			  struct tcp_sacktag_state *state,
+			  int dup_sack, int pcount)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
-	int flag =3D 0;
+	int fack_count =3D state->fack_count;
=20
 	/* Account D-SACK for retransmitted packet. */
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
 		if (after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
 			tp->undo_retrans--;
 		if (sacked & TCPCB_SACKED_ACKED)
-			*reord =3D min(fack_count, *reord);
+			state->reord =3D min(fack_count, state->reord);
 	}
=20
 	/* Nothing to do; acked frame is about to be dropped (was ACKed). */
 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
-		return flag;
+		return sacked;
=20
 	if (!(sacked & TCPCB_SACKED_ACKED)) {
 		if (sacked & TCPCB_SACKED_RETRANS) {
@@ -1317,7 +1323,7 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 			 * that retransmission is still in flight.
 			 */
 			if (sacked & TCPCB_LOST) {
-				*sackedto &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
+				sacked &=3D ~(TCPCB_LOST|TCPCB_SACKED_RETRANS);
 				tp->lost_out -=3D pcount;
 				tp->retrans_out -=3D pcount;
 			}
@@ -1328,21 +1334,22 @@ static int tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 				 */
 				if (before(TCP_SKB_CB(skb)->seq,
 					   tcp_highest_sack_seq(tp)))
-					*reord =3D min(fack_count, *reord);
+					state->reord =3D min(fack_count,
+							   state->reord);
=20
 				/* SACK enhanced F-RTO (RFC4138; Appendix B) */
 				if (!after(TCP_SKB_CB(skb)->end_seq, tp->frto_highmark))
-					flag |=3D FLAG_ONLY_ORIG_SACKED;
+					state->flag |=3D FLAG_ONLY_ORIG_SACKED;
 			}
=20
 			if (sacked & TCPCB_LOST) {
-				*sackedto &=3D ~TCPCB_LOST;
+				sacked &=3D ~TCPCB_LOST;
 				tp->lost_out -=3D pcount;
 			}
 		}
=20
-		*sackedto |=3D TCPCB_SACKED_ACKED;
-		flag |=3D FLAG_DATA_SACKED;
+		sacked |=3D TCPCB_SACKED_ACKED;
+		state->flag |=3D FLAG_DATA_SACKED;
 		tp->sacked_out +=3D pcount;
=20
 		fack_count +=3D pcount;
@@ -1361,21 +1368,20 @@ static int tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 	 * frames and clear it. undo_retrans is decreased above, L|R frames
 	 * are accounted above as well.
 	 */
-	if (dup_sack && (*sackedto & TCPCB_SACKED_RETRANS)) {
-		*sackedto &=3D ~TCPCB_SACKED_RETRANS;
+	if (dup_sack && (sacked & TCPCB_SACKED_RETRANS)) {
+		sacked &=3D ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -=3D pcount;
 	}
=20
-	return flag;
+	return sacked;
 }
=20
 static int tcp_shifted_skb(struct sock *sk, struct sk_buff *prev,
-			   struct sk_buff *skb, unsigned int pcount,
-			   int shifted, int fack_count, int *reord,
-			   int *flag, int mss)
+			   struct sk_buff *skb,
+			   struct tcp_sacktag_state *state,
+			   unsigned int pcount, int shifted, int mss)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	u8 dummy_sacked =3D TCP_SKB_CB(skb)->sacked;	/* We discard results */
=20
 	BUG_ON(!pcount);
=20
@@ -1407,8 +1413,8 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *prev,
 		skb_shinfo(skb)->gso_type =3D 0;
 	}
=20
-	*flag |=3D tcp_sacktag_one(skb, sk, reord, 0, fack_count, &dummy_sack=
ed,
-				 pcount);
+	/* We discard results */
+	tcp_sacktag_one(skb, sk, state, 0, pcount);
=20
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK=
 */
 	TCP_SKB_CB(prev)->sacked |=3D (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_R=
ETRANS);
@@ -1460,9 +1466,9 @@ static int skb_can_shift(struct sk_buff *skb)
  * skb.
  */
 static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_b=
uff *skb,
+					  struct tcp_sacktag_state *state,
 					  u32 start_seq, u32 end_seq,
-					  int dup_sack, int *fack_count,
-					  int *reord, int *flag)
+					  int dup_sack)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *prev;
@@ -1559,8 +1565,7 @@ static struct sk_buff *tcp_shift_skb_data(struct =
sock *sk, struct sk_buff *skb,
=20
 	if (!skb_shift(prev, skb, len))
 		goto fallback;
-	if (!tcp_shifted_skb(sk, prev, skb, pcount, len, *fack_count, reord,
-			     flag, mss))
+	if (!tcp_shifted_skb(sk, prev, skb, state, pcount, len, mss))
 		goto out;
=20
 	/* Hole filled allows collapsing with the next as well, this is very
@@ -1579,12 +1584,12 @@ static struct sk_buff *tcp_shift_skb_data(struc=
t sock *sk, struct sk_buff *skb,
 	len =3D skb->len;
 	if (skb_shift(prev, skb, len)) {
 		pcount +=3D tcp_skb_pcount(skb);
-		tcp_shifted_skb(sk, prev, skb, tcp_skb_pcount(skb), len,
-				*fack_count, reord, flag, mss);
+		tcp_shifted_skb(sk, prev, skb, state, tcp_skb_pcount(skb), len,
+				mss);
 	}
=20
 out:
-	*fack_count +=3D pcount;
+	state->fack_count +=3D pcount;
 	return prev;
=20
 noop:
@@ -1597,9 +1602,9 @@ fallback:
=20
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
 					struct tcp_sack_block *next_dup,
+					struct tcp_sacktag_state *state,
 					u32 start_seq, u32 end_seq,
-					int dup_sack_in, int *fack_count,
-					int *reord, int *flag)
+					int dup_sack_in)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *tmp;
@@ -1629,9 +1634,8 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
 		 * so not even _safe variant of the loop is enough.
 		 */
 		if (in_sack <=3D 0) {
-			tmp =3D tcp_shift_skb_data(sk, skb, start_seq,
-						 end_seq, dup_sack,
-						 fack_count, reord, flag);
+			tmp =3D tcp_shift_skb_data(sk, skb, state,
+						 start_seq, end_seq, dup_sack);
 			if (tmp !=3D NULL) {
 				if (tmp !=3D skb) {
 					skb =3D tmp;
@@ -1650,17 +1654,17 @@ static struct sk_buff *tcp_sacktag_walk(struct =
sk_buff *skb, struct sock *sk,
 			break;
=20
 		if (in_sack) {
-			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack,
-						 *fack_count,
-						 &(TCP_SKB_CB(skb)->sacked),
-						 tcp_skb_pcount(skb));
+			TCP_SKB_CB(skb)->sacked =3D tcp_sacktag_one(skb, sk,
+								  state,
+								  dup_sack,
+								  tcp_skb_pcount(skb));
=20
 			if (!before(TCP_SKB_CB(skb)->seq,
 				    tcp_highest_sack_seq(tp)))
 				tcp_advance_highest_sack(sk, skb);
 		}
=20
-		*fack_count +=3D tcp_skb_pcount(skb);
+		state->fack_count +=3D tcp_skb_pcount(skb);
 	}
 	return skb;
 }
@@ -1669,7 +1673,8 @@ static struct sk_buff *tcp_sacktag_walk(struct sk=
_buff *skb, struct sock *sk,
  * a normal way
  */
 static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct so=
ck *sk,
-					u32 skip_to_seq, int *fack_count)
+					struct tcp_sacktag_state *state,
+					u32 skip_to_seq)
 {
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
@@ -1678,7 +1683,7 @@ static struct sk_buff *tcp_sacktag_skip(struct sk=
_buff *skb, struct sock *sk,
 		if (after(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
 			break;
=20
-		*fack_count +=3D tcp_skb_pcount(skb);
+		state->fack_count +=3D tcp_skb_pcount(skb);
 	}
 	return skb;
 }
@@ -1686,18 +1691,17 @@ static struct sk_buff *tcp_sacktag_skip(struct =
sk_buff *skb, struct sock *sk,
 static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
 						struct sock *sk,
 						struct tcp_sack_block *next_dup,
-						u32 skip_to_seq,
-						int *fack_count, int *reord,
-						int *flag)
+						struct tcp_sacktag_state *state,
+						u32 skip_to_seq)
 {
 	if (next_dup =3D=3D NULL)
 		return skb;
=20
 	if (before(next_dup->start_seq, skip_to_seq)) {
-		skb =3D tcp_sacktag_skip(skb, sk, next_dup->start_seq, fack_count);
-		skb =3D tcp_sacktag_walk(skb, sk, NULL,
-				     next_dup->start_seq, next_dup->end_seq,
-				     1, fack_count, reord, flag);
+		skb =3D tcp_sacktag_skip(skb, sk, state, next_dup->start_seq);
+		skb =3D tcp_sacktag_walk(skb, sk, NULL, state,
+				       next_dup->start_seq, next_dup->end_seq,
+				       1);
 	}
=20
 	return skb;
@@ -1719,15 +1723,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
 	struct tcp_sack_block_wire *sp_wire =3D (struct tcp_sack_block_wire *=
)(ptr+2);
 	struct tcp_sack_block sp[TCP_NUM_SACKS];
 	struct tcp_sack_block *cache;
+	struct tcp_sacktag_state state;
 	struct sk_buff *skb;
 	int num_sacks =3D min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> =
3);
 	int used_sacks;
-	int reord =3D tp->packets_out;
-	int flag =3D 0;
 	int found_dup_sack =3D 0;
-	int fack_count;
 	int i, j;
 	int first_sack_index;
+=09
+	state.flag =3D 0;
+	state.reord =3D tp->packets_out;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1738,7 +1743,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 	found_dup_sack =3D tcp_check_dsack(sk, ack_skb, sp_wire,
 					 num_sacks, prior_snd_una);
 	if (found_dup_sack)
-		flag |=3D FLAG_DSACKING_ACK;
+		state.flag |=3D FLAG_DSACKING_ACK;
=20
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
@@ -1807,7 +1812,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 	}
=20
 	skb =3D tcp_write_queue_head(sk);
-	fack_count =3D 0;
+	state.fack_count =3D 0;
 	i =3D 0;
=20
 	if (!tp->sacked_out) {
@@ -1832,7 +1837,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
-			flag |=3D FLAG_DATA_LOST;
+			state.flag |=3D FLAG_DATA_LOST;
=20
 		/* Skip too early cached blocks */
 		while (tcp_sack_cache_ok(tp, cache) &&
@@ -1845,13 +1850,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
=20
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
-				skb =3D tcp_sacktag_skip(skb, sk, start_seq,
-						       &fack_count);
+				skb =3D tcp_sacktag_skip(skb, sk, &state,
+						       start_seq);
 				skb =3D tcp_sacktag_walk(skb, sk, next_dup,
+						       &state,
 						       start_seq,
 						       cache->start_seq,
-						       dup_sack, &fack_count,
-						       &reord, &flag);
+						       dup_sack);
 			}
=20
 			/* Rest of the block already fully processed? */
@@ -1859,9 +1864,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 				goto advance_sp;
=20
 			skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup,
-						       cache->end_seq,
-						       &fack_count, &reord,
-						       &flag);
+						       &state,
+						       cache->end_seq);
=20
 			/* ...tail remains todo... */
 			if (tcp_highest_sack_seq(tp) =3D=3D cache->end_seq) {
@@ -1869,13 +1873,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
 				skb =3D tcp_highest_sack(sk);
 				if (skb =3D=3D NULL)
 					break;
-				fack_count =3D tp->fackets_out;
+				state.fack_count =3D tp->fackets_out;
 				cache++;
 				goto walk;
 			}
=20
-			skb =3D tcp_sacktag_skip(skb, sk, cache->end_seq,
-					       &fack_count);
+			skb =3D tcp_sacktag_skip(skb, sk, &state, cache->end_seq);
 			/* Check overlap against next cached too (past this one already) */
 			cache++;
 			continue;
@@ -1885,20 +1888,20 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
 			skb =3D tcp_highest_sack(sk);
 			if (skb =3D=3D NULL)
 				break;
-			fack_count =3D tp->fackets_out;
+			state.fack_count =3D tp->fackets_out;
 		}
-		skb =3D tcp_sacktag_skip(skb, sk, start_seq, &fack_count);
+		skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
=20
 walk:
-		skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
-				       dup_sack, &fack_count, &reord, &flag);
+		skb =3D tcp_sacktag_walk(skb, sk, next_dup, &state,
+				       start_seq, end_seq, dup_sack);
=20
 advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
 		 * due to in-order walk
 		 */
 		if (after(end_seq, tp->frto_highmark))
-			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
+			state.flag &=3D ~FLAG_ONLY_ORIG_SACKED;
=20
 		i++;
 	}
@@ -1915,10 +1918,10 @@ advance_sp:
=20
 	tcp_verify_left_out(tp);
=20
-	if ((reord < tp->fackets_out) &&
+	if ((state.reord < tp->fackets_out) &&
 	    ((icsk->icsk_ca_state !=3D TCP_CA_Loss) || tp->undo_marker) &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
-		tcp_update_reordering(sk, tp->fackets_out - reord, 0);
+		tcp_update_reordering(sk, tp->fackets_out - state.reord, 0);
=20
 out:
=20
@@ -1928,7 +1931,7 @@ out:
 	WARN_ON((int)tp->retrans_out < 0);
 	WARN_ON((int)tcp_packets_in_flight(tp) < 0);
 #endif
-	return flag;
+	return state.flag;
 }
=20
 /* Limits sacked_out so that sum with lost_out isn't ever larger than
--=20
1.5.2.2

