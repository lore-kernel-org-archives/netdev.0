From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC patch 1/1] large netlink dumps
Date: Sun, 16 Apr 2017 09:37:08 -0700
Message-ID: <20170416093708.6e95aedd@xeon-e3>
References: <e17f52a6-b2ad-6b39-a655-2e8779a5d192@mojatatu.com>
        <1492312137.10587.87.camel@edumazet-glaptop3.roam.corp.google.com>
        <ae839ce5-351b-f351-3852-2d9f78669efb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33598 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756115AbdDPQhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 12:37:17 -0400
Received: by mail-pf0-f172.google.com with SMTP id s16so56939138pfs.0
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 09:37:16 -0700 (PDT)
In-Reply-To: <ae839ce5-351b-f351-3852-2d9f78669efb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Apr 2017 09:03:08 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 17-04-15 11:08 PM, Eric Dumazet wrote:
> > On Sat, 2017-04-15 at 13:07 -0400, Jamal Hadi Salim wrote:  
> >> Eric,
> >>
> >> How does attached look instead of the 32K?
> >> I found it helps to let user space suggest something
> >> larger.
> >>
> >> cheers,
> >> jamal  
> >
> > Looks dangerous to me, for various reasons.
> >
> > 1) Memory allocations might not like it
> >
> > Have you tried your change after user does a
> > setsockopt(    SO_RCVBUFFORCE,  256 Mbytes), and a
> > recvmsg ( .. 64 Mbytes) ?
> >
> > Presumably, we could replace 32768 by (PAGE_SIZE <<
> > PAGE_ALLOC_COSTLY_ORDER), but this will not matter on x86.
> >  
> 
> For my use case I dont need to go that high, but i can see
> plausibility that someone else will. Is there a reasonable
> large number other than 32K? 128K-512K would be way sufficient.

It was common with routing daemons to set SO_RCVBUF to very large values
to avoid losing notifications.

> > 2) We might have paths in the kernel filling a potential big skb without
> > yielding cpu or a spinlock or a mutex. -> latency source.
> >
> >
> > What perf numbers do you have, using 1MB buffers instead of 32KB ?
> >
> > The syscall overhead seems tiny compared to the actual cost of filling
> > the netlink message, accessing thousands of cache lines all over the
> > places.
> >  
> 
> sycall is affecting me - but I have only compared with limited
> traffic running at the same time as dumping. The more i can batch
> the sooner i can stop polluting the cache.
> 
> The tests I have done are with a default socket buffer of 4M
> and say recvmsg(... 128K). I dont need to go higher
> that 256-512K to achieve my goals.
> With default of 32K I can fit about 250-60 actions in one batch.
> With 128K I can fit 4x that.
> It takes about 1.5 minutes for one process to dump 1M actions
> on my laptop (Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz) with
> 32K; 25% of that time with 128K. tc is single threaded, so i can
> keep one cpu busy 100% while I dump which means latency fear
> is lowered.
> 
> My eventual need: To dump all relevant stats every 5 seconds.
> I will send the other patch I talked about which filters based
> on time which helps in most cases but not always.
> 
> I am also now thinking of adding "a range index filter" and then
> multi-threading several parrallel requests, one for each range of
> indices.
> 
> cheers,
> jamal
