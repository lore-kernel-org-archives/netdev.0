From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 2/2] [TCP]: Reworked recovery's TCPCB_LOST marking
 functions
Date: Wed, 7 Mar 2007 19:59:11 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703071954570.3770@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
 <20070306194259.GK25760@galon.ev-en.org> <20070306.134726.39155177.davem@davemloft.net>
 <20070306220146.GO25760@galon.ev-en.org> <Pine.LNX.4.64.0703071949210.3770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-405867558-1173290351=:3770"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53567 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422969AbXCGR7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 12:59:15 -0500
In-Reply-To: <Pine.LNX.4.64.0703071949210.3770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-405867558-1173290351=:3770
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Complete rewrite for update_scoreboard and mark_head_lost. Couple
of hints became unnecessary because of this change. Changes
!TCPCB_TAGBITS check from the original to !(S|L) but it shouldn't
make a difference, and if there ever is a R only skb TCP will
mark it as LOST too. The algorithm uses some ideas presented by
David Miller and Baruch Even.

Seqno lookups require fast lookups that are provided using
RB-tree patch(+abstraction) from DaveM.

v1-to-v2 changes:
 - Changes non-fack SACK to something less broken; not a complete
   set of changes (other functions should also be changed)
 - Fixed NewReno bugs
 - More comments & added RFCs to places I'm unsure of
 - Delayed reord_count increment (traverses one skb less now)
 - Copied retransmit_hint clearing from the original but I
   think it's superfluous
 - Separated highest_sack to own patch
 - Fixed off-by-one bug in skipping

Only compile tested this one (v1 was tried in a real network though).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h  |    4 -
 include/net/tcp.h    |   11 ++-
 net/ipv4/tcp_input.c |  219 +++++++++++++++++++++++++++++++++++---------------
 3 files changed, 163 insertions(+), 71 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 807fc96..9e706bd 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -323,15 +323,11 @@ #endif
 	u32	highest_sack;	/* Start seq of globally highest revd SACK (valid only in slowpath) */
 
 	/* from STCP, retrans queue hinting */
-	struct sk_buff* lost_skb_hint;
-
-	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
 	struct sk_buff *fastpath_skb_hint;
 
 	int     fastpath_cnt_hint;
-	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ceb95ec..549c249 100644
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
@@ -1194,6 +1192,11 @@ static inline struct sk_buff *tcp_write_
 	return skb->next;
 }
 
+static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
+{
+	return skb->prev;
+}
+
 #define tcp_for_write_queue(skb, sk)				\
 	for (skb = (sk)->sk_write_queue.next;			\
 	     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
@@ -1203,6 +1206,10 @@ #define tcp_for_write_queue_from(skb, sk
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
index 827171a..defe91e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1730,98 +1730,187 @@ static inline void tcp_reset_reno_sack(s
 	tp->left_out = tp->lost_out;
 }
 
-/* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
-			       int packets, u32 high_seq)
+/* RFC: This is from the original, I doubt that this is necessary at all:
+ * clear xmit_retrans hint if seq of this skb is beyond hint. How could we
+ * retransmitted past LOST markings in the first place? I'm not fully sure
+ * about undo and end of connection cases, which can cause R without L?
+ */
+static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
+				       struct sk_buff *skb)
 {
-	struct sk_buff *skb;
-	int cnt;
+	if (tp->retransmit_skb_hint &&
+	    before(TCP_SKB_CB(skb)->seq,
+	    TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
+		tp->retransmit_skb_hint = skb;
+}
 
-	BUG_TRAP(packets <= tp->packets_out);
-	if (tp->lost_skb_hint) {
-		skb = tp->lost_skb_hint;
-		cnt = tp->lost_cnt_hint;
-	} else {
-		skb = tcp_write_queue_head(sk);
-		cnt = 0;
-	}
+/* Forward walk starting from until a not timedout skb is encountered, timeout
+ * everything on the way
+ */
+static void tcp_timedout_mark_forward(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_for_write_queue_from(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-		/* TODO: do this better */
-		/* this is not the most efficient way to do this... */
-		tp->lost_skb_hint = skb;
-		tp->lost_cnt_hint = cnt;
-		cnt += tcp_skb_pcount(skb);
-		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, high_seq))
+		if (skb == tcp_send_head(sk) || !tcp_skb_timedout(sk, skb))
 			break;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+		/*
+		 * Could be lost already from a previous timedout check? I
+		 * think R skbs should never be encountered here.
+		 */
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST)) {
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
+			tcp_verify_retransmit_hint(tp, skb);
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
+ *
+ * Implements both FACK and RFC3517 SACK. Only FACK does per skb timeouts.
+ * Key difference is that FACK uses both SACK blocks and holes, while RFC3517
+ * is using only SACK blocks to mark (TODO: RFC3517 SACK requires a changes to
+ * elsewhere too).
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
 
-	/* New heuristics: it is possible only after we switched
-	 * to restart timer each time when something is ACKed.
-	 * Hence, we can detect timed out packets during fast
-	 * retransmit without falling to slow start.
-	 */
-	if (!IsReno(tp) && tcp_head_timedout(sk, tp)) {
-		struct sk_buff *skb;
+	skb = tcp_write_queue_find(sk, tp->highest_sack);
+	reentry_skb = tcp_write_queue_next(sk, skb);
 
-		skb = tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
-			: tcp_write_queue_head(sk);
+	tcp_for_write_queue_backwards_from(skb, sk) {
+		/*
+		 * BUG-to-solve: Sadly enough, still we might not know here
+		 * what timedout thingie must do something (not necessarily
+		 * encountered the highest SACKED_RETRANS).
+		 * RFC: there is a contradiction between the original code and
+		 * DaveM's interpretation of the skb_timedout loop which would
+		 * be nice to resolve first before fixing this. What should be
+		 * do with the discontinuity of timestamps at SACKED_RETRANS
+		 * edge when LOST is set for it, should timedout of a later
+		 * skb be postponed due to it?
+		 */
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			break;
+		/*
+		 * Skip to high_seq if enough SACK blocks gathered (and no
+		 * timedout work has begun)
+		 */
+		if (!ts_linear && (reord_count >= tp->reordering) &&
+		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+			/*
+			 * reord_count will be out-of-sync after this but
+			 * that's an non-issue because it is definately
+			 * larger than tp->reordering still!
+			 */
+			skb = tcp_write_queue_find(sk, tp->high_seq);
+			if (reentry_skb != NULL)
+				reentry_skb = skb;
+			WARN_ON(tp->high_seq == tp->snd_una);
+			/*
+			 * Search send us too far.
+			 * RFC: is this safe, can high_seq be equal to snd_una
+			 * ever, and what was returned by the find if there
+			 * were no skbs above high_seq?
+			 */
+			skb = tcp_write_queue_prev(sk, skb);
+		}
 
-		tcp_for_write_queue_from(skb, sk) {
-			if (skb == tcp_send_head(sk))
-				break;
+		/*
+		 * Could have S|R skb, or thus checking this here.
+		 * BUG: EVER_RETRANS edge somewhere when !tp->retrans
+		 * (significance is minor, requires undo or so to occur).
+		 */
+		if (IsFack(tp) && !ts_linear &&
+		    (!tp->retrans_out ||
+		     (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))) {
+			ts_linear = 1;
+			/* At SACKED_RETRANS edge, nothing to do past it? */
 			if (!tcp_skb_timedout(sk, skb))
-				break;
+				reentry_skb = NULL;
+		}
 
-			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
+			if (((reord_count >= tp->reordering) ||
+			     (ts_linear && tcp_skb_timedout(sk, skb)))) {
+				/*
+				 * RFC: Might have to handle skb fragmentation
+				 * here if the pcount > 1? Original does not
+				 * handle it, btw.
+				 */
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 				tp->lost_out += tcp_skb_pcount(skb);
+				tcp_verify_retransmit_hint(tp, skb);
 
-				/* clear xmit_retrans hint */
-				if (tp->retransmit_skb_hint &&
-				    before(TCP_SKB_CB(skb)->seq,
-					   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-
-					tp->retransmit_skb_hint = NULL;
+			} else if (reentry_skb != NULL) {
+				/*
+				 * ...wasn't marked, thus a possible entry
+				 * point (possibly last skb before
+				 * TCPCB_LOST edge comes).
+				 */
+				reentry_skb = skb;
 			}
 		}
 
-		tp->scoreboard_skb_hint = skb;
+		/* For RFC3517, do increment only if SACKED_ACKED is set */
+		if (IsFack(tp) || (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+			reord_count += tcp_skb_pcount(skb);
+	}
+	/*
+	 * RFC: Might have to handle the lost <= 0 condition here if nothing
+	 * got marked in the loop
+	 */
+	
+	/* Continue with timedout work */
+	if (IsFack(tp) && (reentry_skb != NULL))
+		tcp_timedout_mark_forward(sk, reentry_skb);
+	
+	tcp_sync_left_out(tp);
+}
 
+/* Simple NewReno thing: Mark head LOST if it wasn't yet and it's below
+ * high_seq, stop. That's all.
+ */
+static void tcp_update_scoreboard_newreno(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = tcp_write_queue_head(sk);
+	
+	if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST) &&
+	    before(tp->snd_una, tp->high_seq)) {
+		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+		tp->lost_out += tcp_skb_pcount(skb);
 		tcp_sync_left_out(tp);
 	}
 }
 
+/* Account newly detected lost packet(s) */
+static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
+{
+	if (!IsReno(tp))
+		tcp_update_scoreboard_fack(sk);
+	else
+		tcp_update_scoreboard_newreno(sk);
+}
+
 /* CWND moderation, preventing bursts due to too big ACKs
  * in dubious situations.
  */
@@ -2115,7 +2204,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp, tp->fackets_out-tp->reordering, tp->high_seq);
+	    	tcp_update_scoreboard_fack(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
-- 
1.4.2

---696243703-405867558-1173290351=:3770--
