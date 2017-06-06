From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 2/3] udp: avoid a cache miss on dequeue
Date: Tue,  6 Jun 2017 16:23:45 +0200
Message-ID: <25a17e660ebc766ef6af918d7607dde4706f0c23.1496756090.git.pabeni@redhat.com>
References: <cover.1496756090.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46742 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751541AbdFFOY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 10:24:59 -0400
In-Reply-To: <cover.1496756090.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since UDP no more uses sk->destructor, we can clear completely
the skb head state before enqueuing. Amend and use
skb_release_head_state() for that.

All head states share a single cacheline, which is not
normally used/accesses on dequeue. We can avoid entirely accessing
such cacheline implementing and using in the UDP code a specialized
skb free helper which ignores the skb head state.

This saves a cacheline miss at skb deallocation time.

v1 -> v2:
  replaced secpath_reset() with skb_release_head_state()

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 24 ++++++++++++++++++++----
 net/ipv4/udp.c         |  6 +++++-
 3 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3c25fca..ddfb964 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -880,10 +880,12 @@ static inline bool skb_unref(struct sk_buff *skb)
 	return true;
 }
 
+void skb_release_head_state(struct sk_buff *skb);
 void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
 void consume_skb(struct sk_buff *skb);
+void consume_stateless_skb(struct sk_buff *skb);
 void  __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c81b828..786cb42 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -643,12 +643,10 @@ static void kfree_skbmem(struct sk_buff *skb)
 	kmem_cache_free(skbuff_fclone_cache, fclones);
 }
 
-static void skb_release_head_state(struct sk_buff *skb)
+void skb_release_head_state(struct sk_buff *skb)
 {
 	skb_dst_drop(skb);
-#ifdef CONFIG_XFRM
-	secpath_put(skb->sp);
-#endif
+	secpath_reset(skb);
 	if (skb->destructor) {
 		WARN_ON(in_irq());
 		skb->destructor(skb);
@@ -751,6 +749,24 @@ void consume_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(consume_skb);
 
+/**
+ *	consume_stateless_skb - free an skbuff, assuming it is stateless
+ *	@skb: buffer to free
+ *
+ *	Works like consume_skb(), but this variant assumes that all the head
+ *	states have been already dropped.
+ */
+void consume_stateless_skb(struct sk_buff *skb)
+{
+	if (!skb_unref(skb))
+		return;
+
+	trace_consume_skb(skb);
+	if (likely(skb->head))
+		skb_release_data(skb);
+	kfree_skbmem(skb);
+}
+
 void __kfree_skb_flush(void)
 {
 	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fdcb743..d8b265f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1359,7 +1359,8 @@ void skb_consume_udp(struct sock *sk, struct sk_buff *skb, int len)
 		sk_peek_offset_bwd(sk, len);
 		unlock_sock_fast(sk, slow);
 	}
-	consume_skb(skb);
+
+	consume_stateless_skb(skb);
 }
 EXPORT_SYMBOL_GPL(skb_consume_udp);
 
@@ -1739,6 +1740,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		sk_mark_napi_id_once(sk, skb);
 	}
 
+	/* clear all pending head states while they are hot in the cache */
+	skb_release_head_state(skb);
+
 	rc = __udp_enqueue_schedule_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
-- 
2.9.4
