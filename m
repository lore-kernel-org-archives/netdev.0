From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 17:38:43 +0400
Message-ID: <20060814133843.GA30374@2ka.mipt.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060811140019.GA8611@ms2.inr.ac.ru> <20060811.172730.34542868.davem@davemloft.net> <20060813130431.GA14138@ms2.inr.ac.ru> <20060814080120.GA20053@2ka.mipt.ru> <20060814131919.GA13064@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50873 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751338AbWHNNjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 09:39:40 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060814131919.GA13064@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 05:19:19PM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> > What if we will store array of pages and in shared info
> > just like we have right now. So there will only one destructor.
> 
> Seems, this is not enough. Actually, I was asking for your experience
> with aio.
> 
> The simplest situation, which confuses me, translated to aio language:
> two senders send two pages. Those pages are to be recycled, when we
> are done. We have to notify both. And we have to merge both those pages
> in one segment.

Since they will be sent from different users it will be separate chunks,
each of which has own destructor, so yes one destructor per page in
described case, but in general it will be one per block of pages.
Blocks can then be combined into queue with additional blocks of
kmalloced data...
Mda, sounds not very good.

> The second half of that mail suggested three different solutions,
> all of them creepy. :-)

I still like existing way - it is much simpler (I hope :) to convince
e1000 developers to fix driver's memory usage with help of putting
skb_shared_info() or only pointer into skb.
With pointer it would be simpler to do refcounting, but it requires
additional allocation which is not cheap.
Inlining skb_shared_info can lead to troubles with cloning/sharing,
although it is also possible to do.

Idea of having header inside struct sk_buff is good until we strike
something, which will create a header which size exceeds preallocated
area (does MAX_TCP_HEADER enough for all, what about ipv6 options?)...

So as first step I would try to create extended alloc_skb() with a
pointer to shared_info (crap) (in case of appropriate sizes, i.e. when
aligned one exceeds power-of-two and so on), and let's e1000 and unix 
socket use that. If there will be additional requirements for other
global changes like you suggested, we can break things more
fundamentally :)

> Alexey

-- 
	Evgeniy Polyakov
