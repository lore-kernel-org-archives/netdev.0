From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: build bug on kfree(struct sk_buff*)
Date: Sun, 15 Mar 2009 17:42:07 +0100
Message-ID: <49BD2FDF.5050504@gmail.com>
References: <49BA8710.20808@gmail.com> <49BAE95D.7060001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:55288 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbZCOQmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 12:42:09 -0400
In-Reply-To: <49BAE95D.7060001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that my initial attempt was invalid. The one below appears to be
correct, although I am not sure whether there is a better implementation.

this patch also fixes a kfree(skb) in net/core/dev.c, what do you think?

Roel

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 include/linux/kernel.h |    4 ++++
 include/linux/slab.h   |    3 +++
 mm/slab.c              |    2 ++
 mm/slob.c              |    2 ++
 mm/slub.c              |    2 ++
 net/core/dev.c         |    2 +-
 6 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 7fa3718..b7f22d8 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -526,6 +526,10 @@ struct sysinfo {
    aren't permitted). */
 #define BUILD_BUG_ON_ZERO(e) (sizeof(char[1 - 2 * !!(e)]) - 1)
 
+/* If the type of x is TYPE, force a compilation error, otherwise produce x */
+#define BUILD_BUG_ON_TYPE(x, TYPE) __builtin_choose_expr(		\
+		__builtin_types_compatible_p(typeof(x), TYPE), (void)0, (x))
+
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 24c5602..30c28f9 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -130,6 +130,9 @@ void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);
 
+/* This ensures that kfree is not called with a struct sk_buff* */
+#define kfree(x) kfree(BUILD_BUG_ON_TYPE(x, struct sk_buff*))
+
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
  * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
diff --git a/mm/slab.c b/mm/slab.c
index 4d00855..cbcd28a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3711,6 +3711,7 @@ EXPORT_SYMBOL(kmem_cache_free);
  * Don't free memory not originally allocated by kmalloc()
  * or you will run into trouble.
  */
+#undef kfree
 void kfree(const void *objp)
 {
 	struct kmem_cache *c;
@@ -3727,6 +3728,7 @@ void kfree(const void *objp)
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(kfree);
+#define kfree(x) kfree(BUILD_BUG_ON_TYPE(x, struct sk_buff*))
 
 unsigned int kmem_cache_size(struct kmem_cache *cachep)
 {
diff --git a/mm/slob.c b/mm/slob.c
index 52bc8a2..451325c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -487,6 +487,7 @@ void *__kmalloc_node(size_t size, gfp_t gfp, int node)
 }
 EXPORT_SYMBOL(__kmalloc_node);
 
+#undef kfree
 void kfree(const void *block)
 {
 	struct slob_page *sp;
@@ -503,6 +504,7 @@ void kfree(const void *block)
 		put_page(&sp->page);
 }
 EXPORT_SYMBOL(kfree);
+#define kfree(x) kfree(BUILD_BUG_ON_TYPE(x, struct sk_buff*))
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
 size_t ksize(const void *block)
diff --git a/mm/slub.c b/mm/slub.c
index 0280eee..41943fc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2738,6 +2738,7 @@ size_t ksize(const void *object)
 }
 EXPORT_SYMBOL(ksize);
 
+#undef kfree
 void kfree(const void *x)
 {
 	struct page *page;
@@ -2755,6 +2756,7 @@ void kfree(const void *x)
 	slab_free(page->slab, page, object, _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);
+#define kfree(x) kfree(BUILD_BUG_ON_TYPE(x, struct sk_buff*))
 
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
diff --git a/net/core/dev.c b/net/core/dev.c
index f112970..c1e9dc0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2671,7 +2671,7 @@ void netif_napi_del(struct napi_struct *napi)
 	struct sk_buff *skb, *next;
 
 	list_del_init(&napi->dev_list);
-	kfree(napi->skb);
+	kfree_skb(napi->skb);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;

