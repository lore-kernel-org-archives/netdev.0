From: Prarit Bhargava <prarit@redhat.com>
Subject: [RFC PATCH]: Fix a warning in the niu driver
Date: Wed, 07 Jul 2010 19:59:41 -0400
Message-ID: <4C3514ED.2060904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392Ab0GHAAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 20:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an RFC to fix the mismatch compile warning in the niu driver.

drivers/net/niu.c: In function 'niu_process_rx_pkt':
drivers/net/niu.c:3490: warning: 'link' may be used uninitialized in this function

AFAICT, link is unused.  It is set in several places but never consumed by
any code.  Additionally, the value of page is unchecked in the functions that
call niu_find_rx_page().  This could lead to a NULL pointer.  However, in
both cases it seems like if !page then the rx ring is corrupt.  I *think* a
BUG() is appropriate, but one of you may have a better suggestion as to
what to do in that case.  Maybe leaving the while loops with a break?

Checking for !page is probably overkill -- maybe the fix is to just remove
link?

Any suggestions or advice is appreciated,

P.

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 961b9ea..8f2251d 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3353,19 +3353,17 @@ static unsigned int niu_hash_rxaddr(struct rx_ring_info *rp, u64 a)
 	return (a & (MAX_RBR_RING_SIZE - 1));
 }
 
-static struct page *niu_find_rxpage(struct rx_ring_info *rp, u64 addr,
-				    struct page ***link)
+static struct page *niu_find_rxpage(struct rx_ring_info *rp, u64 addr)
 {
 	unsigned int h = niu_hash_rxaddr(rp, addr);
-	struct page *p, **pp;
+	struct page *p = NULL;
+	struct page **pp;
 
 	addr &= PAGE_MASK;
 	pp = &rp->rxhash[h];
 	for (; (p = *pp) != NULL; pp = (struct page **) &p->mapping) {
-		if (p->index == addr) {
-			*link = pp;
+		if (p->index == addr)
 			break;
-		}
 	}
 
 	return p;
@@ -3441,7 +3439,7 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 
 	rp->rx_dropped++;
 	while (1) {
-		struct page *page, **link;
+		struct page *page;
 		u64 addr, val;
 		u32 rcr_size;
 
@@ -3450,12 +3448,12 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 		val = le64_to_cpup(&rp->rcr[index]);
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
-		page = niu_find_rxpage(rp, addr, &link);
+		page = niu_find_rxpage(rp, addr);
+		BUG_ON(!page); /* page cannot be NULL, rx_ring is corrupt */
 
 		rcr_size = rp->rbr_sizes[(val & RCR_ENTRY_PKTBUFSZ) >>
 					 RCR_ENTRY_PKTBUFSZ_SHIFT];
 		if ((page->index + PAGE_SIZE) - rcr_size == addr) {
-			*link = (struct page *) page->mapping;
 			np->ops->unmap_page(np->device, page->index,
 					    PAGE_SIZE, DMA_FROM_DEVICE);
 			page->index = 0;
@@ -3487,7 +3485,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 
 	num_rcr = 0;
 	while (1) {
-		struct page *page, **link = NULL;
+		struct page *page;
 		u32 rcr_size, append_size;
 		u64 addr, val, off;
 
@@ -3501,7 +3499,8 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
-		page = niu_find_rxpage(rp, addr, &link);
+		page = niu_find_rxpage(rp, addr);
+		BUG_ON(!page); /* page cannot be NULL, rx_ring is corrupt */
 
 		rcr_size = rp->rbr_sizes[(val & RCR_ENTRY_PKTBUFSZ) >>
 					 RCR_ENTRY_PKTBUFSZ_SHIFT];
@@ -3528,7 +3527,6 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 
 		niu_rx_skb_append(skb, page, off, append_size);
 		if ((page->index + rp->rbr_block_size) - rcr_size == addr) {
-			*link = (struct page *) page->mapping;
 			np->ops->unmap_page(np->device, page->index,
 					    PAGE_SIZE, DMA_FROM_DEVICE);
 			page->index = 0;

