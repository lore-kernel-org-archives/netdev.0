From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Mon, 05 Dec 2016 09:57:19 -0800
Message-ID: <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Paolo Abeni <pabeni@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34834 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbcLER6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 12:58:22 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so17110651pga.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 09:58:22 -0800 (PST)
In-Reply-To: <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In UDP recvmsg() path we currently access 3 cache lines from an skb
while holding receive queue lock, plus another one if packet is
dequeued, since we need to change skb->next->prev

1st cache line (contains ->next/prev pointers, offsets 0x00 and 0x08)
2nd cache line (skb->len & skb->peeked, offsets 0x80 and 0x8e)
3rd cache line (skb->truesize/users, offsets 0xe0 and 0xe4)

skb->peeked is only needed to make sure 0-length packets are properly
handled while MSG_PEEK is operated.

I had first the intent to remove skb->peeked but the "MSG_PEEK at
non-zero offset" support added by Sam Kumar makes this not possible.

This patch avoids one cache line miss during the locked section, when
skb->len and skb->peeked do not have to be read.

It also avoids the skb_set_peeked() cost for non empty UDP datagrams.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/datagram.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 49816af8586bb832e806972b486588041a99524c..9482037a5c8c64aec79e42c65bd2691bdd9450a3 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -214,6 +214,7 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 	if (error)
 		goto no_packet;
 
+	*peeked = 0;
 	do {
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
@@ -227,22 +228,22 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 		spin_lock_irqsave(&queue->lock, cpu_flags);
 		skb_queue_walk(queue, skb) {
 			*last = skb;
-			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				if (_off >= skb->len && (skb->len || _off ||
 							 skb->peeked)) {
 					_off -= skb->len;
 					continue;
 				}
-
-				skb = skb_set_peeked(skb);
-				error = PTR_ERR(skb);
-				if (IS_ERR(skb)) {
-					spin_unlock_irqrestore(&queue->lock,
-							       cpu_flags);
-					goto no_packet;
+				if (!skb->len) {
+					skb = skb_set_peeked(skb);
+					if (IS_ERR(skb)) {
+						error = PTR_ERR(skb);
+						spin_unlock_irqrestore(&queue->lock,
+								       cpu_flags);
+						goto no_packet;
+					}
 				}
-
+				*peeked = 1;
 				atomic_inc(&skb->users);
 			} else {
 				__skb_unlink(skb, queue);
