From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: send loss probe after 1s if no RTT available
Date: Fri, 18 Sep 2015 11:40:33 -0700
Message-ID: <1442601633-28619-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36406 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbbIRSlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 14:41:00 -0400
Received: by padhk3 with SMTP id hk3so57628585pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 11:41:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes TLP to use 1 sec timer by default when RTT is
not available due to SYN/ACK retransmission or SYN cookies.

Prior to this change, the lack of RTT prevents TLP so the first
data packets sent can only be recovered by fast recovery or RTO.
If the fast recovery fails to trigger the RTO is 3 second when
SYN/ACK is retransmitted. With this patch we can trigger fast
recovery in 1sec instead.

Note that we need to check Fast Open more properly. A Fast Open
connection could be (accepted then) closed before it receives
the final ACK of 3WHS so the state is FIN_WAIT_1. Without the
new check, TLP will retransmit FIN instead of SYN/ACK.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d0ad355..4cd0b50 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2165,7 +2165,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	/* Don't do any loss probe on a Fast Open connection before 3WHS
 	 * finishes.
 	 */
-	if (sk->sk_state == TCP_SYN_RECV)
+	if (tp->fastopen_rsk)
 		return false;
 
 	/* TLP is only scheduled when next timer event is RTO. */
@@ -2175,7 +2175,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	/* Schedule a loss probe in 2*RTT for SACK capable connections
 	 * in Open state, that are either limited by cwnd or application.
 	 */
-	if (sysctl_tcp_early_retrans < 3 || !tp->srtt_us || !tp->packets_out ||
+	if (sysctl_tcp_early_retrans < 3 || !tp->packets_out ||
 	    !tcp_is_sack(tp) || inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
 		return false;
 
@@ -2184,9 +2184,10 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 		return false;
 
 	/* Probe timeout is at least 1.5*rtt + TCP_DELACK_MAX to account
-	 * for delayed ack when there's one outstanding packet.
+	 * for delayed ack when there's one outstanding packet. If no RTT
+	 * sample is available then probe after TCP_TIMEOUT_INIT.
 	 */
-	timeout = rtt << 1;
+	timeout = rtt << 1 ? : TCP_TIMEOUT_INIT;
 	if (tp->packets_out == 1)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
-- 
2.6.0.rc0.131.gf624c3d
