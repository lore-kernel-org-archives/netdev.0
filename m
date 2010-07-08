From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]: Fix a warning in the niu driver
Date: Wed, 07 Jul 2010 17:08:20 -0700 (PDT)
Message-ID: <20100707.170820.146356362.davem@davemloft.net>
References: <4C3514ED.2060904@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756105Ab0GHAIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 20:08:09 -0400
In-Reply-To: <4C3514ED.2060904@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 07 Jul 2010 19:59:41 -0400

> This is an RFC to fix the mismatch compile warning in the niu driver.
> 
> drivers/net/niu.c: In function 'niu_process_rx_pkt':
> drivers/net/niu.c:3490: warning: 'link' may be used uninitialized in this function
> 
> AFAICT, link is unused.  It is set in several places but never consumed by
> any code.  Additionally, the value of page is unchecked in the functions that
> call niu_find_rx_page().  This could lead to a NULL pointer.  However, in
> both cases it seems like if !page then the rx ring is corrupt.  I *think* a
> BUG() is appropriate, but one of you may have a better suggestion as to
> what to do in that case.  Maybe leaving the while loops with a break?
> 
> Checking for !page is probably overkill -- maybe the fix is to just remove
> link?
> 
> Any suggestions or advice is appreciated,

You completely removed the unlinking of the page from the hash chain
list.

That's the side effect you're missing.

niu_rx_pkt_ignore() {
 ...
		page = niu_find_rxpage(rp, addr, &link);
 ...
			*link = (struct page *) page->mapping;
 ...
}

niu_process_rx_pkt() {
 ...
		page = niu_find_rxpage(rp, addr, &link);
 ...
			*link = (struct page *) page->mapping;
 ...
}

Your patch would corrupt the list state, since we'd leave
pages in the rx page hash which have only externally references
and thus will be freed up.

Just BUG() if the loop terminates without finding a page.

--------------------
niu: BUG on inability to find page in rx page hashes.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 3d523cb..5d36531 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3330,10 +3330,12 @@ static struct page *niu_find_rxpage(struct rx_ring_info *rp, u64 addr,
 	for (; (p = *pp) != NULL; pp = (struct page **) &p->mapping) {
 		if (p->index == addr) {
 			*link = pp;
-			break;
+			goto found;
 		}
 	}
+	BUG();
 
+found:
 	return p;
 }
 
@@ -3417,7 +3419,6 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
 		page = niu_find_rxpage(rp, addr, &link);
-
 		rcr_size = rp->rbr_sizes[(val & RCR_ENTRY_PKTBUFSZ) >>
 					 RCR_ENTRY_PKTBUFSZ_SHIFT];
 		if ((page->index + PAGE_SIZE) - rcr_size == addr) {
