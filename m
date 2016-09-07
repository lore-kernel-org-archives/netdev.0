From: "Francis Y. Yan" <francisyyan@gmail.com>
Subject: [PATCH net-next 1/2] tcp: measure rwnd-limited time
Date: Tue,  6 Sep 2016 18:32:40 -0700
Message-ID: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, soheil@google.com,
        ncardwell@google.com, "Francis Y. Yan" <francisyyan@gmail.com>,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36022 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756041AbcIGBcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 21:32:51 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so65537pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 18:32:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch measures the total time when TCP transmission is limited
by receiver's advertised window (rwnd), and exports it in tcp_info as
tcpi_rwnd_limited.

The rwnd-limited time is defined as the period when the next segment
to send by TCP cannot fit into rwnd. To measure it, we record the last
timestamp when limited by rwnd (rwnd_limited_ts) and the total
rwnd-limited time (rwnd_limited) in tcp_sock.

Then we export the total rwnd-limited time so far in tcp_info, where
by so far, we mean that if TCP transmission is still being limited by
rwnd, the time interval since rwnd_limited_ts needs to be counted as
well; otherwise, we simply export rwnd_limited.

It is worth noting that we also have to add a new sequence counter
(seqcnt) in tcp_sock to carefully handle tcp_info's reading of
rwnd_limited_ts and rwnd_limited in order to get a consistent snapshot
of both variables together.

Signed-off-by: Francis Y. Yan <francisyyan@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/linux/tcp.h      |  5 +++++
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/tcp.c           |  9 ++++++++-
 net/ipv4/tcp_output.c    | 39 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7be9b12..f5b588e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -176,6 +176,7 @@ struct tcp_sock {
 				 * were acked.
 				 */
 	struct u64_stats_sync syncp; /* protects 64bit vars (cf tcp_get_info()) */
+	seqcount_t seqcnt;	/* proctects rwnd-limited-related vars, etc. */
 
  	u32	snd_una;	/* First byte we want an ack for	*/
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
@@ -204,6 +205,8 @@ struct tcp_sock {
 
 	u32	window_clamp;	/* Maximal window to advertise		*/
 	u32	rcv_ssthresh;	/* Current window clamp			*/
+	struct skb_mstamp rwnd_limited_ts; /* Last timestamp limited by rwnd */
+	u64	rwnd_limited;	/* Total time (us) limited by rwnd */
 
 	/* Information of the most recently (s)acked skb */
 	struct tcp_rack {
@@ -422,4 +425,6 @@ static inline void tcp_saved_syn_free(struct tcp_sock *tp)
 	tp->saved_syn = NULL;
 }
 
+u32 tcp_rwnd_limited_delta(const struct tcp_sock *tp);
+
 #endif	/* _LINUX_TCP_H */
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 482898f..f1e2de4 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -211,6 +211,7 @@ struct tcp_info {
 	__u32	tcpi_min_rtt;
 	__u32	tcpi_data_segs_in;	/* RFC4898 tcpEStatsDataSegsIn */
 	__u32	tcpi_data_segs_out;	/* RFC4898 tcpEStatsDataSegsOut */
+	__u64	tcpi_rwnd_limited;	/* total time (us) limited by rwnd */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 77311a9..ed77f2c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -380,6 +380,7 @@ void tcp_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	seqcount_init(&tp->seqcnt);
 	__skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
@@ -2690,7 +2691,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	u32 now = tcp_time_stamp;
 	unsigned int start;
 	int notsent_bytes;
-	u64 rate64;
+	u64 rate64, rwnd_limited;
 	u32 rate;
 
 	memset(info, 0, sizeof(*info));
@@ -2777,6 +2778,12 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_min_rtt = tcp_min_rtt(tp);
 	info->tcpi_data_segs_in = tp->data_segs_in;
 	info->tcpi_data_segs_out = tp->data_segs_out;
+
+	do {
+		start = read_seqcount_begin(&tp->seqcnt);
+		rwnd_limited = tp->rwnd_limited + tcp_rwnd_limited_delta(tp);
+	} while (read_seqcount_retry(&tp->seqcnt, start));
+	put_unaligned(rwnd_limited, &info->tcpi_rwnd_limited);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8b45794..dab0883 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2020,6 +2020,39 @@ static int tcp_mtu_probe(struct sock *sk)
 	return -1;
 }
 
+u32 tcp_rwnd_limited_delta(const struct tcp_sock *tp)
+{
+	if (tp->rwnd_limited_ts.v64) {
+		struct skb_mstamp now;
+
+		skb_mstamp_get(&now);
+		return skb_mstamp_us_delta(&now, &tp->rwnd_limited_ts);
+	}
+
+	return 0;
+}
+
+static void tcp_start_rwnd_limited(struct tcp_sock *tp)
+{
+	if (!tp->rwnd_limited_ts.v64) {
+		write_seqcount_begin(&tp->seqcnt);
+		skb_mstamp_get(&tp->rwnd_limited_ts);
+		write_seqcount_end(&tp->seqcnt);
+	}
+}
+
+static void tcp_stop_rwnd_limited(struct tcp_sock *tp)
+{
+	if (tp->rwnd_limited_ts.v64) {
+		u32 delta = tcp_rwnd_limited_delta(tp);
+
+		write_seqcount_begin(&tp->seqcnt);
+		tp->rwnd_limited += delta;
+		tp->rwnd_limited_ts.v64 = 0;
+		write_seqcount_end(&tp->seqcnt);
+	}
+}
+
 /* This routine writes packets to the network.  It advances the
  * send_head.  This happens as incoming acks open up the remote
  * window for us.
@@ -2072,6 +2105,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 		cwnd_quota = tcp_cwnd_test(tp, skb);
 		if (!cwnd_quota) {
+			tcp_stop_rwnd_limited(tp);
 			if (push_one == 2)
 				/* Force out a loss probe pkt. */
 				cwnd_quota = 1;
@@ -2079,8 +2113,11 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
+		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now))) {
+			tcp_start_rwnd_limited(tp);
 			break;
+		}
+		tcp_stop_rwnd_limited(tp);
 
 		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
-- 
2.8.0.rc3.226.g39d4020
