From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 22:57:41 +0100
Message-ID: <20151022215741.GW22011@ZenIV.linux.org.uk>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
 <20151021.182955.1434243485706993231.davem@davemloft.net>
 <5628636E.1020107@oracle.com>
 <20151022044458.GP22011@ZenIV.linux.org.uk>
 <20151022060304.GQ22011@ZenIV.linux.org.uk>
 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
 <20151022172146.GS22011@ZenIV.linux.org.uk>
 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
 <20151022190701.GV22011@ZenIV.linux.org.uk>
 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39044 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965918AbbJVV5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 17:57:46 -0400
Content-Disposition: inline
In-Reply-To: <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 09:51:05PM +0200, Casper.Dik@oracle.com wrote:
> 
> >On Thu, Oct 22, 2015 at 08:24:51PM +0200, Casper.Dik@oracle.com wrote:
> >
> >> The external behaviour atomic; you cannot distinguish the order
> >> between the closing of the original file (and waking up other threads
> >> waiting for a record lock) or changing the file referenced by that newfd.
> >> 
> >> But this not include a global or process specific lock.
> >
> >Interesting...  Do you mean that decriptor-to-file lookup blocks until that
> >rundown finishes?
> 
> For that particular file descriptor, yes.  (I'm assuming you mean the 
> Solaris kernel running down all lwps who have a system in progress on that 
> particular file descriptor).  All other fd to file lookups are not blocked 
> at all by this locking.
> 
> It should be clear that any such occurrences are application errors and 
> should be hardly ever seen in practice.  It is also known when this is 
> needed so it is hardly even attempted.

Ho-hum...  It could even be made lockless in fast path; the problems I see
are
	* descriptor-to-file lookup becomes unsafe in a lot of locking
conditions.  Sure, most of that happens on the entry to some syscall, with
very light locking environment, but... auditing every sodding ioctl that
might be doing such lookups is an interesting exercise, and then there are
->mount() instances doing the same thing.  And procfs accesses.  Probably
nothing impossible to deal with, but nothing pleasant either.
	* memory footprint.  In case of Linux on amd64 or sparc64,
main()
{
	int i;
	for (i = 0; i < 1<<24; dup2(0, i++))	// 16M descriptors
		;
}
will chew 132Mb of kernel data (16Mpointer + 32Mbit, assuming sufficient ulimit -n,
of course).  How much will Solaris eat on the same?
	* related to the above - how much cacheline sharing will that involve?
These per-descriptor use counts are bitch to pack, and giving each a cacheline
of its own...  <shudder>
