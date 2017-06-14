From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] net: use skb_unref() in napi_consume_skb()
Date: Wed, 14 Jun 2017 11:48:48 +0200
Message-ID: <3425d279c75e1470cfa55ceb6a13a22019910de7.1497428844.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751955AbdFNJu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 05:50:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 83ada39bb79d ("net: factor out a helper to decrement the
skb refcount") provided and used a helper for decrementing skb usage,
but I missed at least a spot for it.

This change remove some more duplicated code reusing skb_unref() in
napi_consume_skb(), too. The helper uses an additional, unneeded
unlikely(!skb) test - napi_consume_skb() already check it a few lines
above - but the compiler is smart enough to optimize the duplicated
test out.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/core/skbuff.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3046027..c4d2c1f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -817,10 +817,9 @@ void napi_consume_skb(struct sk_buff *skb, int budget)
 		return;
 	}
 
-	if (likely(atomic_read(&skb->users) == 1))
-		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	if (!skb_unref(skb))
 		return;
+
 	/* if reaching here SKB is ready to free */
 	trace_consume_skb(skb);
 
-- 
2.9.4
