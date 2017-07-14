From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 3/5] tcp_bbr: introduce bbr_init_pacing_rate_from_rtt() helper
Date: Fri, 14 Jul 2017 17:49:23 -0400
Message-ID: <20170714214925.30720-3-ncardwell@google.com>
References: <20170714214925.30720-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:36606 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdGNVto (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 17:49:44 -0400
Received: by mail-qt0-f172.google.com with SMTP id i2so72289972qta.3
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 14:49:44 -0700 (PDT)
In-Reply-To: <20170714214925.30720-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a helper to initialize the BBR pacing rate unconditionally,
based on the current cwnd and RTT estimate. This is a pure refactor,
but is needed for two following fixes.

Fixes: 0f8782ea1497 ("tcp_bbr: add BBR congestion control")
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_bbr.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 29e23b851b97..3276140c2506 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -221,6 +221,23 @@ static u32 bbr_bw_to_pacing_rate(struct sock *sk, u32 bw, int gain)
 	return rate;
 }
 
+/* Initialize pacing rate to: high_gain * init_cwnd / RTT. */
+static void bbr_init_pacing_rate_from_rtt(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u64 bw;
+	u32 rtt_us;
+
+	if (tp->srtt_us) {		/* any RTT sample yet? */
+		rtt_us = max(tp->srtt_us >> 3, 1U);
+	} else {			 /* no RTT sample yet */
+		rtt_us = USEC_PER_MSEC;	 /* use nominal default RTT */
+	}
+	bw = (u64)tp->snd_cwnd * BW_UNIT;
+	do_div(bw, rtt_us);
+	sk->sk_pacing_rate = bbr_bw_to_pacing_rate(sk, bw, bbr_high_gain);
+}
+
 /* Pace using current bw estimate and a gain factor. In order to help drive the
  * network toward lower queues while maintaining high utilization and low
  * latency, the average pacing rate aims to be slightly (~1%) lower than the
@@ -805,7 +822,6 @@ static void bbr_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bbr *bbr = inet_csk_ca(sk);
-	u64 bw;
 
 	bbr->prior_cwnd = 0;
 	bbr->tso_segs_goal = 0;	 /* default segs per skb until first ACK */
@@ -821,11 +837,8 @@ static void bbr_init(struct sock *sk)
 
 	minmax_reset(&bbr->bw, bbr->rtt_cnt, 0);  /* init max bw to 0 */
 
-	/* Initialize pacing rate to: high_gain * init_cwnd / RTT. */
-	bw = (u64)tp->snd_cwnd * BW_UNIT;
-	do_div(bw, (tp->srtt_us >> 3) ? : USEC_PER_MSEC);
 	sk->sk_pacing_rate = 0;		/* force an update of sk_pacing_rate */
-	bbr_set_pacing_rate(sk, bw, bbr_high_gain);
+	bbr_init_pacing_rate_from_rtt(sk);
 
 	bbr->restore_cwnd = 0;
 	bbr->round_start = 0;
-- 
2.13.2.932.g7449e964c-goog
