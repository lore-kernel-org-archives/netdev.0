From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 1/3] net: factor out a helper to decrement the skb refcount
Date: Mon, 12 Jun 2017 11:23:41 +0200
Message-ID: <bfa550f4bd51ba4c43c3101dbcd4add53be51c98.1497026892.git.pabeni@redhat.com>
References: <cover.1497026892.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdFLJYd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 05:24:33 -0400
In-Reply-To: <cover.1497026892.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same code is replicated in 3 different places; move it to a
common helper.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h | 13 +++++++++++++
 net/core/datagram.c    |  4 +---
 net/core/skbuff.c      | 14 ++++----------
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d460a4c..decce36 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -867,6 +867,19 @@ static inline unsigned int skb_napi_id(const struct sk_buff *skb)
 #endif
 }
 
+/* decrement the reference count and return true if we can free the skb */
+static inline bool skb_unref(struct sk_buff *skb)
+{
+	if (unlikely(!skb))
+		return false;
+	if (likely(atomic_read(&skb->users) == 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return false;
+
+	return true;
+}
+
 void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index bc46118..e5311a7 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -330,9 +330,7 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 {
 	bool slow;
 
-	if (likely(atomic_read(&skb->users) == 1))
-		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users))) {
+	if (!skb_unref(skb)) {
 		sk_peek_offset_bwd(sk, len);
 		return;
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e508c1e..747263c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -694,12 +694,9 @@ EXPORT_SYMBOL(__kfree_skb);
  */
 void kfree_skb(struct sk_buff *skb)
 {
-	if (unlikely(!skb))
-		return;
-	if (likely(atomic_read(&skb->users) == 1))
-		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	if (!skb_unref(skb))
 		return;
+
 	trace_kfree_skb(skb, __builtin_return_address(0));
 	__kfree_skb(skb);
 }
@@ -746,12 +743,9 @@ EXPORT_SYMBOL(skb_tx_error);
  */
 void consume_skb(struct sk_buff *skb)
 {
-	if (unlikely(!skb))
-		return;
-	if (likely(atomic_read(&skb->users) == 1))
-		smp_rmb();
-	else if (likely(!atomic_dec_and_test(&skb->users)))
+	if (!skb_unref(skb))
 		return;
+
 	trace_consume_skb(skb);
 	__kfree_skb(skb);
 }
-- 
2.9.4
