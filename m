From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: implement TSQ for retransmits
Date: Tue, 20 Sep 2016 22:45:58 -0700
Message-ID: <1474436758.23058.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474424880.23058.65.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35653 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbcIUFqC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 01:46:02 -0400
Received: by mail-pa0-f65.google.com with SMTP id hi10so1808414pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 22:46:01 -0700 (PDT)
In-Reply-To: <1474424880.23058.65.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We saw sch_fq drops caused by the per flow limit of 100 packets and TCP
when dealing with large cwnd and bursts of retransmits.

Even after increasing the limit to 1000, and even after commit
10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time"),
we can still have these drops.

Under certain conditions, TCP can spend a considerable amount of
time queuing thousands of skbs in a single tcp_xmit_retransmit_queue()
invocation, incurring latency spikes and stalls of other softirq
handlers.

This patch implements TSQ for retransmits, limiting number of packets
and giving more chance for scheduling packets in both ways.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |   72 ++++++++++++++++++++++++++--------------
 1 file changed, 47 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d025a7804b597465564f0980f2ac069d6c61d27..478dfc53917815d30838a21b1adc2ea7096425af 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -734,9 +734,16 @@ static void tcp_tsq_handler(struct sock *sk)
 {
 	if ((1 << sk->sk_state) &
 	    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_CLOSING |
-	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK))
-		tcp_write_xmit(sk, tcp_current_mss(sk), tcp_sk(sk)->nonagle,
+	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+
+		if (tp->lost_out > tp->retrans_out &&
+		    tp->snd_cwnd > tcp_packets_in_flight(tp))
+			tcp_xmit_retransmit_queue(sk);
+
+		tcp_write_xmit(sk, tcp_current_mss(sk), tp->nonagle,
 			       0, GFP_ATOMIC);
+	}
 }
 /*
  * One tasklet per cpu tries to send more skbs.
@@ -2039,6 +2046,39 @@ static int tcp_mtu_probe(struct sock *sk)
 	return -1;
 }
 
+/* TCP Small Queues :
+ * Control number of packets in qdisc/devices to two packets / or ~1 ms.
+ * (These limits are doubled for retransmits)
+ * This allows for :
+ *  - better RTT estimation and ACK scheduling
+ *  - faster recovery
+ *  - high rates
+ * Alas, some drivers / subsystems require a fair amount
+ * of queued bytes to ensure line rate.
+ * One example is wifi aggregation (802.11 AMPDU)
+ */
+static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
+				  unsigned int factor)
+{
+	unsigned int limit;
+
+	limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+	limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
+	limit <<= factor;
+
+	if (atomic_read(&sk->sk_wmem_alloc) > limit) {
+		set_bit(TSQ_THROTTLED, &tcp_sk(sk)->tsq_flags);
+		/* It is possible TX completion already happened
+		 * before we set TSQ_THROTTLED, so we must
+		 * test again the condition.
+		 */
+		smp_mb__after_atomic();
+		if (atomic_read(&sk->sk_wmem_alloc) > limit)
+			return true;
+	}
+	return false;
+}
+
 /* This routine writes packets to the network.  It advances the
  * send_head.  This happens as incoming acks open up the remote
  * window for us.
@@ -2125,29 +2165,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
 			break;
 
-		/* TCP Small Queues :
-		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
-		 * This allows for :
-		 *  - better RTT estimation and ACK scheduling
-		 *  - faster recovery
-		 *  - high rates
-		 * Alas, some drivers / subsystems require a fair amount
-		 * of queued bytes to ensure line rate.
-		 * One example is wifi aggregation (802.11 AMPDU)
-		 */
-		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
-		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
-
-		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
-			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
-			/* It is possible TX completion already happened
-			 * before we set TSQ_THROTTLED, so we must
-			 * test again the condition.
-			 */
-			smp_mb__after_atomic();
-			if (atomic_read(&sk->sk_wmem_alloc) > limit)
-				break;
-		}
+		if (tcp_small_queue_check(sk, skb, 0))
+			break;
 
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
@@ -2847,6 +2866,9 @@ begin_fwd:
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
 
+		if (tcp_small_queue_check(sk, skb, 1))
+			return;
+
 		if (tcp_retransmit_skb(sk, skb, segs))
 			return;
 
