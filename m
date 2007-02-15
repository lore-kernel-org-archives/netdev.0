From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Thu, 15 Feb 2007 16:00:20 -0500
Message-ID: <20070215210019.GB30353@gospo.rdu.redhat.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net> <20070213230803.GB26818@gospo.rdu.redhat.com> <200702132333.l1DNX022012433@death.nxdomain.ibm.com> <20070214013130.GD26818@gospo.rdu.redhat.com> <200702140211.l1E2BF22031298@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161256AbXBOVG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 16:06:27 -0500
Content-Disposition: inline
In-Reply-To: <200702140211.l1E2BF22031298@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 06:11:15PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >This is exactly the problem I've got, Jay.  I'd love to come up with
> >something that will be a smaller patch to solve this in the near term
> >and then focus on a larger set of changes down the road but it doesn't
> >seem likely.
> 
> 	That's more or less the conclusion I've reached as well.  The
> locking model needs to be redone from scratch; there are too many
> players and the conditions have changed since things were originally
> done (in terms of side effects, particularly the places that may sleep
> today that didn't in the past).  It's tricky to redo the bulk of the
> innards in small modular steps.
> 

That might be the case, but I feel like the code is in a place where it
*could* work tomorrow with just some small tweaks (getting everything
into process context).  I'm reluctant to cram a whole bunch of changes
down someone's throat immediately (with a big patch) because it will be
difficult to learn incrementally what is being done well and what isn't
based on user feedback.

> >> 	Andy, one thought: do you think it would work better to simplify
> >> the locking that is there first, i.e., convert the timers to work
> >> queues, have a single dispatcher that handles everything (and can be
> >> suspended for mutexing purposes), as in the patch I sent you?  The
> >> problem isn't just rtnl; there also has to be a release of the bonding
> >> locks themselves (to handle the might sleep issues), and that's tricky
> >> to do with so many entities operating concurrently.  Reducing the number
> >> of involved parties should make the problem simpler.
> >> 
> >
> >I really don't feel like there are that many operations happening
> >concurrently, but having a workqueue that managed and dispatched the
> >operations and detected current link status would probably be helpful
> >for long term maintenance.  It would probably be wise to have individual
> >workqueues that managed any mode-specific operations, so their processing
> >doesn't interfere with any link-checking operations.
> 
> 	I like having the mode-specific monitors simply be special case
> monitors in a unified "monitor system." It resolves the link-check
> vs. mode-specific conflict, and allows all of the periodic things to be
> paused as a set for mutexing purposes.  I'm happy to be convinced that
> I'm just blowing hooey here, but that's how it seems to me.
> 

I went back and looked at my patch from a few months ago and I actually
use a single-threaded workqueue for each bond device.  I did not use
different queues to replace each timer -- just different types of work
that is placed on the queue.  So it sounds like we agree -- now we just
need to pick a decent starting point?

> 	For balance-alb (the biggest offender in terms of locking
> violations), the link monitor, alb mode monitor, transmit activity, and
> user initiated stuff (add or remove slave, for example) all need to be
> mutexed against one another.  The user initiated stuff comes in with
> rtnl and the link monitor needs rtnl if it has to fail over.  All of
> them need the regular bonding lock, but the user initiated stuff and the
> link monitor both need to do things (change mac addresses, call
> dev_open) with that lock released.
> 
> 	Do you have any work in progress patches or descendents of the
> big rework thing I sent you?  I need to get back to this, and whatever
> we do it's probably better if we're at least a little bit coordinated.
> 

I've updated my original patch with some changes that take the rtnetlink
lock deeper into the code without adding any conditional locking.  I'm
going to work with it more today and let you know if I think it is
better or worse that what I had before.


