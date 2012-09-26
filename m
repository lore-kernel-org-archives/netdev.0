From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] net: use bigger pages in __netdev_alloc_frag
Date: Wed, 26 Sep 2012 18:46:57 +0200
Message-ID: <1348678017.5093.371.camel@edumazet-glaptop>
References: <1348650402.5093.176.camel@edumazet-glaptop>
	 <50632681.40208@intel.com> <1348676085.5093.361.camel@edumazet-glaptop>
	 <50632F06.1040306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34513 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757044Ab2IZQrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 12:47:01 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so461750bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 09:47:01 -0700 (PDT)
In-Reply-To: <50632F06.1040306@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We currently use percpu order-0 pages in __netdev_alloc_frag
to deliver fragments used by __netdev_alloc_skb()

Depending on NIC driver and arch being 32 or 64 bit, it allows a page to
be split in several fragments (between 1 and 8), assuming PAGE_SIZE=4096

Switching to bigger pages (32768 bytes for PAGE_SIZE=4096 case) allows :

- Better filling of space (the ending hole overhead is less an issue)

- Less calls to page allocator or accesses to page->_count

- Could allow struct skb_shared_info futures changes without major
  performance impact.

This patch implements a transparent fallback to smaller
pages in case of memory pressure.

It also uses a standard "struct page_frag" instead of a custom one.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
---
v2 : fix the (--order <= 0) test, as Benjamin pointed out

 net/core/skbuff.c |   46 ++++++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2ede3cf..607a70f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -340,43 +340,57 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 EXPORT_SYMBOL(build_skb);
 
 struct netdev_alloc_cache {
-	struct page *page;
-	unsigned int offset;
-	unsigned int pagecnt_bias;
+	struct page_frag	frag;
+	/* we maintain a pagecount bias, so that we dont dirty cache line
+	 * containing page->_count every time we allocate a fragment.
+	 */
+	unsigned int		pagecnt_bias;
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
-#define NETDEV_PAGECNT_BIAS (PAGE_SIZE / SMP_CACHE_BYTES)
+#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
+#define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 {
 	struct netdev_alloc_cache *nc;
 	void *data = NULL;
+	int order;
 	unsigned long flags;
 
 	local_irq_save(flags);
 	nc = &__get_cpu_var(netdev_alloc_cache);
-	if (unlikely(!nc->page)) {
+	if (unlikely(!nc->frag.page)) {
 refill:
-		nc->page = alloc_page(gfp_mask);
-		if (unlikely(!nc->page))
-			goto end;
+		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
+			gfp_t gfp = gfp_mask;
+
+			if (order)
+				gfp |= __GFP_COMP | __GFP_NOWARN;
+			nc->frag.page = alloc_pages(gfp, order);
+			if (likely(nc->frag.page))
+				break;
+			if (--order < 0)
+				goto end;
+		}
+		nc->frag.size = PAGE_SIZE << order;
 recycle:
-		atomic_set(&nc->page->_count, NETDEV_PAGECNT_BIAS);
-		nc->pagecnt_bias = NETDEV_PAGECNT_BIAS;
-		nc->offset = 0;
+		atomic_set(&nc->frag.page->_count, NETDEV_PAGECNT_MAX_BIAS);
+		nc->pagecnt_bias = NETDEV_PAGECNT_MAX_BIAS;
+		nc->frag.offset = 0;
 	}
 
-	if (nc->offset + fragsz > PAGE_SIZE) {
+	if (nc->frag.offset + fragsz > nc->frag.size) {
 		/* avoid unnecessary locked operations if possible */
-		if ((atomic_read(&nc->page->_count) == nc->pagecnt_bias) ||
-		    atomic_sub_and_test(nc->pagecnt_bias, &nc->page->_count))
+		if ((atomic_read(&nc->frag.page->_count) == nc->pagecnt_bias) ||
+		    atomic_sub_and_test(nc->pagecnt_bias, &nc->frag.page->_count))
 			goto recycle;
 		goto refill;
 	}
 
-	data = page_address(nc->page) + nc->offset;
-	nc->offset += fragsz;
+	data = page_address(nc->frag.page) + nc->frag.offset;
+	nc->frag.offset += fragsz;
 	nc->pagecnt_bias--;
 end:
 	local_irq_restore(flags);
