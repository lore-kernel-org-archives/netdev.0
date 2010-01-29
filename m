From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: receive-side performance issue (ixgbe, core-i7, softirq cpu%)
Date: Thu, 28 Jan 2010 16:18:02 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001281135110.360@jbrandeb-desk1.amr.corp.intel.com>
References: <606676311001280023j77b8b96aj556706f3e49bcc13@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39741 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab0A2ASG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 19:18:06 -0500
In-Reply-To: <606676311001280023j77b8b96aj556706f3e49bcc13@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 28 Jan 2010, Andrew Dickinson wrote:
> I'm running into some unexpected performance issues.  I say
> "unexpected" because I was running the same tests on this same box 5
> months ago and getting very different (and much better) results.


can you try turning off cpuspeed service, C-States in BIOS, and GV3 (aka 
speedstep) support in BIOS?

Have you upgraded your BIOS since before?

I agree you should be able to see better numbers, I suspect that you are 
getting cross-cpu traffic that is limiting your throughput.

How many flows are you pushing?

Another idea is to compile the "perf" tool in the tools/perf directory of 
the kernel and run "perf record -a -- sleep 10" while running at steady 
state.  then show output of perf report to get an idea of which functions 
are eating all the cpu time.

did you change to the "tickless" kernel?  We've also found that routing 
performance improves dramatically by disabling tickless, preemptive kernel 
and setting HZ=100.  What about CONFIG_HPET?

You should try the kernel that the scheduler fixes went into (maybe 31?) 
or at least try 2.6.32.6 so you've tried something fully up to date.

> === Background ===
> 
> The box is a dual Core i7 box with a pair of Intel 82598EB's.  I'm
> running 2.6.30 with the in-kernel ixgbe driver.  My tests 5 months ago
> were using 2.6.30-rc3 (with a tiny patch from David Miller as seen
> here: http://kerneltrap.org/mailarchive/linux-netdev/2009/4/30/5605924).
>  The box is configured with both NICs in a bridge; normally I'm doing
> some packet processing using ebtables, but for the sake of keeping
> things simple, I'm not doing anything special.. just straight bridging
> (no ebtables rules, etc).  I'm not running irqbalance and instead
> pinning my interrupts, one per core.  I've re-read and double checked
> various settings based on Intel's README (i.e. gso off, tso off, etc).
> 
> In my previous tests, i was able to pass 3+Mpps regardless of how that
> was divided across the two NICS (i.e. 3Mpps all in one direction,
> 1.5Mpps in each direction simultaneously, etc).  Now, I'm hardly able
> to exceed about 750kpps x 2 (i.e. 750k in both directions), and I
> can't do more than 750kpps in one direction even with the other
> direction having no traffic).
> 
> Unfortunately, I didn't take very good notes when I did this last time
> so I don't have my previous .config and I'm not 100% positive I've got
> identical ethtool settings, etc.  That being said, I've worked through
> seemingly every combination of factors that I can think of and I'm
> still unable to see the old performance (NUMA on/off, Hyperthreading
> on/off, various irq coelescing settings, etc).
> 
> I have two identical boxes, they both see the same thing; so a
> hardware issue seems unlikely.  My next step is to grab 2.6.30-rc3 and
> see if I can repro the good performance with that kernel again and
> determine if there was a regression between 2.6.30-rc3 and 2.6.30...
> but I'm skeptical that that's the issue since I'm sure other people
> would have noticed this as well.
> 
> 
> === What I'm seeing ===
> 
> CPU% (almost entirely softirq time, which is expected) ramps extremely
> quickly as packet rate increases.  The following table show the packet
> rate ("150 x 2" means 150kpps in each direction simultaneously), the
> right side is the cpu utilization (as measured by %si in top).
> 
> 150 x 2:   4%
> 300 x 2:   8%
> 450 x 2:  18%
> 483 x 2:  50%
> 525 x 2:  66%
> 600 x 2:  85%
> 750 x 2: 100% (and dropping frames)
> 
> I _am_ seeing interrupts getting spread nicely across cores, so in the
> "150 x 2" case, that's about 4% soft-interrupt time per each of the 16
> cores.   The CPUs are otherwise idle bar a small amount of hardware
> interrupt time (less than 1%).
> 
> 
> === Where it gets weird... ===
> 
> Trying to isolate the problem, I added an ebtables rule to drop
> everything on the forward chain.  I was expecting to see the CPU
> utilization drop since I'd no longer be dealing with the TX-side... no
> change.
> 
> I then decided to switch from a bridge to a route-based solution.  I
> tore down the bridge, enabled ip_forward, setup some IPs and route
> entries, etc.  Nothing changes.  CPU performance is identical to
> what's shown above.  Additionally, if I add an iptables drop on
> FORWARD, the CPU utilization remains unchanged (just like in the
> bridging case above).
> 
> The point that [I think] I'm driving to is that there's something
> fishy going on with the receive-side of the packets.  I wish I could
> point to something more specific or a section of code, but I haven't
> been able to par this down to anything more granular in my testing.
> 
> 
> === Questions ===
> 
> Has anybody seen this before?  If so, what was wrong?
> Do you have any recommendations on things to try (either as guesses
> or, even better, to help eliminate possibilities)
> And along those lines... can anybody think of any possible reasons for this?

hope the above helped.
 
> This is so frustrating since I _know_ this hardware is capable of so
> much more.  It's relatively painless for me to re-run tests in my lab,
> so feel free to throw something at me that you think will stick :D

last I checked, I recall with 82599 I was pushing ~4.5 million 64 byte 
packets a second (bidirectional, no drop), after disabling irqbalance and 
16 tx/rx queues set with set_irq_affinity.sh script (available in our 
ixgbe-foo.tar.gz from sourceforge).  82598 should be a bit lower, but 
probably can get close to that number.

I haven't run the test lately though, but at that point I was likely on 
2.6.30 ish

Jesse
