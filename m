From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Tue, 17 Oct 2006 16:25:00 +0200
Message-ID: <200610171625.00515.dada1@cosmosbay.com>
References: <11587449471424@2ka.mipt.ru> <200610171552.35470.dada1@cosmosbay.com> <20061017140740.GA20686@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Johann Borck <johann.borck@densedata.com>,
	Ulrich Drepper <drepper@redhat.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:57813 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751077AbWJQOZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 10:25:00 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061017140740.GA20686@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 October 2006 16:07, Evgeniy Polyakov wrote:
> On Tue, Oct 17, 2006 at 03:52:34PM +0200, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > > What about the case, which I described in other e-mail, when in case of
> > > the full ring buffer, no new events are written there, and when
> > > userspace commits (i.e. marks as ready to be freed or requeued by
> > > kernel) some events, new ones will be copied from ready queue into the
> > > buffer?
> >
> > Then, user might receive 'false events', exactly like
> > poll()/select()/epoll() can do sometime. IE a 'ready' indication while
> > there is no current event available on a particular fd / event_source.
>
> Only if user simultaneously uses oth interfaces and remove even from the
> queue when it's copy was in mapped buffer, but in that case it's user's
> problem (and if we do want, we can store pointer/index of the ring
> buffer entry, so when event is removed from the ready queue (using
> kevent_get_events()), appropriate entry in the ring buffer will be
> updated to show that it is no longer valid.
>
> > This should be safe, since those programs already ignore read()
> > returns -EAGAIN and other similar things.
> >
> > Programmer prefers to receive two 'event available' indications than ZERO
> > (and be stuck for infinite time). Of course, hot path (normal cases)
> > should return one 'event' only.
> >
> > In order words, being ultra fast 99.99 % of the time, but being able to
> > block forever once in a while is not an option.
>
> Have I missed something? It looks like the only problematic situation is
> described above when user simultaneously uses both interfaces.

In my point of view, user of the 'mmaped ring buffer' should be prepared to 
use both interfaces. Or else you are forced to presize the ring buffer to 
insane limits.

That is :
- Most of the time, we expect consuming events via mmaped ring buffer and no 
syscalls.
- In case we notice a 'mmaped ring buffer overflow', syscalls to get/consume 
events that could not be stored in mmaped buffer (but queued by kevent 
subsystem). If not stored by kevent subsystem (memory failure ?), revert to 
poll() to fetch all 'missed fds' in one row. Go back to normal mode.

- In case of empty ring buffer (or no mmap support at all, because this app 
doesnt expect lot of events per time unit, or because kevent dont have mmap 
support) : Be able to syscall and wait for an event.

Eric
