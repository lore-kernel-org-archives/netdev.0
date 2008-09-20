From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 11:09:52 -0700
Message-ID: <20080920110952.05da49ab@infradead.org>
References: <20080919.234824.223177211.davem@davemloft.net>
	<1221924561.1343.121.camel@localhost.localdomain>
	<20080920084512.58f7fb08@infradead.org>
	<1221926529.1343.140.camel@localhost.localdomain>
	<20080920091918.0ffaef8c@infradead.org>
	<1221932404.1343.196.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: Daniel Walker <dwalker@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41207 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbYITSJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 14:09:52 -0400
In-Reply-To: <1221932404.1343.196.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2008 10:40:04 -0700
Daniel Walker <dwalker@mvista.com> wrote:

> On Sat, 2008-09-20 at 09:19 -0700, Arjan van de Ven wrote:
> > On Sat, 20 Sep 2008 09:02:09 -0700
> > Daniel Walker <dwalker@mvista.com> wrote:
> > 
> > > On Sat, 2008-09-20 at 08:45 -0700, Arjan van de Ven wrote:
> > > > On Sat, 20 Sep 2008 08:29:21 -0700
> > > > > 
> > > > > > Jen's, as stated, has block layer uses for this.  I intend
> > > > > > to use this for receive side flow seperation on
> > > > > > non-multiqueue network cards.  And Steffen Klassert has a
> > > > > > set of IPSEC parallelization changes that can very likely
> > > > > > make use of this.
> > > > > 
> > > > > What's the benefit that you (or Jens) sees from migrating
> > > > > softirqs from specific cpu's to others?
> > > > 
> > > > it means you do all the processing on the CPU that submitted
> > > > the IO in the first place, and likely still has the various
> > > > metadata pieces in its CPU cache (or at least you know you
> > > > won't need to bounce them over)
> > > 
> > > 
> > > In the case of networking and block I would think a lot of the
> > > softirq activity is asserted from userspace.. Maybe the scheduler
> > > shouldn't be migrating these tasks, or could take this softirq
> > > activity into account ..
> > 
> > well a lot of it comes from completion interrupts.
> 
> Yeah, partly I would think.

completions trigger the next send as well (for both block and net) so
it's quite common
> 
> > and moving userspace isn't a good option; think of the case of 1 nic
> > but 4 apache processes doing the work...
> > 
> 
> One nic, so one interrupt ? I guess we're talking about an SMP
> machine?

or multicore

doing IPI's for this on an UP machine is a rather boring exercise

> 
> Dave didn't supply the users of his code, or what kind of improvement
> was seen, or the case in which it would be needed. I think Dave knowns
> his subsystem, but the code on the surface looks like an end run
> around some other problem area..

it's very fundamental, and has been talked about at various conferences
as well.

the basic problem is that the submitter of the IO (be it block or net)
creates a ton of metadata state on submit, and ideally the completion
processing happens on the same CPU, for two reasons
1) to use the state in the cache
2) for the case where you touch userland data/structures, we assume the
scheduler kept affinity

it's a Moses-to-the-Mountain problem, except we have four Moses' but
only one Mountain. 

Or in CS terms: we move the work to the CPU where the userland is
rather than moving the userland to the IRQ CPU, since there is usually
only one IRQ but many userlands and many cpu cores.

(for the UP case this is all very irrelevant obviously)

I assume Dave will pipe in if he disagrees with me ;-)


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
