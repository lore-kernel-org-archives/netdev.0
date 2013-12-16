From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] tcp: use zero-window when free_space is low
Date: Mon, 16 Dec 2013 12:15:57 +0100
Message-ID: <1387192557-9816-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47186 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752787Ab3LPLS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 06:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the kernel tries to announce a zero window when free_space
is below the current receiver mss estimate.

When a sender is transmitting small packets, the receiver might be
unable to shrink the receive window, because
a) we cannot withdraw already-commited receive window, and,
b) we have to round the current rwin up to a multiple of the wscale factor,
   else we would shrink the current window.

This causes the receive buffer to fill up until the rmem limit is hit.
When this happens, we start dropping packets.

As we cannot avoid the "current_win is rounded up to multiple
of mss" issue (we would violate a) above) at least try to prevent the receive
buffer growth towards tcp_rmem[2] limit by attempting
to move to zero-window announcement when free_space
becomes less than 1/16 of the current allowed receive
buffer maximum.  If tcp_rmem[2] is large, this will increase
our chances to get a zero-window announcement out in time.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Unfortunately I couldn't come up with something that has
 no magic ('allowed >> 4') value.  I chose >>4 because it didn't cause
 tput limitations in my 'full-mss-sized, steady state' netcat tests.

 net/ipv4/tcp_output.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

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
+		if (free_space < mss || free_space < (allowed_space >> 4))
 			return 0;
 	}
 
-- 
1.8.1.5
