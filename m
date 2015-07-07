From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net-next] tcp: always send a quick ack when quickacks are enabled
Date: Tue,  7 Jul 2015 14:22:06 +1000
Message-ID: <1436242926-21416-1-git-send-email-jmaxwell37@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmaxwell@redhat.com,
	Jon Maxwell <jmaxwell37@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
__tcp_ack_snd_check() routine which ensures that a quickack is 
always sent when the quickack knob is enabled for that dst.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 net/ipv4/tcp_input.c  | 8 ++++----
 net/ipv4/tcp_output.c | 6 ++----
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 684f095..1af7d74 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3948,7 +3948,6 @@ void tcp_reset(struct sock *sk)
 static void tcp_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	const struct dst_entry *dst;
 
 	inet_csk_schedule_ack(sk);
 
@@ -3960,9 +3959,7 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		dst = __sk_dst_get(sk);
-		if (!dst || !dst_metric(dst, RTAX_QUICKACK))
-			inet_csk(sk)->icsk_ack.pingpong = 1;
+		inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
@@ -4887,6 +4884,7 @@ static inline void tcp_data_snd_check(struct sock *sk)
 static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	const struct dst_entry *dst = __sk_dst_get(sk);
 
 	    /* More than one full frame received... */
 	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
@@ -4896,6 +4894,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 	     __tcp_select_window(sk) >= tp->rcv_wnd) ||
 	    /* We ACK each frame or... */
 	    tcp_in_quickack_mode(sk) ||
+	    /* quickack on dst */
+	    (dst && dst_metric(dst, RTAX_QUICKACK)) ||
 	    /* We have out of order data. */
 	    (ofo_possible && skb_peek(&tp->out_of_order_queue))) {
 		/* Then ack it now */
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
