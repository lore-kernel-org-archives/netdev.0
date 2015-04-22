From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: do not deplete pfmemalloc reserve
Date: Wed, 22 Apr 2015 07:33:36 -0700
Message-ID: <1429713216.18561.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
	 <20150320.132029.103306583158863864.davem@davemloft.net>
	 <550C5A98.5040305@akamai.com>
	 <20150324.021050.384709317309031128.davem@davemloft.net>
	 <55110009.4020706@akamai.com>
	 <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Greg Thelen <gthelen@google.com>,
	David Rientjes <rientjes@google.com>,
	Mel Gorman <mgorman@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33103 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933205AbbDVOdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 10:33:39 -0400
Received: by iecrt8 with SMTP id rt8so38634799iec.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 07:33:38 -0700 (PDT)
In-Reply-To: <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

build_skb() should look at the page pfmemalloc status.
If set, this means page allocator allocated this page in the
expectation it would help to free other pages. Networking
stack can do that only if skb->pfmemalloc is also set.

Also, we must refrain using high order pages from the pfmemalloc
reserve, so __page_frag_refill() must also use __GFP_NOMEMALLOC for
them. Under memory pressure, using order-0 pages is probably the best
strategy.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d1967dab9cc6..456ead534e10 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -311,7 +311,11 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
-	skb->head_frag = frag_size != 0;
+	if (frag_size) {
+		skb->head_frag = 1;
+		if (virt_to_head_page(data)->pfmemalloc)
+			skb->pfmemalloc = 1;
+	}
 	atomic_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
@@ -348,7 +352,8 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
 	gfp_t gfp = gfp_mask;
 
 	if (order) {
-		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
+		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
+			    __GFP_NOMEMALLOC;
 		page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
 		nc->frag.size = PAGE_SIZE << (page ? order : 0);
 	}
