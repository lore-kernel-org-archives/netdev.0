From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next] net: fix __skb_try_recv_from_queue to return the old behavior
Date: Tue, 16 May 2017 21:47:10 -0700
Message-ID: <20170517044710.28300-1-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36201 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdEQErY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 00:47:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so271520pfb.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 21:47:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function has to return NULL on a error case, because there is a
separate error variable.

The offset has to be changed only if skb is returned

Cc: Paolo Abeni <pabeni@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Fixes: 65101aeca522 ("net/sock: factor out dequeue/peek with offset cod")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/core/datagram.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index a4592b4..bc46118 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -170,20 +170,21 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 					  struct sk_buff **last)
 {
 	struct sk_buff *skb;
+	int _off = *off;
 
 	*last = queue->prev;
 	skb_queue_walk(queue, skb) {
 		if (flags & MSG_PEEK) {
-			if (*off >= skb->len && (skb->len || *off ||
+			if (_off >= skb->len && (skb->len || _off ||
 						 skb->peeked)) {
-				*off -= skb->len;
+				_off -= skb->len;
 				continue;
 			}
 			if (!skb->len) {
 				skb = skb_set_peeked(skb);
 				if (unlikely(IS_ERR(skb))) {
 					*err = PTR_ERR(skb);
-					return skb;
+					return NULL;
 				}
 			}
 			*peeked = 1;
@@ -193,6 +194,7 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
 			if (destructor)
 				destructor(sk, skb);
 		}
+		*off = _off;
 		return skb;
 	}
 	return NULL;
@@ -253,8 +255,6 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 
 	*peeked = 0;
 	do {
-		int _off = *off;
-
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
 		 *
@@ -263,8 +263,10 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 		 */
 		spin_lock_irqsave(&queue->lock, cpu_flags);
 		skb = __skb_try_recv_from_queue(sk, queue, flags, destructor,
-						peeked, &_off, err, last);
+						peeked, off, &error, last);
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
+		if (error)
+			goto no_packet;
 		if (skb)
 			return skb;
 
-- 
2.9.3
