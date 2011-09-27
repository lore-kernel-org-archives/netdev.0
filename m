From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: rename tcp_skb_cb flags
Date: Tue, 27 Sep 2011 11:51:54 +0200
Message-ID: <1317117114.2541.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <20110927.005905.1166544891922183065.davem@davemloft.net>
	 <1317103249.2796.25.camel@edumazet-laptop>
	 <20110927.022025.1306291417181821045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33274 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab1I0Jvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 05:51:44 -0400
Received: by gyg10 with SMTP id 10so4990847gyg.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 02:51:43 -0700 (PDT)
In-Reply-To: <20110927.022025.1306291417181821045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename struct tcp_skb_cb "flags" to "tcp_flags" to ease code review and
maintenance.

Its content is a combination of FIN/SYN/RST/PSH/ACK/URG/ECE/CWR flags

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h     |    2 -
 net/ipv4/tcp.c        |    8 ++---
 net/ipv4/tcp_input.c  |    4 +-
 net/ipv4/tcp_output.c |   63 ++++++++++++++++++++--------------------
 4 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 28a9997..0113d30 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -636,7 +636,7 @@ struct tcp_skb_cb {
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
-	__u8		flags;		/* TCP header flags.		*/
+	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
 	__u8		sacked;		/* State flags for SACK/FACK.	*/
 #define TCPCB_SACKED_ACKED	0x01	/* SKB ACK'd by a SACK block	*/
 #define TCPCB_SACKED_RETRANS	0x02	/* SKB retransmitted		*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cc0d5de..131c45f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -524,7 +524,7 @@ EXPORT_SYMBOL(tcp_ioctl);
 
 static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 {
-	TCP_SKB_CB(skb)->flags |= TCPHDR_PSH;
+	TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
 	tp->pushed_seq = tp->write_seq;
 }
 
@@ -540,7 +540,7 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 
 	skb->csum    = 0;
 	tcb->seq     = tcb->end_seq = tp->write_seq;
-	tcb->flags   = TCPHDR_ACK;
+	tcb->tcp_flags = TCPHDR_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
 	tcp_add_write_queue_tail(sk, skb);
@@ -830,7 +830,7 @@ new_segment:
 		skb_shinfo(skb)->gso_segs = 0;
 
 		if (!copied)
-			TCP_SKB_CB(skb)->flags &= ~TCPHDR_PSH;
+			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
 
 		copied += copy;
 		poffset += copy;
@@ -1074,7 +1074,7 @@ new_segment:
 			}
 
 			if (!copied)
-				TCP_SKB_CB(skb)->flags &= ~TCPHDR_PSH;
+				TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7008fcc..143221e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1449,7 +1449,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 		tp->lost_cnt_hint -= tcp_skb_pcount(prev);
 	}
 
-	TCP_SKB_CB(skb)->flags |= TCP_SKB_CB(prev)->flags;
+	TCP_SKB_CB(skb)->tcp_flags |= TCP_SKB_CB(prev)->tcp_flags;
 	if (skb == tcp_highest_sack(sk))
 		tcp_advance_highest_sack(sk, skb);
 
@@ -3348,7 +3348,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		 * connection startup slow start one packet too
 		 * quickly.  This is severely frowned upon behavior.
 		 */
-		if (!(scb->flags & TCPHDR_SYN)) {
+		if (!(scb->tcp_flags & TCPHDR_SYN)) {
 			flag |= FLAG_DATA_ACKED;
 		} else {
 			flag |= FLAG_SYN_ACKED;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 081dcd6..dde6b57 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -297,9 +297,9 @@ static u16 tcp_select_window(struct sock *sk)
 /* Packet ECN state for a SYN-ACK */
 static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_buff *skb)
 {
-	TCP_SKB_CB(skb)->flags &= ~TCPHDR_CWR;
+	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_CWR;
 	if (!(tp->ecn_flags & TCP_ECN_OK))
-		TCP_SKB_CB(skb)->flags &= ~TCPHDR_ECE;
+		TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_ECE;
 }
 
 /* Packet ECN state for a SYN.  */
@@ -309,7 +309,7 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 
 	tp->ecn_flags = 0;
 	if (sysctl_tcp_ecn == 1) {
-		TCP_SKB_CB(skb)->flags |= TCPHDR_ECE | TCPHDR_CWR;
+		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 	}
 }
@@ -356,7 +356,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	skb->csum = 0;
 
-	TCP_SKB_CB(skb)->flags = flags;
+	TCP_SKB_CB(skb)->tcp_flags = flags;
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	skb_shinfo(skb)->gso_segs = 1;
@@ -826,7 +826,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-	if (unlikely(tcb->flags & TCPHDR_SYN))
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
 	else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
@@ -850,9 +850,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	th->seq			= htonl(tcb->seq);
 	th->ack_seq		= htonl(tp->rcv_nxt);
 	*(((__be16 *)th) + 6)	= htons(((tcp_header_size >> 2) << 12) |
-					tcb->flags);
+					tcb->tcp_flags);
 
-	if (unlikely(tcb->flags & TCPHDR_SYN)) {
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN)) {
 		/* RFC1323: The window in SYN & SYN/ACK segments
 		 * is never scaled.
 		 */
@@ -875,7 +875,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
-	if (likely((tcb->flags & TCPHDR_SYN) == 0))
+	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -889,7 +889,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	icsk->icsk_af_ops->send_check(sk, skb);
 
-	if (likely(tcb->flags & TCPHDR_ACK))
+	if (likely(tcb->tcp_flags & TCPHDR_ACK))
 		tcp_event_ack_sent(sk, tcp_skb_pcount(skb));
 
 	if (skb->len != tcp_header_size)
@@ -1032,9 +1032,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(buff)->seq;
 
 	/* PSH and FIN should only be set in the second packet. */
-	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
-	TCP_SKB_CB(buff)->flags = flags;
+	flags = TCP_SKB_CB(skb)->tcp_flags;
+	TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
+	TCP_SKB_CB(buff)->tcp_flags = flags;
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
 
 	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed != CHECKSUM_PARTIAL) {
@@ -1340,7 +1340,8 @@ static inline unsigned int tcp_cwnd_test(struct tcp_sock *tp,
 	u32 in_flight, cwnd;
 
 	/* Don't be strict about the congestion window for the final FIN.  */
-	if ((TCP_SKB_CB(skb)->flags & TCPHDR_FIN) && tcp_skb_pcount(skb) == 1)
+	if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) &&
+	    tcp_skb_pcount(skb) == 1)
 		return 1;
 
 	in_flight = tcp_packets_in_flight(tp);
@@ -1409,7 +1410,7 @@ static inline int tcp_nagle_test(struct tcp_sock *tp, struct sk_buff *skb,
 	 * Nagle can be ignored during F-RTO too (see RFC4138).
 	 */
 	if (tcp_urg_mode(tp) || (tp->frto_counter == 2) ||
-	    (TCP_SKB_CB(skb)->flags & TCPHDR_FIN))
+	    (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		return 1;
 
 	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
@@ -1497,9 +1498,9 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(buff)->seq;
 
 	/* PSH and FIN should only be set in the second packet. */
-	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
-	TCP_SKB_CB(buff)->flags = flags;
+	flags = TCP_SKB_CB(skb)->tcp_flags;
+	TCP_SKB_CB(skb)->tcp_flags = flags & ~(TCPHDR_FIN | TCPHDR_PSH);
+	TCP_SKB_CB(buff)->tcp_flags = flags;
 
 	/* This packet was never sent out yet, so no SACK bits. */
 	TCP_SKB_CB(buff)->sacked = 0;
@@ -1530,7 +1531,7 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	u32 send_win, cong_win, limit, in_flight;
 	int win_divisor;
 
-	if (TCP_SKB_CB(skb)->flags & TCPHDR_FIN)
+	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 		goto send_now;
 
 	if (icsk->icsk_ca_state != TCP_CA_Open)
@@ -1657,7 +1658,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
-	TCP_SKB_CB(nskb)->flags = TCPHDR_ACK;
+	TCP_SKB_CB(nskb)->tcp_flags = TCPHDR_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
 	nskb->csum = 0;
 	nskb->ip_summed = skb->ip_summed;
@@ -1677,11 +1678,11 @@ static int tcp_mtu_probe(struct sock *sk)
 		if (skb->len <= copy) {
 			/* We've eaten all the data from this skb.
 			 * Throw it away. */
-			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags;
+			TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
 			tcp_unlink_write_queue(skb, sk);
 			sk_wmem_free_skb(sk, skb);
 		} else {
-			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
+			TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags &
 						   ~(TCPHDR_FIN|TCPHDR_PSH);
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
@@ -1987,7 +1988,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(next_skb)->end_seq;
 
 	/* Merge over control information. This moves PSH/FIN etc. over */
-	TCP_SKB_CB(skb)->flags |= TCP_SKB_CB(next_skb)->flags;
+	TCP_SKB_CB(skb)->tcp_flags |= TCP_SKB_CB(next_skb)->tcp_flags;
 
 	/* All done, get rid of second SKB and account for it so
 	 * packet counting does not break.
@@ -2035,7 +2036,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 
 	if (!sysctl_tcp_retrans_collapse)
 		return;
-	if (TCP_SKB_CB(skb)->flags & TCPHDR_SYN)
+	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 		return;
 
 	tcp_for_write_queue_from_safe(skb, tmp, sk) {
@@ -2127,12 +2128,12 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * since it is cheap to do so and saves bytes on the network.
 	 */
 	if (skb->len > 0 &&
-	    (TCP_SKB_CB(skb)->flags & TCPHDR_FIN) &&
+	    (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) &&
 	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			/* Reuse, even though it does some unnecessary work */
 			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
-					     TCP_SKB_CB(skb)->flags);
+					     TCP_SKB_CB(skb)->tcp_flags);
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 	}
@@ -2322,7 +2323,7 @@ void tcp_send_fin(struct sock *sk)
 	mss_now = tcp_current_mss(sk);
 
 	if (tcp_send_head(sk) != NULL) {
-		TCP_SKB_CB(skb)->flags |= TCPHDR_FIN;
+		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
 	} else {
@@ -2384,11 +2385,11 @@ int tcp_send_synack(struct sock *sk)
 	struct sk_buff *skb;
 
 	skb = tcp_write_queue_head(sk);
-	if (skb == NULL || !(TCP_SKB_CB(skb)->flags & TCPHDR_SYN)) {
+	if (skb == NULL || !(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
 		printk(KERN_DEBUG "tcp_send_synack: wrong queue state\n");
 		return -EFAULT;
 	}
-	if (!(TCP_SKB_CB(skb)->flags & TCPHDR_ACK)) {
+	if (!(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_ACK)) {
 		if (skb_cloned(skb)) {
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 			if (nskb == NULL)
@@ -2402,7 +2403,7 @@ int tcp_send_synack(struct sock *sk)
 			skb = nskb;
 		}
 
-		TCP_SKB_CB(skb)->flags |= TCPHDR_ACK;
+		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ACK;
 		TCP_ECN_send_synack(tcp_sk(sk), skb);
 	}
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
@@ -2799,13 +2800,13 @@ int tcp_write_wakeup(struct sock *sk)
 		if (seg_size < TCP_SKB_CB(skb)->end_seq - TCP_SKB_CB(skb)->seq ||
 		    skb->len > mss) {
 			seg_size = min(seg_size, mss);
-			TCP_SKB_CB(skb)->flags |= TCPHDR_PSH;
+			TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
 			if (tcp_fragment(sk, skb, seg_size, mss))
 				return -1;
 		} else if (!tcp_skb_pcount(skb))
 			tcp_set_skb_tso_segs(sk, skb, mss);
 
-		TCP_SKB_CB(skb)->flags |= TCPHDR_PSH;
+		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 		if (!err)
