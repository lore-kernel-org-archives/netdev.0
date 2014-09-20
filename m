From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 10:19:10 -0700
Message-ID: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:59939 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbaITRTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 13:19:12 -0400
Received: by mail-pa0-f47.google.com with SMTP id et14so1998045pad.20
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 10:19:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

icsk_rto is an 32bit field, and icsk_backoff can reach 15 by default,
or more if some sysctl (eg tcp_retries2) are changed.

Better use 64bit to perform icsk_rto << icsk_backoff operations

From: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c  |    7 +++++--
 net/ipv4/tcp_output.c |   13 ++++++-------
 net/ipv4/tcp_timer.c  |    5 +++--
 3 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 02fb66d4a018..1ea3847c62fc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3208,9 +3208,12 @@ static void tcp_ack_probe(struct sock *sk)
 		 * This function is not for random using!
 		 */
 	} else {
+		unsigned long when;
+
+		when = min((u64)icsk->icsk_rto << icsk->icsk_backoff,
+			   (u64)TCP_RTO_MAX);
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+					  when, TCP_RTO_MAX);
 	}
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f1280dcad57..2231b400f3ce 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3279,6 +3279,7 @@ void tcp_send_probe0(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned long when;
 	int err;
 
 	err = tcp_write_wakeup(sk);
@@ -3294,9 +3295,8 @@ void tcp_send_probe0(struct sock *sk)
 		if (icsk->icsk_backoff < sysctl_tcp_retries2)
 			icsk->icsk_backoff++;
 		icsk->icsk_probes_out++;
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+		when = min((u64)icsk->icsk_rto << icsk->icsk_backoff,
+			   (u64)TCP_RTO_MAX);
 	} else {
 		/* If packet was not sent due to local congestion,
 		 * do not backoff and do not remember icsk_probes_out.
@@ -3306,11 +3306,10 @@ void tcp_send_probe0(struct sock *sk)
 		 */
 		if (!icsk->icsk_probes_out)
 			icsk->icsk_probes_out = 1;
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff,
-					      TCP_RESOURCE_PROBE_INTERVAL),
-					  TCP_RTO_MAX);
+		when = min((u64)icsk->icsk_rto << icsk->icsk_backoff,
+			   (u64)TCP_RESOURCE_PROBE_INTERVAL);
 	}
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0, when, TCP_RTO_MAX);
 }
 
 int tcp_rtx_synack(struct sock *sk, struct request_sock *req)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a339e7ba05a4..05e1d0723233 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -180,7 +180,7 @@ static int tcp_write_timeout(struct sock *sk)
 
 		retry_until = sysctl_tcp_retries2;
 		if (sock_flag(sk, SOCK_DEAD)) {
-			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
+			const int alive = icsk->icsk_rto < TCP_RTO_MAX;
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
@@ -294,7 +294,8 @@ static void tcp_probe_timer(struct sock *sk)
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
+		u64 exp_rto = (u64)icsk->icsk_rto << icsk->icsk_backoff;
+		const int alive = exp_rto < TCP_RTO_MAX;
 
 		max_probes = tcp_orphan_retries(sk, alive);
 
