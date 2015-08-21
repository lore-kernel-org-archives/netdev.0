From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: fix slow start after idle vs TSO/GSO
Date: Fri, 21 Aug 2015 12:30:00 -0700
Message-ID: <1440185400.6610.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35576 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbHUTaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 15:30:02 -0400
Received: by pacdd16 with SMTP id dd16so50336057pac.2
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 12:30:02 -0700 (PDT)
In-Reply-To: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

slow start after idle might reduce cwnd, but we perform this
after first packet was cooked and sent.

With TSO/GSO, it means that we might send a full TSO packet
even if cwnd should have been reduced to IW10.

Moving the SSAI check in skb_entail() makes sense, because
we slightly reduce number of times this check is done,
especially for large send() and TCP Small queue callbacks from
softirq context.

As Neal pointed out, we also need to perform the check
if/when receive window opens.

Tested:

Following packetdrill test demonstrates the problem
// Test of slow start after idle

`sysctl -q net.ipv4.tcp_slow_start_after_idle=1`

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

+0    < S 0:0(0) win 65535 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.100 < . 1:1(0) ack 1 win 511
+0    accept(3, ..., ...) = 4
+0    setsockopt(4, SOL_SOCKET, SO_SNDBUF, [200000], 4) = 0

+0    write(4, ..., 26000) = 26000
+0    > . 1:5001(5000) ack 1
+0    > . 5001:10001(5000) ack 1
+0    %{ assert tcpi_snd_cwnd == 10 }%

+.100 < . 1:1(0) ack 10001 win 511
+0    %{ assert tcpi_snd_cwnd == 20, tcpi_snd_cwnd }%
+0    > . 10001:20001(10000) ack 1
+0    > P. 20001:26001(6000) ack 1

+.100 < . 1:1(0) ack 26001 win 511
+0    %{ assert tcpi_snd_cwnd == 36, tcpi_snd_cwnd }%

+4 write(4, ..., 20000) = 20000
// If slow start after idle works properly, we should send 5 MSS here (cwnd/2)
+0    > . 26001:31001(5000) ack 1
+0    %{ assert tcpi_snd_cwnd == 10, tcpi_snd_cwnd }%
+0    > . 31001:36001(5000) ack 1

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |   13 +++++++++++++
 net/ipv4/tcp.c        |    2 ++
 net/ipv4/tcp_input.c  |    3 +++
 net/ipv4/tcp_output.c |   12 ++++--------
 4 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 364426a..309801f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1165,6 +1165,19 @@ static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 }
 
 u32 tcp_default_init_rwnd(u32 mss);
+void tcp_cwnd_restart(struct sock *sk, s32 delta);
+
+static inline void tcp_slow_start_after_idle_check(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	s32 delta;
+
+	if (!sysctl_tcp_slow_start_after_idle || tp->packets_out)
+		return;
+	delta = tcp_time_stamp - tp->lsndtime;
+	if (delta > inet_csk(sk)->icsk_rto)
+		tcp_cwnd_restart(sk, delta);
+}
 
 /* Determine a window scaling and initial window to offer. */
 void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 45534a5..b8b8fa1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -627,6 +627,8 @@ static void skb_entail(struct sock *sk, struct sk_buff *skb)
 	sk_mem_charge(sk, skb->truesize);
 	if (tp->nonagle & TCP_NAGLE_PUSH)
 		tp->nonagle &= ~TCP_NAGLE_PUSH;
+
+	tcp_slow_start_after_idle_check(sk);
 }
 
 static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4e4d6bc..0abca28 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3332,6 +3332,9 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 			tp->pred_flags = 0;
 			tcp_fast_path_check(sk);
 
+			if (tcp_send_head(sk))
+				tcp_slow_start_after_idle_check(sk);
+
 			if (nwin > tp->max_window) {
 				tp->max_window = nwin;
 				tcp_sync_mss(sk, inet_csk(sk)->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 444ab5b..1188e4f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -137,12 +137,12 @@ static __u16 tcp_advertise_mss(struct sock *sk)
 }
 
 /* RFC2861. Reset CWND after idle period longer RTO to "restart window".
- * This is the first part of cwnd validation mechanism. */
-static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
+ * This is the first part of cwnd validation mechanism.
+ */
+void tcp_cwnd_restart(struct sock *sk, s32 delta)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	s32 delta = tcp_time_stamp - tp->lsndtime;
-	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
+	u32 restart_cwnd = tcp_init_cwnd(tp, __sk_dst_get(sk));
 	u32 cwnd = tp->snd_cwnd;
 
 	tcp_ca_event(sk, CA_EVENT_CWND_RESTART);
@@ -164,10 +164,6 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
 
-	if (sysctl_tcp_slow_start_after_idle &&
-	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
-		tcp_cwnd_restart(sk, __sk_dst_get(sk));
-
 	tp->lsndtime = now;
 
 	/* If it is a reply for ato after last received
