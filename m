From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Make sacktag logic splittable...
Date: Wed, 28 Mar 2007 17:19:37 -0700 (PDT)
Message-ID: <20070328.171937.91314357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933925AbXC2ATi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 20:19:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BBAA5AE41A5
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 17:19:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It's nearly impossible to break out tcp_sacktag_write_queue() into
smaller worker functions because there are so many local variables
that are live and updated throughout the inner loop and beyond.

So create a state block so we can start simplifying this function
properly.

Pushed to net-2.6.22

commit eb7723322ccc43f19714ac83395e5204fee0e5b8
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Mar 28 17:17:19 2007 -0700

    [TCP]: Create tcp_sacktag_state.
    
    It is difficult to break out the inner-logic of
    tcp_sacktag_write_queue() into worker functions because
    so many local variables get updated in-place.
    
    Start to overcome this by creating a structure block
    of state variables that can be passed around into
    worker routines.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5a8987..464dc80 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -936,6 +936,15 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
  * Both of these heuristics are not used in Loss state, when we cannot
  * account for retransmits accurately.
  */
+struct tcp_sacktag_state {
+	unsigned int flag;
+	int dup_sack;
+	int reord;
+	int prior_fackets;
+	u32 lost_retrans;
+	int first_sack_index;
+};
+
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
@@ -980,23 +989,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	struct tcp_sack_block_wire *sp = (struct tcp_sack_block_wire *)(ptr+2);
 	struct sk_buff *cached_skb;
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
-	int reord = tp->packets_out;
-	int prior_fackets;
-	u32 lost_retrans = 0;
-	int flag = 0;
-	int dup_sack = 0;
+	struct tcp_sacktag_state state;
 	int cached_fack_count;
 	int i;
-	int first_sack_index;
+	int force_one_sack;
 
 	if (!tp->sacked_out) {
 		tp->fackets_out = 0;
 		tp->highest_sack = tp->snd_una;
 	} else
 		*mark_lost_entry_seq = tp->highest_sack;
-	prior_fackets = tp->fackets_out;
 
-	dup_sack = tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_snd_una);
+	state.dup_sack = tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_snd_una);
 
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
@@ -1009,18 +1013,18 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
-	flag = 1;
+	force_one_sack = 1;
 	for (i = 0; i < num_sacks; i++) {
 		__be32 start_seq = sp[i].start_seq;
 		__be32 end_seq = sp[i].end_seq;
 
 		if (i == 0) {
 			if (tp->recv_sack_cache[i].start_seq != start_seq)
-				flag = 0;
+				force_one_sack = 0;
 		} else {
 			if ((tp->recv_sack_cache[i].start_seq != start_seq) ||
 			    (tp->recv_sack_cache[i].end_seq != end_seq))
-				flag = 0;
+				force_one_sack = 0;
 		}
 		tp->recv_sack_cache[i].start_seq = start_seq;
 		tp->recv_sack_cache[i].end_seq = end_seq;
@@ -1031,8 +1035,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 		tp->recv_sack_cache[i].end_seq = 0;
 	}
 
-	first_sack_index = 0;
-	if (flag)
+	state.first_sack_index = 0;
+	if (force_one_sack)
 		num_sacks = 1;
 	else {
 		int j;
@@ -1050,17 +1054,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 					sp[j+1] = tmp;
 
 					/* Track where the first SACK block goes to */
-					if (j == first_sack_index)
-						first_sack_index = j+1;
+					if (j == state.first_sack_index)
+						state.first_sack_index = j+1;
 				}
 
 			}
 		}
 	}
 
-	/* clear flag as used for different purpose in following code */
-	flag = 0;
-
 	/* Use SACK fastpath hint if valid */
 	cached_skb = tp->fastpath_skb_hint;
 	cached_fack_count = tp->fastpath_cnt_hint;
@@ -1069,6 +1070,11 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 		cached_fack_count = 0;
 	}
 
+	state.flag = 0;
+	state.reord = tp->packets_out;
+	state.prior_fackets = tp->fackets_out;
+	state.lost_retrans = 0;
+
 	for (i=0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq = ntohl(sp->start_seq);
@@ -1080,7 +1086,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
-			flag |= FLAG_DATA_LOST;
+			state.flag |= FLAG_DATA_LOST;
 
 		tcp_for_write_queue_from(skb, sk) {
 			int in_sack, pcount;
@@ -1091,7 +1097,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 			cached_skb = skb;
 			cached_fack_count = fack_count;
-			if (i == first_sack_index) {
+			if (i == state.first_sack_index) {
 				tp->fastpath_skb_hint = skb;
 				tp->fastpath_cnt_hint = fack_count;
 			}
@@ -1130,7 +1136,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 			sacked = TCP_SKB_CB(skb)->sacked;
 
 			/* Account D-SACK for retransmitted packet. */
-			if ((dup_sack && in_sack) &&
+			if ((state.dup_sack && in_sack) &&
 			    (sacked & TCPCB_RETRANS) &&
 			    after(TCP_SKB_CB(skb)->end_seq, tp->undo_marker))
 				tp->undo_retrans--;
@@ -1138,14 +1144,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 			/* The frame is ACKed. */
 			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una)) {
 				if (sacked&TCPCB_RETRANS) {
-					if ((dup_sack && in_sack) &&
+					if ((state.dup_sack && in_sack) &&
 					    (sacked&TCPCB_SACKED_ACKED))
-						reord = min(fack_count, reord);
+						state.reord = min(fack_count, state.reord);
 				} else {
 					/* If it was in a hole, we detected reordering. */
-					if (fack_count < prior_fackets &&
+					if (fack_count < state.prior_fackets &&
 					    !(sacked&TCPCB_SACKED_ACKED))
-						reord = min(fack_count, reord);
+						state.reord = min(fack_count, state.reord);
 				}
 
 				/* Nothing to do; acked frame is about to be dropped. */
@@ -1154,8 +1160,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 			if ((sacked&TCPCB_SACKED_RETRANS) &&
 			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!lost_retrans || after(end_seq, lost_retrans)))
-				lost_retrans = end_seq;
+			    (!state.lost_retrans || after(end_seq, state.lost_retrans)))
+				state.lost_retrans = end_seq;
 
 			if (!in_sack)
 				continue;
@@ -1179,8 +1185,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 					 * which was in hole. It is reordering.
 					 */
 					if (!(sacked & TCPCB_RETRANS) &&
-					    fack_count < prior_fackets)
-						reord = min(fack_count, reord);
+					    fack_count < state.prior_fackets)
+						state.reord = min(fack_count, state.reord);
 
 					if (sacked & TCPCB_LOST) {
 						TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
@@ -1196,15 +1202,15 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 					 * Clearing correct due to in-order walk
 					 */
 					if (after(end_seq, tp->frto_highmark)) {
-						flag &= ~FLAG_ONLY_ORIG_SACKED;
+						state.flag &= ~FLAG_ONLY_ORIG_SACKED;
 					} else {
 						if (!(sacked & TCPCB_RETRANS))
-							flag |= FLAG_ONLY_ORIG_SACKED;
+							state.flag |= FLAG_ONLY_ORIG_SACKED;
 					}
 				}
 
 				TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
-				flag |= FLAG_DATA_SACKED;
+				state.flag |= FLAG_DATA_SACKED;
 				tp->sacked_out += tcp_skb_pcount(skb);
 
 				if (fack_count > tp->fackets_out)
@@ -1214,8 +1220,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 				    tp->highest_sack))
 					tp->highest_sack = TCP_SKB_CB(skb)->seq;
 			} else {
-				if (dup_sack && (sacked&TCPCB_RETRANS))
-					reord = min(fack_count, reord);
+				if (state.dup_sack && (sacked&TCPCB_RETRANS))
+					state.reord = min(fack_count, state.reord);
 			}
 
 			/* D-SACK. We can detect redundant retransmission
@@ -1223,7 +1229,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 			 * undo_retrans is decreased above, L|R frames
 			 * are accounted above as well.
 			 */
-			if (dup_sack &&
+			if (state.dup_sack &&
 			    (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS)) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 				tp->retrans_out -= tcp_skb_pcount(skb);
@@ -1251,20 +1257,20 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	 * we have to account for reordering! Ugly,
 	 * but should help.
 	 */
-	if (IsFack(tp) && lost_retrans && icsk->icsk_ca_state == TCP_CA_Recovery) {
+	if (IsFack(tp) && state.lost_retrans && icsk->icsk_ca_state == TCP_CA_Recovery) {
 		struct sk_buff *skb;
 
 		tcp_for_write_queue(skb, sk) {
 			if (skb == tcp_send_head(sk))
 				break;
-			if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
+			if (after(TCP_SKB_CB(skb)->seq, state.lost_retrans))
 				break;
 			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 				continue;
 			if ((TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
-			    after(lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
+			    after(state.lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
 			    (IsFack(tp) ||
-			     !before(lost_retrans,
+			     !before(state.lost_retrans,
 				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
 				     tp->mss_cache))) {
 				TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
@@ -1276,7 +1282,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 				if (!(TCP_SKB_CB(skb)->sacked&(TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 					tp->lost_out += tcp_skb_pcount(skb);
 					TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-					flag |= FLAG_DATA_SACKED;
+					state.flag |= FLAG_DATA_SACKED;
 					NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 				}
 			}
@@ -1285,9 +1291,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 
 	tp->left_out = tp->sacked_out + tp->lost_out;
 
-	if ((reord < tp->fackets_out) && icsk->icsk_ca_state != TCP_CA_Loss &&
+	if ((state.reord < tp->fackets_out) && icsk->icsk_ca_state != TCP_CA_Loss &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
-		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
+		tcp_update_reordering(sk, ((tp->fackets_out + 1) - state.reord), 0);
 
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
@@ -1295,7 +1301,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	BUG_TRAP((int)tp->retrans_out >= 0);
 	BUG_TRAP((int)tcp_packets_in_flight(tp) >= 0);
 #endif
-	return flag;
+	return state.flag;
 }
 
 /* F-RTO can only be used if these conditions are satisfied:
