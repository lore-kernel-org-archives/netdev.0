From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 13:51:50 +0000
Message-ID: <50AB990602000078000A9F5B@nat28.tlf.novell.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
 <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
 <1353418516.13542.38.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Stefan Bader" <stefan.bader@canonical.com>,
	"Sander Eikelenboom" <linux@eikelenboom.it>,
	"Eric Dumazet" <edumazet@google.com>,
	"KonradRzeszutek Wilk" <konrad@kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"ANNIE LI" <annie.li@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:56325 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab2KTNu4 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:8:1>);
	Tue, 20 Nov 2012 08:50:56 -0500
In-Reply-To: <1353418516.13542.38.camel@zakaz.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 20.11.12 at 14:35, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Tue, 2012-11-20 at 12:28 +0000, Jan Beulich wrote:
>> >>> On 20.11.12 at 12:40, Ian Campbell <ian.campbell@citrix.com> wrote:
>> > An SKB paged fragment can consist of a compound page with order > 0.
>> > However the netchannel protocol deals only in PAGE_SIZE frames.
>> > 
>> > Handle this in xennet_make_frags by iterating over the frames which
>> > make up the page.
>> > 
>> > This is the netfront equivalent to 6a8ed462f16b for netback.
>> 
>> Wouldn't you need to be at least a little more conservative here
>> with respect to resource use: I realize that get_id_from_freelist()
>> return values were never checked, and failure of
>> gnttab_claim_grant_reference() was always dealt with via
>> BUG_ON(), but considering that netfront_tx_slot_available()
>> doesn't account for compound page fragments, I think this (lack
>> of) error handling needs improvement in the course of the
>> change here (regardless of - I think - someone having said that
>> usually the sum of all pages referenced from an skb's fragments
>> would not exceed MAX_SKB_FRAGS - "usually" just isn't enough
>> imo).
> 
> I think it is more than "usually", it is derived from the number of
> pages needed to contain 64K of data which is the maximum size of the
> data associated with an skb (AIUI).
> 
> Unwinding from failure in xennet_make_frags looks pretty tricky,

Yes, I agree.

> but how about this incremental patch:

Looks good, but can probably be simplified quite a bit:

> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -505,6 +505,46 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
>  	np->tx.req_prod_pvt = prod;
>  }
>  
> +/*
> + * Count how many ring slots are required to send the frags of this
> + * skb. Each frag might be a compound page.
> + */
> +static int xennet_count_skb_frag_pages(struct sk_buff *skb)
> +{
> +	int i, frags = skb_shinfo(skb)->nr_frags;
> +	int pages = 0;
> +
> +	for (i = 0; i < frags; i++) {
> +		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
> +		unsigned long size = skb_frag_size(frag);
> +		unsigned long offset = frag->page_offset;
> +
> +		/* Skip unused frames from start of page */
> +		offset &= ~PAGE_MASK;
> +
> +		while (size > 0) {
> +			unsigned long bytes;
> +
> +			BUG_ON(offset >= PAGE_SIZE);
> +
> +			bytes = PAGE_SIZE - offset;
> +			if (bytes > size)
> +				bytes = size;
> +
> +			offset += bytes;
> +			size -= bytes;
> +
> +			/* Next frame */
> +			if (offset == PAGE_SIZE && size) {
> +				pages++;
> +				offset = 0;
> +			}
> +		}

Isn't the whole loop equivalent to 

		pages = PFN_UP(offset + size);

(at least as long as size is not zero)?

Plus I think the increment of pages would need to be pulled out
of the if() body.

> +	}
> +
> +	return pages;
> +}
> +
>  static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	unsigned short id;
> @@ -517,12 +557,13 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	grant_ref_t ref;
>  	unsigned long mfn;
>  	int notify;
> -	int frags = skb_shinfo(skb)->nr_frags;
> +	int frags;
>  	unsigned int offset = offset_in_page(data);
>  	unsigned int len = skb_headlen(skb);
>  	unsigned long flags;
>  
> -	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
> +	frags = xennet_count_skb_frag_pages(skb) +
> +		DIV_ROUND_UP(offset + len, PAGE_SIZE);
>  	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {

This condition would now need adjustment, though (because
"frags" is no longer what its name says).

Jan

>  		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
>  		       frags);
