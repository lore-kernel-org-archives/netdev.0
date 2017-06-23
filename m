From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v3 02/13] sock: skb_copy_ubufs support for
 compound pages
Date: Thu, 22 Jun 2017 23:59:20 -0400
Message-ID: <CAF=yD-JGekEkBsFfgZa+-TN3-QBPy4sfK0QLPx83Uh3DAoodvg@mail.gmail.com>
References: <20170621211816.53837-3-willemdebruijn.kernel@gmail.com>
 <20170622.130528.1762873686654379973.davem@davemloft.net> <CAF=yD-+WQ1b9BytG4JuhgHCR8gAKvUVJPUfi4t-u_DqAFnVrkA@mail.gmail.com>
 <20170622.213646.1398197704798474384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36457 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdFWEAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 00:00:02 -0400
In-Reply-To: <20170622.213646.1398197704798474384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 9:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Thu, 22 Jun 2017 16:57:07 -0400
>
>>>
>>> Likewise.
>>>
>>>> +             f_off = f->page_offset;
>>>> +             f_size = f->size;
>>>> +
>>>> +             vaddr = kmap_atomic(skb_frag_page(f));
>>>
>>> I looked at some kmap_atomic() implementations and I do not think
>>> it supports compound pages.
>>
>> Indeed. Thanks. It appears that I can do the obvious thing and
>> kmap the individual page that is being copied inside the loop:
>>
>>   kmap_atomic(skb_frag_page(f) + (f_off >> PAGE_SHIFT));
>>
>> This is similar to existing logic in copy_huge_page_from_user
>> and __flush_dcache_page in arch/arm/mm/flush.c
>>
>> But, this also applies to other skb operations that call kmap_atomic,
>> such as skb_copy_bits and __skb_checksum. Not all can be called
>> from a codepath with a compound user page, but I have to address
>> the ones that can.
>
> Yeah that's quite a mess, it looks like this assumption that
> kmap can handle compound pages exists in quite a few places.

I hadn't even considered that skbs can already hold compound
page frags without zerocopy.

Open coding all call sites to iterate is tedious and unnecessary
in the common case where a page is not highmem.

kmap_atomic has enough slots to map an entire order-3 compound
page at once. But kmap_atomic cannot fail and there may be edge
cases that are larger than order-3.

Packet rings allocate with __GFP_COMP and an order derived
from (user supplied) tp_block_size, for instance. But it links each
skb_frag_t from an individual page, so this case seems okay.

Perhaps calls to kmap_atomic can be replaced with a
kmap_compound(..) that checks

 __this_cpu_read(__kmap_atomic_idx) +  (1 << compound_order(p)) < KM_TYPE_NR

before calling kmap_atomic on all pages in the compound page. In
the common case that the page is not high mem, a single call is
enough, as there is no per-page operation.
