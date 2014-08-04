From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: reduce spurious retransmits due to transient SACK reneging
Date: Mon,  4 Aug 2014 19:12:29 -0400
Message-ID: <1407193949-14921-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:37007 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbaHDXMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 19:12:38 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so32041oac.5
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 16:12:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit reduces spurious retransmits due to apparent SACK reneging
by only reacting to SACK reneging that persists for a short delay.

When a sequence space hole at snd_una is filled, some TCP receivers
send a series of ACKs as they apparently scan their out-of-order queue
and cumulatively ACK all the packets that have now been consecutiveyly
received. This is essentially misbehavior B in "Misbehaviors in TCP
SACK generation" ACM SIGCOMM Computer Communication Review, April
2011, so we suspect that this is from several common OSes (Windows
2000, Windows Server 2003, Windows XP). However, this issue has also
been seen in other cases, e.g. the netdev thread "TCP being hoodwinked
into spurious retransmissions by lack of timestamps?" from March 2014,
where the receiver was thought to be a BSD box.

Since snd_una would temporarily be adjacent to a previously SACKed
range in these scenarios, this receiver behavior triggered the Linux
SACK reneging code path in the sender. This led the sender to clear
the SACK scoreboard, enter CA_Loss, and spuriously retransmit
(potentially) every packet from the entire write queue at line rate
just a few milliseconds before the ACK for each packet arrives at the
sender.

To avoid such situations, now when a sender sees apparent reneging it
does not yet retransmit, but rather adjusts the RTO timer to give the
receiver a little time (max(RTT/2, 10ms)) to send us some more ACKs
that will restore sanity to the SACK scoreboard. If the reneging
persists until this RTO then, as before, we clear the SACK scoreboard
and enter CA_Loss.

A 10ms delay tolerates a receiver sending such a stream of ACKs at
56Kbit/sec. And to allow for receivers with slower or more congested
paths, we wait for at least RTT/2.

We validated the resulting max(RTT/2, 10ms) delay formula with a mix
of North American and South American Google web server traffic, and
found that for ACKs displaying transient reneging:

 (1) 90% of inter-ACK delays were less than 10ms
 (2) 99% of inter-ACK delays were less than RTT/2

In tests on Google web servers this commit reduced reneging events by
75%-90% (as measured by the TcpExtTCPSACKReneging counter), without
any measurable impact on latency for user HTTP and SPDY requests.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h    |  2 +-
 net/ipv4/tcp_input.c | 29 ++++++++++++++++++-----------
 net/ipv4/tcp_timer.c |  4 ++--
 3 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0aeb2eb..dafa1cb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -411,7 +411,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   bool fastopen);
 int tcp_child_process(struct sock *parent, struct sock *child,
 		      struct sk_buff *skb);
-void tcp_enter_loss(struct sock *sk, int how);
+void tcp_enter_loss(struct sock *sk);
 void tcp_clear_retrans(struct tcp_sock *tp);
 void tcp_update_metrics(struct sock *sk);
 void tcp_init_metrics(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7832d94..6a29845 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1904,16 +1904,17 @@ void tcp_clear_retrans(struct tcp_sock *tp)
 	tp->sacked_out = 0;
 }
 
-/* Enter Loss state. If "how" is not zero, forget all SACK information
+/* Enter Loss state. If we detect SACK reneging, forget all SACK information
  * and reset tags completely, otherwise preserve SACKs. If receiver
  * dropped its ofo queue, we will know this due to reneging detection.
  */
-void tcp_enter_loss(struct sock *sk, int how)
+void tcp_enter_loss(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	bool new_recovery = false;
+	bool is_reneg;			/* is receiver reneging on SACKs? */
 
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
@@ -1934,7 +1935,11 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tcp_reset_reno_sack(tp);
 
 	tp->undo_marker = tp->snd_una;
-	if (how) {
+
+	skb = tcp_write_queue_head(sk);
+	is_reneg = skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED);
+	if (is_reneg) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSACKRENEGING);
 		tp->sacked_out = 0;
 		tp->fackets_out = 0;
 	}
@@ -1948,7 +1953,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 			tp->undo_marker = 0;
 
 		TCP_SKB_CB(skb)->sacked &= (~TCPCB_TAGBITS)|TCPCB_SACKED_ACKED;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || how) {
+		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED) || is_reneg) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
 			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			tp->lost_out += tcp_skb_pcount(skb);
@@ -1981,19 +1986,21 @@ void tcp_enter_loss(struct sock *sk, int how)
  * remembered SACKs do not reflect real state of receiver i.e.
  * receiver _host_ is heavily congested (or buggy).
  *
- * Do processing similar to RTO timeout.
+ * To avoid big spurious retransmission bursts due to transient SACK
+ * scoreboard oddities that look like reneging, we give the receiver a
+ * little time (max(RTT/2, 10ms)) to send us some more ACKs that will
+ * restore sanity to the SACK scoreboard. If the apparent reneging
+ * persists until this RTO then we'll clear the SACK scoreboard.
  */
 static bool tcp_check_sack_reneging(struct sock *sk, int flag)
 {
 	if (flag & FLAG_SACK_RENEGING) {
-		struct inet_connection_sock *icsk = inet_csk(sk);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSACKRENEGING);
+		struct tcp_sock *tp = tcp_sk(sk);
+		unsigned long delay = max(usecs_to_jiffies(tp->srtt_us >> 4),
+					  msecs_to_jiffies(10));
 
-		tcp_enter_loss(sk, 1);
-		icsk->icsk_retransmits++;
-		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  icsk->icsk_rto, TCP_RTO_MAX);
+					  delay, TCP_RTO_MAX);
 		return true;
 	}
 	return false;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 286227a..df90cd1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -391,7 +391,7 @@ void tcp_retransmit_timer(struct sock *sk)
 			tcp_write_err(sk);
 			goto out;
 		}
-		tcp_enter_loss(sk, 0);
+		tcp_enter_loss(sk);
 		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		__sk_dst_reset(sk);
 		goto out_reset_timer;
@@ -422,7 +422,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 	}
 
-	tcp_enter_loss(sk, 0);
+	tcp_enter_loss(sk);
 
 	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
 		/* Retransmission failed because of local congestion,
-- 
2.0.0.526.g5318336
