From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking functions
Date: Tue, 6 Mar 2007 14:52:42 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-779104379-1173185562=:3770"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51021 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933868AbXCFMwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 07:52:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-779104379-1173185562=:3770
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Complete rewrite for update_scoreboard and mark_head_lost. Couple
of hints became unnecessary because of this change. Changes
!TCPCB_TAGBITS check from the original to !(S|L) but it shouldn't
make a difference, and if there ever is an R only skb TCP will
mark it as LOST too. The algorithm uses some ideas presented by
David Miller and Baruch Even.

Seqno lookups require fast lookups that are provided using
RB-tree patch(+abstraction) from DaveM.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

I'm sorry about poorly chunked diff, is it possible to force git to 
produce better (large block) diffs when a complete function is rewritten 
from scratch in the patch (manpage of git-diff-files hints -B bit it did 
not work, affects whole file rewrites only perhaps)?

This probably conflicts with the other patches in the rbtree patchset of 
DaveM (two first are required) because I tested this one (at least the 
non-timedout part worked) and didn't want some random breakage 
from the other patches (as such was reported).

 include/linux/tcp.h      |    6 -
 include/net/tcp.h        |    6 +
 net/ipv4/tcp_input.c     |  194 +++++++++++++++++++++++++++++-----------------
 net/ipv4/tcp_minisocks.c |    1 
 4 files changed, 130 insertions(+), 77 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b73687a..ccb9645 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -320,16 +320,14 @@ #endif
 
 	struct tcp_sack_block_wire recv_sack_cache[4];
 
-	/* from STCP, retrans queue hinting */
-	struct sk_buff* lost_skb_hint;
+	u32	highest_sack;	/* Start seq of globally highest revd SACK */
 
-	struct sk_buff *scoreboard_skb_hint;
+	/* from STCP, retrans queue hinting */
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
 	struct sk_buff *fastpath_skb_hint;
 
 	int     fastpath_cnt_hint;
-	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ceb95ec..02929bb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1047,8 +1047,6 @@ static inline void tcp_mib_init(void)
 
 /*from STCP */
 static inline void clear_all_retrans_hints(struct tcp_sock *tp){
-	tp->lost_skb_hint = NULL;
-	tp->scoreboard_skb_hint = NULL;
 	tp->retransmit_skb_hint = NULL;
 	tp->forward_skb_hint = NULL;
 	tp->fastpath_skb_hint = NULL;
@@ -1203,6 +1201,10 @@ #define tcp_for_write_queue_from(skb, sk
 	for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
 	     skb = skb->next)
 
+#define tcp_for_write_queue_backwards_from(skb, sk)		\
+	for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
+	     skb = skb->prev)
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 22d0bb0..eb474eb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1188,6 +1188,10 @@ tcp_sacktag_write_queue(struct sock *sk,
 
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out = fack_count;
+
+				if (after(TCP_SKB_CB(skb)->seq,
+				    tp->highest_sack))
+					tp->highest_sack = TCP_SKB_CB(skb)->seq;
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord = min(fack_count, reord);
@@ -1726,96 +1730,144 @@ static inline void tcp_reset_reno_sack(s
 	tp->left_out = tp->lost_out;
 }
 
-/* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
-			       int packets, u32 high_seq)
+/* Forward walk marking LOST until non-timedout is encountered */
+static void tcp_timedout_mark_forward(struct sock *sk, struct sk_buff *skb)
 {
-	struct sk_buff *skb;
-	int cnt;
-
-	BUG_TRAP(packets <= tp->packets_out);
-	if (tp->lost_skb_hint) {
-		skb = tp->lost_skb_hint;
-		cnt = tp->lost_cnt_hint;
-	} else {
-		skb = tcp_write_queue_head(sk);
-		cnt = 0;
-	}
+	struct tcp_sock *tp = tcp_sk(sk);
 
+	/* ...continue timed out work if necessary */
 	tcp_for_write_queue_from(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-		/* TODO: do this better */
-		/* this is not the most efficient way to do this... */
-		tp->lost_skb_hint = skb;
-		tp->lost_cnt_hint = cnt;
-		cnt += tcp_skb_pcount(skb);
-		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, high_seq))
+		if (skb == tcp_send_head(sk) ||
+		    !tcp_skb_timedout(sk, skb))
 			break;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+
+		/* Could be lost already from a previous timedout check !(S|L).
+		 * I think R skbs should never be encountered here if the
+		 * reentry_skb is set correctly (only the skipping to high_seq
+		 * in tcp_update_scoreboard_fack is suspectable to cause this
+		 * I think besides a bug).
+		 */
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS)) {
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
-
-			/* clear xmit_retransmit_queue hints
-			 *  if this is beyond hint */
-			if(tp->retransmit_skb_hint != NULL &&
-			   before(TCP_SKB_CB(skb)->seq,
-				  TCP_SKB_CB(tp->retransmit_skb_hint)->seq)) {
-
-				tp->retransmit_skb_hint = NULL;
-			}
 		}
 	}
-	tcp_sync_left_out(tp);
 }
 
-/* Account newly detected lost packet(s) */
-
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
+/* Algorithm details
+ *
+ *  I)  walk backwards until the first previously LOST marked skb is found (or
+ *      snd_una is encountered) starting from highest_sack->seq
+ *       1)  Skip skbs until reord_count > tp->reordering, then continue from
+ *           min(skb_now->seq, tp->high_seq)
+ *       2a) Mark non-SACKed skbs LOST
+ *       2b) If TCP can timeout non-SACKed skb safely, mark it LOST
+ *       3)  If LOST was not set for a non-SACKed skb, it's possible an
+ *           entrypoint for the step II (store it as such).
+ *
+ *  II) call forward walk that marks timedout skbs as LOST starting from an
+ *      entrypoint provided by the backwards walk, that is, min(LOST_edge,
+ *      tp->high_seq)
+ */
+static void tcp_update_scoreboard_fack(struct sock *sk)
 {
-	if (IsFack(tp)) {
-		int lost = tp->fackets_out - tp->reordering;
-		if (lost <= 0)
-			lost = 1;
-		tcp_mark_head_lost(sk, tp, lost, tp->high_seq);
-	} else {
-		tcp_mark_head_lost(sk, tp, 1, tp->high_seq);
-	}
+	struct tcp_sock *tp = tcp_sk(sk);
+	int reord_count = 0;
+	int ts_linear = 0;
+	struct sk_buff *skb, *reentry_skb = NULL;
+
+	/* How to get this highest_sack? */
+	skb = tcp_write_queue_find(sk, tp->highest_sack);
+	reentry_skb = tcp_write_queue_next(sk, skb);
+
+	tcp_for_write_queue_backwards_from(skb, sk) {
+		/* BUG-to-solve: Sadly enough, still we might not know here
+		 * what timedout thingie must do something (not necessarily
+		 * encountered the highest SACKED_RETRANS).
+		 */
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			break;
 
-	/* New heuristics: it is possible only after we switched
-	 * to restart timer each time when something is ACKed.
-	 * Hence, we can detect timed out packets during fast
-	 * retransmit without falling to slow start.
-	 */
-	if (!IsReno(tp) && tcp_head_timedout(sk, tp)) {
-		struct sk_buff *skb;
+		/* For RFC3517, do this only if SACKED_ACKED */
+		reord_count += tcp_skb_pcount(skb);
 
-		skb = tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
-			: tcp_write_queue_head(sk);
+		/* Skip to high_seq if enough SACK blocks gathered (and no
+		 * timedout work has begun)
+		 */
+		if (!ts_linear && (reord_count > tp->reordering) &&
+		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+			/* reord_count will be out-of-sync after this but
+			 * that's an non-issue because it is definately
+			 * larger than tp->reordering still!
+			 */
+			skb = tcp_write_queue_find(sk, tp->high_seq);
+			if (reentry_skb != NULL)
+				reentry_skb = tcp_write_queue_next(sk, skb);
+		}
 
-		tcp_for_write_queue_from(skb, sk) {
-			if (skb == tcp_send_head(sk))
-				break;
+		/* Could have S|R skb, or thus checking this here.
+		 * BUG: EVER_RETRANS edge somewhere when !tp->retrans
+		 * (minor, requires undo or so to occur).
+		 */
+		if (!ts_linear &&
+		    (!tp->retrans_out ||
+		     (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))) {
+			ts_linear = 1;
+			/* At SACKED_RETRANS edge, nothing to do past it */
 			if (!tcp_skb_timedout(sk, skb))
-				break;
-
-			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
-				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
+				reentry_skb = NULL;
+		}
 
-				/* clear xmit_retrans hint */
-				if (tp->retransmit_skb_hint &&
-				    before(TCP_SKB_CB(skb)->seq,
-					   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+			continue;
 
-					tp->retransmit_skb_hint = NULL;
-			}
+		if (((reord_count > tp->reordering) || /* check off-by-one?*/
+		     (ts_linear && tcp_skb_timedout(sk, skb)))) {
+			/* Might have to handle skb fragmentation here if the
+			 * pcount > 1? Original does not handle it, btw.
+			 */
+			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+			tp->lost_out += tcp_skb_pcount(skb);
+		} else if (reentry_skb != NULL) {
+			 /* ...wasn't marked, thus a possible entry point
+			  * (possibly last skb before TCPCB_LOST edge comes).
+			  */
+			reentry_skb = skb;
 		}
+	}
+	/* Might have to handle the lost <= 0 condition here if nothing
+	 * got marked in the loop (time
+	 */
+	if (reentry_skb != NULL)
+		tcp_timedout_mark_forward(sk, reentry_skb);
+	
+	tcp_sync_left_out(tp);
+}
 
-		tp->scoreboard_skb_hint = skb;
-
-		tcp_sync_left_out(tp);
+/* Simple NewReno + timedout thing:
+ *   1) Mark head LOST if it wasn't yet
+ *   2) Call the timedout thingie 
+ */
+static void tcp_update_scoreboard_newreno(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = tcp_write_queue_head(sk);
+	if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
+		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+		tp->lost_out += tcp_skb_pcount(skb);
 	}
+	/* This is wasteful */
+	tcp_timedout_mark_forward(sk, tcp_write_queue_next(sk, skb));
+}
+
+/* Account newly detected lost packet(s) */
+static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
+{
+	if (IsFack(tp))
+		tcp_update_scoreboard_fack(sk);
+	else
+		tcp_update_scoreboard_newreno(sk);
+	tcp_sync_left_out(tp);
 }
 
 /* CWND moderation, preventing bursts due to too big ACKs
@@ -2111,7 +2163,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp, tp->fackets_out-tp->reordering, tp->high_seq);
+	    	tcp_update_scoreboard_fack(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0a57c36..68d0000 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -389,6 +389,7 @@ struct sock *tcp_create_openreq_child(st
 		newtp->pred_flags = 0;
 		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
 		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
+		newtp->highest_sack = treq->snt_isn + 1;
 
 		tcp_prequeue_init(newtp);
 
-- 
1.4.2

---696243703-779104379-1173185562=:3770--
