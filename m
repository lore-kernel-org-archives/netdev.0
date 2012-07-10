From: David Miller <davem@davemloft.net>
Subject: [PATCH 01/16] tcp: Move dynamnic metrics handling into seperate
 file.
Date: Tue, 10 Jul 2012 08:07:08 -0700 (PDT)
Message-ID: <20120710.080708.201390738580969426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698Ab2GJPHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:09 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2E824586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h      |    4 +
 net/ipv4/Makefile      |    2 +-
 net/ipv4/tcp_input.c   |  188 +----------------------------------------------
 net/ipv4/tcp_metrics.c |  192 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 199 insertions(+), 187 deletions(-)
 create mode 100644 net/ipv4/tcp_metrics.c

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 53fb7d8..98ca797 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -388,6 +388,8 @@ extern void tcp_enter_frto(struct sock *sk);
 extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
+extern void tcp_init_metrics(struct sock *sk);
+extern void tcp_disable_fack(struct tcp_sock *tp);
 extern void tcp_close(struct sock *sk, long timeout);
 extern void tcp_init_sock(struct sock *sk);
 extern unsigned int tcp_poll(struct file * file, struct socket *sock,
@@ -556,6 +558,8 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 	return (tp->srtt >> 3) + tp->rttvar;
 }
 
+extern void tcp_set_rto(struct sock *sk);
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index ff75d3b..5a23e8b 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -7,7 +7,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
-	     tcp_minisocks.o tcp_cong.o \
+	     tcp_minisocks.o tcp_cong.o tcp_metrics.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ca0d0e7..055ac49 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -93,7 +93,6 @@ int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_frto_response __read_mostly;
-int sysctl_tcp_nometrics_save __read_mostly;
 
 int sysctl_tcp_thin_dupack __read_mostly;
 
@@ -701,7 +700,7 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
  * routine referred to above.
  */
-static inline void tcp_set_rto(struct sock *sk)
+void tcp_set_rto(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	/* Old crap is replaced with new one. 8)
@@ -728,109 +727,6 @@ static inline void tcp_set_rto(struct sock *sk)
 	tcp_bound_rto(sk);
 }
 
-/* Save metrics learned by this TCP session.
-   This function is called only, when TCP finishes successfully
-   i.e. when it enters TIME-WAIT or goes from LAST-ACK to CLOSE.
- */
-void tcp_update_metrics(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
-
-	if (sysctl_tcp_nometrics_save)
-		return;
-
-	if (dst && (dst->flags & DST_HOST)) {
-		const struct inet_connection_sock *icsk = inet_csk(sk);
-		int m;
-		unsigned long rtt;
-
-		dst_confirm(dst);
-
-		if (icsk->icsk_backoff || !tp->srtt) {
-			/* This session failed to estimate rtt. Why?
-			 * Probably, no packets returned in time.
-			 * Reset our results.
-			 */
-			if (!(dst_metric_locked(dst, RTAX_RTT)))
-				dst_metric_set(dst, RTAX_RTT, 0);
-			return;
-		}
-
-		rtt = dst_metric_rtt(dst, RTAX_RTT);
-		m = rtt - tp->srtt;
-
-		/* If newly calculated rtt larger than stored one,
-		 * store new one. Otherwise, use EWMA. Remember,
-		 * rtt overestimation is always better than underestimation.
-		 */
-		if (!(dst_metric_locked(dst, RTAX_RTT))) {
-			if (m <= 0)
-				set_dst_metric_rtt(dst, RTAX_RTT, tp->srtt);
-			else
-				set_dst_metric_rtt(dst, RTAX_RTT, rtt - (m >> 3));
-		}
-
-		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
-			unsigned long var;
-			if (m < 0)
-				m = -m;
-
-			/* Scale deviation to rttvar fixed point */
-			m >>= 1;
-			if (m < tp->mdev)
-				m = tp->mdev;
-
-			var = dst_metric_rtt(dst, RTAX_RTTVAR);
-			if (m >= var)
-				var = m;
-			else
-				var -= (var - m) >> 2;
-
-			set_dst_metric_rtt(dst, RTAX_RTTVAR, var);
-		}
-
-		if (tcp_in_initial_slowstart(tp)) {
-			/* Slow start still did not finish. */
-			if (dst_metric(dst, RTAX_SSTHRESH) &&
-			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
-			    (tp->snd_cwnd >> 1) > dst_metric(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_cwnd >> 1);
-			if (!dst_metric_locked(dst, RTAX_CWND) &&
-			    tp->snd_cwnd > dst_metric(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND, tp->snd_cwnd);
-		} else if (tp->snd_cwnd > tp->snd_ssthresh &&
-			   icsk->icsk_ca_state == TCP_CA_Open) {
-			/* Cong. avoidance phase, cwnd is reliable. */
-			if (!dst_metric_locked(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH,
-					       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
-			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND,
-					       (dst_metric(dst, RTAX_CWND) +
-						tp->snd_cwnd) >> 1);
-		} else {
-			/* Else slow start did not finish, cwnd is non-sense,
-			   ssthresh may be also invalid.
-			 */
-			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND,
-					       (dst_metric(dst, RTAX_CWND) +
-						tp->snd_ssthresh) >> 1);
-			if (dst_metric(dst, RTAX_SSTHRESH) &&
-			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
-			    tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_ssthresh);
-		}
-
-		if (!dst_metric_locked(dst, RTAX_REORDERING)) {
-			if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
-			    tp->reordering != sysctl_tcp_reordering)
-				dst_metric_set(dst, RTAX_REORDERING, tp->reordering);
-		}
-	}
-}
-
 __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst)
 {
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
@@ -867,7 +763,7 @@ void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
  * Packet counting of FACK is based on in-order assumptions, therefore TCP
  * disables it when reordering is detected
  */
-static void tcp_disable_fack(struct tcp_sock *tp)
+void tcp_disable_fack(struct tcp_sock *tp)
 {
 	/* RFC3517 uses different metric in lost marker => reset on change */
 	if (tcp_is_fack(tp))
@@ -881,86 +777,6 @@ static void tcp_dsack_seen(struct tcp_sock *tp)
 	tp->rx_opt.sack_ok |= TCP_DSACK_SEEN;
 }
 
-/* Initialize metrics on socket. */
-
-static void tcp_init_metrics(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
-
-	if (dst == NULL)
-		goto reset;
-
-	dst_confirm(dst);
-
-	if (dst_metric_locked(dst, RTAX_CWND))
-		tp->snd_cwnd_clamp = dst_metric(dst, RTAX_CWND);
-	if (dst_metric(dst, RTAX_SSTHRESH)) {
-		tp->snd_ssthresh = dst_metric(dst, RTAX_SSTHRESH);
-		if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
-			tp->snd_ssthresh = tp->snd_cwnd_clamp;
-	} else {
-		/* ssthresh may have been reduced unnecessarily during.
-		 * 3WHS. Restore it back to its initial default.
-		 */
-		tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
-	}
-	if (dst_metric(dst, RTAX_REORDERING) &&
-	    tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
-		tcp_disable_fack(tp);
-		tcp_disable_early_retrans(tp);
-		tp->reordering = dst_metric(dst, RTAX_REORDERING);
-	}
-
-	if (dst_metric(dst, RTAX_RTT) == 0 || tp->srtt == 0)
-		goto reset;
-
-	/* Initial rtt is determined from SYN,SYN-ACK.
-	 * The segment is small and rtt may appear much
-	 * less than real one. Use per-dst memory
-	 * to make it more realistic.
-	 *
-	 * A bit of theory. RTT is time passed after "normal" sized packet
-	 * is sent until it is ACKed. In normal circumstances sending small
-	 * packets force peer to delay ACKs and calculation is correct too.
-	 * The algorithm is adaptive and, provided we follow specs, it
-	 * NEVER underestimate RTT. BUT! If peer tries to make some clever
-	 * tricks sort of "quick acks" for time long enough to decrease RTT
-	 * to low value, and then abruptly stops to do it and starts to delay
-	 * ACKs, wait for troubles.
-	 */
-	if (dst_metric_rtt(dst, RTAX_RTT) > tp->srtt) {
-		tp->srtt = dst_metric_rtt(dst, RTAX_RTT);
-		tp->rtt_seq = tp->snd_nxt;
-	}
-	if (dst_metric_rtt(dst, RTAX_RTTVAR) > tp->mdev) {
-		tp->mdev = dst_metric_rtt(dst, RTAX_RTTVAR);
-		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
-	}
-	tcp_set_rto(sk);
-reset:
-	if (tp->srtt == 0) {
-		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
-		 * 3WHS. This is most likely due to retransmission,
-		 * including spurious one. Reset the RTO back to 3secs
-		 * from the more aggressive 1sec to avoid more spurious
-		 * retransmission.
-		 */
-		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_FALLBACK;
-		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_FALLBACK;
-	}
-	/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has been
-	 * retransmitted. In light of RFC6298 more aggressive 1sec
-	 * initRTO, we only reset cwnd when more than 1 SYN/SYN-ACK
-	 * retransmission has occurred.
-	 */
-	if (tp->total_retrans > 1)
-		tp->snd_cwnd = 1;
-	else
-		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-}
-
 static void tcp_update_reordering(struct sock *sk, const int metric,
 				  const int ts)
 {
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
new file mode 100644
index 0000000..2793ecf
--- /dev/null
+++ b/net/ipv4/tcp_metrics.c
@@ -0,0 +1,192 @@
+#include <linux/cache.h>
+#include <linux/tcp.h>
+
+#include <net/inet_connection_sock.h>
+#include <net/sock.h>
+#include <net/dst.h>
+#include <net/tcp.h>
+
+int sysctl_tcp_nometrics_save __read_mostly;
+
+/* Save metrics learned by this TCP session.  This function is called
+ * only, when TCP finishes successfully i.e. when it enters TIME-WAIT
+ * or goes from LAST-ACK to CLOSE.
+ */
+void tcp_update_metrics(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
+
+	if (sysctl_tcp_nometrics_save)
+		return;
+
+	if (dst && (dst->flags & DST_HOST)) {
+		const struct inet_connection_sock *icsk = inet_csk(sk);
+		int m;
+		unsigned long rtt;
+
+		dst_confirm(dst);
+
+		if (icsk->icsk_backoff || !tp->srtt) {
+			/* This session failed to estimate rtt. Why?
+			 * Probably, no packets returned in time.
+			 * Reset our results.
+			 */
+			if (!(dst_metric_locked(dst, RTAX_RTT)))
+				dst_metric_set(dst, RTAX_RTT, 0);
+			return;
+		}
+
+		rtt = dst_metric_rtt(dst, RTAX_RTT);
+		m = rtt - tp->srtt;
+
+		/* If newly calculated rtt larger than stored one,
+		 * store new one. Otherwise, use EWMA. Remember,
+		 * rtt overestimation is always better than underestimation.
+		 */
+		if (!(dst_metric_locked(dst, RTAX_RTT))) {
+			if (m <= 0)
+				set_dst_metric_rtt(dst, RTAX_RTT, tp->srtt);
+			else
+				set_dst_metric_rtt(dst, RTAX_RTT, rtt - (m >> 3));
+		}
+
+		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
+			unsigned long var;
+			if (m < 0)
+				m = -m;
+
+			/* Scale deviation to rttvar fixed point */
+			m >>= 1;
+			if (m < tp->mdev)
+				m = tp->mdev;
+
+			var = dst_metric_rtt(dst, RTAX_RTTVAR);
+			if (m >= var)
+				var = m;
+			else
+				var -= (var - m) >> 2;
+
+			set_dst_metric_rtt(dst, RTAX_RTTVAR, var);
+		}
+
+		if (tcp_in_initial_slowstart(tp)) {
+			/* Slow start still did not finish. */
+			if (dst_metric(dst, RTAX_SSTHRESH) &&
+			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
+			    (tp->snd_cwnd >> 1) > dst_metric(dst, RTAX_SSTHRESH))
+				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_cwnd >> 1);
+			if (!dst_metric_locked(dst, RTAX_CWND) &&
+			    tp->snd_cwnd > dst_metric(dst, RTAX_CWND))
+				dst_metric_set(dst, RTAX_CWND, tp->snd_cwnd);
+		} else if (tp->snd_cwnd > tp->snd_ssthresh &&
+			   icsk->icsk_ca_state == TCP_CA_Open) {
+			/* Cong. avoidance phase, cwnd is reliable. */
+			if (!dst_metric_locked(dst, RTAX_SSTHRESH))
+				dst_metric_set(dst, RTAX_SSTHRESH,
+					       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
+			if (!dst_metric_locked(dst, RTAX_CWND))
+				dst_metric_set(dst, RTAX_CWND,
+					       (dst_metric(dst, RTAX_CWND) +
+						tp->snd_cwnd) >> 1);
+		} else {
+			/* Else slow start did not finish, cwnd is non-sense,
+			   ssthresh may be also invalid.
+			 */
+			if (!dst_metric_locked(dst, RTAX_CWND))
+				dst_metric_set(dst, RTAX_CWND,
+					       (dst_metric(dst, RTAX_CWND) +
+						tp->snd_ssthresh) >> 1);
+			if (dst_metric(dst, RTAX_SSTHRESH) &&
+			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
+			    tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
+				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_ssthresh);
+		}
+
+		if (!dst_metric_locked(dst, RTAX_REORDERING)) {
+			if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
+			    tp->reordering != sysctl_tcp_reordering)
+				dst_metric_set(dst, RTAX_REORDERING, tp->reordering);
+		}
+	}
+}
+
+/* Initialize metrics on socket. */
+
+void tcp_init_metrics(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct dst_entry *dst = __sk_dst_get(sk);
+
+	if (dst == NULL)
+		goto reset;
+
+	dst_confirm(dst);
+
+	if (dst_metric_locked(dst, RTAX_CWND))
+		tp->snd_cwnd_clamp = dst_metric(dst, RTAX_CWND);
+	if (dst_metric(dst, RTAX_SSTHRESH)) {
+		tp->snd_ssthresh = dst_metric(dst, RTAX_SSTHRESH);
+		if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
+			tp->snd_ssthresh = tp->snd_cwnd_clamp;
+	} else {
+		/* ssthresh may have been reduced unnecessarily during.
+		 * 3WHS. Restore it back to its initial default.
+		 */
+		tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
+	}
+	if (dst_metric(dst, RTAX_REORDERING) &&
+	    tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
+		tcp_disable_fack(tp);
+		tcp_disable_early_retrans(tp);
+		tp->reordering = dst_metric(dst, RTAX_REORDERING);
+	}
+
+	if (dst_metric(dst, RTAX_RTT) == 0 || tp->srtt == 0)
+		goto reset;
+
+	/* Initial rtt is determined from SYN,SYN-ACK.
+	 * The segment is small and rtt may appear much
+	 * less than real one. Use per-dst memory
+	 * to make it more realistic.
+	 *
+	 * A bit of theory. RTT is time passed after "normal" sized packet
+	 * is sent until it is ACKed. In normal circumstances sending small
+	 * packets force peer to delay ACKs and calculation is correct too.
+	 * The algorithm is adaptive and, provided we follow specs, it
+	 * NEVER underestimate RTT. BUT! If peer tries to make some clever
+	 * tricks sort of "quick acks" for time long enough to decrease RTT
+	 * to low value, and then abruptly stops to do it and starts to delay
+	 * ACKs, wait for troubles.
+	 */
+	if (dst_metric_rtt(dst, RTAX_RTT) > tp->srtt) {
+		tp->srtt = dst_metric_rtt(dst, RTAX_RTT);
+		tp->rtt_seq = tp->snd_nxt;
+	}
+	if (dst_metric_rtt(dst, RTAX_RTTVAR) > tp->mdev) {
+		tp->mdev = dst_metric_rtt(dst, RTAX_RTTVAR);
+		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
+	}
+	tcp_set_rto(sk);
+reset:
+	if (tp->srtt == 0) {
+		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
+		 * 3WHS. This is most likely due to retransmission,
+		 * including spurious one. Reset the RTO back to 3secs
+		 * from the more aggressive 1sec to avoid more spurious
+		 * retransmission.
+		 */
+		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_FALLBACK;
+		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_FALLBACK;
+	}
+	/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has been
+	 * retransmitted. In light of RFC6298 more aggressive 1sec
+	 * initRTO, we only reset cwnd when more than 1 SYN/SYN-ACK
+	 * retransmission has occurred.
+	 */
+	if (tp->total_retrans > 1)
+		tp->snd_cwnd = 1;
+	else
+		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+}
-- 
1.7.10.4
