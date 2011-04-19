From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Mon, 18 Apr 2011 20:52:37 -0400
Message-ID: <20110419005237.GA2040@neilslaptop.think-freely.org>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
 <1302908069.2845.29.camel@bwh-desktop>
 <20110416015938.GB2200@neilslaptop.think-freely.org>
 <20110416091704.4fa62a50@nehalam>
 <20110417172010.GA3362@neilslaptop.think-freely.org>
 <1303065539.5282.938.camel@localhost>
 <20110418010844.GA4376@neilslaptop.think-freely.org>
 <1303163494.2857.98.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Thomas Gleixner <tglx@linutronix.de>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39976 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab1DSAw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 20:52:57 -0400
Content-Disposition: inline
In-Reply-To: <1303163494.2857.98.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 10:51:34PM +0100, Ben Hutchings wrote:
> On Sun, 2011-04-17 at 21:08 -0400, Neil Horman wrote:
> > On Sun, Apr 17, 2011 at 07:38:59PM +0100, Ben Hutchings wrote:
> > > On Sun, 2011-04-17 at 13:20 -0400, Neil Horman wrote:
> > > > On Sat, Apr 16, 2011 at 09:17:04AM -0700, Stephen Hemminger wrote:
> > > [...]
> > > > > My gut feeling is that:
> > > > >   * kernel should default to a simple static sane irq policy without user
> > > > >     space.  This is especially true for multi-queue devices where the default
> > > > >     puts all IRQ's on one cpu.
> > > > > 
> > > > Thats not how it currently works, AFAICS.  The default kernel policy is
> > > > currently that cpu affinity for any newly requested irq is all cpus.  Any
> > > > restriction beyond that is the purview and doing of userspace (irqbalance or
> > > > manual affinity setting).
> > > 
> > > Right.  Though it may be reasonable for the kernel to use the hint as
> > > the initial affinity for a newly allocated IRQ (not sure quite how we
> > > determine that).
> > > 
> > So I understand what your saying here, but I'm having a hard time reconciling
> > the two notions.  Currently as it stands, affinity_hint gets set by a single
> > function call in the kernel (irq_set_affinity_hint), and is called by drivers
> > wishing to guide irqbalances behavior (currently only ixgbe does this).  The
> > behavior a driver is capable of guiding however are either overly simple (ixgbe
> > just tells irqbalance to place each irq on a separate cpu, which irqbalance
> > would do anyway)
> 
> It's a bit more subtle than that.
> 
> ixgbe is trying to set up hardware flow steering.  Some versions of the
> hardware can steer packets to RX queues based on the TX queue that was
> last used for the same flow.  The TX queue selection based on CPU in
> ixgbe_select_queue() should be the inverse of the IRQ affinity mapping
> of RX queues, and the affinity hints are supposed to ensure that this is
> true.
> 
Ah, ok, that makes a bit more sense then.  Thank you for that.

> I think it should be possible to replace those hints with use of
> irq_cpu_rmap for TX queue selection.
> 
> > or overly complex (forcing policy into the kernel, which I
> > tried to do with this patch series, but based on the responses I've gotten here,
> > that seems non-desireable).
> 
> The trouble is that irqbalance has been so bad for multiqueue net
> devices in the past that many vendors (including Solarflare) recommended
> that it be disabled.  I think irqbalance does sensible things now but
> many systems will be running without it for some time to come.
> 
> I was thinking that if the drivers could set sane hints to start with
> then it would improve matters for those systems without irqbalance.  But
> maybe it would be better still for some part of the networking core or
> IRQ core to set up a default spreading of multiqueue IRQs.
>
But doesn't this force policy for irqbalancing into the kernel, as Thomas and
Eric alluded to?  It seems to me that, if we can export just a bit more
information regarding irqs and their associations to devices (which has been a
major achilles heel of irqblance in the past), then I think we can create a sane
default balancing policy with some simple udev rules.  I've been messing with
this a bit today.
 
> [...]
> > > > Actually, as I read back to myself, that acutally sounds kind of good to me.  It
> > > > keeps all the policy for this in user space, and minimizes what we have to add
> > > > to the kernel to make it happen (some process information in /proc and another
> > > > udev event).  I'd like to get some feedback before I start implementing this,
> > > > but I think this could be done.  What do you think?
> > > 
> > > I don't think it's a good idea to override the scheduler dynamically
> > > like this.
> > > 
> > Why not?  Not disagreeing here, but I'm curious as to why you think this is bad.
> > We already have several interfaces for doing this in user space (cgroups and
> > taskset come to mind).  Nominally they are used directly by sysadmins, and used
> > sparingly for specific configurations.
> 
> Yes, that is why I think this is different.
> 
Ok, fair enough.

> > All I'm suggesting is that we create a
> > daemon to identify processes that would benefit from running closer to the nics
> > they are getting data from, and restricting them to cpus that fit that benefit.
> > If a sysadmin doesn't want that behavior, they can stop the daemon, or change
> > its configuration to avoid including processes they don't want to move/restrict.
> 
> I think this could improve latency under low CPU load and throughput
> under high CPU load for small numbers of relatively long-lived flows.
> But for large numbers of flows or high turnover of flows the affinity
> will just be noise.
> 
> You're welcome to do your own experiments, obviously!
> 
I will, but I'll start with the low hanging fruit.  I'm going to try exporting
the msi table for a device.  With that I can use the netdev_registration uevent
to properly identify network based irqs without the need for 1/2 assed regex
searches and volume counts and do one shot rebalancing of them.

Thanks for your time & thoughts!
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
