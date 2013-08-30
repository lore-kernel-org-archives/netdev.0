From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not use cached RTT for RTT estimation
Date: Fri, 30 Aug 2013 08:35:53 -0700
Message-ID: <1377876953.7360.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63470 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424Ab3H3Pf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 11:35:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so2466013pad.5
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 08:35:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>

RTT cached in the TCP metrics are valuable for the initial timeout
because SYN RTT usually does not account for serialization delays
on low BW path.

However using it to seed the RTT estimator maybe disruptive because
other components (e.g., pacing) require the smooth RTT to be obtained
from actual connection.

The solution is to use the higher cached RTT to set the first RTO
conservatively like tcp_rtt_estimator(), but avoid seeding the other
RTT estimator variables such as srtt.  It is also a good idea to
keep RTO conservative to obtain the first RTT sample, and the
performance is insured by TCP loss probe if SYN RTT is available.

To keep the seeding formula consistent across SYN RTT and cached RTT,
the rttvar is twice the cached RTT instead of cached RTTVAR value. The
reason is because cached variation may be too small (near min RTO)
which defeats the purpose of being conservative on first RTO. However
the metrics still keep the RTT variations as they might be useful for
user applications (through ip).

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Eric Dumazet <edumazet@google.com>
---
Google-Bug-Id: 6427464

 net/ipv4/tcp_metrics.c |   44 +++++++++------------------------------
 1 file changed, 11 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f6a005c..273ed73 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -443,7 +443,7 @@ void tcp_init_metrics(struct sock *sk)
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_metrics_block *tm;
-	u32 val;
+	u32 val, crtt = 0; /* cached RTT scaled by 8 */
 
 	if (dst == NULL)
 		goto reset;
@@ -478,40 +478,18 @@ void tcp_init_metrics(struct sock *sk)
 		tp->reordering = val;
 	}
 
-	val = tcp_metric_get(tm, TCP_METRIC_RTT);
-	if (val == 0 || tp->srtt == 0) {
-		rcu_read_unlock();
-		goto reset;
-	}
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
-	val = msecs_to_jiffies(val);
-	if (val > tp->srtt) {
-		tp->srtt = val;
-		tp->rtt_seq = tp->snd_nxt;
-	}
-	val = tcp_metric_get_jiffies(tm, TCP_METRIC_RTTVAR);
-	if (val > tp->mdev) {
-		tp->mdev = val;
-		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
-	}
+	crtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
 	rcu_read_unlock();
-
-	tcp_set_rto(sk);
 reset:
-	if (tp->srtt == 0) {
+	if (crtt > tp->srtt) {
+		/* Initial RTT (tp->srtt) from SYN usually don't measure
+		 * serialization delay on low BW links well so RTO may be
+		 * under-estimated. Stay conservative and seed RTO with
+		 * the RTTs from past data exchanges, using the same seeding
+		 * formula in tcp_rtt_estimator().
+		 */
+		inet_csk(sk)->icsk_rto = crtt + max(crtt >> 2, tcp_rto_min(sk));
+	} else if (tp->srtt == 0) {
 		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
 		 * 3WHS. This is most likely due to retransmission,
 		 * including spurious one. Reset the RTO back to 3secs
