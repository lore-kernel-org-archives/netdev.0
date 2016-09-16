From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 04/14] tcp: count packets marked lost for a TCP connection
Date: Fri, 16 Sep 2016 14:48:53 -0400
Message-ID: <1474051743-13311-5-git-send-email-ncardwell@google.com>
References: <1474051743-13311-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:35412 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762137AbcIPStu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 14:49:50 -0400
Received: by mail-qt0-f171.google.com with SMTP id 93so47226370qtg.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:49:49 -0700 (PDT)
In-Reply-To: <1474051743-13311-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Count the number of packets that a TCP connection marks lost.

Congestion control modules can use this loss rate information for more
intelligent decisions about how fast to send.

Specifically, this is used in TCP BBR policer detection. BBR uses a
high packet loss rate as one signal in its policer detection and
policer bandwidth estimation algorithm.

The BBR policer detection algorithm cannot simply track retransmits,
because a retransmit can be (and often is) an indicator of packets
lost long, long ago. This is particularly true in a long CA_Loss
period that repairs the initial massive losses when a policer kicks
in.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/linux/tcp.h  |  1 +
 net/ipv4/tcp_input.c | 25 ++++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 6433cc8..38590fb 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -267,6 +267,7 @@ struct tcp_sock {
 				 * receiver in Recovery. */
 	u32	prr_out;	/* Total number of pkts sent during Recovery. */
 	u32	delivered;	/* Total data packets delivered incl. rexmits */
+	u32	lost;		/* Total data packets lost incl. rexmits */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ac5b38f..024b579 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -899,12 +899,29 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_buff *skb)
 		tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
 }
 
+/* Sum the number of packets on the wire we have marked as lost.
+ * There are two cases we care about here:
+ * a) Packet hasn't been marked lost (nor retransmitted),
+ *    and this is the first loss.
+ * b) Packet has been marked both lost and retransmitted,
+ *    and this means we think it was lost again.
+ */
+static void tcp_sum_lost(struct tcp_sock *tp, struct sk_buff *skb)
+{
+	__u8 sacked = TCP_SKB_CB(skb)->sacked;
+
+	if (!(sacked & TCPCB_LOST) ||
+	    ((sacked & TCPCB_LOST) && (sacked & TCPCB_SACKED_RETRANS)))
+		tp->lost += tcp_skb_pcount(skb);
+}
+
 static void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 		tcp_verify_retransmit_hint(tp, skb);
 
 		tp->lost_out += tcp_skb_pcount(skb);
+		tcp_sum_lost(tp, skb);
 		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 	}
 }
@@ -913,6 +930,7 @@ void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	tcp_verify_retransmit_hint(tp, skb);
 
+	tcp_sum_lost(tp, skb);
 	if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_LOST|TCPCB_SACKED_ACKED))) {
 		tp->lost_out += tcp_skb_pcount(skb);
 		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
@@ -1890,6 +1908,7 @@ void tcp_enter_loss(struct sock *sk)
 	struct sk_buff *skb;
 	bool new_recovery = icsk->icsk_ca_state < TCP_CA_Recovery;
 	bool is_reneg;			/* is receiver reneging on SACKs? */
+	bool mark_lost;
 
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
@@ -1923,8 +1942,12 @@ void tcp_enter_loss(struct sock *sk)
 		if (skb == tcp_send_head(sk))
 			break;
 
+		mark_lost = (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) ||
+			     is_reneg);
+		if (mark_lost)
+			tcp_sum_lost(tp, skb);
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || is_reneg) {
+		if (mark_lost) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
-- 
2.8.0.rc3.226.g39d4020
