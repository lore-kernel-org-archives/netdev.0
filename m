From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Mon, 29 May 2017 17:27:24 +0200
Message-ID: <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55306 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdE2P2F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 11:28:05 -0400
In-Reply-To: <cover.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since UDP no more uses sk->destructor, we can clear completely
the skb head state before enqueuing.

All head states share a single cacheline, which is not
normally used/accesses on dequeue. We can avoid entirely accessing
such cacheline implementing and using in the UDP code a specialized
skb free helper which ignores the skb head state.

This saves a cacheline miss at skb deallocation time.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 18 ++++++++++++++++++
 net/ipv4/udp.c         |  6 +++++-
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3c25fca..94ad816 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -884,6 +884,7 @@ void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
 void consume_skb(struct sk_buff *skb);
+void consume_stateless_skb(struct sk_buff *skb);
 void  __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c81b828..9625f2e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -751,6 +751,24 @@ void consume_skb(struct sk_buff *skb)
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
index fdcb743..53fa48d 100644
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
 
+	/* drop all pending head states; dst, nf and sk are dropped by caller */
+	secpath_reset(skb);
+
 	rc = __udp_enqueue_schedule_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
-- 
2.9.4
