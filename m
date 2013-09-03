From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: better comments for RTO initiallization
Date: Tue,  3 Sep 2013 14:14:35 -0700
Message-ID: <1378242875-5172-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:34785 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761085Ab3ICVOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 17:14:41 -0400
Received: by mail-qa0-f74.google.com with SMTP id i13so368499qae.5
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 14:14:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1b7fdd2ab585("tcp: do not use cached RTT for RTT estimation")
removes important comments on how RTO is initialized and updated.
Hopefully this patch puts those information back.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_metrics.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 273ed73..4a22f3e 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -481,13 +481,27 @@ void tcp_init_metrics(struct sock *sk)
 	crtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
 	rcu_read_unlock();
 reset:
+	/* The initial RTT measurement from the SYN/SYN-ACK is not ideal
+	 * to seed the RTO for later data packets because SYN packets are
+	 * small. Use the per-dst cached values to seed the RTO but keep
+	 * the RTT estimator variables intact (e.g., srtt, mdev, rttvar).
+	 * Later the RTO will be updated immediately upon obtaining the first
+	 * data RTT sample (tcp_rtt_estimator()). Hence the cached RTT only
+	 * influences the first RTO but not later RTT estimation.
+	 *
+	 * But if RTT is not available from the SYN (due to retransmits or
+	 * syn cookies) or the cache, force a conservative 3secs timeout.
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
 	if (crtt > tp->srtt) {
-		/* Initial RTT (tp->srtt) from SYN usually don't measure
-		 * serialization delay on low BW links well so RTO may be
-		 * under-estimated. Stay conservative and seed RTO with
-		 * the RTTs from past data exchanges, using the same seeding
-		 * formula in tcp_rtt_estimator().
-		 */
 		inet_csk(sk)->icsk_rto = crtt + max(crtt >> 2, tcp_rto_min(sk));
 	} else if (tp->srtt == 0) {
 		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
-- 
1.8.4
