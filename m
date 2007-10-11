From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 5/6] [TCP]: Rewrite sack_recv_cache (WIP)
Date: Thu, 11 Oct 2007 15:21:57 +0300
Message-ID: <11921053181933-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11921053182989-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181239-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053181212-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053182585-git-send-email-ilpo.jarvinen@helsinki.fi> <11921053184007-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>,
	--cc@cs.helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34816 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbXJKMWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:22:03 -0400
In-Reply-To: <11921053184007-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Key points of this patch are:

  - In case new SACK information is advance only type, no skb
    processing below previously discovered highest point is done
  - Optimize cases below highest point too since there's no need
    to always go up to highest point (which is very likely still
    present in that SACK), this is not entirely true though
    because I'm dropping the fastpath_skb_hint which could
    previously optimize those cases even better. Whether that
    significant, I'm not too sure.

Corrently it will provide skipping by walking. Combined with
RB-tree, all skipping would become fast too regardless of window
size (can be done incrementally later).

Previously a number of cases in TCP SACK processing fails to
take advantage of costly stored information in sack_recv_cache.
Most importantly expected events such as cumulative ACK and new
hole ACKs. Processing on such ACKs result in rather long walks
building up latencies (which easily gets nasty when window is
large). Those latencies are often completely unnecessary
compared with the amount of _new_ information received, usually
for cumulative ACK there's no new information at all, yet TCP
walked whole queue unnecessary potentially taking a number of
costly cache misses on the way, etc.!

Since the inclusion of highest_sack, there's a lot information
that is very likely redundant (SACK fastpath hint stuff,
fackets_out, highest_sack), though there's no ultimate guarantee
that they'll remain the same whole the time (in all unearthly
scenarios). Take advantage of this too and drop fastpath hint
and use direct access to highest SACKed skb as replacement.

Effectively "special cased" fastpath is dropped. This change
adds some complexity to introduce better coveraged "fastpath",
though the added complexity should make TCP behave more cache
friendly.

The current ACK's SACK blocks are compared against each cached
block individially and only ranges that are new are then scanned
by the high constant walk. For other parts of write queue, even
when in previously known part of the SACK blocks, a faster skip
function is used (if necessary at all). In addition, whenever
possible, TCP fast-forwards to highest_sack skb that was made
available by an earlier patch. In typical case, no other things
but this fast-forward and mandatory markings after that occur
making the access pattern quite similar to the former fastpath
"special case".

DSACKs are special case that must always be walked.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    3 -
 include/net/tcp.h     |    1 -
 net/ipv4/tcp_input.c  |  253 ++++++++++++++++++++++++++++++-----------=
-------
 net/ipv4/tcp_output.c |   14 +---
 4 files changed, 159 insertions(+), 112 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 3e412f2..91c4430 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -343,10 +343,7 @@ struct tcp_sock {
 	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
-	struct sk_buff *fastpath_skb_hint;
=20
-	int     fastpath_cnt_hint;	/* Lags behind by current skb's pcount
-					 * compared to respective fackets_out */
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aead90a..cff2d86 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1078,7 +1078,6 @@ static inline void tcp_clear_retrans_hints_partia=
l(struct tcp_sock *tp)
 static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 {
 	tcp_clear_retrans_hints_partial(tp);
-	tp->fastpath_skb_hint =3D NULL;
 }
=20
 /* MD5 Signature */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c260642..c13f1af 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1170,10 +1170,14 @@ struct tcp_sacktag_state {
 	int reord;
 	int prior_fackets;
 	u32 highest_sack_end_seq;
-	int first_sack_index;
+	int fack_count;
+	u32 dup_start;
+	u32 dup_end;
 };
=20
-static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
+static int tcp_check_dsack(struct tcp_sock *tp,
+			   struct tcp_sacktag_state *state,
+			   struct sk_buff *ack_skb,
 			   struct tcp_sack_block_wire *sp, int num_sacks,
 			   u32 prior_snd_una)
 {
@@ -1183,6 +1187,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
=20
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
 		dup_sack =3D 1;
+		state->dup_start =3D start_seq_0;
+		state->dup_end =3D end_seq_0;
 		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
@@ -1192,6 +1198,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
 			dup_sack =3D 1;
+			state->dup_start =3D start_seq_1;
+			state->dup_end =3D end_seq_1;
 			tcp_dsack_seen(tp);
 			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
 		}
@@ -1343,6 +1351,88 @@ static void tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 	}
 }
=20
+static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
+					struct tcp_sacktag_state *state,
+					u32 start_seq, u32 end_seq,
+					int dup_sack)
+{
+	tcp_for_write_queue_from(skb, sk) {
+		int in_sack;
+
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		/* The retransmission queue is always in order, so
+		 * we can short-circuit the walk early.
+		 */
+		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
+			break;
+
+		if (dup_sack)
+			state->dup_start =3D 0;
+
+		if (state->dup_start && !before(TCP_SKB_CB(skb)->seq, state->dup_sta=
rt))
+			tcp_sacktag_walk(skb, sk, state, state->dup_start, state->dup_end, =
1);
+
+		in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+		if (in_sack < 0)
+			break;
+
+		state->fack_count +=3D tcp_skb_pcount(skb);
+
+		tcp_sacktag_one(skb, sk, state, in_sack, dup_sack,
+				state->fack_count, end_seq);
+	}
+	return skb;
+}
+
+/* Avoid all extra work that is being done by sacktag while walking in
+ * a normal way
+ */
+static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct so=
ck *sk,
+					struct tcp_sacktag_state *state,
+					u32 skip_to_seq)
+{
+	tcp_for_write_queue_from(skb, sk) {
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		if (before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
+			break;
+
+		/* DSACKs must always be processed */
+		if (state->dup_start && !before(TCP_SKB_CB(skb)->seq, state->dup_sta=
rt)) {
+			skb =3D tcp_sacktag_walk(skb, sk, state, state->dup_start,
+					       state->dup_end, 1);
+		}
+	}
+	return skb;
+}
+
+/* We have better entry point available */
+static struct sk_buff *tcp_sacktag_skip_to_highsack(struct sk_buff *sk=
b,
+						    struct sock *sk,
+						    struct tcp_sacktag_state *state,
+						    struct tcp_sack_block *cache)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	if (state->dup_start && after(state->dup_start, cache->start_seq) &&
+	    before(state->dup_start, TCP_SKB_CB(tp->highest_sack)->end_seq)) =
{
+		skb =3D tcp_sacktag_skip(skb, sk, state, state->dup_start);
+		tcp_sacktag_walk(skb, sk, state, state->dup_start, state->dup_end, 1=
);
+	}
+	skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+	state->fack_count =3D tp->fackets_out;
+
+	return skb;
+}
+
+static int tcp_sack_cache_ok(struct tcp_sock *tp, struct tcp_sack_bloc=
k *cache)
+{
+	return cache < tp->recv_sack_cache + ARRAY_SIZE(tp->recv_sack_cache);
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 =
prior_snd_una)
 {
@@ -1352,16 +1442,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			      TCP_SKB_CB(ack_skb)->sacked);
 	struct tcp_sack_block_wire *sp_wire =3D (struct tcp_sack_block_wire *=
)(ptr+2);
 	struct tcp_sack_block sp[4];
-	struct sk_buff *cached_skb;
+	struct tcp_sack_block *cache;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int used_sacks;
 	struct tcp_sacktag_state state;
 	int found_dup_sack;
-	int cached_fack_count;
-	int i;
-	int force_one_sack;
+	struct sk_buff *skb;
+	int i, j;
=20
 	state.flag =3D 0;
+	state.dup_start =3D 0;
+	state.dup_end =3D 0;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1369,7 +1460,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp_wire, num_sacks, p=
rior_snd_una);
+	found_dup_sack =3D tcp_check_dsack(tp, &state, ack_skb, sp_wire, num_=
sacks, prior_snd_una);
 	if (found_dup_sack)
 		state.flag |=3D FLAG_DSACKING_ACK;
=20
@@ -1412,113 +1503,88 @@ tcp_sacktag_write_queue(struct sock *sk, struc=
t sk_buff *ack_skb, u32 prior_snd_
 		used_sacks++;
 	}
=20
-	/* SACK fastpath:
-	 * if the only SACK change is the increase of the end_seq of
-	 * the first block then only apply that SACK block
-	 * and use retrans queue hinting otherwise slowpath */
-	force_one_sack =3D 1;
-	for (i =3D 0; i < used_sacks; i++) {
-		u32 start_seq =3D sp[i].start_seq;
-		u32 end_seq =3D sp[i].end_seq;
-
-		if (i =3D=3D 0) {
-			if (tp->recv_sack_cache[i].start_seq !=3D start_seq)
-				force_one_sack =3D 0;
-		} else {
-			if ((tp->recv_sack_cache[i].start_seq !=3D start_seq) ||
-			    (tp->recv_sack_cache[i].end_seq !=3D end_seq))
-				force_one_sack =3D 0;
-		}
-		tp->recv_sack_cache[i].start_seq =3D start_seq;
-		tp->recv_sack_cache[i].end_seq =3D end_seq;
-	}
-	/* Clear the rest of the cache sack blocks so they won't match mistak=
enly. */
-	for (; i < ARRAY_SIZE(tp->recv_sack_cache); i++) {
-		tp->recv_sack_cache[i].start_seq =3D 0;
-		tp->recv_sack_cache[i].end_seq =3D 0;
-	}
-
-	state.first_sack_index =3D 0;
-	if (force_one_sack)
-		used_sacks =3D 1;
-	else {
-		int j;
-		tp->fastpath_skb_hint =3D NULL;
-
-		/* order SACK blocks to allow in order walk of the retrans queue */
-		for (i =3D used_sacks-1; i > 0; i--) {
-			for (j =3D 0; j < i; j++){
-				if (after(sp[j].start_seq, sp[j+1].start_seq)) {
-					struct tcp_sack_block tmp;
-
-					tmp =3D sp[j];
-					sp[j] =3D sp[j+1];
-					sp[j+1] =3D tmp;
-
-					/* Track where the first SACK block goes to */
-					if (j =3D=3D state.first_sack_index)
-						state.first_sack_index =3D j+1;
-				}
+	/* order SACK blocks to allow in order walk of the retrans queue */
+	for (i =3D used_sacks-1; i > 0; i--) {
+		for (j =3D 0; j < i; j++){
+			if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+				struct tcp_sack_block tmp;
=20
+				tmp =3D sp[j];
+				sp[j] =3D sp[j+1];
+				sp[j+1] =3D tmp;
 			}
 		}
 	}
=20
-	/* Use SACK fastpath hint if valid */
-	cached_skb =3D tp->fastpath_skb_hint;
-	cached_fack_count =3D tp->fastpath_cnt_hint;
-	if (!cached_skb) {
-		cached_skb =3D tcp_write_queue_head(sk);
-		cached_fack_count =3D 0;
-	}
-
 	state.reord =3D tp->packets_out;
 	state.prior_fackets =3D tp->fackets_out;
+	state.fack_count =3D 0;
 	state.highest_sack_end_seq =3D 0;
=20
-	for (i=3D0; i< used_sacks; i++) {
-		struct sk_buff *skb;
+	skb =3D tcp_write_queue_head(sk);
+	i =3D 0;
+
+	if (!tp->sacked_out) {
+		/* It's already past, so skip checking against it */
+		cache =3D tp->recv_sack_cache + ARRAY_SIZE(tp->recv_sack_cache);
+	} else {
+		cache =3D tp->recv_sack_cache;
+		/* Skip empty blocks in at head of the cache */
+		while (tcp_sack_cache_ok(tp, cache) && !cache->start_seq &&
+		       !cache->end_seq)
+			cache++;
+	}
+
+	while (i < used_sacks) {
 		u32 start_seq =3D sp[i].start_seq;
 		u32 end_seq =3D sp[i].end_seq;
-		int fack_count;
-		int dup_sack =3D (found_dup_sack && (i =3D=3D state.first_sack_index=
));
-
-		skb =3D cached_skb;
-		fack_count =3D cached_fack_count;
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
 			state.flag |=3D FLAG_DATA_LOST;
=20
-		tcp_for_write_queue_from(skb, sk) {
-			int in_sack;
+		/* Skip too early cached blocks */
+		while (tcp_sack_cache_ok(tp, cache) &&
+		       !before(start_seq, cache->end_seq))
+			cache++;
=20
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
+		if (tcp_sack_cache_ok(tp, cache)) {
+			if (after(end_seq, cache->start_seq)) {
+				if (before(start_seq, cache->start_seq)) {
+					skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
+					skb =3D tcp_sacktag_walk(skb, sk, &state, start_seq, cache->start=
_seq, 0);
+				}
+				/* Rest of the block already fully processed? */
+				if (!after(end_seq, cache->end_seq)) {
+					i++;
+					continue;
+				}
+				if (TCP_SKB_CB(tp->highest_sack)->end_seq !=3D cache->end_seq) {
+					skb =3D tcp_sacktag_skip(skb, sk, &state, cache->end_seq);
+					cache++;
+					continue;
+				}
=20
-			cached_skb =3D skb;
-			cached_fack_count =3D fack_count;
-			if (i =3D=3D state.first_sack_index) {
-				tp->fastpath_skb_hint =3D skb;
-				tp->fastpath_cnt_hint =3D fack_count;
+				skb =3D tcp_sacktag_skip_to_highsack(skb, sk, &state, cache);
 			}
+		} else if (!before(start_seq, tcp_highest_sack_seq(sk)) &&
+			   before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(sk))) {
+			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+			state.fack_count =3D tp->fackets_out;
+		}
=20
-			/* The retransmission queue is always in order, so
-			 * we can short-circuit the walk early.
-			 */
-			if (!before(TCP_SKB_CB(skb)->seq, end_seq))
-				break;
-
-			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
-			if (in_sack < 0)
-				break;
-
-			fack_count +=3D tcp_skb_pcount(skb);
+		skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
+		skb =3D tcp_sacktag_walk(skb, sk, &state, start_seq, end_seq, 0);
+		i++;
+	}
=20
-			tcp_sacktag_one(skb, sk, &state, in_sack,
-					dup_sack, fack_count, end_seq);
-		}
+	/* Clear the head of the cache sack blocks so we can skip it next tim=
e */
+	for (i =3D 0; i < ARRAY_SIZE(tp->recv_sack_cache) - used_sacks; i++) =
{
+		tp->recv_sack_cache[i].start_seq =3D 0;
+		tp->recv_sack_cache[i].end_seq =3D 0;
 	}
+	for (j =3D 0; j < used_sacks; j++)
+		tp->recv_sack_cache[i++] =3D sp[j];
=20
 	if (tp->retrans_out &&
 	    after(state.highest_sack_end_seq, tp->lost_retrans_low) &&
@@ -2746,9 +2812,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p)
 		tcp_rearm_rto(sk);
=20
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
-		/* hint's skb might be NULL but we don't need to care */
-		tp->fastpath_cnt_hint -=3D min_t(u32, pkts_acked,
-					       tp->fastpath_cnt_hint);
 		if (tcp_is_reno(tp))
 			tcp_remove_reno_sacks(sk, pkts_acked);
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9603de8..1225f91 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -653,9 +653,7 @@ static void tcp_set_skb_tso_segs(struct sock *sk, s=
truct sk_buff *skb, unsigned
 }
=20
 /* When a modification to fackets out becomes necessary, we need to ch=
eck
- * skb is counted to fackets_out or not. Another important thing is to
- * tweak SACK fastpath hint too as it would overwrite all changes unle=
ss
- * hint is also changed.
+ * skb is counted to fackets_out or not.
  */
 static void tcp_adjust_fackets_out(struct sock *sk, struct sk_buff *sk=
b,
 				   int decr)
@@ -667,11 +665,6 @@ static void tcp_adjust_fackets_out(struct sock *sk=
, struct sk_buff *skb,
=20
 	if (!before(tcp_highest_sack_seq(sk), TCP_SKB_CB(skb)->seq))
 		tp->fackets_out -=3D decr;
-
-	/* cnt_hint is "off-by-one" compared with fackets_out (see sacktag) *=
/
-	if (tp->fastpath_skb_hint !=3D NULL &&
-	    after(TCP_SKB_CB(tp->fastpath_skb_hint)->seq, TCP_SKB_CB(skb)->se=
q))
-		tp->fastpath_cnt_hint -=3D decr;
 }
=20
 /* Function to create two new TCP segments.  Shrinks the given segment
@@ -1761,11 +1754,6 @@ static void tcp_retrans_try_collapse(struct sock=
 *sk, struct sk_buff *skb, int m
=20
 		/* changed transmit queue under us so clear hints */
 		tcp_clear_retrans_hints_partial(tp);
-		/* manually tune sacktag skb hint */
-		if (tp->fastpath_skb_hint =3D=3D next_skb) {
-			tp->fastpath_skb_hint =3D skb;
-			tp->fastpath_cnt_hint -=3D tcp_skb_pcount(skb);
-		}
=20
 		sk_stream_free_skb(sk, next_skb);
 	}
--=20
1.5.0.6

