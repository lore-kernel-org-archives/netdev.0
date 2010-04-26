From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH v3] TCP: avoid to send keepalive probes if receiving data
Date: Sun, 25 Apr 2010 23:40:59 -0300
Message-ID: <1272249659-2292-1-git-send-email-fleitner@redhat.com>
References: <20100425235549.GB2550@sysclose.org>
Cc: David Miller <davem@davemloft.net>,
	Ilpo <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab0DZClg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 22:41:36 -0400
In-Reply-To: <20100425235549.GB2550@sysclose.org>
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
 net/ipv4/tcp.c       |    5 ++++-
 net/ipv4/tcp_timer.c |    8 ++++++++
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..94f605c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2298,7 +2298,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			if (sock_flag(sk, SOCK_KEEPOPEN) &&
 			    !((1 << sk->sk_state) &
 			      (TCPF_CLOSE | TCPF_LISTEN))) {
-				__u32 elapsed = tcp_time_stamp - tp->rcv_tstamp;
+				u32 elapsed = min_t(u32,
+				      tcp_time_stamp - icsk->icsk_ack.lrcvtime,
+				      tcp_time_stamp - tp->rcv_tstamp);
+
 				if (tp->keepalive_time > elapsed)
 					elapsed = tp->keepalive_time - elapsed;
 				else
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8a0ab29..9d1bb6f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -554,6 +554,14 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;
 
+	elapsed = tcp_time_stamp - icsk->icsk_ack.lrcvtime;
+
+	/* receiving data means alive */
+	if (elapsed < keepalive_time_when(tp)) {
+		elapsed = keepalive_time_when(tp) - elapsed;
+		goto resched;
+	}
+
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;
 
 	if (elapsed >= keepalive_time_when(tp)) {
-- 
1.5.5.6

