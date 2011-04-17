From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Sun, 17 Apr 2011 19:38:59 +0100
Message-ID: <1303065539.5282.938.camel@localhost>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
	 <1302908069.2845.29.camel@bwh-desktop>
	 <20110416015938.GB2200@neilslaptop.think-freely.org>
	 <20110416091704.4fa62a50@nehalam>
	 <20110417172010.GA3362@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Thomas Gleixner <tglx@linutronix.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36993 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab1DQSjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 14:39:04 -0400
In-Reply-To: <20110417172010.GA3362@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 13:20 -0400, Neil Horman wrote:
> On Sat, Apr 16, 2011 at 09:17:04AM -0700, Stephen Hemminger wrote:
[...]
> > My gut feeling is that:
> >   * kernel should default to a simple static sane irq policy without user
> >     space.  This is especially true for multi-queue devices where the default
> >     puts all IRQ's on one cpu.
> > 
> Thats not how it currently works, AFAICS.  The default kernel policy is
> currently that cpu affinity for any newly requested irq is all cpus.  Any
> restriction beyond that is the purview and doing of userspace (irqbalance or
> manual affinity setting).

Right.  Though it may be reasonable for the kernel to use the hint as
the initial affinity for a newly allocated IRQ (not sure quite how we
determine that).

[...]
> >   * irqbalance should not do the hacks it does to try and guess at network traffic.
> > 
> Well, I can certainly agree with that, but I'm not sure what that looks like.
> 
> I could envision something like:
> 
> 1) Use irqbalance to do a one time placement of interrupts, keeping a simple
> (possibly sub-optimal) policy, perhaps something like new irqs get assigned to
> the least loaded cpu within the numa node of the device the irq is originating
> from.
> 
> 2) Add a udev event on the addition of new interrupts, to rerun irqbalance

Yes, making irqbalance more (or entirely) event-driven seems like a good
thing.

> 3) Add some exported information to identify processes that are high users of
> network traffic, and correlate that usage to a rxq/irq that produces that
> information (possibly some per-task proc file)
> 
> 4) Create/expand an additional user space daemon to monitor the highest users of
> network traffic on various rxq/irqs (as identified in (3)) and restrict those
> processes execution to those cpus which are on the same L2 cache as the irq
> itself.  The cpuset cgroup could be usefull in doing this perhaps.

I just don't see that you're going to get processes associated with
specific RX queues unless you make use of flow steering.

The 128-entry flow hash indirection table is part of Microsoft's
requirements for RSS so most multiqueue hardware is going to let you do
limited flow steering that way.

> Actually, as I read back to myself, that acutally sounds kind of good to me.  It
> keeps all the policy for this in user space, and minimizes what we have to add
> to the kernel to make it happen (some process information in /proc and another
> udev event).  I'd like to get some feedback before I start implementing this,
> but I think this could be done.  What do you think?

I don't think it's a good idea to override the scheduler dynamically
like this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

