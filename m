From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: [PATCH] small skbuff.[ch] tweaks
Date: Tue, 2 Sep 2003 01:16:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902081625.GA52298@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch:
  o Makes a couple inline functions in <linux/skbuff.h> take const arguments
    as appropriate
  o Obvious unlikely()/likely()/BUG_ON() conversions

Patch is versus 2.6.0-test4.

-Mitch

--- linux-2.6.0-test4-VIRGIN/include/linux/skbuff.h	2003-08-10 05:28:41.000000000 -0700
+++ linux-2.6.0-test4mnb1/include/linux/skbuff.h	2003-09-01 14:08:54.000000000 -0700
@@ -306,7 +306,7 @@
  *
  *	Returns true if the queue is empty, false otherwise.
  */
-static inline int skb_queue_empty(struct sk_buff_head *list)
+static inline int skb_queue_empty(const struct sk_buff_head *list)
 {
 	return list->next == (struct sk_buff *)list;
 }
@@ -475,7 +475,7 @@
  *
  *	Return the length of an &sk_buff queue.
  */
-static inline __u32 skb_queue_len(struct sk_buff_head *list_)
+static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
 {
 	return list_->qlen;
 }
@@ -1050,7 +1050,7 @@
 					      int gfp_mask)
 {
 	struct sk_buff *skb = alloc_skb(length + 16, gfp_mask);
-	if (skb)
+	if (likely(skb))
 		skb_reserve(skb, 16);
 	return skb;
 }
--- linux-2.6.0-test4-VIRGIN/net/core/skbuff.c	2003-08-22 13:47:28.000000000 -0700
+++ linux-2.6.0-test4mnb1/net/core/skbuff.c	2003-09-01 14:00:37.000000000 -0700
@@ -129,14 +129,17 @@
 	/* Get the HEAD */
 	skb = kmem_cache_alloc(skbuff_head_cache,
 			       gfp_mask & ~__GFP_DMA);
-	if (!skb)
+	if (unlikely(!skb))
 		goto out;
 
 	/* Get the DATA. Size must match skb_add_mtu(). */
 	size = SKB_DATA_ALIGN(size);
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
-	if (!data)
-		goto nodata;
+	if (unlikely(!data)) {
+		kmem_cache_free(skbuff_head_cache, skb);
+		skb = NULL;
+		goto out;
+	}
 
 	memset(skb, 0, offsetof(struct sk_buff, truesize));
 	skb->truesize = size + sizeof(struct sk_buff);
@@ -153,10 +156,6 @@
 	skb_shinfo(skb)->frag_list = NULL;
 out:
 	return skb;
-nodata:
-	kmem_cache_free(skbuff_head_cache, skb);
-	skb = NULL;
-	goto out;
 }
 
 
@@ -218,7 +217,7 @@
 
 void __kfree_skb(struct sk_buff *skb)
 {
-	if (skb->list) {
+	if (unlikely(skb->list)) {
 	 	printk(KERN_WARNING "Warning: kfree_skb passed an skb still "
 		       "on a list (from %p).\n", NET_CALLER(skb));
 		BUG();
@@ -229,7 +228,7 @@
 	secpath_put(skb->sp);
 #endif
 	if(skb->destructor) {
-		if (in_irq())
+		if (unlikely(in_irq()))
 			printk(KERN_WARNING "Warning: kfree_skb on "
 					    "hard IRQ %p\n", NET_CALLER(skb));
 		skb->destructor(skb);
@@ -261,7 +260,7 @@
 {
 	struct sk_buff *n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 
-	if (!n) 
+	if (unlikely(!n))
 		return NULL;
 
 #define C(x) n->x = skb->x
@@ -395,7 +394,7 @@
 	 */
 	struct sk_buff *n = alloc_skb(skb->end - skb->head + skb->data_len,
 				      gfp_mask);
-	if (!n)
+	if (unlikely(!n))
 		return NULL;
 
 	/* Set the data pointer */
@@ -405,7 +404,7 @@
 	n->csum	     = skb->csum;
 	n->ip_summed = skb->ip_summed;
 
-	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
+	if (unlikely(skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len)))
 		BUG();
 
 	copy_skb_header(n, skb);
@@ -433,7 +432,7 @@
 	 */
 	struct sk_buff *n = alloc_skb(skb->end - skb->head, gfp_mask);
 
-	if (!n)
+	if (unlikely(!n))
 		goto out;
 
 	/* Set the data pointer */
@@ -493,14 +492,13 @@
 	int size = nhead + (skb->end - skb->head) + ntail;
 	long off;
 
-	if (skb_shared(skb))
-		BUG();
+	BUG_ON(skb_shared(skb));
 
 	size = SKB_DATA_ALIGN(size);
 
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
-	if (!data)
-		goto nodata;
+	if (unlikely(!data))
+		return -ENOMEM;
 
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
@@ -527,9 +525,6 @@
 	skb->cloned   = 0;
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
-
-nodata:
-	return -ENOMEM;
 }
 
 /* Make private copy of skb with writable head and some headroom */
@@ -543,8 +538,8 @@
 		skb2 = pskb_copy(skb, GFP_ATOMIC);
 	else {
 		skb2 = skb_clone(skb, GFP_ATOMIC);
-		if (skb2 && pskb_expand_head(skb2, SKB_DATA_ALIGN(delta), 0,
-					     GFP_ATOMIC)) {
+		if (unlikely(skb2 && pskb_expand_head(skb2,
+				SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC))) {
 			kfree_skb(skb2);
 			skb2 = NULL;
 		}
@@ -582,7 +577,7 @@
 	 */
 	struct sk_buff *n = alloc_skb(newheadroom + skb->len + newtailroom,
 				      gfp_mask);
-	if (!n)
+	if (unlikely(!n))
 		return NULL;
 
 	skb_reserve(n, newheadroom);
@@ -591,7 +586,7 @@
 	skb_put(n, skb->len);
 
 	/* Copy the data only. */
-	if (skb_copy_bits(skb, 0, n->data, skb->len))
+	if (unlikely(skb_copy_bits(skb, 0, n->data, skb->len)))
 		BUG();
 
 	copy_skb_header(n, skb);
@@ -625,7 +620,7 @@
 	
 	nskb = skb_copy_expand(skb, skb_headroom(skb), skb_tailroom(skb) + pad, GFP_ATOMIC);
 	kfree_skb(skb);
-	if (nskb)
+	if (likely(nskb))
 		memset(nskb->data+nskb->len, 0, pad);
 	return nskb;
 }	
@@ -645,9 +640,8 @@
 		int end = offset + skb_shinfo(skb)->frags[i].size;
 		if (end > len) {
 			if (skb_cloned(skb)) {
-				if (!realloc)
-					BUG();
-				if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				BUG_ON(!realloc);
+				if (unlikely(pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 					return -ENOMEM;
 			}
 			if (len <= offset) {
@@ -713,12 +707,12 @@
 	int i, k, eat = (skb->tail + delta) - skb->end;
 
 	if (eat > 0 || skb_cloned(skb)) {
-		if (pskb_expand_head(skb, 0, eat > 0 ? eat + 128 : 0,
-				     GFP_ATOMIC))
+		if (unlikely(pskb_expand_head(skb, 0, eat > 0 ? eat + 128 : 0,
+				     GFP_ATOMIC)))
 			return NULL;
 	}
 
-	if (skb_copy_bits(skb, skb_headlen(skb), skb->tail, delta))
+	if (unlikely(skb_copy_bits(skb, skb_headlen(skb), skb->tail, delta)))
 		BUG();
 
 	/* Optimization: no fragments, no reasons to preestimate
@@ -748,8 +742,7 @@
 		struct sk_buff *insp = NULL;
 
 		do {
-			if (!list)
-				BUG();
+			BUG_ON(!list);
 
 			if (list->len <= eat) {
 				/* Eaten as whole. */
@@ -762,7 +755,7 @@
 				if (skb_shared(list)) {
 					/* Sucks! We need to fork list. :-( */
 					clone = skb_clone(list, GFP_ATOMIC);
-					if (!clone)
+					if (unlikely(!clone))
 						return NULL;
 					insp = list->next;
 					list = clone;
@@ -771,7 +764,7 @@
 					 * problems. */
 					insp = list;
 				}
-				if (!pskb_pull(list, eat)) {
+				if (unlikely(!pskb_pull(list, eat))) {
 					if (clone)
 						kfree_skb(clone);
 					return NULL;
@@ -825,7 +818,7 @@
 	int i, copy;
 	int start = skb_headlen(skb);
 
-	if (offset > (int)skb->len - len)
+	if (unlikely(offset > (int)skb->len - len))
 		goto fault;
 
 	/* Copy header. */
@@ -877,8 +870,8 @@
 			if ((copy = end - offset) > 0) {
 				if (copy > len)
 					copy = len;
-				if (skb_copy_bits(list, offset - start,
-						  to, copy))
+				if (unlikely(skb_copy_bits(list, offset - start,
+						  to, copy)))
 					goto fault;
 				if ((len -= copy) == 0)
 					return 0;
@@ -888,7 +881,7 @@
 			start = end;
 		}
 	}
-	if (!len)
+	if (likely(!len))
 		return 0;
 
 fault:
@@ -965,8 +958,7 @@
 			start = end;
 		}
 	}
-	if (len)
-		BUG();
+	BUG_ON(len);
 
 	return csum;
 }
@@ -1048,8 +1040,7 @@
 			start = end;
 		}
 	}
-	if (len)
-		BUG();
+	BUG_ON(len);
 	return csum;
 }
 
@@ -1063,8 +1054,7 @@
 	else
 		csstart = skb_headlen(skb);
 
-	if (csstart > skb_headlen(skb))
-		BUG();
+	BUG_ON(csstart > skb_headlen(skb));
 
 	memcpy(to, skb->data, csstart);
 
