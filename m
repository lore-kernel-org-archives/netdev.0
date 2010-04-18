From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH v2] TCP: avoid to send keepalive probes if it is receiving data
Date: Sun, 18 Apr 2010 11:55:19 -0300
Message-ID: <1271602519-6805-1-git-send-email-fleitner@redhat.com>
References: <1271581560.16881.4769.camel@edumazet-laptop>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831Ab0DRO4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:56:04 -0400
In-Reply-To: <1271581560.16881.4769.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1122 says the following:
...
  Keep-alive packets MUST only be sent when no data or
  acknowledgement packets have been received for the
  connection within an interval.
...

Fix this by storing the timestamp of last received data
packet and checking for it when the keepalive timer expires.

-v2 fix do_tcp_setsockopt() as pointed by Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 include/linux/tcp.h  |    1 +
 net/ipv4/tcp.c       |    5 ++++-
 net/ipv4/tcp_input.c |    3 +++
 net/ipv4/tcp_timer.c |    8 ++++++++
 4 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..405678f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -314,6 +314,7 @@ struct tcp_sock {
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
+	u32	lrcvtime;	/* timestamp of last received data packet (for keepalives) */
 
 	/* Data for direct copy to user */
 	struct {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..a4048d7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2298,7 +2298,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			if (sock_flag(sk, SOCK_KEEPOPEN) &&
 			    !((1 << sk->sk_state) &
 			      (TCPF_CLOSE | TCPF_LISTEN))) {
-				__u32 elapsed = tcp_time_stamp - tp->rcv_tstamp;
+				u32 elapsed = min_t(u32,
+						      tcp_time_stamp - tp->rcv_tstamp,
+						      tcp_time_stamp - tp->lrcvtime);
+
 				if (tp->keepalive_time > elapsed)
 					elapsed = tp->keepalive_time - elapsed;
 				else
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f240f57..60d2980 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5391,6 +5391,8 @@ no_ack:
 				__kfree_skb(skb);
 			else
 				sk->sk_data_ready(sk, 0);
+
+			tp->lrcvtime = tcp_time_stamp;
 			return 0;
 		}
 	}
@@ -5421,6 +5423,7 @@ step5:
 
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
+	tp->lrcvtime = tcp_time_stamp;
 	return 0;
 
 csum_error:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8a0ab29..74dd804 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -554,6 +554,14 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;
 
+	elapsed = tcp_time_stamp - tp->lrcvtime;
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

