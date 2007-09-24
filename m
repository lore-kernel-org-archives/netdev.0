From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 4/5] [TCP]: Rewrite sack_recv_cache (WIP)
Date: Mon, 24 Sep 2007 13:28:46 +0300
Message-ID: <1190629727956-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297272364-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297271155-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297274028-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Tom Quetchenbach <virtualphtn@gmail.com>,
	Baruch Even <bar
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45643 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbXIXK2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 06:28:51 -0400
In-Reply-To: <11906297274028-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Previously a number of cases in TCP SACK processing fail to take
advantage of costly stored information in sack_recv_cache. Most
importantly expected events such as cumulative ACK, new hole
ACKs and first ACK after RTO fall to this category. Processing
on such ACKs result in rather long walks building up latencies
(which easily gets nasty when window is large), which are
completely unnecessary, usually no new information was gathered
except the new SACK block above the hole in the respective case.

Since the inclusion of highest_sack, there's a lot information
that is very likely redundant (SACK fastpath hint stuff,
fackets_out, highest_sack), though there's no ultimate guarantee
that they'll remain the same whole the time (in all unearthly
scenarios). Take advantage of this too and drop fastpath hint.
Effectively this drops "special cased" fastpath. This change
adds some complexity to introduce better coveraged "fastpath".
The current ACK's SACK blocks are compared against each cached
block individially and only ranges that are new are then scanned
by the high constant walk. For other parts of write queue, even
when in previously known part of the SACK blocks, a faster skip
function is used. In addition, whenever possible, TCP
fast-forwards to highest_sack skb that was made available
earlier. In typical case, no other things but this fast-forward
and mandatory markings after that occur making the access
pattern quite similar to the former fastpath. DSACKs are special
case that must always be walked.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    4 +-
 include/net/tcp.h     |    1 -
 net/ipv4/tcp_input.c  |  320 ++++++++++++++++++++++++++++++-----------=
-------
 net/ipv4/tcp_output.c |   12 +--
 4 files changed, 202 insertions(+), 135 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 1d6be2a..8d91eac 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -330,7 +330,7 @@ struct tcp_sock {
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
 	struct tcp_sack_block selective_acks[4]; /* The SACKS themselves*/
=20
-	struct tcp_sack_block_wire recv_sack_cache[4];
+	struct tcp_sack_block recv_sack_cache[4];
=20
 	struct sk_buff *highest_sack;   /* highest skb with SACK received
 					 * (validity guaranteed only if
@@ -343,9 +343,7 @@ struct tcp_sock {
 	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
-	struct sk_buff *fastpath_skb_hint;
=20
-	int     fastpath_cnt_hint;
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8bc64b7..d5def9b 100644
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
index 85dd4b0..9dfdd67 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1106,11 +1106,15 @@ struct tcp_sacktag_state {
 	unsigned int flag;
 	int reord;
 	int prior_fackets;
+	int fack_count;
 	u32 lost_retrans;
-	int first_sack_index;
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
@@ -1120,6 +1124,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
=20
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
 		dup_sack =3D 1;
+		state->dup_start =3D start_seq_0;
+		state->dup_end =3D end_seq_0;
 		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
@@ -1129,6 +1135,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
 			dup_sack =3D 1;
+			state->dup_start =3D start_seq_1;
+			state->dup_end =3D end_seq_1;
 			tcp_dsack_seen(tp);
 			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
 		}
@@ -1251,6 +1259,104 @@ static void tcp_sacktag_one(struct sk_buff *skb=
, struct sock *sk,
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
+		int in_sack, pcount;
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
+		in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
+			  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
+
+		pcount =3D tcp_skb_pcount(skb);
+
+		if (pcount > 1 && !in_sack &&
+		    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
+			unsigned int pkt_len;
+
+			in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq);
+
+			if (!in_sack)
+				pkt_len =3D (start_seq - TCP_SKB_CB(skb)->seq);
+			else
+				pkt_len =3D (end_seq - TCP_SKB_CB(skb)->seq);
+			if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size))
+				break;
+			pcount =3D tcp_skb_pcount(skb);
+		}
+
+		state->fack_count +=3D pcount;
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
@@ -1258,23 +1364,26 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	unsigned char *ptr =3D (skb_transport_header(ack_skb) +
 			      TCP_SKB_CB(ack_skb)->sacked);
-	struct tcp_sack_block_wire *sp =3D (struct tcp_sack_block_wire *)(ptr=
+2);
-	struct sk_buff *cached_skb;
+	struct tcp_sack_block_wire *sp_wire =3D (struct tcp_sack_block_wire *=
)(ptr+2);
+	struct tcp_sack_block sp[4];
+	struct tcp_sack_block *cache;
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
+	int used_sacks;
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
 		tp->fackets_out =3D 0;
 		tp->highest_sack =3D tcp_write_queue_head(sk);
 	}
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_=
snd_una);
+	found_dup_sack =3D tcp_check_dsack(tp, &state, ack_skb, sp_wire, num_=
sacks, prior_snd_una);
 	if (found_dup_sack)
 		state.flag |=3D FLAG_DSACKING_ACK;
=20
@@ -1285,79 +1394,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_wind=
ow))
 		return 0;
=20
-	/* SACK fastpath:
-	 * if the only SACK change is the increase of the end_seq of
-	 * the first block then only apply that SACK block
-	 * and use retrans queue hinting otherwise slowpath */
-	force_one_sack =3D 1;
+	used_sacks =3D 0;
 	for (i =3D 0; i < num_sacks; i++) {
-		__be32 start_seq =3D sp[i].start_seq;
-		__be32 end_seq =3D sp[i].end_seq;
+		int dup_sack =3D !i && found_dup_sack;
=20
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
+		sp[used_sacks].start_seq =3D ntohl(get_unaligned(&sp_wire[i].start_s=
eq));
+		sp[used_sacks].end_seq =3D ntohl(get_unaligned(&sp_wire[i].end_seq))=
;
=20
-	state.first_sack_index =3D 0;
-	if (force_one_sack)
-		num_sacks =3D 1;
-	else {
-		int j;
-		tp->fastpath_skb_hint =3D NULL;
-
-		/* order SACK blocks to allow in order walk of the retrans queue */
-		for (i =3D num_sacks-1; i > 0; i--) {
-			for (j =3D 0; j < i; j++){
-				if (after(ntohl(sp[j].start_seq),
-					  ntohl(sp[j+1].start_seq))){
-					struct tcp_sack_block_wire tmp;
-
-					tmp =3D sp[j];
-					sp[j] =3D sp[j+1];
-					sp[j+1] =3D tmp;
-
-					/* Track where the first SACK block goes to */
-					if (j =3D=3D state.first_sack_index)
-						state.first_sack_index =3D j+1;
-				}
-
-			}
-		}
-	}
-
-	/* Use SACK fastpath hint if valid */
-	cached_skb =3D tp->fastpath_skb_hint;
-	cached_fack_count =3D tp->fastpath_cnt_hint;
-	if (!cached_skb) {
-		cached_skb =3D tcp_write_queue_head(sk);
-		cached_fack_count =3D 0;
-	}
-
-	state.reord =3D tp->packets_out;
-	state.prior_fackets =3D tp->fackets_out;
-	state.lost_retrans =3D 0;
-
-	for (i=3D0; i<num_sacks; i++, sp++) {
-		struct sk_buff *skb;
-		__u32 start_seq =3D ntohl(sp->start_seq);
-		__u32 end_seq =3D ntohl(sp->end_seq);
-		int fack_count;
-		int dup_sack =3D (found_dup_sack && (i =3D=3D state.first_sack_index=
));
-
-		if (!tcp_is_sackblock_valid(tp, dup_sack, start_seq, end_seq)) {
+		if (!tcp_is_sackblock_valid(tp, dup_sack,
+					    sp[used_sacks].start_seq,
+					    sp[used_sacks].end_seq)) {
 			if (dup_sack) {
 				if (!tp->undo_marker)
 					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
@@ -1366,68 +1412,102 @@ tcp_sacktag_write_queue(struct sock *sk, struc=
t sk_buff *ack_skb, u32 prior_snd_
 			} else {
 				/* Don't count olds caused by ACK reordering */
 				if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
-				    !after(end_seq, tp->snd_una))
+				    !after(sp[used_sacks].end_seq, tp->snd_una))
 					continue;
 				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
 			}
 			continue;
 		}
=20
-		skb =3D cached_skb;
-		fack_count =3D cached_fack_count;
-
-		/* Event "B" in the comment above. */
-		if (after(end_seq, tp->high_seq))
-			state.flag |=3D FLAG_DATA_LOST;
+		/* Ignore very old stuff early */
+		if (!after(sp[used_sacks].end_seq, prior_snd_una))
+			continue;
=20
-		tcp_for_write_queue_from(skb, sk) {
-			int in_sack, pcount;
+		used_sacks++;
+	}
=20
-			if (skb =3D=3D tcp_send_head(sk))
-				break;
+	/* order SACK blocks to allow in order walk of the retrans queue */
+	for (i =3D used_sacks-1; i > 0; i--) {
+		for (j =3D 0; j < i; j++){
+			if (after(sp[j].start_seq, sp[j+1].start_seq)) {
+				struct tcp_sack_block tmp;
=20
-			cached_skb =3D skb;
-			cached_fack_count =3D fack_count;
-			if (i =3D=3D state.first_sack_index) {
-				tp->fastpath_skb_hint =3D skb;
-				tp->fastpath_cnt_hint =3D fack_count;
+				tmp =3D sp[j];
+				sp[j] =3D sp[j+1];
+				sp[j+1] =3D tmp;
 			}
+		}
+	}
=20
-			/* The retransmission queue is always in order, so
-			 * we can short-circuit the walk early.
-			 */
-			if (!before(TCP_SKB_CB(skb)->seq, end_seq))
-				break;
+	state.reord =3D tp->packets_out;
+	state.prior_fackets =3D tp->fackets_out;
+	state.lost_retrans =3D 0;
+	state.fack_count =3D 0;
=20
-			in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
-				!before(end_seq, TCP_SKB_CB(skb)->end_seq);
+	skb =3D tcp_write_queue_head(sk);
+	i =3D 0;
=20
-			pcount =3D tcp_skb_pcount(skb);
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
=20
-			if (pcount > 1 && !in_sack &&
-			    after(TCP_SKB_CB(skb)->end_seq, start_seq)) {
-				unsigned int pkt_len;
+	while (i < used_sacks) {
+		u32 start_seq =3D sp[i].start_seq;
+		u32 end_seq =3D sp[i].end_seq;
=20
-				in_sack =3D !after(start_seq,
-						 TCP_SKB_CB(skb)->seq);
+		/* Event "B" in the comment above. */
+		if (after(end_seq, tp->high_seq))
+			state.flag |=3D FLAG_DATA_LOST;
=20
-				if (!in_sack)
-					pkt_len =3D (start_seq -
-						   TCP_SKB_CB(skb)->seq);
-				else
-					pkt_len =3D (end_seq -
-						   TCP_SKB_CB(skb)->seq);
-				if (tcp_fragment(sk, skb, pkt_len, skb_shinfo(skb)->gso_size))
-					break;
-				pcount =3D tcp_skb_pcount(skb);
-			}
+		/* Skip too early cached blocks */
+		while (tcp_sack_cache_ok(tp, cache) &&
+		       !before(start_seq, cache->end_seq))
+			cache++;
=20
-			fack_count +=3D pcount;
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
-			tcp_sacktag_one(skb, sk, &state, in_sack,
-					dup_sack, fack_count, end_seq);
+				skb =3D tcp_sacktag_skip_to_highsack(skb, sk, &state, cache);
+			}
+		} else if (!before(start_seq, tcp_highest_sack_seq(sk)) &&
+			   before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(sk))) {
+			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
+			state.fack_count =3D tp->fackets_out;
 		}
+
+		skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
+		skb =3D tcp_sacktag_walk(skb, sk, &state, start_seq, end_seq, 0);
+		i++;
+	}
+
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
 	/* Check for lost retransmit. This superb idea is
 	 * borrowed from "ratehalving". Event "C".
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fd51692..4cfda16 100644
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
@@ -1760,9 +1753,6 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
=20
 		/* changed transmit queue under us so clear hints */
 		tcp_clear_retrans_hints_partial(tp);
-		/* manually tune sacktag skb hint */
-		if (tp->fastpath_skb_hint =3D=3D next_skb)
-			tp->fastpath_skb_hint =3D skb;
=20
 		sk_stream_free_skb(sk, next_skb);
 	}
--=20
1.5.0.6

