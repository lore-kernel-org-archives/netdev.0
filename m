From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: reset reordering est. selectively on timeout
Date: Mon, 12 Aug 2013 16:41:25 -0700
Message-ID: <1376350885-32407-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	mattmathis@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:39680 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983Ab3HLX5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 19:57:22 -0400
Received: by mail-yh0-f74.google.com with SMTP id z20so761599yhz.5
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 16:57:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On timeout the TCP sender unconditionally reset the estimated
degree of network reordering (tp->reordering). This idea behind
is that the estimate is too large to trigger fast recovery
(e.g., due to a IP path change).

But for example if the sender only had 2 packets outstanding,
then a timeout doesn't tell much about reordering. A sender that
learns about reordering on big writes and lose packets on small
writes will end up falsely retransmit again and again, especially
when reordering is more likely on big writes.

Therefore the sender should only suspects tp->reordering is too
high if it could have gone into fast recovery with the (lower)
default estimate.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b61274b..e965cc7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1877,8 +1877,13 @@ void tcp_enter_loss(struct sock *sk, int how)
 	}
 	tcp_verify_left_out(tp);
 
-	tp->reordering = min_t(unsigned int, tp->reordering,
-			       sysctl_tcp_reordering);
+	/* Timeout in disordered state after receiving substantial DUPACKs
+	 * suggests that the degree of reordering is over-estimated.
+	 */
+	if (icsk->icsk_ca_state <= TCP_CA_Disorder &&
+	    tp->sacked_out >= sysctl_tcp_reordering)
+		tp->reordering = min_t(unsigned int, tp->reordering,
+				       sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
-- 
1.8.3
