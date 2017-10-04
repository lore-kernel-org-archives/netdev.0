From: Wei Wang <weiwan@google.com>
Subject: [PATCH v2 net-next 2/2] tcp: clean up TFO server's initial tcp_rearm_rto() call
Date: Wed,  4 Oct 2017 10:04:04 -0700
Message-ID: <20171004170404.132419-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:44476 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdJDREJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:04:09 -0400
Received: by mail-pf0-f175.google.com with SMTP id t62so5369305pfd.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 10:04:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This commit does a cleanup and moves tcp_rearm_rto() call in the TFO
server case into a previous spot in tcp_rcv_state_process() to make
it more compact.
This is only a cosmetic change.

Suggested-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
no change in v2

 net/ipv4/tcp_input.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bd3a35f5dbf2..c5b8d61846c2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5911,6 +5911,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		if (req) {
 			inet_csk(sk)->icsk_retransmits = 0;
 			reqsk_fastopen_remove(sk, req, false);
+			/* Re-arm the timer because data may have been sent out.
+			 * This is similar to the regular data transmission case
+			 * when new data has just been ack'ed.
+			 *
+			 * (TFO) - we could try to be more aggressive and
+			 * retransmitting any data sooner based on when they
+			 * are sent out.
+			 */
+			tcp_rearm_rto(sk);
 		} else {
 			tcp_init_transfer(sk, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
 			tp->copied_seq = tp->rcv_nxt;
@@ -5933,18 +5942,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		if (tp->rx_opt.tstamp_ok)
 			tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
 
-		if (req) {
-			/* Re-arm the timer because data may have been sent out.
-			 * This is similar to the regular data transmission case
-			 * when new data has just been ack'ed.
-			 *
-			 * (TFO) - we could try to be more aggressive and
-			 * retransmitting any data sooner based on when they
-			 * are sent out.
-			 */
-			tcp_rearm_rto(sk);
-		}
-
 		if (!inet_csk(sk)->icsk_ca_ops->cong_control)
 			tcp_update_pacing_rate(sk);
 
-- 
2.14.2.920.gcf0c67979c-goog
