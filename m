From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 03/14] net: add function to allocate sk_buff head without data area
Date: Wed, 17 Apr 2013 18:46:58 +0200
Message-ID: <1366217229-22705-4-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935968Ab3DQQrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:24 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to allocate a sk_buff head without any data. This will
be used by memory mapped netlink to attach data from the mmaped area
to the skb.

Additionally change skb_release_all() to check whether the skb has a
data area to allow the skb destructor to clear the data pointer in case
only a head has been allocated.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/skbuff.h |  6 ++++++
 net/core/skbuff.c      | 30 +++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e27d1c7..4f95130 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -649,6 +649,12 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
+extern struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
+static inline struct sk_buff *alloc_skb_head(gfp_t priority)
+{
+	return __alloc_skb_head(priority, -1);
+}
+
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ba64614..3bd61c4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -179,6 +179,33 @@ out:
  *
  */
 
+struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
+{
+	struct sk_buff *skb;
+
+	/* Get the HEAD */
+	skb = kmem_cache_alloc_node(skbuff_head_cache,
+				    gfp_mask & ~__GFP_DMA, node);
+	if (!skb)
+		goto out;
+
+	/*
+	 * Only clear those fields we need to clear, not those that we will
+	 * actually initialise below. Hence, don't put any more fields after
+	 * the tail pointer in struct sk_buff!
+	 */
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->data = NULL;
+	skb->truesize = sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header = ~0U;
+#endif
+out:
+	return skb;
+}
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -584,7 +611,8 @@ static void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	skb_release_data(skb);
+	if (likely(skb->data))
+		skb_release_data(skb);
 }
 
 /**
-- 
1.8.1.4
