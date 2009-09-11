From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Fri, 11 Sep 2009 15:33:33 -0400
Message-ID: <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756152AbZIKTdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 15:33:39 -0400
In-Reply-To: <20090911.114620.260824240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 11:46 -0700, David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Fri, 11 Sep 2009 01:25:58 -0400
> 
> > fanotify's user interface uses a custom socket (it doesn't use netlink
> > since work must be done in the context of the receive side of the socket)
> > 
> > This patch simply defines the fanotify socket number declarations.  The
> > actual implementation of the socket is in a later patch.
> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> I would really prefer if you worked on eliminating the problem that
> prevents you from using netlink instead.

I'm not really sure if I can, although I'd love to hear input from
someone who knows the netlink code on how I can make it do what I need.
I'm really not duplicating much other than the NLMSG_OK and NLMSG_NEXT
macros.  My code doesn't even use skbs and I'm not savy enough to really
know how I could.  I'm more than willing to work on it if someone can
point me to how it might work.

The basic problem is that process (a) opens a file.  In the context of
process(a) we need to take a reference on the struct path, store some
other information about what happened and then wait for the listener,
process(b), to run.  When process (b) runs it takes the struct path,
opens the file it points to, then writes up to userspace the information
collected back when (a) was running and the fd opened in (b)'s context.

Currently (aka this patch set) I do the storage of information and the
waiting for (b) to be ready using the same queuing mechanism as inotify.
the fsnotify backend creates a single 'event' which can be added to the
queues for multiple notification listeners.  So if 50 inotify watches
are on the same directory we only create one event.  I guess this could
be reimplemented to send an skb which contains the information that
fsnotify stores in an event rather than just queuing up the generic
event.  Then I could somehow hook the recv side of netlink to pull the
skb off and instead of dumping it's data to the receiver to actually
open an fd and rewrite the message.  I'm not sure what netlink is buying
me here thought.  I also don't know the code well enough to know
everywhere that an skb can be lost.  Since the skb is going to hold a
reference to a struct path and contain a pointer to a struct path I
certainly can't handle it being dropped.  The other major thing that I
lose or have a much harder time reimplementing is event merging.  After
process (a) drops an event on the queue if it does something else to the
same file fanotify will search the queue and merge events.  I certainly
don't know how to search the netlink queue to find old skbs edit them,
and all the while make sure I'm doing it race free.

I'm willing to try to make this happen, I'm just sure I see the benefit
and I don't know anyone who knows the net/netlink code well enough who
owuld be interested to help.....

-Eric

