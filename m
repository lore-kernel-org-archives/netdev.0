From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] tcp: introduce a per-route knob for quick ack
Date: Wed, 12 Jun 2013 17:55:54 +0800
Message-ID: <1371030955-6740-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648Ab3FLJ4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 05:56:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

According to previous discussion [1], it seems there is no
reasonable heuristics.

Similar to TCP_QUICK_ACK option, but for people who can't
modify the source code and still wants to control
TCP delayed ACK behavior. As people suggested, introduce
a per-route knob for it.

1. http://marc.info/?t=136507071100004&r=1&w=2

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 include/uapi/linux/rtnetlink.h |    2 ++
 net/ipv4/tcp_input.c           |    5 ++++-
 net/ipv4/tcp_output.c          |    6 ++++--
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 7a2144e..eb0f1a5 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -386,6 +386,8 @@ enum {
 #define RTAX_RTO_MIN RTAX_RTO_MIN
 	RTAX_INITRWND,
 #define RTAX_INITRWND RTAX_INITRWND
+	RTAX_QUICKACK,
+#define RTAX_QUICKACK RTAX_QUICKACK
 	__RTAX_MAX
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 907311c..51ed9b7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3726,6 +3726,7 @@ void tcp_reset(struct sock *sk)
 static void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	const struct dst_entry *dst;
 
 	inet_csk_schedule_ack(sk);
 
@@ -3737,7 +3738,9 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		inet_csk(sk)->icsk_ack.pingpong = 1;
+		dst = __sk_dst_get(sk);
+		if (!dst_metric(dst, RTAX_QUICKACK))
+			inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ec335fa..f840b92 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -160,6 +160,7 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
+	const struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (sysctl_tcp_slow_start_after_idle &&
 	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
@@ -170,8 +171,9 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	/* If it is a reply for ato after last received
 	 * packet, enter pingpong mode.
 	 */
-	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato)
-		icsk->icsk_ack.pingpong = 1;
+	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato &&
+	    !dst_metric(dst, RTAX_QUICKACK))
+			icsk->icsk_ack.pingpong = 1;
 }
 
 /* Account for an ACK we sent. */
