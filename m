From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 6/6] tcp: tcp_cong_control helper
Date: Tue,  2 Feb 2016 10:33:09 -0800
Message-ID: <1454437989-3842-7-git-send-email-ycheng@google.com>
References: <1454437989-3842-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33835 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965115AbcBBSdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:33:44 -0500
Received: by mail-pf0-f172.google.com with SMTP id o185so104552917pfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 10:33:43 -0800 (PST)
In-Reply-To: <1454437989-3842-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor and consolidate cwnd and rate updates into a new function
tcp_cong_control().

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 39c5326..52aa5df 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3325,6 +3325,24 @@ static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 	return flag & FLAG_DATA_ACKED;
 }
 
+/* The "ultimate" congestion control function that aims to replace the rigid
+ * cwnd increase and decrease control (tcp_cong_avoid,tcp_*cwnd_reduction).
+ * It's called toward the end of processing an ACK with precise rate
+ * information. All transmission or retransmission are delayed afterwards.
+ */
+static void tcp_cong_control(struct sock *sk, u32 ack, u32 acked_sacked,
+			     int flag)
+{
+	if (tcp_in_cwnd_reduction(sk)) {
+		/* Reduce cwnd if state mandates */
+		tcp_cwnd_reduction(sk, acked_sacked, flag);
+	} else if (tcp_may_raise_cwnd(sk, flag)) {
+		/* Advance cwnd if state allows */
+		tcp_cong_avoid(sk, ack, acked_sacked);
+	}
+	tcp_update_pacing_rate(sk);
+}
+
 /* Check that window update is acceptable.
  * The function assumes that snd_una<=ack<=snd_next.
  */
@@ -3555,7 +3573,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	int prior_packets = tp->packets_out;
 	u32 prior_delivered = tp->delivered;
 	int acked = 0; /* Number of packets newly acked */
-	u32 acked_sacked; /* Number of packets newly acked or sacked */
 	int rexmit = REXMIT_NONE; /* Flag to (re)transmit to recover losses */
 
 	sack_state.first_sackt.v64 = 0;
@@ -3655,16 +3672,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
 
-	acked_sacked = tp->delivered - prior_delivered;
-	/* Advance cwnd if state allows */
-	if (tcp_in_cwnd_reduction(sk)) {
-		/* Reduce cwnd if state mandates */
-		tcp_cwnd_reduction(sk, acked_sacked, flag);
-	} else if (tcp_may_raise_cwnd(sk, flag)) {
-		/* Advance cwnd if state allows */
-		tcp_cong_avoid(sk, ack, acked_sacked);
-	}
-
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
 		struct dst_entry *dst = __sk_dst_get(sk);
 		if (dst)
@@ -3673,7 +3680,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
 		tcp_schedule_loss_probe(sk);
-	tcp_update_pacing_rate(sk);
+	tcp_cong_control(sk, ack, tp->delivered - prior_delivered, flag);
 	tcp_xmit_recovery(sk, rexmit);
 	return 1;
 
-- 
2.7.0.rc3.207.g0ac5344
