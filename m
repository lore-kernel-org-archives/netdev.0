From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: improve undo on timeout
Date: Fri, 22 Aug 2014 14:15:22 -0700
Message-ID: <1408742122-23674-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:58268 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaHVVPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 17:15:52 -0400
Received: by mail-pd0-f201.google.com with SMTP id g10so2945974pdj.4
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 14:15:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon timeout, undo (via both timestamps/Eifel and DSACKs) was
disabled if any retransmits were still in flight.  The concern was
perhaps that spurious retransmission sent in a previous recovery
episode may trigger DSACKs to falsely undo the current recovery.

However, this inadvertently misses undo opportunities (using either
TCP timestamps or DSACKs) when timeout occurs during a loss episode,
i.e.  recurring timeouts or timeout during fast recovery. In these
cases some retransmissions will be in flight but we should allow
undo. Furthermore, we should only reset undo_marker and undo_retrans
upon timeout if we are starting a new recovery episode. Finally,
when we do reset our undo state, we now do so in a manner similar
to tcp_enter_recovery(), so that we require a DSACK for each of
the outstsanding retransmissions. This will achieve the original
goal by requiring that we receive the same number of DSACKs as
retransmissions.

This patch increases the undo events by 50% on Google servers.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h  |  2 +-
 net/ipv4/tcp_input.c | 26 +++++++++++---------------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fa5258f..e567f0d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -276,7 +276,7 @@ struct tcp_sock {
 	u32	retrans_stamp;	/* Timestamp of the last retransmit,
 				 * also used in SYN-SENT to remember stamp of
 				 * the first SYN. */
-	u32	undo_marker;	/* tracking retrans started here. */
+	u32	undo_marker;	/* snd_una upon a new recovery episode. */
 	int	undo_retrans;	/* number of undoable retransmissions. */
 	u32	total_retrans;	/* Total retransmits for entire connection */
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a906e02..aba4926 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1888,21 +1888,21 @@ static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 	tp->sacked_out = 0;
 }
 
-static void tcp_clear_retrans_partial(struct tcp_sock *tp)
+void tcp_clear_retrans(struct tcp_sock *tp)
 {
 	tp->retrans_out = 0;
 	tp->lost_out = 0;
-
 	tp->undo_marker = 0;
 	tp->undo_retrans = -1;
+	tp->fackets_out = 0;
+	tp->sacked_out = 0;
 }
 
-void tcp_clear_retrans(struct tcp_sock *tp)
+static inline void tcp_init_undo(struct tcp_sock *tp)
 {
-	tcp_clear_retrans_partial(tp);
-
-	tp->fackets_out = 0;
-	tp->sacked_out = 0;
+	tp->undo_marker = tp->snd_una;
+	/* Retransmission still in flight may cause DSACKs later. */
+	tp->undo_retrans = tp->retrans_out ? : -1;
 }
 
 /* Enter Loss state. If we detect SACK reneging, forget all SACK information
@@ -1925,18 +1925,18 @@ void tcp_enter_loss(struct sock *sk)
 		tp->prior_ssthresh = tcp_current_ssthresh(sk);
 		tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
 		tcp_ca_event(sk, CA_EVENT_LOSS);
+		tcp_init_undo(tp);
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 
-	tcp_clear_retrans_partial(tp);
+	tp->retrans_out = 0;
+	tp->lost_out = 0;
 
 	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
 
-	tp->undo_marker = tp->snd_una;
-
 	skb = tcp_write_queue_head(sk);
 	is_reneg = skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED);
 	if (is_reneg) {
@@ -1950,9 +1950,6 @@ void tcp_enter_loss(struct sock *sk)
 		if (skb == tcp_send_head(sk))
 			break;
 
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
-			tp->undo_marker = 0;
-
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
 		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || is_reneg) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
@@ -2671,8 +2668,7 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 	NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
 	tp->prior_ssthresh = 0;
-	tp->undo_marker = tp->snd_una;
-	tp->undo_retrans = tp->retrans_out ? : -1;
+	tcp_init_undo(tp);
 
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		if (!ece_ack)
-- 
2.1.0.rc2.206.gedb03e5
