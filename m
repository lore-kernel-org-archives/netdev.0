From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 18:11:15 -0800
Message-ID: <200702140211.l1E2BF22031298@death.nxdomain.ibm.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com> <20070214013130.GD26818@gospo.rdu.redhat.com>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:46871 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbXBNCLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 21:11:19 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1E2BI4u027074
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 21:11:18 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1E2BI3o285418
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 21:11:18 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1E2BHMc023193
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 21:11:18 -0500
In-reply-to: <20070214013130.GD26818@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>This is exactly the problem I've got, Jay.  I'd love to come up with
>something that will be a smaller patch to solve this in the near term
>and then focus on a larger set of changes down the road but it doesn't
>seem likely.

	That's more or less the conclusion I've reached as well.  The
locking model needs to be redone from scratch; there are too many
players and the conditions have changed since things were originally
done (in terms of side effects, particularly the places that may sleep
today that didn't in the past).  It's tricky to redo the bulk of the
innards in small modular steps.

>> 	Andy, one thought: do you think it would work better to simplify
>> the locking that is there first, i.e., convert the timers to work
>> queues, have a single dispatcher that handles everything (and can be
>> suspended for mutexing purposes), as in the patch I sent you?  The
>> problem isn't just rtnl; there also has to be a release of the bonding
>> locks themselves (to handle the might sleep issues), and that's tricky
>> to do with so many entities operating concurrently.  Reducing the number
>> of involved parties should make the problem simpler.
>> 
>
>I really don't feel like there are that many operations happening
>concurrently, but having a workqueue that managed and dispatched the
>operations and detected current link status would probably be helpful
>for long term maintenance.  It would probably be wise to have individual
>workqueues that managed any mode-specific operations, so their processing
>doesn't interfere with any link-checking operations.

	I like having the mode-specific monitors simply be special case
monitors in a unified "monitor system." It resolves the link-check
vs. mode-specific conflict, and allows all of the periodic things to be
paused as a set for mutexing purposes.  I'm happy to be convinced that
I'm just blowing hooey here, but that's how it seems to me.

	For balance-alb (the biggest offender in terms of locking
violations), the link monitor, alb mode monitor, transmit activity, and
user initiated stuff (add or remove slave, for example) all need to be
mutexed against one another.  The user initiated stuff comes in with
rtnl and the link monitor needs rtnl if it has to fail over.  All of
them need the regular bonding lock, but the user initiated stuff and the
link monitor both need to do things (change mac addresses, call
dev_open) with that lock released.

	Do you have any work in progress patches or descendents of the
big rework thing I sent you?  I need to get back to this, and whatever
we do it's probably better if we're at least a little bit coordinated.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
