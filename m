From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 16:07:00 -0700 (PDT)
Message-ID: <20071005.160700.38700247.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750732AbXJEXHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:07:14 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> > +		BUG_ON(!page);
> 
> BUG_ON checks for NULL are useless if the code following is
> just going to dereference the pointer anyway. 

Agreed, all such cases fixed in the patch below, thanks!

> > +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> > +		tb = &rp->tx_buffs[idx];
> > +		BUG_ON(tb->skb != NULL);
> 
> > +		np->ops->unmap_page(np->device, tb->mapping,
> > +				    skb_shinfo(skb)->frags[i].size,
> > +				    DMA_TO_DEVICE);
> 
> Shouldn't this be skb_shinfo(tb->skb)->frags...

Nope, look at the logic, the assertion is making surethat
tb->skb == NULL.

When transmitting, the first descriptor holds the SKB pointer
and the rest of the descriptors for that packet explicitly
set the slots' SKB to NULL.

> > +		idx = NEXT_TX(rp, idx);
> > +	}
> > +
> > +	dev_kfree_skb(skb);
> 
> Should be dev_kfree_skb_any() if you plan on supporting
> netconsole.

I have no such plans at this time :-)

I think I've covered all of your feedback from this email,
thanks again for the review.

>From 418d57645f3132241eb180f9d381ef6541745e23 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 16:04:16 -0700
Subject: [PATCH] [NIU]: Remove BUG_ON() NULL pointer checks.

As mentioned by Stephen Hemminger, these are superfluous
if we are about to dereference the thing anyways.  The
OOPS has the same effect and will show the problem just
as clearly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 450d95e..c29235e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -2134,7 +2134,6 @@ static int niu_rx_pkt_ignore(struct niu *np, struct rx_ring_info *rp)
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
 		page = niu_find_rxpage(rp, addr, &link);
-		BUG_ON(!page);
 
 		rcr_size = rp->rbr_sizes[(val & RCR_ENTRY_PKTBUFSZ) >>
 					 RCR_ENTRY_PKTBUFSZ_SHIFT];
@@ -2185,7 +2184,6 @@ static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
 		addr = (val & RCR_ENTRY_PKT_BUF_ADDR) <<
 			RCR_ENTRY_PKT_BUF_ADDR_SHIFT;
 		page = niu_find_rxpage(rp, addr, &link);
-		BUG_ON(!page);
 
 		rcr_size = rp->rbr_sizes[(val & RCR_ENTRY_PKTBUFSZ) >>
 					 RCR_ENTRY_PKTBUFSZ_SHIFT];
@@ -2294,8 +2292,6 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 	u64 tx_flags;
 	int i, len;
 
-	BUG_ON(!skb);
-
 	tp = (struct tx_pkt_hdr *) skb->data;
 	tx_flags = le64_to_cpup(&tp->flags);
 
-- 
1.5.3.3

