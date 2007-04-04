From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Simplify LOST marker code
Date: Wed, 4 Apr 2007 11:54:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704041151000.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-537753760-1175676858=:28337"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41484 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933454AbXDDIyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 04:54:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-537753760-1175676858=:28337
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

During the development of the algorithm, some unnecessary cruft
seems to have crept in that is nowadays unnecessary:

1) LOST edge finder that sets not_marked_skb in the first loop
causes suboptimal performance because the preceeding else branch
already decides that the entry won't be necessary (else the loop
exits in the if branch).

2) timedout_continue need not to be a flag anymore. Combined
it with not_marked_skb.

3) reentry_to_highest_sack is unnecessary and the decision
can be made online. Also check if skb exists after the
highest_sack.

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   53 +++++++++++++++++---------------------------------
 1 files changed, 18 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fee6406..107bece 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1870,33 +1870,33 @@ static void tcp_update_scoreboard_fack(s
 				       int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int timedout_continue = 0;
-	/* Beware: not_marked_skb might be pointing to sk_write_queue */
-	struct sk_buff *not_marked_skb;
+	/* Beware: timedout_continue might be pointing to sk_write_queue */
+	struct sk_buff *timedout_continue = NULL;
 	struct sk_buff *skb;
 
 	if (!tp->sacked_out) {
 		if (IsFack(tp) || fast_rexmit) {
 			tcp_mark_head_lost_single(sk);
-			not_marked_skb = tcp_write_queue_head(sk);
-			not_marked_skb = tcp_write_queue_next(sk, not_marked_skb);
-			timedout_continue = 1;
+			skb = tcp_write_queue_head(sk);
+			timedout_continue = tcp_write_queue_next(sk, skb);
 		}
 
 	} else {
 		unsigned int holes_seen = 0;
-		int reentry_to_highest_sack = 0;
 
-		timedout_continue = 1;
 		skb = tcp_write_queue_find(sk, entry_seq);
 		/* If this ever becomes expensive, it can be delayed */
-		not_marked_skb = tcp_write_queue_next(sk, skb);
+		timedout_continue = tcp_write_queue_next(sk, skb);
 		if (entry_seq != tp->highest_sack) {
 			/* Not interested in "the last" SACKed one we got */
 			/* RFC: find_below could help here too */
 			skb = tcp_write_queue_prev(sk, skb);
-			/* Delay lookup because it might turn out unnecessary! */
-			reentry_to_highest_sack = 1;
+			if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
+			    (tp->fackets_out < tp->packets_out)) {
+				timedout_continue = tcp_write_queue_find(sk, tp->highest_sack);
+				timedout_continue = tcp_write_queue_next(sk, timedout_continue);
+			} else
+				timedout_continue = NULL;
 		} else {
 			unsigned int reord_count = IsFack(tp) ? 0 : 1;
 
@@ -1910,18 +1910,8 @@ static void tcp_update_scoreboard_fack(s
 
 				if (IsFack(tp) && tcp_skb_timedout(sk, skb))
 					break;
-				else {
-					timedout_continue = 0;
-					reentry_to_highest_sack = 0;
-				}
-
-				/*
-				 * Isn't marked, thus a possible entrypoint
-				 * (last skb before LOST edge but TCP doesn't
-				 * know for sure yet)
-				 */
-				if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-					not_marked_skb = skb;
+				else
+					timedout_continue = NULL;
 
 				if (IsFack(tp) ||
 				    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
@@ -1930,11 +1920,10 @@ static void tcp_update_scoreboard_fack(s
 					if (after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
 						/* RFC: should we have find_below? */
 						skb = tcp_write_queue_find(sk, tp->high_seq);
-						not_marked_skb = skb;
-						skb = tcp_write_queue_prev(sk, skb);
 						/* Timedout top is again uncertain? */
 						if (tcp_skb_timedout(sk, skb))
-							timedout_continue = 1;
+							timedout_continue = skb;
+						skb = tcp_write_queue_prev(sk, skb);
 					}
 					/* TODO?: do skb fragmentation if necessary */
 					break;
@@ -1962,18 +1951,12 @@ static void tcp_update_scoreboard_fack(s
 		/* Phase III: Nothing is still marked?, mark head then */
 		if ((IsFack(tp) || fast_rexmit) && !tp->lost_out)
 			tcp_mark_head_lost_single(sk);
-
-backwards_walk_done:
-		if (IsFack(tp) && timedout_continue && reentry_to_highest_sack) {
-			/* ...do the delayed lookup */
-			skb = tcp_write_queue_find(sk, tp->highest_sack);
-			not_marked_skb = tcp_write_queue_next(sk, skb);
-		}
 	}
+backwards_walk_done:
 
 	/* Continue with timedout work */
-	if (IsFack(tp) && timedout_continue)
-		tcp_timedout_mark_forward(sk, not_marked_skb);
+	if (IsFack(tp) && (timedout_continue != NULL))
+		tcp_timedout_mark_forward(sk, timedout_continue);
 
 	tcp_sync_left_out(tp);
 }
-- 
1.4.2

---696243703-537753760-1175676858=:28337--
