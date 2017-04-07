From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: restrict F-RTO to work-around broken middle-boxes
Date: Fri,  7 Apr 2017 11:42:05 -0700
Message-ID: <20170407184205.168217-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:32983 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754489AbdDGSmn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:42:43 -0400
Received: by mail-pg0-f52.google.com with SMTP id x125so74158945pgb.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 11:42:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent extension of F-RTO 89fe18e44 ("tcp: extend F-RTO
to catch more spurious timeouts") interacts badly with certain
broken middle-boxes.  These broken boxes modify and falsely raise
the receive window on the ACKs. During a timeout induced recovery,
F-RTO would send new data packets to probe if the timeout is false
or not. Since the receive window is falsely raised, the receiver
would silently drop these F-RTO packets. The recovery would take N
(exponentially backoff) timeouts to repair N packet losses.  A TCP
performance killer.

Due to this unfortunate situation, this patch removes this extension
to revert F-RTO back to the RFC specification.

Fixes: 89fe18e44f7e ("tcp: extend F-RTO to catch more spurious timeouts")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2c1f59386a7b..659d1baefb2b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1935,6 +1935,7 @@ void tcp_enter_loss(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct net *net = sock_net(sk);
 	struct sk_buff *skb;
+	bool new_recovery = icsk->icsk_ca_state < TCP_CA_Recovery;
 	bool is_reneg;			/* is receiver reneging on SACKs? */
 	bool mark_lost;
 
@@ -1994,15 +1995,18 @@ void tcp_enter_loss(struct sock *sk)
 	tp->high_seq = tp->snd_nxt;
 	tcp_ecn_queue_cwr(tp);
 
-	/* F-RTO RFC5682 sec 3.1 step 1 mandates to disable F-RTO
-	 * if a previous recovery is underway, otherwise it may incorrectly
-	 * call a timeout spurious if some previously retransmitted packets
-	 * are s/acked (sec 3.2). We do not apply that retriction since
-	 * retransmitted skbs are permanently tagged with TCPCB_EVER_RETRANS
-	 * so FLAG_ORIG_SACK_ACKED is always correct. But we do disable F-RTO
-	 * on PTMU discovery to avoid sending new data.
+	/* F-RTO RFC5682 sec 3.1 step 1: retransmit SND.UNA if no previous
+	 * loss recovery is underway except recurring timeout(s) on
+	 * the same SND.UNA (sec 3.2). Disable F-RTO on path MTU probing
+	 *
+	 * In theory F-RTO can be used repeatedly during loss recovery.
+	 * In practice this interacts badly with broken middle-boxes that
+	 * falsely raise the receive window, which results in repeated
+	 * timeouts and stop-and-go behavior.
 	 */
-	tp->frto = sysctl_tcp_frto && !inet_csk(sk)->icsk_mtup.probe_size;
+	tp->frto = sysctl_tcp_frto &&
+		   (new_recovery || icsk->icsk_retransmits) &&
+		   !inet_csk(sk)->icsk_mtup.probe_size;
 }
 
 /* If ACK arrived pointing to a remembered SACK, it means that our
-- 
2.12.2.715.g7642488e1d-goog
