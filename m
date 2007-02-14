From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 20:31:30 -0500
Message-ID: <20070214013130.GD26818@gospo.rdu.redhat.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481AbXBNBcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 20:32:32 -0500
Content-Disposition: inline
In-Reply-To: <200702132333.l1DNX022012433@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 03:33:00PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >On Tue, Feb 13, 2007 at 02:32:43PM -0800, David Miller wrote:
> [...]
> >> Maybe if you put the RTNL acquisition deeper into the call
> >> path, ie. down into the code that knows RTNL is needed,
> >> perhaps it won't be so ugly.  Replace the conditions with
> >> functions.
> >
> >That is almost exactly what I am working on right now.  I'm trying to
> >determine where the best place to put this would be so reduce the
> >chance that I'd be using conditional locking.  
> 
> 	It's complicated to do this because the small number of places
> that need rtnl are way down at the bottom of the chain, and the top of
> the chain can be entered either with or without rtnl, and not knowing if
> we'll actually end up doing the "need rtnl" bits or not until we're
> pretty far down the chain.  Hence my original prototype that I sent to
> Andy that passed down "have rtnl" status to the lower levels.

This is exactly the problem I've got, Jay.  I'd love to come up with
something that will be a smaller patch to solve this in the near term
and then focus on a larger set of changes down the road but it doesn't
seem likely.

> 	Andy, one thought: do you think it would work better to simplify
> the locking that is there first, i.e., convert the timers to work
> queues, have a single dispatcher that handles everything (and can be
> suspended for mutexing purposes), as in the patch I sent you?  The
> problem isn't just rtnl; there also has to be a release of the bonding
> locks themselves (to handle the might sleep issues), and that's tricky
> to do with so many entities operating concurrently.  Reducing the number
> of involved parties should make the problem simpler.
> 

I really don't feel like there are that many operations happening
concurrently, but having a workqueue that managed and dispatched the
operations and detected current link status would probably be helpful
for long term maintenance.  It would probably be wise to have individual
workqueues that managed any mode-specific operations, so their processing
doesn't interfere with any link-checking operations.

