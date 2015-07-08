From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net-next] tcp: v1 always send a quick ack when quickacks are enabled
Date: Wed,  8 Jul 2015 10:12:28 +1000
Message-ID: <1436314348-25577-1-git-send-email-jmaxwell37@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, edumazet@google.com, ncardwell@google.com,
	ycheng@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmaxwell@redhat.com,
	jmaxwell37@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34019 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbbGHANE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 20:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V1 of this patch contains Eric Dumazet's suggestion to move the per
dst RTAX_QUICKACK check into tcp_in_quickack_mode(). Thanks Eric.

I ran some tests and after setting the "ip route change quickack 1"
knob there were still many delayed ACKs sent. This occured
because when icsk_ack.quick=0 the !icsk_ack.pingpong value is
subsequently ignored as tcp_in_quickack_mode() checks both these
values. The condition for a quick ack to trigger requires
that both icsk_ack.quick != 0 and icsk_ack.pingpong=0. Currently
only icsk_ack.pingpong is controlled by the knob. But the
icsk_ack.quick value changes dynamically depending on heuristics.
The crux of the matter is that delayed acks still cannot be entirely
disabled even with the RTAX_QUICKACK per dst knob enabled. This
patch ensures that a quick ack is always sent when the RTAX_QUICKACK
per dst knob is turned on.

The "ip route change quickack 1" knob was recently added to enable
quickacks. It was modeled around the TCP_QUICKACK setsockopt() option.
This issue is that even with "ip route change quickack 1" enabled
we still see delayed ACKs under some conditions. It would be nice
to be able to completely disable delayed ACKs.

Here is an example:

# netstat -s|grep dela
    3 delayed acks sent

For all routes enable the knob

# ip route change quickack 1

Generate some traffic across a slow link and we still see the delayed
acks.

# netstat -s|grep dela
    106 delayed acks sent
    1 delayed acks further delayed because of locked socket

The issue is that both the "ip route change quickack 1" knob and
the TCP_QUICKACK option set the icsk_ack.pingpong variable to 0.
However at the business end in the __tcp_ack_snd_check() routine,
tcp_in_quickack_mode() checks that both icsk_ack.quick != 0
and icsk_ack.pingpong=0 in order to trigger a quickack. As
icsk_ack.quick is determined by heuristics it can be 0. When
that occurs the icsk_ack.pingpong value is ignored and a delayed
ACK is sent regardless.

This patch moves the RTAX_QUICKACK per dst check into the
tcp_in_quickack_mode() routine which ensures that a quickack is
always sent when the quickack knob is enabled for that dst.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 net/ipv4/tcp_input.c  | 11 +++++------
 net/ipv4/tcp_output.c |  6 ++----
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 684f095..b9da527 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -196,11 +196,13 @@ static void tcp_enter_quickack_mode(struct sock *sk)
  * and the session is not interactive.
  */
 
-static inline bool tcp_in_quickack_mode(const struct sock *sk)
+static bool tcp_in_quickack_mode(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 
-	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
+	return (dst && dst_metric(dst, RTAX_QUICKACK)) ||
+		(icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong);
 }
 
 static void tcp_ecn_queue_cwr(struct tcp_sock *tp)
@@ -3948,7 +3950,6 @@ void tcp_reset(struct sock *sk)
 static void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	const struct dst_entry *dst;
 
 	inet_csk_schedule_ack(sk);
 
@@ -3960,9 +3961,7 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		dst = __sk_dst_get(sk);
-		if (!dst || !dst_metric(dst, RTAX_QUICKACK))
-			inet_csk(sk)->icsk_ack.pingpong = 1;
+		inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b1c218d..7105784 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -163,7 +163,6 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
-	const struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (sysctl_tcp_slow_start_after_idle &&
 	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
@@ -174,9 +173,8 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	/* If it is a reply for ato after last received
 	 * packet, enter pingpong mode.
 	 */
-	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato &&
-	    (!dst || !dst_metric(dst, RTAX_QUICKACK)))
-			icsk->icsk_ack.pingpong = 1;
+	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato)
+		icsk->icsk_ack.pingpong = 1;
 }
 
 /* Account for an ACK we sent. */
-- 
1.8.3.1
