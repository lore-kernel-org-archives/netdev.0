From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: attempt a single high order allocation
Date: Wed, 27 Aug 2014 20:49:34 -0700
Message-ID: <1409197774.3173.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409154398.3173.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Rientjes <rientjes@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57488 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419AbaH1Dtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 23:49:35 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so761900pab.15
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 20:49:35 -0700 (PDT)
In-Reply-To: <1409154398.3173.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit ed98df3361f0 ("net: use __GFP_NORETRY for high order
allocations") we tried to address one issue caused by order-3
allocations.

We still observe high latencies and system overhead in situations where
compaction is not successful.

Instead of trying order-3, order-2, and order-1, do a single order-3
best effort and immediately fallback to plain order-0.

This mimics slub strategy to fallback to slab min order if the high
order allocation used for performance failed.

Order-3 allocations give a performance boost only if they can be done
without recurring and expensive memory scan.

Quoting David :

The page allocator relies on synchronous (sync light) memory compaction
after direct reclaim for allocations that don't retry and deferred
compaction doesn't work with this strategy because the allocation order
is always decreasing from the previous failed attempt.

This means sync light compaction will always be encountered if memory
cannot be defragmented or reclaimed several times during the
skb_page_frag_refill() iteration.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 net/core/sock.c |   30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2714811afbd8..29870571c42f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1822,6 +1822,9 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 							   order);
 					if (page)
 						goto fill_page;
+					/* Do not retry other high order allocations */
+					order = 1;
+					max_page_order = 0;
 				}
 				order--;
 			}
@@ -1869,10 +1872,8 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
  * no guarantee that allocations succeed. Therefore, @sz MUST be
  * less or equal than PAGE_SIZE.
  */
-bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
+bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 {
-	int order;
-
 	if (pfrag->page) {
 		if (atomic_read(&pfrag->page->_count) == 1) {
 			pfrag->offset = 0;
@@ -1883,20 +1884,21 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
 		put_page(pfrag->page);
 	}
 
-	order = SKB_FRAG_PAGE_ORDER;
-	do {
-		gfp_t gfp = prio;
-
-		if (order)
-			gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
-		pfrag->page = alloc_pages(gfp, order);
+	pfrag->offset = 0;
+	if (SKB_FRAG_PAGE_ORDER) {
+		pfrag->page = alloc_pages(gfp | __GFP_COMP |
+					  __GFP_NOWARN | __GFP_NORETRY,
+					  SKB_FRAG_PAGE_ORDER);
 		if (likely(pfrag->page)) {
-			pfrag->offset = 0;
-			pfrag->size = PAGE_SIZE << order;
+			pfrag->size = PAGE_SIZE << SKB_FRAG_PAGE_ORDER;
 			return true;
 		}
-	} while (--order >= 0);
-
+	}
+	pfrag->page = alloc_page(gfp);
+	if (likely(pfrag->page)) {
+		pfrag->size = PAGE_SIZE;
+		return true;
+	}
 	return false;
 }
 EXPORT_SYMBOL(skb_page_frag_refill);
