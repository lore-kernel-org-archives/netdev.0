From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 30 May 2014 13:11:41 +0100
Message-ID: <20140530121141.GA2655@zion.uk.xensource.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516131145.GK18551@zion.uk.xensource.com>
 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516143653.GL18551@zion.uk.xensource.com>
 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516153452.GM18551@zion.uk.xensource.com>
 <53763CD1.6060500@citrix.com>
 <53883C18.2050708@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:24275 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337AbaE3MLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 08:11:42 -0400
Content-Disposition: inline
In-Reply-To: <53883C18.2050708@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 10:06:48AM +0200, Stefan Bader wrote:
[...]
> I had been idly wondering about this onwards. And trying to understand the whole
> skb handling environment, I tried to come up with some idea as well. It may be
> totally stupid and using the wrong assumptions. It seems to work in the sense
> that things did not blow up into my face immediately and somehow I did not see
> dropped packages due to the number of slots either.
> But again, I am not sure I am doing the right thing. The idea was to just try to
> get rid of so many compound pages (which I believe are the only ones that can
> have an offset big enough to allow some alignment savings)...
> 
> -Stefan
> 

Thanks. I think the general idea is OK, but it still involves
unnecessary page allocation. We don't actually need to get rid of
compound page by replacing it with a new page, we just need to make sure
the data inside is aligned.

If you look at xennet_make_frags, it only grants the 4K page which
contains data. I presume a simple memove would be better than alloc_page
+ memcpy. What do you think?

Like:
   memmove(page_address(fpage), page_address(fpage)+offset, size);
   frag->page_offset = 0;

Wei.

> 
> From 8571b106643b32296e58526e2fbe97c330877ac8 Mon Sep 17 00:00:00 2001
> From: Stefan Bader <stefan.bader@canonical.com>
> Date: Thu, 29 May 2014 12:18:01 +0200
> Subject: [PATCH] xen-netfront: Align frags to fit max slots
> 
> In cases where the frags in a skb require more than MAX_SKB_FRAGS + 1
> (= 18) 4K pages of grant pages, try to reduce the footprint by moving
> the data to new pages and have it aligned to the beginning.
> Then replace the page in the frag and release the old one. This sure is
> more expensive in compute but should happen not too often and sounds
> better than to just drop the packet in that case.
> 
> Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
> ---
>  drivers/net/xen-netfront.c | 65 +++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 62 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 158b5e6..ad71e5c 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -544,6 +544,61 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
>  	return pages;
>  }
> 
> +/*
> + * Align data to new pages in order to save slots required to
> + * transmit this buffer.
> + * @skb - socket buffer
> + * @target - number of pages to save
> + * returns the number of pages the fragments have been reduced of
> + */
> +static int xennet_align_frags(struct sk_buff *skb, int target)
> +{
> +	int i, frags = skb_shinfo(skb)->nr_frags;
> +	int reduced = 0;
> +
> +	for (i = 0; i < frags; i++) {
> +		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
> +		struct page *fpage = skb_frag_page(frag);
> +		struct page *npage;
> +		unsigned long size;
> +		unsigned long offset;
> +		gfp_t gfp;
> +		int order;
> +
> +		if (!PageCompound(fpage))
> +			continue;
> +
> +		size = skb_frag_size(frag);
> +		offset = frag->page_offset & ~PAGE_MASK;
> +
> +		/*
> +		 * If the length of data in the last subpage of a compound
> +		 * page is smaller than the offset into the first data sub-
> +		 * page, we can save a subpage by copying data around.
> +		 */
> +		if ( ((offset + size) & ~PAGE_MASK) > offset )
> +			continue;
> +
> +		gfp = GFP_ATOMIC | __GFP_COLD;
> +		order = PFN_UP(size);
> +		if (order)
> +			gfp |= __GFP_COMP | __GFP_NOWARN;
> +
> +		npage = alloc_pages(gfp, order);
> +		if (!npage)
> +			break;
> +		memcpy(page_address(npage), skb_frag_address(frag), size);
> +		frag->page.p = npage;
> +		frag->page_offset = 0;
> +		put_page(fpage);
> +
> +		if (++reduced >= target)
> +			break;
> +	}
> +
> +	return reduced;
> +}
> +
>  static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	unsigned short id;
> @@ -573,9 +628,13 @@ static int xennet_start_xmit(struct sk_buff *skb, struct
> net_device *dev)
>  	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> -		net_alert_ratelimited(
> -			"xennet: skb rides the rocket: %d slots\n", slots);
> -		goto drop;
> +		slots -= xennet_align_frags(skb, slots - (MAX_SKB_FRAGS + 1));
> +		if (slots > MAX_SKB_FRAGS + 1) {
> +			net_alert_ratelimited(
> +				"xennet: skb rides the rocket: %d slots\n",
> +				slots);
> +			goto drop;
> +		}
>  	}
> 
>  	spin_lock_irqsave(&np->tx_lock, flags);
> -- 
> 1.9.1
> 
> 
> 
