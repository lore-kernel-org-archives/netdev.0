From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 09:31:14 +0400
Message-ID: <20060809053113.GB17446@2ka.mipt.ru>
References: <11550230861383@2ka.mipt.ru> <44D902EF.8070809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:26093 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030482AbWHIFcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:32:07 -0400
To: Zach Brown <zach.brown@oracle.com>
Content-Disposition: inline
In-Reply-To: <44D902EF.8070809@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 02:32:31PM -0700, Zach Brown (zach.brown@oracle.com) wrote:
> Evgeniy Polyakov wrote:
> > Generic event handling mechanism.
> > 
> > I send this patchset for comments and review, it still contains AIO and 
> > aio_sendfile() implementation on top of get_block() abstraction, which was
> > decided to postpone for a while (it is simpler right now to generate patchset as a whole,
> > when kevent will be ready for merge, I will generate patchset without AIO stuff).
> 
> I think that's the wrong order.  Let's see the clean patch before
> deciding to merge it.  Just remove the current aio_sendfile
> implementation.  We can build up one that is suitable for merging once
> the kevent core is ready for merging.

That's why I'm asking for what exactly should be moved into the
patchset. I.e. do we need poll/select (it is the same as what epoll
does), timer, network AIO? How they should be splitted?

> > Since number of suggested changes goes from 'several' to 'very small', I'm asking for 
> > inclusion or declining.
> 
> Well, I'm a little confused.  It still seems like we have a long way to
> go before having something that we'll want to merge.  There's still
> trivial things that need fixing like using LIST_POISON outside list.h
> and that nutty 1 second "default" timeout thing, both previously
> mentioned.  Then there's much more fundamental stuff like still
> returning events from the _wait() syscall.  I thought the notion was
> that the wait syscall would only wait and that events were always to be
> collected from the ring.

Using LIST_POISON is a flag that kevent is in appropriate queue or not,
I can add some flag into the structure, but why, if it is clear just by
looking into list's pointers.
Thanks for mentioning timeout issue, I forgot about it, that will be
fixed.
I decided to allow to get events using syscall until glibc guys are
happy with how things work (if any). Then it can be trivially removed.

> David, what do you think about the networking calls in here?  Are they
> suitable for merging?  I've been assuming that you'll want much more
> code re-use, but I don't remember seeing you say either way.

The main problem with code reuse is that network AIO uses pinned pages
(until there will be a method to allocate "dma" memory are) and thus
uses memcpy() instead of copy_*_user(), so for full reuse we need some
kind of extending iovec, which is exported to userspace, or add some
flags into skbs, which is not the right thing to do, or heavily extend
socket API to include pointer to "copying" function itself.

> There's also something that's been bugging me that I want to ask the
> crowd.  The kevent work is doing the same thing fs/aio.c did: for an API
> to support async operation we duplicate its existing system call API.
> In fs/aio.c it was IO_CMD_* and struct uiocb members, with kevent it's a
> system call like sys_aio_sendfile().  This seems like it might get to be
> a little much if we bring async support to much of networking, disk io,
> and say timers.  That's a lot of interfaces to duplicate.  Is this the
> direction we want to take?  One could imagine doing a wrapper syscall
> that might allocate a kevent struct and hang it off task_struct for
> subsystems to recognize and work with, but that'd bring different
> trade-offs.
> 
> > Should I prepare final patchset and what should it include?
> 
> Can you address the things I mentioned last time I looked through the
> code and remove the parts of the patch that we know aren't going to be
> merged?

I will remove AIO stuff from the next patchset.
Other things will be addressed as described.

Thank you.

> - z

-- 
	Evgeniy Polyakov
