From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 02/13] sock: skb_copy_ubufs support for
 compound pages
Date: Thu, 22 Jun 2017 16:57:07 -0400
Message-ID: <CAF=yD-+WQ1b9BytG4JuhgHCR8gAKvUVJPUfi4t-u_DqAFnVrkA@mail.gmail.com>
References: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
 <20170621211816.53837-3-willemdebruijn.kernel@gmail.com> <20170622.130528.1762873686654379973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170622.130528.1762873686654379973.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>
> Likewise.
>
>> +             f_off = f->page_offset;
>> +             f_size = f->size;
>> +
>> +             vaddr = kmap_atomic(skb_frag_page(f));
>
> I looked at some kmap_atomic() implementations and I do not think
> it supports compound pages.

Indeed. Thanks. It appears that I can do the obvious thing and
kmap the individual page that is being copied inside the loop:

  kmap_atomic(skb_frag_page(f) + (f_off >> PAGE_SHIFT));

This is similar to existing logic in copy_huge_page_from_user
and __flush_dcache_page in arch/arm/mm/flush.c

But, this also applies to other skb operations that call kmap_atomic,
such as skb_copy_bits and __skb_checksum. Not all can be called
from a codepath with a compound user page, but I have to address
the ones that can.
