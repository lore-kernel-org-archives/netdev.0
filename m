From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of kmem_cache_free_bulk()
Date: Mon, 7 Sep 2015 09:25:49 -0700
Message-ID: <CALx6S348WrCr1mCOCMsr7fnSRp1bDRaG+-G1B+gpCJ3a4JeUtQ@mail.gmail.com>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
	<CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
	<20150907104101.3e392a6d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org,
	aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150907104101.3e392a6d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

>> What not pass a list of skbs (e.g. using skb->next)?
>
> Because the next layer, the slab API needs an array:
>   kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>

I suppose we could ask the same question of that function. IMO
encouraging drivers to define arrays of pointers on the stack like
you're doing in the ixgbe patch is a bad direction.

In any case I believe this would be simpler in the networking side
just to maintain a list of skb's to free. Then the dev_free_waitlist
structure might not be needed then since we could just use a
skb_buf_head for that.


Tom

> Look at the patch:
>  [PATCH V2 3/3] slub: build detached freelist with look-ahead
>  http://thread.gmane.org/gmane.linux.kernel.mm/137469/focus=137472
>
> Where I use this array to progressively scan for objects belonging to
> the same page.  (A subtle detail is I manage to zero out the array,
> which is good from a security/error-handling point of view, as pointers
> to the objects are not left dangling on the stack).
>
>
> I cannot argue that, writing skb->next comes as an additional cost,
> because the slUb free also writes into this cacheline.  Perhaps the
> slAb allocator does not?
>
> [...]
>> > +       if (likely(cnt)) {
>> > +               kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
>> > +       }
>> > +}
>> > +EXPORT_SYMBOL(kfree_skb_bulk);
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
