From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v4 net-next 03/16] tcp: use windowed min filter library for TCP min_rtt estimation
Date: Mon, 19 Sep 2016 23:39:10 -0400
Message-ID: <1474342763-16715-4-git-send-email-ncardwell@google.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35193 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753870AbcITDjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:39:33 -0400
Received: by mail-qk0-f172.google.com with SMTP id t7so4309804qkh.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 20:39:32 -0700 (PDT)
In-Reply-To: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor the TCP min_rtt code to reuse the new win_minmax library in
lib/win_minmax.c to simplify the TCP code.

This is a pure refactor: the functionality is exactly the same. We
just moved the windowed min code to make TCP easier to read and
maintain, and to allow other parts of the kernel to use the windowed
min/max filter code.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/linux/tcp.h      |  5 ++--
 include/net/tcp.h        |  2 +-
 net/ipv4/tcp.c           |  2 +-
 net/ipv4/tcp_input.c     | 64 ++++--------------------------------------------
 net/ipv4/tcp_minisocks.c |  2 +-
 5 files changed, 10 insertions(+), 65 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c723a46..6433cc8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -19,6 +19,7 @@
 
 
 #include <linux/skbuff.h>
+#include <linux/win_minmax.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -234,9 +235,7 @@ struct tcp_sock {
 	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
 	u32	rttvar_us;	/* smoothed mdev_max			*/
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
-	struct rtt_meas {
-		u32 rtt, ts;	/* RTT in usec and sampling time in jiffies. */
-	} rtt_min[3];
+	struct  minmax rtt_min;
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
 	u32	retrans_out;	/* Retransmitted packets out		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index fdfbedd..2f1648a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -671,7 +671,7 @@ static inline bool tcp_ca_dst_locked(const struct dst_entry *dst)
 /* Minimum RTT in usec. ~0 means not available. */
 static inline u32 tcp_min_rtt(const struct tcp_sock *tp)
 {
-	return tp->rtt_min[0].rtt;
+	return minmax_get(&tp->rtt_min);
 }
 
 /* Compute the actual receive window we are currently advertising.
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a13fcb3..5b0b49c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -387,7 +387,7 @@ void tcp_init_sock(struct sock *sk)
 
 	icsk->icsk_rto = TCP_TIMEOUT_INIT;
 	tp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
-	tp->rtt_min[0].rtt = ~0U;
+	minmax_reset(&tp->rtt_min, tcp_time_stamp, ~0U);
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 70b892d..ac5b38f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2879,67 +2879,13 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	*rexmit = REXMIT_LOST;
 }
 
-/* Kathleen Nichols' algorithm for tracking the minimum value of
- * a data stream over some fixed time interval. (E.g., the minimum
- * RTT over the past five minutes.) It uses constant space and constant
- * time per update yet almost always delivers the same minimum as an
- * implementation that has to keep all the data in the window.
- *
- * The algorithm keeps track of the best, 2nd best & 3rd best min
- * values, maintaining an invariant that the measurement time of the
- * n'th best >= n-1'th best. It also makes sure that the three values
- * are widely separated in the time window since that bounds the worse
- * case error when that data is monotonically increasing over the window.
- *
- * Upon getting a new min, we can forget everything earlier because it
- * has no value - the new min is <= everything else in the window by
- * definition and it's the most recent. So we restart fresh on every new min
- * and overwrites 2nd & 3rd choices. The same property holds for 2nd & 3rd
- * best.
- */
 static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
 {
-	const u32 now = tcp_time_stamp, wlen = sysctl_tcp_min_rtt_wlen * HZ;
-	struct rtt_meas *m = tcp_sk(sk)->rtt_min;
-	struct rtt_meas rttm = {
-		.rtt = likely(rtt_us) ? rtt_us : jiffies_to_usecs(1),
-		.ts = now,
-	};
-	u32 elapsed;
-
-	/* Check if the new measurement updates the 1st, 2nd, or 3rd choices */
-	if (unlikely(rttm.rtt <= m[0].rtt))
-		m[0] = m[1] = m[2] = rttm;
-	else if (rttm.rtt <= m[1].rtt)
-		m[1] = m[2] = rttm;
-	else if (rttm.rtt <= m[2].rtt)
-		m[2] = rttm;
-
-	elapsed = now - m[0].ts;
-	if (unlikely(elapsed > wlen)) {
-		/* Passed entire window without a new min so make 2nd choice
-		 * the new min & 3rd choice the new 2nd. So forth and so on.
-		 */
-		m[0] = m[1];
-		m[1] = m[2];
-		m[2] = rttm;
-		if (now - m[0].ts > wlen) {
-			m[0] = m[1];
-			m[1] = rttm;
-			if (now - m[0].ts > wlen)
-				m[0] = rttm;
-		}
-	} else if (m[1].ts == m[0].ts && elapsed > wlen / 4) {
-		/* Passed a quarter of the window without a new min so
-		 * take 2nd choice from the 2nd quarter of the window.
-		 */
-		m[2] = m[1] = rttm;
-	} else if (m[2].ts == m[1].ts && elapsed > wlen / 2) {
-		/* Passed half the window without a new min so take the 3rd
-		 * choice from the last half of the window.
-		 */
-		m[2] = rttm;
-	}
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 wlen = sysctl_tcp_min_rtt_wlen * HZ;
+
+	minmax_running_min(&tp->rtt_min, wlen, tcp_time_stamp,
+			   rtt_us ? : jiffies_to_usecs(1));
 }
 
 static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f63c73d..5689471 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -464,7 +464,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->srtt_us = 0;
 		newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
-		newtp->rtt_min[0].rtt = ~0U;
+		minmax_reset(&newtp->rtt_min, tcp_time_stamp, ~0U);
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
 
 		newtp->packets_out = 0;
-- 
2.8.0.rc3.226.g39d4020
