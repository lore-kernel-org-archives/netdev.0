From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Thu, 6 Jan 2011 00:50:52 +0000
Message-ID: <20110106005052.GA4476@shareable.org>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-9-git-send-email-shawn.guo@freescale.com> <20110105161235.GA2112@gallagher> <20110105164409.GV25121@pengutronix.de> <20110105172501.GB2112@gallagher> <20110105175617.GD12222@shareable.org> <20110105183509.GH8638@n2100.arm.linux.org.uk> <20110105194418.GE12222@shareable.org> <20110105201502.GK8638@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, bryan.wu@canonical.com, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com,
	Shawn Guo <shawn.guo@freescale.com>, eric@eukrea.com,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:39616 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab1AFAvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 19:51:15 -0500
Content-Disposition: inline
In-Reply-To: <20110105201502.GK8638@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux wrote:
> On Wed, Jan 05, 2011 at 07:44:18PM +0000, Jamie Lokier wrote:
> > 'git show 534be1d5' explains how it works: cpu_relax() flushes buffered
> > writes from _this_ CPU, so that other CPUs which are polling can make
> > progress, which avoids this CPU getting stuck if there is an indirect
> > dependency (no matter how convoluted) between what it's polling and which
> > it wrote just before.
> > 
> > So cpu_relax() is *essential* in some polling loops, not a hint.
> > 
> > In principle that could happen for I/O polling, if (a) buffered memory
> > writes are delayed by I/O read transactions, and (b) the device state we're
> > waiting on depends on I/O yet to be done on another CPU, which could be
> > polling memory first (e.g. a spinlock).
> > 
> > I doubt (a) in practice - but what about buses that block during I/O read?
> > (I have a chip like that here, but it's ARMv4T.)
> 
> Let's be clear - ARMv5 and below generally are well ordered architectures
> within the limits of caching.  There are cases where the write buffer
> allows two writes to pass each other.  However, for IO we generally map
> these - especially for ARMv4 and below - as 'uncacheable unbufferable'.
> So on these, if the program says "read this location" the pipeline will
> stall until the read has been issued - and if you use the result in the
> next instruction, it will stall until the data is available.  So really,
> it's not a problem here.
> 
> ARMv6 and above have a weakly ordered memory model with speculative
> prefetching, so memory reads/writes can be completely unordered.  Device
> accesses can pass memory accesses, but device accesses are always visible
> in program order with respect to each other.
> 
> So, if you're spinning in a loop reading an IO device, all previous IO
> accesses will be completed (in all ARM architectures) before the result
> of your read is evaluated.

No, that wasn't the scenario - it was:

You're spinning reading an IO device, whose state depends indirectly
on a *CPU memory* write that is forever buffered.

(Go and re-read 'git show 534be1d5' if you haven't already.)

The indirect dependence is that another CPU needs to see that write
before it can tell the device to change state in whatever way the
first CPU is polling for.

It's probably clearer in code:

CPU #1

    spin_lock(&mydev->lock);
    /* Look at state. */
    spin_unlock(&mydev->lock);       <-- THIS MEMORY WRITE BUFFERED FOREVER

    /* We expect this to be quick enough that polling is cool. */
    while (readl(mydev->reg_status) & MYDEV_STATUS_BUSY) {
        /* If only we had cpu_relax() */
    }

CPU #2

    spin_lock(&mydev->lock);         <-- STUCK HERE
    /* Look at state. */
    spin_unlock(&mydev->lock);

    writel(MYDEV_TRIGGER, mydev->reg_go);   /* Device is BUSY until this. */

The deadlock in this code (might) happen when CPU #2 is waiting for
the spinlock, and CPU #1's memory write remains in its write buffer
during CPU #1's polling loop.

If that can happen, it's fixed by adding cpu_relax() - to generic
driver code with polling loops.

It can only happen if any CPUs (i.e. ARMv6) that buffer writes due to
prioritising continuous memory reads also have that effect for
continuous IO reads.  This might even apply to non-ARM archs with
non-trivial cpu_relax() definitions; I don't know as they don't always
explain why.

The above driver style isn't particularly obvious, but there are a lot
of drivers with almost every conceivable access pattern.  If you use
your imagination, especially if the second code is an interrupt
handler, it's plausible.  Even though this example would be better
sleeping and waiting normally - there's nothing inherently forbidden
about the above pattern (except that cpu_relax() is needed).

> (But, let's make you squirm some more - mb() on ARMv6 and above may
> equate to a CPU memory barrier _plus_ a few IO accesses to the external
> L2 cache controller - which will be ordered wrt other IO accesses of
> course.)

I squirm at all modern ARM architectures.  Omit the slightest highly
version-specific thing, or run a kernel built with slightly wrong
config options, and it's fine except for random, very rare memory or
I/O corruption.  The workarounds and special bits seem to get more and
more convoluted with each version.

-- Jamie
