From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/15] tcp_bbr: use tcp_jiffies32 instead of tcp_time_stamp
Date: Tue, 16 May 2017 14:00:05 -0700
Message-ID: <20170516210014.31176-7-edumazet@google.com>
References: <20170516210014.31176-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34069 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752635AbdEPV2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:22 -0400
Received: by mail-pg0-f48.google.com with SMTP id u28so82320666pgn.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:17 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tcp_jiffies32 instead of tcp_time_stamp, since
tcp_time_stamp will soon be only used for TCP TS option.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_bbr.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 92b045c72163def1c1d6aa0f2002760186aa5dc3..40dc4fc5f6acba91634290e1cacde69a3584248f 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -730,12 +730,12 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
 	bool filter_expired;
 
 	/* Track min RTT seen in the min_rtt_win_sec filter window: */
-	filter_expired = after(tcp_time_stamp,
+	filter_expired = after(tcp_jiffies32,
 			       bbr->min_rtt_stamp + bbr_min_rtt_win_sec * HZ);
 	if (rs->rtt_us >= 0 &&
 	    (rs->rtt_us <= bbr->min_rtt_us || filter_expired)) {
 		bbr->min_rtt_us = rs->rtt_us;
-		bbr->min_rtt_stamp = tcp_time_stamp;
+		bbr->min_rtt_stamp = tcp_jiffies32;
 	}
 
 	if (bbr_probe_rtt_mode_ms > 0 && filter_expired &&
@@ -754,7 +754,7 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
 		/* Maintain min packets in flight for max(200 ms, 1 round). */
 		if (!bbr->probe_rtt_done_stamp &&
 		    tcp_packets_in_flight(tp) <= bbr_cwnd_min_target) {
-			bbr->probe_rtt_done_stamp = tcp_time_stamp +
+			bbr->probe_rtt_done_stamp = tcp_jiffies32 +
 				msecs_to_jiffies(bbr_probe_rtt_mode_ms);
 			bbr->probe_rtt_round_done = 0;
 			bbr->next_rtt_delivered = tp->delivered;
@@ -762,8 +762,8 @@ static void bbr_update_min_rtt(struct sock *sk, const struct rate_sample *rs)
 			if (bbr->round_start)
 				bbr->probe_rtt_round_done = 1;
 			if (bbr->probe_rtt_round_done &&
-			    after(tcp_time_stamp, bbr->probe_rtt_done_stamp)) {
-				bbr->min_rtt_stamp = tcp_time_stamp;
+			    after(tcp_jiffies32, bbr->probe_rtt_done_stamp)) {
+				bbr->min_rtt_stamp = tcp_jiffies32;
 				bbr->restore_cwnd = 1;  /* snap to prior_cwnd */
 				bbr_reset_mode(sk);
 			}
@@ -810,7 +810,7 @@ static void bbr_init(struct sock *sk)
 	bbr->probe_rtt_done_stamp = 0;
 	bbr->probe_rtt_round_done = 0;
 	bbr->min_rtt_us = tcp_min_rtt(tp);
-	bbr->min_rtt_stamp = tcp_time_stamp;
+	bbr->min_rtt_stamp = tcp_jiffies32;
 
 	minmax_reset(&bbr->bw, bbr->rtt_cnt, 0);  /* init max bw to 0 */
 
-- 
2.13.0.303.g4ebf302169-goog
