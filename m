From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Fri, 11 Aug 2006 00:04:54 -0700
Message-ID: <20060811000454.d0345288.akpm@osdl.org>
References: <11551105602734@2ka.mipt.ru>
	<20060809152127.481fb346.akpm@osdl.org>
	<20060810061433.GA4689@2ka.mipt.ru>
	<20060810001844.ff5e7429.akpm@osdl.org>
	<20060810075047.GB24370@2ka.mipt.ru>
	<20060810010254.3b52682f.akpm@osdl.org>
	<20060810082235.GA21025@2ka.mipt.ru>
	<20060810175639.b64faaa9.akpm@osdl.org>
	<20060811061535.GA11230@2ka.mipt.ru>
	<20060810232340.ab326d3f.akpm@osdl.org>
	<20060811063018.GB11230@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34010 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161155AbWHKHFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 03:05:19 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060811063018.GB11230@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Aug 2006 10:30:21 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Thu, Aug 10, 2006 at 11:23:40PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > On Fri, 11 Aug 2006 10:15:35 +0400
> > Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > 
> > > On Thu, Aug 10, 2006 at 05:56:39PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > > > > Per kevent fd.
> > > > > I have some ideas about better mmap ring implementation, which would
> > > > > dinamically grow it's buffer when events are added and reuse the same
> > > > > place for next events, but there are some nitpics unresolved yet.
> > > > > Let's not see there in next releases (no merge of course), until better 
> > > > > solution is ready. I will change that area when other things are ready.
> > > > 
> > > > This is not a problem with the mmap interface per-se.  If the proposed
> > > > event code permits each user to pin 160MB of kernel memory then that would
> > > > be a serious problem.
> > > 
> > > The main disadvantage is that all memory is allocated on the start even
> > > if it will not be used later. I think dynamic grow is appropriate
> > > solution, since user will have that memory used anyway, since kevents
> > > are allocated, just part of them will be allocated from possibly 
> > > mmaped memory.
> > 
> > But the worst-case remains the same, doesn't it?  160MB of pinned kernel
> > memory per user?
> 
> Yes. And now I think dynamic growing is not a good solution, since user
> can not know when he must call mmap() again to get additional pages
> (although I have some hacks to "dynamically" replace previously mmapped
> pages with new ones).
> 
> This area can be decreased down to 70mb by reducing amount of
> information placed into the buffer (only user's data and flags) without
> additional hints.
> 

70MB is still very bad, naturally.

There are other ways in which users can do this sort of thing - passing
fd's across sockets, allocating zillions of pagetables come to mind.  But
we don't want to add more.

Possible options:

- Add a new rlimit for the number of kevent fd's

- Add a new rlimit for the amount of kevent memory

- Add a new rlimit for the total amount of pinned kernel memory.  First
  user is kevent.

- Account a kevent fd as being worth 100 regular fds, so the naughty user
  hits EMFILE early (ug).

A new rlimit is attractive, and they're easy to add.  Problem is, userspace
support is hard (I think).  afaik a standard Linux system doesn't have
global and per-user rlimit config files which are parsed and acted upon at
login.  That would make rlimits more useful.
