From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 2/3] tcp: do not slow start when cwnd equals ssthresh
Date: Thu,  9 Jul 2015 13:16:30 -0700
Message-ID: <1436472991-16056-3-git-send-email-ycheng@google.com>
References: <1436472991-16056-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Van Jacobson <vanj@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34918 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbbGIUR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 16:17:29 -0400
Received: by iecuq6 with SMTP id uq6so184079301iec.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 13:17:28 -0700 (PDT)
In-Reply-To: <1436472991-16056-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original design slow start is only used to raise cwnd
when cwnd is stricly below ssthresh. It makes little sense
to slow start when cwnd == ssthresh: especially
when hystart has set ssthresh in the initial ramp, or after
recovery when cwnd resets to ssthresh. Not doing so will
also help reduce the buffer bloat slightly.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
---
 include/net/tcp.h    | 2 +-
 net/ipv4/tcp_cdg.c   | 2 +-
 net/ipv4/tcp_cong.c  | 4 +---
 net/ipv4/tcp_hybla.c | 2 +-
 4 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index dba22fc..364426a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -991,7 +991,7 @@ static inline unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 
 static inline bool tcp_in_slow_start(const struct tcp_sock *tp)
 {
-	return tp->snd_cwnd <= tp->snd_ssthresh;
+	return tp->snd_cwnd < tp->snd_ssthresh;
 }
 
 static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 8c6fd3d..167b6a3 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -264,7 +264,7 @@ static void tcp_cdg_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	u32 prior_snd_cwnd;
 	u32 incr;
 
-	if (tp->snd_cwnd < tp->snd_ssthresh && hystart_detect)
+	if (tcp_in_slow_start(tp) && hystart_detect)
 		tcp_cdg_hystart_update(sk);
 
 	if (after(ack, ca->rtt_seq) && ca->rtt.v64) {
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 654729a..a2ed23c 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -365,10 +365,8 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
  */
 u32 tcp_slow_start(struct tcp_sock *tp, u32 acked)
 {
-	u32 cwnd = tp->snd_cwnd + acked;
+	u32 cwnd = min(tp->snd_cwnd + acked, tp->snd_ssthresh);
 
-	if (cwnd > tp->snd_ssthresh)
-		cwnd = tp->snd_ssthresh + 1;
 	acked -= cwnd - tp->snd_cwnd;
 	tp->snd_cwnd = min(cwnd, tp->snd_cwnd_clamp);
 
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index f963b27..083831e 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -112,7 +112,7 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 
 	rho_fractions = ca->rho_3ls - (ca->rho << 3);
 
-	if (tp->snd_cwnd < tp->snd_ssthresh) {
+	if (tcp_in_slow_start(tp)) {
 		/*
 		 * slow start
 		 *      INC = 2^RHO - 1
-- 
2.4.3.573.g4eafbef
