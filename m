From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Sun, 22 Jan 2017 09:50:13 -0800
Message-ID: <CALx6S37EsGgf69R6N5DkLQbOgiHO1J4si4LMJ1+DMjnHW41eMQ@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
 <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
 <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com> <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: kernel netdev <netdev@brouer.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33695 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbdAVRuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 12:50:15 -0500
Received: by mail-qt0-f195.google.com with SMTP id n13so12057416qtc.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 09:50:14 -0800 (PST)
In-Reply-To: <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 12:31 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Sat, Jan 21, 2017 at 9:12 PM, kernel netdev <netdev@brouer.com> wrote:
>>
>>
>> Den 21. jan. 2017 7.10 PM skrev "Tom Herbert" <tom@herbertland.com>:
>>
>> On Thu, Jan 19, 2017 at 11:14 AM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet <eric.dumazet@gmail.com>
>>> wrote:
>>>> From: Eric Dumazet <edumazet@google.com>
>>>>
>>>> A driver using dev_alloc_page() must not reuse a page allocated from
>>>> emergency memory reserve.
>>>>
>>>> Otherwise all packets using this page will be immediately dropped,
>>>> unless for very specific sockets having SOCK_MEMALLOC bit set.
>>>>
>>>> This issue might be hard to debug, because only a fraction of received
>>>> packets would be dropped.
>>>
>>> Hi Eric,
>>>
>>> When you say reuse, you mean point to the same page from several SKBs ?
>>>
>>> Because in our page cache implementation we don't reuse pages that
>>> already passed to the stack,
>>> we just keep them in the page cache until the ref count drop back to
>>> one, so we recycle them (i,e they will be re-used only when no one
>>> else is using them).
>>>
>> Saeed,
>>
>> Speaking of the mlx page cache can we remove this or a least make it
>> optional to use. It is another example of complex functionality being
>> put into drivers that makes things like backports more complicated and
>
> Re complexity, I am not sure the mlx page cache is that complex,
> we just wrap alloc_page/put_page with our own page cache calls.
> Roughly the page cache implementation is 200-300 LOC tops all concentrate=
d
> in one place in the code.
>
Taken as part of the RX buffer management code the whole thing in very
complicated and seems to be completely bereft of any comments in the
code as to how things are supposed to work.

>> provide at best some marginal value. In the case of the mlx5e cache
>> code the results from pktgen really weren't very impressive in the
>> first place. Also, the cache suffers from HOL blocking where we can
>
> Well, with pktgen you won't notice a huge improvement since the pages are=
 freed
> in the stack directly from our rx receive handler (gro_receive), those
> pages will go back to the page allocator and get requested immediately
> again from the driver (no stress).
>
> The real improvements are seen when you really stress the page allocator =
with
> real uses cases such as  TCP/UDP with user applications, where the
> pages are held longer than the driver needs, the page cache in this
> case will play an important role of reducing the stress
> on the page allocater since with those use cases we are juggling with
> more pages than pktgen could.
>
> With more stress (#cores TCP streams) our humble page cache some times
> can't hold ! and it will get full fast enough and will fail to recycle
> for a huge percentage of the driver pages requests.
>
> Before our own page cache we used dev_alloc_skb which used its own
> cache "page_frag_cache" and it worked nice enough. So i don't really
> recommend removing the page cache, until we have
> a generic RX page cache solution for all device drivers.
>
>> block the whole cache due to an outstanding reference on just one page
>> (something that you wouldn't see in pktgen but is likely to happen in
>> real applications).
>>
>
> Re the HOL issue, we have some upcoming patches that would drastically
> improve the HOL blocking issue (we will simple swap the HOL on every
> sample).
>
>>
>> (Send from phone in car)
>>
>
> Driver Safe :) ..
>
>> To Tom, have you measured the effect of this page cache? Before claiming=
 it
>> is ineffective.
>>
>> My previous measurements show approx 20=E2=84=85 speedup on a UDP test w=
ith delivery
>> to remote CPU.
>>
>> Removing the cache would of cause be a good usecase for speeding up the =
page
>> allocator (PCP). Which Mel Gorman and me are working on. AFAIK current p=
age
>> order0 cost 240 cycles. Mel have reduced til to 180, and without NUMA 15=
0
>> cycles. And with bulking this can be amortized to 80 cycles.
>>
>
> Are you trying to say that we won't need the cache if you manage to
> deliver those optimizations ?
> can you compare those optimizations with the page_frag_cache from
> dev_alloc_skb ?
>
>> --Jesper
>>
