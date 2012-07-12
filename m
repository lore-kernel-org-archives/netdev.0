From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 2/2] net: Update alloc frag to reduce get/put page usage and
	recycle pages
Date: Wed, 11 Jul 2012 17:18:10 -0700
Message-ID: <20120712001810.26542.61967.stgit@gitlad.jf.intel.com>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.duyck@gmail.com, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17193 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030530Ab2GLARt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 20:17:49 -0400
In-Reply-To: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does several things.

First it reorders the netdev_alloc_frag code so that only one conditional
check is needed in most cases instead of 2.

Second it incorporates the atomic_set and atomic_sub_return logic from an
earlier proposed patch by Eric Dumazet allowing for a reduction in the
get_page/put_page overhead when dealing with frags.

Finally it also incorporates the page reuse code so that if the page count
is dropped to 0 we can just reinitialize the page and reuse it.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/skbuff.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 506f678..69f4add 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -296,9 +296,12 @@ EXPORT_SYMBOL(build_skb);
 struct netdev_alloc_cache {
 	struct page *page;
 	unsigned int offset;
+	unsigned int pagecnt_bias;
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
+#define NETDEV_PAGECNT_BIAS (PAGE_SIZE / SMP_CACHE_BYTES)
+
 /**
  * netdev_alloc_frag - allocate a page fragment
  * @fragsz: fragment size
@@ -311,23 +314,33 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	struct netdev_alloc_cache *nc;
 	void *data = NULL;
 	unsigned long flags;
+	unsigned int offset;
 
 	local_irq_save(flags);
 	nc = &__get_cpu_var(netdev_alloc_cache);
-	if (unlikely(!nc->page)) {
-refill:
+	offset = nc->offset;
+	if (unlikely(offset < fragsz)) {
+		BUG_ON(PAGE_SIZE < fragsz);
+
+		if (likely(nc->page) &&
+		    atomic_sub_and_test(nc->pagecnt_bias, &nc->page->_count))
+			goto recycle;
+
 		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
-		nc->offset = 0;
-	}
-	if (likely(nc->page)) {
-		if (nc->offset + fragsz > PAGE_SIZE) {
-			put_page(nc->page);
-			goto refill;
+		if (unlikely(!nc->page)) {
+			offset = 0;
+			goto end;
 		}
-		data = page_address(nc->page) + nc->offset;
-		nc->offset += fragsz;
-		get_page(nc->page);
-	}
+recycle:
+		atomic_set(&nc->page->_count, NETDEV_PAGECNT_BIAS);
+		nc->pagecnt_bias = NETDEV_PAGECNT_BIAS;
+		offset = PAGE_SIZE;
+	}
+	offset -= fragsz;
+	nc->pagecnt_bias--;
+	data = page_address(nc->page) + offset;
+end:
+	nc->offset = offset;
 	local_irq_restore(flags);
 	return data;
 }
