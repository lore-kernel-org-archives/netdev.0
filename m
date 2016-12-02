From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] udp: be less conservative with sock rmem accounting
Date: Fri,  2 Dec 2016 17:35:49 +0100
Message-ID: <d13b9808dad5f6e3fe3808bae3b4f64dfcee07fe.1480696423.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59906 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751320AbcLBQk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 11:40:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit 850cbaddb52d ("udp: use it's own memory accounting
schema"), the udp protocol allowed sk_rmem_alloc to grow beyond
the rcvbuf by the whole current packet's truesize. After said commit
we allow sk_rmem_alloc to exceed the rcvbuf only if the receive queue
is empty. As reported by Jesper this cause a performance regression
for some (small) values of rcvbuf.

This commit is intended to fix the regression restoring the old
handling of the rcvbuf limit.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Fixes: 850cbaddb52d ("udp: use it's own memory accounting schema")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e1d0bf8..16d88ba 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1205,14 +1205,14 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 	 * queue is full; always allow at least a packet
 	 */
 	rmem = atomic_read(&sk->sk_rmem_alloc);
-	if (rmem && (rmem + size > sk->sk_rcvbuf))
+	if (rmem > sk->sk_rcvbuf)
 		goto drop;
 
 	/* we drop only if the receive buf is full and the receive
 	 * queue contains some other skb
 	 */
 	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
-	if ((rmem > sk->sk_rcvbuf) && (rmem > size))
+	if (rmem > (size + sk->sk_rcvbuf))
 		goto uncharge_drop;
 
 	spin_lock(&list->lock);
-- 
1.8.3.1
