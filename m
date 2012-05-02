From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v3 3/3] tcp: early retransmit: delayed fast retransmit
Date: Wed,  2 May 2012 11:46:31 -0700
Message-ID: <1335984391-31340-3-git-send-email-ycheng@google.com>
References: <1335984391-31340-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f202.google.com ([209.85.212.202]:65444 "EHLO
	mail-wi0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755965Ab2EBSqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 14:46:35 -0400
Received: by wibhj13 with SMTP id hj13so61532wib.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 11:46:34 -0700 (PDT)
In-Reply-To: <1335984391-31340-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implementing the advanced early retransmit (sysctl_tcp_early_retrans==2).
Delays the fast retransmit by an interval of RTT/4. We borrow the
RTO timer to implement the delay. If we receive another ACK or send
a new packet, the timer is cancelled and restored to original RTO
value offset by time elapsed.  When the delayed-ER timer fires,
we enter fast recovery and perform fast retransmit.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
ChangeLog in v2:
 - Set sysctl_tcp_early_retrans default to 2
ChangeLog in v3:
 - use separate u8 for early retrans stats in tcp_sock
 - disable ER if detects any reordering

 include/linux/tcp.h   |    8 +++---
 include/net/tcp.h     |    3 ++
 net/ipv4/tcp_input.c  |   72 +++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv4/tcp_output.c |    5 +--
 net/ipv4/tcp_timer.c  |    5 +++
 5 files changed, 78 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7d08a79..f8e15b2 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -365,12 +365,12 @@ struct tcp_sock {
 
 	u32	frto_highmark;	/* snd_nxt when RTO occurred */
 	u16	advmss;		/* Advertised MSS			*/
-	u16	nonagle     : 4,/* Disable Nagle algorithm?             */
+	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
-		repair      : 1,
-		do_early_retrans: 1;/* Enable RFC5827 early-retransmit  */
-
+		repair      : 1;
+	u8	do_early_retrans:1,/* Enable RFC5827 early retransmit (ER) */
+		early_retrans_delayed:1; /* Delayed ER timer installed */
 	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	repair_queue;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 685437a..5283aa4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -500,6 +500,8 @@ extern void tcp_send_delayed_ack(struct sock *sk);
 
 /* tcp_input.c */
 extern void tcp_cwnd_application_limited(struct sock *sk);
+extern void tcp_resume_early_retransmit(struct sock *sk);
+extern void tcp_rearm_rto(struct sock *sk);
 
 /* tcp_timer.c */
 extern void tcp_init_xmit_timers(struct sock *);
@@ -805,6 +807,7 @@ static inline void tcp_enable_early_retrans(struct tcp_sock *tp)
 {
 	tp->do_early_retrans = sysctl_tcp_early_retrans &&
 		!sysctl_tcp_thin_dupack && sysctl_tcp_reordering == 3;
+	tp->early_retrans_delayed = 0;
 }
 
 static inline void tcp_disable_early_retrans(struct tcp_sock *tp)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 98c586d..9363a54 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -989,8 +989,9 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 		       tp->undo_marker ? tp->undo_retrans : 0);
 #endif
 		tcp_disable_fack(tp);
-		tcp_disable_early_retrans(tp);
 	}
+	if (metric > 0)
+		tcp_disable_early_retrans(tp);
 }
 
 /* This must be called before lost_out is incremented */
@@ -2342,6 +2343,27 @@ static inline int tcp_dupack_heuristics(const struct tcp_sock *tp)
 	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
 }
 
+static bool tcp_pause_early_retransmit(struct sock *sk, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned long delay;
+
+	/* Delay early retransmit and entering fast recovery for
+	 * max(RTT/4, 2msec) unless ack has ECE mark, no RTT samples
+	 * available, or RTO is scheduled to fire first.
+	 */
+	if (sysctl_tcp_early_retrans < 2 || (flag & FLAG_ECE) || !tp->srtt)
+		return false;
+
+	delay = max_t(unsigned long, (tp->srtt >> 5), msecs_to_jiffies(2));
+	if (!time_after(inet_csk(sk)->icsk_timeout, (jiffies + delay)))
+		return false;
+
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, delay, TCP_RTO_MAX);
+	tp->early_retrans_delayed = 1;
+	return true;
+}
+
 static inline int tcp_skb_timedout(const struct sock *sk,
 				   const struct sk_buff *skb)
 {
@@ -2449,7 +2471,7 @@ static inline int tcp_head_timedout(const struct sock *sk)
  * Main question: may we further continue forward transmission
  * with the same cwnd?
  */
-static int tcp_time_to_recover(struct sock *sk)
+static int tcp_time_to_recover(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
@@ -2503,7 +2525,7 @@ static int tcp_time_to_recover(struct sock *sk)
 	if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
 	    (tp->packets_out == (tp->sacked_out + 1) && tp->packets_out < 4) &&
 	    !tcp_may_send_now(sk))
-		return 1;
+		return !tcp_pause_early_retransmit(sk, flag);
 
 	return 0;
 }
@@ -3170,7 +3192,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 		if (icsk->icsk_ca_state <= TCP_CA_Disorder)
 			tcp_try_undo_dsack(sk);
 
-		if (!tcp_time_to_recover(sk)) {
+		if (!tcp_time_to_recover(sk, flag)) {
 			tcp_try_to_open(sk, flag);
 			return;
 		}
@@ -3269,16 +3291,47 @@ static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 /* Restart timer after forward progress on connection.
  * RFC2988 recommends to restart timer to now+rto.
  */
-static void tcp_rearm_rto(struct sock *sk)
+void tcp_rearm_rto(struct sock *sk)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+		u32 rto = inet_csk(sk)->icsk_rto;
+		/* Offset the time elapsed after installing regular RTO */
+		if (tp->early_retrans_delayed) {
+			struct sk_buff *skb = tcp_write_queue_head(sk);
+			const u32 rto_time_stamp = TCP_SKB_CB(skb)->when + rto;
+			s32 delta = (s32)(rto_time_stamp - tcp_time_stamp);
+			/* delta may not be positive if the socket is locked
+			 * when the delayed ER timer fires and is rescheduled.
+			 */
+			if (delta > 0)
+				rto = delta;
+		}
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
+					  TCP_RTO_MAX);
 	}
+	tp->early_retrans_delayed = 0;
+}
+
+/* This function is called when the delayed ER timer fires. TCP enters
+ * fast recovery and performs fast-retransmit.
+ */
+void tcp_resume_early_retransmit(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tcp_rearm_rto(sk);
+
+	/* Stop if ER is disabled after the delayed ER timer is scheduled */
+	if (!tp->do_early_retrans)
+		return;
+
+	tcp_enter_recovery(sk, false);
+	tcp_update_scoreboard(sk, 1);
+	tcp_xmit_retransmit_queue(sk);
 }
 
 /* If we get here, the whole TSO packet has not been acked. */
@@ -3727,6 +3780,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (after(ack, tp->snd_nxt))
 		goto invalid_ack;
 
+	if (tp->early_retrans_delayed)
+		tcp_rearm_rto(sk);
+
 	if (after(ack, prior_snd_una))
 		flag |= FLAG_SND_UNA_ADVANCED;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 834e89f..d947330 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -78,9 +78,8 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 		tp->frto_counter = 3;
 
 	tp->packets_out += tcp_skb_pcount(skb);
-	if (!prior_packets)
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+	if (!prior_packets || tp->early_retrans_delayed)
+		tcp_rearm_rto(sk);
 }
 
 /* SND.NXT, if window was not shrunk.
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 34d4a02..e911e6c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -319,6 +319,11 @@ void tcp_retransmit_timer(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
+	if (tp->early_retrans_delayed) {
+		tcp_resume_early_retransmit(sk);
+		return;
+	}
+
 	if (!tp->packets_out)
 		goto out;
 
-- 
1.7.7.3
