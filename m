From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 15:38:51 +0100
Message-ID: <5627A37B.4090208@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3> <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com> <562594E1.8040403@oracle.com> <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com> <20151021034950.GL22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	Casper Dik <casper.dik@oracle.com>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50438 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbbJUOjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:39:05 -0400
In-Reply-To: <20151021034950.GL22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2015 04:49, Al Viro wrote:

Firstly, thank you for the comprehensive and considered reply.

> Refcount is an implementation detail, of course.  However, in any Unix I know
> of, there are two separate notions - descriptor losing connection to opened
> file (be it from close(), exit(), execve(), dup2(), etc.) and opened file
> getting closed.

Yep, it's an implementation detail inside the kernel - Solaris also has 
a refcount inside its vnodes. However that's really only dimly visible 
at the process level, where all you have is an integer file ID.

> The latter cannot happen while there are descriptors connected to the
> file in question, of course.  However, that is not the only thing
> that might prevent an opened file from getting closed - e.g. sending an
> SCM_RIGHTS datagram with attached descriptor connected to the opened file
> in question *at* *the* *moment* *of* *sendmsg(2)* will carry said opened
> file until it is successfully received or discarded (in the former case
> recepient will get a new descriptor refering to that opened file, of course).
> Having the original descriptor closed right after sendmsg(2) does *not*
> do anything to opened file.  On any Unix that implements descriptor-passing.

I believe async IO data is another way that a file can remain live after 
a close(), from the close() section of IEEE Std 1003.1:

"An I/O operation that is not canceled completes as if the close() 
operation had not yet occurred"

> There's going to be a notion of "last close"; that's what this refcount is
> about and _that_ is more than implementation detail.

Yes, POSIX distinguishes between "file descriptor" and "file 
description" (ugh!) and the close() page says:

"When all file descriptors associated with an open file description have 
been closed, the open file description shall be freed."

In the context of this discussion I believe it's the behaviour of the 
integer file descriptor that's the issue. Once it's had close() called 
on it then it's invalid, and any IO on it should fail, even if the 
underlying file description is still 'live'.

> In other words, is that destruction of
> 	* any descriptor refering to this socket [utterly insane for obvious
> reasons]
> 	* the last descriptor refering to this socket (modulo descriptor
> passing, etc.) [a bitch to implement, unless we treat a syscall in progress
> as keeping the opened file open], or
> 	* _the_ descriptor used to issue accept(2) [a bitch to implement,
> with a lot of fun races in an already race-prone area]?

 From reading the POSIX close() page I believe the second option is the 
correct one.

> Additional question is whether it's
> 	* just a magical behaviour of close(2) [ugly], or
> 	* something that happens when descriptor gets dissociated from
> opened file [obviously more consistent]?

The second, I believe.

> BTW, for real fun, consider this:
> 7)
> // fd is a socket
> fd2 = dup(fd);
> in thread A: accept(fd);
> in thread B: accept(fd);
> in thread C: accept(fd2);
> in thread D: close(fd);
>
> Which threads (if any), should get hit where it hurts?

A & B should return from the accept with an error. C should continue. 
Which is what happens on Solaris.

> I have no idea what semantics does Solaris have in that area and how racy
> their descriptor table handling is.  And no, I'm not going to RTFS their
> kernel, CDDL being what it is.

I can answer that for you :-) I've looked through the appropriate bits 
of the Solaris kernel code and my colleague Casper has written an 
excellent summary of what happens, so with his permission I've just 
copied it verbatim below:

----------
Since at least Solaris 7 (1998), a thread which is sleeping
on a file descriptor which is being closed by another thread,
will be woken up.

To this end each thread keeps a list of file descriptors
in use by the current active system call.

When a file descriptor is closed and this file descriptor
is marked as being in use by other threads, the kernel
will search all threads to see which have this file descriptor
listed as in use. For each such thread, the kernel tells
the thread that its active fds list is now stale and, if
possible, makes the thread run.

While this algorithm is pretty expensive, it is not often invoked.

The thread running close() will NOT return until all other threads
using that filedescriptor have released it.

When run, the thread will return from its syscall and will in most cases
return EBADF. A second thread trying to close this same file descriptor
may return earlier with close() returning EBADF.
----------

-- 
Alan Burlison
--
