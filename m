From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) tcp westwood cleanup for 2.4
Date: Fri, 1 Oct 2004 15:57:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001155725.3cd22049@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Backport of the 2.6 code cleanup for Westwood TCP.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-10-01 15:54:14 -07:00
+++ b/net/ipv4/tcp_input.c	2004-10-01 15:54:14 -07:00
@@ -2556,15 +2556,13 @@
  * WESTWOOD_RTT_MIN minimum bound since we could be on a LAN!
  */
 
-static inline __u32 westwood_update_rttmin(struct sock *sk)
+static inline __u32 westwood_update_rttmin(const struct sock *sk)
 {
-	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
+	const struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 	__u32 rttmin = tp->westwood.rtt_min;
 
-	if (tp->westwood.rtt == 0)
-		return rttmin;
-
-	if (tp->westwood.rtt < tp->westwood.rtt_min || !rttmin)
+	if (tp->westwood.rtt != 0 && 
+	    (tp->westwood.rtt < tp->westwood.rtt_min || !rttmin))
 		rttmin = tp->westwood.rtt;
 
 	return rttmin;
@@ -2575,9 +2573,9 @@
  * Evaluate increases for dk. 
  */
 
-static __u32 westwood_acked(struct sock *sk)
+static __u32 westwood_acked(const struct sock *sk)
 {
-	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
+	const struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 
 	return ((tp->snd_una) - (tp->westwood.snd_una));
 }
@@ -2591,9 +2589,9 @@
  * window, 1 if the sample has to be considered in the next window.
  */
 
-static int westwood_new_window(struct sock *sk)
+static int westwood_new_window(const struct sock *sk)
 {
-	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
+	const struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 	__u32 left_bound;
 	__u32 rtt;
 	int ret = 0;
@@ -2627,14 +2625,13 @@
 	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 	__u32 delta = now - tp->westwood.rtt_win_sx;
 
-	if (!delta)
-		return;
-
-	if (tp->westwood.rtt)
-		westwood_filter(sk, delta);
-
-	tp->westwood.bk = 0;
-	tp->westwood.rtt_win_sx = tcp_time_stamp;
+	if (delta) {
+		if (tp->westwood.rtt)
+			westwood_filter(sk, delta);
+
+		tp->westwood.bk = 0;
+		tp->westwood.rtt_win_sx = tcp_time_stamp;
+	}
 }
 
 static void westwood_update_window(struct sock *sk, __u32 now)
@@ -2688,7 +2685,7 @@
 
 static inline int westwood_may_change_cumul(struct tcp_opt *tp)
 {
-	return ((tp->westwood.cumul_ack) > westwood_mss(tp));
+	return (tp->westwood.cumul_ack > westwood_mss(tp));
 }
 
 static inline void westwood_partial_update(struct tcp_opt *tp)
@@ -2709,7 +2706,7 @@
  * delayed or partial acks.
  */
 
-static __u32 westwood_acked_count(struct sock *sk)
+static inline __u32 westwood_acked_count(struct sock *sk)
 {
 	struct tcp_opt *tp = &(sk->tp_pinfo.af_tcp);
 
@@ -2723,7 +2720,7 @@
 
 	if (westwood_may_change_cumul(tp)) {
 		/* Partial or delayed ack */
-		if ((tp->westwood.accounted) >= (tp->westwood.cumul_ack))
+		if (tp->westwood.accounted >= tp->westwood.cumul_ack)
 			westwood_partial_update(tp);
 		else 
 			westwood_complete_update(tp);
