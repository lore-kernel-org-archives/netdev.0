From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Add some function overview comments in tcp_input.c
Date: Fri, 24 Jul 2009 11:47:19 +0200
Message-ID: <20090724094719.GA19200@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33887 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbZGXJrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 05:47:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some function overview comments in tcp_input.c

Only partial so far. I didn't attempt to accurately comment
the SACK machinery and the congestion state machine. 

I also fixed the grammar in one or two other comments
(but still trying to keep the authentic "ANK language" @)

No code changes.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 net/ipv4/tcp_input.c |   47 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 41 insertions(+), 6 deletions(-)

Index: linux-2.6.31-rc3-ak/net/ipv4/tcp_input.c
===================================================================
--- linux-2.6.31-rc3-ak.orig/net/ipv4/tcp_input.c
+++ linux-2.6.31-rc3-ak/net/ipv4/tcp_input.c
@@ -4,6 +4,7 @@
  *		interface as the means of communication with the user level.
  *
  *		Implementation of the Transmission Control Protocol(TCP).
+ *             This file handles packets coming in from the network.
  *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
@@ -194,6 +195,8 @@ static inline int tcp_in_quickack_mode(c
 	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
 }
 
+/* Explicit Congestion Notification handling. */
+
 static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
 {
 	if (tp->ecn_flags & TCP_ECN_OK)
@@ -799,7 +802,9 @@ void tcp_update_metrics(struct sock *sk)
 	}
 }
 
-/* Numbers are taken from RFC3390.
+/* Set up initial congestion window for a socket.
+ *
+ * Numbers are taken from RFC3390.
  *
  * John Heffner states:
  *
@@ -992,6 +997,7 @@ static void tcp_skb_mark_lost(struct tcp
 	}
 }
 
+/* Update lost estimate. */
 static void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
 					    struct sk_buff *skb)
 {
@@ -2818,6 +2824,7 @@ static void tcp_try_to_open(struct sock
 	}
 }
 
+/* MTU probe failed. */
 static void tcp_mtup_probe_failed(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2826,6 +2833,7 @@ static void tcp_mtup_probe_failed(struct
 	icsk->icsk_mtup.probe_size = 0;
 }
 
+/* MTU probe succeeded: update the MSS. */
 static void tcp_mtup_probe_success(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -3115,6 +3123,7 @@ static void tcp_ack_no_tstamp(struct soc
 	tcp_valid_rtt_meas(sk, seq_rtt);
 }
 
+/* Update RTT estimate based on incoming ACKs. */
 static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
 				      const s32 seq_rtt)
 {
@@ -3126,6 +3135,7 @@ static inline void tcp_ack_update_rtt(st
 		tcp_ack_no_tstamp(sk, seq_rtt, flag);
 }
 
+/* Call the pluggable congestion avoidance algorithm */
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -3340,18 +3350,19 @@ static int tcp_clean_rtx_queue(struct so
 	return flag;
 }
 
+/* Reinitialize window probe timer after incoming ACKs. */
 static void tcp_ack_probe(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	/* Was it a usable window open? */
+	/* Was an usable window open? */
 
 	if (!after(TCP_SKB_CB(tcp_send_head(sk))->end_seq, tcp_wnd_end(tp))) {
 		icsk->icsk_backoff = 0;
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_PROBE0);
 		/* Socket must be waked up by subsequent tcp_data_snd_check().
-		 * This function is not for random using!
+		 * This function is not for casual usage!
 		 */
 	} else {
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
@@ -3694,7 +3705,8 @@ old_ack:
 	return 0;
 }
 
-/* Look for tcp options. Normally only called on SYN and SYNACK packets.
+/* Slow path TCP options parser.
+ * Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
@@ -3791,6 +3803,7 @@ void tcp_parse_options(struct sk_buff *s
 	}
 }
 
+/* Fast path time stamp parsing. */
 static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 {
 	__be32 *ptr = (__be32 *)(th + 1);
@@ -4152,6 +4165,7 @@ static void tcp_sack_maybe_coalesce(stru
 	}
 }
 
+/* New out of order packet received. Process the SACKs. */
 static void tcp_sack_new_ofo_skb(struct sock *sk, u32 seq, u32 end_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4195,7 +4209,6 @@ new_sack:
 }
 
 /* RCV.NXT advances, some SACKs should be eaten. */
-
 static void tcp_sack_remove(struct tcp_sock *tp)
 {
 	struct tcp_sack_block *sp = &tp->selective_acks[0];
@@ -4269,6 +4282,7 @@ static void tcp_ofo_queue(struct sock *s
 static int tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
+/* When the socket buffer is over limit try to free some memory. */
 static inline int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
 {
 	if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf ||
@@ -4288,6 +4302,10 @@ static inline int tcp_try_rmem_schedule(
 	return 0;
 }
 
+/* Queue incoming data on the socket and also do state changes.
+ * This also handles the fast path of directly pushing data to a
+ * receive process that is currently blocked in recvmsg.
+ */
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcphdr *th = tcp_hdr(skb);
@@ -4503,6 +4521,7 @@ add_sack:
 	}
 }
 
+/* Collapse one SKB with the next to save memory in the OOO queue. */
 static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
 					struct sk_buff_head *list)
 {
@@ -4676,7 +4695,10 @@ static void tcp_collapse_ofo_queue(struc
 }
 
 /*
- * Purge the out-of-order queue.
+ * Purge the out-of-order queue. This is done under socket buffer memory pressure,
+ * and throws out-of-order data already received (but not queued to the
+ * process because it was out of order) away.
+ *
  * Return true if queue was pruned.
  */
 static int tcp_prune_ofo_queue(struct sock *sk)
@@ -4773,6 +4795,7 @@ void tcp_cwnd_application_limited(struct
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+/* Should we increase the send buffer? */
 static int tcp_should_expand_sndbuf(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -4822,6 +4845,7 @@ static void tcp_new_space(struct sock *s
 	sk->sk_write_space(sk);
 }
 
+/* Check if we can signal users to queue more data */
 static void tcp_check_space(struct sock *sk)
 {
 	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
@@ -4832,6 +4856,7 @@ static void tcp_check_space(struct sock
 	}
 }
 
+/* Check if sending data is needed, e.g. because the window opened up */
 static inline void tcp_data_snd_check(struct sock *sk)
 {
 	tcp_push_pending_frames(sk);
@@ -4973,6 +4998,9 @@ static void tcp_urg(struct sock *sk, str
 	}
 }
 
+/* Fast path copy to user space code. When the receiving process is currently
+ * blocked in a recvmsg call directly copy to user space.
+ */
 static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -5019,6 +5047,10 @@ static inline int tcp_checksum_complete_
 }
 
 #ifdef CONFIG_NET_DMA
+
+/* Attempt to copy data to user space using hardware accelerated
+ * copy engines.
+ */
 static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 				  int hlen)
 {
@@ -5359,6 +5391,9 @@ discard:
 	return 0;
 }
 
+/* RFC793 receive state procedure for SYN-SENT sockets. This normally processes
+ * the SYN-ACK, but also handles a few odd cases.
+ */
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
