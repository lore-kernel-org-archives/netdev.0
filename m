From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] net: add destructor for skb data.
Date: Sat, 5 Apr 2008 21:56:05 +1000
Message-ID: <200804052156.05318.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60853 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYDEL42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 07:56:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we want to notify something when an skb is truly finished (such as
for tun vringfd support), we need a destructor on the data.  We don't
need to add other fields, since we can just allocate extra room at the
end.

(I wonder if we could *reduce* the shinfo allocation where no frags are needed?)

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/skbuff.h |   29 ++++++++++++++++++++++++++---
 net/core/skbuff.c      |   12 +++++++++---
 2 files changed, 35 insertions(+), 6 deletions(-)

diff -r 77871c14566e include/linux/skbuff.h
--- a/include/linux/skbuff.h	Fri Mar 28 13:41:36 2008 +1100
+++ b/include/linux/skbuff.h	Mon Mar 31 23:01:58 2008 +1000
@@ -148,6 +148,7 @@ struct skb_shared_info {
 	__be32          ip6_frag_id;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
+	void		(*destructor)(struct skb_shared_info *);
 };
 
 /* We divide dataref into two halves.  The higher 16 bits hold references
@@ -344,17 +346,18 @@ extern void kfree_skb(struct sk_buff *sk
 extern void kfree_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int fclone, int node);
+				   gfp_t priority, int fclone, unsigned extra,
+				   int node);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	return __alloc_skb(size, priority, 0, 0, -1);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, 1, 0, -1);
 }
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
diff -r 77871c14566e net/core/skbuff.c
--- a/net/core/skbuff.c	Fri Mar 28 13:41:36 2008 +1100
+++ b/net/core/skbuff.c	Mon Mar 31 23:01:58 2008 +1000
@@ -169,6 +169,7 @@ EXPORT_SYMBOL(skb_truesize_bug);
  *	@gfp_mask: allocation mask
  *	@fclone: allocate from fclone cache instead of head cache
  *		and allocate a cloned (child) skb
+ *	@extra: extra bytes at end of shinfo.
  *	@node: numa node to allocate memory on
  *
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
@@ -179,7 +180,7 @@ EXPORT_SYMBOL(skb_truesize_bug);
  *	%GFP_ATOMIC.
  */
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
-			    int fclone, int node)
+			    int fclone, unsigned extra, int node)
 {
 	struct kmem_cache *cache;
 	struct skb_shared_info *shinfo;
@@ -194,7 +195,8 @@ struct sk_buff *__alloc_skb(unsigned int
 		goto out;
 
 	size = SKB_DATA_ALIGN(size);
-	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
+	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info)
+					 + extra,
 			gfp_mask, node);
 	if (!data)
 		goto nodata;
@@ -218,6 +220,7 @@ struct sk_buff *__alloc_skb(unsigned int
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->destructor = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -255,7 +258,7 @@ struct sk_buff *__netdev_alloc_skb(struc
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, 0, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -302,6 +305,9 @@ static void skb_release_data(struct sk_b
 
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
+
+		if (skb_shinfo(skb)->destructor)
+			skb_shinfo(skb)->destructor(skb_shinfo(skb));
 
 		kfree(skb->head);
 	}
