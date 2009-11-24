From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 11:07:23 +0100 (CET)
Message-ID: <alpine.LFD.2.00.0911241027140.24119@localhost.localdomain>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>  <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>  <1258968980.2697.9.camel@ppwaskie-mobl2> <1258995923.4531.715.camel@laptop>  <Pine.WNT.4.64.0911231529240.10056@ppwaskie-MOBL2.amr.corp.intel.com>
  <1259051902.4531.1053.camel@laptop> <1259053156.2631.21.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <peterz@infradead.org>,
	Yong Zhang <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:54709 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528AbZKXKHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 05:07:41 -0500
In-Reply-To: <1259053156.2631.21.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Nov 2009, Peter P Waskiewicz Jr wrote:
> On Tue, 2009-11-24 at 01:38 -0700, Peter Zijlstra wrote:
> > On Mon, 2009-11-23 at 15:32 -0800, Waskiewicz Jr, Peter P wrote:
> > 
> > > Unfortunately, a driver can't.  The irq_set_affinity() function isn't 
> > > exported.  I proposed a patch on netdev to export it, and then to tie down 
> > > an interrupt using IRQF_NOBALANCING, so irqbalance won't touch it.  That 
> > > was rejected, since the driver is enforcing policy of the interrupt 
> > > balancing, not irqbalance.
> > 
> > Why would a patch touching the irq subsystem go to netdev?
> 
> The only change to the IRQ subsystem was:
> 
> EXPORT_SYMBOL(irq_set_affinity);

Which is still touching the generic irq subsystem and needs the ack of
the relevant maintainer. If there is a need to expose such an
interface to drivers then the maintainer wants to know exactly why and
needs to be part of the discussion of alternative solutions. Otherwise
you waste time on implementing stuff like the current patch which is
definitely not going anywhere near the irq subsystem.

> > If all you want is to expose policy to userspace then you don't need any
> > of this, simply expose the NICs home node through a sysfs device thingy
> > (I was under the impression its already there somewhere, but I can't
> > ever find anything in /sys).
> > 
> > No need what so ever to poke at the IRQ subsystem.
> 
> The point is we need something common that the kernel side (whether a
> driver or /proc can modify) that irqbalance can use.

/sys/class/net/ethX/device/numa_node 

perhaps ?
 
> > > Also, if you use the /proc interface to change smp_affinity on an 
> > > interrupt without any of these changes, irqbalance will override it on its 
> > > next poll interval.  This also is not desirable.
> > 
> > This all sounds backwards.. we've got a perfectly functional interface
> > for affinity -- which people object to being used for some reason. So
> > you add another interface on top, and that is ok?
> > 
> 
> But it's not functional.  If I set the affinity in smp_affinity, then
> irqbalance will override it 10 seconds later.

And to work around the brain wreckage of irqbalanced you want to
fiddle in the irq code instead of teaching irqbalanced to handle node
affinities ?

The only thing which is worth to investigate is whether the irq core
code should honour the dev->numa_node setting and restrict the
possible irq affinity settings to that node. If a device is tied to a
node it makes a certain amount of sense to do that.

But such a change would not need a new interface in the irq core and
definitely not a new cpumask_t member in the irq_desc structure to
store a node affinity which can be expressed with a simple
integer.

But this needs more thoughts and I want to know more about the
background and the reasoning for such a change.

Thanks,

	tglx



