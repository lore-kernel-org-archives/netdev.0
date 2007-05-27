From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 6/9] [TCP]: Reorganize lost marking code
Date: Sun, 27 May 2007 10:38:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705271032460.2532@kivilampi-30.cs.helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1229304644-1180251487=:2532"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40600 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbXE0HiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 03:38:11 -0400
In-Reply-To: <11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1229304644-1180251487=:2532
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 26 May 2007, Ilpo Järvinen wrote:

> -static void tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq,
> -				       int fast_rexmit)
> +struct sk_buff *tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq,
> +					   int fast_rexmit)

Noticed that the static got dropped here unintentionally, 2nd try included 
below.


[PATCH 6/9] [TCP]: Reorganize lost marking code

The indentation started to get scary, so I reorganized code so
that some trivial ifs are in tcp_update_scoreboard and the main
loops remain in tcp_update_scoreboard_fack.

It's much easier to view the actual changes with git-diff -w
than from the messy looking (default) diff.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  157 +++++++++++++++++++++++++-------------------------
 1 files changed, 79 insertions(+), 78 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 452a3b0..c5eda37 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1866,7 +1866,6 @@ static void tcp_mark_head_lost_single(struct sock *sk)
 	    before(tp->snd_una, tp->high_seq)) {
 		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 		tp->lost_out += tcp_skb_pcount(skb);
-		tcp_sync_left_out(tp);
 	}
 }
 
@@ -1905,99 +1904,85 @@ static void tcp_mark_head_lost_single(struct sock *sk)
  * Key difference here is that FACK uses both SACK blocks and holes while
  * RFC3517 is using only SACK blocks when counting for reordering.
  */
-static void tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq,
-				       int fast_rexmit)
+static struct sk_buff *tcp_update_scoreboard_fack(struct sock *sk,
+						  u32 entry_seq,
+						  int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	/* Beware: timedout_continue might be pointing to sk_write_queue */
 	struct sk_buff *timedout_continue = NULL;
 	struct sk_buff *skb;
-
-	if (!tp->sacked_out) {
-		if (IsFack(tp) || fast_rexmit) {
-			tcp_mark_head_lost_single(sk);
-			skb = tcp_write_queue_head(sk);
-			timedout_continue = tcp_write_queue_next(sk, skb);
-		}
-
+	unsigned int holes_seen = 0;
+
+	skb = tcp_write_queue_find(sk, entry_seq);
+	/* If this ever becomes expensive, it can be delayed */
+	timedout_continue = tcp_write_queue_next(sk, skb);
+	if (entry_seq != tp->highest_sack) {
+		/* Not interested in "the last" SACKed one we got */
+		/* RFC: find_below could help here too */
+		skb = tcp_write_queue_prev(sk, skb);
+		if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
+		    (tp->fackets_out < tp->packets_out)) {
+			timedout_continue = tcp_write_queue_find(sk, tp->highest_sack);
+			timedout_continue = tcp_write_queue_next(sk, timedout_continue);
+		} else
+			timedout_continue = NULL;
 	} else {
-		unsigned int holes_seen = 0;
-
-		skb = tcp_write_queue_find(sk, entry_seq);
-		/* If this ever becomes expensive, it can be delayed */
-		timedout_continue = tcp_write_queue_next(sk, skb);
-		if (entry_seq != tp->highest_sack) {
-			/* Not interested in "the last" SACKed one we got */
-			/* RFC: find_below could help here too */
-			skb = tcp_write_queue_prev(sk, skb);
-			if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
-			    (tp->fackets_out < tp->packets_out)) {
-				timedout_continue = tcp_write_queue_find(sk, tp->highest_sack);
-				timedout_continue = tcp_write_queue_next(sk, timedout_continue);
-			} else
-				timedout_continue = NULL;
-		} else {
-			unsigned int reord_count = IsFack(tp) ? 0 : 1;
-
-			/* Phase I: Search until TCP can mark */
-			tcp_for_write_queue_backwards_from(skb, sk) {
-				if ((tp->fackets_out <= tp->sacked_out +
-							tp->lost_out +
-							holes_seen) ||
-				    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
-					goto backwards_walk_done;
-
-				if (IsFack(tp) && tcp_skb_timedout(sk, skb))
-					break;
-				else
-					timedout_continue = NULL;
-
-				if (IsFack(tp) ||
-				    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-					reord_count += tcp_skb_pcount(skb);
-				if (reord_count > tp->reordering) {
-					if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
-						/* RFC: should we have find_below? */
-						skb = tcp_write_queue_find(sk, tp->high_seq);
-						/* Timedout top is again uncertain? */
-						if (tcp_skb_timedout(sk, skb))
-							timedout_continue = skb;
-						skb = tcp_write_queue_prev(sk, skb);
-					}
-					/* TODO?: do skb fragmentation if necessary */
-					break;
-				}
-
-				if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-					holes_seen += tcp_skb_pcount(skb);
-			}
-		}
+		unsigned int reord_count = IsFack(tp) ? 0 : 1;
 
-		/* Phase II: Marker */
+		/* Phase I: Search until TCP can mark */
 		tcp_for_write_queue_backwards_from(skb, sk) {
 			if ((tp->fackets_out <= tp->sacked_out + tp->lost_out +
 						holes_seen) ||
 			    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
 				goto backwards_walk_done;
 
-			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
-				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-				tp->lost_out += tcp_skb_pcount(skb);
-				tcp_verify_retransmit_hint(tp, skb);
+			if (IsFack(tp) && tcp_skb_timedout(sk, skb))
+				break;
+			else
+				timedout_continue = NULL;
+
+			if (IsFack(tp) ||
+			    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+				reord_count += tcp_skb_pcount(skb);
+			if (reord_count > tp->reordering) {
+				if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
+					/* RFC: should we have find_below? */
+					skb = tcp_write_queue_find(sk, tp->high_seq);
+					/* Timedout top is again uncertain? */
+					if (tcp_skb_timedout(sk, skb))
+						timedout_continue = skb;
+					skb = tcp_write_queue_prev(sk, skb);
+				}
+				/* TODO?: do skb fragmentation if necessary */
+				break;
 			}
+
+			if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+				holes_seen += tcp_skb_pcount(skb);
 		}
+	}
+
+	/* Phase II: Marker */
+	tcp_for_write_queue_backwards_from(skb, sk) {
+		if ((tp->fackets_out <= tp->sacked_out + tp->lost_out +
+					holes_seen) ||
+		    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
+			goto backwards_walk_done;
 
-		/* Phase III: Nothing is still marked?, mark head then */
-		if ((IsFack(tp) || fast_rexmit) && !tp->lost_out)
-			tcp_mark_head_lost_single(sk);
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
+			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
+			tp->lost_out += tcp_skb_pcount(skb);
+			tcp_verify_retransmit_hint(tp, skb);
+		}
 	}
-backwards_walk_done:
 
-	/* Continue with timedout work */
-	if (IsFack(tp) && (timedout_continue != NULL))
-		tcp_timedout_mark_forward(sk, timedout_continue);
+	/* Phase III: Nothing is still marked?, mark head then */
+	if ((IsFack(tp) || fast_rexmit) && !tp->lost_out)
+		tcp_mark_head_lost_single(sk);
 
-	tcp_sync_left_out(tp);
+backwards_walk_done:
+	return timedout_continue;
 }
 
 /* Account newly detected lost packet(s) */
@@ -2005,11 +1990,27 @@ static void tcp_update_scoreboard(struct sock *sk, u32 sack_entry_seq,
 				  int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = NULL;
+
+	if (!IsReno(tp)) {
+		if (!tp->sacked_out) {
+			if (IsFack(tp) || fast_rexmit) {
+				tcp_mark_head_lost_single(sk);
+				skb = tcp_write_queue_head(sk);
+				skb = tcp_write_queue_next(sk, skb);
+			}
+		} else
+			skb = tcp_update_scoreboard_fack(sk, sack_entry_seq,
+							 fast_rexmit);
 
-	if (!IsReno(tp))
-		tcp_update_scoreboard_fack(sk, sack_entry_seq, fast_rexmit);
-	else
+		/* Continue with timedout work */
+		if (IsFack(tp) && (skb != NULL))
+			tcp_timedout_mark_forward(sk, skb);
+
+	} else
 		tcp_mark_head_lost_single(sk);
+
+	tcp_sync_left_out(tp);
 }
 
 /* CWND moderation, preventing bursts due to too big ACKs
-- 
1.5.0.6

---696243703-1229304644-1180251487=:2532--
