From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3] tcp: introduce a per-route knob for quick ack
Date: Sat, 15 Jun 2013 09:39:18 +0800
Message-ID: <1371260359-5875-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285Ab3FOBkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 21:40:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

In previous discussions, I tried to find some reasonable heuristics
for delayed ACK, however this seems not possible, according to Eric:

	"ACKS might also be delayed because of bidirectional
	traffic, and is more controlled by the application
	response time. TCP stack can not easily estimate it."

	"ACK can be incredibly useful to recover from losses in
	a short time.

	The vast majority of TCP sessions are small lived, and we
	send one ACK per received segment anyway at beginning or
	retransmits to let the sender smoothly increase its cwnd,
	so an auto-tuning facility wont help them that much."

and according to David:

	"ACKs are the only information we have to detect loss.

	And, for the same reasons that TCP VEGAS is fundamentally
	broken, we cannot measure the pipe or some other
	receiver-side-visible piece of information to determine
	when it's "safe" to stretch ACK.

	And even if it's "safe", we should not do it so that losses are
	accurately detected and we don't spuriously retransmit.

	The only way to know when the bandwidth increases is to
	"test" it, by sending more and more packets until drops happen.
	That's why all successful congestion control algorithms must
	operate on explicited tested pieces of information.

	Similarly, it's not really possible to universally know if
	it's safe to stretch ACK or not."

It still makes sense to enable or disable quick ack mode like
what TCP_QUICK_ACK does.

Similar to TCP_QUICK_ACK option, but for people who can't
modify the source code and still wants to control
TCP delayed ACK behavior. As David suggested, this should belong
to per-path scope, since different pathes may want different
behaviors.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
v3: check return value of __sk_dst_get()
v2: improve changelog

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
index 46271cdc..28af45a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3717,6 +3717,7 @@ void tcp_reset(struct sock *sk)
 static void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	const struct dst_entry *dst;
 
 	inet_csk_schedule_ack(sk);
 
@@ -3728,7 +3729,9 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		inet_csk(sk)->icsk_ack.pingpong = 1;
+		dst = __sk_dst_get(sk);
+		if (!dst || !dst_metric(dst, RTAX_QUICKACK))
+			inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3dd46ea..3d71830 100644
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
+	    (!dst || !dst_metric(dst, RTAX_QUICKACK)))
+			icsk->icsk_ack.pingpong = 1;
 }
 
 /* Account for an ACK we sent. */
