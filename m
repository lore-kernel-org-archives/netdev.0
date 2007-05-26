From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 9/9] [RFC] [TCP]: Kill tp->fackets_out (tcp_sock diet program)
Date: Sat, 26 May 2007 11:36:02 +0300
Message-ID: <1180168562815-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi> <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi> <1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40613 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515AbXEZIgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:11 -0400
In-Reply-To: <1180168562524-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

The replacement fastpath uses arithmetics to find out fackets_out
(or a necessary subset of it) when the sizes are less than MSS
off from MSS*packets_out. Slowpath walks through the write queue.

Saves some space in tcp_sock. Both fackets_out and SACK
processing fack count hint can be removed right away. However,
this also enables further improvements to SACK processing since
strict ordering constraints due to fack counting are removed,
e.g., the highest_sack might be useful replacement for the skb
hint (we should measure this at some real server, e.g., by adding
mib counts or so to see how often highest_sack and fastpath skb
hint really point to a different thing; I suspect that's being
really marginal proportion if that ever occurs).

Negative side:
- Sending many data segments with SACK blocks (bi-dir flow and
losses at the same round-trip for both directions) can cause TCP
to need slow path.
- No-Nagler will take a great hit but that's what they're
asking for...

Unsolved issues:
- MSS shrinkage must be handled without failure in arithmetics.
Either run tcp_fragment for every too large skb (which is not
going to be a safe alternative since allocs can fail) or somehow
force slow path (so far I haven't found a solution that would
consume less than u32 seqno in tcp_sock)!
- ...A number of potential off by one (or by MSS in this case)
places haven't yet been triple checked...

Enhancement ideas:
- It might be possible to extend fastpath by checking if snd_sml
is below / above highest_sack (could allow to up 2*MSS off case
using fast path)...

All in all, very scary patch. Please do not apply. This is not
yet completely thought one.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h      |    2 -
 include/net/tcp.h        |    1 +
 net/ipv4/tcp.c           |    2 +-
 net/ipv4/tcp_input.c     |  216 +++++++++++++++++++++++++++++++++-----=
--------
 net/ipv4/tcp_minisocks.c |    1 -
 net/ipv4/tcp_output.c    |   22 ++----
 6 files changed, 162 insertions(+), 82 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1ce9fd4..d4ecb1f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -341,14 +341,12 @@ struct tcp_sock {
 	struct sk_buff *forward_skb_hint;
 	struct sk_buff *fastpath_skb_hint;
=20
-	int     fastpath_cnt_hint;
 	int     retransmit_cnt_hint;
=20
 	u16	advmss;		/* Advertised MSS			*/
 	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	lost_out;	/* Lost packets			*/
 	u32	sacked_out;	/* SACK'd packets			*/
-	u32	fackets_out;	/* FACK'd packets			*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
=20
 	u32	retrans_stamp;	/* Timestamp of the last retransmit,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5255d51..f96a466 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -359,6 +359,7 @@ extern int			tcp_use_frto(struct sock *sk);
 extern void			tcp_enter_frto(struct sock *sk);
 extern void			tcp_enter_loss(struct sock *sk, int how);
 extern void			tcp_clear_retrans(struct tcp_sock *tp);
+extern int			tcp_calc_fackets_out(struct sock *sk);
 extern void			tcp_update_metrics(struct sock *sk);
=20
 extern void			tcp_close(struct sock *sk,=20
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd4c295..3f9a021 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2020,7 +2020,7 @@ void tcp_get_info(struct sock *sk, struct tcp_inf=
o *info)
 	info->tcpi_sacked =3D tp->sacked_out;
 	info->tcpi_lost =3D tp->lost_out;
 	info->tcpi_retrans =3D tp->retrans_out;
-	info->tcpi_fackets =3D tp->fackets_out;
+	info->tcpi_fackets =3D tcp_calc_fackets_out(sk);
=20
 	info->tcpi_last_data_sent =3D jiffies_to_msecs(now - tp->lsndtime);
 	info->tcpi_last_data_recv =3D jiffies_to_msecs(now - icsk->icsk_ack.l=
rcvtime);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9c12c90..02cb546 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -913,6 +913,82 @@ reset:
 	}
 }
=20
+static u32 tcp_expected_fullsized(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct inet_connection_sock *icsk =3D inet_csk(sk);
+	u32 expected_size;
+
+	expected_size =3D tp->packets_out * tp->mss_cache;
+	if (icsk->icsk_mtup.probe_size)
+		expected_size +=3D icsk->icsk_mtup.probe_size - tp->mss_cache;
+
+	return expected_size;
+}
+
+static u32 tcp_missing_from_fullsized(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	return tcp_expected_fullsized(sk) - (tp->snd_nxt - tp->snd_una);
+}
+
+/* Returns 1 if less than MSS bytes are missing (off from fullsized
+ * segments). Under such conditions, simple aritmetics can be used to
+ * calculate segment boundaries cheaply (without write_queue walking).
+ *
+ * Idea: range_almost_fullsized could be do to allows even 2*MSS off
+ * cases, not with 100% coverage though, as it's possible exclude one
+ * additional non-MSS sized skb by checking if snd_sml is outside the
+ * range.
+ */
+static int tcp_win_almost_fullsized(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	return tcp_missing_from_fullsized(sk) < tp->mss_cache;
+}
+
+/* Figures out the pcount between skb and end_seq, skb =3D=3D NULL mea=
ns head.
+ * in_pkts controls the return format (pcount/bytes). To limit walk le=
ngths,
+ * also maxval is provided (set to packets_out if nothing else is vali=
d).
+ *
+ * Fastpath: use arithmetic
+ * Slowpath: walk skbs
+ */
+static int tcp_size_pkts(struct sock *sk, struct sk_buff *skb,=20
+			 u32 end_seq, int maxiter, int in_pkts)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u32 size;
+
+	if (!tp->packets_out)
+		return 0;
+	if (skb =3D=3D NULL)
+		skb =3D tcp_write_queue_head(sk);
+	if (TCP_SKB_CB(skb)->seq =3D=3D end_seq)
+		return 0;
+
+	if (tcp_win_almost_fullsized(sk)) {
+		size =3D end_seq + tp->mss_cache - TCP_SKB_CB(skb)->seq;
+		if (in_pkts)
+			size =3D DIV_ROUND_UP(size, tp->mss_cache);
+
+	} else {
+		size =3D 0;
+		tcp_for_write_queue_from(skb, sk) {
+			size +=3D tcp_skb_pcount(skb);
+			if (!before(TCP_SKB_CB(skb)->seq, end_seq) ||
+			    (size >=3D maxiter))
+				break;
+		}
+		if (!in_pkts)
+			size *=3D tp->mss_cache;
+	}
+
+	return size;
+}				 =20
+
 static void tcp_update_reordering(struct sock *sk, const int metric,
 				  const int ts)
 {
@@ -930,10 +1006,9 @@ static void tcp_update_reordering(struct sock *sk=
, const int metric,
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPSACKREORDER);
 #if FASTRETRANS_DEBUG > 1
-		printk(KERN_DEBUG "Disorder%d %d %u f%u s%u rr%d\n",
+		printk(KERN_DEBUG "Disorder%d %d %u s%u rr%d\n",
 		       tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
 		       tp->reordering,
-		       tp->fackets_out,
 		       tp->sacked_out,
 		       tp->undo_marker ? tp->undo_retrans : 0);
 #endif
@@ -993,12 +1068,20 @@ static void tcp_update_reordering(struct sock *s=
k, const int metric,
 struct tcp_sacktag_state {
 	unsigned int flag;
 	int dup_sack;
-	int reord;
-	int prior_fackets;
+	struct sk_buff *reord;
 	u32 lost_retrans;
+	u32 prior_hisack;
 	int first_sack_index;
 };
=20
+static void tcp_skb_reordered(struct tcp_sacktag_state *state,=20
+			      struct sk_buff *skb)
+{
+	if ((state->reord =3D=3D NULL) ||
+	    before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(state->reord)->seq))
+		state->reord =3D skb;
+}
+
 static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
@@ -1034,7 +1117,7 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
=20
 static void tcp_sacktag_one(struct sk_buff *skb, struct tcp_sock *tp,
 			    struct tcp_sacktag_state *state, int in_sack,
-			    int fack_count, u32 end_seq)
+			    u32 end_seq)
 {
 	u8 sacked =3D TCP_SKB_CB(skb)->sacked;
=20
@@ -1049,12 +1132,12 @@ static void tcp_sacktag_one(struct sk_buff *skb=
, struct tcp_sock *tp,
 		if (sacked & TCPCB_RETRANS) {
 			if ((state->dup_sack && in_sack) &&
 			    (sacked & TCPCB_SACKED_ACKED))
-				state->reord =3D min(fack_count, state->reord);
+				tcp_skb_reordered(state, skb);
 		} else {
 			/* If it was in a hole, we detected reordering. */
-			if (fack_count < state->prior_fackets &&
+			if (before(TCP_SKB_CB(skb)->seq, state->prior_hisack) &&
 			    !(sacked & TCPCB_SACKED_ACKED))
-				state->reord =3D min(fack_count, state->reord);
+				tcp_skb_reordered(state, skb);
 		}
=20
 		/* Nothing to do; acked frame is about to be dropped. */
@@ -1089,8 +1172,8 @@ static void tcp_sacktag_one(struct sk_buff *skb, =
struct tcp_sock *tp,
 			 * which was in hole. It is reordering.
 			 */
 			if (!(sacked & TCPCB_RETRANS) &&
-			    fack_count < state->prior_fackets)
-				state->reord =3D min(fack_count, state->reord);
+			    before(TCP_SKB_CB(skb)->seq, state->prior_hisack))
+				tcp_skb_reordered(state, skb);
=20
 			if (sacked & TCPCB_LOST) {
 				TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_LOST;
@@ -1117,16 +1200,11 @@ static void tcp_sacktag_one(struct sk_buff *skb=
, struct tcp_sock *tp,
 		state->flag |=3D FLAG_DATA_SACKED;
 		tp->sacked_out +=3D tcp_skb_pcount(skb);
=20
-		if (fack_count > tp->fackets_out)
-			tp->fackets_out =3D fack_count;
-
 		if (after(TCP_SKB_CB(skb)->seq,
 			  tp->highest_sack))
 			tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
-	} else {
-		if (state->dup_sack && (sacked&TCPCB_RETRANS))
-			state->reord =3D min(fack_count, state->reord);
-	}
+	} else if (state->dup_sack && (sacked&TCPCB_RETRANS))
+		tcp_skb_reordered(state, skb);
=20
 	/* D-SACK. We can detect redundant retransmission
 	 * in S|R and plain R frames and clear it.
@@ -1153,14 +1231,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
 	struct sk_buff *cached_skb;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	struct tcp_sacktag_state state;
-	int cached_fack_count;
 	int i;
 	int force_one_sack;
=20
-	if (!tp->sacked_out) {
-		tp->fackets_out =3D 0;
+	if (!tp->sacked_out)
 		tp->highest_sack =3D tp->snd_una;
-	} else
+	else
 		*mark_lost_entry_seq =3D tp->highest_sack;
=20
 	state.dup_sack =3D tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_=
snd_una);
@@ -1227,25 +1303,20 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb,
=20
 	/* Use SACK fastpath hint if valid */
 	cached_skb =3D tp->fastpath_skb_hint;
-	cached_fack_count =3D tp->fastpath_cnt_hint;
-	if (!cached_skb) {
+	if (!cached_skb)
 		cached_skb =3D tcp_write_queue_head(sk);
-		cached_fack_count =3D 0;
-	}
=20
 	state.flag =3D 0;
-	state.reord =3D tp->packets_out;
-	state.prior_fackets =3D tp->fackets_out;
+	state.reord =3D NULL;
+	state.prior_hisack =3D tp->highest_sack;
 	state.lost_retrans =3D 0;
=20
 	for (i=3D0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq =3D ntohl(sp->start_seq);
 		__u32 end_seq =3D ntohl(sp->end_seq);
-		int fack_count;
=20
 		skb =3D cached_skb;
-		fack_count =3D cached_fack_count;
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1258,11 +1329,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 				break;
=20
 			cached_skb =3D skb;
-			cached_fack_count =3D fack_count;
-			if (i =3D=3D state.first_sack_index) {
+			if (i =3D=3D state.first_sack_index)
 				tp->fastpath_skb_hint =3D skb;
-				tp->fastpath_cnt_hint =3D fack_count;
-			}
=20
 			/* The retransmission queue is always in order, so
 			 * we can short-circuit the walk early.
@@ -1293,10 +1361,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 				pcount =3D tcp_skb_pcount(skb);
 			}
=20
-			fack_count +=3D pcount;
-
-			tcp_sacktag_one(skb, tp, &state, in_sack,
-					fack_count, end_seq);
+			tcp_sacktag_one(skb, tp, &state, in_sack, end_seq);
 		}
=20
 		/* Prepare non-reno LOST marking fast path entry point, the
@@ -1351,9 +1416,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 		}
 	}
=20
-	if ((state.reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_C=
A_Loss &&
-	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
-		tcp_update_reordering(sk, ((tp->fackets_out + 1) - state.reord), 0);
+	if ((state.reord !=3D NULL) && icsk->icsk_ca_state !=3D TCP_CA_Loss &=
&
+	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark))) {
+		int reord_cnt;
+		BUG_ON(after(TCP_SKB_CB(state.reord)->seq, tp->highest_sack));
+
+		reord_cnt =3D tcp_size_pkts(sk, state.reord,
+					  tp->highest_sack + tp->mss_cache,
+					  TCP_MAX_REORDERING, 1);
+		tcp_update_reordering(sk, reord_cnt, 0);
+	}
=20
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >=3D 0);
@@ -1575,7 +1647,6 @@ void tcp_clear_retrans(struct tcp_sock *tp)
 {
 	tp->retrans_out =3D 0;
=20
-	tp->fackets_out =3D 0;
 	tp->sacked_out =3D 0;
 	tp->lost_out =3D 0;
=20
@@ -1626,7 +1697,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 			tp->lost_out +=3D tcp_skb_pcount(skb);
 		} else {
 			tp->sacked_out +=3D tcp_skb_pcount(skb);
-			tp->fackets_out =3D cnt;
 		}
 	}
 	tcp_sync_left_out(tp);
@@ -1667,10 +1737,26 @@ static int tcp_check_sack_reneging(struct sock =
*sk)
 	return 0;
 }
=20
-static inline int tcp_fackets_out(struct tcp_sock *tp)
+
+
+int tcp_calc_fackets_out(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (IsReno(tp))
+		return tp->sacked_out + 1;
+
+	return tcp_size_pkts(sk, NULL, tp->highest_sack, tp->packets_out, 1);
+}
+
+static inline int tcp_enough_reordering(struct sock *sk)
 {
-	return (IsReno(tp) || Is3517Sack(tp)) ? tp->sacked_out + 1 :
-						tp->fackets_out;
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (!IsFack(tp))
+		return (tp->sacked_out + 1) * tp->mss_cache;
+
+	return tcp_size_pkts(sk, NULL, tp->highest_sack, tp->reordering, 0);
 }
=20
 static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *sk=
b)
@@ -1793,7 +1879,8 @@ static int tcp_time_to_recover(struct sock *sk)
 		return 1;
=20
 	/* Not-A-Trick#2 : Classic rule... */
-	if (tcp_fackets_out(tp) > tp->reordering)
+	/* CHECKME: off-by-one? */
+	if (tcp_enough_reordering(sk) > tp->reordering * tp->mss_cache)
 		return 1;
=20
 	/* Trick#3 : when we use RFC2988 timer restart, fast
@@ -1912,6 +1999,16 @@ struct sk_buff *tcp_update_scoreboard_fack(struc=
t sock *sk, u32 entry_seq,
 	struct sk_buff *timedout_continue =3D NULL;
 	struct sk_buff *skb;
 	unsigned int holes_seen =3D 0;
+	u32 fackets_out;
+=09
+	/* fackets_out is calculated only when it's cheap, in other cases
+	 * we just overestimate it which keeps our arithmetic valid
+	 */
+	if (tcp_win_almost_fullsized(sk))
+		fackets_out =3D tcp_size_pkts(sk, NULL, tp->highest_sack,
+					    tp->packets_out, 0);
+	else
+		fackets_out =3D tp->packets_out * tp->mss_cache;
=20
 	if (entry_seq !=3D tp->highest_sack) {
 		/* Look for skb below min_seq(entry_seq, tp->high_seq) */
@@ -1924,7 +2021,9 @@ struct sk_buff *tcp_update_scoreboard_fack(struct=
 sock *sk, u32 entry_seq,
=20
 		timedout_continue =3D NULL;
 		if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
-		    (tp->fackets_out < tp->packets_out)) {
+		    (!(before(tp->snd_sml,  tp->highest_sack) ||
+		       tcp_win_almost_fullsized(sk)) ||
+		     tp->highest_sack + tp->mss_cache < tp->snd_nxt)) {
 			timedout_continue =3D tcp_write_queue_next(sk, skb);
 		    	if (!after(entry_seq, tp->high_seq)) {
 				/* Use latest SACK info in skipping past skbs */
@@ -1942,8 +2041,8 @@ struct sk_buff *tcp_update_scoreboard_fack(struct=
 sock *sk, u32 entry_seq,
=20
 		/* Phase I: Search until TCP can mark */
 		tcp_for_write_queue_backwards_from(skb, sk) {
-			if ((tp->fackets_out <=3D tp->sacked_out + tp->lost_out +
-						holes_seen) ||
+			if ((fackets_out <=3D (tp->sacked_out + tp->lost_out +
+					     holes_seen) * tp->mss_cache) ||
 			    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
 				goto backwards_walk_done;
=20
@@ -1975,8 +2074,8 @@ struct sk_buff *tcp_update_scoreboard_fack(struct=
 sock *sk, u32 entry_seq,
=20
 	/* Phase II: Marker */
 	tcp_for_write_queue_backwards_from(skb, sk) {
-		if ((tp->fackets_out <=3D tp->sacked_out + tp->lost_out +
-					holes_seen) ||
+		if ((fackets_out <=3D (tp->sacked_out + tp->lost_out +
+				     holes_seen) * tp->mss_cache) ||
 		    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
 			goto backwards_walk_done;
=20
@@ -2168,7 +2267,8 @@ static int tcp_try_undo_partial(struct sock *sk, =
int acked)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed =3D IsReno(tp) || (tcp_fackets_out(tp) > tp->reordering);
+	int failed =3D IsReno(tp) ||
+		(tcp_enough_reordering(sk) > tp->reordering * tp->mss_cache);
=20
 	if (tcp_may_undo(tp)) {
 		/* Plain luck! Hole if filled with delayed
@@ -2177,7 +2277,7 @@ static int tcp_try_undo_partial(struct sock *sk, =
int acked)
 		if (tp->retrans_out =3D=3D 0)
 			tp->retrans_stamp =3D 0;
=20
-		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
+		tcp_update_reordering(sk, tcp_calc_fackets_out(sk) + acked, 1);
=20
 		DBGUNDO(sk, "Hoe");
 		tcp_undo_cwr(sk, 0);
@@ -2306,9 +2406,6 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
 	if (!tp->packets_out)
 		tp->sacked_out =3D 0;
-	/* 2. SACK counts snd_fack in packets inaccurately. */
-	if (tp->sacked_out =3D=3D 0)
-		tp->fackets_out =3D 0;
=20
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
@@ -2323,7 +2420,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
 	if (IsFack(tp) && (flag&FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
-	    tp->fackets_out > tp->reordering) {
+	    tcp_enough_reordering(sk) > tp->reordering * tp->mss_cache) {
 		tcp_update_scoreboard_fack(sk, mark_lost_entry_seq, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
@@ -2577,10 +2674,6 @@ static int tcp_tso_acked(struct sock *sk, struct=
 sk_buff *skb,
 		} else if (*seq_rtt < 0)
 			*seq_rtt =3D now - scb->when;
=20
-		if (tp->fackets_out) {
-			__u32 dval =3D min(tp->fackets_out, packets_acked);
-			tp->fackets_out -=3D dval;
-		}
 		tp->packets_out -=3D packets_acked;
=20
 		BUG_ON(tcp_skb_pcount(skb) =3D=3D 0);
@@ -2665,7 +2758,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 			seq_rtt =3D now - scb->when;
 			last_ackt =3D skb->tstamp;
 		}
-		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tcp_packets_out_dec(tp, skb);
 		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ad4f36..44f548d 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -407,7 +407,6 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->packets_out =3D 0;
 		newtp->retrans_out =3D 0;
 		newtp->sacked_out =3D 0;
-		newtp->fackets_out =3D 0;
 		newtp->snd_ssthresh =3D 0x7fffffff;
=20
 		/* So many TCP implementations out there (incorrectly) count the
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 23ee283..1753683 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -735,18 +735,12 @@ int tcp_fragment(struct sock *sk, struct sk_buff =
*skb, u32 len, unsigned int mss
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
 			tp->lost_out -=3D diff;
=20
-		if (diff > 0) {
-			/* Adjust Reno SACK estimate. */
-			if (!tp->rx_opt.sack_ok) {
-				tp->sacked_out -=3D diff;
-				if ((int)tp->sacked_out < 0)
-					tp->sacked_out =3D 0;
-				tcp_sync_left_out(tp);
-			}
-
-			tp->fackets_out -=3D diff;
-			if ((int)tp->fackets_out < 0)
-				tp->fackets_out =3D 0;
+		/* Adjust Reno SACK estimate. */
+		if (diff > 0 && !tp->rx_opt.sack_ok) {
+			tp->sacked_out -=3D diff;
+			if ((int)tp->sacked_out < 0)
+				tp->sacked_out =3D 0;
+			tcp_sync_left_out(tp);
 		}
 	}
=20
@@ -1729,10 +1723,6 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
 		if (!tp->rx_opt.sack_ok && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
=20
-		/* Not quite right: it can be > snd.fack, but
-		 * it is better to underestimate fackets.
-		 */
-		tcp_dec_pcount_approx(&tp->fackets_out, next_skb);
 		tcp_packets_out_dec(tp, next_skb);
 		sk_stream_free_skb(sk, next_skb);
 	}
--=20
1.5.0.6

