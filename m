From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/15] tcp: bic,cubic: use tcp_jiffies32 instead of tcp_time_stamp
Date: Tue, 16 May 2017 14:00:06 -0700
Message-ID: <20170516210014.31176-8-edumazet@google.com>
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
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35618 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752589AbdEPV2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:15 -0400
Received: by mail-pg0-f46.google.com with SMTP id q125so62893513pgq.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:14 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tcp_jiffies32 instead of tcp_time_stamp, since
tcp_time_stamp will soon be only used for TCP TS option.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_bic.c   |  6 +++---
 net/ipv4/tcp_cubic.c | 12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 36087bca9f489646c2ca5aae3111449a956dd33b..609965f0e29836ed95605a2c7f3170e67c641058 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -84,14 +84,14 @@ static void bictcp_init(struct sock *sk)
 static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 {
 	if (ca->last_cwnd == cwnd &&
-	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
+	    (s32)(tcp_jiffies32 - ca->last_time) <= HZ / 32)
 		return;
 
 	ca->last_cwnd = cwnd;
-	ca->last_time = tcp_time_stamp;
+	ca->last_time = tcp_jiffies32;
 
 	if (ca->epoch_start == 0) /* record the beginning of an epoch */
-		ca->epoch_start = tcp_time_stamp;
+		ca->epoch_start = tcp_jiffies32;
 
 	/* start off normal */
 	if (cwnd <= low_window) {
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 2052ca740916d0872a41125ab61b769b334a314b..57ae5b5ae643efad106f5d6ac224ca54a52f9689 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -231,21 +231,21 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd, u32 acked)
 	ca->ack_cnt += acked;	/* count the number of ACKed packets */
 
 	if (ca->last_cwnd == cwnd &&
-	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
+	    (s32)(tcp_jiffies32 - ca->last_time) <= HZ / 32)
 		return;
 
 	/* The CUBIC function can update ca->cnt at most once per jiffy.
 	 * On all cwnd reduction events, ca->epoch_start is set to 0,
 	 * which will force a recalculation of ca->cnt.
 	 */
-	if (ca->epoch_start && tcp_time_stamp == ca->last_time)
+	if (ca->epoch_start && tcp_jiffies32 == ca->last_time)
 		goto tcp_friendliness;
 
 	ca->last_cwnd = cwnd;
-	ca->last_time = tcp_time_stamp;
+	ca->last_time = tcp_jiffies32;
 
 	if (ca->epoch_start == 0) {
-		ca->epoch_start = tcp_time_stamp;	/* record beginning */
+		ca->epoch_start = tcp_jiffies32;	/* record beginning */
 		ca->ack_cnt = acked;			/* start counting */
 		ca->tcp_cwnd = cwnd;			/* syn with cubic */
 
@@ -276,7 +276,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd, u32 acked)
 	 * if the cwnd < 1 million packets !!!
 	 */
 
-	t = (s32)(tcp_time_stamp - ca->epoch_start);
+	t = (s32)(tcp_jiffies32 - ca->epoch_start);
 	t += msecs_to_jiffies(ca->delay_min >> 3);
 	/* change the unit from HZ to bictcp_HZ */
 	t <<= BICTCP_HZ;
@@ -448,7 +448,7 @@ static void bictcp_acked(struct sock *sk, const struct ack_sample *sample)
 		return;
 
 	/* Discard delay samples right after fast recovery */
-	if (ca->epoch_start && (s32)(tcp_time_stamp - ca->epoch_start) < HZ)
+	if (ca->epoch_start && (s32)(tcp_jiffies32 - ca->epoch_start) < HZ)
 		return;
 
 	delay = (sample->rtt_us << 3) / USEC_PER_MSEC;
-- 
2.13.0.303.g4ebf302169-goog
