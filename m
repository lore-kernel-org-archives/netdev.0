From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of
 kmem_cache_free_bulk()
Date: Tue, 08 Sep 2015 14:01:10 -0700 (PDT)
Message-ID: <20150908.140110.899240065088272758.davem@davemloft.net>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org,
 aravinda@linux.vnet.ibm.com, cl@linux.com, paulmck@linux.vnet.ibm.com,
 iamjoonsoo.kim@lge.com
To: brouer@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150904170046.4312.38018.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Sep 2015 19:00:53 +0200

> +/**
> + *	kfree_skb_bulk - bulk free SKBs when refcnt allows to
> + *	@skbs: array of SKBs to free
> + *	@size: number of SKBs in array
> + *
> + *	If SKB refcnt allows for free, then release any auxiliary data
> + *	and then bulk free SKBs to the SLAB allocator.
> + *
> + *	Note that interrupts must be enabled when calling this function.
> + */
> +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size)
> +{
> +	int i;
> +	size_t cnt = 0;
> +
> +	for (i = 0; i < size; i++) {
> +		struct sk_buff *skb = skbs[i];
> +
> +		if (!skb_dec_and_test(skb))
> +			continue; /* skip skb, not ready to free */
> +
> +		/* Construct an array of SKBs, ready to be free'ed and
> +		 * cleanup all auxiliary, before bulk free to SLAB.
> +		 * For now, only handle non-cloned SKBs, related to
> +		 * SLAB skbuff_head_cache
> +		 */
> +		if (skb->fclone == SKB_FCLONE_UNAVAILABLE) {
> +			skb_release_all(skb);
> +			skbs[cnt++] = skb;
> +		} else {
> +			/* SKB was a clone, don't handle this case */
> +			__kfree_skb(skb);
> +		}
> +	}
> +	if (likely(cnt)) {
> +		kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
> +	}
> +}

You're going to have to do a trace_kfree_skb() or trace_consume_skb() for
these things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
