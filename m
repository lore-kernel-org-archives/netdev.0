From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Initial thoughts on TXDP
Date: Fri, 2 Dec 2016 13:13:44 +0100
Message-ID: <20161202131344.12ce594c@redhat.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
        <20161201024407.GE26507@breakpoint.cc>
        <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752585AbcLBMNt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 07:13:49 -0500
In-Reply-To: <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 1 Dec 2016 11:51:42 -0800 Tom Herbert <tom@herbertland.com> wrote:
> On Wed, Nov 30, 2016 at 6:44 PM, Florian Westphal <fw@strlen.de> wrote:
> > Tom Herbert <tom@herbertland.com> wrote:  
[...]
> >>   - Call into TCP/IP stack with page data directly from driver-- no
> >> skbuff allocation or interface. This is essentially provided by the
> >> XDP API although we would need to generalize the interface to call
> >> stack functions (I previously posted patches for that). We will also
> >> need a new action, XDP_HELD?, that indicates the XDP function held the
> >> packet (put on a socket for instance).  
> >
> > Seems this will not work at all with the planned page pool thing when
> > pages start to be held indefinitely.

It is quite the opposite, the page pool support pages are being held
for longer times, than drivers today.  The current driver page recycle
tricks cannot, as they depend on page refcnt being decremented quickly
(while pages are still mapped in their recycle queue).

> > You can also never get even close to userspace offload stacks once you
> > need/do this; allocations in hotpath are too expensive.

Yes. It is important to understand that once the number of outstanding
pages get large, the driver recycle stops working.  Meaning the pages
allocations start to go through the page allocator.  I've documented[1]
that the bare alloc+free cost[2] (231 cycles order-0/4K) is higher than
the 10G wirespeed budget (201 cycles).

Thus, the driver recycle tricks are nice for benchmarking, as it hides
the page allocator overhead. But this optimization might disappear for
Tom's and Eric's more real-world use-cases e.g. like 10.000 sockets.
The page pool don't these issues.

[1] http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench01.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
