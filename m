From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: use TS opt on RTTs for congestion control
Date: Wed, 31 May 2017 11:30:53 -0700
Message-ID: <20170531183053.16602-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33043 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdEaSbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:31:14 -0400
Received: by mail-pf0-f172.google.com with SMTP id e193so14616350pfh.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:31:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when a data packet is retransmitted, we do not compute an
RTT sample for congestion control due to Kern's check. Therefore the
congestion control that uses RTT signals may not receive any update
during loss recovery which could last many round trips. For example,
BBR and Vegas may not be able to update its min RTT estimation if the
network path has shortened until it recovers from losses. This patch
mitigates that by using TCP timestamp options for RTT measurement
for congestion control. Note that we already use timestamps for
RTT estimation.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9f4380662196..4ea8ec5c7bb4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2921,9 +2921,9 @@ static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
 			   rtt_us ? : jiffies_to_usecs(1));
 }
 
-static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
-				      long seq_rtt_us, long sack_rtt_us,
-				      long ca_rtt_us)
+static bool tcp_ack_update_rtt(struct sock *sk, const int flag,
+			       long seq_rtt_us, long sack_rtt_us,
+			       long ca_rtt_us, struct rate_sample *rs)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2948,6 +2948,7 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 
 		seq_rtt_us = ca_rtt_us = delta_us;
 	}
+	rs->rtt_us = ca_rtt_us; /* RTT of last (S)ACKed packet (or -1) */
 	if (seq_rtt_us < 0)
 		return false;
 
@@ -2967,12 +2968,13 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
 void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
 {
+	struct rate_sample rs;
 	long rtt_us = -1L;
 
 	if (req && !req->num_retrans && tcp_rsk(req)->snt_synack)
 		rtt_us = tcp_stamp_us_delta(tcp_clock_us(), tcp_rsk(req)->snt_synack);
 
-	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us);
+	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us, &rs);
 }
 
 
@@ -3177,9 +3179,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		sack_rtt_us = tcp_stamp_us_delta(tp->tcp_mstamp, sack->first_sackt);
 		ca_rtt_us = tcp_stamp_us_delta(tp->tcp_mstamp, sack->last_sackt);
 	}
-	sack->rate->rtt_us = ca_rtt_us; /* RTT of last (S)ACKed packet, or -1 */
 	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us,
-					ca_rtt_us);
+					ca_rtt_us, sack->rate);
 
 	if (flag & FLAG_ACKED) {
 		tcp_rearm_rto(sk);
@@ -3215,7 +3216,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 	if (icsk->icsk_ca_ops->pkts_acked) {
 		struct ack_sample sample = { .pkts_acked = pkts_acked,
-					     .rtt_us = ca_rtt_us,
+					     .rtt_us = sack->rate->rtt_us,
 					     .in_flight = last_in_flight };
 
 		icsk->icsk_ca_ops->pkts_acked(sk, &sample);
-- 
2.13.0.219.gdb65acc882-goog
