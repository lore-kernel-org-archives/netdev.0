From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Sun, 13 Sep 2009 21:26:38 -0400
Message-ID: <1252891598.16335.42.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911.114620.260824240.davem@davemloft.net>
	 <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com>
	 <1252704102.25158.36.camel@dogo.mojatatu.com>
	 <20090911214254.GB19901@shareable.org>
	 <1252709567.25158.61.camel@dogo.mojatatu.com>
	 <20090914000303.GA30621@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org, balbir@in.ibm.com
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754733AbZINB1K@vger.kernel.org>
In-Reply-To: <20090914000303.GA30621@shareable.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-09-14 at 01:03 +0100, Jamie Lokier wrote:
> jamal wrote:
> > On Fri, 2009-09-11 at 22:42 +0100, Jamie Lokier wrote:

First let me state the 2 main new things fanotify gives so neither is
lost.

#1 fanotify implements the same basic thing as inotify except rather
than an arbitrary number (inotify speak a watch descriptor) which
userspace has to somehow convert back into a file, fanotify gives
userspace an open file descriptor to that object.  (this is the part
that requires recv side processing)

#2 fanotify allows the userspace 'listener' or 'group' (I use group to
describe it's actions in kernel and listener to describe it's action in
userspace) to request that it be allowed to arbitrate open and access
(read) security decisions.

> > > Eric's explained that it would be normal for _every_ file operation on
> > > some systems to trigger a fanotify event and possibly wait on the
> > > response, or at least in major directory trees on the filesystem.
> > > Even if it's just for the fanotify app to say "oh I don't care about
> > > that file, carry on".
> > > 
> > 
> > That doesnt sound very scalable. Should it not be you get nothing unless
> > you register for interest in something?
> 
> You do get nothing unless you register interest.  The problem is
> there's no way to register interest on just a subtree, so the fanotify
> approach is let you register for events on the whole filesystem, and
> let the userspace daemon filter paths.  At least it's decisions can be
> cached, although I'm not sure how that works when multiple processes
> want to monitor overlapping parts of the filesystem.

fanotify provides 3 options to register.
1) this inode
2) this dir and it's children
3) all files on the whole fscking system

this patch only does #1 and #2.  After it's in I'm going to take a
serious look at #4 subtrees.

Responses to access decisions are cached and checked in kernel per
fanotify listener.  So listener 1 can ignore requests for a given inode
while listener 2 still gets notification and forces the original process
to block.

> It doesn't sound scalable to me, either, and that's why I don't like
> this part, and described a solution to monitoring subtrees - which
> would also solve the problem for inotify.  (Both use fsnotify under
> the hood, and that's where subtree notification would go).

Subtree checking hasn't seen and work from me but it is something I plan
to work on.  And one thing that makes me scared to tie myself to
syscalls when I already have something that works relatively cleanly and
easily.

> Eric's mentioned interest in a way to monitor subtrees, but that
> hasn't gone anywhere as far as I know.  He doesn't seem convinced by
> my solution - or even that scalability will be an issue.  I think
> there's a bit of vision lacking here, and I'll admit I'm more
> interested in the inotify uses of fsnotify (being able to detect
> changes) than the fanotify uses (being able to _block_ or _modify_
> changes).  I think both inotify and fanotify ought to benefit from the
> same improvements to file monitoring.

sort of agree with you here.  anything that gets added to support
subtrees would have to be in the generic code.  Although I question how
inotify could be used, as a wd is not (in my mind) a reasonable way to
tell userspace about files.  (and with subtrees it would be a wd and a
pathname....)    I think fanotify with notification only (what I'm
giving in this patch series is a much better fit for subtree
notification.

> > > File performance is one of those things which really needs to be fast
> > > for a good user experience - and it's not unusual to grep the odd
> > > 10,000 files here or there (just think of what a kernel developer
> > > does), or to replace a few thousand quickly (rpm/dpkg) and things like
> > > that.
> > > 
> > 
> > So grepping 10000 files would cause 10000 events? I am not sure how the
> > scheme works; filtering of what events get delivered sounds more
> > reasonable if it happens in the kernel.
> 
> I believe it would cause 10000 events, yes, even if they are files
> that userspace policy is not interested in.  Eric, is that right?

If fanotify wants it, yes, that's exactly what happens.

> However I believe after the first grep, subsequent greps' decisions
> would be cached by marking the inodes.  I'm not sure what happens if
> two fanotify monitors both try marking the inodes.

Each can mark individually.

> Arguably if a fanotify monitor is running before those files are in
> page cache anyway, then I/O may dominate, and when the files are
> cached, fanotify has already cached it's decisions in the kernel.
> However fanotify is synchronous: each new file access involves a round
> trip to the fanotify userspace and back before it can proceed, so
> there's quite a lot of IPC and scheduling too.  Without testing, it's
> hard to guess how it'll really perform.

As I recall my old old tests on a 32 way system showed around a 10%
performance penalty when building a kernel when making userspace
arbitrate decisions and the cache was blank.  So yes, there is a serious
performance hit to making a userspace application control access
decisions.  Then again, I'd rather not have those people who need this
system wide access controls to do it in the kernel (anti-malware
vendors)

I believe that people who chose to use this interface will have to
realize there is a severe up front performance penalty.  On a steady
state system like a web server you'd see near 0% performance (a new srcu
lock, inode->i_lock, and running a short list)  But yes, controling
access to every file on a system eats performance, that's the nature of
the beast.

> > Theres a difference between events which are abbreviated in the form
> > "hey some read happened on fd you are listening on" vs "hey a read
> > of file X for 16 bytes at offset 200 by process Y just occured while
> > at the same time process Z was writting at offset 2000". The later
> > (which netlink will give you) includes a lot more attribute details
> > which could be filtered or can be extended to include a lot
> > more. The former(what epoll will give you) is merely a signal.

> But this part is irrelevant to fanotify, because there's no plan or
> intention to provide that much detail about I/O.

We have ZERO plan to include ordering.  ZERO.  inotify sorta pretends it
deals with ordering by only dropping a notification if it is the same as
the last one in the queue.  fanotify will gladly merge events which
exist anywhere in the queue clearly throwing ordering to the wind.

We do plan to include the pid, uid, and gid of the process making the
original request.  We also plan to include the f_flags of the file in
the original process when possible.
