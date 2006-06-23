From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Sat, 24 Jun 2006 00:17:17 +0400
Message-ID: <20060623201716.GA26168@2ka.mipt.ru>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623195513.GC14126@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:61662 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751964AbWFWURP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:17:15 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060623195513.GC14126@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 03:55:13PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> On Fri, Jun 23, 2006 at 11:24:29PM +0400, Evgeniy Polyakov wrote:
> > What API are you talking about?
> > There is only epoll(), which is 40% slower than kevent, and AIO, which
> > works not as state machine, but as repeated call for the same work.
> > There is also inotify, which allocates new message each time event
> > occurs, which is not a good solution for every situation.
> 
> AIO can be implemented as a state machine.  Nothing in the API stops 
> you from doing that, and in fact there was code which was implemented as 
> a state machine used on 2.4 kernels.

But now it is implemented as repeated call for the same work, which does
not look like it can be used for any other types of work.
And repeated work introduce latencies.
As far as I recall, it is you who wanted to remove thread based approach
from AIO subsystem.

> > Linux just does not have unified event processing mechanism, which was
> > pointed to many times in AIO mail list and when epoll() was only
> > introduced. I would even say, that Linux does not have such mechanism at
> > all, since every potential user implements it's own, which can not be
> > used with others.
> 
> The epoll event API doesn't have space in the event fields for result codes 
> as needed for AIO.  The AIO API does -- how is it lacking in this regard?

AIO completion approach was designed to be used with process context VFS
update. read/write approach can not cover other types of notifications,
like inode updates or timers.

> > Kevent fixes that. Although implementation itself can be suboptimal for
> > some cases or even unacceptible at all, but it is really needed
> > functionality.
> 
> At the expense of adding another API?  How is this a good thing?  Why 
> not spit out events in the existing format?

Format of the structure transferred between the objects does not matter
at all. We can create a wrapper on kevent structures or kevent can
transform data from AIO objects.
The main design goal of kevent is to provide easy connected hooks into
any state machine, which might be used by kernelspace to notify about
any kind of events without any knowledge of it's background nature.
Kevent can be used for example as notification blocks for address
changes or it can replace netlink completely (it can even emulate
event multicasting).

Kevent is queue of events, which can be transferred from any object to
any destination.

> > Every existing notification can be built on top of kevent. One can find
> > how easy it was to implement generic poll/select notifications (what
> > epoll() does) or socket notifications (which are similar to epoll(), but
> > are called from inside socket state machine, thus improving processing
> > performance).
> 
> So far your code is adding a lot without unifying anything.

Not at all!
Kevent is a mechanism, which allows to impleement AIO, network AIO, poll
and select, timer control, adaptive readhead (as example of AIO VFS
update). All the code I present shows how to use kevent, it is not part
of the kevent. One can find Makefile in kevent dir to check what is the
core of the subsystem, which allows to be used as a transport for
events.

AIO, NAIO, poll/select, socket and timer notifications are just users.
One can add it's own usage as easy as to call kevent_storage
initialization function and event generation function. All other pieces
are hidded in the implementation.

> 		-ben
> -- 
> "Time is of no importance, Mr. President, only life is important."
> Don't Email: <dont@kvack.org>.

-- 
	Evgeniy Polyakov
