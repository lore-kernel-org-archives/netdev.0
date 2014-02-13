From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Thu, 13 Feb 2014 12:52:30 +0100
Message-ID: <1392292350-28800-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43061 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbaBML4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 06:56:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel tries to announce a zero window when free_space
is below the current receiver mss estimate.

When a sender is transmitting small packets and reader consumes data
slowly (or not at all), receiver might be unable to shrink the receive
win because

a) we cannot withdraw already-commited receive window, and,
b) we have to round the current rwin up to a multiple of the wscale
   factor, else we would shrink the current window.

This causes the receive buffer to fill up until the rmem limit is hit.
When this happens, we start dropping packets.

Moreover, tcp_clamp_window may continue to grow sk_rcvbuf towards rmem[2]
even if socket is not being read from.

As we cannot avoid the "current_win is rounded up to multiple of mss"
issue [we would violate a) above] at least try to prevent the receive buf
growth towards tcp_rmem[2] limit by attempting to move to zero-window
announcement when free_space becomes less than 1/16 of the current
allowed receive buffer maximum.  If tcp_rmem[2] is large, this will
increase our chances to get a zero-window announcement out in time.

Reproducer:
On server:
$ nc -l -p 12345
<suspend it: CTRL-Z>

Client:
#!/usr/bin/env python
import socket
import time

sock = socket.socket()
sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
sock.connect(("192.168.4.1", 12345));
while True:
   sock.send('A' * 23)
   time.sleep(0.005)


socket buffer on server-side will grow until tcp_rmem[2] is hit,
at which point the client rexmits data until -EDTIMEOUT:

tcp_data_queue invokes tcp_try_rmem_schedule which will call
tcp_prune_queue which calls tcp_clamp_window().  And that function will
grow sk->sk_rcvbuf up until it eventually hits tcp_rmem[2].

Cc: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 V1 of this patch was deferred, resending to get discussion going again.
 Changes since v1:
  - add reproducer to commit message

 Unfortunately I couldn't come up with something that has no magic
 ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
 tput limitations in my 'full-mss-sized, steady state' netcat tests.

 Maybe someone has better idea?

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2a69f42..fd8d821 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2145,7 +2145,8 @@ u32 __tcp_select_window(struct sock *sk)
 	 */
 	int mss = icsk->icsk_ack.rcv_mss;
 	int free_space = tcp_space(sk);
-	int full_space = min_t(int, tp->window_clamp, tcp_full_space(sk));
+	int allowed_space = tcp_full_space(sk);
+	int full_space = min_t(int, tp->window_clamp, allowed_space);
 	int window;
 
 	if (mss > full_space)
@@ -2158,7 +2159,19 @@ u32 __tcp_select_window(struct sock *sk)
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh,
 					       4U * tp->advmss);
 
-		if (free_space < mss)
+		/* free_space might become our new window, make sure we don't
+		 * increase it due to wscale.
+		 */
+		free_space = round_down(free_space, 1 << tp->rx_opt.rcv_wscale);
+
+		/* if free space is less than mss estimate, or is below 1/16th
+		 * of the maximum allowed, try to move to zero-window, else
+		 * tcp_clamp_window() will grow rcv buf up to tcp_rmem[2], and
+		 * new incoming data is dropped due to memory limits.
+		 * With large window, mss test triggers way too late in order
+		 * to announce zero window in time before rmem limit kicks in.
+		 */
+		if (free_space < (allowed_space >> 4) || free_space < mss)
 			return 0;
 	}
 
-- 
1.8.1.5
