From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 07/11] net: introduce napi_alloc_skb_hint() for
 more use-cases
Date: Tue, 02 Feb 2016 22:13:57 +0100
Message-ID: <20160202211314.16315.70164.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbcBBVN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:13:59 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default bulk alloc size arbitrarily choosen (to be 8) might
not suit all use-cases, this introduce a function napi_alloc_skb_hint()
that allow the caller to specify a bulk size hint they are expecting.
It is a hint because __napi_alloc_skb() limits the bulk size to
the array size.

One user is the mlx5 driver, which bulk re-populate it's RX ring
with both SKBs and pages.  Thus, it would like to work with
bigger bulk alloc chunks.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/skbuff.h |   19 +++++++++++++++----
 net/core/skbuff.c      |    8 +++-----
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b06ba2e07c89..4d0c0eacbc34 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2391,14 +2391,25 @@ static inline void skb_free_frag(void *addr)
 	__free_page_frag(addr);
 }
 
+#define NAPI_SKB_CACHE_SIZE	64U /* Used in struct napi_alloc_cache */
+#define NAPI_SKB_BULK_ALLOC	 8U /* Default slab bulk alloc in NAPI */
+
 void *napi_alloc_frag(unsigned int fragsz);
-struct sk_buff *__napi_alloc_skb(struct napi_struct *napi,
-				 unsigned int length, gfp_t gfp_mask);
+struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
+				 unsigned int bulk_hint, gfp_t gfp_mask);
 static inline struct sk_buff *napi_alloc_skb(struct napi_struct *napi,
-					     unsigned int length)
+					     unsigned int len)
+{
+	return __napi_alloc_skb(napi, len, NAPI_SKB_BULK_ALLOC, GFP_ATOMIC);
+}
+static inline struct sk_buff *napi_alloc_skb_hint(struct napi_struct *napi,
+						  unsigned int len,
+						  unsigned int bulk_hint)
 {
-	return __napi_alloc_skb(napi, length, GFP_ATOMIC);
+	bulk_hint = bulk_hint ? : 1;
+	return __napi_alloc_skb(napi, len, bulk_hint, GFP_ATOMIC);
 }
+
 void napi_consume_skb(struct sk_buff *skb, int budget);
 
 void __kfree_skb_flush(void);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ae8cdbec90ee..f77209fb5361 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -347,8 +347,6 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 }
 EXPORT_SYMBOL(build_skb);
 
-#define NAPI_SKB_CACHE_SIZE	64
-
 struct napi_alloc_cache {
 	struct page_frag_cache page;
 	size_t skb_count;
@@ -480,9 +478,10 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
  *	%NULL is returned if there is no free memory.
  */
 struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
-				 gfp_t gfp_mask)
+				 unsigned int bulk_hint, gfp_t gfp_mask)
 {
 	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	unsigned int bulk_sz = min(bulk_hint, NAPI_SKB_CACHE_SIZE);
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	void *data;
@@ -507,10 +506,9 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	if (unlikely(!data))
 		return NULL;
 
-#define BULK_ALLOC_SIZE 8
 	if (!nc->skb_count) {
 		nc->skb_count = kmem_cache_alloc_bulk(skbuff_head_cache,
-						      gfp_mask, BULK_ALLOC_SIZE,
+						      gfp_mask, bulk_sz,
 						      nc->skb_cache);
 	}
 	if (likely(nc->skb_count)) {
