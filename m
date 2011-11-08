From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during fast recovery
Date: Tue,  8 Nov 2011 13:07:11 -0500
Message-ID: <1320775631-16341-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:44159 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756211Ab1KHSHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 13:07:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes for some issues that prevent DSACKs from allowing TCP senders to
undo cwnd reductions made during fast recovery.

There were a few related bugs/issues:

1) Senders ignored DSACKs after recovery when there were no
outstanding packets (a common scenario for HTTP servers).

2) When the ACK field is below snd_una (which can happen when ACKs are
reordered), senders ignored DSACKs (preventing undo) and passed up
chances to send out more packets based on any newly-SACKed packets.

3) Senders were overriding cwnd values picked during an undo by
calling tcp_moderate_cwnd() in tcp_try_to_open().

The fixes:

(1) When there are no outstanding packets (the "no_queue" goto label),
use DSACKs to undo congestion window reductions.

(2) When the ACK field is below snd_una (the "old_ack" goto label),
process any DSACKs and try to send out more packets based on
newly-SACKed packets.

(3) Don't moderate cwnd in tcp_try_to_open() if we're in TCP_CA_Open,
since doing so is generally unnecessary and specifically would
override a DSACK-based undo of a cwnd reduction made in fast recovery.

(4) Simplify the congestion avoidance state machine by removing the
behavior where SACK-enabled connections hung around in the
TCP_CA_Disorder state just waiting for DSACKs. Instead, when snd_una
advances to high_seq or beyond we typically move to TCP_CA_Open
immediately and allow an undo in either TCP_CA_Open or TCP_CA_Disorder
if we later receive enough DSACKs. Previously, SACK-enabled
connections hung around in TCP_CA_Disorder state while
snd_una==high_seq, just waiting to accumulate DSACKs and hopefully
undo a cwnd reduction. This could and did lead to the following
unfortunate scenario: if some incoming ACKs advance snd_una beyond
high_seq then we were setting undo_marker to 0 and moving to
TCP_CA_Open, so if (due to reordering in the ACK return path) we
shortly thereafter received a DSACK then we were no longer able to
undo the cwnd reduction.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   44 +++++++++++++++++++++++---------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..78dd38c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2858,7 +2858,7 @@ static void tcp_try_keep_open(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int state = TCP_CA_Open;
 
-	if (tcp_left_out(tp) || tcp_any_retrans_done(sk) || tp->undo_marker)
+	if (tcp_left_out(tp) || tcp_any_retrans_done(sk))
 		state = TCP_CA_Disorder;
 
 	if (inet_csk(sk)->icsk_ca_state != state) {
@@ -2881,7 +2881,8 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		tcp_try_keep_open(sk);
-		tcp_moderate_cwnd(tp);
+		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
+			tcp_moderate_cwnd(tp);
 	} else {
 		tcp_cwnd_down(sk, flag);
 	}
@@ -3009,11 +3010,11 @@ static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
  * tcp_xmit_retransmit_queue().
  */
 static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
-				  int newly_acked_sacked, int flag)
+				  int newly_acked_sacked, bool is_dupack,
+				  int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	int is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0, mib_idx;
@@ -3066,17 +3067,6 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 			}
 			break;
 
-		case TCP_CA_Disorder:
-			tcp_try_undo_dsack(sk);
-			if (!tp->undo_marker ||
-			    /* For SACK case do not Open to allow to undo
-			     * catching for all duplicate ACKs. */
-			    tcp_is_reno(tp) || tp->snd_una != tp->high_seq) {
-				tp->undo_marker = 0;
-				tcp_set_ca_state(sk, TCP_CA_Open);
-			}
-			break;
-
 		case TCP_CA_Recovery:
 			if (tcp_is_reno(tp))
 				tcp_reset_reno_sack(tp);
@@ -3117,7 +3107,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 				tcp_add_reno_sack(sk);
 		}
 
-		if (icsk->icsk_ca_state == TCP_CA_Disorder)
+		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
 
 		if (!tcp_time_to_recover(sk)) {
@@ -3681,10 +3671,12 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 prior_snd_una = tp->snd_una;
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
+	bool is_dupack = false;
 	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets;
 	int prior_sacked = tp->sacked_out;
+	int pkts_acked = 0;
 	int newly_acked_sacked = 0;
 	int frto_cwnd = 0;
 
@@ -3757,6 +3749,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
 
+	pkts_acked = prior_packets - tp->packets_out;
 	newly_acked_sacked = (prior_packets - prior_sacked) -
 			     (tp->packets_out - tp->sacked_out);
 
@@ -3771,8 +3764,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack, prior_in_flight);
-		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out,
-				      newly_acked_sacked, flag);
+		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
@@ -3784,6 +3778,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	return 1;
 
 no_queue:
+	/* If data was DSACKed, see if we can undo a cwnd reduction. */
+	if (flag & FLAG_DSACKING_ACK)
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
@@ -3797,10 +3795,14 @@ invalid_ack:
 	return -1;
 
 old_ack:
+	/* If data was SACKed, tag it and see if we should send more data.
+	 * If data was DSACKed, see if we can undo a cwnd reduction.
+	 */
 	if (TCP_SKB_CB(skb)->sacked) {
-		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
-		if (icsk->icsk_ca_state == TCP_CA_Open)
-			tcp_try_keep_open(sk);
+		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+		newly_acked_sacked = tp->sacked_out - prior_sacked;
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	}
 
 	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
1.7.3.1
