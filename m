From: David Miller <davem@davemloft.net>
Subject: lockless pagecache Cassini regression
Date: Thu, 03 Jan 2008 19:32:45 -0800 (PST)
Message-ID: <20080103.193245.15134133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: npiggin@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753260AbYADDcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 22:32:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nick, I think the following changeset:

    commit fa4f0774d7c6cccb4d1fda76b91dd8eddcb2dd6a

    [CASSINI]: dont touch page_count
    
    Remove page refcount manipulations from cassini driver by using
    another field in struct page. Needed for lockless pagecache.
    
    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Broke the Cassini driver.

While it is true that, within the cassini driver, you converted
the counter bumps and tests accurately, this changeset does not
account for the page count bumps that are going to occur
in other contexts when the SKBs being constructed are freed
up (and thus the skb_frag_struct pages get liberated).

Basically what these drivers do is allocate a page, give it
to the network card, and the card decides how to chop up the
page based upon the size of arriving packets.  Therefore we
don't know ahead of time how many references to the page we
will generate while attaching bits of the page to receive
packet SKBs that get built.

As incoming packets are constructed by the card using chunks of these
system pages, it indicates in the descriptor which parts of which
pages were used.  We then use this to attach the page parts onto the
SKB.  Once the SKB is constructed it is passed up to the networking,
later on the SKB is freed and the page references are dropped by
kfree_skbmem().

And it is these page reference counts that the Cassini driver needs to
test to be correct, not the driver local ones we are now using.

I do something similar to what Cassini was doing in the NIU driver
(drivers/net/niu.c).  I think we need to restore Cassini to something
similar to what NIU is doing.

The only tricky bit is the page count checks, and frankly those can
just be transformed into references to compount_head(page)->_count or
similar.

Actually, page_count() does exactly that, it is implemented by
checking atomic_read(&compound_head(page)->_count) and thus I
think the best thing to do is revert your changes.

These pages are freshly allocated pages, not stuff in the page
cache or similar, so I think this is safe and the way to move
forward.

Also, these changes added lots of new atomics to the driver.
It's already doing get_page() etc. as needed.

What do you think Nick?

[CASSINI]: Revert 'dont touch page_count'.

This reverts changeset fa4f0774d7c6cccb4d1fda76b91dd8eddcb2dd6a
([CASSINI]: dont touch page_count) because it breaks the driver.

The local page counting added by this changeset did not account
for the asynchronous page count changes done by kfree_skb()
and friends.

The change adds extra atomics and on top of it all appears to be
totally unnecessary as well.

Signed-off-by: David S. Miller <davem@davemloft.net>

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
