From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net: Automatic IRQ siloing for network devices
Date: Sat, 16 Apr 2011 09:17:04 -0700
Message-ID: <20110416091704.4fa62a50@nehalam>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
	<1302908069.2845.29.camel@bwh-desktop>
	<20110416015938.GB2200@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33643 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab1DPQRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 12:17:11 -0400
In-Reply-To: <20110416015938.GB2200@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011 21:59:38 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Fri, Apr 15, 2011 at 11:54:29PM +0100, Ben Hutchings wrote:
> > On Fri, 2011-04-15 at 16:17 -0400, Neil Horman wrote:
> > > Automatic IRQ siloing for network devices
> > > 
> > > At last years netconf:
> > > http://vger.kernel.org/netconf2010.html
> > > 
> > > Tom Herbert gave a talk in which he outlined some of the things we can do to
> > > improve scalability and througput in our network stack
> > > 
> > > One of the big items on the slides was the notion of siloing irqs, which is the
> > > practice of setting irq affinity to a cpu or cpu set that was 'close' to the
> > > process that would be consuming data.  The idea was to ensure that a hard irq
> > > for a nic (and its subsequent softirq) would execute on the same cpu as the
> > > process consuming the data, increasing cache hit rates and speeding up overall
> > > throughput.
> > > 
> > > I had taken an idea away from that talk, and have finally gotten around to
> > > implementing it.  One of the problems with the above approach is that its all
> > > quite manual.  I.e. to properly enact this siloiong, you have to do a few things
> > > by hand:
> > > 
> > > 1) decide which process is the heaviest user of a given rx queue 
> > > 2) restrict the cpus which that task will run on
> > > 3) identify the irq which the rx queue in (1) maps to
> > > 4) manually set the affinity for the irq in (3) to cpus which match the cpus in
> > > (2)
> > [...]
> > 
> > This presumably works well with small numbers of flows and/or large
> > numbers of queues.  You could scale it up somewhat by manipulating the
> > device's flow hash indirection table, but that usually only has 128
> > entries.  (Changing the indirection table is currently quite expensive,
> > though that could be changed.)
> > 
> > I see RFS and accelerated RFS as the only reasonable way to scale to
> > large numbers of flows.  And as part of accelerated RFS, I already did
> > the work for mapping CPUs to IRQs (note, not the other way round).  If
> > IRQ affinity keeps changing then it will significantly undermine the
> > usefulness of hardware flow steering.
> > 
> > Now I'm not saying that your approach is useless.  There is more
> > hardware out there with flow hashing than with flow steering, and there
> > are presumably many systems with small numbers of active flows.  But I
> > think we need to avoid having two features that conflict and a
> > requirement for administrators to make a careful selection between them.
> > 
> > Ben.
> > 
> I hear what your saying and I agree, theres no point in having features work
> against each other.  That said, I'm not sure I agree that these features have to
> work against one another, nor does a sysadmin need to make a choice between the
> two.  Note the third patch in this series.  Making this work requires that
> network drivers wanting to participate in this affinity algorithm opt in by
> using the request_net_irq macro to attach the interrupt to the rfs affinity code
> that I added.  Theres no reason that a driver which supports hardware that still
> uses flow steering can't opt out of this algorithm, and as a result irqbalance
> will still treat those interrupts as it normally does.  And for those drivers
> which do opt in, irqbalance can take care of affinity assignment, using the
> provided hint.  No need for sysadmin intervention.
> 
> I'm sure there can be improvements made to this code, but I think theres less
> conflict between the work you've done and this code than there appears to be at
> first blush.
> 

My gut feeling is that:
  * kernel should default to a simple static sane irq policy without user
    space.  This is especially true for multi-queue devices where the default
    puts all IRQ's on one cpu.

  * irqbalance should do a one-shot rearrangement at boot up. It should rearrange
    when new IRQ's are requested. The kernel should have capablity to notify
    userspace (uevent?) when IRQ's are added or removed.

  * Let scheduler make decisions about migrating processes (rather than let irqbalance
    migrate IRQ's).

  * irqbalance should not do the hacks it does to try and guess at network traffic.


-- 
