From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce netdev_alloc_frag()
Date: Fri, 18 May 2012 17:12:12 +0200
Message-ID: <1337353932.7029.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56291 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2ERPMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 11:12:17 -0400
Received: by eaak11 with SMTP id k11so847236eaa.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 08:12:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix two issues introduced in commit a1c7fff7e18f5
( net: netdev_alloc_skb() use build_skb() )

- Must be IRQ safe (non NAPI drivers can use it)
- Must not leak the frag if build_skb() fails to allocate sk_buff

This patch introduces netdev_alloc_frag() for drivers willing to
use build_skb() instead of __netdev_alloc_skb() variants.

Factorize code so that :
__dev_alloc_skb() is a wrapper around __netdev_alloc_skb(), and
dev_alloc_skb() a wrapper around netdev_alloc_skb()

Use __GFP_COLD flag.

Almost all network drivers now benefit from skb->head_frag
infrastructure.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |   42 ++++++++-----------
 net/core/skbuff.c      |   82 +++++++++++++++++++--------------------
 2 files changed, 59 insertions(+), 65 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bb47314..fe37c21 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1680,31 +1680,11 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
-/**
- *	__dev_alloc_skb - allocate an skbuff for receiving
- *	@length: length to allocate
- *	@gfp_mask: get_free_pages mask, passed to alloc_skb
- *
- *	Allocate a new &sk_buff and assign it a usage count of one. The
- *	buffer has unspecified headroom built in. Users should allocate
- *	the headroom they think they need without accounting for the
- *	built in space. The built in space is used for optimisations.
- *
- *	%NULL is returned if there is no free memory.
- */
-static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
-					      gfp_t gfp_mask)
-{
-	struct sk_buff *skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
-	if (likely(skb))
-		skb_reserve(skb, NET_SKB_PAD);
-	return skb;
-}
-
-extern struct sk_buff *dev_alloc_skb(unsigned int length);
+extern void *netdev_alloc_frag(unsigned int fragsz);
 
 extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
-		unsigned int length, gfp_t gfp_mask);
+					  unsigned int length,
+					  gfp_t gfp_mask);
 
 /**
  *	netdev_alloc_skb - allocate an skbuff for rx on a specific device
@@ -1720,11 +1700,25 @@ extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
  *	allocates memory it can be called from an interrupt.
  */
 static inline struct sk_buff *netdev_alloc_skb(struct net_device *dev,
-		unsigned int length)
+					       unsigned int length)
 {
 	return __netdev_alloc_skb(dev, length, GFP_ATOMIC);
 }
 
+/* legacy helper around __netdev_alloc_skb() */
+static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
+					      gfp_t gfp_mask)
+{
+	return __netdev_alloc_skb(NULL, length, gfp_mask);
+}
+
+/* legacy helper around netdev_alloc_skb() */
+static inline struct sk_buff *dev_alloc_skb(unsigned int length)
+{
+	return netdev_alloc_skb(NULL, length);
+}
+
+
 static inline struct sk_buff *__netdev_alloc_skb_ip_align(struct net_device *dev,
 		unsigned int length, gfp_t gfp)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7645df1..f0bcbe6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -300,6 +300,40 @@ struct netdev_alloc_cache {
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
 /**
+ * netdev_alloc_frag - allocate a page fragment
+ * @fragsz: fragment size
+ *
+ * Allocates a frag from a page for receive buffer.
+ * Uses GFP_ATOMIC allocations.
+ */
+void *netdev_alloc_frag(unsigned int fragsz)
+{
+	struct netdev_alloc_cache *nc;
+	void *data = NULL;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	nc = &__get_cpu_var(netdev_alloc_cache);
+	if (unlikely(!nc->page)) {
+refill:
+		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		nc->offset = 0;
+	}
+	if (likely(nc->page)) {
+		if (nc->offset + fragsz > PAGE_SIZE) {
+			put_page(nc->page);
+			goto refill;
+		}
+		data = page_address(nc->page) + nc->offset;
+		nc->offset += fragsz;
+		get_page(nc->page);
+	}
+	local_irq_restore(flags);
+	return data;
+}
+EXPORT_SYMBOL(netdev_alloc_frag);
+
+/**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate
@@ -313,32 +347,20 @@ static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
  *	%NULL is returned if there is no free memory.
  */
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
-		unsigned int length, gfp_t gfp_mask)
+				   unsigned int length, gfp_t gfp_mask)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
 			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
-		struct netdev_alloc_cache *nc;
-		void *data = NULL;
+		void *data = netdev_alloc_frag(fragsz);
 
-		nc = &get_cpu_var(netdev_alloc_cache);
-		if (!nc->page) {
-refill:			nc->page = alloc_page(gfp_mask);
-			nc->offset = 0;
-		}
-		if (likely(nc->page)) {
-			if (nc->offset + fragsz > PAGE_SIZE) {
-				put_page(nc->page);
-				goto refill;
-			}
-			data = page_address(nc->page) + nc->offset;
-			nc->offset += fragsz;
-			get_page(nc->page);
+		if (likely(data)) {
+			skb = build_skb(data, fragsz);
+			if (unlikely(!skb))
+				put_page(virt_to_head_page(data));
 		}
-		put_cpu_var(netdev_alloc_cache);
-		skb = data ? build_skb(data, fragsz) : NULL;
 	} else {
 		skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
 	}
@@ -360,28 +382,6 @@ void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
 }
 EXPORT_SYMBOL(skb_add_rx_frag);
 
-/**
- *	dev_alloc_skb - allocate an skbuff for receiving
- *	@length: length to allocate
- *
- *	Allocate a new &sk_buff and assign it a usage count of one. The
- *	buffer has unspecified headroom built in. Users should allocate
- *	the headroom they think they need without accounting for the
- *	built in space. The built in space is used for optimisations.
- *
- *	%NULL is returned if there is no free memory. Although this function
- *	allocates memory it can be called from an interrupt.
- */
-struct sk_buff *dev_alloc_skb(unsigned int length)
-{
-	/*
-	 * There is more code here than it seems:
-	 * __dev_alloc_skb is an inline
-	 */
-	return __dev_alloc_skb(length, GFP_ATOMIC);
-}
-EXPORT_SYMBOL(dev_alloc_skb);
-
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list = *listp;
