From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/3] node-aware skb allocation
Date: Wed, 15 Nov 2006 18:37:07 +0100
Message-ID: <20061115173707.GC18244@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:51380 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030758AbWKORhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 12:37:17 -0500
To: akpm@osdl.org, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Node-aware allocation of skbs for the receive path.

Details:

  - __alloc_skb gets a new node argument and cals the node-aware
    slab functions with it.
  - netdev_alloc_skb passed the node number it gets from dev_to_node
    to it, everyone else passes -1 (any node)


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/skbuff.h
===================================================================
--- linux-2.6.orig/include/linux/skbuff.h	2006-11-02 12:47:50.000000000 +0100
+++ linux-2.6/include/linux/skbuff.h	2006-11-02 12:48:22.000000000 +0100
@@ -331,17 +331,17 @@
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone);
+				   gfp_t priority, int fclone, int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0);
+	return __alloc_skb(size, priority, 0, -1);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1);
+	return __alloc_skb(size, priority, 1, -1);
 }
 
 extern struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
Index: linux-2.6/net/core/skbuff.c
===================================================================
--- linux-2.6.orig/net/core/skbuff.c	2006-11-02 12:47:50.000000000 +0100
+++ linux-2.6/net/core/skbuff.c	2006-11-02 12:48:22.000000000 +0100
@@ -131,6 +131,7 @@
  *	@gfp_mask: allocation mask
  *	@fclone: allocate from fclone cache instead of head cache
  *		and allocate a cloned (child) skb
+ *	@node: numa node to allocate memory on
  *
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
  *	tail room of size bytes. The object has a reference count of one.
@@ -140,7 +141,7 @@
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone)
+			    int fclone, int node)
 {
 	kmem_cache_t *cache;
 	struct skb_shared_info *shinfo;
@@ -150,14 +151,14 @@
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
 	/* Get the HEAD */
-	skb = kmem_cache_alloc(cache, gfp_mask & ~__GFP_DMA);
+	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
 		goto out;
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask);
+	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
+			gfp_mask, node);
 	if (!data)
 		goto nodata;
 
@@ -266,9 +267,10 @@
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
+	int node = dev->class_dev.dev ? dev_to_node(dev->class_dev.dev) : -1;
 	struct sk_buff *skb;
 
-	skb = alloc_skb(length + NET_SKB_PAD, gfp_mask);
+ 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
