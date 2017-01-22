From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency reserve
Date: Sun, 22 Jan 2017 10:09:23 -0800
Message-ID: <CALx6S369rCbKYh3aLGp4G1GLwG456yqnX-a3fnG+vAKgvmS8vw@mail.gmail.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
 <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com> <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kernel netdev <netdev@brouer.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34181 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdAVSRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 13:17:52 -0500
Received: by mail-qt0-f196.google.com with SMTP id a29so12177175qtb.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 10:17:52 -0800 (PST)
In-Reply-To: <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 11:12 AM, kernel netdev <netdev@brouer.com> wrote:
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
> provide at best some marginal value. In the case of the mlx5e cache
> code the results from pktgen really weren't very impressive in the
> first place. Also, the cache suffers from HOL blocking where we can
> block the whole cache due to an outstanding reference on just one page
> (something that you wouldn't see in pktgen but is likely to happen in
> real applications).
>
>
> (Send from phone in car)
>
> To Tom, have you measured the effect of this page cache? Before claiming =
it
> is ineffective.

No, I have not. TBH, I have most of the past few weeks trying to debug
a backport of the code from 4.9 to 4.6. Until we have a working
backport performance is immaterial for our purposes. Unfortunately, we
are seeing some issues: the checksum faults I described previously and
crashes on bad page refcns which are presumably being caused by the
logic in RX buffer processing. This is why I am now having to dissect
the code and trying to disable things like the page cache that are not
essential functionality.

In any case the HOL blocking issue is obvious from reading the code
which and implies bimodal behavior-- we don't need a test for that to
know it's a bad as we've see the bad effects of that in many other
contexts.
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
That would be great. If only I had a nickel for every time someone
started working on a driver and came the conclusion that they need to
do a custom memory allocator because the kernel allocator is so
inefficient!

Tom

> --Jesper
>
