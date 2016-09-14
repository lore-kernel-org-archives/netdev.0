From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix a stale ooo_last_skb after a replace
Date: Tue, 13 Sep 2016 22:55:05 -0700
Message-ID: <1473832505.22679.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
        Yaogong Wang <wygivan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36722 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbcINFzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:55:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id n24so255690pfb.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 22:55:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When skb replaces another one in ooo queue, I forgot to also
update tp->ooo_last_skb as well, if the replaced skb was the last one
in the queue.

To fix this, we simply can re-use the code that runs after an insertion,
trying to merge skbs at the right of current skb.

This not only fixes the bug, but also remove all small skbs that might
be a subset of the new one.

Example:

We receive segments 2001:3001,  4001:5001

Then we receive 2001:8001 : We should replace 2001:3001 with the big
skb, but also remove 4001:50001 from the queue to save space.

packetdrill test demonstrating the bug

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

+0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
+0.100 < . 1:1(0) ack 1 win 1024
+0 accept(3, ..., ...) = 4

+0.01 < . 1001:2001(1000) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 1001:2001>

+0.01 < . 1001:3001(2000) ack 1 win 1024
+0    > . 1:1(0) ack 1 <nop,nop, sack 1001:2001 1001:3001>


Fixes: 9f5afeae5152 ("tcp: use an RB tree for ooo receive queue")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yuchung Cheng <ycheng@google.com>
Cc: Yaogong Wang <wygivan@google.com>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 70b892db99018fb42ab38ab7e5ce0dab498f9571..dad3e7eeed94b6f76f4bef4812c5d0fe9944e5f0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4502,7 +4502,7 @@ coalesce_done:
 				NET_INC_STATS(sock_net(sk),
 					      LINUX_MIB_TCPOFOMERGE);
 				__kfree_skb(skb1);
-				goto add_sack;
+				goto merge_right;
 			}
 		} else if (tcp_try_coalesce(sk, skb1, skb, &fragstolen)) {
 			goto coalesce_done;
@@ -4514,6 +4514,7 @@ insert:
 	rb_link_node(&skb->rbnode, parent, p);
 	rb_insert_color(&skb->rbnode, &tp->out_of_order_queue);
 
+merge_right:
 	/* Remove other segments covered by skb. */
 	while ((q = rb_next(&skb->rbnode)) != NULL) {
 		skb1 = rb_entry(q, struct sk_buff, rbnode);
