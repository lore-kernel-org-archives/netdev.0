From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 18:21:46 +0100
Message-ID: <20151022172146.GS22011@ZenIV.linux.org.uk>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
 <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
 <20151022044458.GP22011@ZenIV.linux.org.uk>
 <20151022060304.GQ22011@ZenIV.linux.org.uk>
 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37557 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280AbbJVRVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:21:51 -0400
Content-Disposition: inline
In-Reply-To: <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 08:34:19AM +0200, Casper.Dik@oracle.com wrote:
> 
> 
> >And I'm really curious about the things Solaris would do with dup2() there.
> >Does it take into account the possibility of new accept() coming just as
> >dup2() is trying to terminate the ongoing ones?  Is there a window when
> >descriptor-to-file lookups would fail?  Looks like a race/deadlock country...
> 
> Solaris does not "terminate" threads, instead it tells them that the
> file descriptor information used is stale and wkae's up the thread.

Sorry, lousy wording - I meant "terminate syscall in another thread".
Better yet, make that "what happens if new accept(newfd) comes while dup2()
waits for affected syscalls in other threads to finish"?  Assuming it
does wait, that is...

While we are at it, what's the relative order of record locks removal
and switching the meaning of newfd?  In our kernel it happens *after*
the switchover (i.e. if another thread is waiting for a record lock held on
any alias of newfd and we do dup2(oldfd, newfd), the waiter will not see
the state with newfd still refering to what it used to; note that waiter
might be using any descriptor refering to the file newfd used to refer
to, so it won't be affected by the "wake those who had the meaning of
their arguments change" side of things).
