From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] igb: don't reuse pages with pfmemalloc flag
Date: Thu, 30 Oct 2014 05:33:54 -0700
Message-ID: <1414672436-20616-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Roman Gushchin <klamm@yandex-team.ru>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19001 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932774AbaJ3Md7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 08:33:59 -0400
In-Reply-To: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Gushchin <klamm@yandex-team.ru>

Incoming packet is dropped silently by sk_filter(), if the skb was
allocated from pfmemalloc reserves and the corresponding socket is
not marked with the SOCK_MEMALLOC flag.

Igb driver allocates pages for DMA with __skb_alloc_page(), which
calls alloc_pages_node() with the __GFP_MEMALLOC flag. So, in case
of OOM condition, igb can get pages with pfmemalloc flag set.

If an incoming packet hits the pfmemalloc page and is large enough
(small packets are copying into the memory, allocated with
netdev_alloc_skb_ip_align(), so they are not affected), it will be
dropped.

This behavior is ok under high memory pressure, but the problem is
that the igb driver reuses these mapped pages. So, packets are still
dropping even if all memory issues are gone and there is a plenty
of free memory.

In my case, some TCP sessions hang on a small percentage (< 0.1%)
of machines days after OOMs.

Fix this by avoiding reuse of such pages.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Tested-by: Aaron Brown "aaron.f.brown@intel.com"
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a21b144..a2d72a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6537,6 +6537,9 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 	if (unlikely(page_to_nid(page) != numa_node_id()))
 		return false;
 
+	if (unlikely(page->pfmemalloc))
+		return false;
+
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
 	if (unlikely(page_count(page) != 1))
@@ -6603,7 +6606,8 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* we can reuse buffer as-is, just make sure it is local */
-		if (likely(page_to_nid(page) == numa_node_id()))
+		if (likely((page_to_nid(page) == numa_node_id()) &&
+			   !page->pfmemalloc))
 			return true;
 
 		/* this page cannot be reused so discard it */
-- 
1.9.3
