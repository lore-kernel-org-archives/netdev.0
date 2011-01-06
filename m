From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Thu, 6 Jan 2011 09:13:01 +0000
Message-ID: <20110106091301.GS8638@n2100.arm.linux.org.uk>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-9-git-send-email-shawn.guo@freescale.com> <20110105161235.GA2112@gallagher> <20110105164409.GV25121@pengutronix.de> <20110105172501.GB2112@gallagher> <20110105175617.GD12222@shareable.org> <20110105183509.GH8638@n2100.arm.linux.org.uk> <20110105194418.GE12222@shareable.org> <20110105201502.GK8638@n2100.arm.linux.org.uk> <20110106005052.GA4476@shareable.org>
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
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:58650 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab1AFJNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 04:13:49 -0500
Content-Disposition: inline
In-Reply-To: <20110106005052.GA4476@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 06, 2011 at 12:50:52AM +0000, Jamie Lokier wrote:
> Russell King - ARM Linux wrote:
> > On Wed, Jan 05, 2011 at 07:44:18PM +0000, Jamie Lokier wrote:
> > > 'git show 534be1d5' explains how it works: cpu_relax() flushes buffered
> > > writes from _this_ CPU, so that other CPUs which are polling can make
> > > progress, which avoids this CPU getting stuck if there is an indirect
> > > dependency (no matter how convoluted) between what it's polling and which
> > > it wrote just before.
> > > 
> > > So cpu_relax() is *essential* in some polling loops, not a hint.
> > > 
> > > In principle that could happen for I/O polling, if (a) buffered memory
> > > writes are delayed by I/O read transactions, and (b) the device state we're
> > > waiting on depends on I/O yet to be done on another CPU, which could be
> > > polling memory first (e.g. a spinlock).
> > > 
> > > I doubt (a) in practice - but what about buses that block during I/O read?
> > > (I have a chip like that here, but it's ARMv4T.)
> > 
> > Let's be clear - ARMv5 and below generally are well ordered architectures
> > within the limits of caching.  There are cases where the write buffer
> > allows two writes to pass each other.  However, for IO we generally map
> > these - especially for ARMv4 and below - as 'uncacheable unbufferable'.
> > So on these, if the program says "read this location" the pipeline will
> > stall until the read has been issued - and if you use the result in the
> > next instruction, it will stall until the data is available.  So really,
> > it's not a problem here.
> > 
> > ARMv6 and above have a weakly ordered memory model with speculative
> > prefetching, so memory reads/writes can be completely unordered.  Device
> > accesses can pass memory accesses, but device accesses are always visible
> > in program order with respect to each other.
> > 
> > So, if you're spinning in a loop reading an IO device, all previous IO
> > accesses will be completed (in all ARM architectures) before the result
> > of your read is evaluated.
> 
> No, that wasn't the scenario - it was:
> 
> You're spinning reading an IO device, whose state depends indirectly
> on a *CPU memory* write that is forever buffered.
> 
> (Go and re-read 'git show 534be1d5' if you haven't already.)

I know what that's about, and it's about memory based accesses _only_.

What you're talking about is a programming error.  Such errors cause
data corruption if you're talking about DMA stuff.

At the moment, the solution to that is to put whatever's necessary into
readl/writel to ensure that they behave as ordered operations with
respect to everything else.  You'll find that on ARM, writel has a
barrier before it to ensure memory writes are visible before the device
write, and on readl there's a barrier to ensure that no memory read can
happen before the IO device read.

cpu_relax() has nothing to do with ensuring ordering with devices.

With relaxed IO operations, the responsibility for ensuring proper ordering
between memory and IO falls to the programmer.
