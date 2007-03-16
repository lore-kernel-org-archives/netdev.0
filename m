From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCHv5 3/5] [TCP]: Reworked recovery's TCPCB_LOST marking functions
Date: Fri, 16 Mar 2007 20:41:04 +0200
Message-ID: <1174070466450-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11740704663475-git-send-email-ilpo.jarvinen@helsinki.fi> <11740704662337-git-send-email-ilpo.jarvinen@helsinki.fi> <11740704663404-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42614 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbXCPSlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 14:41:09 -0400
In-Reply-To: <11740704663404-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete rewrite for update_scoreboard and mark_head_lost. Couple
of hints became unnecessary because of this change, NewReno code
was greatly simplified. I changed !TCPCB_TAGBITS check from the
original to a !(S|L) check but it shouldn't make a difference,
and if there ever is a R only skb TCP will mark it as LOST too
that is a correct behavior (IMHO). The algorithm uses some ideas
presented by David Miller and Baruch Even.

This patch provides an unoptimized version.

Seqno lookups require fast lookups that are provided using
RB-tree patch (which is nowadays included into the latest
net-2.6.22).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h  |    4 -
 include/net/tcp.h    |   11 +++
 net/ipv4/tcp_input.c |  180 ++++++++++++++++++++++++++++++++++++------=
--------
 3 files changed, 139 insertions(+), 56 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 9e542d5..728321f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -338,15 +338,11 @@ #endif
 	u32	highest_sack;	/* Start seq of globally highest revd SACK (valid o=
nly in slowpath) */
=20
 	/* from STCP, retrans queue hinting */
-	struct sk_buff* lost_skb_hint;
-
-	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
 	struct sk_buff *fastpath_skb_hint;
=20
 	int     fastpath_cnt_hint;
-	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b451127..fe1c4f0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1047,8 +1047,6 @@ static inline void tcp_mib_init(void)
=20
 /*from STCP */
 static inline void clear_all_retrans_hints(struct tcp_sock *tp){
-	tp->lost_skb_hint =3D NULL;
-	tp->scoreboard_skb_hint =3D NULL;
 	tp->retransmit_skb_hint =3D NULL;
 	tp->forward_skb_hint =3D NULL;
 	tp->fastpath_skb_hint =3D NULL;
@@ -1194,6 +1192,11 @@ static inline struct sk_buff *tcp_write_
 	return skb->next;
 }
=20
+static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, st=
ruct sk_buff *skb)
+{
+	return skb->prev;
+}
+
 #define tcp_for_write_queue(skb, sk)					\
 		for (skb =3D (sk)->sk_write_queue.next;			\
 		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
@@ -1203,6 +1206,10 @@ #define tcp_for_write_queue_from(skb, sk
 		for (; (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);\
 		     skb =3D skb->next)
=20
+#define tcp_for_write_queue_backwards_from(skb, sk)			\
+		for (; (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);\
+		     skb =3D skb->prev)
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 870404b..f2b3f68 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1737,92 +1737,172 @@ static inline void tcp_reset_reno_sack(s
  * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
  * retransmitted past LOST markings in the first place? I'm not fully =
sure
  * about undo and end of connection cases, which can cause R without L=
?
+ * Anyway, if it was already R (it should be), no need to touch the hi=
nt.
  */
 static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
 				       struct sk_buff *skb)
 {
 	if ((tp->retransmit_skb_hint !=3D NULL) &&
+	    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
 	    before(TCP_SKB_CB(skb)->seq,
 	    TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
 		tp->retransmit_skb_hint =3D skb;
 }
=20
-/* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
-			       int packets, u32 high_seq)
+/* Forward walk starting from until a not timedout skb is encountered,=
 timeout
+ * everything on the way
+ */
+static void tcp_timedout_mark_forward(struct sock *sk, struct sk_buff =
*skb)
 {
-	struct sk_buff *skb;
-	int cnt;
-
-	BUG_TRAP(packets <=3D tp->packets_out);
-	if (tp->lost_skb_hint) {
-		skb =3D tp->lost_skb_hint;
-		cnt =3D tp->lost_cnt_hint;
-	} else {
-		skb =3D tcp_write_queue_head(sk);
-		cnt =3D 0;
-	}
+	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	tcp_for_write_queue_from(skb, sk) {
-		if (skb =3D=3D tcp_send_head(sk))
+		if (skb =3D=3D tcp_send_head(sk) || !tcp_skb_timedout(sk, skb))
 			break;
-		/* TODO: do this better */
-		/* this is not the most efficient way to do this... */
-		tp->lost_skb_hint =3D skb;
-		tp->lost_cnt_hint =3D cnt;
-		cnt +=3D tcp_skb_pcount(skb);
-		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, high_seq))
-			break;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+		/* Could be lost already from a previous timedout check */
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
 			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
-	tcp_sync_left_out(tp);
 }
=20
-/* Account newly detected lost packet(s) */
+/* Simple NewReno thing: Mark head LOST if it wasn't yet and it's belo=
w
+ * high_seq, stop. That's all.
+ */
+static void tcp_mark_head_lost_single(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb =3D tcp_write_queue_head(sk);
=20
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp=
)
+	if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST) &&
+	    before(tp->snd_una, tp->high_seq)) {
+		TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
+		tp->lost_out +=3D tcp_skb_pcount(skb);
+		tcp_sync_left_out(tp);
+	}
+}
+
+/* Marks per skb LOST bits with SACK is enabled.
+ *
+ * Algorithm details
+ *
+ * Walk backwards until the first previously LOST marked skb is found =
(or head
+ * is encountered) starting from highest_sack seq. Phases:
+ *
+ * Ia)  Condition 1, enough SACK blocks to indicate a loss:
+ *       Skip skbs until reord_count >=3D tp->reordering, then continu=
e from
+ *       min(skb_now->seq, tp->high_seq) and goto Marker.
+ *
+ * Ib)  Condition 2, skbs timed out:
+ *       During walk, also check if the currently processed skb has ti=
med out.
+ *       If such skb is found, goto Marker (thus if it is found before=
 skipping
+ *       to tp->high_seq in Ia, no skipping will be done).
+ *
+ * II)  Marker
+ *       Mark every non-SACKed skb that is encountered as LOST. When f=
irst
+ *       previously LOST marked skb is found, short-circuit.
+ *
+ * III) Polish up
+ *       If no skbs are marked, at least one is marked after the loop.
+ *
+ * IV)  Timedout work to do (if top timedout skb was not encountered)
+ *       If the previous walking didn't reveal the edge after which sk=
bs are
+ *       not timedout, it might be past the work we've done so far. Th=
erefore
+ *       call forward walk that marks timedout skbs as LOST starting f=
rom an
+ *       entry point right above a known point provided from the backw=
ards
+ *       walk. Basically the entry point will be next skb after highes=
t_sack
+ *       or high_seq (if TCP did the skip).
+ */
+static void tcp_update_scoreboard_fack(struct sock *sk)
 {
-	if (IsFack(tp)) {
-		int lost =3D tp->fackets_out - tp->reordering;
-		if (lost <=3D 0)
-			lost =3D 1;
-		tcp_mark_head_lost(sk, tp, lost, tp->high_seq);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	int timedout_continue =3D 1;
+	/* Beware: not_marked_skb might be pointing to sk_write_queue */
+	struct sk_buff *not_marked_skb;
+	struct sk_buff *skb;
+
+	if (!tp->sacked_out) {
+		tcp_mark_head_lost_single(sk);
+		not_marked_skb =3D tcp_write_queue_head(sk);
+		not_marked_skb =3D tcp_write_queue_next(sk, not_marked_skb);
+
 	} else {
-		tcp_mark_head_lost(sk, tp, 1, tp->high_seq);
-	}
+		unsigned int reord_count =3D 0;
=20
-	/* New heuristics: it is possible only after we switched
-	 * to restart timer each time when something is ACKed.
-	 * Hence, we can detect timed out packets during fast
-	 * retransmit without falling to slow start.
-	 */
-	if (!IsReno(tp) && tcp_head_timedout(sk, tp)) {
-		struct sk_buff *skb;
+		skb =3D tcp_write_queue_find(sk, tp->highest_sack);
+		/* If this ever becomes expensive, it can be delayed */
+		not_marked_skb =3D tcp_write_queue_next(sk, skb);
=20
-		skb =3D tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
-			: tcp_write_queue_head(sk);
+		/* Phase I: Search until TCP can mark */
+		tcp_for_write_queue_backwards_from(skb, sk) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+				break;
=20
-		tcp_for_write_queue_from(skb, sk) {
-			if (skb =3D=3D tcp_send_head(sk))
+			if (tcp_skb_timedout(sk, skb))
 				break;
-			if (!tcp_skb_timedout(sk, skb))
+			else
+				timedout_continue =3D 0;
+
+			/*
+			 * Isn't marked, thus a possible entrypoint (last skb
+			 * before LOST edge but TCP doesn't know for sure yet)
+			 */
+			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+				not_marked_skb =3D skb;
+
+			reord_count +=3D tcp_skb_pcount(skb);
+			if (reord_count > tp->reordering) {
+				if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+					/* RFC: should we have find_below? */
+					skb =3D tcp_write_queue_find(sk, tp->high_seq);
+					not_marked_skb =3D skb;
+					skb =3D tcp_write_queue_prev(sk, skb);
+					/* Timedout top is again uncertain? */
+					if (tcp_skb_timedout(sk, skb))
+						timedout_continue =3D 1;
+				}
+				/* ...else:
+				 * RFC: Might have to handle skb fragmentation
+				 * here if reord_count > tp->reordering, which
+				 * can be caused by pcount > 1 in the last
+				 * skb... Original does not handle it, btw.
+				 */
 				break;
+			}
+		}
=20
-			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+		/* Phase II: Marker */
+		tcp_for_write_queue_backwards_from(skb, sk) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+				break;
+			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 				TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 				tp->lost_out +=3D tcp_skb_pcount(skb);
 				tcp_verify_retransmit_hint(tp, skb);
 			}
 		}
=20
-		tp->scoreboard_skb_hint =3D skb;
-
-		tcp_sync_left_out(tp);
+		/* Phase III: Nothing is still marked?, mark head then */
+		if (!tp->lost_out)
+			tcp_mark_head_lost_single(sk);
 	}
+
+	/* Continue with timedout work */
+	if (timedout_continue)
+		tcp_timedout_mark_forward(sk, not_marked_skb);
+
+	tcp_sync_left_out(tp);
+}
+
+/* Account newly detected lost packet(s) */
+static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp=
)
+{
+	if (!IsReno(tp))
+		tcp_update_scoreboard_fack(sk);
+	else
+		tcp_mark_head_lost_single(sk);
 }
=20
 /* CWND moderation, preventing bursts due to too big ACKs
@@ -2118,7 +2198,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp, tp->fackets_out-tp->reordering, tp->high_=
seq);
+	    	tcp_update_scoreboard_fack(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
--=20
1.4.2

