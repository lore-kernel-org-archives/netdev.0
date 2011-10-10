From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 09:32:00 +0200
Message-ID: <1318231920.29415.404.camel@pasglop>
References: <20111004202620.GA3455@oc1711230544.ibm.com>
	 <20111005081502.GB2681@mtldesk30> <20111006135759.GH2681@mtldesk30>
	 <1318145118.29415.371.camel@pasglop> <20111009073546.GI2681@mtldesk30>
	 <1318147254.29415.377.camel@pasglop> <20111009080747.GJ2681@mtldesk30>
	 <1318149536.29415.384.camel@pasglop> <20111009092102.GK2681@mtldesk30>
	 <1318153939.29415.401.camel@pasglop>  <20111009103020.GL2681@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51257 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381Ab1JJHc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 03:32:26 -0400
In-Reply-To: <20111009103020.GL2681@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-10-09 at 12:30 +0200, Eli Cohen wrote:

> > Ideally you want to avoid that swapping altogether and use the right
> > accessor that indicates that your register is BE to start with. IE.
> > remove the swab32 completely and then use something like 
> > iowrite32be() instead of writel().
> I agree, this looks better but does it work on memory mapped io or
> only on io pci space? All our registers are memory mapped...

The iomap functions work on both.

> > Basically, the problem you have is that writel() has an implicit "write
> > to LE register" semantic. Your register is BE. the "iomap" variants
> > provide you with more fine grained "be" variants to use in that case.
> > There's also writel_be() but that one doesn't exist on every
> > architecture afaik.
> So writel_be is the function I should use for memory mapped io? If it
> does not exist for all platforms it's a pitty :-(

Just use the iomap variant. Usually you also use pci_iomap() instead of
ioremap() but afaik, for straight MMIO, it works with normal ioremap as
well.

> > Now, once the mmio problem is out of the way, let's look back at how you
> > then use that qpn.
> > 
> > With the current code, you've generated something in memory which is
> > byte reversed, so essentially "LE" on ppc and "BE" on x86.
> > 
> > Then, this statement:
> > 
> > *(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
> > 
> > Will essentially write it out as-is in memory for use by the chip. The chip,
> > from what you say, expects BE, so this will be broken on PPC.
> I see. So this field is layed in le for ppc and the rest of the
> descriptor is be. so I assum that __iowrite64_copy() does not swap
> anything but we still have tx_desc->ctrl.vlan_tag in the wrong
> endianess.

Yes because you had swapped it initially. IE your original swab32 is
what busts it for you on ppc.

> > Here too, the right solution is to instead not do that swab32 to begin
> > with (ring->doorbell_qpn remains a native endian value) and instead do,
> > in addition to the above mentioned change to the writel:
> > 
> > 	*(u32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
> > 
> > (Also get rid of that cast and define vlan_tag as a __be32 to start
> > with).
> > 
> > Cheers,
> > Ben.
> 
> Thanks for your review. I will send another patch which should fix the
> deficiencies.

Cheers,
Ben.
