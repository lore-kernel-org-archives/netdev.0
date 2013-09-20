From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix dynamic right sizing
Date: Fri, 20 Sep 2013 13:56:58 -0700
Message-ID: <1379710618.3431.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:51571 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab3ITU5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 16:57:02 -0400
Received: by mail-yh0-f46.google.com with SMTP id c41so400184yho.33
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 13:57:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dynamic Right Sizing (DRS) is supposed to open TCP receive window
automatically, but suffers from two bugs, presented by order
of importance.

1) tcp_rcv_space_adjust() fix :

Using twice the last received amount is very pessimistic,
because it doesn't allow fast recovery or proper slow start
ramp up, if sender wants to increase cwin by 100% every RTT.

copied = bytes received in previous RTT

2*copied = bytes we expect to receive in next RTT

4*copied = bytes we need to advertise in rwin at end of next RTT

DRS is one RTT late, it needs a 4x factor.

If sender is not using ABC, and increases cwin by 50% every rtt,
then we needed 1.5*1.5 = 2.25 factor.
This is probably why this bug was not really noticed.

2) There is no window adjustment after first RTT. DRS triggers only
  after the second RTT.
  DRS needs two RTT to initialize, so tcp_fixup_rcvbuf() should setup
  sk_rcvbuf to allow proper window grow for first two RTT.

This patch increases TCP efficiency particularly for large RTT flows
when autotuning is used at the receiver, and more particularly
in presence of packet losses.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Van Jacobson <vanj@google.com>
---
 net/ipv4/tcp_input.c |   84 +++++++++++++++++++++++++----------------
 1 file changed, 53 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 25a89ea..5d08385 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -355,6 +355,12 @@ static void tcp_fixup_rcvbuf(struct sock *sk)
 	rcvmem = 2 * SKB_TRUESIZE(mss + MAX_TCP_HEADER) *
 		 tcp_default_init_rwnd(mss);
 
+	/* Dynamic Right Sizing (DRS) has 2 to 3 RTT latency
+	 * Allow enough cushion so that sender is not limited by our window
+	 */
+	if (sysctl_tcp_moderate_rcvbuf)
+		rcvmem <<= 2;
+
 	if (sk->sk_rcvbuf < rcvmem)
 		sk->sk_rcvbuf = min(rcvmem, sysctl_tcp_rmem[2]);
 }
@@ -373,6 +379,8 @@ void tcp_init_buffer_space(struct sock *sk)
 		tcp_fixup_sndbuf(sk);
 
 	tp->rcvq_space.space = tp->rcv_wnd;
+	tp->rcvq_space.time = tcp_time_stamp;
+	tp->rcvq_space.seq = tp->copied_seq;
 
 	maxwin = tcp_full_space(sk);
 
@@ -512,48 +520,62 @@ void tcp_rcv_space_adjust(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int time;
-	int space;
-
-	if (tp->rcvq_space.time == 0)
-		goto new_measure;
+	int copied;
 
 	time = tcp_time_stamp - tp->rcvq_space.time;
 	if (time < (tp->rcv_rtt_est.rtt >> 3) || tp->rcv_rtt_est.rtt == 0)
 		return;
 
-	space = 2 * (tp->copied_seq - tp->rcvq_space.seq);
+	/* Number of bytes copied to user in last RTT */
+	copied = tp->copied_seq - tp->rcvq_space.seq;
+	if (copied <= tp->rcvq_space.space)
+		goto new_measure;
+
+	/* A bit of theory :
+	 * copied = bytes received in previous RTT, our base window
+	 * To cope with packet losses, we need a 2x factor
+	 * To cope with slow start, and sender growing its cwin by 100 %
+	 * every RTT, we need a 4x factor, because the ACK we are sending
+	 * now is for the next RTT, not the current one :
+	 * <prev RTT . ><current RTT .. ><next RTT .... >
+	 */
+
+	if (sysctl_tcp_moderate_rcvbuf &&
+	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK)) {
+		int rcvwin, rcvmem, rcvbuf;
 
-	space = max(tp->rcvq_space.space, space);
+		/* minimal window to cope with packet losses, assuming
+		 * steady state. Add some cushion because of small variations.
+		 */
+		rcvwin = (copied << 1) + 16 * tp->advmss;
 
-	if (tp->rcvq_space.space != space) {
-		int rcvmem;
+		/* If rate increased by 25%,
+		 *	assume slow start, rcvwin = 3 * copied
+		 * If rate increased by 50%,
+		 *	assume sender can use 2x growth, rcvwin = 4 * copied
+		 */
+		if (copied >=
+		    tp->rcvq_space.space + (tp->rcvq_space.space >> 2)) {
+			if (copied >=
+			    tp->rcvq_space.space + (tp->rcvq_space.space >> 1))
+				rcvwin <<= 1;
+			else
+				rcvwin += (rcvwin >> 1);
+		}
 
-		tp->rcvq_space.space = space;
+		rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
+		while (tcp_win_from_space(rcvmem) < tp->advmss)
+			rcvmem += 128;
 
-		if (sysctl_tcp_moderate_rcvbuf &&
-		    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK)) {
-			int new_clamp = space;
+		rcvbuf = min(rcvwin / tp->advmss * rcvmem, sysctl_tcp_rmem[2]);
+		if (rcvbuf > sk->sk_rcvbuf) {
+			sk->sk_rcvbuf = rcvbuf;
 
-			/* Receive space grows, normalize in order to
-			 * take into account packet headers and sk_buff
-			 * structure overhead.
-			 */
-			space /= tp->advmss;
-			if (!space)
-				space = 1;
-			rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
-			while (tcp_win_from_space(rcvmem) < tp->advmss)
-				rcvmem += 128;
-			space *= rcvmem;
-			space = min(space, sysctl_tcp_rmem[2]);
-			if (space > sk->sk_rcvbuf) {
-				sk->sk_rcvbuf = space;
-
-				/* Make the window clamp follow along.  */
-				tp->window_clamp = new_clamp;
-			}
+			/* Make the window clamp follow along.  */
+			tp->window_clamp = rcvwin;
 		}
 	}
+	tp->rcvq_space.space = copied;
 
 new_measure:
 	tp->rcvq_space.seq = tp->copied_seq;
@@ -5674,8 +5696,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			tcp_init_congestion_control(sk);
 
 			tcp_mtup_init(sk);
-			tcp_init_buffer_space(sk);
 			tp->copied_seq = tp->rcv_nxt;
+			tcp_init_buffer_space(sk);
 		}
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
