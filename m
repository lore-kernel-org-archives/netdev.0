From: xiaohui.xin@intel.com
Subject: [RFC][PATCH v4 07/18] Make __alloc_skb() to get external buffer.
Date: Sun, 25 Apr 2010 17:19:54 +0800
Message-ID: <1272187206-18534-7-git-send-email-xiaohui.xin@intel.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-2-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-3-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-4-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-5-git-send-email-xiaohui.xin@intel.com>
 <1272187206-18534-6-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-6-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

Add a dev parameter to __alloc_skb(), skb->data
points to external buffer, recompute skb->head,
maintain shinfo of the external buffer, record
external buffer info into destructor_arg field.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---

	__alloc_skb() cleanup by

	Jeff Dike <jdike@linux.intel.com>

 include/linux/skbuff.h |    7 ++++---
 net/core/skbuff.c      |   43 +++++++++++++++++++++++++++++++++++++------
 2 files changed, 41 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 96799f5..8949b15 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -448,17 +448,18 @@ extern void kfree_skb(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int fclone,
+				   int node, struct net_device *dev);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	return __alloc_skb(size, priority, 0, -1, NULL);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, 1, -1, NULL);
 }
 
 extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6345acc..ae223d2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -161,7 +161,8 @@ EXPORT_SYMBOL(skb_under_panic);
  *	@fclone: allocate from fclone cache instead of head cache
  *		and allocate a cloned (child) skb
  *	@node: numa node to allocate memory on
- *
+ *	@dev: a device owns the skb if the skb try to get external buffer.
+ *		otherwise is NULL.
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
  *	tail room of size bytes. The object has a reference count of one.
  *	The return is the buffer. On a failure the return is %NULL.
@@ -170,12 +171,13 @@ EXPORT_SYMBOL(skb_under_panic);
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone, int node)
+			    int fclone, int node, struct net_device *dev)
 {
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
-	u8 *data;
+	u8 *data = NULL;
+	struct skb_external_page *ext_page = NULL;
 
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
@@ -185,8 +187,23 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
-			gfp_mask, node);
+
+	/* If the device wants to do mediate passthru(zero-copy),
+	 * the skb may try to get external buffers from outside.
+	 * If fails, then fall back to alloc buffers from kernel.
+	 */
+	if (dev && dev->mp_port) {
+		ext_page = netdev_alloc_external_page(dev, skb, size);
+		if (ext_page) {
+			data = ext_page->start;
+			size = ext_page->size;
+		}
+	}
+
+	if (!data)
+		data = kmalloc_node_track_caller(
+				size + sizeof(struct skb_shared_info),
+				gfp_mask, node);
 	if (!data)
 		goto nodata;
 
@@ -208,6 +225,15 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->mac_header = ~0U;
 #endif
 
+	/* If the skb get external buffers sucessfully, since the shinfo is
+	 * at the end of the buffer, we may retain the shinfo once we
+	 * need it sometime.
+	 */
+	if (ext_page) {
+		skb->head = skb->data - NET_IP_ALIGN - NET_SKB_PAD;
+		memcpy(ext_page->ushinfo, skb_shinfo(skb),
+		       sizeof(struct skb_shared_info));
+	}
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
 	atomic_set(&shinfo->dataref, 1);
@@ -231,6 +257,11 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 	}
+	/* Record the external buffer info in this field. It's not so good,
+	 * but we cannot find another place easily.
+	 */
+	shinfo->destructor_arg = ext_page;
+
 out:
 	return skb;
 nodata:
@@ -259,7 +290,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node, dev);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
-- 
1.5.4.4
