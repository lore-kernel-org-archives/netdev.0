From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Fri, 11 Sep 2009 22:27:31 +0100
Message-ID: <20090911212731.GA19901@shareable.org>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <20090911204602.GA19371@shareable.org> <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Paris wrote:
> On Fri, 2009-09-11 at 21:46 +0100, Jamie Lokier wrote:
> > Eric Paris wrote:
> > > > I would really prefer if you worked on eliminating the problem that
> > > > prevents you from using netlink instead.
> > > 
> > > I'm not really sure if I can, although I'd love to hear input from
> > > someone who knows the netlink code on how I can make it do what I need.
> > > I'm really not duplicating much other than the NLMSG_OK and NLMSG_NEXT
> > > macros.  My code doesn't even use skbs and I'm not savy enough to really
> > > know how I could.  I'm more than willing to work on it if someone can
> > > point me to how it might work.
> > 
> > Let's turn the question around.
> > 
> > Since you're doing lots of non-sockety things, and can't tolerate
> > dropped packets - why isn't it a character device?  What's the reason
> > for using a socket at all?
> > 
> > (I'm reminded of /dev/poll, /dev/epoll and /dev/inotify :-)
> 
> Originally it was a char device and I was told to use a socket protocol
> so I could use get/set sockopt rather than ioctl, because ioctl is the
> devil (even if those aren't THAT much better).
> 
> The queuing being done using events instead of skbs was done reusing
> inotify code, reusing network code would be just as good with me.  What
> I really need is a way to convey a pointer from one process to another.
> That's why I claim loss is not an option, since I'm holding a reference
> to the pointer I can't have that conveyance disappear under us.

It's fine as long as the disappearing knows to releas the reference.
But I suspect fanotify would be awfully hard to use if messages were
unreliable.

> If network people want me to get back out of the network system I can go
> back to a char file with lots of ioctls.  I'd love to reuse code, I just
> don't know what's possible...

Ok.  I understand you're pushed in different directions by different
schools of thought.

Let's look at some history.  What happened to /dev/epoll.  It worked
very well (and several OSes have /dev/poll which is similar).  There
was no technical reason to change the interface.

But when it came to mainlining it, Linus objected, and forced it to
become a small set of system calls.  It's quite a nice interface to
use now.

Then /dev/inotify.  You know what happened.  The history was similar:
Linux objected to the device, and forced it to use a few system calls.

More recently, people skipped over the /dev path, having seen how it
went before, and just implemented things like timerfd, eventfd and
signalfd system calls.

That seems to be the Linux way - if the interface can be exposed as a
small set of sensible system calls, and it's really a core kernel
facility.

Does fanotify need "lots of ioctls", or could it fit comfortably into
say 2-5 strongly typed system calls, like inotify and epoll do?

-- Jamie
