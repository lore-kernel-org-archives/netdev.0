From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 15:33:00 -0800
Message-ID: <200702132333.l1DNX022012433@death.nxdomain.ibm.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51310 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbXBMXdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 18:33:04 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1DNX2BJ025586
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 18:33:02 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1DNX2ce303728
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 18:33:02 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1DNX1QZ031493
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 18:33:02 -0500
In-reply-to: <20070213230803.GB26818@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Tue, Feb 13, 2007 at 02:32:43PM -0800, David Miller wrote:
[...]
>> Maybe if you put the RTNL acquisition deeper into the call
>> path, ie. down into the code that knows RTNL is needed,
>> perhaps it won't be so ugly.  Replace the conditions with
>> functions.
>
>That is almost exactly what I am working on right now.  I'm trying to
>determine where the best place to put this would be so reduce the
>chance that I'd be using conditional locking.  

	It's complicated to do this because the small number of places
that need rtnl are way down at the bottom of the chain, and the top of
the chain can be entered either with or without rtnl, and not knowing if
we'll actually end up doing the "need rtnl" bits or not until we're
pretty far down the chain.  Hence my original prototype that I sent to
Andy that passed down "have rtnl" status to the lower levels.

	Andy, one thought: do you think it would work better to simplify
the locking that is there first, i.e., convert the timers to work
queues, have a single dispatcher that handles everything (and can be
suspended for mutexing purposes), as in the patch I sent you?  The
problem isn't just rtnl; there also has to be a release of the bonding
locks themselves (to handle the might sleep issues), and that's tricky
to do with so many entities operating concurrently.  Reducing the number
of involved parties should make the problem simpler.

>I once put together a patch that used a macro like this (ignore the
>whitespace problems, this was just a cut and paste):
>
>/**
> * bond_rtnl_wrapper - take the rtnl_lock if needed
> * @x:         function with args
> *
> */
>#define RTNL_WRAPPER(x)                \
>({                                     \
>       int __rc__;                     \
>       if (rtnl_trylock()) {           \
>               __rc__ = x;             \
>               rtnl_unlock();          \
>       } else {                        \
>               __rc__ = x;             \
>       }                               \
>       __rc__;                         \
>})
>
>
>and wrapped it around the calls to dev_set_mac_address.  I wasn't
>pleased with it, but it seemed like it worked pretty well based on the
>testing I did.

	The problem with this is that it'll cause failures in the case
that some other unrelated entity holds rtnl ("x" will be performed
concurrently with whomever actually holds rtnl).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
