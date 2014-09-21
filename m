From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 17:29:17 -0700
Message-ID: <1411259357.26859.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
	 <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411244392.10610.4.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48045 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbaIUA3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 20:29:19 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so2333677pad.39
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 17:29:19 -0700 (PDT)
In-Reply-To: <1411244392.10610.4.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

icsk_rto is a 32bit field, and icsk_backoff can reach 15 by default,
or more if some sysctl (eg tcp_retries2) are changed.

Better use 64bit to perform icsk_rto << icsk_backoff operations

As Joe Perches suggested, add a helper for this.

From: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |    9 +++++++++
 net/ipv4/tcp_input.c               |    5 +++--
 net/ipv4/tcp_output.c              |   13 ++++++-------
 net/ipv4/tcp_timer.c               |    4 ++--
 4 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 5fbe6568c3cf..7551b402d6fe 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -242,6 +242,15 @@ static inline void inet_csk_reset_xmit_timer(struct sock *sk, const int what,
 #endif
 }
 
+static inline unsigned long
+inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
+		     unsigned long max_when)
+{
+        u64 when = (u64)icsk->icsk_rto << icsk->icsk_backoff;
+
+        return (unsigned long)min_t(u64, when, max_when);
+}
+
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
 struct request_sock *inet_csk_search_req(const struct sock *sk,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 02fb66d4a018..13f3da4762e3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3208,9 +3208,10 @@ static void tcp_ack_probe(struct sock *sk)
 		 * This function is not for random using!
 		 */
 	} else {
+		unsigned long when = inet_csk_rto_backoff(icsk, TCP_RTO_MAX);
+
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+					  when, TCP_RTO_MAX);
 	}
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f1280dcad57..8c61a7c0c889 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3279,6 +3279,7 @@ void tcp_send_probe0(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned long probe_max;
 	int err;
 
 	err = tcp_write_wakeup(sk);
@@ -3294,9 +3295,7 @@ void tcp_send_probe0(struct sock *sk)
 		if (icsk->icsk_backoff < sysctl_tcp_retries2)
 			icsk->icsk_backoff++;
 		icsk->icsk_probes_out++;
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+		probe_max = TCP_RTO_MAX;
 	} else {
 		/* If packet was not sent due to local congestion,
 		 * do not backoff and do not remember icsk_probes_out.
@@ -3306,11 +3305,11 @@ void tcp_send_probe0(struct sock *sk)
 		 */
 		if (!icsk->icsk_probes_out)
 			icsk->icsk_probes_out = 1;
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff,
-					      TCP_RESOURCE_PROBE_INTERVAL),
-					  TCP_RTO_MAX);
+		probe_max = TCP_RESOURCE_PROBE_INTERVAL;
 	}
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
+				  inet_csk_rto_backoff(icsk, probe_max),
+				  TCP_RTO_MAX);
 }
 
 int tcp_rtx_synack(struct sock *sk, struct request_sock *req)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a339e7ba05a4..b24360f6e293 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -180,7 +180,7 @@ static int tcp_write_timeout(struct sock *sk)
 
 		retry_until = sysctl_tcp_retries2;
 		if (sock_flag(sk, SOCK_DEAD)) {
-			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
+			const int alive = icsk->icsk_rto < TCP_RTO_MAX;
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
@@ -294,7 +294,7 @@ static void tcp_probe_timer(struct sock *sk)
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
+		const int alive = inet_csk_rto_backoff(icsk, TCP_RTO_MAX) < TCP_RTO_MAX;
 
 		max_probes = tcp_orphan_retries(sk, alive);
 
