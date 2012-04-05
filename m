From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Fix bug when gap in rcv sequence is filled
Date: Thu,  5 Apr 2012 11:46:03 -0700
Message-ID: <1333651563-3279-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, ncardwell@google.com,
	ilpo.jarvinen@helsink.fi,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49906 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272Ab2DESqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 14:46:12 -0400
Received: by pbcun15 with SMTP id un15so1838485pbc.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 11:46:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per RFC2581 and the newer RFC5681, "the receiver SHOULD send an immediate ACK
when it receives a data segment that fills in all or part of a gap in the
sequence space." When TCP receiver gets the next in-sequence packet, we move
data from ofo queue to receive queue. At this point, we should send an immediate
ack by entering quickack mode.  In the current code, instead of entering
quickack mode upon requeing packets from ofo queue to receive_queue, we enter
quickack mode only when ofo queue becomes empty after requeuing.  This ignores
the possibility that there may be further packets left in ofo queue. This patch
fixes this behavior and enters quickack mode whenever packets are moved from ofo
queue to receive queue.

Also, comment has been updated to reflect that RFC5681 obsoletes RFC2581.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_input.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..ebed78d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4388,12 +4388,14 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 
 /* This one checks to see if we can put data from the
  * out_of_order queue into the receive_queue.
+ * Return 1 if data is moved from ofo queue to receive_queue and 0 otherwise.
  */
-static void tcp_ofo_queue(struct sock *sk)
+static int tcp_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 dsack_high = tp->rcv_nxt;
 	struct sk_buff *skb;
+	bool requeued = false; /*true if an skb is requeued to receive_queue*/
 
 	while ((skb = skb_peek(&tp->out_of_order_queue)) != NULL) {
 		if (after(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
@@ -4418,10 +4420,12 @@ static void tcp_ofo_queue(struct sock *sk)
 
 		__skb_unlink(skb, &tp->out_of_order_queue);
 		__skb_queue_tail(&sk->sk_receive_queue, skb);
+		requeued = true;
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (tcp_hdr(skb)->fin)
 			tcp_fin(sk);
 	}
+	return requeued ? 1 : 0 ;
 }
 
 static int tcp_prune_ofo_queue(struct sock *sk);
@@ -4636,12 +4640,11 @@ queue_and_out:
 			tcp_fin(sk);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
-			tcp_ofo_queue(sk);
 
-			/* RFC2581. 4.2. SHOULD send immediate ACK, when
-			 * gap in queue is filled.
+			/* RFC5681 (which obsoletes RFC2581.) 4.2. SHOULD send
+			 * immediate ACK, when gap in queue is filled.
 			 */
-			if (skb_queue_empty(&tp->out_of_order_queue))
+			if (tcp_ofo_queue(sk))
 				inet_csk(sk)->icsk_ack.pingpong = 0;
 		}
 
-- 
1.7.0.4
