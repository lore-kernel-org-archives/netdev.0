From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] sock: sock_dequeue_err_skb() needs hard irq safety
Date: Wed, 18 Feb 2015 05:47:55 -0800
Message-ID: <1424267275.4942.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:58217 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbBRNr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 08:47:58 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so1802610iga.0
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 05:47:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Non NAPI drivers can call skb_tstamp_tx() and then sock_queue_err_skb()
from hard IRQ context.

Therefore, sock_dequeue_err_skb() needs to block hard irq or
corruptions or hangs can happen.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 364a9e93243d1 ("sock: deduplicate errqueue dequeue")
Fixes: cb820f8e4b7f7 ("net: Provide a generic socket error queue delivery method for Tx time stamps.")
---
 net/core/skbuff.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 88c613eab142..f80507823531 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3621,13 +3621,14 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 {
 	struct sk_buff_head *q = &sk->sk_error_queue;
 	struct sk_buff *skb, *skb_next;
+	unsigned long flags;
 	int err = 0;
 
-	spin_lock_bh(&q->lock);
+	spin_lock_irqsave(&q->lock, flags);
 	skb = __skb_dequeue(q);
 	if (skb && (skb_next = skb_peek(q)))
 		err = SKB_EXT_ERR(skb_next)->ee.ee_errno;
-	spin_unlock_bh(&q->lock);
+	spin_unlock_irqrestore(&q->lock, flags);
 
 	sk->sk_err = err;
 	if (err)
