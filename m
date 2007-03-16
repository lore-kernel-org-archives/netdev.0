From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC RESEND PATCH 5/5] [TCP]: non-FACK SACK follows conservative
 SACK loss recovery (RFC3517)
Date: Fri, 16 Mar 2007 17:11:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703161659320.23854@kivilampi-30.cs.helsinki.fi>
References: <11740560023261-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11740560021077-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11740560021541-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11740560022597-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1174056002151-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11740560023645-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1245015203-1174057876=:23854"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37973 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965371AbXCPPLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 11:11:23 -0400
In-Reply-To: <11740560023645-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1245015203-1174057876=:23854
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Many assumptions that are true when no reordering or other
strange events happen are not a part of the RFC3517. FACK
implementation is based on such assumptions. Previously (before
the rewrite) the non-FACK SACK was basically doing fast rexmit
and then it times out all skbs when first cumulative ACK arrives,
which cannot really be called SACK based recovery :-).

RFC3517 SACK disables these things:
- Per SKB timeouts & head timeout entry to recovery
- Marking at least one skb while in recovery (RFC3517 does this
  only for the fast retransmission but not for the other skbs
  when cumulative ACKs arrive in the recovery)
- B & C flavors of loss detection (see comment before
  tcp_sacktag_write_queue)

This does not implement the "last resort" rule 3 of NextSeg, which
allows retransmissions also when not enough SACK blocks have yet
arrived above a segment for IsLost to return true [RFC3517].

The implementation differs from RFC3517 in two points:
- Rate-halving is used instead of FlightSize / 2
- Instead of using dupACKs to trigger the recovery, the number
  of SACK blocks is used as FACK does with SACK blocks+holes
  (which provides more accurate number). It seems that the
  difference can affect negatively only if the receiver does not
  generate SACK blocks at all even though it claimed to be
  SACK-capable.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---

The previously sent patch was missing || fast_rexmit for !sacked_out case.
Sadly enough now gcc started then to warn about not_marked_skb not being
initialized (wasn't previously). Ironically, in this case there are more
paths were it's initialized and none of the paths was removed due to the
change :-). That's easy to fix later on (if these are seriously considered 
for inclusion) by initializing timedout_continue to zero and setting it to 
1 only in the relevant branches, which is probably enough to bring gcc 
to its rest again.

 net/ipv4/tcp_input.c |   55 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 88d3a4c..9802a22 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -111,6 +111,7 @@ #define FLAG_FORWARD_PROGRESS	(FLAG_ACKE
 #define IsReno(tp) ((tp)->rx_opt.sack_ok == 0)
 #define IsFack(tp) ((tp)->rx_opt.sack_ok & 2)
 #define IsDSack(tp) ((tp)->rx_opt.sack_ok & 4)
+#define Is3517Sack(tp) (!IsReno(tp) && !IsFack(tp))
 
 #define IsSackFrto() (sysctl_tcp_frto == 0x2)
 
@@ -1232,7 +1233,7 @@ tcp_sacktag_write_queue(struct sock *sk,
 	 * we have to account for reordering! Ugly,
 	 * but should help.
 	 */
-	if (lost_retrans && icsk->icsk_ca_state == TCP_CA_Recovery) {
+	if (IsFack(tp) && lost_retrans && icsk->icsk_ca_state == TCP_CA_Recovery) {
 		struct sk_buff *skb;
 
 		tcp_for_write_queue(skb, sk) {
@@ -1551,7 +1552,8 @@ static int tcp_check_sack_reneging(struc
 
 static inline int tcp_fackets_out(struct tcp_sock *tp)
 {
-	return IsReno(tp) ? tp->sacked_out+1 : tp->fackets_out;
+	return (IsReno(tp) || Is3517Sack(tp)) ? tp->sacked_out + 1 :
+						tp->fackets_out;
 }
 
 static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *skb)
@@ -1677,7 +1679,7 @@ static int tcp_time_to_recover(struct so
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
-	if (tcp_head_timedout(sk, tp))
+	if (IsFack(tp) && tcp_head_timedout(sk, tp))
 		return 1;
 
 	/* Trick#4: It is still not OK... But will it be useful to delay
@@ -1826,8 +1828,13 @@ static void tcp_mark_head_lost_single(st
  *       entry point right above a known point provided from the backwards
  *       walk. Basically the entry point will be next skb after highest_sack
  *       or high_seq (if TCP did the skip).
+ *
+ * Implements both FACK and RFC3517 SACK. Only FACK does per skb timeouts.
+ * Key difference here is that FACK uses both SACK blocks and holes while
+ * RFC3517 is using only SACK blocks when counting for reordering.
  */
-static void tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq)
+static void tcp_update_scoreboard_fack(struct sock *sk, u32 entry_seq,
+				       int fast_rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int timedout_continue = 1;
@@ -1836,9 +1843,11 @@ static void tcp_update_scoreboard_fack(s
 	struct sk_buff *skb;
 
 	if (!tp->sacked_out) {
-		tcp_mark_head_lost_single(sk);
-		not_marked_skb = tcp_write_queue_head(sk);
-		not_marked_skb = tcp_write_queue_next(sk, not_marked_skb);
+		if (IsFack(tp) || fast_rexmit) {
+			tcp_mark_head_lost_single(sk);
+			not_marked_skb = tcp_write_queue_head(sk);
+			not_marked_skb = tcp_write_queue_next(sk, not_marked_skb);
+		}
 
 	} else {
 		unsigned int holes_seen = 0;
@@ -1854,7 +1863,7 @@ static void tcp_update_scoreboard_fack(s
 			/* Delay lookup because it might turn out unnecessary! */
 			reentry_to_highest_sack = 1;
 		} else {
-			unsigned int reord_count = 0;
+			unsigned int reord_count = IsFack(tp) ? 0 : 1;
 
 			/* Phase I: Search until TCP can mark */
 			tcp_for_write_queue_backwards_from(skb, sk) {
@@ -1864,7 +1873,7 @@ static void tcp_update_scoreboard_fack(s
 				    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
 					goto backwards_walk_done;
 
-				if (tcp_skb_timedout(sk, skb))
+				if (IsFack(tp) && tcp_skb_timedout(sk, skb))
 					break;
 				else {
 					timedout_continue = 0;
@@ -1881,13 +1890,15 @@ static void tcp_update_scoreboard_fack(s
 					holes_seen += tcp_skb_pcount(skb);
 				}
 
-				reord_count += tcp_skb_pcount(skb);
+				if (IsFack(tp) ||
+				    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+					reord_count += tcp_skb_pcount(skb);
 				if (reord_count > tp->reordering)
 					break;
 			}
 		}
 
-		if (!tcp_skb_timedout(sk, skb) &&
+		if ((!IsFack(tp) || !tcp_skb_timedout(sk, skb)) &&
 		    after(TCP_SKB_CB(skb)->seq, tp->high_seq)) {
 			/* RFC: should we have find_below? */
 			skb = tcp_write_queue_find(sk, tp->high_seq);
@@ -1914,11 +1925,11 @@ static void tcp_update_scoreboard_fack(s
 		}
 
 		/* Phase III: Nothing is still marked?, mark head then */
-		if (!tp->lost_out)
+		if ((IsFack(tp) || fast_rexmit) && !tp->lost_out)
 			tcp_mark_head_lost_single(sk);
 
 backwards_walk_done:
-		if (timedout_continue && reentry_to_highest_sack) {
+		if (IsFack(tp) && timedout_continue && reentry_to_highest_sack) {
 			/* ...do the delayed lookup */
 			skb = tcp_write_queue_find(sk, tp->highest_sack);
 			not_marked_skb = tcp_write_queue_next(sk, skb);
@@ -1926,7 +1937,7 @@ backwards_walk_done:
 	}
 
 	/* Continue with timedout work */
-	if (timedout_continue)
+	if (IsFack(tp) && timedout_continue)
 		tcp_timedout_mark_forward(sk, not_marked_skb);
 
 	tcp_sync_left_out(tp);
@@ -1934,10 +1945,10 @@ backwards_walk_done:
 
 /* Account newly detected lost packet(s) */
 static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp,
-				  u32 sack_entry_seq)
+				  u32 sack_entry_seq, int fast_rexmit)
 {
 	if (!IsReno(tp))
-		tcp_update_scoreboard_fack(sk, sack_entry_seq);
+		tcp_update_scoreboard_fack(sk, sack_entry_seq, fast_rexmit);
 	else
 		tcp_mark_head_lost_single(sk);
 }
@@ -2081,7 +2092,7 @@ static int tcp_try_undo_partial(struct s
 				int acked)
 {
 	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed = IsReno(tp) || tp->fackets_out>tp->reordering;
+	int failed = IsReno(tp) || (tcp_fackets_out(tp) > tp->reordering);
 
 	if (tcp_may_undo(tp)) {
 		/* Plain luck! Hole if filled with delayed
@@ -2212,6 +2223,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int is_dupack = (tp->snd_una == prior_snd_una && !(flag&FLAG_NOT_DUP));
+	int fast_rexmit = 0;
 
 	/* Some technical things:
 	 * 1. Reno does not count dupacks (sacked_out) automatically. */
@@ -2231,11 +2243,11 @@ tcp_fastretrans_alert(struct sock *sk, u
 		return;
 
 	/* C. Process data loss notification, provided it is valid. */
-	if ((flag&FLAG_DATA_LOST) &&
+	if (IsFack(tp) && (flag&FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-	    	tcp_update_scoreboard_fack(sk, mark_lost_entry_seq);
+	    	tcp_update_scoreboard_fack(sk, mark_lost_entry_seq, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
 
@@ -2358,10 +2370,11 @@ tcp_fastretrans_alert(struct sock *sk, u
 		tp->bytes_acked = 0;
 		tp->snd_cwnd_cnt = 0;
 		tcp_set_ca_state(sk, TCP_CA_Recovery);
+		fast_rexmit = 1;
 	}
 
-	if (is_dupack || tcp_head_timedout(sk, tp))
-		tcp_update_scoreboard(sk, tp, mark_lost_entry_seq);
+	if (is_dupack || (IsFack(tp) && tcp_head_timedout(sk, tp)))
+		tcp_update_scoreboard(sk, tp, mark_lost_entry_seq, fast_rexmit);
 	tcp_cwnd_down(sk);
 	tcp_xmit_retransmit_queue(sk);
 }
-- 
1.4.2

---696243703-1245015203-1174057876=:23854--
