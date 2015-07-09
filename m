From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/3] tcp: add tcp_in_slow_start helper
Date: Thu,  9 Jul 2015 13:16:29 -0700
Message-ID: <1436472991-16056-2-git-send-email-ycheng@google.com>
References: <1436472991-16056-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34904 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbbGIUR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 16:17:27 -0400
Received: by iecuq6 with SMTP id uq6so184078965iec.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 13:17:26 -0700 (PDT)
In-Reply-To: <1436472991-16056-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper to test the slow start condition in various congestion
control modules and other places. This is to prepare a slight improvement
in policy as to exactly when to slow start.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 include/net/tcp.h        | 7 ++++++-
 net/ipv4/tcp_bic.c       | 2 +-
 net/ipv4/tcp_cong.c      | 2 +-
 net/ipv4/tcp_cubic.c     | 4 ++--
 net/ipv4/tcp_highspeed.c | 2 +-
 net/ipv4/tcp_htcp.c      | 2 +-
 net/ipv4/tcp_illinois.c  | 2 +-
 net/ipv4/tcp_metrics.c   | 2 +-
 net/ipv4/tcp_scalable.c  | 2 +-
 net/ipv4/tcp_vegas.c     | 6 +++---
 net/ipv4/tcp_veno.c      | 2 +-
 11 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 950cfec..dba22fc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -989,6 +989,11 @@ static inline unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 
 #define TCP_INFINITE_SSTHRESH	0x7fffffff
 
+static inline bool tcp_in_slow_start(const struct tcp_sock *tp)
+{
+	return tp->snd_cwnd <= tp->snd_ssthresh;
+}
+
 static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
 {
 	return tp->snd_ssthresh >= TCP_INFINITE_SSTHRESH;
@@ -1065,7 +1070,7 @@ static inline bool tcp_is_cwnd_limited(const struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 
 	/* If in slow start, ensure cwnd grows to twice what was ACKed. */
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		return tp->snd_cwnd < 2 * tp->max_packets_out;
 
 	return tp->is_cwnd_limited;
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index c037644..fd1405d 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -146,7 +146,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 	else {
 		bictcp_update(ca, tp->snd_cwnd);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 84be008..654729a 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -413,7 +413,7 @@ void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		return;
 
 	/* In "safe" area, increase. */
-	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+	if (tcp_in_slow_start(tp)) {
 		acked = tcp_slow_start(tp, acked);
 		if (!acked)
 			return;
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 06d3d66..28011fb 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -320,7 +320,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+	if (tcp_in_slow_start(tp)) {
 		if (hystart && after(ack, ca->end_seq))
 			bictcp_hystart_reset(sk);
 		acked = tcp_slow_start(tp, acked);
@@ -439,7 +439,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 		ca->delay_min = delay;
 
 	/* hystart triggers when cwnd is larger than some threshold */
-	if (hystart && tp->snd_cwnd <= tp->snd_ssthresh &&
+	if (hystart && tcp_in_slow_start(tp) &&
 	    tp->snd_cwnd >= hystart_low_window)
 		hystart_update(sk, delay);
 }
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index 882c08a..db78424 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -116,7 +116,7 @@ static void hstcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 	else {
 		/* Update AIMD parameters.
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 58469ff..82f0d9e 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -236,7 +236,7 @@ static void htcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 	else {
 		/* In dangerous area, increase slowly.
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index f71002e..2ab9bbb 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -268,7 +268,7 @@ static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		return;
 
 	/* In slow start */
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 
 	else {
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index a51d63a..b3d64f6 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -461,7 +461,7 @@ void tcp_update_metrics(struct sock *sk)
 				tcp_metric_set(tm, TCP_METRIC_CWND,
 					       tp->snd_cwnd);
 		}
-	} else if (tp->snd_cwnd > tp->snd_ssthresh &&
+	} else if (!tcp_in_slow_start(tp) &&
 		   icsk->icsk_ca_state == TCP_CA_Open) {
 		/* Cong. avoidance phase, cwnd is reliable. */
 		if (!tcp_metric_locked(tm, TCP_METRIC_SSTHRESH))
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index 333bcb2..bf5ea9e 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -22,7 +22,7 @@ static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
+	if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 	else
 		tcp_cong_avoid_ai(tp, min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT),
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index a6cea1d..13951c4 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -225,7 +225,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 			 */
 			diff = tp->snd_cwnd * (rtt-vegas->baseRTT) / vegas->baseRTT;
 
-			if (diff > gamma && tp->snd_cwnd <= tp->snd_ssthresh) {
+			if (diff > gamma && tcp_in_slow_start(tp)) {
 				/* Going too fast. Time to slow down
 				 * and switch to congestion avoidance.
 				 */
@@ -240,7 +240,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 				tp->snd_cwnd = min(tp->snd_cwnd, (u32)target_cwnd+1);
 				tp->snd_ssthresh = tcp_vegas_ssthresh(tp);
 
-			} else if (tp->snd_cwnd <= tp->snd_ssthresh) {
+			} else if (tcp_in_slow_start(tp)) {
 				/* Slow start.  */
 				tcp_slow_start(tp, acked);
 			} else {
@@ -281,7 +281,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		vegas->minRTT = 0x7fffffff;
 	}
 	/* Use normal slow start */
-	else if (tp->snd_cwnd <= tp->snd_ssthresh)
+	else if (tcp_in_slow_start(tp))
 		tcp_slow_start(tp, acked);
 }
 
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 112151e..0d094b9 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -150,7 +150,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 
 		veno->diff = (tp->snd_cwnd << V_PARAM_SHIFT) - target_cwnd;
 
-		if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		if (tcp_in_slow_start(tp)) {
 			/* Slow start.  */
 			tcp_slow_start(tp, acked);
 		} else {
-- 
2.4.3.573.g4eafbef
