From: Eric Paris <eparis@redhat.com>
Subject: Re: fanotify as syscalls
Date: Tue, 15 Sep 2009 17:54:59 -0400
Message-ID: <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
References: <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <20090911204602.GA19371@shareable.org>
	 <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com>
	 <20090911212731.GA19901@shareable.org>
	 <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
	 <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
	 <20090914140720.GA8564@ioremap.net>
	 <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com>
	 <20090915201620.GB32192@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbZIOVzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 17:55:19 -0400
In-Reply-To: <20090915201620.GB32192@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-16 at 00:16 +0400, Evgeniy Polyakov wrote:
> On Mon, Sep 14, 2009 at 03:08:15PM -0400, Eric Paris (eparis@redhat.com) wrote:
> > Just this week I got another request to look at syscalls.  So I did, I
> > haven't prototyped it, but I can do it with syscalls, they would look
> > like this:
> > 
> > int fanotify_init(int flags, int f_flags, __u64 mask, unsigned int priority);
> 
> ...
> 
> > Are there demands that I convert to syscalls?  Do I really gain anything
> > using 9 new inextensible syscalls over socket(), bind(), and 8
> > setsockopt() calls?
> 
> In my personal opinion sockets are way much simpler and obvious than
> syscalls. Also one should not edit hundred of arch-dependant headers
> conflicting with other pity syscallers.
> 
> But implementing af_fanotify opens a door for zillions of other
> af_something which can be implemented using existing infrastructure
> namely netlink will solve likely 99% of potential usage cases.
> 
> And frankly I did not find it way too convincing that using netlink is
> impossible in your scenario if some things will be simplified, namely
> event merging.

Nothing's impossible, but is netlink a square peg for this round hole?
One of the great benefits of netlink, the attribute matching and
filtering, although possibly useful isn't some panacea as we have to do
that well before netlink to have anything like decent performance.
Imagine every single fs event creating an skb and sending it with
netlink only to have most of them dropped.

The only other benefit to netlink that I know of is the reasonable,
easy, and clean addition of information later in time with backwards
compatibility as needed.  That's really cool, I admit, but with the
limited amount of additional info that users have wanted out of inotify
I think my data type extensibility should be enough.

>  Moreover you can implement a pool of working threads and
> postpone all the work to them and appropriate event queues, which will
> allow to use rlimits for the listeners and open files 'kind of' on
> behalf of those processes.

I'm sorry, I don't userstand.  I don't see how worker threads help
anything here.  Can you explain what you are thinking?

> But it is quite diferent from the approach you selected and which is
> more obvious indeed. So if you ask a question whether fanotify should
> use sockets or syscalls, I would prefer sockets

I've heard someone else off list say this as well.  I'm not certain why.
I actually spent the day yesterday and have fanotify working over 5 new
syscalls (good thing I wrote the code with separate back and and front
ends for just this purpose)  And I really don't hate it.  I think 3
might be enough.

fanotify_init() ---- very much like inotify_init
fanotify_modify_mark_at() --- like inotify_add_watch and rm_watch
fanotify_modify_mark_fd() --- same but with an fd instead of a path
fanotify_response() --- userspace tells the kernel what to do if requested/allowed
   (could probably be done using write() to the fanotify fd)
fanotify_exclude() --- a horrid syscall which might be better as an ioctl since it isn't strongly typed....

If there is a strong need for syscalls I'm ready and willing.  I'd love
to hear Linus say socket+setsockopt() is a merge blocker and I have to
go to syscalls if he sees it that way.  If davem and friends say I'm not
networky enough to use socket()+setsockopt() I guess I have to look at
netlink (which I'm still not convinced buys us anything vs the crazy
complexity) or go with syscalls.  I'm perfectly willing to admit this is
a /dev+ioctl type interface only implemented on socket+setsockopt().  If
that's a no go, someone say it now please.

> but I still recommend
> to rethink your decision to move away from netlink to be 100% sure that
> it will not solve your needs.

I don't see what's gained using netlink.  I am already reusing the
fsnotify code to do all my queuing.  Someone help me understand the
benefit of netlink and help me understand how we can reasonably meet the
needs and I'll try to prototype it.

1) fd's must be opened in the recv process
2) reliability, if loss must know on the send side

