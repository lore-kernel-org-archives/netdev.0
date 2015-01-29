From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next v2 1/5] tcp: stretch ACK fixes prep
Date: Wed, 28 Jan 2015 20:01:35 -0500
Message-ID: <1422493299-22114-2-git-send-email-ncardwell@google.com>
References: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:50535 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbbA2BJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:09:11 -0500
Received: by mail-yk0-f176.google.com with SMTP id q200so10952673ykb.7
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:09:10 -0800 (PST)
In-Reply-To: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LRO, GRO, delayed ACKs, and middleboxes can cause "stretch ACKs" that
cover more than the RFC-specified maximum of 2 packets. These stretch
ACKs can cause serious performance shortfalls in common congestion
control algorithms that were designed and tuned years ago with
receiver hosts that were not using LRO or GRO, and were instead
politely ACKing every other packet.

This patch series fixes Reno and CUBIC to handle stretch ACKs.

This patch prepares for the upcoming stretch ACK bug fix patches. It
adds an "acked" parameter to tcp_cong_avoid_ai() to allow for future
fixes to tcp_cong_avoid_ai() to correctly handle stretch ACKs, and
changes all congestion control algorithms to pass in 1 for the ACKed
count. It also changes tcp_slow_start() to return the number of packet
ACK "credits" that were not processed in slow start mode, and can be
processed by the congestion control module in additive increase mode.

In future patches we will fix tcp_cong_avoid_ai() to handle stretch
ACKs, and fix Reno and CUBIC handling of stretch ACKs in slow start
and additive increase mode.

Reported-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h       |  4 ++--
 net/ipv4/tcp_bic.c      |  2 +-
 net/ipv4/tcp_cong.c     | 11 +++++++----
 net/ipv4/tcp_cubic.c    |  2 +-
 net/ipv4/tcp_scalable.c |  3 ++-
 net/ipv4/tcp_veno.c     |  2 +-
 net/ipv4/tcp_yeah.c     |  2 +-
 7 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b8fdc6b..7c280a4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -843,8 +843,8 @@ void tcp_get_available_congestion_control(char *buf, size_t len);
 void tcp_get_allowed_congestion_control(char *buf, size_t len);
 int tcp_set_allowed_congestion_control(char *allowed);
 int tcp_set_congestion_control(struct sock *sk, const char *name);
-void tcp_slow_start(struct tcp_sock *tp, u32 acked);
-void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
+u32 tcp_slow_start(struct tcp_sock *tp, u32 acked);
+void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
 
 u32 tcp_reno_ssthresh(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index bb395d4..c037644 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -150,7 +150,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		tcp_slow_start(tp, acked);
 	else {
 		bictcp_update(ca, tp->snd_cwnd);
-		tcp_cong_avoid_ai(tp, ca->cnt);
+		tcp_cong_avoid_ai(tp, ca->cnt, 1);
 	}
 }
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 63c29db..60bc170 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -360,25 +360,28 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
  * ABC caps N to 2. Slow start exits when cwnd grows over ssthresh and
  * returns the leftover acks to adjust cwnd in congestion avoidance mode.
  */
-void tcp_slow_start(struct tcp_sock *tp, u32 acked)
+u32 tcp_slow_start(struct tcp_sock *tp, u32 acked)
 {
 	u32 cwnd = tp->snd_cwnd + acked;
 
 	if (cwnd > tp->snd_ssthresh)
 		cwnd = tp->snd_ssthresh + 1;
+	acked -= cwnd - tp->snd_cwnd;
 	tp->snd_cwnd = min(cwnd, tp->snd_cwnd_clamp);
+
+	return acked;
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
 /* In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd (or alternative w) */
-void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w)
+void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked)
 {
 	if (tp->snd_cwnd_cnt >= w) {
 		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 			tp->snd_cwnd++;
 		tp->snd_cwnd_cnt = 0;
 	} else {
-		tp->snd_cwnd_cnt++;
+		tp->snd_cwnd_cnt += acked;
 	}
 }
 EXPORT_SYMBOL_GPL(tcp_cong_avoid_ai);
@@ -402,7 +405,7 @@ void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		tcp_slow_start(tp, acked);
 	/* In dangerous area, increase slowly. */
 	else
-		tcp_cong_avoid_ai(tp, tp->snd_cwnd);
+		tcp_cong_avoid_ai(tp, tp->snd_cwnd, 1);
 }
 EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
 
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 6b60024..df4bc4d 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -320,7 +320,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 		tcp_slow_start(tp, acked);
 	} else {
 		bictcp_update(ca, tp->snd_cwnd);
-		tcp_cong_avoid_ai(tp, ca->cnt);
+		tcp_cong_avoid_ai(tp, ca->cnt, 1);
 	}
 }
 
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index 6824afb..333bcb2 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -25,7 +25,8 @@ static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp, acked);
 	else
-		tcp_cong_avoid_ai(tp, min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT));
+		tcp_cong_avoid_ai(tp, min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT),
+				  1);
 }
 
 static u32 tcp_scalable_ssthresh(struct sock *sk)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index a4d2d2d..112151e 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -159,7 +159,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 				/* In the "non-congestive state", increase cwnd
 				 *  every rtt.
 				 */
-				tcp_cong_avoid_ai(tp, tp->snd_cwnd);
+				tcp_cong_avoid_ai(tp, tp->snd_cwnd, 1);
 			} else {
 				/* In the "congestive state", increase cwnd
 				 * every other rtt.
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index cd72732..17d3566 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -92,7 +92,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 
 	} else {
 		/* Reno */
-		tcp_cong_avoid_ai(tp, tp->snd_cwnd);
+		tcp_cong_avoid_ai(tp, tp->snd_cwnd, 1);
 	}
 
 	/* The key players are v_vegas.beg_snd_una and v_beg_snd_nxt.
-- 
2.2.0.rc0.207.ga3a616c
