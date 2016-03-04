From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/7] net: bulk alloc and reuse of SKBs in NAPI
 context
Date: Fri, 04 Mar 2016 14:01:43 +0100
Message-ID: <20160304130143.32651.33813.stgit@firesoul>
References: <20160304130054.32651.51776.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387AbcCDNBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 08:01:48 -0500
In-Reply-To: <20160304130054.32651.51776.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduce bulk alloc of SKBs and allow reuse of SKBs
free'ed in same softirq cycle.  SKBs are normally free'ed during TX
completion, but most high speed drivers also cleanup TX ring during
NAPI RX poll cycle.  Thus, if using napi_consume_skb/__kfree_skb_defer,
SKBs will be avail in the napi_alloc_cache->skb_cache.

If no SKBs are avail for reuse, then only bulk alloc 8 SKBs, to limit
the potential overshooting unused SKBs needed to free'ed when NAPI
cycle ends (flushed in net_rx_action via __kfree_skb_flush()).

Generalize ___build_skb() to allow passing it a preallocated SKB.

I've previously demonstrated a 1% speedup for IPv4 forwarding, when
used on the ixgbe driver.  If SKB alloc and free happens on different
CPUs (like in RPS use-case) the performance benefit is expected to
increase.

All drivers using the napi_alloc_skb() call will benefit from
this change automatically.

Joint work with Alexander Duyck.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/core/skbuff.c |   71 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 45 insertions(+), 26 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7af7ec635d90..96fb7933b614 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -281,32 +281,14 @@ nodata:
 }
 EXPORT_SYMBOL(__alloc_skb);
 
-/**
- * __build_skb - build a network buffer
- * @data: data buffer provided by caller
- * @frag_size: size of data, or 0 if head was kmalloced
- *
- * Allocate a new &sk_buff. Caller provides space holding head and
- * skb_shared_info. @data must have been allocated by kmalloc() only if
- * @frag_size is 0, otherwise data should come from the page allocator
- *  or vmalloc()
- * The return is the new skb buffer.
- * On a failure the return is %NULL, and @data is not freed.
- * Notes :
- *  Before IO, driver allocates only data buffer where NIC put incoming frame
- *  Driver should add room at head (NET_SKB_PAD) and
- *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
- *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
- *  before giving packet to stack.
- *  RX rings only contains data buffers, not full skbs.
- */
-struct sk_buff *__build_skb(void *data, unsigned int frag_size)
+/* Allows skb being (pre)allocated by caller */
+static inline
+struct sk_buff *___build_skb(void *data, unsigned int frag_size,
+			     struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo;
-	struct sk_buff *skb;
 	unsigned int size = frag_size ? : ksize(data);
 
-	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
 	if (!skb)
 		return NULL;
 
@@ -331,6 +313,34 @@ struct sk_buff *__build_skb(void *data, unsigned int frag_size)
 	return skb;
 }
 
+/**
+ * __build_skb - build a network buffer
+ * @data: data buffer provided by caller
+ * @frag_size: size of data, or 0 if head was kmalloced
+ *
+ * Allocate a new &sk_buff. Caller provides space holding head and
+ * skb_shared_info. @data must have been allocated by kmalloc() only if
+ * @frag_size is 0, otherwise data should come from the page allocator
+ *  or vmalloc()
+ * The return is the new skb buffer.
+ * On a failure the return is %NULL, and @data is not freed.
+ * Notes :
+ *  Before IO, driver allocates only data buffer where NIC put incoming frame
+ *  Driver should add room at head (NET_SKB_PAD) and
+ *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
+ *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
+ *  before giving packet to stack.
+ *  RX rings only contains data buffers, not full skbs.
+ */
+struct sk_buff *__build_skb(void *data, unsigned int frag_size)
+{
+	struct sk_buff *skb;
+	unsigned int size = frag_size ? : ksize(data);
+
+	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	return ___build_skb(data, size, skb);
+}
+
 /* build_skb() is wrapper over __build_skb(), that specifically
  * takes care of skb->head and skb->pfmemalloc
  * This means that if @frag_size is not zero, then @data must be backed
@@ -490,8 +500,8 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 
 	len += NET_SKB_PAD + NET_IP_ALIGN;
 
-	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
-	    (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
+	if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
+		     (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA)))) {
 		skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
 		if (!skb)
 			goto skb_fail;
@@ -508,11 +518,20 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	if (unlikely(!data))
 		return NULL;
 
-	skb = __build_skb(data, len);
-	if (unlikely(!skb)) {
+#define BULK_ALLOC_SIZE 8
+	if (!nc->skb_count) {
+		nc->skb_count = kmem_cache_alloc_bulk(skbuff_head_cache,
+						      gfp_mask, BULK_ALLOC_SIZE,
+						      nc->skb_cache);
+	}
+	if (likely(nc->skb_count)) {
+		skb = (struct sk_buff *)nc->skb_cache[--nc->skb_count];
+	} else {
+		/* alloc bulk failed */
 		skb_free_frag(data);
 		return NULL;
 	}
+	skb = ___build_skb(data, len, skb);
 
 	/* use OR instead of assignment to avoid clearing of bits in mask */
 	if (nc->page.pfmemalloc)
