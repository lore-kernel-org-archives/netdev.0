From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Sun, 17 Apr 2011 21:08:44 -0400
Message-ID: <20110418010844.GA4376@neilslaptop.think-freely.org>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
 <1302908069.2845.29.camel@bwh-desktop>
 <20110416015938.GB2200@neilslaptop.think-freely.org>
 <20110416091704.4fa62a50@nehalam>
 <20110417172010.GA3362@neilslaptop.think-freely.org>
 <1303065539.5282.938.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Thomas Gleixner <tglx@linutronix.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53388 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab1DRBJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 21:09:05 -0400
Content-Disposition: inline
In-Reply-To: <1303065539.5282.938.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 17, 2011 at 07:38:59PM +0100, Ben Hutchings wrote:
> On Sun, 2011-04-17 at 13:20 -0400, Neil Horman wrote:
> > On Sat, Apr 16, 2011 at 09:17:04AM -0700, Stephen Hemminger wrote:
> [...]
> > > My gut feeling is that:
> > >   * kernel should default to a simple static sane irq policy without user
> > >     space.  This is especially true for multi-queue devices where the default
> > >     puts all IRQ's on one cpu.
> > > 
> > Thats not how it currently works, AFAICS.  The default kernel policy is
> > currently that cpu affinity for any newly requested irq is all cpus.  Any
> > restriction beyond that is the purview and doing of userspace (irqbalance or
> > manual affinity setting).
> 
> Right.  Though it may be reasonable for the kernel to use the hint as
> the initial affinity for a newly allocated IRQ (not sure quite how we
> determine that).
> 
So I understand what your saying here, but I'm having a hard time reconciling
the two notions.  Currently as it stands, affinity_hint gets set by a single
function call in the kernel (irq_set_affinity_hint), and is called by drivers
wishing to guide irqbalances behavior (currently only ixgbe does this).  The
behavior a driver is capable of guiding however are either overly simple (ixgbe
just tells irqbalance to place each irq on a separate cpu, which irqbalance
would do anyway) or overly complex (forcing policy into the kernel, which I
tried to do with this patch series, but based on the responses I've gotten here,
that seems non-desireable).

I personally like the idea of using affinity_hint to export various guidelines
to drive irqbalances behavior, but I think I'm in the minority on that.  Given
the responses here, It almost seems to me like we should do away with
affinity_hint alltogether (or perhaps just continue to ignore it), and rather
export data relevent to balancing in various other locations, and just have
irqbalance use that info directly.


> [...]
> > >   * irqbalance should not do the hacks it does to try and guess at network traffic.
> > > 
> > Well, I can certainly agree with that, but I'm not sure what that looks like.
> > 
> > I could envision something like:
> > 
> > 1) Use irqbalance to do a one time placement of interrupts, keeping a simple
> > (possibly sub-optimal) policy, perhaps something like new irqs get assigned to
> > the least loaded cpu within the numa node of the device the irq is originating
> > from.
> > 
> > 2) Add a udev event on the addition of new interrupts, to rerun irqbalance
> 
> Yes, making irqbalance more (or entirely) event-driven seems like a good
> thing.
> 
Yeah, I can do that, it shouldn't be hard.  Do we need to worry about bursty
interfaces (i.e. irqs that have high volume counts for periods of time followed
by periods of low activity).  A periodic irqbalance can reblance behavior like
that wheras a one-shot cannot.  Can we just assume that the one-shot rebalance
would give a 'good enough' placement in that situation?

> > 3) Add some exported information to identify processes that are high users of
> > network traffic, and correlate that usage to a rxq/irq that produces that
> > information (possibly some per-task proc file)
> > 
> > 4) Create/expand an additional user space daemon to monitor the highest users of
> > network traffic on various rxq/irqs (as identified in (3)) and restrict those
> > processes execution to those cpus which are on the same L2 cache as the irq
> > itself.  The cpuset cgroup could be usefull in doing this perhaps.
> 
> I just don't see that you're going to get processes associated with
> specific RX queues unless you make use of flow steering.
> 
> The 128-entry flow hash indirection table is part of Microsoft's
> requirements for RSS so most multiqueue hardware is going to let you do
> limited flow steering that way.
> 
Yes, Agreed.  I had presumed that any feature like this would assume RFS was
available and enabled. If it wasn't, we'd have to re-implement some metric
gathering code along with code to correlate sockets to rx queues and irqs.  That
would be 90% of the RFS code and this patch series :)

> > Actually, as I read back to myself, that acutally sounds kind of good to me.  It
> > keeps all the policy for this in user space, and minimizes what we have to add
> > to the kernel to make it happen (some process information in /proc and another
> > udev event).  I'd like to get some feedback before I start implementing this,
> > but I think this could be done.  What do you think?
> 
> I don't think it's a good idea to override the scheduler dynamically
> like this.
> 
Why not?  Not disagreeing here, but I'm curious as to why you think this is bad.
We already have several interfaces for doing this in user space (cgroups and
taskset come to mind).  Nominally they are used directly by sysadmins, and used
sparingly for specific configurations.  All I'm suggesting is that we create a
daemon to identify processes that would benefit from running closer to the nics
they are getting data from, and restricting them to cpus that fit that benefit.
If a sysadmin doesn't want that behavior, they can stop the daemon, or change
its configuration to avoid including processes they don't want to move/restrict.

Thanks & Regards
Neil
 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
