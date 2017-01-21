From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency
 reserve
Date: Sat, 21 Jan 2017 11:26:49 -0800
Message-ID: <1485026809.16328.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
         <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
         <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>, brouer@redhat.com
To: kernel netdev <netdev@brouer.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33732 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdAUT0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 14:26:51 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so7485041pfg.0
        for <netdev@vger.kernel.org>; Sat, 21 Jan 2017 11:26:51 -0800 (PST)
In-Reply-To: <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-01-21 at 20:12 +0100, kernel netdev wrote:
> 
> 
> Den 21. jan. 2017 7.10 PM skrev "Tom Herbert" <tom@herbertland.com>:
>         On Thu, Jan 19, 2017 at 11:14 AM, Saeed Mahameed
>         <saeedm@dev.mellanox.co.il> wrote:
>         > On Thu, Jan 19, 2017 at 9:03 AM, Eric Dumazet
>         <eric.dumazet@gmail.com> wrote:
>         >> From: Eric Dumazet <edumazet@google.com>
>         >>
>         >> A driver using dev_alloc_page() must not reuse a page
>         allocated from
>         >> emergency memory reserve.
>         >>
>         >> Otherwise all packets using this page will be immediately
>         dropped,
>         >> unless for very specific sockets having SOCK_MEMALLOC bit
>         set.
>         >>
>         >> This issue might be hard to debug, because only a fraction
>         of received
>         >> packets would be dropped.
>         >
>         > Hi Eric,
>         >
>         > When you say reuse, you mean point to the same page from
>         several SKBs ?
>         >
>         > Because in our page cache implementation we don't reuse
>         pages that
>         > already passed to the stack,
>         > we just keep them in the page cache until the ref count drop
>         back to
>         > one, so we recycle them (i,e they will be re-used only when
>         no one
>         > else is using them).
>         >
>         
>         Saeed,
>         
>         Speaking of the mlx page cache can we remove this or a least
>         make it
>         optional to use. It is another example of complex
>         functionality being
>         put into drivers that makes things like backports more
>         complicated and
>         provide at best some marginal value. In the case of the mlx5e
>         cache
>         code the results from pktgen really weren't very impressive in
>         the
>         first place. Also, the cache suffers from HOL blocking where
>         we can
>         block the whole cache due to an outstanding reference on just
>         one page
>         (something that you wouldn't see in pktgen but is likely to
>         happen in
>         real applications).
> 
> 
> (Send from phone in car)
> 
> 
> To Tom, have you measured the effect of this page cache? Before
> claiming it is ineffective.
> 
> 
> My previous measurements show approx 20℅ speedup on a UDP test with
> delivery to remote CPU.
> 
I find this a bit strange. When you have time (ie not while driving your
car or during week end) please give more details, for example on message
size. Was it before skb_condense() was added ?

> 
> Removing the cache would of cause be a good usecase for speeding up
> the page allocator (PCP). Which Mel Gorman and me are working on.
> AFAIK current page order0 cost 240 cycles. Mel have reduced til to
> 180, and without NUMA 150 cycles. And with bulking this can be
> amortized to 80 cycles.
> 
> 
> --Jesper
> 
> 
> 
