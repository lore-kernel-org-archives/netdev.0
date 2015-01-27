From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 5/5] tcp: fix timing issue in CUBIC slope calculation
Date: Tue, 27 Jan 2015 15:34:43 -0500
Message-ID: <1422390883-15603-6-git-send-email-ncardwell@google.com>
References: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:46941 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbbA0UfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:35:07 -0500
Received: by mail-yk0-f174.google.com with SMTP id 131so7296759ykp.5
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:35:06 -0800 (PST)
In-Reply-To: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug in CUBIC that causes cwnd to increase slightly
too slowly when multiple ACKs arrive in the same jiffy.

If cwnd is supposed to increase at a rate of more than once per jiffy,
then CUBIC was sometimes too slow. Because the bic_target is
calculated for a future point in time, calculated with time in
jiffies, the cwnd can increase over the course of the jiffy while the
bic_target calculated as the proper CUBIC cwnd at time
t=tcp_time_stamp+rtt does not increase, because tcp_time_stamp only
increases on jiffy tick boundaries.

So since the cnt is set to:
	ca->cnt = cwnd / (bic_target - cwnd);
as cwnd increases but bic_target does not increase due to jiffy
granularity, the cnt becomes too large, causing cwnd to increase
too slowly.

For example:
- suppose at the beginning of a jiffy, cwnd=40, bic_target=44
- so CUBIC sets:
   ca->cnt =  cwnd / (bic_target - cwnd) = 40 / (44 - 40) = 40/4 = 10
- suppose we get 10 acks, each for 1 segment, so tcp_cong_avoid_ai()
   increases cwnd to 41
- so CUBIC sets:
   ca->cnt =  cwnd / (bic_target - cwnd) = 41 / (44 - 41) = 41 / 3 = 13

So now CUBIC will wait for 13 packets to be ACKed before increasing
cwnd to 42, insted of 10 as it should.

The fix is to avoid adjusting the slope (determined by ca->cnt)
multiple times within a jiffy, and instead skip to compute the Reno
cwnd, the "TCP friendliness" code path.

Reported-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cubic.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index e036958..4f91141 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -213,6 +213,13 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd, u32 acked)
 	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
 		return;
 
+	/* The CUBIC function can update ca->cnt at most once per jiffy.
+	 * On all cwnd reduction events, ca->epoch_start is set to 0,
+	 * which will force a recalculation of ca->cnt.
+	 */
+	if (ca->epoch_start && tcp_time_stamp == ca->last_time)
+		goto tcp_friendliness;
+
 	ca->last_cwnd = cwnd;
 	ca->last_time = tcp_time_stamp;
 
@@ -280,6 +287,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd, u32 acked)
 	if (ca->last_max_cwnd == 0 && ca->cnt > 20)
 		ca->cnt = 20;	/* increase cwnd 5% per RTT */
 
+tcp_friendliness:
 	/* TCP Friendly */
 	if (tcp_friendliness) {
 		u32 scale = beta_scale;
-- 
2.2.0.rc0.207.ga3a616c
