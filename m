From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] TCP burst control
Date: Tue, 6 Jul 2004 15:58:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706155858.11b368e6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When using advanced congestion control it is possible for TCP to decide that
it has a large window to fill with data right away. The problem is that if TCP
creates long bursts, it becomes unfriendly to other flows and is more likely
to overrun intermediate queues.

This patch limits the amount of data in flight. It came from BICTCP 1.1 but it 
has been generalized to all TCP congestion algorithms. It has had some testing,
but needs to be more widely tested.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2004-07-06 15:52:39 -07:00
+++ b/include/linux/sysctl.h	2004-07-06 15:52:39 -07:00
@@ -339,6 +339,7 @@
 	NET_TCP_BIC_LOW_WINDOW=104,
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
+	NET_TCP_BURST_MODERATION=107,
 };
 
 enum {
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-07-06 15:52:39 -07:00
+++ b/include/linux/tcp.h	2004-07-06 15:52:39 -07:00
@@ -341,6 +341,7 @@
 	__u32	sacked_out;	/* SACK'd packets			*/
 	__u32	fackets_out;	/* FACK'd packets			*/
 	__u32	high_seq;	/* snd_nxt at onset of congestion	*/
+	__u32   max_in_flight;	/* for burst moderation */
 
 	__u32	retrans_stamp;	/* Timestamp of the last retransmit,
 				 * also used in SYN-SENT to remember stamp of
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-07-06 15:52:39 -07:00
+++ b/include/net/tcp.h	2004-07-06 15:52:39 -07:00
@@ -613,6 +613,7 @@
 extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_default_win_scale;
 extern int sysctl_tcp_moderate_rcvbuf;
+extern int sysctl_tcp_burst_moderation;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -1335,8 +1336,11 @@
 {
 	tp->undo_marker = 0;
 	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
-	tp->snd_cwnd = min(tp->snd_cwnd,
-			   tcp_packets_in_flight(tp) + 1U);
+	if (sysctl_tcp_burst_moderation) 
+		tp->snd_cwnd = min(tp->snd_cwnd, 
+				   max(tp->snd_ssthresh, tcp_packets_in_flight(tp) + 1U));
+	else 
+		tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp) + 1U);
 	tp->snd_cwnd_cnt = 0;
 	tp->high_seq = tp->snd_nxt;
 	tp->snd_cwnd_stamp = tcp_time_stamp;
@@ -1393,6 +1397,24 @@
 		  tcp_minshall_check(tp))));
 }
 
+/*
+ * If doing packet burst moderation
+ * then check to see if we have used up our limit
+ */
+static __inline__ int
+tcp_burst_exhausted(struct tcp_opt *tp)
+{
+	u32 cap = tp->max_in_flight;
+
+	if (!sysctl_tcp_burst_moderation || cap == 0)
+		return 0;
+	
+	if (likely(tp->ca_state != TCP_CA_Recovery))
+		cap += tcp_max_burst(tp) + (tp->snd_cwnd>>7);
+
+	return (tcp_packets_in_flight(tp) >= cap);
+}
+
 /* This checks if the data bearing packet SKB (usually sk->sk_send_head)
  * should be put on the wire right now.
  */
@@ -1423,11 +1445,19 @@
 	/* Don't be strict about the congestion window for the
 	 * final FIN frame.  -DaveM
 	 */
-	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
-		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
-		((tcp_packets_in_flight(tp) < tp->snd_cwnd) ||
-		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
-		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
+	if ((tcp_packets_in_flight(tp) >= tp->snd_cwnd ||
+	     tcp_burst_exhausted(tp)) && 
+	    !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
+		return 0;	/* no space in congestion window */
+
+	if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd))
+		return 0;	/* send window full */
+
+	if (!((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
+	      || !tcp_nagle_check(tp, skb, cur_mss, nonagle)))
+		return 0;	 /* limited by sender */
+
+	return 1;
 }
 
 static __inline__ void tcp_check_probe_timer(struct sock *sk, struct tcp_opt *tp)
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2004-07-06 15:52:39 -07:00
+++ b/net/ipv4/sysctl_net_ipv4.c	2004-07-06 15:52:39 -07:00
@@ -682,6 +682,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_BURST_MODERATION,
+		.procname	= "tcp_burst_moderation",
+		.data		= &sysctl_tcp_burst_moderation,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-07-06 15:52:39 -07:00
+++ b/net/ipv4/tcp_input.c	2004-07-06 15:52:39 -07:00
@@ -91,6 +91,7 @@
 int sysctl_tcp_vegas_cong_avoid;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
+int sysctl_tcp_burst_moderation = 1;
 
 /* Default values of the Vegas variables, in fixed-point representation
  * with V_PARAM_SHIFT bits to the right of the binary point.
@@ -1596,7 +1597,11 @@
 	if (decr && tp->snd_cwnd > limit)
 		tp->snd_cwnd -= decr;
 
-	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
+	limit = tcp_packets_in_flight(tp)+1;
+	if (sysctl_tcp_burst_moderation)
+		limit = max(tp->snd_ssthresh, limit);
+	
+	tp->snd_cwnd = min(tp->snd_cwnd, limit);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -3823,8 +3828,13 @@
 		/* Limited by application or receiver window. */
 		u32 win_used = max(tp->snd_cwnd_used, 2U);
 		if (win_used < tp->snd_cwnd) {
+			u32 limit = (tp->snd_cwnd + win_used) >> 1;
 			tp->snd_ssthresh = tcp_current_ssthresh(tp);
-			tp->snd_cwnd = (tp->snd_cwnd + win_used) >> 1;
+			if (sysctl_tcp_burst_moderation) 
+				tp->snd_cwnd = min(tp->snd_cwnd,
+						   max(tp->snd_ssthresh, limit));
+			else
+				tp->snd_cwnd = limit;
 		}
 		tp->snd_cwnd_used = 0;
 	}
@@ -4097,6 +4107,8 @@
 			struct tcphdr *th, unsigned len)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
+
+	tp->max_in_flight = 0;
 
 	/*
 	 *	Header prediction.
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-07-06 15:52:39 -07:00
+++ b/net/ipv4/tcp_output.c	2004-07-06 15:52:39 -07:00
@@ -205,6 +205,10 @@
 #define SYSCTL_FLAG_WSCALE	0x2
 #define SYSCTL_FLAG_SACK	0x4
 
+		if (sysctl_tcp_burst_moderation && !tp->max_in_flight)
+			tp->max_in_flight = tcp_packets_in_flight(tp) 
+				+ tcp_max_burst(tp);
+
 		sysctl_flags = 0;
 		if (tcb->flags & TCPCB_FLAG_SYN) {
 			tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
@@ -948,6 +952,11 @@
 			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
 				return;
 
+			if (sysctl_tcp_burst_moderation && tp->max_in_flight) {
+				if (tcp_packets_in_flight(tp) >= tp->max_in_flight)
+					return;
+			}
+
 			if (sacked&TCPCB_LOST) {
 				if (!(sacked&(TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
 					if (tcp_retransmit_skb(sk, skb))
@@ -996,6 +1005,11 @@
 
 		if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
 			break;
+
+		if (sysctl_tcp_burst_moderation && tp->max_in_flight) {
+			if (tcp_packets_in_flight(tp) >= tp->max_in_flight)
+				return;
+		}
 
 		if(TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS)
 			continue;
