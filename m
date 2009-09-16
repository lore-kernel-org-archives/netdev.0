From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 16:05:23 +0400
Message-ID: <20090916120523.GA12830@ioremap.net>
References: <20090911204602.GA19371@shareable.org> <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org> <20090914140720.GA8564@ioremap.net> <1252955295.2246.35.camel@dhcp231-106.rdu.redhat.com> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:58193 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbZIPMFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 08:05:21 -0400
Content-Disposition: inline
In-Reply-To: <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 05:54:59PM -0400, Eric Paris (eparis@redhat.com) wrote:
> Nothing's impossible, but is netlink a square peg for this round hole?
> One of the great benefits of netlink, the attribute matching and
> filtering, although possibly useful isn't some panacea as we have to do
> that well before netlink to have anything like decent performance.
> Imagine every single fs event creating an skb and sending it with
> netlink only to have most of them dropped.

There is no problem with performance even with single IO per skb.
Consider usual send/recv calls which may end up with the same skb per
syscall - most of the overhead comes from data copy or syscall machinery
(for small writes) and not from allocation path.

I have a 3.5 years old performance graph at
http://www.ioremap.net/gallery/netlink_perf.png

which shows 400 MB/s of bandwidth for 4k writes, I'm pretty sure it is
limited by copy performance only.

> The only other benefit to netlink that I know of is the reasonable,
> easy, and clean addition of information later in time with backwards
> compatibility as needed.  That's really cool, I admit, but with the
> limited amount of additional info that users have wanted out of inotify
> I think my data type extensibility should be enough.

I want alot from inotify which I'm afraid will not be easy with fanotify
either, but its existing model just does not allow its extension. I
would not be 100% sure that there will be no additional needs in a year
or so for fanotify.

> >  Moreover you can implement a pool of working threads and
> > postpone all the work to them and appropriate event queues, which will
> > allow to use rlimits for the listeners and open files 'kind of' on
> > behalf of those processes.
> 
> I'm sorry, I don't userstand.  I don't see how worker threads help
> anything here.  Can you explain what you are thinking?

I meant that it could be possible to postpone all the work of queueing,
event allocation, fd opening and population all be done on behalf of
some other threads in the system and only original process credentials
would be checked to satisfy various limits. In this case there will be
no questions in which context given fd was created and it is possible to
use async netlink nature.

I do not force you to do this of course, but there is already quite huge
infrastructure for similar tasks and it could be worth to
change/reconsider things to use existing models and not invent own.
Of course this is a matter of overall benefit.

> > But it is quite diferent from the approach you selected and which is
> > more obvious indeed. So if you ask a question whether fanotify should
> > use sockets or syscalls, I would prefer sockets
> 
> I've heard someone else off list say this as well.  I'm not certain why.
> I actually spent the day yesterday and have fanotify working over 5 new
> syscalls (good thing I wrote the code with separate back and and front
> ends for just this purpose)  And I really don't hate it.  I think 3
> might be enough.
> 
> fanotify_init() ---- very much like inotify_init
> fanotify_modify_mark_at() --- like inotify_add_watch and rm_watch
> fanotify_modify_mark_fd() --- same but with an fd instead of a path

Those two can be combined I think.

> fanotify_response() --- userspace tells the kernel what to do if requested/allowed
>    (could probably be done using write() to the fanotify fd)
> fanotify_exclude() --- a horrid syscall which might be better as an ioctl since it isn't strongly typed....

It all sounds good and simple, but what if you will need modify command
with new arguments? Instead of adding new typed option you will need to
add another syscall. I already did that for inotify but via ioctl and
pretty sure there will be such need for much wider fanotify some time in
the future.

> I don't see what's gained using netlink.  I am already reusing the
> fsnotify code to do all my queuing.  Someone help me understand the
> benefit of netlink and help me understand how we can reasonably meet the
> needs and I'll try to prototype it.
> 
> 1) fd's must be opened in the recv process

Or just injected into registered process' fd table with appropriate
limit checks? In this case it can be done on behalf of whatever other
worker.

> 2) reliability, if loss must know on the send side

You have this knowledge at netlink sending time, but there is no way to
wait until 'fail' condition is removed like when you can block writing
into socket waiting for buffer space to become large enough.

And there is no way to tell how many listeners got message and how many
was dropped in multicast deliver except that there were drops.
This can be trivially extended though.

-- 
	Evgeniy Polyakov
