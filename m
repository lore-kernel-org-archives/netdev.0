From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/3) tcp westwood cleanup
Date: Mon, 27 Sep 2004 11:22:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927112249.38bea6ff@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Westwood code cleanup;
	* use const.
	* avoid needless paren's and returns
	* inline acked_count (called once)

diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-09-27 10:26:03 -07:00
+++ b/net/ipv4/tcp_input.c	2004-09-27 10:26:03 -07:00
@@ -2620,18 +2620,16 @@
  * WESTWOOD_RTT_MIN minimum bound since we could be on a LAN!
  */
 
-static inline __u32 westwood_update_rttmin(struct sock *sk)
+static inline __u32 westwood_update_rttmin(const struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_opt *tp = tcp_sk(sk);
 	__u32 rttmin = tp->westwood.rtt_min;
 
-	if (tp->westwood.rtt == 0)
-		return(rttmin);
-
-	if (tp->westwood.rtt < tp->westwood.rtt_min || !rttmin)
+	if (tp->westwood.rtt != 0 &&
+	    (tp->westwood.rtt < tp->westwood.rtt_min || !rttmin))
 		rttmin = tp->westwood.rtt;
 
-	return(rttmin);
+	return rttmin;
 }
 
 /*
@@ -2639,11 +2637,11 @@
  * Evaluate increases for dk. 
  */
 
-static inline __u32 westwood_acked(struct sock *sk)
+static inline __u32 westwood_acked(const struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_opt *tp = tcp_sk(sk);
 
-	return ((tp->snd_una) - (tp->westwood.snd_una));
+	return tp->snd_una - tp->westwood.snd_una;
 }
 
 /*
@@ -2655,9 +2653,9 @@
  * window, 1 if the sample has to be considered in the next window.
  */
 
-static int westwood_new_window(struct sock *sk)
+static int westwood_new_window(const struct sock *sk)
 {
-	struct tcp_opt *tp = tcp_sk(sk);
+	const struct tcp_opt *tp = tcp_sk(sk);
 	__u32 left_bound;
 	__u32 rtt;
 	int ret = 0;
@@ -2691,14 +2689,13 @@
 	struct tcp_opt *tp = tcp_sk(sk);
 	__u32 delta = now - tp->westwood.rtt_win_sx;
 
-        if (!delta)
-                return;
-
-	if (tp->westwood.rtt)
-                westwood_filter(sk, delta);
-
-        tp->westwood.bk = 0;
-        tp->westwood.rtt_win_sx = tcp_time_stamp;
+        if (delta) {
+		if (tp->westwood.rtt)
+			westwood_filter(sk, delta);
+
+		tp->westwood.bk = 0;
+		tp->westwood.rtt_win_sx = tcp_time_stamp;
+	}
 }
 
 
@@ -2742,7 +2739,7 @@
 
 static inline int westwood_may_change_cumul(struct tcp_opt *tp)
 {
-	return ((tp->westwood.cumul_ack) > tp->mss_cache_std);
+	return (tp->westwood.cumul_ack > tp->mss_cache_std);
 }
 
 static inline void westwood_partial_update(struct tcp_opt *tp)
@@ -2763,7 +2760,7 @@
  * delayed or partial acks.
  */
 
-static __u32 westwood_acked_count(struct sock *sk)
+static inline __u32 westwood_acked_count(struct sock *sk)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 
@@ -2777,7 +2774,7 @@
 
         if (westwood_may_change_cumul(tp)) {
 		/* Partial or delayed ack */
-		if ((tp->westwood.accounted) >= (tp->westwood.cumul_ack))
+		if (tp->westwood.accounted >= tp->westwood.cumul_ack)
 			westwood_partial_update(tp);
 		else
 			westwood_complete_update(tp);
