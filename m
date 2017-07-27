From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH net-next 4/6] tcp: remove header prediction
Date: Fri, 28 Jul 2017 01:31:15 +0200
Message-ID: <20170727233117.29695-5-fw@strlen.de>
References: <20170727233117.29695-1-fw@strlen.de>
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, weiwan@google.com, brakmo@fb.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38368 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751634AbdG0Xb1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 19:31:27 -0400
In-Reply-To: <20170727233117.29695-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like prequeue, I am not sure this is overly useful nowadays.

If we receive a train of packets, GRO will aggregate them if the
headers are the same (HP predates GRO by several years) so we don't
get a per-packet benefit, only a per-aggregated-packet one.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/tcp.h      |   6 --
 include/net/tcp.h        |  23 ------
 net/ipv4/tcp.c           |   4 +-
 net/ipv4/tcp_input.c     | 192 +++--------------------------------------------
 net/ipv4/tcp_minisocks.c |   2 -
 net/ipv4/tcp_output.c    |   2 -
 6 files changed, 10 insertions(+), 219 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 32fb37cfb0d1..d7389ea36e10 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -148,12 +148,6 @@ struct tcp_sock {
 	u16	gso_segs;	/* Max number of segs per GSO packet	*/
 
 /*
- *	Header prediction flags
- *	0x5?10 << 16 + snd_wnd in net byte order
- */
-	__be32	pred_flags;
-
-/*
  *	RFC793 variables by their proper names. This means you can
  *	read the code and the spec side by side (and laugh ...)
  *	See RFC793 and RFC1122. The RFC writes these in capitals.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8507c81fb0e9..8f11b82b5b5a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -631,29 +631,6 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 	return usecs_to_jiffies((tp->srtt_us >> 3) + tp->rttvar_us);
 }
 
-static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
-{
-	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
-			       ntohl(TCP_FLAG_ACK) |
-			       snd_wnd);
-}
-
-static inline void tcp_fast_path_on(struct tcp_sock *tp)
-{
-	__tcp_fast_path_on(tp, tp->snd_wnd >> tp->rx_opt.snd_wscale);
-}
-
-static inline void tcp_fast_path_check(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	if (RB_EMPTY_ROOT(&tp->out_of_order_queue) &&
-	    tp->rcv_wnd &&
-	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
-	    !tp->urg_data)
-		tcp_fast_path_on(tp);
-}
-
 /* Compute the actual rto_min value */
 static inline u32 tcp_rto_min(struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 62018ea6f45f..e022874d509f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1848,10 +1848,8 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 		tcp_rcv_space_adjust(sk);
 
 skip_copy:
-		if (tp->urg_data && after(tp->copied_seq, tp->urg_seq)) {
+		if (tp->urg_data && after(tp->copied_seq, tp->urg_seq))
 			tp->urg_data = 0;
-			tcp_fast_path_check(sk);
-		}
 		if (used + offset < skb->len)
 			continue;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 87efde9f5a90..bfde9d7d210e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -103,7 +103,6 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define FLAG_DATA_SACKED	0x20 /* New SACK.				*/
 #define FLAG_ECE		0x40 /* ECE in this ACK				*/
 #define FLAG_LOST_RETRANS	0x80 /* This ACK marks some retransmission lost */
-#define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
 #define FLAG_ORIG_SACK_ACKED	0x200 /* Never retransmitted data are (s)acked	*/
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
 #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info */
@@ -3367,12 +3366,6 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 		if (tp->snd_wnd != nwin) {
 			tp->snd_wnd = nwin;
 
-			/* Note, it is the only place, where
-			 * fast path is recovered for sending TCP.
-			 */
-			tp->pred_flags = 0;
-			tcp_fast_path_check(sk);
-
 			if (tcp_send_head(sk))
 				tcp_slow_start_after_idle_check(sk);
 
@@ -3597,19 +3590,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (flag & FLAG_UPDATE_TS_RECENT)
 		tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
 
-	if (!(flag & FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
-		/* Window is constant, pure forward advance.
-		 * No more checks are required.
-		 * Note, we use the fact that SND.UNA>=SND.WL2.
-		 */
-		tcp_update_wl(tp, ack_seq);
-		tcp_snd_una_update(tp, ack);
-		flag |= FLAG_WIN_UPDATE;
-
-		tcp_in_ack_event(sk, CA_ACK_WIN_UPDATE);
-
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPHPACKS);
-	} else {
+	{
 		u32 ack_ev_flags = CA_ACK_SLOWPATH;
 
 		if (ack_seq != TCP_SKB_CB(skb)->end_seq)
@@ -4398,8 +4379,6 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	/* Disable header prediction. */
-	tp->pred_flags = 0;
 	inet_csk_schedule_ack(sk);
 
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
@@ -4638,8 +4617,6 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		if (tp->rx_opt.num_sacks)
 			tcp_sack_remove(tp);
 
-		tcp_fast_path_check(sk);
-
 		if (eaten > 0)
 			kfree_skb_partial(skb, fragstolen);
 		if (!sock_flag(sk, SOCK_DEAD))
@@ -4965,7 +4942,6 @@ static int tcp_prune_queue(struct sock *sk)
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_RCVPRUNED);
 
 	/* Massive buffer overcommit. */
-	tp->pred_flags = 0;
 	return -1;
 }
 
@@ -5137,9 +5113,6 @@ static void tcp_check_urg(struct sock *sk, const struct tcphdr *th)
 
 	tp->urg_data = TCP_URG_NOTYET;
 	tp->urg_seq = ptr;
-
-	/* Disable header prediction. */
-	tp->pred_flags = 0;
 }
 
 /* This is the 'fast' part of urgent handling. */
@@ -5298,26 +5271,6 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 
 /*
  *	TCP receive function for the ESTABLISHED state.
- *
- *	It is split into a fast path and a slow path. The fast path is
- * 	disabled when:
- *	- A zero window was announced from us - zero window probing
- *        is only handled properly in the slow path.
- *	- Out of order segments arrived.
- *	- Urgent data is expected.
- *	- There is no buffer space left
- *	- Unexpected TCP flags/window values/header lengths are received
- *	  (detected by checking the TCP header against pred_flags)
- *	- Data is sent in both directions. Fast path only supports pure senders
- *	  or pure receivers (this means either the sequence number or the ack
- *	  value must stay constant)
- *	- Unexpected TCP option.
- *
- *	When these conditions are not satisfied it drops into a standard
- *	receive procedure patterned after RFC793 to handle all cases.
- *	The first three cases are guaranteed by proper pred_flags setting,
- *	the rest is checked inline. Fast processing is turned on in
- *	tcp_data_queue when everything is OK.
  */
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct tcphdr *th)
@@ -5328,144 +5281,19 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	tcp_mstamp_refresh(tp);
 	if (unlikely(!sk->sk_rx_dst))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
-	/*
-	 *	Header prediction.
-	 *	The code loosely follows the one in the famous
-	 *	"30 instruction TCP receive" Van Jacobson mail.
-	 *
-	 *	Van's trick is to deposit buffers into socket queue
-	 *	on a device interrupt, to call tcp_recv function
-	 *	on the receive process context and checksum and copy
-	 *	the buffer to user space. smart...
-	 *
-	 *	Our current scheme is not silly either but we take the
-	 *	extra cost of the net_bh soft interrupt processing...
-	 *	We do checksum and copy also but from device to kernel.
-	 */
 
 	tp->rx_opt.saw_tstamp = 0;
 
-	/*	pred_flags is 0xS?10 << 16 + snd_wnd
-	 *	if header_prediction is to be made
-	 *	'S' will always be tp->tcp_header_len >> 2
-	 *	'?' will be 0 for the fast path, otherwise pred_flags is 0 to
-	 *  turn it off	(when there are holes in the receive
-	 *	 space for instance)
-	 *	PSH flag is ignored.
-	 */
-
-	if ((tcp_flag_word(th) & TCP_HP_BITS) == tp->pred_flags &&
-	    TCP_SKB_CB(skb)->seq == tp->rcv_nxt &&
-	    !after(TCP_SKB_CB(skb)->ack_seq, tp->snd_nxt)) {
-		int tcp_header_len = tp->tcp_header_len;
-
-		/* Timestamp header prediction: tcp_header_len
-		 * is automatically equal to th->doff*4 due to pred_flags
-		 * match.
-		 */
-
-		/* Check timestamp */
-		if (tcp_header_len == sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) {
-			/* No? Slow path! */
-			if (!tcp_parse_aligned_timestamp(tp, th))
-				goto slow_path;
-
-			/* If PAWS failed, check it more carefully in slow path */
-			if ((s32)(tp->rx_opt.rcv_tsval - tp->rx_opt.ts_recent) < 0)
-				goto slow_path;
-
-			/* DO NOT update ts_recent here, if checksum fails
-			 * and timestamp was corrupted part, it will result
-			 * in a hung connection since we will drop all
-			 * future packets due to the PAWS test.
-			 */
-		}
-
-		if (len <= tcp_header_len) {
-			/* Bulk data transfer: sender */
-			if (len == tcp_header_len) {
-				/* Predicted packet is in window by definition.
-				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
-				 * Hence, check seq<=rcv_wup reduces to:
-				 */
-				if (tcp_header_len ==
-				    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
-				    tp->rcv_nxt == tp->rcv_wup)
-					tcp_store_ts_recent(tp);
-
-				/* We know that such packets are checksummed
-				 * on entry.
-				 */
-				tcp_ack(sk, skb, 0);
-				__kfree_skb(skb);
-				tcp_data_snd_check(sk);
-				return;
-			} else { /* Header too small */
-				TCP_INC_STATS(sock_net(sk), TCP_MIB_INERRS);
-				goto discard;
-			}
-		} else {
-			int eaten = 0;
-			bool fragstolen = false;
-
-			if (tcp_checksum_complete(skb))
-				goto csum_error;
-
-			if ((int)skb->truesize > sk->sk_forward_alloc)
-				goto step5;
-
-			/* Predicted packet is in window by definition.
-			 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
-			 * Hence, check seq<=rcv_wup reduces to:
-			 */
-			if (tcp_header_len ==
-			    (sizeof(struct tcphdr) + TCPOLEN_TSTAMP_ALIGNED) &&
-			    tp->rcv_nxt == tp->rcv_wup)
-				tcp_store_ts_recent(tp);
-
-			tcp_rcv_rtt_measure_ts(sk, skb);
-
-			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPHPHITS);
-
-			/* Bulk data transfer: receiver */
-			eaten = tcp_queue_rcv(sk, skb, tcp_header_len,
-					      &fragstolen);
-
-			tcp_event_data_recv(sk, skb);
-
-			if (TCP_SKB_CB(skb)->ack_seq != tp->snd_una) {
-				/* Well, only one small jumplet in fast path... */
-				tcp_ack(sk, skb, FLAG_DATA);
-				tcp_data_snd_check(sk);
-				if (!inet_csk_ack_scheduled(sk))
-					goto no_ack;
-			}
-
-			__tcp_ack_snd_check(sk, 0);
-no_ack:
-			if (eaten)
-				kfree_skb_partial(skb, fragstolen);
-			sk->sk_data_ready(sk);
-			return;
-		}
-	}
-
-slow_path:
 	if (len < (th->doff << 2) || tcp_checksum_complete(skb))
 		goto csum_error;
 
 	if (!th->ack && !th->rst && !th->syn)
 		goto discard;
 
-	/*
-	 *	Standard slow path.
-	 */
-
 	if (!tcp_validate_incoming(sk, skb, th, 1))
 		return;
 
-step5:
-	if (tcp_ack(sk, skb, FLAG_SLOWPATH | FLAG_UPDATE_TS_RECENT) < 0)
+	if (tcp_ack(sk, skb, FLAG_UPDATE_TS_RECENT) < 0)
 		goto discard;
 
 	tcp_rcv_rtt_measure_ts(sk, skb);
@@ -5519,11 +5347,10 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	if (sock_flag(sk, SOCK_KEEPOPEN))
 		inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
 
-	if (!tp->rx_opt.snd_wscale)
-		__tcp_fast_path_on(tp, tp->snd_wnd);
-	else
-		tp->pred_flags = 0;
-
+	if (!sock_flag(sk, SOCK_DEAD)) {
+		sk->sk_state_change(sk);
+		sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
+	}
 }
 
 static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
@@ -5652,7 +5479,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		tcp_ecn_rcv_synack(tp, th);
 
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
-		tcp_ack(sk, skb, FLAG_SLOWPATH);
+		tcp_ack(sk, skb, 0);
 
 		/* Ok.. it's good. Set up sequence numbers and
 		 * move to established.
@@ -5888,8 +5715,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		return 0;
 
 	/* step 5: check the ACK field */
-	acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH |
-				      FLAG_UPDATE_TS_RECENT |
+
+	acceptable = tcp_ack(sk, skb, FLAG_UPDATE_TS_RECENT |
 				      FLAG_NO_CHALLENGE_ACK) > 0;
 
 	if (!acceptable) {
@@ -5957,7 +5784,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		tp->lsndtime = tcp_jiffies32;
 
 		tcp_initialize_rcv_mss(sk);
-		tcp_fast_path_on(tp);
 		break;
 
 	case TCP_FIN_WAIT1: {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 188a6f31356d..1537b87c657f 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -436,8 +436,6 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		struct tcp_sock *newtp = tcp_sk(newsk);
 
 		/* Now setup tcp_sock */
-		newtp->pred_flags = 0;
-
 		newtp->rcv_wup = newtp->copied_seq =
 		newtp->rcv_nxt = treq->rcv_isn + 1;
 		newtp->segs_in = 1;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 886d874775df..8380464aead1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -295,9 +295,7 @@ static u16 tcp_select_window(struct sock *sk)
 	/* RFC1323 scaling applied */
 	new_win >>= tp->rx_opt.rcv_wscale;
 
-	/* If we advertise zero window, disable fast path. */
 	if (new_win == 0) {
-		tp->pred_flags = 0;
 		if (old_win)
 			NET_INC_STATS(sock_net(sk),
 				      LINUX_MIB_TCPTOZEROWINDOWADV);
-- 
2.13.0
