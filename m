From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 02/13] sock: skb_copy_ubufs support for
 compound pages
Date: Thu, 29 Jun 2017 11:54:17 -0400
Message-ID: <CAF=yD-+zoBq9C6LjH0h2cK1DtitB5z5iOjCNYgWPMSs6zQ8G7g@mail.gmail.com>
References: <20170621211816.53837-3-willemdebruijn.kernel@gmail.com>
 <20170622.130528.1762873686654379973.davem@davemloft.net> <CAF=yD-+WQ1b9BytG4JuhgHCR8gAKvUVJPUfi4t-u_DqAFnVrkA@mail.gmail.com>
 <20170622.213646.1398197704798474384.davem@davemloft.net> <CAF=yD-JGekEkBsFfgZa+-TN3-QBPy4sfK0QLPx83Uh3DAoodvg@mail.gmail.com>
 <CAF=yD-LJ-EvWbKtxqrcK1D=nRSzWzpPcFVOX1poZ3+P=aa0QfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAF=yD-LJ-EvWbKtxqrcK1D=nRSzWzpPcFVOX1poZ3+P=aa0QfA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> Perhaps calls to kmap_atomic can be replaced with a
>> kmap_compound(..) that checks
>>
>>  __this_cpu_read(__kmap_atomic_idx) +  (1 << compound_order(p)) < KM_TYPE_NR
>>
>> before calling kmap_atomic on all pages in the compound page. In
>> the common case that the page is not high mem, a single call is
>> enough, as there is no per-page operation.
>
> This does not work. Some callers, such as __skb_checksum, cannot
> fail, so neither can kmap_compound. Also, vaddr of consecutive
> kmap_atomic calls are not guaranteed to be in order. Indeed, on x86
> and arm vaddr appears to grows down: (FIXADDR_TOP - ((x) << PAGE_SHIFT))
>
> An alternative is to change the kmap_atomic callers in skbuff.c. To
> avoid open coding, we can wrap the kmap_atomic; op; kunmap_atomic
> in a macro that loops only if needed

I'll send this as RFC. It's not the most elegant solution.

The issue only arises with pages allocated with both __GFP_COMP and
__GFP_HIGHMEM, which is rare: skb_page_frag_refill,
alloc_skb_with_frags, __napi_alloc_skb and most device drivers do not
pass the high mem flag.

Exceptions are rds, mlx5. And transparent hugepages, which is a
problem with zerocopy fragments only (though not only msg_zerocopy,
potentially also the existing virtio and xen paths).

A simpler solution, then, may be to covert rds and mlx5 to not pass
__GFP_HIGHMEM and copy data on all zerocopy requests for this type of
pages.
