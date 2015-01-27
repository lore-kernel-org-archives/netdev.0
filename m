From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 4/5] tcp: fix stretch ACK bugs in CUBIC
Date: Tue, 27 Jan 2015 15:34:42 -0500
Message-ID: <1422390883-15603-5-git-send-email-ncardwell@google.com>
References: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:37564 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759708AbbA0UfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:35:06 -0500
Received: by mail-yk0-f173.google.com with SMTP id 142so7305111ykq.4
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:35:05 -0800 (PST)
In-Reply-To: <1422390883-15603-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change CUBIC to properly handle stretch ACKs in additive increase mode
by passing in the count of ACKed packets to tcp_cong_avoid_ai().

In addition, because we are now precisely accounting for stretch ACKs,
including delayed ACKs, we can now remove the delayed ACK tracking and
estimation code that tracked recent delayed ACK behavior in
ca->delayed_ack.

Reported-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_cubic.c | 30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index df4bc4d..e036958 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -93,9 +93,7 @@ struct bictcp {
 	u32	epoch_start;	/* beginning of an epoch */
 	u32	ack_cnt;	/* number of acks */
 	u32	tcp_cwnd;	/* estimated tcp cwnd */
-#define ACK_RATIO_SHIFT	4
-#define ACK_RATIO_LIMIT (32u << ACK_RATIO_SHIFT)
-	u16	delayed_ack;	/* estimate the ratio of Packets/ACKs << 4 */
+	u16	unused;
 	u8	sample_cnt;	/* number of samples to decide curr_rtt */
 	u8	found;		/* the exit point is found? */
 	u32	round_start;	/* beginning of each round */
@@ -114,7 +112,6 @@ static inline void bictcp_reset(struct bictcp *ca)
 	ca->bic_K = 0;
 	ca->delay_min = 0;
 	ca->epoch_start = 0;
-	ca->delayed_ack = 2 << ACK_RATIO_SHIFT;
 	ca->ack_cnt = 0;
 	ca->tcp_cwnd = 0;
 	ca->found = 0;
@@ -205,12 +202,12 @@ static u32 cubic_root(u64 a)
 /*
  * Compute congestion window to use.
  */
-static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
+static inline void bictcp_update(struct bictcp *ca, u32 cwnd, u32 acked)
 {
 	u32 delta, bic_target, max_cnt;
 	u64 offs, t;
 
-	ca->ack_cnt++;	/* count the number of ACKs */
+	ca->ack_cnt += acked;	/* count the number of ACKed packets */
 
 	if (ca->last_cwnd == cwnd &&
 	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
@@ -221,7 +218,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 
 	if (ca->epoch_start == 0) {
 		ca->epoch_start = tcp_time_stamp;	/* record beginning */
-		ca->ack_cnt = 1;			/* start counting */
+		ca->ack_cnt = acked;			/* start counting */
 		ca->tcp_cwnd = cwnd;			/* syn with cubic */
 
 		if (ca->last_max_cwnd <= cwnd) {
@@ -301,7 +298,6 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 		}
 	}
 
-	ca->cnt = (ca->cnt << ACK_RATIO_SHIFT) / ca->delayed_ack;
 	if (ca->cnt == 0)			/* cannot be zero */
 		ca->cnt = 1;
 }
@@ -317,11 +313,12 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (tp->snd_cwnd <= tp->snd_ssthresh) {
 		if (hystart && after(ack, ca->end_seq))
 			bictcp_hystart_reset(sk);
-		tcp_slow_start(tp, acked);
-	} else {
-		bictcp_update(ca, tp->snd_cwnd);
-		tcp_cong_avoid_ai(tp, ca->cnt, 1);
+		acked = tcp_slow_start(tp, acked);
+		if (!acked)
+			return;
 	}
+	bictcp_update(ca, tp->snd_cwnd, acked);
+	tcp_cong_avoid_ai(tp, ca->cnt, acked);
 }
 
 static u32 bictcp_recalc_ssthresh(struct sock *sk)
@@ -416,15 +413,6 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 	struct bictcp *ca = inet_csk_ca(sk);
 	u32 delay;
 
-	if (icsk->icsk_ca_state == TCP_CA_Open) {
-		u32 ratio = ca->delayed_ack;
-
-		ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
-		ratio += cnt;
-
-		ca->delayed_ack = clamp(ratio, 1U, ACK_RATIO_LIMIT);
-	}
-
 	/* Some calls are for duplicates without timetamps */
 	if (rtt_us < 0)
 		return;
-- 
2.2.0.rc0.207.ga3a616c
