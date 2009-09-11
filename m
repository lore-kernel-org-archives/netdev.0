From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Fri, 11 Sep 2009 17:51:42 -0400
Message-ID: <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <20090911204602.GA19371@shareable.org>
	 <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	 <20090911212731.GA19901@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756876AbZIKVvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:51:50 -0400
In-Reply-To: <20090911212731.GA19901@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 22:27 +0100, Jamie Lokier wrote:
> Eric Paris wrote:
> > On Fri, 2009-09-11 at 21:46 +0100, Jamie Lokier wrote:
> > > Eric Paris wrote:
> > > > > I would really prefer if you worked on eliminating the problem that
> > > > > prevents you from using netlink instead.
> > > > 
> > > > I'm not really sure if I can, although I'd love to hear input from
> > > > someone who knows the netlink code on how I can make it do what I need.
> > > > I'm really not duplicating much other than the NLMSG_OK and NLMSG_NEXT
> > > > macros.  My code doesn't even use skbs and I'm not savy enough to really
> > > > know how I could.  I'm more than willing to work on it if someone can
> > > > point me to how it might work.
> > > 
> > > Let's turn the question around.
> > > 
> > > Since you're doing lots of non-sockety things, and can't tolerate
> > > dropped packets - why isn't it a character device?  What's the reason
> > > for using a socket at all?
> > > 
> > > (I'm reminded of /dev/poll, /dev/epoll and /dev/inotify :-)
> > 
> > Originally it was a char device and I was told to use a socket protocol
> > so I could use get/set sockopt rather than ioctl, because ioctl is the
> > devil (even if those aren't THAT much better).
> > 
> > The queuing being done using events instead of skbs was done reusing
> > inotify code, reusing network code would be just as good with me.  What
> > I really need is a way to convey a pointer from one process to another.
> > That's why I claim loss is not an option, since I'm holding a reference
> > to the pointer I can't have that conveyance disappear under us.
> 
> It's fine as long as the disappearing knows to releas the reference.

Absolutely.

> But I suspect fanotify would be awfully hard to use if messages were
> unreliable.

For some things yes, some things no.  I'd have to understand where loss
can happen to know if it's feasible.  If I know loss happens in the
sender context that's great.  If it's somewhere in the middle and the
sender doesn't immediately know it'll never be delivered, yes, I don't
think it can solve all my needs.  How many places can and skb get lost
between the sender and the receiver?

> Does fanotify need "lots of ioctls", or could it fit comfortably into
> say 2-5 strongly typed system calls, like inotify and epoll do?

Certainly not a lot.  I do it now with 5 setsockopt calls.  I could do
it with a limited number of syscalls (what I have today in about 4) but
I still don't believe I know all the future use cases or how to define
them in syscalls.  People are still coming up with things they want
inotify to do but we can't implement them in the syscalls we have.  I
think we all know it's a hell of a lot easier to implement a new
setsockopt call than a new syscall.

I don't think I know everything everyone is going to want out of a new
notification system yet, so I'm reticent to go down that path.  I know
how to solve some of the suck of inotify, I know how to solve a number
of people's problems (and have all the patches to do it) but when it
comes to the organic nature of things and what I hope to be the growing
future of fanotify to solve everything for everyone, I don't think I can
define it all yet.  I just don't want to end up with another inotify, it
works, the syscalls do what they do very very well, but people want new
things out of it, and we can't reasonably give it to them.

Maybe syscalls are the right thing, and I know I can solve a lot of use
cases with syscalls, but I don't even know if I know all the use cases.

-Eric

