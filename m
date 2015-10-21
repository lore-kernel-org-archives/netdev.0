From: Casper.Dik@oracle.com
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Wed, 21 Oct 2015 22:33:04 +0200
Message-ID: <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
References: <20151019095938.72ea48e6@xeon-e3> <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com> <562594E1.8040403@oracle.com> <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com> <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47723 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157AbbJUUp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 16:45:59 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9LKjwQr020178
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 20:45:59 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9LKaGWa004834
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 20:45:58 GMT
In-Reply-To: <20151021185104.GM22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>On Wed, Oct 21, 2015 at 03:38:51PM +0100, Alan Burlison wrote:
>
>> >There's going to be a notion of "last close"; that's what this refcount is
>> >about and _that_ is more than implementation detail.
>> 
>> Yes, POSIX distinguishes between "file descriptor" and "file
>> description" (ugh!) and the close() page says:
>
>Would've been better if they went for something like "IO channel" for
>the latter ;-/

Or at least some other word.  A file descriptor is just an index to
a list of file pointers (and wasn't named so?)

>> "When all file descriptors associated with an open file description
>> have been closed, the open file description shall be freed."
>
>BTW, is SCM_RIGHTS outside of scope?  They do mention it in one place
>only:
>| Ancillary data is also possible at the socket level. The <sys/socket.h>
>| header shall define the following symbolic constant for use as the cmsg_type
>| value when cmsg_level is SOL_SOCKET:
>|
>| SCM_RIGHTS
>|     Indicates that the data array contains the access rights to be sent or
>| received.
>
>with no further details whatsoever.  It's been there since at least 4.3-Reno;
>does anybody still use the older variant (->msg_accrights, that is)?  IIRC,
>there was some crap circa 2.6 when Solaris used to do ->msg_accrights for
>descriptor-passing, but more or less current versions appear to support
>SCM_RIGHTS...  In any case, descriptor-passing had been there in some form
>since at least '83 (the old variant is already present in 4.2) and considering
>it out-of-scope for POSIX is bloody ridiculous, IMO.

SCM_RIGHTS was introduced as part of the POSIX standardization of BSD 
sockets.  Looks like they became part of Solaris 2.6, but the default
was non-standard sockets so you may easily find msg->accrights but not
SCM_RIGHTS.

msg_accrights is what was introduced in BSD in likely the first 
implementation of socket-based file descriptor passing.

SysV has its own file descriptor passing on file descriptors passing.

But that interface is too much ad-hoc, so SCM_RIGHTS is a standardizations 
allowing multiple types of messages to be send around

>Unless they want to consider in-flight descriptor-passing datagrams as
>collections of file descriptors, the quoted sentence is seriously misleading.
>And then there's mmap(), which they do kinda-sorta mention...

Well, a file descriptor really only exists in the context of a process; 
in-flight it is no longer a file descriptor as there process context with 
a file descriptor table; so pointers to file descriptions are passed 
around.

>> >In other words, is that destruction of
>> >	* any descriptor refering to this socket [utterly insane for obvious
>> >reasons]
>> >	* the last descriptor refering to this socket (modulo descriptor
>> >passing, etc.) [a bitch to implement, unless we treat a syscall in progress
>> >as keeping the opened file open], or
>> >	* _the_ descriptor used to issue accept(2) [a bitch to implement,
>> >with a lot of fun races in an already race-prone area]?
>> 
>> From reading the POSIX close() page I believe the second option is
>> the correct one.
>
>Er...  So fd2 = dup(fd);accept(fd)/close(fd) should *not* trigger that
>behaviour, in your opinion?  Because fd is sure as hell not the last
>descriptor refering to that socket - fd2 remains alive and well.
>
>Behaviour you describe below matches the _third_ option.

>> >BTW, for real fun, consider this:
>> >7)
>> >// fd is a socket
>> >fd2 = dup(fd);
>> >in thread A: accept(fd);
>> >in thread B: accept(fd);
>> >in thread C: accept(fd2);
>> >in thread D: close(fd);
>> >
>> >Which threads (if any), should get hit where it hurts?
>> 
>> A & B should return from the accept with an error. C should
>> continue. Which is what happens on Solaris.
>
>> To this end each thread keeps a list of file descriptors
>> in use by the current active system call.
>
>Yecchhhh...  How much cross-CPU traffic does that cause on
>multithread processes?  Not on close(2), on maintaining the
>descriptor use counts through the normal syscalls.

In the Solaris implementation is pretty much what we do;
but there is no much cross-CPU traffic.  Of course, you will need
to keep locks in the file descriptor table if only to find
the actual file pointer.

The work is done only in the case of a badly written application
where close is required to hunt down all threads currently using
the specific file descriptor.

>> When a file descriptor is closed and this file descriptor
>> is marked as being in use by other threads, the kernel
>> will search all threads to see which have this file descriptor
>> listed as in use. For each such thread, the kernel tells
>> the thread that its active fds list is now stale and, if
>> possible, makes the thread run.
>>
>> While this algorithm is pretty expensive, it is not often invoked.
>
>Sure, but the upkeep of data structures it would need is there
>whether you actually end up triggering it or not.  Both in
>memory footprint and in cacheline pingpong...

Most of the work on using a file descriptor is local to the thread.

>Besides, the list of threads using given descriptor table also needs
>to be maintained, unless you scan *all* threads in the system (which
>would be quite a fun wrt latency and affect a lot more than just the
>process doing something dumb and rare).

In Solaris all threads using the same file descriptor table are all the 
threads in the same process.  This is typical for Unix but it is not what 
we have in Linux, or so I'm told.   So we already have that particular
list of threads.

>BTW, speaking of fun races: AFAICS, NetBSD dup2() isn't atomic.  It
>calls fd_close() outside of ->fd_lock (has to, since fd_close() is
>grabbing that itself), so another thread doing e.g.  fcntl(newfd, F_GETFD)
>in the middle of dup2(oldfd, newfd) might end up with EBADF, even though
>both before and after dup2() newfd had been open.  What's worse,
>thread A:
>	fd1 = open("foo", ...);
>	fd2 = open("bar", ...);
>	...
>	dup2(fd1, fd2);
>thread B:
>	fd = open("baz", ...);
>might, AFAICS, end up with fd == fd2 and refering to foo instead of baz.
>All it takes is the last open() managing to grab ->fd_lock just as fd_close()
>from dup2() has dropped it.  Which is an unexpected behaviour, to put it
>mildly, no matter how much standard lawyering one applies...

It could happen even when the implementation does not have any races; but 
I think you're saying that you know that the open call in thread B 
comes after the open to fd2, then fd != fd2.

This looks indeed like a bug.

Casper
