From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 05:21:01 +0100
Message-ID: <20151022042100.GO22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59703 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbJVEVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 00:21:08 -0400
Content-Disposition: inline
In-Reply-To: <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 10:33:04PM +0200, Casper.Dik@oracle.com wrote:
> 
> >On Wed, Oct 21, 2015 at 03:38:51PM +0100, Alan Burlison wrote:
> >
> >> >There's going to be a notion of "last close"; that's what this refcount is
> >> >about and _that_ is more than implementation detail.
> >> 
> >> Yes, POSIX distinguishes between "file descriptor" and "file
> >> description" (ugh!) and the close() page says:
> >
> >Would've been better if they went for something like "IO channel" for
> >the latter ;-/
> 
> Or at least some other word.  A file descriptor is just an index to
> a list of file pointers (and wasn't named so?)

*nod*

There's no less than 3 distinct notions associated with the word "file" -
"file as collection of bytes on filesystem", "opened file as IO channel" and
"file descriptor", all related ;-/  "File description" vs. "file descriptor"
is atrociously bad terminology.

> >Unless they want to consider in-flight descriptor-passing datagrams as
> >collections of file descriptors, the quoted sentence is seriously misleading.
> >And then there's mmap(), which they do kinda-sorta mention...
> 
> Well, a file descriptor really only exists in the context of a process; 
> in-flight it is no longer a file descriptor as there process context with 
> a file descriptor table; so pointers to file descriptions are passed 
> around.

Yes.  Note, BTW, that descriptor contains a bit more than a pointer - there
are properties associated with it (close-on-exec and is-it-already-claimed),
which makes abusing it for describing SCM_RIGHTS payloads even more of a
stretch.  IOW, description of semantics for close() and friends needs fixing -
it simply does not match the situation on anything that would be anywhere
near POSIX compliance in other areas.
 
> >Sure, but the upkeep of data structures it would need is there
> >whether you actually end up triggering it or not.  Both in
> >memory footprint and in cacheline pingpong...
> 
> Most of the work on using a file descriptor is local to the thread.

Using - sure, but what of cacheline dirtied every time you resolve a
descriptor to file reference?  How much does it cover and to what
degree is that local to thread?  When it's a refcount inside struct file -
no big deal, we'll be reading the same cacheline anyway and unless several
threads are pounding on the same file with syscalls at the same time,
that won't be a big deal.  But when refcounts are associated with
descriptors...

In case of Linux we have two bitmaps and an array of pointers associated
with descriptor table.  They grow on demand (in parallel)
	* reserving a descriptor is done under ->file_lock (dropped/regained
around memory allocation if we end up expanding the sucker, actual reassignment
of pointers to array/bitmaps is under that spinlock)
	* installing a pointer is lockless (we wait for ongoing resize to
settle, RCU takes care of the rest)
	* grabbing a file by index is lockless as well
	* removing a pointer is under ->file_lock, so's replacing it by dup2().

Grabbing a file by descriptor follows pointer from task_struct to descriptor
table, from descriptor table to element of array of pointers (embedded when
we have few descriptors, but becomes separately allocated when more is
needed), and from array element to struct file.  In struct file we fetch
->f_mode and (if descriptor table is shared) atomically increment ->f_count.

For comparison, NetBSD has an extra level of indirection (with similar
tricks for embedding them while there are few descriptors), with a lot
fatter structure around the pointer to file - they keep close-on-exec and
in-use in there, along with refcount and their equivalent of waitqueue.
These structures, once they grow past the embedded set, are allocated
one-by-one, so copying the table on fork() costs a _lot_ more.  Rather
than an array of pointers to files they have an array of pointers to
those guys.  Reserving a descriptor triggers allocation of new struct
fdfile and installing a pointer to it into the array.  Allows for slightly
simpler installing of pointer to file afterwards - unlike us, they don't
have to be careful about array resize happening in parallel.

Grabbing a file by index is lockless, so's installing a pointer to file.
Reserving a descriptor is under ->fd_lock (mutex rather than a spinlock).
Removing a pointer is under ->fd_lock, so's replacing it by
dup2(), but dup2() has an unpleasant race (see upthread).

They do the same amount of pointer-chasing on lookup proper, but only because
they do not look into struct file itself there.  Which happens immediately
afterwards, since callers *will* look into what they've got.  I didn't look
into the details of barrier use in there, but it looks generally sane.

Cacheline pingpong is probably not a big deal there, but only because these
structures are fat and scattered.  Another fun issue is that they have
in-use bits buried deep, which means that they need to mirror them in
a separate bitmap - would cost too much otherwise.  They actually went for
two-level bitmap - the first one with a bit per 32 descriptors, another -
with bit per descriptor.  Might or might not be worth nicking (and 1:32
ratio needs experimenting)...

The worst issues seem to be memory footprint and cost on fork().  Extra
level of indirection is unpleasant, but not terribly so.  Use of mutex
instead of spinlock is a secondary issue - it should be reasonably easy
to deal with.  And there are outright races, both in dup2() and in
restart-related logics...

Having a mirror of in-use bits is another potential source of races -
hadn't looked into that deeply enough.  That'll probably come into
play on any attempts to reduce fork() costs...

> >Besides, the list of threads using given descriptor table also needs
> >to be maintained, unless you scan *all* threads in the system (which
> >would be quite a fun wrt latency and affect a lot more than just the
> >process doing something dumb and rare).
> 
> In Solaris all threads using the same file descriptor table are all the 
> threads in the same process.  This is typical for Unix but it is not what 
> we have in Linux, or so I'm told.   So we already have that particular
> list of threads.

Linux (as well as *BSD and Plan 9) has descriptor table as first-class
sharable resource - any thread you spawn might share or copy it, and
you can unshare yours at any time.  Maintaining the list of threads
using the damn thing wouldn't be too much PITA, anyway - that's a secondary
issue.

> >BTW, speaking of fun races: AFAICS, NetBSD dup2() isn't atomic.  It
> >calls fd_close() outside of ->fd_lock (has to, since fd_close() is
> >grabbing that itself), so another thread doing e.g.  fcntl(newfd, F_GETFD)
> >in the middle of dup2(oldfd, newfd) might end up with EBADF, even though
> >both before and after dup2() newfd had been open.  What's worse,
> >thread A:
> >	fd1 = open("foo", ...);
> >	fd2 = open("bar", ...);
> >	...
> >	dup2(fd1, fd2);
> >thread B:
> >	fd = open("baz", ...);
> >might, AFAICS, end up with fd == fd2 and refering to foo instead of baz.
> >All it takes is the last open() managing to grab ->fd_lock just as fd_close()
> >from dup2() has dropped it.  Which is an unexpected behaviour, to put it
> >mildly, no matter how much standard lawyering one applies...
> 
> It could happen even when the implementation does not have any races; but 
> I think you're saying that you know that the open call in thread B 
> comes after the open to fd2, then fd != fd2.

No, what I'm saying is that dup2() of one descriptor thread A has opened to
another such descriptor, with no other threads ever doing anything to either
should *not* affect anything done by other threads.  If open() in thread B
comes before fd2 = open("bar", ...), it still should (and will) get a different
descriptor.

The point is, dup2() over _unused_ descriptor is inherently racy, but dup2()
over a descriptor we'd opened and kept open should be safe.  As it is,
their implementation boils down to "userland must do process-wide exclusion
between *any* dup2() and all syscalls that might create a new descriptor -
open()/pipe()/socket()/accept()/recvmsg()/dup()/etc".  At the very least,
it's a big QoI problem, especially since such userland exclusion would have
to be taken around the operations that can block for a long time.  Sure,
POSIX wording regarding dup2 is so weak that this behaviour can be argued
to be compliant, but... replacement of the opened file associated with
newfd really ought to be atomic to be of any use for multithreaded processes.
IOW, if newfd is an opened descriptor prior to dup2() and no other thread
attempts to close it by any means, there should be no window during which
it would appear to be not opened.  Linux and FreeBSD satisfy that; OpenBSD
seems to do the same, from the quick look.  NetBSD doesn't, no idea about
Solaris.  FWIW, older NetBSD implementation (prior to "File descriptor changes,
discussed on tech-kern:" back in 2008) used to behave like OpenBSD one; it
had fixed a lot of crap, so it's entirely possible that OpenBSD simply has
kept the old implementation, with tons of other races in that area, but this
dup2() race got introduced in that rewrite.
