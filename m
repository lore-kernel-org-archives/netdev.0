From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 5/8] smc91x: add SMC91X_IO_SHIFT* macros and make
 SMC_IO_SHIFT a variable
Date: Fri, 20 Jun 2008 08:02:18 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806200754030.23059@xanadu.home>
References: <485A3E0B.1080505@gmail.com>
 <alpine.LFD.1.10.0806191223390.2982@xanadu.home> <485B2850.5050004@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:49443 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYFTMCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 08:02:19 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2R00IDZG3UQWD0@VL-MO-MR003.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 20 Jun 2008 08:02:19 -0400 (EDT)
In-reply-to: <485B2850.5050004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008, Eric Miao wrote:

> Nicolas Pitre wrote:
> > On Thu, 19 Jun 2008, Eric Miao wrote:
> > 
> >> SMC_IO_SHIFT is currently hardcoded, which makes some platforms (e.g.
> >> Lubbock) unable to use the newly introduced platform data. This patch
> >> introduces SMC91X_IO_SHIFT* macros and make SMC_IO_SHIFT a variable.
> >>
> >> Signed-off-by: Eric Miao <eric.miao@marvell.com>
> > 
> > NAK.
> > 
> > The very point of those macros is actually to optimize the IO accesses 
> > as much as possible at compile time.  By introducing a variable element 
> > in the definition of those macros (for when the driver is configured 
> > with constant params for those macros of course) you add a significant 
> > overhead to every access to the hardware, including when transferring 
> > data in and out of the chip.
> > 
> 
> Contrary to expected, the result shows a slight decrease on zylonite,
> PXA310@624MHz, result shown as below:
> 
> (by a simple measurement with "proc/uptime" and tftp)
> 
> with SMC_IO_SHIFT being a variable
> 
> trial 1: 2062776 bytes in (179.77 - 177.72 = 2.05) seconds = 1,006,232 Bps
> trial 2: 2062776 bytes in (183.00 - 180.95 = 2.05) seconds = 1,006,232 Bps
> trial 3: 2062776 bytes in (261.48 - 259.42 = 2.06) seconds = 1,001,347 Bps
> 
> with SMC_IO_SHIFT being a constant
> 
> trial 1: 2062776 bytes in (41.07 - 39.04 = 2.03) seconds = 1,016,145 Bps
> trial 2: 2062776 bytes in (97.19 - 95.16 = 2.03) seconds = 1,016,145 Bps
> trial 3: 2062776 bytes in (159.81 - 157.78 = 2.03) seconds = 1,016,145 Bps
> 
> The statistics were stable during the test, so I generally think it's
> typical.
> 
> On lubbock, PXA255@200MHz, however, the result shows a slight increase:
> 
> with SMC_IO_SHIFT being a variable
> 
> trial 1: 2062776 bytes in (49.42 - 42.20 = 7.22) seconds = 285,703 Bps
> trial 2: 2062776 bytes in (60.27 - 53.07 = 7.20) seconds = 286,497 Bps
> trial 3: 2062776 bytes in (141.04 - 133.84 = 7.20) seconds = 286,497 Bps
> 
> with SMC_IO_SHIFT being a constant
> 
> trial 1: 2062776 bytes in (58.93 - 51.62 = 7.31) seconds = 282,185 Bps
> trial 2: 2062776 bytes in (69.26 - 61.95 = 7.31) seconds = 282,185 Bps
> trial 3: 2062776 bytes in (151.58 - 144.27 = 7.31) seconds = 282,185 Bps
> 
> So I'm thinking that the overhead may not be so significant as expected,
> 1. control register accesses are rare compared to data register
> 2. data register access is usually fixed at one address and enclosed in
>    a loop, which the compiler may well optimize

You must also look at the CPU usage too.  A faster CPU may well mitigate 
the latency issue and make no significant throughput difference, but at 
a higher CPU cost.  That means fewer cycles for doing anything else, 
like drawing those pictures on the screen as they are received over the 
net for example.

> > And this is very important to have the lowest overhead possible with 
> > this chip that can do 100mbps on platforms with a CPU clock almost as 
> > slow.
> > 
> 
> Indeed, the overhead will be magnified on a system with slow CPU clock,
> maybe I should spend some time to have a test also. However, arguably,
> the smc91x chips are usually used as a debug ethernet on most (if not
> all) platforms, I don't think a serious design will deploy such a chip
> for performance critical application, though.

That's not acceptable as an argument to introduce what actually is a 
regression, especially when it should be possible to avoid it.  And the 
fact is that there are already designs out there using this chip in 
production, serious or not.


Nicolas
