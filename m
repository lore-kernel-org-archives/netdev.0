From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 3/7] tcp: remove tcp_mark_lost_retrans()
Date: Fri, 16 Oct 2015 21:57:43 -0700
Message-ID: <1445057867-32257-4-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34317 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbbJQE6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:05 -0400
Received: by pabws5 with SMTP id ws5so8324233pab.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:05 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the existing lost retransmit detection because RACK subsumes
it completely. This also stops the overloading the ack_seq field of
the skb control block.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h   |  2 --
 net/ipv4/tcp_input.c  | 65 ---------------------------------------------------
 net/ipv4/tcp_output.c |  6 -----
 3 files changed, 73 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 90edef5..8c54863 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -283,8 +283,6 @@ struct tcp_sock {
 	int     lost_cnt_hint;
 	u32     retransmit_high;	/* L-bits may be on up to this seqno */
 
-	u32	lost_retrans_low;	/* Sent seq after any rxmit (lowest) */
-
 	u32	prior_ssthresh; /* ssthresh saved at recovery start	*/
 	u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e177386..5ad08d8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1048,70 +1048,6 @@ static bool tcp_is_sackblock_valid(struct tcp_sock *tp, bool is_dsack,
 	return !before(start_seq, end_seq - tp->max_window);
 }
 
-/* Check for lost retransmit. This superb idea is borrowed from "ratehalving".
- * Event "B". Later note: FACK people cheated me again 8), we have to account
- * for reordering! Ugly, but should help.
- *
- * Search retransmitted skbs from write_queue that were sent when snd_nxt was
- * less than what is now known to be received by the other end (derived from
- * highest SACK block). Also calculate the lowest snd_nxt among the remaining
- * retransmitted skbs to avoid some costly processing per ACKs.
- */
-static void tcp_mark_lost_retrans(struct sock *sk, int *flag)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-	int cnt = 0;
-	u32 new_low_seq = tp->snd_nxt;
-	u32 received_upto = tcp_highest_sack_seq(tp);
-
-	if (!tcp_is_fack(tp) || !tp->retrans_out ||
-	    !after(received_upto, tp->lost_retrans_low) ||
-	    icsk->icsk_ca_state != TCP_CA_Recovery)
-		return;
-
-	tcp_for_write_queue(skb, sk) {
-		u32 ack_seq = TCP_SKB_CB(skb)->ack_seq;
-
-		if (skb == tcp_send_head(sk))
-			break;
-		if (cnt == tp->retrans_out)
-			break;
-		if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
-			continue;
-
-		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
-			continue;
-
-		/* TODO: We would like to get rid of tcp_is_fack(tp) only
-		 * constraint here (see above) but figuring out that at
-		 * least tp->reordering SACK blocks reside between ack_seq
-		 * and received_upto is not easy task to do cheaply with
-		 * the available datastructures.
-		 *
-		 * Whether FACK should check here for tp->reordering segs
-		 * in-between one could argue for either way (it would be
-		 * rather simple to implement as we could count fack_count
-		 * during the walk and do tp->fackets_out - fack_count).
-		 */
-		if (after(received_upto, ack_seq)) {
-			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-			tp->retrans_out -= tcp_skb_pcount(skb);
-			*flag |= FLAG_LOST_RETRANS;
-			tcp_skb_mark_lost_uncond_verify(tp, skb);
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
-		} else {
-			if (before(ack_seq, new_low_seq))
-				new_low_seq = ack_seq;
-			cnt += tcp_skb_pcount(skb);
-		}
-	}
-
-	if (tp->retrans_out)
-		tp->lost_retrans_low = new_low_seq;
-}
-
 static bool tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
 			    struct tcp_sack_block_wire *sp, int num_sacks,
 			    u32 prior_snd_una)
@@ -1838,7 +1774,6 @@ advance_sp:
 	    ((inet_csk(sk)->icsk_ca_state != TCP_CA_Loss) || tp->undo_marker))
 		tcp_update_reordering(sk, tp->fackets_out - state->reord, 0);
 
-	tcp_mark_lost_retrans(sk, &state->flag);
 	tcp_verify_left_out(tp);
 out:
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6e79fcb..49730e5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2655,8 +2655,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 			net_dbg_ratelimited("retrans_out leaked\n");
 		}
 #endif
-		if (!tp->retrans_out)
-			tp->lost_retrans_low = tp->snd_nxt;
 		TCP_SKB_CB(skb)->sacked |= TCPCB_RETRANS;
 		tp->retrans_out += tcp_skb_pcount(skb);
 
@@ -2664,10 +2662,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (!tp->retrans_stamp)
 			tp->retrans_stamp = tcp_skb_timestamp(skb);
 
-		/* snd_nxt is stored to detect loss of retransmitted segment,
-		 * see tcp_input.c tcp_sacktag_write_queue().
-		 */
-		TCP_SKB_CB(skb)->ack_seq = tp->snd_nxt;
 	} else if (err != -EBUSY) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
-- 
2.6.0.rc2.230.g3dd15c0
