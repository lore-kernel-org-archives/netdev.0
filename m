From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Fri, 23 Oct 2015 20:51:51 +0100
Message-ID: <20151023195151.GY22011@ZenIV.linux.org.uk>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151023183025.GA941@netbsd.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Casper Dik <casper.dik@oracle.com>
To: David Holland <dholland-tech@netbsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48111 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbbJWTv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 15:51:57 -0400
Content-Disposition: inline
In-Reply-To: <20151023183025.GA941@netbsd.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 06:30:25PM +0000, David Holland wrote:

> So, I'm coming late to this discussion and I don't have the original
> context; however, to me this cited behavior seems undesirable and if I
> ran across it in the wild I would probably describe it as a bug.

Unfortunately, that's precisely what NetBSD is trying to implement (and
that's what will happen if nothing else reopens fd).  See the logics in
fd_close(), with ->fo_restart() and waiting for all activity to settle
down.  As for the missing context, what fd_close() is doing is also
unreliable - inducing ERESTART in other threads sitting in accept(2) and
things like that and waiting for them to run into EBADF they'll get
(barring races) on syscall restart; threads sitting in accept() et.al.
on the same struct file, but with different descriptors will hopefully
go into restart and continue unaffected.  All that machinery relies on
nothing having reused the descriptor for socket(2), dup2() target, etc. while
those threads had been going through the syscall restart - if that happens,
you are SOL, since accept(2) _will_ restart on an unexpected socket.

Moreover, if you fix dup2() atomicity, this approach will reliably shit
itself for situations when dup2() rather than close() is used to close
the socket.  It relies upon having at least some window where the victim
descriptor would be yielding EBADF.

> System call processing for operations on files involves translating a
> file descriptor (a number) into an open-file object (or "file
> description"), struct file in BSD and I think also in Linux. The
> actual system call logic operates on the open-file object, so once the
> translation happens application monkeyshines involving file descriptor
> numbers should have no effect on calls in progress. Other behavior
> would violate the principle of least surprise, as this basic
> architecture predates POSIX.

Well, to be fair, until '93 there was no way to have descriptor table changed
under a syscall in the first place.  The old model (everything up to and 
ncluding 4.4BSD final) simply didn't include anything of that sort - mapping
from descriptors to open files was not shared and all changes a syscall might
see were ones done by the syscall itself.

So this thing isn't covered by the basic architecture - it's something that
had been significantly new merely two decades ago.  And POSIX still hasn't
quite caught up with that newfangled 4.2BSD thing...

IMO what you've described above is fine - that's how Linux works, that's
how FreeBSD and OpenBSD work and that's how NetBSD used to work until 2008
or so.  "Cancel syscall if any of the descriptors got dissociated from
opened files by action of another thread, have the dissociating operation
wait for all affected syscalls to run down" thing had been introduced then
and it is similar to what Solaris is doing.

AFAICS, the main issue with that is the memory footprint from hell and/or
cacheline clusterfuck.  Having accept(2) bugger off with e.g. EINTR in such
situation isn't inherently worse or better than having it sit there as if
close() or dup2() has not happened - matter of taste, and if there had been a
way to do it without inflicting the price on processes that do not pull that
kind of crap in the first place... might be worth considering.

As it is, the memory footprint seems to be too heavy.  I'm not entirely
convinced that there's no clever way to avoid that, but right now I don't
see anything that would look like a good approach.
