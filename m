From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 17:22:09 +0100
Message-ID: <20130916162209.GL12758@n2100.arm.linux.org.uk>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com> <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu> <20130916175152.4e013457@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ethan Tuttle <ethan@ethantuttle.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54931 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab3IPQW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 12:22:56 -0400
Content-Disposition: inline
In-Reply-To: <20130916175152.4e013457@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 05:51:52PM +0200, Thomas Petazzoni wrote:
> Willy, Ethan,
> 
> On Mon, 16 Sep 2013 08:50:47 +0200, Willy Tarreau wrote:
> 
> > I'm currently testing on 3.11.1 (which I had here) and am not getting
> > any issue after 50M packets. My kernel is running in thumb mode and
> > without SMP.
> > 
> > Ethan, we'll need your config I guess.
> 
> Can both of you also report the U-Boot version you're using, and the
> SoC revision (it's visible in the U-Boot output). Maybe Globalscale is
> shipping Mirabox with a different version of the bootloader, or some
> hardware difference, that is causing problems? (I'm just speculating
> here, but another user already reported having issues with his Mirabox,
> and Russell King analyzed the oops as very likely being hardware
> problems).

One seemed to be a single bit error in an instruction inside the kernel
image.  The other was what seems to be an impossible abort.

I still don't see how we could end up with a prefetch abort inside memset()
due to the kernel domain being inaccessible, but still be able to get
an oops out, especially when we dump out the memory for the faulting
instruction by accessing that memory via that apparantly inaccessible
domain while running the code which dumps that memory also under this
apparantly inaccessible domain.  If the domain containing the kernel
really was inaccessible, the system would be completely dead.

The only possibilities I can come up with for that is that abort was
caused by something spurious happening at the hardware level causing
corruption of the instruction TLB (corrupting the domain index stored
in the I-TLB) or other CPU control hardware causing it to spuriously
generate that fault.

As the domain field in the page table L1 entries covers bit 8, and the
single bit error with the instruction was also bit 8, maybe there's a
design weakness on data line bit 8 causing marginal operation.

To add to this, the abort given in this report gives an IFSR value of
0x409, which equates to "Synchronous parity error on memory access"
in ARMv7.  The other value (0x400) equates to "TLB conflict abort"
which can only happen with LPAE support enabled...  So this is just
getting more weird!
