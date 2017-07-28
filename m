From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 1/2] tcp: extract the function to compute delivery rate
Date: Fri, 28 Jul 2017 10:28:20 -0700
Message-ID: <20170728172821.102562-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34838 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbdG1R3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:29:44 -0400
Received: by mail-pg0-f44.google.com with SMTP id v190so113685301pgv.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:29:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Refactor the code to extract the function to compute delivery rate.
This function will be used in later commit.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 71ce33decd97..65d210d0394c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -388,6 +388,19 @@ static int retrans_to_secs(u8 retrans, int timeout, int rto_max)
 	return period;
 }
 
+static u64 tcp_compute_delivery_rate(const struct tcp_sock *tp)
+{
+	u32 rate = READ_ONCE(tp->rate_delivered);
+	u32 intv = READ_ONCE(tp->rate_interval_us);
+	u64 rate64 = 0;
+
+	if (rate && intv) {
+		rate64 = (u64)rate * tp->mss_cache * USEC_PER_SEC;
+		do_div(rate64, intv);
+	}
+	return rate64;
+}
+
 /* Address-family independent initialization for a tcp_sock.
  *
  * NOTE: A lot of things set to zero explicitly by call to
@@ -2823,7 +2836,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
 	const struct tcp_sock *tp = tcp_sk(sk); /* iff sk_type == SOCK_STREAM */
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	u32 now, intv;
+	u32 now;
 	u64 rate64;
 	bool slow;
 	u32 rate;
@@ -2922,13 +2935,9 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_data_segs_out = tp->data_segs_out;
 
 	info->tcpi_delivery_rate_app_limited = tp->rate_app_limited ? 1 : 0;
-	rate = READ_ONCE(tp->rate_delivered);
-	intv = READ_ONCE(tp->rate_interval_us);
-	if (rate && intv) {
-		rate64 = (u64)rate * tp->mss_cache * USEC_PER_SEC;
-		do_div(rate64, intv);
+	rate64 = tcp_compute_delivery_rate(tp);
+	if (rate64)
 		info->tcpi_delivery_rate = rate64;
-	}
 	unlock_sock_fast(sk, slow);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
-- 
2.14.0.rc0.400.g1c36432dff-goog
