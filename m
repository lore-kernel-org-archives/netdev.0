From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 02/13] sock: skb_copy_ubufs support for
 compound pages
Date: Tue, 27 Jun 2017 11:53:25 -0400
Message-ID: <CAF=yD-LJ-EvWbKtxqrcK1D=nRSzWzpPcFVOX1poZ3+P=aa0QfA@mail.gmail.com>
References: <20170621211816.53837-3-willemdebruijn.kernel@gmail.com>
 <20170622.130528.1762873686654379973.davem@davemloft.net> <CAF=yD-+WQ1b9BytG4JuhgHCR8gAKvUVJPUfi4t-u_DqAFnVrkA@mail.gmail.com>
 <20170622.213646.1398197704798474384.davem@davemloft.net> <CAF=yD-JGekEkBsFfgZa+-TN3-QBPy4sfK0QLPx83Uh3DAoodvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAF=yD-JGekEkBsFfgZa+-TN3-QBPy4sfK0QLPx83Uh3DAoodvg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>> I looked at some kmap_atomic() implementations and I do not think
>>>> it supports compound pages.
>>>
>>> Indeed. Thanks. It appears that I can do the obvious thing and
>>> kmap the individual page that is being copied inside the loop:
>>>
>>>   kmap_atomic(skb_frag_page(f) + (f_off >> PAGE_SHIFT));
>>>
>>> This is similar to existing logic in copy_huge_page_from_user
>>> and __flush_dcache_page in arch/arm/mm/flush.c
>>>
>>> But, this also applies to other skb operations that call kmap_atomic,
>>> such as skb_copy_bits and __skb_checksum. Not all can be called
>>> from a codepath with a compound user page, but I have to address
>>> the ones that can.
>>
>> Yeah that's quite a mess, it looks like this assumption that
>> kmap can handle compound pages exists in quite a few places.
>
> I hadn't even considered that skbs can already hold compound
> page frags without zerocopy.
>
> Open coding all call sites to iterate is tedious and unnecessary
> in the common case where a page is not highmem.
>
> kmap_atomic has enough slots to map an entire order-3 compound
> page at once. But kmap_atomic cannot fail and there may be edge
> cases that are larger than order-3.
>
> Packet rings allocate with __GFP_COMP and an order derived
> from (user supplied) tp_block_size, for instance. But it links each
> skb_frag_t from an individual page, so this case seems okay.
>
> Perhaps calls to kmap_atomic can be replaced with a
> kmap_compound(..) that checks
>
>  __this_cpu_read(__kmap_atomic_idx) +  (1 << compound_order(p)) < KM_TYPE_NR
>
> before calling kmap_atomic on all pages in the compound page. In
> the common case that the page is not high mem, a single call is
> enough, as there is no per-page operation.

This does not work. Some callers, such as __skb_checksum, cannot
fail, so neither can kmap_compound. Also, vaddr of consecutive
kmap_atomic calls are not guaranteed to be in order. Indeed, on x86
and arm vaddr appears to grows down: (FIXADDR_TOP - ((x) << PAGE_SHIFT))

An alternative is to change the kmap_atomic callers in skbuff.c. To
avoid open coding, we can wrap the kmap_atomic; op; kunmap_atomic
in a macro that loops only if needed:

static inline bool skb_frag_must_loop(struct page *p)
{
#if defined(CONFIG_HIGHMEM) || defined(CONFIG_X86_32)
        if (PageHighMem(p))
                return true;
#endif
        return false;
}

#define skb_frag_map_foreach(f, start, size, p, p_off, cp, copied)      \
        for (p = skb_frag_page(f) + ((start) >> PAGE_SHIFT),            \
             p_off = (start) & (PAGE_SIZE - 1),                         \
             copied = 0,                                                \
             cp = skb_frag_must_loop(p) ?                               \
                    min_t(u32, size, PAGE_SIZE - p_off) : size;         \
             copied < size;                                             \
             copied += cp, p++, p_off = 0,                              \
             cp = min_t(u32, size - copied, PAGE_SIZE))                 \

This does not change behavior on machines without high mem
or on low mem pages.

skb_seq_read keeps a mapping between calls to the function,
so will need a separate approach.
