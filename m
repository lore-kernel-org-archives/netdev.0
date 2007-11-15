From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 09/10] [TCP]: Rewrite SACK block processing & sack_recv_cache use
Date: Thu, 15 Nov 2007 15:37:33 +0200
Message-ID: <11951338541351-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854614-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338543774-git-send-email-ilpo.jarvinen@helsinki.fi> <11951338541495-git-send-email-ilpo.jarvinen@helsinki.fi> <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757494AbXKONhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:39 -0500
In-Reply-To: <1195133854112-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Key points of this patch are:

  - In case new SACK information is advance only type, no skb
    processing below previously discovered highest point is done
  - Optimize cases below highest point too since there's no need
    to always go up to highest point (which is very likely still
    present in that SACK), this is not entirely true though
    because I'm dropping the fastpath_skb_hint which could
    previously optimize those cases even better. Whether that's
    significant, I'm not too sure.

Corrently it will provide skipping by walking. Combined with
RB-tree, all skipping would become fast too regardless of window
size (can be done incrementally later).

Previously a number of cases in TCP SACK processing fails to
take advantage of costly stored information in sack_recv_cache,
most importantly, expected events such as cumulative ACK and new
hole ACKs. Processing on such ACKs result in rather long walks
building up latencies (which easily gets nasty when window is
huge). Those latencies are often completely unnecessary
compared with the amount of _new_ information received, usually
for cumulative ACK there's no new information at all, yet TCP
walks whole queue unnecessary potentially taking a number of
costly cache misses on the way, etc.!

Since the inclusion of highest_sack, there's a lot information
that is very likely redundant (SACK fastpath hint stuff,
fackets_out, highest_sack), though there's no ultimate guarantee
that they'll remain the same whole the time (in all unearthly
scenarios). Take advantage of this knowledge here and drop
fastpath hint and use direct access to highest SACKed skb as
a replacement.

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

The local to recv_sack_cache copying could be more intelligent
w.r.t DSACKs which are likely to be there only once but that
is left to a separate patch.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    3 -
 include/net/tcp.h     |    1 -
 net/ipv4/tcp_input.c  |  277 +++++++++++++++++++++++++++++++----------=
--------
 net/ipv4/tcp_output.c |   14 +---
 4 files changed, 175 insertions(+), 120 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 794497c..08027f1 100644
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
index 3444647..0844261 100644
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
index 69f2f79..5833b01 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1333,6 +1333,88 @@ static int tcp_sacktag_one(struct sk_buff *skb, =
struct tcp_sock *tp,
 	return flag;
 }
=20
+static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
+					struct tcp_sack_block *next_dup,
+					u32 start_seq, u32 end_seq,
+					int dup_sack_in, int *fack_count,
+					int *reord, int *flag)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	tcp_for_write_queue_from(skb, sk) {
+		int in_sack =3D 0;
+		int dup_sack =3D dup_sack_in;
+
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		/* queue is in-order =3D> we can short-circuit the walk early */
+		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
+			break;
+
+		if ((next_dup !=3D NULL) &&
+		    before(TCP_SKB_CB(skb)->seq, next_dup->end_seq)) {
+			in_sack =3D tcp_match_skb_to_sack(sk, skb,
+							next_dup->start_seq,
+							next_dup->end_seq);
+			if (in_sack > 0)
+				dup_sack =3D 1;
+		}
+
+		if (in_sack <=3D 0)
+			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+		if (unlikely(in_sack < 0))
+			break;
+
+		if (in_sack)
+			*flag |=3D tcp_sacktag_one(skb, tp, reord, dup_sack, *fack_count);
+
+		*fack_count +=3D tcp_skb_pcount(skb);
+	}
+	return skb;
+}
+
+/* Avoid all extra work that is being done by sacktag while walking in
+ * a normal way
+ */
+static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct so=
ck *sk,
+					u32 skip_to_seq)
+{
+	tcp_for_write_queue_from(skb, sk) {
+		if (skb =3D=3D tcp_send_head(sk))
+			break;
+
+		if (before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
+			break;
+	}
+	return skb;
+}
+
+static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
+						struct sock *sk,
+						struct tcp_sack_block *next_dup,
+						u32 skip_to_seq,
+						int *fack_count, int *reord,
+						int *flag)
+{
+	if (next_dup =3D=3D NULL)
+		return skb;
+
+	if (before(next_dup->start_seq, skip_to_seq)) {
+		skb =3D tcp_sacktag_skip(skb, sk, next_dup->start_seq);
+		tcp_sacktag_walk(skb, sk, NULL,
+				 next_dup->start_seq, next_dup->end_seq,
+				 1, fack_count, reord, flag);
+	}
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
@@ -1342,16 +1424,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			      TCP_SKB_CB(ack_skb)->sacked);
 	struct tcp_sack_block_wire *sp_wire =3D (struct tcp_sack_block_wire *=
)(ptr+2);
 	struct tcp_sack_block sp[4];
-	struct sk_buff *cached_skb;
+	struct tcp_sack_block *cache;
+	struct sk_buff *skb;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int used_sacks;
 	int reord =3D tp->packets_out;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
-	int cached_fack_count;
-	int i;
+	int fack_count;
+	int i, j;
 	int first_sack_index;
-	int force_one_sack;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1409,132 +1491,123 @@ tcp_sacktag_write_queue(struct sock *sk, stru=
ct sk_buff *ack_skb, u32 prior_snd_
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
-	if (force_one_sack)
-		used_sacks =3D 1;
-	else {
-		int j;
-		tp->fastpath_skb_hint =3D NULL;
-
-		/* order SACK blocks to allow in order walk of the retrans queue */
-		for (i =3D used_sacks - 1; i > 0; i--) {
-			for (j =3D 0; j < i; j++){
-				if (after(sp[j].start_seq, sp[j+1].start_seq)) {
-					struct tcp_sack_block tmp;
-
-					tmp =3D sp[j];
-					sp[j] =3D sp[j+1];
-					sp[j+1] =3D tmp;
-
-					/* Track where the first SACK block goes to */
-					if (j =3D=3D first_sack_index)
-						first_sack_index =3D j+1;
-				}
-
+	/* order SACK blocks to allow in order walk of the retrans queue */
+	for (i =3D used_sacks - 1; i > 0; i--) {
+		for (j =3D 0; j < i; j++){
+			if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+				struct tcp_sack_block tmp;
+
+				tmp =3D sp[j];
+				sp[j] =3D sp[j+1];
+				sp[j+1] =3D tmp;
+			=09
+				/* Track where the first SACK block goes to */
+				if (j =3D=3D first_sack_index)
+					first_sack_index =3D j+1;
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
+	skb =3D tcp_write_queue_head(sk);
+	fack_count =3D 0;
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
 	}
=20
-	for (i =3D 0; i < used_sacks; i++) {
-		struct sk_buff *skb;
+	while (i < used_sacks) {
 		u32 start_seq =3D sp[i].start_seq;
 		u32 end_seq =3D sp[i].end_seq;
-		int fack_count;
 		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
-		int next_dup =3D (found_dup_sack && (i+1 =3D=3D first_sack_index));
-
-		skb =3D cached_skb;
-		fack_count =3D cached_fack_count;
+		struct tcp_sack_block *next_dup =3D NULL;
+	=09
+		if (found_dup_sack && ((i + 1) =3D=3D first_sack_index))
+			next_dup =3D &sp[i + 1];
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
 			flag |=3D FLAG_DATA_LOST;
=20
-		tcp_for_write_queue_from(skb, sk) {
-			int in_sack =3D 0;
-
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
-
-			cached_skb =3D skb;
-			cached_fack_count =3D fack_count;
-			if (i =3D=3D first_sack_index) {
-				tp->fastpath_skb_hint =3D skb;
-				tp->fastpath_cnt_hint =3D fack_count;
+		/* Skip too early cached blocks */
+		while (tcp_sack_cache_ok(tp, cache) &&
+		       !before(start_seq, cache->end_seq))
+			cache++;
+
+		/* Can skip some work by looking recv_sack_cache? */
+		if (tcp_sack_cache_ok(tp, cache) && !dup_sack &&
+		    after(end_seq, cache->start_seq)) {
+
+			/* Head todo? */
+			if (before(start_seq, cache->start_seq)) {
+				skb =3D tcp_sacktag_skip(skb, sk, start_seq);
+				skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq,
+						       cache->start_seq, dup_sack,
+						       &fack_count, &reord, &flag);
 			}
=20
-			/* The retransmission queue is always in order, so
-			 * we can short-circuit the walk early.
-			 */
-			if (!before(TCP_SKB_CB(skb)->seq, end_seq))
-				break;
-
-			dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
+			/* Rest of the block already fully processed? */
+			if (!after(end_seq, cache->end_seq)) {
+				skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq=
,
+							       &fack_count, &reord, &flag);
+				goto advance_sp;
+			}
=20
-			/* Due to sorting DSACK may reside within this SACK block! */
-			if (next_dup) {
-				u32 dup_start =3D sp[i+1].start_seq;
-				u32 dup_end =3D sp[i+1].end_seq;
+			/* ...tail remains todo... */
+			if (TCP_SKB_CB(tp->highest_sack)->end_seq =3D=3D cache->end_seq) {
+				/* ...but better entrypoint exists! Check that DSACKs are
+				 * properly accounted while skipping here
+				 */
+				tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
+							 &fack_count, &reord, &flag);
=20
-				if (before(TCP_SKB_CB(skb)->seq, dup_end)) {
-					in_sack =3D tcp_match_skb_to_sack(sk, skb, dup_start, dup_end);
-					if (in_sack > 0)
-						dup_sack =3D 1;
-				}
+				skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+				fack_count =3D tp->fackets_out;
+				cache++;
+				goto walk;
 			}
=20
-			/* DSACK info lost if out-of-mem, try SACK still */
-			if (in_sack <=3D 0)
-				in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
-			if (unlikely(in_sack < 0))
-				break;
-
-			if (in_sack)
-				flag |=3D tcp_sacktag_one(skb, tp, &reord, dup_sack, fack_count);
+			skb =3D tcp_sacktag_skip(skb, sk, cache->end_seq);
+			/* Check overlap against next cached too (past this one already) */
+			cache++;
+			continue;
+		}
=20
-			fack_count +=3D tcp_skb_pcount(skb);
+		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
+			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+			fack_count =3D tp->fackets_out;
 		}
+		skb =3D tcp_sacktag_skip(skb, sk, start_seq);
+
+walk:
+		skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
+				       dup_sack, &fack_count, &reord, &flag);
=20
+advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
 		 * due to in-order walk
 		 */
 		if (after(end_seq, tp->frto_highmark))
 			flag &=3D ~FLAG_ONLY_ORIG_SACKED;
+
+		i++;
 	}
=20
+	/* Clear the head of the cache sack blocks so we can skip it next tim=
e */
+	for (i =3D 0; i < ARRAY_SIZE(tp->recv_sack_cache) - used_sacks; i++) =
{
+		tp->recv_sack_cache[i].start_seq =3D 0;
+		tp->recv_sack_cache[i].end_seq =3D 0;
+	}
+	for (j =3D 0; j < used_sacks; j++)
+		tp->recv_sack_cache[i++] =3D sp[j];
+
 	flag |=3D tcp_mark_lost_retrans(sk);
=20
 	tcp_verify_left_out(tp);
@@ -2818,9 +2891,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s=
32 *seq_rtt_p,
 		}
=20
 		tp->fackets_out -=3D min(pkts_acked, tp->fackets_out);
-		/* hint's skb might be NULL but we don't need to care */
-		tp->fastpath_cnt_hint -=3D min_t(u32, pkts_acked,
-					       tp->fastpath_cnt_hint);
+
 		if (ca_ops->pkts_acked) {
 			s32 rtt_us =3D -1;
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a5863f9..b0ece43 100644
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
 	if (!before(tcp_highest_sack_seq(tp), TCP_SKB_CB(skb)->seq))
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

