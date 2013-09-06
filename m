From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: properly increase rcv_ssthresh for ofo packets
Date: Fri, 06 Sep 2013 10:35:58 -0700
Message-ID: <1378488958.31445.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:56875 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab3IFRf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 13:35:59 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so3459070pbc.39
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 10:35:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP receive window handling is multi staged.

A socket has a memory budget, static or dynamic, in sk_rcvbuf.

Because we do not really know how this memory budget translates to
a TCP window (payload), TCP announces a small initial window
(about 20 MSS).

When a packet is received, we increase TCP rcv_win depending
on the payload/truesize ratio of this packet. Good citizen
packets give a hint that it's reasonable to have rcv_win = sk_rcvbuf/2

This heuristic takes place in tcp_grow_window()

Problem is : We currently call tcp_grow_window() only for in-order
packets.

This means that reorders or packet losses stop proper grow of
rcv_win, and senders are unable to benefit from fast recovery,
or proper reordering level detection.

Really, a packet being stored in OFO queue is not a bad citizen.
It should be part of the game as in-order packets.

In our traces, we very often see sender is limited by linux small
receive windows, even if linux hosts use autotuning (DRS) and should
allow rcv_win to grow to ~3MB.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1969e16..28708d3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4141,6 +4141,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 		if (!tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
 			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 		} else {
+			tcp_grow_window(sk, skb);
 			kfree_skb_partial(skb, fragstolen);
 			skb = NULL;
 		}
@@ -4216,8 +4217,10 @@ add_sack:
 	if (tcp_is_sack(tp))
 		tcp_sack_new_ofo_skb(sk, seq, end_seq);
 end:
-	if (skb)
+	if (skb) {
+		tcp_grow_window(sk, skb);
 		skb_set_owner_r(skb, sk);
+	}
 }
 
 static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int hdrlen,
