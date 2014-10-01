From: Prashant <prashant@broadcom.com>
Subject: Re: [PATCH net v6 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 30 Sep 2014 20:14:57 -0700
Message-ID: <542B71B1.4020103@broadcom.com>
References: <1409960135.18724.33.camel@prashant>	<1409961810.26422.149.camel@edumazet-glaptop2.roam.corp.google.com>	<20140905.171306.1460013939580748402.davem@davemloft.net> <20140905.213902.1124686922505260665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <bpoirier@suse.de>, <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140905.213902.1124686922505260665.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 9/5/2014 9:39 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 05 Sep 2014 17:13:06 -0700 (PDT)
>
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 05 Sep 2014 17:03:30 -0700
>>
>>> Instead of this private helper (and pretty limited one btw), we could
>>> add a core function, that would build skbs with order-0 fragments.
>>>
>>> Instead of skb_linearize(), I guess many call sites could instead use
>>> this new helper.
>>>
>>> Because as you said, skb_linearize() of one 64KB GSO packet can ask
>>> order-5 allocations, and this generally does not work reliably.
>>
>> xen-netback could make use of this helper too.
>
> I was curious what it might look like so I cobbled the following
> completely untested patch together :-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index da1378a..eba0ad6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -955,6 +955,67 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
>   EXPORT_SYMBOL(skb_copy);
>
>   /**
> + *	skb_copy_pskb	-	copy sk_buff into a paged skb
> + *	@oskb: buffer to copy
> + *	@gfp_mask: allocation priority
> + *
> + *	Normalize a paged skb into one that maximally uses order
> + *	zero pages in it's fragment array.  This is used to canonicalize
> + *	spaghetti SKBs that use the page array inefficiently (f.e. only
> + *	one byte per page frag).
> + */
> +
> +struct sk_buff *skb_copy_pskb(const struct sk_buff *oskb, gfp_t gfp_mask)
> +{
> +	unsigned int data_len = oskb->data_len;
> +	int offset, npages, i;
> +	struct sk_buff *skb;
> +
> +	npages = (data_len + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
> +	if (npages > MAX_SKB_FRAGS)
> +		return NULL;
> +
> +	skb = __alloc_skb(skb_end_offset(oskb), gfp_mask,
> +			  skb_alloc_rx_flag(oskb), NUMA_NO_NODE);
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, skb_headroom(oskb));
> +	skb_put(skb, skb_headlen(oskb));
> +	skb_copy_from_linear_data(oskb, skb->data, skb->len);
> +
> +	copy_skb_header(skb, oskb);
> +
> +	skb->truesize += data_len;
> +	offset = skb_headlen(oskb);
> +	for (i = 0; i < npages; i++) {
> +		struct page *page = alloc_page(gfp_mask);
> +		unsigned int chunk;
> +		u8 *vaddr;
> +
> +		if (!page) {
> +			kfree(skb);
> +			skb = NULL;
> +			break;
> +		}
> +
> +		chunk = min_t(unsigned int, data_len, PAGE_SIZE);
> +		skb_fill_page_desc(skb, i, page, 0, chunk);
> +
> +		vaddr = kmap_atomic(page);
> +		skb_copy_bits(oskb, offset, vaddr, chunk);
> +		kunmap_atomic(vaddr);
> +
> +		offset += chunk;
> +		data_len -= chunk;
> +		skb->data_len += chunk;
> +	}
> +
> +	return skb;
> +}
> +EXPORT_SYMBOL(skb_copy_pskb);
> +
> +/**
>    *	__pskb_copy_fclone	-  create copy of an sk_buff with private head.
>    *	@skb: buffer to copy
>    *	@headroom: headroom of new skb
>
Sorry about the late reply, out of all the HW bug conditions checked in 
tg3_tx_frag_set() the most frequently hit condition is the short 8 byte 
dma bug, where the chip cannot handle TX descriptors whose data buffer 
is 8 bytes or less. Most of the LSO skb's given to the driver has their 
fragments filled upto PAGE_SIZE (expect the last fragment depending on 
skb->len). And if such a LSO skb's last fragment meets the 8 bytes HW 
bug condition the above routine will not help workaround this particular 
case.
