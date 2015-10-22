From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 21:15:02 +0100
Message-ID: <562943C6.5020402@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
 <20151022042100.GO22011@ZenIV.linux.org.uk> <5628C0AE.2020508@oracle.com>
 <20151022181656.GT22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50839 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965114AbbJVUPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 16:15:10 -0400
In-Reply-To: <20151022181656.GT22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/15 19:16, Al Viro wrote:

>> Don't you have to do that anyway, to do anything useful with the file?
>
> Dirtying the cacheline that contains struct file itself is different, but
> that's not per-descriptor.

Yes, true enough.

> Usually it's per-process, but any thread could ask for a private instance
> to work with (and then spawn more threads sharing that instance - or getting
> independent copies).

[snip]

Thanks again for the info, interesting. Solaris also does things along 
the same lines. In fact we recently extended posix_spawn so it could be 
used by the JVM to create subprocesses without wholescale copying, and 
Casper has done some optimisation work on posix_spawn as well.

>> I don't think that it's possible to claim that a non-atomic dup2()
>> is POSIX-compliant.
>
> Except that it's in non-normative part of dup2(2), AFAICS.  I certainly
> agree that it would be a standard lawyering beyond reason, but "not
> possible to claim" is too optimistic.  Maybe I'm just more cynical...

Possibly so, and possibly justifiably so as well ;-)

>> ThreadA remains sat in accept on fd1 which is now a plain file, not
>> a socket.
>
> No.  accept() is not an operation on file descriptors; it's an operation on
> file descriptions (pardon for use of that terminology).  They are specified
> by passing descriptors, but there's a hell of a difference between e.g.
> dup() or fcntl(,F_SETFD,) (operations on descriptors) and read() or lseek()
> (operations on descriptions).
>
> Lookups are done once per syscall; the only exception is F_SETFL{,W}, where
> we recheck that descriptor is refering to the same thing before granting
> the lock.

Yes, but if you believe that dup2() requires an implicit close() within 
it and that dup2() has to be atomic then expecting that other threads 
waiting on the same fd in accept() will get a notification seems 
reasonable enough.

> Again, POSIX is still underspecifying the semantics of shared descriptor
> tables; back when the bulk of it had been written there had been no way
> to have a descriptor -> description mapping changed under a syscall by
> action of another thread.  Hell, they still hadn't picked on some things
> that happened in early 80s, let alone early-to-mid 90s...

That's indisputably true - much of the POSIX behaviour predates threads 
and it shows, quite badly, in some places.

> Linux and Solaris happen to cover these gaps differently; FreeBSD and
> OpenBSD are probably closer to Linux variant, NetBSD - to Solaris one.

Yes, true enough.

-- 
Alan Burlison
--
