From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/6]: [CASSINI]: Revert 'dont touch page_count'.
Date: Fri, 04 Jan 2008 00:33:30 -0800 (PST)
Message-ID: <20080104.003330.261312579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753808AbYADIvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Revert 'dont touch page_count'.

This reverts changeset fa4f0774d7c6cccb4d1fda76b91dd8eddcb2dd6a
([CASSINI]: dont touch page_count) because it breaks the driver.

The local page counting added by this changeset did not account
for the asynchronous page count changes done by kfree_skb()
and friends.

The change adds extra atomics and on top of it all appears to be
totally unnecessary as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |   36 ++++--------------------------------
 1 files changed, 4 insertions(+), 32 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 9030ca5..ff957f2 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -336,30 +336,6 @@ static inline void cas_mask_intr(struct cas *cp)
 		cas_disable_irq(cp, i);
 }
 
-static inline void cas_buffer_init(cas_page_t *cp)
-{
-	struct page *page = cp->buffer;
-	atomic_set((atomic_t *)&page->lru.next, 1);
-}
-
-static inline int cas_buffer_count(cas_page_t *cp)
-{
-	struct page *page = cp->buffer;
-	return atomic_read((atomic_t *)&page->lru.next);
-}
-
-static inline void cas_buffer_inc(cas_page_t *cp)
-{
-	struct page *page = cp->buffer;
-	atomic_inc((atomic_t *)&page->lru.next);
-}
-
-static inline void cas_buffer_dec(cas_page_t *cp)
-{
-	struct page *page = cp->buffer;
-	atomic_dec((atomic_t *)&page->lru.next);
-}
-
 static void cas_enable_irq(struct cas *cp, const int ring)
 {
 	if (ring == 0) { /* all but TX_DONE */
@@ -497,7 +473,6 @@ static int cas_page_free(struct cas *cp, cas_page_t *page)
 {
 	pci_unmap_page(cp->pdev, page->dma_addr, cp->page_size,
 		       PCI_DMA_FROMDEVICE);
-	cas_buffer_dec(page);
 	__free_pages(page->buffer, cp->page_order);
 	kfree(page);
 	return 0;
@@ -527,7 +502,6 @@ static cas_page_t *cas_page_alloc(struct cas *cp, const gfp_t flags)
 	page->buffer = alloc_pages(flags, cp->page_order);
 	if (!page->buffer)
 		goto page_err;
-	cas_buffer_init(page);
 	page->dma_addr = pci_map_page(cp->pdev, page->buffer, 0,
 				      cp->page_size, PCI_DMA_FROMDEVICE);
 	return page;
@@ -606,7 +580,7 @@ static void cas_spare_recover(struct cas *cp, const gfp_t flags)
 	list_for_each_safe(elem, tmp, &list) {
 		cas_page_t *page = list_entry(elem, cas_page_t, list);
 
-		if (cas_buffer_count(page) > 1)
+		if (page_count(page->buffer) > 1) 
 			continue;
 
 		list_del(elem);
@@ -1374,7 +1348,7 @@ static inline cas_page_t *cas_page_spare(struct cas *cp, const int index)
 	cas_page_t *page = cp->rx_pages[1][index];
 	cas_page_t *new;
 
-	if (cas_buffer_count(page) == 1)
+	if (page_count(page->buffer) == 1)
 		return page;
 
 	new = cas_page_dequeue(cp);
@@ -1394,7 +1368,7 @@ static cas_page_t *cas_page_swap(struct cas *cp, const int ring,
 	cas_page_t **page1 = cp->rx_pages[1];
 
 	/* swap if buffer is in use */
-	if (cas_buffer_count(page0[index]) > 1) {
+	if (page_count(page0[index]->buffer) > 1) {
 		cas_page_t *new = cas_page_spare(cp, index);
 		if (new) {
 			page1[index] = page0[index];
@@ -2066,7 +2040,6 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 		skb->len      += hlen - swivel;
 
 		get_page(page->buffer);
-		cas_buffer_inc(page);
 		frag->page = page->buffer;
 		frag->page_offset = off;
 		frag->size = hlen - swivel;
@@ -2091,7 +2064,6 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 			frag++;
 
 			get_page(page->buffer);
-			cas_buffer_inc(page);
 			frag->page = page->buffer;
 			frag->page_offset = 0;
 			frag->size = hlen;
@@ -2255,7 +2227,7 @@ static int cas_post_rxds_ringN(struct cas *cp, int ring, int num)
 	released = 0;
 	while (entry != last) {
 		/* make a new buffer if it's still in use */
-		if (cas_buffer_count(page[entry]) > 1) {
+		if (page_count(page[entry]->buffer) > 1) {
 			cas_page_t *new = cas_page_dequeue(cp);
 			if (!new) {
 				/* let the timer know that we need to
-- 
1.5.4.rc2.17.g257f

