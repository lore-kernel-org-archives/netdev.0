From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Mon, 14 Sep 2009 01:03:03 +0100
Message-ID: <20090914000303.GA30621@shareable.org>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <1252704102.25158.36.camel@dogo.mojatatu.com> <20090911214254.GB19901@shareable.org> <1252709567.25158.61.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:33935 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbZINADU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 20:03:20 -0400
Content-Disposition: inline
In-Reply-To: <1252709567.25158.61.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Fri, 2009-09-11 at 22:42 +0100, Jamie Lokier wrote:
> 
> > One of the uses of fanotify is as a security or auditing mechanism.
> > That can't tolerate gaps.
> > 
> > It's fundemantally different from inotify in one important respect:
> > inotify apps can recover from losing events by checking what they are
> > watching.
> > 
> > The fanotify application will know that it missed events, but what
> > happens to the other application which _caused_ those events?  Does it
> > get to do things it shouldn't, or hide them from the fanotify app, by
> > simply overloading the system?  Or the opposite, does it get access
> > denied - spurious file errors when the system is overloaded?
> > 
> > There's no way to handle that by dropping events.  A transport
> > mechanism can be dropped (say skbs), but the event itself has to be
> > kept, and then retried.
> > 
> >
> > Since you have to keep an event object around until it's handled,
> > there's no point tying it to an unreliable delivery mechanism which
> > you'd have to wrap a retry mechanism around.
> > 
> > In other words, that part of netlink is a poor match.  It would match
> > inotify much better.
> 
> Reliability is something that you should build in. Netlink provides you
> all the necessary tools. What you are asking for here is essentially 
> reliable multicasting.

Almost.  It's reliable multicasting plus unicast responses which must
be waited for.  That changes things.

> You dont have infinite memory, therefore there
> will be times when you will overload one of the users, and they wont
> have sufficient buffer space and then you have to retransmit.

If you have enough memory to remember _what_ to retransmit, then you
have enough memory to buffer a fixed-size message.  It just depends on
how you do the buffering.  To say netlink drops the message and you
can retry is just saying that the buffering is happening one step
earlier, before netlink.  That's what I mean by netlink being a
pointless complication for this, because you can just as easily write
code which gets to the message to userspace without going through
netlink and with no chance of it being dropped.

> Is the current proposed mechanism capable of reliably multicasting
> without need for retransmit?

Yes.  It uses positive acknowledge and flow control, because these
match naturally with what fanotify does at the next higher level.

The process generating the multicast (e.g. trying to write a file) is
blocked until the receiver gets the message, handles it and
acknowledges with a "yes you can" or "no you can't" response.

That's part of fanotify's design.  The pattern conveniently has no
issues with using unbounded memory for message, because the sending
process is blocked.

> > Speaking of skbs, how fast and compact are they for this?
> 
> They are largish relative to say if you trimmed down to basic necessity.
> But then you get a lot of the buffer management aspects for free.
> In this case, the concept of multicasting is built in so for one event
> to be sent to X users - you only need one skb.

True you only need one skb.  But netlink doesn't handle waiting for
positive acknowledge responses from every receiver, and combining
their value, does it?  You can't really take advantage of netlink's
built in multicast, because to known when it has all the responses,
the fanotify layer has to track the subscriber list itself anyway.

What I'm saying is perhaps skbs are useful for fanotify, but I don't
know that netlink's multicasting is useful.  But storing the messages
in skbs for transmission, and using parts of netlink to manage them,
and to provide some of the API, that might be useful.

> > Eric's explained that it would be normal for _every_ file operation on
> > some systems to trigger a fanotify event and possibly wait on the
> > response, or at least in major directory trees on the filesystem.
> > Even if it's just for the fanotify app to say "oh I don't care about
> > that file, carry on".
> > 
> 
> That doesnt sound very scalable. Should it not be you get nothing unless
> you register for interest in something?

You do get nothing unless you register interest.  The problem is
there's no way to register interest on just a subtree, so the fanotify
approach is let you register for events on the whole filesystem, and
let the userspace daemon filter paths.  At least it's decisions can be
cached, although I'm not sure how that works when multiple processes
want to monitor overlapping parts of the filesystem.

It doesn't sound scalable to me, either, and that's why I don't like
this part, and described a solution to monitoring subtrees - which
would also solve the problem for inotify.  (Both use fsnotify under
the hood, and that's where subtree notification would go).

Eric's mentioned interest in a way to monitor subtrees, but that
hasn't gone anywhere as far as I know.  He doesn't seem convinced by
my solution - or even that scalability will be an issue.  I think
there's a bit of vision lacking here, and I'll admit I'm more
interested in the inotify uses of fsnotify (being able to detect
changes) than the fanotify uses (being able to _block_ or _modify_
changes).  I think both inotify and fanotify ought to benefit from the
same improvements to file monitoring.

> > File performance is one of those things which really needs to be fast
> > for a good user experience - and it's not unusual to grep the odd
> > 10,000 files here or there (just think of what a kernel developer
> > does), or to replace a few thousand quickly (rpm/dpkg) and things like
> > that.
> > 
> 
> So grepping 10000 files would cause 10000 events? I am not sure how the
> scheme works; filtering of what events get delivered sounds more
> reasonable if it happens in the kernel.

I believe it would cause 10000 events, yes, even if they are files
that userspace policy is not interested in.  Eric, is that right?

However I believe after the first grep, subsequent greps' decisions
would be cached by marking the inodes.  I'm not sure what happens if
two fanotify monitors both try marking the inodes.

Arguably if a fanotify monitor is running before those files are in
page cache anyway, then I/O may dominate, and when the files are
cached, fanotify has already cached it's decisions in the kernel.
However fanotify is synchronous: each new file access involves a round
trip to the fanotify userspace and back before it can proceed, so
there's quite a lot of IPC and scheduling too.  Without testing, it's
hard to guess how it'll really perform.

> > While skbs and netlink aren't that slow, I suspect they're an order of
> > magnitude or two slower than, say, epoll or inotify at passing events
> > around.
> 
> not familiar with inotify.

inotify is like dnotify, and like a signal or epoll: a message that
something happened.  You register interest in individual files or
directories only, and inotify does not (yet) provide a way to monitor
the whole filesystem or a subtree.

fanotify is different: it provides access control, and can _refuse_
attempts to read file X, or even modify the file before permitting the
file to be read.

> Theres a difference between events which are abbreviated in the form
> "hey some read happened on fd you are listening on" vs "hey a read
> of file X for 16 bytes at offset 200 by process Y just occured while
> at the same time process Z was writting at offset 2000". The later
> (which netlink will give you) includes a lot more attribute details
> which could be filtered or can be extended to include a lot
> more. The former(what epoll will give you) is merely a signal.

Firstly, it's really hard to retain the ordering of userspace events
like that in a useful way, given the non-determinstic parallelism
going on with multiple processes doing I/O do the same file :-)

Second, you can't really pump messages with that much detail into
netlink and let _it_ filter them to userspace; that would be too much
processing.  You'd have to have some way of not generating that much
detail except when it's been requested, and preferably only for files
you want it for.

But this part is irrelevant to fanotify, because there's no plan or
intention to provide that much detail about I/O.

If you want, feel free to provide a stracenotify subsystem to track
everything in detail :-)

-- Jamie
