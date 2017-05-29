From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/3] net: factor out a helper to decrement the skb refcount
Date: Mon, 29 May 2017 17:27:23 +0200
Message-ID: <d8ae2b225a566fb1addf970db79cbcea834b4ad0.1496070490.git.pabeni@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47626 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdE2P2D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 11:28:03 -0400
In-Reply-To: <cover.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same code is replicated in 3 different places; move it to a
common helper.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 13 +++++++++++++
 net/core/datagram.c    |  4 +---
 net/core/skbuff.c      | 14 ++++----------
 3 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 45a59c1..3c25fca 100644
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
index 780b7c1..c81b828 100644
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
