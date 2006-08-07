From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 10:05:57 +0200
Message-ID: <200608071005.57517.dada1@cosmosbay.com>
References: <20060807060155.GA6487@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:16104 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751149AbWHGIGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 04:06:00 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060807060155.GA6487@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 07 August 2006 08:01, Evgeniy Polyakov wrote:
> Hello.
>
> Attached patch allows to avoid unnecessary alignment overhead
> in skb->data allocation.
> Main idea is to allocate struct skb_shared_info from cache when
> addition of sizeof(struct skb_shared_info) ens up in different order
> allocation than initial size order.
> This allows to solve problem with 4k allocations for 1500 MTU and 32k
> allocations for 9k jumbo frames for some chips.
> Patch was not tested, so if idea worth it I will complete it.
>
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>

> +	if ((1UL << order) > size + sizeof(void *) + sizeof(struct
> skb_shared_info)) { +		data = ____kmalloc(size + sizeof(struct
> skb_shared_info), gfp_mask); +		if (!data)
> +			goto nodata;
> +		memset(skb, 0, offsetof(struct sk_buff, truesize));
> +	} else {
> +		unsigned long *ptr;
> +
> +		data = ____kmalloc(size, gfp_mask);

You certainly want to kmalloc(size + sizeof(void *)) here, dont you ?

> +		if (!data)
> +			goto nodata;
> +		sh = kmem_cache_alloc(skbuff_shared_info_cache, gfp_mask);
> +		if (!sh) {
> +			kfree(data);
> +			goto nodata;
> +		}
> +		memset(skb, 0, offsetof(struct sk_buff, truesize));
> +		skb->shinfo_cache = 1;
> +		ptr = data;
> +		ptr[size] = sh;

Eric
