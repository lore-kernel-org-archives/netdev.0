From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v6 1/6] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Thu, 16 Jan 2014 22:23:25 -0800
Message-ID: <1389939810-14998-2-git-send-email-mwdalton@google.com>
References: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:41795 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaAQGXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:23:39 -0500
Received: by mail-qe0-f73.google.com with SMTP id 5so331909qeb.4
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 22:23:38 -0800 (PST)
In-Reply-To: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_page_frag_refill currently permits only order-0 page allocs
unless GFP_WAIT is used. Change skb_page_frag_refill to attempt
higher-order page allocations whether or not GFP_WAIT is used. If
memory cannot be allocated, the allocator will fall back to
successively smaller page allocs (down to order-0 page allocs).

This change brings skb_page_frag_refill in line with the existing
page allocation strategy employed by netdev_alloc_frag, which attempts
higher-order page allocations whether or not GFP_WAIT is set, falling
back to successively lower-order page allocations on failure. Part
of migration of virtio-net to per-receive queue page frag allocators.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 net/core/sock.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 85ad6f0..b3f7ee3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1836,9 +1836,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
 		put_page(pfrag->page);
 	}
 
-	/* We restrict high order allocations to users that can afford to wait */
-	order = (prio & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
-
+	order = SKB_FRAG_PAGE_ORDER;
 	do {
 		gfp_t gfp = prio;
 
-- 
1.8.5.2
