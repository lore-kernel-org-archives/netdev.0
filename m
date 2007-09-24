From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/5] [TCP]: Create tcp_sacktag_state.
Date: Mon, 24 Sep 2007 13:28:43 +0300
Message-ID: <11906297272364-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Tom Quetchenbach <virtualphtn@gmail.com>,
	Baruch Even <bar
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52915 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbXIXK2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 06:28:49 -0400
In-Reply-To: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David S. Miller <davem@davemloft.net>

It is difficult to break out the inner-logic of
tcp_sacktag_write_queue() into worker functions because
so many local variables get updated in-place.

Start to overcome this by creating a structure block
of state variables that can be passed around into
worker routines.

[I made minor tweaks due to rebase/reordering of stuff
in tcp-2.6 tree, and dropped found_dup_sack & dup_sack
from state -ij]

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   89 ++++++++++++++++++++++++++----------------=
-------
 1 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 259f517..04ff465 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1102,6 +1102,13 @@ static int tcp_is_sackblock_valid(struct tcp_soc=
k *tp, int is_dsack,
 	return !before(start_seq, end_seq - tp->max_window);
 }
=20
+struct tcp_sacktag_state {
+	unsigned int flag;
+	int reord;
+	int prior_fackets;
+	u32 lost_retrans;
+	int first_sack_index;
+};
=20
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
@@ -1146,25 +1153,22 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	struct tcp_sack_block_wire *sp =3D (struct tcp_sack_block_wire *)(ptr=
+2);
 	struct sk_buff *cached_skb;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
-	int reord =3D tp->packets_out;
-	int prior_fackets;
-	u32 lost_retrans =3D 0;
-	int flag =3D 0;
-	int found_dup_sack =3D 0;
+	struct tcp_sacktag_state state;
+	int found_dup_sack;
 	int cached_fack_count;
 	int i;
-	int first_sack_index;
+	int force_one_sack;
+
+	state.flag =3D 0;
=20
 	if (!tp->sacked_out) {
 		tp->fackets_out =3D 0;
 		tp->highest_sack =3D tp->snd_una;
 	}
-	prior_fackets =3D tp->fackets_out;
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp,
-					 num_sacks, prior_snd_una);
+	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_=
snd_una);
 	if (found_dup_sack)
-		flag |=3D FLAG_DSACKING_ACK;
+		state.flag |=3D FLAG_DSACKING_ACK;
=20
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
@@ -1177,18 +1181,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
-	flag =3D 1;
+	force_one_sack =3D 1;
 	for (i =3D 0; i < num_sacks; i++) {
 		__be32 start_seq =3D sp[i].start_seq;
 		__be32 end_seq =3D sp[i].end_seq;
=20
 		if (i =3D=3D 0) {
 			if (tp->recv_sack_cache[i].start_seq !=3D start_seq)
-				flag =3D 0;
+				force_one_sack =3D 0;
 		} else {
 			if ((tp->recv_sack_cache[i].start_seq !=3D start_seq) ||
 			    (tp->recv_sack_cache[i].end_seq !=3D end_seq))
-				flag =3D 0;
+				force_one_sack =3D 0;
 		}
 		tp->recv_sack_cache[i].start_seq =3D start_seq;
 		tp->recv_sack_cache[i].end_seq =3D end_seq;
@@ -1199,8 +1203,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		tp->recv_sack_cache[i].end_seq =3D 0;
 	}
=20
-	first_sack_index =3D 0;
-	if (flag)
+	state.first_sack_index =3D 0;
+	if (force_one_sack)
 		num_sacks =3D 1;
 	else {
 		int j;
@@ -1218,17 +1222,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 					sp[j+1] =3D tmp;
=20
 					/* Track where the first SACK block goes to */
-					if (j =3D=3D first_sack_index)
-						first_sack_index =3D j+1;
+					if (j =3D=3D state.first_sack_index)
+						state.first_sack_index =3D j+1;
 				}
=20
 			}
 		}
 	}
=20
-	/* clear flag as used for different purpose in following code */
-	flag =3D 0;
-
 	/* Use SACK fastpath hint if valid */
 	cached_skb =3D tp->fastpath_skb_hint;
 	cached_fack_count =3D tp->fastpath_cnt_hint;
@@ -1237,12 +1238,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 		cached_fack_count =3D 0;
 	}
=20
+	state.reord =3D tp->packets_out;
+	state.prior_fackets =3D tp->fackets_out;
+	state.lost_retrans =3D 0;
+
 	for (i=3D0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq =3D ntohl(sp->start_seq);
 		__u32 end_seq =3D ntohl(sp->end_seq);
 		int fack_count;
-		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
+		int dup_sack =3D (found_dup_sack && (i =3D=3D state.first_sack_index=
));
=20
 		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
 			if (dup_sack) {
@@ -1265,7 +1270,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
-			flag |=3D FLAG_DATA_LOST;
+			state.flag |=3D FLAG_DATA_LOST;
=20
 		tcp_for_write_queue_from(skb, sk) {
 			int in_sack, pcount;
@@ -1276,7 +1281,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 			cached_skb =3D skb;
 			cached_fack_count =3D fack_count;
-			if (i =3D=3D first_sack_index) {
+			if (i =3D=3D state.first_sack_index) {
 				tp->fastpath_skb_hint =3D skb;
 				tp->fastpath_cnt_hint =3D fack_count;
 			}
@@ -1325,12 +1330,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 				if (sacked&TCPCB_RETRANS) {
 					if ((dup_sack && in_sack) &&
 					    (sacked&TCPCB_SACKED_ACKED))
-						reord =3D min(fack_count, reord);
+						state.reord =3D min(fack_count, state.reord);
 				} else {
 					/* If it was in a hole, we detected reordering. */
-					if (fack_count < prior_fackets &&
+					if (fack_count < state.prior_fackets &&
 					    !(sacked&TCPCB_SACKED_ACKED))
-						reord =3D min(fack_count, reord);
+						state.reord =3D min(fack_count, state.reord);
 				}
=20
 				/* Nothing to do; acked frame is about to be dropped. */
@@ -1339,8 +1344,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 			if ((sacked&TCPCB_SACKED_RETRANS) &&
 			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!lost_retrans || after(end_seq, lost_retrans)))
-				lost_retrans =3D end_seq;
+			    (!state.lost_retrans || after(end_seq, state.lost_retrans)))
+				state.lost_retrans =3D end_seq;
=20
 			if (!in_sack)
 				continue;
@@ -1364,8 +1369,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 					 * which was in hole. It is reordering.
 					 */
 					if (!(sacked & TCPCB_RETRANS) &&
-					    fack_count < prior_fackets)
-						reord =3D min(fack_count, reord);
+					    fack_count < state.prior_fackets)
+						state.reord =3D min(fack_count, state.reord);
=20
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
@@ -1381,15 +1386,15 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 					 * Clearing correct due to in-order walk
 					 */
 					if (after(end_seq, tp->frto_highmark)) {
-						flag &=3D ~FLAG_ONLY_ORIG_SACKED;
+						state.flag &=3D ~FLAG_ONLY_ORIG_SACKED;
 					} else {
 						if (!(sacked & TCPCB_RETRANS))
-							flag |=3D FLAG_ONLY_ORIG_SACKED;
+							state.flag |=3D FLAG_ONLY_ORIG_SACKED;
 					}
 				}
=20
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
-				flag |=3D FLAG_DATA_SACKED;
+				state.flag |=3D FLAG_DATA_SACKED;
 				tp->sacked_out +=3D tcp_skb_pcount(skb);
=20
 				if (fack_count > tp->fackets_out)
@@ -1400,7 +1405,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 					tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
-					reord =3D min(fack_count, reord);
+					state.reord =3D min(fack_count, state.reord);
 			}
=20
 			/* D-SACK. We can detect redundant retransmission
@@ -1423,20 +1428,20 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	 * we have to account for reordering! Ugly,
 	 * but should help.
 	 */
-	if (lost_retrans && icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
+	if (state.lost_retrans && icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)=
 {
 		struct sk_buff *skb;
=20
 		tcp_for_write_queue(skb, sk) {
 			if (skb =3D=3D tcp_send_head(sk))
 				break;
-			if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
+			if (after(TCP_SKB_CB(skb)->seq, state.lost_retrans))
 				break;
 			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 				continue;
 			if ((TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
-			    after(lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
+			    after(state.lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
 			    (tcp_is_fack(tp) ||
-			     !before(lost_retrans,
+			     !before(state.lost_retrans,
 				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
 				     tp->mss_cache))) {
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
@@ -1448,7 +1453,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				if (!(TCP_SKB_CB(skb)->sacked&(TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 					tp->lost_out +=3D tcp_skb_pcount(skb);
 					TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
-					flag |=3D FLAG_DATA_SACKED;
+					state.flag |=3D FLAG_DATA_SACKED;
 					NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 				}
 			}
@@ -1457,9 +1462,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
=20
 	tcp_verify_left_out(tp);
=20
-	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Loss=
 &&
+	if ((state.reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_C=
A_Loss &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
-		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
+		tcp_update_reordering(sk, ((tp->fackets_out + 1) - state.reord), 0);
=20
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >=3D 0);
@@ -1467,7 +1472,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	BUG_TRAP((int)tp->retrans_out >=3D 0);
 	BUG_TRAP((int)tcp_packets_in_flight(tp) >=3D 0);
 #endif
-	return flag;
+	return state.flag;
 }
=20
 /* F-RTO can only be used if TCP has never retransmitted anything othe=
r than
--=20
1.5.0.6

