From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tsq: fix nonagle handling
Date: Sun, 09 Feb 2014 18:40:11 -0800
Message-ID: <1392000011.6615.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	John Ogness <john.ogness@linutronix.de>,
	Thomas Glanzmann <thomas@glanzmann.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:47134 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbaBJCkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:40:13 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so5567925pab.24
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 18:40:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Ogness <john.ogness@linutronix.de>

Commit 46d3ceabd8d9 ("tcp: TCP Small Queues") introduced a possible
regression for applications using TCP_NODELAY.

If TCP session is throttled because of tsq, we should consult
tp->nonagle when TX completion is done and allow us to send additional
segment, especially if this segment is not a full MSS.
Otherwise this segment is sent after an RTO.

[edumazet] : Cooked the changelog, added another fix about testing
sk_wmem_alloc twice because TX completion can happen right before
setting TSQ_THROTTLED bit.

This problem is particularly visible with recent auto corking,
but might also be triggered with low tcp_limit_output_bytes
values or NIC drivers delaying TX completion by hundred of usec,
and very low rtt.

Thomas Glanzmann for example reported an iscsi regression, caused
by tcp auto corking making this bug quite visible.

Fixes: 46d3ceabd8d9 ("tcp: TCP Small Queues")
Signed-off-by: John Ogness <john.ogness@linutronix.de>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Thomas Glanzmann <thomas@glanzmann.de>
---
 net/ipv4/tcp_output.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 10435b3b9d0f..3be16727f058 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -698,7 +698,8 @@ static void tcp_tsq_handler(struct sock *sk)
 	if ((1 << sk->sk_state) &
 	    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_CLOSING |
 	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK))
-		tcp_write_xmit(sk, tcp_current_mss(sk), 0, 0, GFP_ATOMIC);
+		tcp_write_xmit(sk, tcp_current_mss(sk), tcp_sk(sk)->nonagle,
+			       0, GFP_ATOMIC);
 }
 /*
  * One tasklet per cpu tries to send more skbs.
@@ -1904,7 +1905,15 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
-			break;
+			/* It is possible TX completion already happened
+			 * before we set TSQ_THROTTLED, so we must
+			 * test again the condition.
+			 * We abuse smp_mb__after_clear_bit() because
+			 * there is no smp_mb__after_set_bit() yet
+			 */
+			smp_mb__after_clear_bit();
+			if (atomic_read(&sk->sk_wmem_alloc) > limit)
+				break;
 		}
 
 		limit = mss_now;
