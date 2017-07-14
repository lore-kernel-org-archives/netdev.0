From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net 2/5] tcp_bbr: introduce bbr_bw_to_pacing_rate() helper
Date: Fri, 14 Jul 2017 17:49:22 -0400
Message-ID: <20170714214925.30720-2-ncardwell@google.com>
References: <20170714214925.30720-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:32920 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdGNVtn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 17:49:43 -0400
Received: by mail-qt0-f170.google.com with SMTP id r30so72288748qtc.0
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 14:49:42 -0700 (PDT)
In-Reply-To: <20170714214925.30720-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a helper to convert a BBR bandwidth and gain factor to a
pacing rate in bytes per second. This is a pure refactor, but is
needed for two following fixes.

Fixes: 0f8782ea1497 ("tcp_bbr: add BBR congestion control")
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_bbr.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 743e97511dc8..29e23b851b97 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -211,6 +211,16 @@ static u64 bbr_rate_bytes_per_sec(struct sock *sk, u64 rate, int gain)
 	return rate >> BW_SCALE;
 }
 
+/* Convert a BBR bw and gain factor to a pacing rate in bytes per second. */
+static u32 bbr_bw_to_pacing_rate(struct sock *sk, u32 bw, int gain)
+{
+	u64 rate = bw;
+
+	rate = bbr_rate_bytes_per_sec(sk, rate, gain);
+	rate = min_t(u64, rate, sk->sk_max_pacing_rate);
+	return rate;
+}
+
 /* Pace using current bw estimate and a gain factor. In order to help drive the
  * network toward lower queues while maintaining high utilization and low
  * latency, the average pacing rate aims to be slightly (~1%) lower than the
@@ -220,10 +230,8 @@ static u64 bbr_rate_bytes_per_sec(struct sock *sk, u64 rate, int gain)
  */
 static void bbr_set_pacing_rate(struct sock *sk, u32 bw, int gain)
 {
-	u64 rate = bw;
+	u32 rate = bbr_bw_to_pacing_rate(sk, bw, gain);
 
-	rate = bbr_rate_bytes_per_sec(sk, rate, gain);
-	rate = min_t(u64, rate, sk->sk_max_pacing_rate);
 	if (bbr_full_bw_reached(sk) || rate > sk->sk_pacing_rate)
 		sk->sk_pacing_rate = rate;
 }
-- 
2.13.2.932.g7449e964c-goog
