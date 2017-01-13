From: Yuchung Cheng <ycheng@google.com>
Subject: [net-next 11/13] tcp: remove RFC4653 NCR
Date: Thu, 12 Jan 2017 22:03:52 -0800
Message-ID: <20170113060354.85234-12-ycheng@google.com>
References: <20170113060354.85234-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33975 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdAMGEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:04:30 -0500
Received: by mail-pf0-f181.google.com with SMTP id 127so25543899pfg.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:04:30 -0800 (PST)
In-Reply-To: <20170113060354.85234-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the (partial) implementation of the aggressive
limited transmit in RFC4653 TCP Non-Congestion Robustness (NCR).

NCR is a mitigation to the problem created by the dynamic
DUPACK threshold.  With the current adaptive DUPACK threshold
(tp->reordering) could cause timeouts by preventing fast recovery.
For example, if the last packet of a cwnd burst was reordered, the
threshold will be set to the size of cwnd. But if next application
burst is smaller than threshold and has drops instead of reorderings,
the sender would not trigger fast recovery but instead resorts to a
timeout recovery.

NCR mitigates this issue by checking the number of DUPACKs against
the current flight size additionally. The techniqueue is similar to
the early retransmit RFC.

With RACK loss detection, this mitigation is not needed, because RACK
does not use DUPACK threshold to detect losses. RACK arms a reordering
timer to fire at most a quarter RTT later to start fast recovery.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 79c819077a59..87315ab1ab1a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2161,8 +2161,6 @@ static inline int tcp_dupack_heuristics(const struct tcp_sock *tp)
 static bool tcp_time_to_recover(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	__u32 packets_out;
-	int tcp_reordering = sock_net(sk)->ipv4.sysctl_tcp_reordering;
 
 	/* Trick#1: The loss is proven. */
 	if (tp->lost_out)
@@ -2172,19 +2170,6 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	if (tcp_dupack_heuristics(tp) > tp->reordering)
 		return true;
 
-	/* Trick#4: It is still not OK... But will it be useful to delay
-	 * recovery more?
-	 */
-	packets_out = tp->packets_out;
-	if (packets_out <= tp->reordering &&
-	    tp->sacked_out >= max_t(__u32, packets_out/2, tcp_reordering) &&
-	    !tcp_may_send_now(sk)) {
-		/* We have nothing to send. This connection is limited
-		 * either by receiver window or by application.
-		 */
-		return true;
-	}
-
 	/* If a thin stream is detected, retransmit after first
 	 * received dupack. Employ only if SACK is supported in order
 	 * to avoid possible corner-case series of spurious retransmissions
-- 
2.11.0.483.g087da7b7c-goog
