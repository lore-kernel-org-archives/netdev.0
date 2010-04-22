From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 22 Apr 2010 16:41:40 +0100
Message-ID: <1271950900.2095.25.camel@achroite.uk.solarflarecom.com>
References: <20100420180112.1276.11906.stgit@ppwaskie-hc2.jf.intel.com>
	 <1271854785.2101.17.camel@achroite.uk.solarflarecom.com>
	 <Pine.WNT.4.64.1004220459110.3324@PPWASKIE-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10511 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab0DVPlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 11:41:45 -0400
In-Reply-To: <Pine.WNT.4.64.1004220459110.3324@PPWASKIE-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 05:11 -0700, Peter P Waskiewicz Jr wrote:
> On Wed, 21 Apr 2010, Ben Hutchings wrote:
> 
> > On Tue, 2010-04-20 at 11:01 -0700, Peter P Waskiewicz Jr wrote:
> >> This patch adds a callback function pointer to the irq_desc
> >> structure, along with a registration function and a read-only
> >> proc entry for each interrupt.
> >>
> >> This affinity_hint handle for each interrupt can be used by
> >> underlying drivers that need a better mechanism to control
> >> interrupt affinity.  The underlying driver can register a
> >> callback for the interrupt, which will allow the driver to
> >> provide the CPU mask for the interrupt to anything that
> >> requests it.  The intent is to extend the userspace daemon,
> >> irqbalance, to help hint to it a preferred CPU mask to balance
> >> the interrupt into.
> >
> > Doesn't it make more sense to have the driver follow affinity decisions
> > made from user-space?  I realise that reallocating queues is disruptive
> > and we probably don't want irqbalance to trigger that, but there should
> > be a mechanism for the administrator to trigger it.
> 
> The driver here would be assisting userspace (irqbalance) to provide 
> better details how the HW is laid out with respect to flows.  As it stands 
> today, irqbalance is almost guaranteed to move interrups to CPUs that are 
> not aligned with where applications are running for network adapters. 
> This is very apparent when running at speeds in the 10 Gigabit range, or 
> even multiple 1 Gigabit ports running at the same time.

I'm well aware that irqbalance isn't making good decisions at the
moment.  The question is whether this will really help irqbalance to do
better.

[...]
> > This just assigns IRQs to the first n CPU threads.  Depending on the
> > enumeration order, this might result in assigning an IRQ to each of 2
> > threads on a core while leaving other cores unused!
> 
> This ixgbe patch is only meant to be an example of how you could use it. 
> I didn't hammer out all the corner cases of interrupt alignment in it yet. 
> However, ixgbe is already aligning Tx flows onto the CPU/queue pair the Tx 
> occurred (i.e. Tx session from CPU 4 will be queued on Tx queue 4),
[...]

OK, now I remember ixgbe has this odd select_queue() implementation.
But this behaviour can result in reordering whenever a user thread
migrates, and in any case Dave discourages people from setting
select_queue().  So I see that these changes would be useful for ixgbe
(together with an update to irqbalance), but they don't seem to fit the
general direction of multiqueue networking on Linux.

(Actually, the hints seem to be incomplete.  If there are more than 16
CPU threads then multiple CPU threads can map to the same queues, but it
looks like you only include the first in the queue's hint.)

An alternate approach is to use the RX queue index to drive TX queue
selection.  I posted a patch to do that earlier this week.  However I
haven't yet had a chance to try that on a suitably large system.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

