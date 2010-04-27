From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH v4] TCP: avoid to send keepalive probes if receiving data
Date: Tue, 27 Apr 2010 01:33:27 -0300
Message-ID: <1272342807-13379-1-git-send-email-fleitner@redhat.com>
References: <20100426.112422.246526700.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	Ilpo <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab0D0EeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 00:34:17 -0400
In-Reply-To: <20100426.112422.246526700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1122 says the following:
...
  Keep-alive packets MUST only be sent when no data or
  acknowledgement packets have been received for the
  connection within an interval.
...

The acknowledgement packet is reseting the keepalive
timer but the data packet isn't. This patch fixes it by
checking the timestamp of the last received data packet
too when the keepalive timer expires.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 include/net/tcp.h    |    8 ++++++++
 net/ipv4/tcp.c       |    2 +-
 net/ipv4/tcp_timer.c |    4 ++--
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 75be5a2..305810e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1032,6 +1032,14 @@ static inline int keepalive_probes(const struct tcp_sock *tp)
 	return tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
 }
 
+static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
+{
+	const struct inet_connection_sock *icsk = &tp->inet_conn;
+
+	return min_t(u32, tcp_time_stamp - icsk->icsk_ack.lrcvtime,
+			  tcp_time_stamp - tp->rcv_tstamp);
+}
+
 static inline int tcp_fin_time(const struct sock *sk)
 {
 	int fin_timeout = tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..48a6f33 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2298,7 +2298,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			if (sock_flag(sk, SOCK_KEEPOPEN) &&
 			    !((1 << sk->sk_state) &
 			      (TCPF_CLOSE | TCPF_LISTEN))) {
-				__u32 elapsed = tcp_time_stamp - tp->rcv_tstamp;
+				u32 elapsed = keepalive_time_elapsed(tp);
 				if (tp->keepalive_time > elapsed)
 					elapsed = tp->keepalive_time - elapsed;
 				else
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8a0ab29..a9155f9 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -517,7 +517,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	struct sock *sk = (struct sock *) data;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	__u32 elapsed;
+	u32 elapsed;
 
 	/* Only process if socket is not in use. */
 	bh_lock_sock(sk);
@@ -554,7 +554,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;
 
-	elapsed = tcp_time_stamp - tp->rcv_tstamp;
+	elapsed = keepalive_time_elapsed(tp);
 
 	if (elapsed >= keepalive_time_when(tp)) {
 		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
-- 
1.5.5.6

