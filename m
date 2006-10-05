From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Thu, 5 Oct 2006 16:37:15 +0400
Message-ID: <20061005123715.GA7475@2ka.mipt.ru>
References: <11587449471424@2ka.mipt.ru> <200610051245.03880.dada1@cosmosbay.com> <20061005105536.GA4838@2ka.mipt.ru> <200610051409.31826.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52608 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751439AbWJEMh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 08:37:57 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200610051409.31826.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 02:09:31PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Thursday 05 October 2006 12:55, Evgeniy Polyakov wrote:
> > On Thu, Oct 05, 2006 at 12:45:03PM +0200, Eric Dumazet (dada1@cosmosbay.com) 
> > >
> > > What is missing or not obvious is : If events are skipped because of
> > > overflows, What happens ? Connections stuck forever ? Hope that
> > > everything will restore itself ? Is kernel able to SIGNAL this problem to
> > > user land ?
> >
> > Exisitng  code does not overflow by design, but can consume a lot of
> > memory. I talked about the case, when there will be some limit on
> > number of entries put into mapped buffer.
> 
> You still dont answer my question. Please answer the question.
> Recap : You have a max of XXXX events queued. A network message come and 
> kernel want to add another event. It cannot because limit is reached. How the 
> User Program knows that this problem was hit ?

Existing design does not allow overflow.
If event was added into the queue (like user requested notification,
when new data has arrived), it is guaranteed that there will be place to
put that event into mapped buffer when it is ready.

If user wants to add anotehr event (for example after accept() user
wants to add another socket with request for notification about data
arrival into that socket), it can fail though. This limit is introduced
only because of mmap buffer.
 
> > It is the same.
> > What if reing buffer was grown upto 3 entry, and is now empty, and we
> > need to put there 4 entries? Grow it again?
> > It can be done, easily, but it looks like a workaround not as solution.
> > And it is highly unlikely that in situation, when there are a lot of
> > event, ring can be empty.
> 
> I dont speak of re-allocation of ring buffer. I dont care to allocate at 
> startup a big enough buffer.
> 
> Say you have allocated a ring buffer of 1024*1024 entries.
> Then you queue 100 events per second, and dequeue them immediatly.
> No need to blindly use all 1024*1024 slots in the ring buffer, doing 
> index = (index+1)%(1024*1024)

But what if they are not dequeued immediateyl? What if rate is high and
while one tries to dequeue, system adds another events?

> > epoll() does not have mmap.
> > Problem is not about how many events can be put into the kernel, but how
> > many of them can be put into mapped buffer.
> > There is no problem if mmap is turned off.
> 
> So zap mmap() support completely, since it is not usable at all. We wont 
> discuss on it.

Initial implementation did not have it.
But I was requested to do it, and it is ready now.
No one likes it, but no one provides an alternative implementation.
We are stuck.

-- 
	Evgeniy Polyakov
