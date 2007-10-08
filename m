From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-2.6.24] skbuff: change skb_frag_struct to scatterlist
Date: Mon, 08 Oct 2007 00:04:51 -0700 (PDT)
Message-ID: <20071008.000451.38691636.davem@davemloft.net>
References: <20071005174322.0a13c173@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58251
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752274AbXJHHE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 03:04:58 -0400
In-Reply-To: <20071005174322.0a13c173@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 17:43:22 -0700

> Replace the skb frag list with the common scatterlist definition.
> This allows device drivers to use dma_scatter/gather operations which
> may be faster on some platforms. As a side benefit, it is easier to
> handle dma mapping error unwind.
> 
> This idea came up long ago, just never got implemented.
> Reimplemented against net-2.6.24.  This version is for comment, not
> tested yet.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Thanks for keeping this idea alive.

But this isn't the hard part.  The issue is that skb->data is still
seperate, and as long as that's true DMA mapping error recovery is
still a complete mess because we still have to do two seperate DMA
mappings on transmit, one of which is conditional, instead of one call
which is easy to handle properly.

We could do something cute like have the packet building routines use
skb_shinfo(skb)->frags[1] and onward, and then right before
->hard_start_xmit() we fill in skb_shinfo(skb)->frags[0] with
virt_to_page(skb->data) etc.

No page refcount bumps on this magic first entry, in order for it to
be as near zero cost as possible.

Anyways, just one idea.
