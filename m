From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 16:44:42 -0400
Message-ID: <20060623204442.GE14126@kvack.org>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623195513.GC14126@kvack.org> <20060623201716.GA26168@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:31663 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1752036AbWFWUos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:44:48 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060623201716.GA26168@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 24, 2006 at 12:17:17AM +0400, Evgeniy Polyakov wrote:
> But now it is implemented as repeated call for the same work, which does
> not look like it can be used for any other types of work.

Given an iocb, you do not have to return -EIOCBRETRY, instead return 
-EIOCBQUEUED and then from whatever context do an aio_complete() with the 
result for that iocb.

> And repeated work introduce latencies.
> As far as I recall, it is you who wanted to remove thread based approach
> from AIO subsystem.

I have essentially given up on trying to get the filesystem AIO patches 
in given that the concerns against them are "woe complexity" with no real 
recourse for inclusion being open.  If David is open to changes in the 
networking area, I'd love to see it built on top of your code.

> AIO completion approach was designed to be used with process context VFS
> update. read/write approach can not cover other types of notifications,
> like inode updates or timers.

The completion event is 100% generic and does not need to come from process 
context.  Calling aio_complete() from irq context is entirely valid.

> Format of the structure transferred between the objects does not matter
> at all. We can create a wrapper on kevent structures or kevent can
> transform data from AIO objects.

> The main design goal of kevent is to provide easy connected hooks into
> any state machine, which might be used by kernelspace to notify about
> any kind of events without any knowledge of it's background nature.
> Kevent can be used for example as notification blocks for address
> changes or it can replace netlink completely (it can even emulate
> event multicasting).
> 
> Kevent is queue of events, which can be transferred from any object to
> any destination.

And io_getevents() reads a queue of events, so I'm not sure why you need 
a new syscall.

> Not at all!
> Kevent is a mechanism, which allows to impleement AIO, network AIO, poll
> and select, timer control, adaptive readhead (as example of AIO VFS
> update). All the code I present shows how to use kevent, it is not part
> of the kevent. One can find Makefile in kevent dir to check what is the
> core of the subsystem, which allows to be used as a transport for
> events.
> 
> AIO, NAIO, poll/select, socket and timer notifications are just users.
> One can add it's own usage as easy as to call kevent_storage
> initialization function and event generation function. All other pieces
> are hidded in the implementation.

I'll look at adapting your code to use the existing syscalls.  Maybe code 
will be better at expressing my concerns.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
