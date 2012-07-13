From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH] net: Update alloc frag to reduce get/put page usage and
	recycle pages
Date: Thu, 12 Jul 2012 17:23:50 -0700
Message-ID: <20120713001922.27393.1358.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, alexander.duyck@gmail.com,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8308 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab2GMAXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 20:23:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to help improve performance by reducing the number of
locked operations required to allocate a frag on x86 and other platforms.
This is accomplished by using atomic_set operations on the page count
instead of calling get_page and put_page.  It is based on work originally
provided by Eric Dumazet.

In addition it also helps to reduce memory overhead when using TCP.  This
is done by recycling the page if the only holder of the frame is the
netdev_alloc_frag call itself.  This can occur when skb heads are stolen by
either GRO or TCP and the driver providing the packets is using paged frags
to store all of the data for the packets.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Reverted back to something closer to the patch that Eric originally
    submitted.  The main goal in all this is to get the removal of expensive
    atomic ops and recycling added for now while Eric is still working on
    an approach that uses larger pages.

 net/core/skbuff.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 506f678..a757a2c 100644
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
@@ -317,17 +320,26 @@ void *netdev_alloc_frag(unsigned int fragsz)
 	if (unlikely(!nc->page)) {
 refill:
 		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		if (unlikely(!nc->page))
+			goto end;
+recycle:
+		atomic_set(&nc->page->_count, NETDEV_PAGECNT_BIAS);
+		nc->pagecnt_bias = NETDEV_PAGECNT_BIAS;
 		nc->offset = 0;
 	}
-	if (likely(nc->page)) {
-		if (nc->offset + fragsz > PAGE_SIZE) {
-			put_page(nc->page);
-			goto refill;
-		}
-		data = page_address(nc->page) + nc->offset;
-		nc->offset += fragsz;
-		get_page(nc->page);
+
+	if (nc->offset + fragsz > PAGE_SIZE) {
+		/* avoid unnecessary locked operations if possible */
+		if ((atomic_read(&nc->page->_count) == nc->pagecnt_bias) ||
+		    atomic_sub_and_test(nc->pagecnt_bias, &nc->page->_count))
+			goto recycle;
+		goto refill;
 	}
+
+	data = page_address(nc->page) + nc->offset;
+	nc->offset += fragsz;
+	nc->pagecnt_bias--;
+end:
 	local_irq_restore(flags);
 	return data;
 }
