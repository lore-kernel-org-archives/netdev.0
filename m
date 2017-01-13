From: Yuchung Cheng <ycheng@google.com>
Subject: [net-next 09/13] tcp: remove forward retransmit feature
Date: Thu, 12 Jan 2017 22:03:50 -0800
Message-ID: <20170113060354.85234-10-ycheng@google.com>
References: <20170113060354.85234-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35969 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdAMGE2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:04:28 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so25841304pfu.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:04:28 -0800 (PST)
In-Reply-To: <20170113060354.85234-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forward retransmit is an esoteric feature in RFC3517 (condition(3)
in the NextSeg()). Basically if a packet is not considered lost by
the current criteria (# of dupacks etc), but the congestion window
has room for more packets, then retransmit this packet.

However it actually conflicts with the rest of recovery design. For
example, when reordering is detected we want to be conservative
in retransmitting packets but forward-retransmit feature would
break that to force more retransmission. Also the implementation is
fairly complicated inside the retransmission logic inducing extra
iterations in the write queue. With RACK losses are being detected
timely and this heuristic is no longer necessary. There this patch
removes the feature.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h   |  1 -
 net/ipv4/tcp_input.c  |  5 -----
 net/ipv4/tcp_output.c | 61 +++------------------------------------------------
 3 files changed, 3 insertions(+), 64 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 970d5f00589f..8e5f4c15d0e5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -307,7 +307,6 @@ struct tcp_sock {
 					 */
 
 	int     lost_cnt_hint;
-	u32     retransmit_high;	/* L-bits may be on up to this seqno */
 
 	u32	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9469ce384d3b..a041a92348ee 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -916,10 +916,6 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_buff *skb)
 	    before(TCP_SKB_CB(skb)->seq,
 		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
 		tp->retransmit_skb_hint = skb;
-
-	if (!tp->lost_out ||
-	    after(TCP_SKB_CB(skb)->end_seq, tp->retransmit_high))
-		tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
 }
 
 /* Sum the number of packets on the wire we have marked as lost.
@@ -1983,7 +1979,6 @@ void tcp_enter_loss(struct sock *sk)
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
-			tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
 		}
 	}
 	tcp_verify_left_out(tp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0ba9026cb70d..6327e4d368a4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2831,36 +2831,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 	return err;
 }
 
-/* Check if we forward retransmits are possible in the current
- * window/congestion state.
- */
-static bool tcp_can_forward_retransmit(struct sock *sk)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	const struct tcp_sock *tp = tcp_sk(sk);
-
-	/* Forward retransmissions are possible only during Recovery. */
-	if (icsk->icsk_ca_state != TCP_CA_Recovery)
-		return false;
-
-	/* No forward retransmissions in Reno are possible. */
-	if (tcp_is_reno(tp))
-		return false;
-
-	/* Yeah, we have to make difficult choice between forward transmission
-	 * and retransmission... Both ways have their merits...
-	 *
-	 * For now we do not retransmit anything, while we have some new
-	 * segments to send. In the other cases, follow rule 3 for
-	 * NextSeg() specified in RFC3517.
-	 */
-
-	if (tcp_may_send_now(sk))
-		return false;
-
-	return true;
-}
-
 /* This gets called after a retransmit timeout, and the initially
  * retransmitted data is acknowledged.  It tries to continue
  * resending the rest of the retransmit queue, until either
@@ -2875,24 +2845,16 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	struct sk_buff *hole = NULL;
-	u32 max_segs, last_lost;
+	u32 max_segs;
 	int mib_idx;
-	int fwd_rexmitting = 0;
 
 	if (!tp->packets_out)
 		return;
 
-	if (!tp->lost_out)
-		tp->retransmit_high = tp->snd_una;
-
 	if (tp->retransmit_skb_hint) {
 		skb = tp->retransmit_skb_hint;
-		last_lost = TCP_SKB_CB(skb)->end_seq;
-		if (after(last_lost, tp->retransmit_high))
-			last_lost = tp->retransmit_high;
 	} else {
 		skb = tcp_write_queue_head(sk);
-		last_lost = tp->snd_una;
 	}
 
 	max_segs = tcp_tso_segs(sk, tcp_current_mss(sk));
@@ -2915,31 +2877,14 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		 */
 		segs = min_t(int, segs, max_segs);
 
-		if (fwd_rexmitting) {
-begin_fwd:
-			if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-				break;
-			mib_idx = LINUX_MIB_TCPFORWARDRETRANS;
-
-		} else if (!before(TCP_SKB_CB(skb)->seq, tp->retransmit_high)) {
-			tp->retransmit_high = last_lost;
-			if (!tcp_can_forward_retransmit(sk))
-				break;
-			/* Backtrack if necessary to non-L'ed skb */
-			if (hole) {
-				skb = hole;
-				hole = NULL;
-			}
-			fwd_rexmitting = 1;
-			goto begin_fwd;
-
+		if (tp->retrans_out >= tp->lost_out) {
+			break;
 		} else if (!(sacked & TCPCB_LOST)) {
 			if (!hole && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
 				hole = skb;
 			continue;
 
 		} else {
-			last_lost = TCP_SKB_CB(skb)->end_seq;
 			if (icsk->icsk_ca_state != TCP_CA_Loss)
 				mib_idx = LINUX_MIB_TCPFASTRETRANS;
 			else
-- 
2.11.0.483.g087da7b7c-goog
