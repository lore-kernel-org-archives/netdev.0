From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Sat, 21 Jan 2017 22:31:26 +0200
Message-ID: <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
 <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com> <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kernel netdev <netdev@brouer.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35409 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAUUbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 15:31:47 -0500
Received: by mail-qk0-f195.google.com with SMTP id u25so6053843qki.2
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2017 12:31:47 -0800 (PST)
In-Reply-To: <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 9:12 PM, kernel netdev <netdev@brouer.com> wrote:
>
>
> Den 21. jan. 2017 7.10 PM skrev "Tom Herbert" <tom@herbertland.com>:
>
> On Thu, Jan 19, 2017 at 11:14 AM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> A driver using dev_alloc_page() must not reuse a page allocated from
>>> emergency memory reserve.
>>>
>>> Otherwise all packets using this page will be immediately dropped,
>>> unless for very specific sockets having SOCK_MEMALLOC bit set.
>>>
>>> This issue might be hard to debug, because only a fraction of received
>>> packets would be dropped.
>>
>> Hi Eric,
>>
>> When you say reuse, you mean point to the same page from several SKBs ?
>>
>> Because in our page cache implementation we don't reuse pages that
>> already passed to the stack,
>> we just keep them in the page cache until the ref count drop back to
>> one, so we recycle them (i,e they will be re-used only when no one
>> else is using them).
>>
> Saeed,
>
> Speaking of the mlx page cache can we remove this or a least make it
> optional to use. It is another example of complex functionality being
> put into drivers that makes things like backports more complicated and

Re complexity, I am not sure the mlx page cache is that complex,
we just wrap alloc_page/put_page with our own page cache calls.
Roughly the page cache implementation is 200-300 LOC tops all concentrated
in one place in the code.

> provide at best some marginal value. In the case of the mlx5e cache
> code the results from pktgen really weren't very impressive in the
> first place. Also, the cache suffers from HOL blocking where we can

Well, with pktgen you won't notice a huge improvement since the pages are f=
reed
in the stack directly from our rx receive handler (gro_receive), those
pages will go back to the page allocator and get requested immediately
again from the driver (no stress).

The real improvements are seen when you really stress the page allocator wi=
th
real uses cases such as  TCP/UDP with user applications, where the
pages are held longer than the driver needs, the page cache in this
case will play an important role of reducing the stress
on the page allocater since with those use cases we are juggling with
more pages than pktgen could.

With more stress (#cores TCP streams) our humble page cache some times
can't hold ! and it will get full fast enough and will fail to recycle
for a huge percentage of the driver pages requests.

Before our own page cache we used dev_alloc_skb which used its own
cache "page_frag_cache" and it worked nice enough. So i don't really
recommend removing the page cache, until we have
a generic RX page cache solution for all device drivers.

> block the whole cache due to an outstanding reference on just one page
> (something that you wouldn't see in pktgen but is likely to happen in
> real applications).
>

Re the HOL issue, we have some upcoming patches that would drastically
improve the HOL blocking issue (we will simple swap the HOL on every
sample).

>
> (Send from phone in car)
>

Driver Safe :) ..

> To Tom, have you measured the effect of this page cache? Before claiming =
it
> is ineffective.
>
> My previous measurements show approx 20=E2=84=85 speedup on a UDP test wi=
th delivery
> to remote CPU.
>
> Removing the cache would of cause be a good usecase for speeding up the p=
age
> allocator (PCP). Which Mel Gorman and me are working on. AFAIK current pa=
ge
> order0 cost 240 cycles. Mel have reduced til to 180, and without NUMA 150
> cycles. And with bulking this can be amortized to 80 cycles.
>

Are you trying to say that we won't need the cache if you manage to
deliver those optimizations ?
can you compare those optimizations with the page_frag_cache from
dev_alloc_skb ?

> --Jesper
>
