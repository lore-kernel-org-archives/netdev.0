From: Zach Brown <zach.brown@oracle.com>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Tue, 08 Aug 2006 14:32:31 -0700
Message-ID: <44D902EF.8070809@oracle.com>
References: <11550230861383@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetsuo.zabbo.net ([207.173.201.20]:31360 "EHLO tetsuo.zabbo.net")
	by vger.kernel.org with ESMTP id S964951AbWHHVcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 17:32:35 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11550230861383@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Generic event handling mechanism.
> 
> I send this patchset for comments and review, it still contains AIO and 
> aio_sendfile() implementation on top of get_block() abstraction, which was
> decided to postpone for a while (it is simpler right now to generate patchset as a whole,
> when kevent will be ready for merge, I will generate patchset without AIO stuff).

I think that's the wrong order.  Let's see the clean patch before
deciding to merge it.  Just remove the current aio_sendfile
implementation.  We can build up one that is suitable for merging once
the kevent core is ready for merging.

> Since number of suggested changes goes from 'several' to 'very small', I'm asking for 
> inclusion or declining.

Well, I'm a little confused.  It still seems like we have a long way to
go before having something that we'll want to merge.  There's still
trivial things that need fixing like using LIST_POISON outside list.h
and that nutty 1 second "default" timeout thing, both previously
mentioned.  Then there's much more fundamental stuff like still
returning events from the _wait() syscall.  I thought the notion was
that the wait syscall would only wait and that events were always to be
collected from the ring.

David, what do you think about the networking calls in here?  Are they
suitable for merging?  I've been assuming that you'll want much more
code re-use, but I don't remember seeing you say either way.

There's also something that's been bugging me that I want to ask the
crowd.  The kevent work is doing the same thing fs/aio.c did: for an API
to support async operation we duplicate its existing system call API.
In fs/aio.c it was IO_CMD_* and struct uiocb members, with kevent it's a
system call like sys_aio_sendfile().  This seems like it might get to be
a little much if we bring async support to much of networking, disk io,
and say timers.  That's a lot of interfaces to duplicate.  Is this the
direction we want to take?  One could imagine doing a wrapper syscall
that might allocate a kevent struct and hang it off task_struct for
subsystems to recognize and work with, but that'd bring different
trade-offs.

> Should I prepare final patchset and what should it include?

Can you address the things I mentioned last time I looked through the
code and remove the parts of the patch that we know aren't going to be
merged?

- z
