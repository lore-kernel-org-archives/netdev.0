From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] tcp-tso: do not split TSO packets at retransmit time
Date: Mon, 18 Apr 2016 13:56:12 -0700
Message-ID: <1461012972-15757-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34247 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbcDRU4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 16:56:17 -0400
Received: by mail-pf0-f177.google.com with SMTP id c20so84359049pfc.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 13:56:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux TCP stack painfully segments all TSO/GSO packets before retransmits.

This was fine back in the days when TSO/GSO were emerging, with their
bugs, but we believe the dark age is over.

Keeping big packets in write queues, but also in stack traversal
has a lot of benefits.
 - Less memory overhead, because write queues have less skbs
 - Less cpu overhead at ACK processing.
 - Better SACK processing, as lot of studies mentioned how
   awful linux was at this ;)
 - Less cpu overhead to send the rtx packets
   (IP stack traversal, netfilter traversal, qdisc, drivers...)
 - Better latencies in presence of losses.
 - Smaller spikes in fq like packet schedulers, as retransmits
   are not constrained by TCP Small Queues.

1 % packet losses are common today, and at 100Gbit speeds, this
translates to ~80,000 losses per second. If we are unlucky and
first MSS of a 45-MSS TSO is lost, we are cooking 44 MSS segments
at rtx instead of a single 44-MSS TSO packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |  4 ++--
 net/ipv4/tcp_input.c  |  2 +-
 net/ipv4/tcp_output.c | 64 +++++++++++++++++++++++----------------------------
 net/ipv4/tcp_timer.c  |  4 ++--
 4 files changed, 34 insertions(+), 40 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fd40f8c64d5f..0dc272dcd772 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -538,8 +538,8 @@ __u32 cookie_v6_init_sequence(const struct sk_buff *skb, __u16 *mss);
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle);
 bool tcp_may_send_now(struct sock *sk);
-int __tcp_retransmit_skb(struct sock *, struct sk_buff *);
-int tcp_retransmit_skb(struct sock *, struct sk_buff *);
+int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs);
+int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs);
 void tcp_retransmit_timer(struct sock *sk);
 void tcp_xmit_retransmit_queue(struct sock *);
 void tcp_simple_retransmit(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 90e0d9256b74..729e489b5608 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5543,7 +5543,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	if (data) { /* Retransmit unacked data in SYN */
 		tcp_for_write_queue_from(data, sk) {
 			if (data == tcp_send_head(sk) ||
-			    __tcp_retransmit_skb(sk, data))
+			    __tcp_retransmit_skb(sk, data, 1))
 				break;
 		}
 		tcp_rearm_rto(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6451b83d81e9..4876b256a70a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2266,7 +2266,7 @@ void tcp_send_loss_probe(struct sock *sk)
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
 		goto rearm_timer;
 
-	if (__tcp_retransmit_skb(sk, skb))
+	if (__tcp_retransmit_skb(sk, skb, 1))
 		goto rearm_timer;
 
 	/* Record snd_nxt for loss detection. */
@@ -2551,17 +2551,17 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
  * state updates are done by the caller.  Returns non-zero if an
  * error occurred which prevented the send.
  */
-int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
+int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int cur_mss;
-	int err;
+	int diff, len, err;
+
 
-	/* Inconslusive MTU probe */
-	if (icsk->icsk_mtup.probe_size) {
+	/* Inconclusive MTU probe */
+	if (icsk->icsk_mtup.probe_size)
 		icsk->icsk_mtup.probe_size = 0;
-	}
 
 	/* Do not sent more than we queued. 1/4 is reserved for possible
 	 * copying overhead: fragmentation, tunneling, mangling etc.
@@ -2594,30 +2594,27 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    TCP_SKB_CB(skb)->seq != tp->snd_una)
 		return -EAGAIN;
 
-	if (skb->len > cur_mss) {
-		if (tcp_fragment(sk, skb, cur_mss, cur_mss, GFP_ATOMIC))
+	len = cur_mss * segs;
+	if (skb->len > len) {
+		if (tcp_fragment(sk, skb, len, cur_mss, GFP_ATOMIC))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
-		int oldpcount = tcp_skb_pcount(skb);
+		if (skb_unclone(skb, GFP_ATOMIC))
+			return -ENOMEM;
 
-		if (unlikely(oldpcount > 1)) {
-			if (skb_unclone(skb, GFP_ATOMIC))
-				return -ENOMEM;
-			tcp_init_tso_segs(skb, cur_mss);
-			tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
-		}
+		diff = tcp_skb_pcount(skb);
+		tcp_set_skb_tso_segs(skb, cur_mss);
+		diff -= tcp_skb_pcount(skb);
+		if (diff)
+			tcp_adjust_pcount(sk, skb, diff);
+		if (skb->len < cur_mss)
+			tcp_retrans_try_collapse(sk, skb, cur_mss);
 	}
 
 	/* RFC3168, section 6.1.1.1. ECN fallback */
 	if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN_ECN) == TCPHDR_SYN_ECN)
 		tcp_ecn_clear_syn(sk, skb);
 
-	tcp_retrans_try_collapse(sk, skb, cur_mss);
-
-	/* Make a copy, if the first transmission SKB clone we made
-	 * is still in somebody's hands, else make a clone.
-	 */
-
 	/* make sure skb->data is aligned on arches that require it
 	 * and check if ack-trimming & collapsing extended the headroom
 	 * beyond what csum_start can cover.
@@ -2633,20 +2630,22 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (likely(!err)) {
+		segs = tcp_skb_pcount(skb);
+
 		TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
 		/* Update global TCP statistics. */
-		TCP_INC_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS);
+		TCP_ADD_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS, segs);
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
-		tp->total_retrans++;
+		tp->total_retrans += segs;
 	}
 	return err;
 }
 
-int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
+int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int err = __tcp_retransmit_skb(sk, skb);
+	int err = __tcp_retransmit_skb(sk, skb, segs);
 
 	if (err == 0) {
 #if FASTRETRANS_DEBUG > 0
@@ -2737,6 +2736,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 	tcp_for_write_queue_from(skb, sk) {
 		__u8 sacked = TCP_SKB_CB(skb)->sacked;
+		int segs;
 
 		if (skb == tcp_send_head(sk))
 			break;
@@ -2744,14 +2744,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		if (!hole)
 			tp->retransmit_skb_hint = skb;
 
-		/* Assume this retransmit will generate
-		 * only one packet for congestion window
-		 * calculation purposes.  This works because
-		 * tcp_retransmit_skb() will chop up the
-		 * packet to be MSS sized and all the
-		 * packet counting works out.
-		 */
-		if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
+		segs = tp->snd_cwnd - tcp_packets_in_flight(tp);
+		if (segs <= 0)
 			return;
 
 		if (fwd_rexmitting) {
@@ -2788,7 +2782,7 @@ begin_fwd:
 		if (sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))
 			continue;
 
-		if (tcp_retransmit_skb(sk, skb))
+		if (tcp_retransmit_skb(sk, skb, segs))
 			return;
 
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 49bc474f8e35..373b03e78aaa 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -404,7 +404,7 @@ void tcp_retransmit_timer(struct sock *sk)
 			goto out;
 		}
 		tcp_enter_loss(sk);
-		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
+		tcp_retransmit_skb(sk, tcp_write_queue_head(sk), 1);
 		__sk_dst_reset(sk);
 		goto out_reset_timer;
 	}
@@ -436,7 +436,7 @@ void tcp_retransmit_timer(struct sock *sk)
 
 	tcp_enter_loss(sk);
 
-	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
+	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk), 1) > 0) {
 		/* Retransmission failed because of local congestion,
 		 * do not backoff.
 		 */
-- 
2.8.0.rc3.226.g39d4020
