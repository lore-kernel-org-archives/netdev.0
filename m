From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp: adjust window probe timers to safer values
Date: Wed,  6 May 2015 05:52:13 -0700
Message-ID: <1430916734-5051-2-git-send-email-edumazet@google.com>
References: <1430916734-5051-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:32806 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbEFMw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 08:52:27 -0400
Received: by obcwm4 with SMTP id wm4so448356obc.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 05:52:26 -0700 (PDT)
In-Reply-To: <1430916734-5051-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the advent of small rto timers in datacenter TCP,
(ip route ... rto_min x), the following can happen :

1) Qdisc is full, transmit fails.

   TCP sets a timer based on icsk_rto to retry the transmit, without
   exponential backoff.
   With low icsk_rto, and lot of sockets, all cpus are servicing timer
   interrupts like crazy.
   Intent of the code was to retry with a timer between 200 (TCP_RTO_MIN)
   and 500ms (TCP_RESOURCE_PROBE_INTERVAL)

2) Receivers can send zero windows if they don't drain their receive queue.

   TCP sends zero window probes, based on icsk_rto current value, with
   exponential backoff.
   With /proc/sys/net/ipv4/tcp_retries2 being 15 (or even smaller in
   some cases), sender can abort in less than onr or two minutes !
   If receiver stops the sender, it obviously doesn't care of very tight
   rto. Probability of dropping the ACK reopening the window is not
   worth the risk.

Lets change the base timer to be at least 200ms (TCP_RTO_MIN) for these
events (but not normal RTO based retransmits)

A followup patch adds a new SNMP counter, as it would have helped a lot
diagnosing this issue.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     | 27 ++++++++++++++++++++++-----
 net/ipv4/tcp_input.c  |  2 +-
 net/ipv4/tcp_output.c |  2 +-
 3 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6d204f3f9df8..7a2248a35b13 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1043,14 +1043,31 @@ static inline bool tcp_is_cwnd_limited(const struct sock *sk)
 	return tp->is_cwnd_limited;
 }
 
-static inline void tcp_check_probe_timer(struct sock *sk)
+/* Something is really bad, we could not queue an additional packet,
+ * because qdisc is full or receiver sent a 0 window.
+ * We do not want to add fuel to the fire, or abort too early,
+ * so make sure the timer we arm now is at least 200ms in the future,
+ * regardless of current icsk_rto value (as it could be ~2ms)
+ */
+static inline unsigned long tcp_probe0_base(const struct sock *sk)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
+	return max_t(unsigned long, inet_csk(sk)->icsk_rto, TCP_RTO_MIN);
+}
 
-	if (!tp->packets_out && !icsk->icsk_pending)
+/* Variant of inet_csk_rto_backoff() used for zero window probes */
+static inline unsigned long tcp_probe0_when(const struct sock *sk,
+					    unsigned long max_when)
+{
+	u64 when = (u64)tcp_probe0_base(sk) << inet_csk(sk)->icsk_backoff;
+
+	return (unsigned long)min_t(u64, when, max_when);
+}
+
+static inline void tcp_check_probe_timer(struct sock *sk)
+{
+	if (!tcp_sk(sk)->packets_out && !inet_csk(sk)->icsk_pending)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  icsk->icsk_rto, TCP_RTO_MAX);
+					  tcp_probe0_base(sk), TCP_RTO_MAX);
 }
 
 static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index df2ca615cd0c..cf8b20ff6658 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3233,7 +3233,7 @@ static void tcp_ack_probe(struct sock *sk)
 		 * This function is not for random using!
 		 */
 	} else {
-		unsigned long when = inet_csk_rto_backoff(icsk, TCP_RTO_MAX);
+		unsigned long when = tcp_probe0_when(sk, TCP_RTO_MAX);
 
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
 					  when, TCP_RTO_MAX);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a369e8a70b2c..b76c719e1979 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3490,7 +3490,7 @@ void tcp_send_probe0(struct sock *sk)
 		probe_max = TCP_RESOURCE_PROBE_INTERVAL;
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-				  inet_csk_rto_backoff(icsk, probe_max),
+				  tcp_probe0_when(sk, probe_max),
 				  TCP_RTO_MAX);
 }
 
-- 
2.2.0.rc0.207.ga3a616c
