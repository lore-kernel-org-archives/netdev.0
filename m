From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net] sock: reset sk_err when the error queue is empty
Date: Fri,  2 Jun 2017 12:38:22 -0400
Message-ID: <20170602163822.67543-1-soheil.kdev@gmail.com>
Cc: chrubis@suse.cz, Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34316 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdFBQib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 12:38:31 -0400
Received: by mail-qt0-f194.google.com with SMTP id o21so1982198qtb.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 09:38:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Prior to f5f99309fa74 (sock: do not set sk_err in
sock_dequeue_err_skb), sk_err was reset to the error of
the skb on the head of the error queue.

Applications, most notably ping, are relying on this
behavior to reset sk_err for ICMP packets.

Set sk_err to the ICMP error when there is an ICMP packet
at the head of the error queue.

Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
Reported-by: Cyril Hrubis <chrubis@suse.cz>
Test-by: Cyril Hrubis <chrubis@suse.cz>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 346d3e85dfbc..b1be7c01efe2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3754,8 +3754,11 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 
 	spin_lock_irqsave(&q->lock, flags);
 	skb = __skb_dequeue(q);
-	if (skb && (skb_next = skb_peek(q)))
+	if (skb && (skb_next = skb_peek(q))) {
 		icmp_next = is_icmp_err_skb(skb_next);
+		if (icmp_next)
+			sk->sk_err = SKB_EXT_ERR(skb_next)->ee.ee_origin;
+	}
 	spin_unlock_irqrestore(&q->lock, flags);
 
 	if (is_icmp_err_skb(skb) && !icmp_next)
-- 
2.13.0.506.g27d5fe0cd-goog
