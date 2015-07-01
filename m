From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/2 net-next] tcp: reduce cwnd if retransmit is lost in CA_Loss
Date: Wed,  1 Jul 2015 14:11:14 -0700
Message-ID: <1435785075-20600-2-git-send-email-ycheng@google.com>
References: <1435785075-20600-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36171 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbbGAVLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 17:11:24 -0400
Received: by igrv9 with SMTP id v9so83260367igr.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 14:11:23 -0700 (PDT)
In-Reply-To: <1435785075-20600-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the retransmission in CA_Loss is lost again, we should not
continue to slow start or raise cwnd in congestion avoidance mode.
Instead we should enter fast recovery and use PRR to reduce cwnd,
following the principle in RFC5681:

"... or the loss of a retransmission, should be taken as two
 indications of congestion and, therefore, cwnd (and ssthresh) MUST
 be lowered twice in this case."

This is especially important to reduce loss when the CA_Loss
state was caused by a traffic policer dropping the entire inflight.
The CA_Loss state has a problem where a loss of L packets causes the
sender to send a burst of L packets. So a policer that's dropping
most packets in a given RTT can cause a huge retransmit storm. By
contrast, PRR includes logic to bound the number of outbound packets
that result from a given ACK. So switching to CA_Recovery on lost
retransmits in CA_Loss avoids this retransmit storm problem when
in CA_Loss.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 684f095..923e0e5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -109,6 +109,7 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define FLAG_SYN_ACKED		0x10 /* This ACK acknowledged SYN.		*/
 #define FLAG_DATA_SACKED	0x20 /* New SACK.				*/
 #define FLAG_ECE		0x40 /* ECE in this ACK				*/
+#define FLAG_LOST_RETRANS	0x80 /* This ACK marks some retransmission lost */
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
 #define FLAG_ORIG_SACK_ACKED	0x200 /* Never retransmitted data are (s)acked	*/
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
@@ -1037,7 +1038,7 @@ static bool tcp_is_sackblock_valid(struct tcp_sock *tp, bool is_dsack,
  * highest SACK block). Also calculate the lowest snd_nxt among the remaining
  * retransmitted skbs to avoid some costly processing per ACKs.
  */
-static void tcp_mark_lost_retrans(struct sock *sk)
+static void tcp_mark_lost_retrans(struct sock *sk, int *flag)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1078,7 +1079,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		if (after(received_upto, ack_seq)) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -= tcp_skb_pcount(skb);
-
+			*flag |= FLAG_LOST_RETRANS;
 			tcp_skb_mark_lost_uncond_verify(tp, skb);
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
@@ -1818,7 +1819,7 @@ advance_sp:
 	    ((inet_csk(sk)->icsk_ca_state != TCP_CA_Loss) || tp->undo_marker))
 		tcp_update_reordering(sk, tp->fackets_out - state->reord, 0);
 
-	tcp_mark_lost_retrans(sk);
+	tcp_mark_lost_retrans(sk, &state->flag);
 	tcp_verify_left_out(tp);
 out:
 
@@ -2676,7 +2677,7 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 	tp->prior_ssthresh = 0;
 	tcp_init_undo(tp);
 
-	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
+	if (!tcp_in_cwnd_reduction(sk)) {
 		if (!ece_ack)
 			tp->prior_ssthresh = tcp_current_ssthresh(sk);
 		tcp_init_cwnd_reduction(sk);
@@ -2852,9 +2853,10 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack);
-		if (icsk->icsk_ca_state != TCP_CA_Open)
+		if (icsk->icsk_ca_state != TCP_CA_Open &&
+		    !(flag & FLAG_LOST_RETRANS))
 			return;
-		/* Fall through to processing in Open state. */
+		/* Change state if cwnd is undone or retransmits are lost */
 	default:
 		if (tcp_is_reno(tp)) {
 			if (flag & FLAG_SND_UNA_ADVANCED)
-- 
2.4.3.573.g4eafbef
