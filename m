From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: increase throughput when reordering is high
Date: Wed, 21 Aug 2013 17:29:23 -0700
Message-ID: <1377131363-31341-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:36355 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab3HVA3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 20:29:45 -0400
Received: by mail-qa0-f74.google.com with SMTP id hu14so165689qab.3
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 17:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stack currently detects reordering and avoid spurious
retransmission very well. However the throughput is sub-optimal under
high reordering because cwnd is increased only if the data is deliverd
in order. I.e., FLAG_DATA_ACKED check in tcp_ack().  The more packet
are reordered the worse the throughput is.

Therefore when reordering is proven high, cwnd should advance whenever
the data is delivered regardless of its ordering. If reordering is low,
conservatively advance cwnd only on ordered deliveries in Open state,
and retain cwnd in Disordered state (RFC5681).

Using netperf on a qdisc setup of 20Mbps BW and random RTT from 45ms
to 55ms (for reordering effect). This change increases TCP throughput
by 20 - 25% to near bottleneck BW.

A special case is the stretched ACK with new SACK and/or ECE mark.
For example, a receiver may receive an out of order or ECN packet with
unacked data buffered because of LRO or delayed ACK. The principle on
such an ACK is to advance cwnd on the cummulative acked part first,
then reduce cwnd in tcp_fastretrans_alert().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e965cc7..ec492ea 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2485,8 +2485,6 @@ static void tcp_try_to_open(struct sock *sk, int flag, const int prior_unsacked)
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		tcp_try_keep_open(sk);
-		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
-			tcp_moderate_cwnd(tp);
 	} else {
 		tcp_cwnd_reduction(sk, prior_unsacked, 0);
 	}
@@ -3128,11 +3126,24 @@ static inline bool tcp_ack_is_dubious(const struct sock *sk, const int flag)
 		inet_csk(sk)->icsk_ca_state != TCP_CA_Open;
 }
 
+/* Decide wheather to run the increase function of congestion control. */
 static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
-	return (!(flag & FLAG_ECE) || tp->snd_cwnd < tp->snd_ssthresh) &&
-		!tcp_in_cwnd_reduction(sk);
+	if (tcp_in_cwnd_reduction(sk))
+		return false;
+
+	/* If reordering is high then always grow cwnd whenever data is
+	 * delivered regardless of its ordering. Otherwise stay conservative
+	 * and only grow cwnd on in-order delivery in Open state, and retain
+	 * cwnd in Disordered state (RFC5681). A stretched ACK with
+	 * new SACK or ECE mark may first advance cwnd here and later reduce
+	 * cwnd in tcp_fastretrans_alert() based on more states.
+	 */
+	if (tcp_sk(sk)->reordering > sysctl_tcp_reordering)
+		return flag & FLAG_FORWARD_PROGRESS;
+
+	return inet_csk(sk)->icsk_ca_state == TCP_CA_Open &&
+	       flag & FLAG_DATA_ACKED;
 }
 
 /* Check that window update is acceptable.
@@ -3352,18 +3363,15 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, sack_rtt);
 	acked -= tp->packets_out;
 
+	/* Advance cwnd if state allows */
+	if (tcp_may_raise_cwnd(sk, flag))
+		tcp_cong_avoid(sk, ack, prior_in_flight);
+
 	if (tcp_ack_is_dubious(sk, flag)) {
-		/* Advance CWND, if state allows this. */
-		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(sk, flag))
-			tcp_cong_avoid(sk, ack, prior_in_flight);
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
 				      is_dupack, flag);
-	} else {
-		if (flag & FLAG_DATA_ACKED)
-			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
-
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
 
-- 
1.8.3
