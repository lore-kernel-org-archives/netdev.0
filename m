From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/15] tcp_lp: cache tcp_time_stamp
Date: Tue, 16 May 2017 14:00:12 -0700
Message-ID: <20170516210014.31176-14-edumazet@google.com>
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
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33017 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752928AbdEPV2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:32 -0400
Received: by mail-pf0-f182.google.com with SMTP id e193so86503645pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:32 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_time_stamp will become slightly more expensive soon,
cache its value.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_lp.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index d6fb6c067af4641f232b94e7c590c212648e8173..ef3122abb3734a63011fba035f7a7aae431da8de 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -264,18 +264,19 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
+	u32 now = tcp_time_stamp;
 	u32 delta;
 
 	if (sample->rtt_us > 0)
 		tcp_lp_rtt_sample(sk, sample->rtt_us);
 
 	/* calc inference */
-	delta = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
+	delta = now - tp->rx_opt.rcv_tsecr;
 	if ((s32)delta > 0)
 		lp->inference = 3 * delta;
 
 	/* test if within inference */
-	if (lp->last_drop && (tcp_time_stamp - lp->last_drop < lp->inference))
+	if (lp->last_drop && (now - lp->last_drop < lp->inference))
 		lp->flag |= LP_WITHIN_INF;
 	else
 		lp->flag &= ~LP_WITHIN_INF;
@@ -312,7 +313,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
 		tp->snd_cwnd = max(tp->snd_cwnd >> 1U, 1U);
 
 	/* record this drop time */
-	lp->last_drop = tcp_time_stamp;
+	lp->last_drop = now;
 }
 
 static struct tcp_congestion_ops tcp_lp __read_mostly = {
-- 
2.13.0.303.g4ebf302169-goog
