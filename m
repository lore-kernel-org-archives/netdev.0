From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 19:16:56 +0100
Message-ID: <20151022181656.GT22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
 <20151022042100.GO22011@ZenIV.linux.org.uk>
 <5628C0AE.2020508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casper.Dik@oracle.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37848 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965462AbbJVSRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 14:17:00 -0400
Content-Disposition: inline
In-Reply-To: <5628C0AE.2020508@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 11:55:42AM +0100, Alan Burlison wrote:
> On 22/10/2015 05:21, Al Viro wrote:
> 
> >>Most of the work on using a file descriptor is local to the thread.
> >
> >Using - sure, but what of cacheline dirtied every time you resolve a
> >descriptor to file reference?
> 
> Don't you have to do that anyway, to do anything useful with the file?

Dirtying the cacheline that contains struct file itself is different, but
that's not per-descriptor.

> >In case of Linux we have two bitmaps and an array of pointers associated
> >with descriptor table.  They grow on demand (in parallel)
> >	* reserving a descriptor is done under ->file_lock (dropped/regained
> >around memory allocation if we end up expanding the sucker, actual reassignment
> >of pointers to array/bitmaps is under that spinlock)
> >	* installing a pointer is lockless (we wait for ongoing resize to
> >settle, RCU takes care of the rest)
> >	* grabbing a file by index is lockless as well
> >	* removing a pointer is under ->file_lock, so's replacing it by dup2().
> 
> Is that table per-process or global?

Usually it's per-process, but any thread could ask for a private instance
to work with (and then spawn more threads sharing that instance - or getting
independent copies).

It's common for Plan 9-inspired models - basically, you treat every thread
as a machine that consists of
	* memory
	* file descriptor table
	* namespace
	* signal handlers
	...
	* CPU (i.e. actual thread of execution).
The last part can't be shared; anything else can.  fork(2) variant used to
start new threads (clone(2) in case of Linux, rfork(2) in Plan 9 and *BSD)
is told which components should be copies of parent's ones and which should
be shared with the parent.  fork(2) is simply "copy everything except for the
namespace".  It's fairly common to have "share everything", but intermediate
variants are also possible.  There are constraints (e.g. you can't share
signal handlers without sharing the memory space), but descriptor table
can be shared independently from memory space just fine.  There's also a
way to say "unshare this, this and that components" - mapped to unshare(2) in
Linux and to rfork(2) in Plan 9.

Best way to think of that is to consider descriptor table as a first-class
object a thread can be connected to.  Usually you have one for each process,
with all threads belonging to that process connected to the same thing,
but that's just the most common use.

> I don't think that it's possible to claim that a non-atomic dup2()
> is POSIX-compliant.

Except that it's in non-normative part of dup2(2), AFAICS.  I certainly
agree that it would be a standard lawyering beyond reason, but "not
possible to claim" is too optimistic.  Maybe I'm just more cynical...

> ThreadA remains sat in accept on fd1 which is now a plain file, not
> a socket.

No.  accept() is not an operation on file descriptors; it's an operation on
file descriptions (pardon for use of that terminology).  They are specified
by passing descriptors, but there's a hell of a difference between e.g.
dup() or fcntl(,F_SETFD,) (operations on descriptors) and read() or lseek()
(operations on descriptions).

Lookups are done once per syscall; the only exception is F_SETFL{,W}, where
we recheck that descriptor is refering to the same thing before granting
the lock.

Again, POSIX is still underspecifying the semantics of shared descriptor
tables; back when the bulk of it had been written there had been no way
to have a descriptor -> description mapping changed under a syscall by
action of another thread.  Hell, they still hadn't picked on some things
that happened in early 80s, let alone early-to-mid 90s...

Linux and Solaris happen to cover these gaps differently; FreeBSD and
OpenBSD are probably closer to Linux variant, NetBSD - to Solaris one.
