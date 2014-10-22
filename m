From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] igb: don't reuse pages with pfmemalloc flag
Date: Wed, 22 Oct 2014 17:50:19 +0400
Message-ID: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <klamm@yandex-team.ru>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	davem@davemloft.net, sassmann@kpanic.de,
	gregkh@linuxfoundation.org, e1000-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0d4c897..6586392 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6178,6 +6178,9 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 	if (unlikely(page_to_nid(page) != numa_node_id()))
 		return false;
 
+	if (unlikely(page->pfmemalloc))
+		return false;
+
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
 	if (unlikely(page_count(page) != 1))
@@ -6245,7 +6248,8 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* we can reuse buffer as-is, just make sure it is local */
-		if (likely(page_to_nid(page) == numa_node_id()))
+		if (likely((page_to_nid(page) == numa_node_id()) &&
+			   !page->pfmemalloc))
 			return true;
 
 		/* this page cannot be reused so discard it */
-- 
1.9.3
