From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/6] datagram: Factor out sk queue referencing
Date: Tue, 21 Feb 2012 21:30:33 +0400
Message-ID: <4F43D4B9.8030005@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35522 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab2BURal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:30:41 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes lines shorter and simplifies further patching.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/core/datagram.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 68bbf9f..6f54d0a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -180,18 +180,19 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 		 * However, this function was correct in any case. 8)
 		 */
 		unsigned long cpu_flags;
+		struct sk_buff_head *queue = &sk->sk_receive_queue;
 
-		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
-		skb = skb_peek(&sk->sk_receive_queue);
+		spin_lock_irqsave(&queue->lock, cpu_flags);
+		skb = skb_peek(queue);
 		if (skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				skb->peeked = 1;
 				atomic_inc(&skb->users);
 			} else
-				__skb_unlink(skb, &sk->sk_receive_queue);
+				__skb_unlink(skb, queue);
 		}
-		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
+		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
 		if (skb)
 			return skb;
-- 
1.5.5.6
