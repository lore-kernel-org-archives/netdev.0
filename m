From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 11:55:42 +0100
Message-ID: <5628C0AE.2020508@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3> <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com> <562594E1.8040403@oracle.com> <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com> <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <201510212033.t9LKX4G8007718@room101.nl.oracle.com> <20151022042100.GO22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>, Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50094 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbbJVKzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 06:55:54 -0400
In-Reply-To: <20151022042100.GO22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 05:21, Al Viro wrote:

>> Most of the work on using a file descriptor is local to the thread.
>
> Using - sure, but what of cacheline dirtied every time you resolve a
> descriptor to file reference?

Don't you have to do that anyway, to do anything useful with the file?

> How much does it cover and to what
> degree is that local to thread?  When it's a refcount inside struct file -
> no big deal, we'll be reading the same cacheline anyway and unless several
> threads are pounding on the same file with syscalls at the same time,
> that won't be a big deal.  But when refcounts are associated with
> descriptors...

There is a refcount in the struct held in the per-process list of open 
files and the 'slow path' processing is only taken if there's more than 
one LWP in the process that's accessing the file.

> In case of Linux we have two bitmaps and an array of pointers associated
> with descriptor table.  They grow on demand (in parallel)
> 	* reserving a descriptor is done under ->file_lock (dropped/regained
> around memory allocation if we end up expanding the sucker, actual reassignment
> of pointers to array/bitmaps is under that spinlock)
> 	* installing a pointer is lockless (we wait for ongoing resize to
> settle, RCU takes care of the rest)
> 	* grabbing a file by index is lockless as well
> 	* removing a pointer is under ->file_lock, so's replacing it by dup2().

Is that table per-process or global?

> The point is, dup2() over _unused_ descriptor is inherently racy, but dup2()
> over a descriptor we'd opened and kept open should be safe.  As it is,
> their implementation boils down to "userland must do process-wide exclusion
> between *any* dup2() and all syscalls that might create a new descriptor -
> open()/pipe()/socket()/accept()/recvmsg()/dup()/etc".  At the very least,
> it's a big QoI problem, especially since such userland exclusion would have
> to be taken around the operations that can block for a long time.  Sure,
> POSIX wording regarding dup2 is so weak that this behaviour can be argued
> to be compliant, but... replacement of the opened file associated with
> newfd really ought to be atomic to be of any use for multithreaded processes.

There's existing language in the Issue 7 dup2() description that says 
dup2() has to be atomic:

"the dup2( ) function provides unique services, as no other
interface is able to atomically replace an existing file descriptor."

And there is some new language in Issue 7 Technical Corrigenda 2 that 
reinforces that, when it's talking about reassignment of 
stdin/stdout/stderr:

"Furthermore, a close() followed by a reopen operation (e.g. open(), 
dup() etc) is not atomic; dup2() should be used to change standard file 
descriptors."

I don't think that it's possible to claim that a non-atomic dup2() is 
POSIX-compliant.

> IOW, if newfd is an opened descriptor prior to dup2() and no other thread
> attempts to close it by any means, there should be no window during which
> it would appear to be not opened.  Linux and FreeBSD satisfy that; OpenBSD
> seems to do the same, from the quick look.  NetBSD doesn't, no idea about
> Solaris.  FWIW, older NetBSD implementation (prior to "File descriptor changes,
> discussed on tech-kern:" back in 2008) used to behave like OpenBSD one; it
> had fixed a lot of crap, so it's entirely possible that OpenBSD simply has
> kept the old implementation, with tons of other races in that area, but this
> dup2() race got introduced in that rewrite.

Related to dup2(), there's some rather surprising behaviour on Linux. 
Here's the scenario:

----------
ThreadA opens, listens and accepts on socket fd1, waiting for incoming 
connections.

ThreadB waits for a while, then opens normal file fd2 for read/write.
ThreadB uses dup2 to make fd1 a clone of fd2.
ThreadB closes fd2.

ThreadA remains sat in accept on fd1 which is now a plain file, not a 
socket.

ThreadB writes to fd1, the result of which appears in the file, so fd1 
is indeed operating as a plain file.

ThreadB exits. ThreadA is still sat in accept on fd1.

A connection is made to fd1 by another process. The accept call succeeds 
and returns the incoming  connection. fd1 is still operating as a 
socket, even though it's now actually a plain file.
----------

I assume this is another consequence of the fact that threads waiting in 
accept don't get a notification if the fd they are using is closed, 
either directly by a call to close or by a syscall such as dup2. Not 
waking up other threads on a fd when it is closed seems like it's 
undesirable behaviour.

I can see the reasoning behind allowing shutdown to be used to do such a 
wakeup even if that's not POSIX-compliant - it may make it slightly 
easier for applications avoid fd recycling races. However the current 
situation is that shutdown is the *only* way to perform such a wakeup - 
simply closing the fd has no effect on any other threads. That seems 
incorrect.

-- 
Alan Burlison
--
