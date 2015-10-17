From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 2/7] tcp: track min RTT using windowed min-filter
Date: Fri, 16 Oct 2015 21:57:42 -0700
Message-ID: <1445057867-32257-3-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35048 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbbJQE6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:04 -0400
Received: by payp3 with SMTP id p3so7576853pay.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:04 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kathleen Nichols' algorithm for tracking the minimum RTT of a
data stream over some measurement window. It uses constant space
and constant time per update. Yet it almost always delivers
the same minimum as an implementation that has to keep all
the data in the window. The measurement window is tunable via
sysctl.net.ipv4.tcp_min_rtt_wlen with a default value of 5 minutes.

The algorithm keeps track of the best, 2nd best & 3rd best min
values, maintaining an invariant that the measurement time of
the n'th best >= n-1'th best. It also makes sure that the three
values are widely separated in the time window since that bounds
the worse case error when that data is monotonically increasing
over the window.

Upon getting a new min, we can forget everything earlier because
it has no value - the new min is less than everything else in the
window by definition and it's the most recent. So we restart fresh
on every new min and overwrites the 2nd & 3rd choices. The same
property holds for the 2nd & 3rd best.

Therefore we have to maintain two invariants to maximize the
information in the samples, one on values (1st.v <= 2nd.v <=
3rd.v) and the other on times (now-win <=1st.t <= 2nd.t <= 3rd.t <=
now). These invariants determine the structure of the code

The RTT input to the windowed filter is the minimum RTT measured
from ACK or SACK, or as the last resort from TCP timestamps.

The accessor tcp_min_rtt() returns the minimum RTT seen in the
window. ~0U indicates it is not available. The minimum is 1usec
even if the true RTT is below that.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |  8 ++++
 include/linux/tcp.h                    |  3 ++
 include/net/tcp.h                      |  7 +++
 net/ipv4/sysctl_net_ipv4.c             |  7 +++
 net/ipv4/tcp.c                         |  1 +
 net/ipv4/tcp_input.c                   | 78 +++++++++++++++++++++++++++++++---
 net/ipv4/tcp_minisocks.c               |  1 +
 7 files changed, 100 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2..502d6a5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -384,6 +384,14 @@ tcp_mem - vector of 3 INTEGERs: min, pressure, max
 	Defaults are calculated at boot time from amount of available
 	memory.
 
+tcp_min_rtt_wlen - INTEGER
+	The window length of the windowed min filter to track the minimum RTT.
+	A shorter window lets a flow more quickly pick up new (higher)
+	minimum RTT when it is moved to a longer path (e.g., due to traffic
+	engineering). A longer window makes the filter more resistant to RTT
+	inflations such as transient congestion. The unit is seconds.
+	Default: 300
+
 tcp_moderate_rcvbuf - BOOLEAN
 	If set, TCP performs receive buffer auto-tuning, attempting to
 	automatically size the buffer (no greater than tcp_rmem[2]) to
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 86a7eda..90edef5 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -217,6 +217,9 @@ struct tcp_sock {
 	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
 	u32	rttvar_us;	/* smoothed mdev_max			*/
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
+	struct rtt_meas {
+		u32 rtt, ts;	/* RTT in usec and sampling time in jiffies. */
+	} rtt_min[3];
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
 	u32	retrans_out;	/* Retransmitted packets out		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a6be56d..4575f0e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -279,6 +279,7 @@ extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
 extern unsigned int sysctl_tcp_notsent_lowat;
 extern int sysctl_tcp_min_tso_segs;
+extern int sysctl_tcp_min_rtt_wlen;
 extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
@@ -671,6 +672,12 @@ static inline bool tcp_ca_dst_locked(const struct dst_entry *dst)
 	return dst_metric_locked(dst, RTAX_CC_ALGO);
 }
 
+/* Minimum RTT in usec. ~0 means not available. */
+static inline u32 tcp_min_rtt(const struct tcp_sock *tp)
+{
+	return tp->rtt_min[0].rtt;
+}
+
 /* Compute the actual receive window we are currently advertising.
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 894da3a..13ab434 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -577,6 +577,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "tcp_min_rtt_wlen",
+		.data		= &sysctl_tcp_min_rtt_wlen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ac1bdbb..0cfa7c0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -388,6 +388,7 @@ void tcp_init_sock(struct sock *sk)
 
 	icsk->icsk_rto = TCP_TIMEOUT_INIT;
 	tp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
+	tp->rtt_min[0].rtt = ~0U;
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 38743e5..e177386 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -95,6 +95,7 @@ int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
+int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 
 int sysctl_tcp_thin_dupack __read_mostly;
 
@@ -2915,8 +2916,69 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	tcp_xmit_retransmit_queue(sk);
 }
 
+/* Kathleen Nichols' algorithm for tracking the minimum value of
+ * a data stream over some fixed time interval. (E.g., the minimum
+ * RTT over the past five minutes.) It uses constant space and constant
+ * time per update yet almost always delivers the same minimum as an
+ * implementation that has to keep all the data in the window.
+ *
+ * The algorithm keeps track of the best, 2nd best & 3rd best min
+ * values, maintaining an invariant that the measurement time of the
+ * n'th best >= n-1'th best. It also makes sure that the three values
+ * are widely separated in the time window since that bounds the worse
+ * case error when that data is monotonically increasing over the window.
+ *
+ * Upon getting a new min, we can forget everything earlier because it
+ * has no value - the new min is <= everything else in the window by
+ * definition and it's the most recent. So we restart fresh on every new min
+ * and overwrites 2nd & 3rd choices. The same property holds for 2nd & 3rd
+ * best.
+ */
+static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
+{
+	const u32 now = tcp_time_stamp, wlen = sysctl_tcp_min_rtt_wlen * HZ;
+	struct rtt_meas *m = tcp_sk(sk)->rtt_min;
+	struct rtt_meas rttm = { .rtt = (rtt_us ? : 1), .ts = now };
+	u32 elapsed;
+
+	/* Check if the new measurement updates the 1st, 2nd, or 3rd choices */
+	if (unlikely(rttm.rtt <= m[0].rtt))
+		m[0] = m[1] = m[2] = rttm;
+	else if (rttm.rtt <= m[1].rtt)
+		m[1] = m[2] = rttm;
+	else if (rttm.rtt <= m[2].rtt)
+		m[2] = rttm;
+
+	elapsed = now - m[0].ts;
+	if (unlikely(elapsed > wlen)) {
+		/* Passed entire window without a new min so make 2nd choice
+		 * the new min & 3rd choice the new 2nd. So forth and so on.
+		 */
+		m[0] = m[1];
+		m[1] = m[2];
+		m[2] = rttm;
+		if (now - m[0].ts > wlen) {
+			m[0] = m[1];
+			m[1] = rttm;
+			if (now - m[0].ts > wlen)
+				m[0] = rttm;
+		}
+	} else if (m[1].ts == m[0].ts && elapsed > wlen / 4) {
+		/* Passed a quarter of the window without a new min so
+		 * take 2nd choice from the 2nd quarter of the window.
+		 */
+		m[2] = m[1] = rttm;
+	} else if (m[2].ts == m[1].ts && elapsed > wlen / 2) {
+		/* Passed half the window without a new min so take the 3rd
+		 * choice from the last half of the window.
+		 */
+		m[2] = rttm;
+	}
+}
+
 static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
-				      long seq_rtt_us, long sack_rtt_us)
+				      long seq_rtt_us, long sack_rtt_us,
+				      long ca_rtt_us)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2936,11 +2998,16 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 	 */
 	if (seq_rtt_us < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 	    flag & FLAG_ACKED)
-		seq_rtt_us = jiffies_to_usecs(tcp_time_stamp - tp->rx_opt.rcv_tsecr);
-
+		seq_rtt_us = ca_rtt_us = jiffies_to_usecs(tcp_time_stamp -
+							  tp->rx_opt.rcv_tsecr);
 	if (seq_rtt_us < 0)
 		return false;
 
+	/* ca_rtt_us >= 0 is counting on the invariant that ca_rtt_us is
+	 * always taken together with ACK, SACK, or TS-opts. Any negative
+	 * values will be skipped with the seq_rtt_us < 0 check above.
+	 */
+	tcp_update_rtt_min(sk, ca_rtt_us);
 	tcp_rtt_estimator(sk, seq_rtt_us);
 	tcp_set_rto(sk);
 
@@ -2961,7 +3028,7 @@ void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
 		rtt_us = skb_mstamp_us_delta(&now, &tcp_rsk(req)->snt_synack);
 	}
 
-	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L);
+	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us);
 }
 
 
@@ -3175,7 +3242,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		ca_rtt_us = skb_mstamp_us_delta(&now, &sack->last_sackt);
 	}
 
-	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us);
+	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us,
+					ca_rtt_us);
 
 	if (flag & FLAG_ACKED) {
 		tcp_rearm_rto(sk);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 41828bd..b875c28 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -470,6 +470,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->srtt_us = 0;
 		newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
+		newtp->rtt_min[0].rtt = ~0U;
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
 
 		newtp->packets_out = 0;
-- 
2.6.0.rc2.230.g3dd15c0
