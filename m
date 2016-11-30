From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next] sock: reset sk_err for ICMP packets read from error queue
Date: Wed, 30 Nov 2016 14:01:08 -0500
Message-ID: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Cc: edumazet@google.com, willemb@google.com, maze@google.com,
        hannes@stressinduktion.org,
        Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35577 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755486AbcK3TBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:01:17 -0500
Received: by mail-qt0-f193.google.com with SMTP id m48so20730155qta.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 11:01:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Only when ICMP packets are enqueued onto the error queue,
sk_err is also set. Before f5f99309fa74 (sock: do not set sk_err
in sock_dequeue_err_skb), a subsequent error queue read
would set sk_err to the next error on the queue, or 0 if empty.
As no error types other than ICMP set this field, sk_err should
not be modified upon dequeuing them.

Only for ICMP errors, reset the (racy) sk_err. Some applications,
like traceroute, rely on it and go into a futile busy POLLERR
loop otherwise.

In principle, sk_err has to be set while an ICMP error is queued.
Testing is_icmp_err_skb(skb_next) approximates this without
requiring a full queue walk. Applications that receive both ICMP
and other errors cannot rely on this legacy behavior, as other
errors do not set sk_err in the first place.

Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d1d1a5a..8dad391 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3714,20 +3714,29 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
 
+static bool is_icmp_err_skb(const struct sk_buff *skb)
+{
+	return skb && (SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
+		       SKB_EXT_ERR(skb)->ee.ee_origin == SO_EE_ORIGIN_ICMP6);
+}
+
 struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
 {
 	struct sk_buff_head *q = &sk->sk_error_queue;
-	struct sk_buff *skb, *skb_next;
+	struct sk_buff *skb, *skb_next = NULL;
+	bool icmp_next = false;
 	unsigned long flags;
-	int err = 0;
 
 	spin_lock_irqsave(&q->lock, flags);
 	skb = __skb_dequeue(q);
 	if (skb && (skb_next = skb_peek(q)))
-		err = SKB_EXT_ERR(skb_next)->ee.ee_errno;
+		icmp_next = is_icmp_err_skb(skb_next);
 	spin_unlock_irqrestore(&q->lock, flags);
 
-	if (err)
+        if (is_icmp_err_skb(skb) && !icmp_next)
+		sk->sk_err = 0;
+
+	if (skb_next)
 		sk->sk_error_report(sk);
 
 	return skb;
-- 
2.8.0.rc3.226.g39d4020
