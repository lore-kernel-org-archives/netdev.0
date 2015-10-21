From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 19:51:04 +0100
Message-ID: <20151021185104.GM22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	Casper Dik <casper.dik@oracle.com>
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55877 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbbJUSvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 14:51:07 -0400
Content-Disposition: inline
In-Reply-To: <5627A37B.4090208@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 03:38:51PM +0100, Alan Burlison wrote:

> >There's going to be a notion of "last close"; that's what this refcount is
> >about and _that_ is more than implementation detail.
> 
> Yes, POSIX distinguishes between "file descriptor" and "file
> description" (ugh!) and the close() page says:

Would've been better if they went for something like "IO channel" for
the latter ;-/

> "When all file descriptors associated with an open file description
> have been closed, the open file description shall be freed."

BTW, is SCM_RIGHTS outside of scope?  They do mention it in one place
only:
| Ancillary data is also possible at the socket level. The <sys/socket.h>
| header shall define the following symbolic constant for use as the cmsg_type
| value when cmsg_level is SOL_SOCKET:
|
| SCM_RIGHTS
|     Indicates that the data array contains the access rights to be sent or
| received.

with no further details whatsoever.  It's been there since at least 4.3-Reno;
does anybody still use the older variant (->msg_accrights, that is)?  IIRC,
there was some crap circa 2.6 when Solaris used to do ->msg_accrights for
descriptor-passing, but more or less current versions appear to support
SCM_RIGHTS...  In any case, descriptor-passing had been there in some form
since at least '83 (the old variant is already present in 4.2) and considering
it out-of-scope for POSIX is bloody ridiculous, IMO.

Unless they want to consider in-flight descriptor-passing datagrams as
collections of file descriptors, the quoted sentence is seriously misleading.
And then there's mmap(), which they do kinda-sorta mention...

> >In other words, is that destruction of
> >	* any descriptor refering to this socket [utterly insane for obvious
> >reasons]
> >	* the last descriptor refering to this socket (modulo descriptor
> >passing, etc.) [a bitch to implement, unless we treat a syscall in progress
> >as keeping the opened file open], or
> >	* _the_ descriptor used to issue accept(2) [a bitch to implement,
> >with a lot of fun races in an already race-prone area]?
> 
> From reading the POSIX close() page I believe the second option is
> the correct one.

Er...  So fd2 = dup(fd);accept(fd)/close(fd) should *not* trigger that
behaviour, in your opinion?  Because fd is sure as hell not the last
descriptor refering to that socket - fd2 remains alive and well.

Behaviour you describe below matches the _third_ option.

> >BTW, for real fun, consider this:
> >7)
> >// fd is a socket
> >fd2 = dup(fd);
> >in thread A: accept(fd);
> >in thread B: accept(fd);
> >in thread C: accept(fd2);
> >in thread D: close(fd);
> >
> >Which threads (if any), should get hit where it hurts?
> 
> A & B should return from the accept with an error. C should
> continue. Which is what happens on Solaris.

> To this end each thread keeps a list of file descriptors
> in use by the current active system call.

Yecchhhh...  How much cross-CPU traffic does that cause on
multithread processes?  Not on close(2), on maintaining the
descriptor use counts through the normal syscalls.

> When a file descriptor is closed and this file descriptor
> is marked as being in use by other threads, the kernel
> will search all threads to see which have this file descriptor
> listed as in use. For each such thread, the kernel tells
> the thread that its active fds list is now stale and, if
> possible, makes the thread run.
>
> While this algorithm is pretty expensive, it is not often invoked.

Sure, but the upkeep of data structures it would need is there
whether you actually end up triggering it or not.  Both in
memory footprint and in cacheline pingpong...

Besides, the list of threads using given descriptor table also needs
to be maintained, unless you scan *all* threads in the system (which
would be quite a fun wrt latency and affect a lot more than just the
process doing something dumb and rare).

BTW, speaking of fun races: AFAICS, NetBSD dup2() isn't atomic.  It
calls fd_close() outside of ->fd_lock (has to, since fd_close() is
grabbing that itself), so another thread doing e.g.  fcntl(newfd, F_GETFD)
in the middle of dup2(oldfd, newfd) might end up with EBADF, even though
both before and after dup2() newfd had been open.  What's worse,
thread A:
	fd1 = open("foo", ...);
	fd2 = open("bar", ...);
	...
	dup2(fd1, fd2);
thread B:
	fd = open("baz", ...);
might, AFAICS, end up with fd == fd2 and refering to foo instead of baz.
All it takes is the last open() managing to grab ->fd_lock just as fd_close()
from dup2() has dropped it.  Which is an unexpected behaviour, to put it
mildly, no matter how much standard lawyering one applies...
