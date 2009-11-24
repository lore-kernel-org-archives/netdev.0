From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 09:55:19 -0800
Message-ID: <1259085319.2631.46.camel@ppwaskie-mobl2>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	 <1258968980.2697.9.camel@ppwaskie-mobl2> <1258995923.4531.715.camel@laptop>
	 <Pine.WNT.4.64.0911231529240.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1259051902.4531.1053.camel@laptop>
	 <1259053156.2631.21.camel@ppwaskie-mobl2>
	 <alpine.LFD.2.00.0911241027140.24119@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Yong Zhang <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60174 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933553AbZKXRzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 12:55:09 -0500
In-Reply-To: <alpine.LFD.2.00.0911241027140.24119@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 03:07 -0700, Thomas Gleixner wrote:
> On Tue, 24 Nov 2009, Peter P Waskiewicz Jr wrote:
> > On Tue, 2009-11-24 at 01:38 -0700, Peter Zijlstra wrote:
> > > On Mon, 2009-11-23 at 15:32 -0800, Waskiewicz Jr, Peter P wrote:
> > > 
> > > > Unfortunately, a driver can't.  The irq_set_affinity() function isn't 
> > > > exported.  I proposed a patch on netdev to export it, and then to tie down 
> > > > an interrupt using IRQF_NOBALANCING, so irqbalance won't touch it.  That 
> > > > was rejected, since the driver is enforcing policy of the interrupt 
> > > > balancing, not irqbalance.
> > > 
> > > Why would a patch touching the irq subsystem go to netdev?
> > 
> > The only change to the IRQ subsystem was:
> > 
> > EXPORT_SYMBOL(irq_set_affinity);
> 
> Which is still touching the generic irq subsystem and needs the ack of
> the relevant maintainer. If there is a need to expose such an
> interface to drivers then the maintainer wants to know exactly why and
> needs to be part of the discussion of alternative solutions. Otherwise
> you waste time on implementing stuff like the current patch which is
> definitely not going anywhere near the irq subsystem.
> 

Understood, and duly noted.

> > > If all you want is to expose policy to userspace then you don't need any
> > > of this, simply expose the NICs home node through a sysfs device thingy
> > > (I was under the impression its already there somewhere, but I can't
> > > ever find anything in /sys).
> > > 
> > > No need what so ever to poke at the IRQ subsystem.
> > 
> > The point is we need something common that the kernel side (whether a
> > driver or /proc can modify) that irqbalance can use.
> 
> /sys/class/net/ethX/device/numa_node 
> 
> perhaps ?

What I'm trying to do though is one to many NUMA node assignments.  See
below for a better overview of what the issue is we're trying to solve.

>  
> > > > Also, if you use the /proc interface to change smp_affinity on an 
> > > > interrupt without any of these changes, irqbalance will override it on its 
> > > > next poll interval.  This also is not desirable.
> > > 
> > > This all sounds backwards.. we've got a perfectly functional interface
> > > for affinity -- which people object to being used for some reason. So
> > > you add another interface on top, and that is ok?
> > > 
> > 
> > But it's not functional.  If I set the affinity in smp_affinity, then
> > irqbalance will override it 10 seconds later.
> 
> And to work around the brain wreckage of irqbalanced you want to
> fiddle in the irq code instead of teaching irqbalanced to handle node
> affinities ?
> 
> The only thing which is worth to investigate is whether the irq core
> code should honour the dev->numa_node setting and restrict the
> possible irq affinity settings to that node. If a device is tied to a
> node it makes a certain amount of sense to do that.
> 
> But such a change would not need a new interface in the irq core and
> definitely not a new cpumask_t member in the irq_desc structure to
> store a node affinity which can be expressed with a simple
> integer.
> 
> But this needs more thoughts and I want to know more about the
> background and the reasoning for such a change.
> 

I'll use the ixgbe driver as my example, since that is where my
immediate problems are.  This is our 10GbE device, and supports 128 Rx
queues, 128 Tx queues, and has a maximum of 64 MSI-X vectors.  In a
typical case, let's say an 8-core machine (Nehalem-EP with
hyperthreading off) brings one port online.  We'll allocate 8 Rx and 8
Tx queues.  When these allocations occur, we want to allocate the memory
for our descriptor rings and buffer structs and DMA areas onto the
various NUMA nodes.  This will promote spreading of the load not just
across CPUs, but also the memory controllers.

If we were to just run like that and have irqbalance move our vectors to
a single node, then we'd have half of our network resources creating
cross-node traffic, which is undesirable, since the OS may have to take
locks node to node to get the memory it's looking for.

The bottom line is we need some mechanism that allows a driver/user to
deterministically assign the underlying interrupt resources to the
correct NUMA node for each interrupt.  And in the example above, we may
have more than one NUMA node we need to balance into.

Please let me know if I've explained this well enough.  I appreciate the
time.

Cheers,
-PJ Waskiewicz

