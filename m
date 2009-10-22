From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Thu, 22 Oct 2009 01:22:36 -0700
Message-ID: <1256199756.2634.65.camel@ppwaskie-mobl2>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
	 <20091021022713.32449.54868.stgit@localhost.localdomain>
	 <20091021.215031.57955781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38110 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbZJVIX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 04:23:59 -0400
In-Reply-To: <20091021.215031.57955781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-21 at 21:50 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 20 Oct 2009 19:27:14 -0700
> 
> > From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > 
> > This patch will set each MSI-X vector to IRQF_NOBALANCING to
> > prevent autobalance of the interrupts, then applies a CPU
> > affinity.  This will only be done when Flow Director is enabled,
> > which needs interrupts to be processed on the same CPUs where the
> > applications are running.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Just explain to me why irqbalanced in userspace cannot take care
> of this issue.

The problem we have is when Flow Director is enabled, we want to try and
balance the applications across all CPUs.  irqbalance is going to fight
with the scheduler to balance things, and our tests show that irqbalance
only utilizes a few of the CPU cores, not all of them.  That fights
directly with Flow Director and what it's trying to do.

> Second, even if we cannot use irqbalanced for some reason, the last
> thing I want to see is drivers directly fiddling with interrupt
> states and attributes.  Every driver is going to do it every so
> slightly differently, and often will get it wrong.

The first thing any performance guide says is to disable irqbalance, and
affinitize the interrupts in /proc/irq/<irq>/smp_affinity.  This will
ensure the best distribution of work.  The major disadvantage in doing
this is disabling irqbalance affects the entire system.  What this
patchset is trying to do is make sure a single driver, trying to
optimize for performance, doesn't need to affect the entire system.
Setting no-balancing on a vector is the best approach for the entire
system.

I completely understand your concern that this opens precedent for other
drivers to potentially start doing crazy things with interrupts, but
with MSI-X, we're only impacting our driver.

> There is also no global policy or policy control available when
> drivers do this stuff directly.  And that's how we end up with
> situations where every driver behaves differently which results in a
> terrible user experience.

Again, I think the overall impact is worse where the normal approach to
performance tuning is to altogether disable irqbalancing.  The same
effect can be attained by a user disabling irqbalance, and assigning
whatever affinity they want, which could be even more devastating.  What
we're trying to do here is have the driver come as best tuned out of the
box as possible.

If there's something about this particular implementation you're not
comfortable with, I'm very willing to take any feedback on it.  We're
trying to do a specific thing, not lead poor design in drivers when
dealing with interrupts.

Regards,
-PJ Waskiewicz

