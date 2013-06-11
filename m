From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: properly send new data in fast recovery in first RTT
Date: Tue, 11 Jun 2013 15:35:32 -0700
Message-ID: <1370990132-27652-1-git-send-email-ycheng@google.com>
Cc: nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:33388 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab3FKWfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 18:35:43 -0400
Received: by mail-qc0-f201.google.com with SMTP id u11so118975qcx.0
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 15:35:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux sends new unset data during disorder and recovery state if all
(suspected) lost packets have been retransmitted ( RFC5681, section
3.2 step 1 & 2, RFC3517 section 4, NexSeg() Rule 2).  One requirement
is to keep the receive window about twice the estimated sender's
congestion window (tcp_rcv_space_adjust()), assuming the fast
retransmits repair the losses in the next round trip.

But currently it's not the case on the first round trip in either
normal or Fast Open connection, beucase the initial receive window
is identical to (expected) sender's initial congestion window. The
fix is to double it.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |  5 ++---
 net/ipv4/tcp_input.c  | 13 ++-----------
 net/ipv4/tcp_output.c | 33 ++++++++++++++++++---------------
 3 files changed, 22 insertions(+), 29 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0d637e9..6fa8083 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -61,9 +61,6 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
  */
 #define MAX_TCP_WINDOW		32767U
 
-/* Offer an initial receive window of 10 mss. */
-#define TCP_DEFAULT_INIT_RCVWND	10
-
 /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
 #define TCP_MIN_MSS		88U
 
@@ -1047,6 +1044,8 @@ static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 	rx_opt->num_sacks = 0;
 }
 
+extern u32 tcp_default_init_rwnd(u32 mss);
+
 /* Determine a window scaling and initial window to offer. */
 extern void tcp_select_initial_window(int __space, __u32 mss,
 				      __u32 *rcv_wnd, __u32 *window_clamp,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 907311c..46271cdc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -347,22 +347,13 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 }
 
 /* 3. Tuning rcvbuf, when connection enters established state. */
-
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
 	u32 mss = tcp_sk(sk)->advmss;
-	u32 icwnd = TCP_DEFAULT_INIT_RCVWND;
 	int rcvmem;
 
-	/* Limit to 10 segments if mss <= 1460,
-	 * or 14600/mss segments, with a minimum of two segments.
-	 */
-	if (mss > 1460)
-		icwnd = max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
-
-	rcvmem = 2 * SKB_TRUESIZE(mss + MAX_TCP_HEADER);
-
-	rcvmem *= icwnd;
+	rcvmem = 2 * SKB_TRUESIZE(mss + MAX_TCP_HEADER) *
+		 tcp_default_init_rwnd(mss);
 
 	if (sk->sk_rcvbuf < rcvmem)
 		sk->sk_rcvbuf = min(rcvmem, sysctl_tcp_rmem[2]);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ec335fa..3dd46ea 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -181,6 +181,21 @@ static inline void tcp_event_ack_sent(struct sock *sk, unsigned int pkts)
 	inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 }
 
+
+u32 tcp_default_init_rwnd(u32 mss)
+{
+	/* Initial receive window should be twice of TCP_INIT_CWND to
+	 * enable proper sending of new unset data during fast recovery
+	 * (RFC 3517, Section 4, NextSeg() rule (2)). Further place a
+	 * limit when mss is larger than 1460.
+	 */
+	u32 init_rwnd = TCP_INIT_CWND * 2;
+
+	if (mss > 1460)
+		init_rwnd = max((1460 * init_rwnd) / mss, 2U);
+	return init_rwnd;
+}
+
 /* Determine a window scaling and initial window to offer.
  * Based on the assumption that the given amount of space
  * will be offered. Store the results in the tp structure.
@@ -230,22 +245,10 @@ void tcp_select_initial_window(int __space, __u32 mss,
 		}
 	}
 
-	/* Set initial window to a value enough for senders starting with
-	 * initial congestion window of TCP_DEFAULT_INIT_RCVWND. Place
-	 * a limit on the initial window when mss is larger than 1460.
-	 */
 	if (mss > (1 << *rcv_wscale)) {
-		int init_cwnd = TCP_DEFAULT_INIT_RCVWND;
-		if (mss > 1460)
-			init_cwnd =
-			max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
-		/* when initializing use the value from init_rcv_wnd
-		 * rather than the default from above
-		 */
-		if (init_rcv_wnd)
-			*rcv_wnd = min(*rcv_wnd, init_rcv_wnd * mss);
-		else
-			*rcv_wnd = min(*rcv_wnd, init_cwnd * mss);
+		if (!init_rcv_wnd) /* Use default unless specified otherwise */
+			init_rcv_wnd = tcp_default_init_rwnd(mss);
+		*rcv_wnd = min(*rcv_wnd, init_rcv_wnd * mss);
 	}
 
 	/* Set the clamp no higher than max representable value */
-- 
1.8.3
