From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 9 Oct 2011 12:30:20 +0200
Message-ID: <20111009103020.GL2681@mtldesk30>
References: <20111004202620.GA3455@oc1711230544.ibm.com>
 <20111005081502.GB2681@mtldesk30>
 <20111006135759.GH2681@mtldesk30>
 <1318145118.29415.371.camel@pasglop>
 <20111009073546.GI2681@mtldesk30>
 <1318147254.29415.377.camel@pasglop>
 <20111009080747.GJ2681@mtldesk30>
 <1318149536.29415.384.camel@pasglop>
 <20111009092102.GK2681@mtldesk30>
 <1318153939.29415.401.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55323 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174Ab1JIKa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 06:30:27 -0400
Received: by bkbzt4 with SMTP id zt4so7064339bkb.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 03:30:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318153939.29415.401.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 09, 2011 at 11:52:19AM +0200, Benjamin Herrenschmidt wrote:
> 
> > > To go back to the driver code, the statements that ring a "bell" are:
> > > 
> > > 	*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
> > > 
> > > This doesn't look right unless "doorbell_qpn" itself is already somewhat
> > > in the appropriate byte order.
> 
> > This is something that supports my claim that the chipset swaps
> > endianess in ppc.
> 
> No the chipset doesn't swap
> 
> > Look at mlx4_en_activate_tx_ring():
> > ring->doorbell_qpn = swab32(ring->qp.qpn << 8);
> 
> That looks gross, I think somebody writing this driver doesn't
> understand endianness.
> 
> > so in LE machines it layed as big endian in memory while in BE machines
> > it is layed as little endian in memory.
> 
> Yes which is very odd, it should be layed out the same in memory
> regardless of the machine. However in this case, this isn't accessed
> directly via DMA (this field at least), so what you appear to be doing
> here is to artificially "undo" what writel does later on (see below).
> 
> > Then we write this value to the device registers which must get it in
> > big endian otherwise it won't work - and we know this works in both
> > ppc and x86. You can ignore the case of blue flame:
> 
> Well it works because your device is odd and has BE registers :-) It's
> however not the right way to do and it's broken in your blue flame case
> (for what is now obvious reasons, see below).
> 
> What's happening basically here is that you are swapping once in
> swab32 , store that swapped value, then writel will re-swap on power and
> not swap on x86 (because the writel accessor performs swapping). So on
> x86 you basically do LE -> BE and on ppc you do BE -> LE -> BE :-)
> Pretty inefficient.
> 
> None of this has anything to do with the chipset which doesn't swap
> anything behind your back.
> 
> Ideally you want to avoid that swapping altogether and use the right
> accessor that indicates that your register is BE to start with. IE.
> remove the swab32 completely and then use something like 
> iowrite32be() instead of writel().
I agree, this looks better but does it work on memory mapped io or
only on io pci space? All our registers are memory mapped...

> 
> Basically, the problem you have is that writel() has an implicit "write
> to LE register" semantic. Your register is BE. the "iomap" variants
> provide you with more fine grained "be" variants to use in that case.
> There's also writel_be() but that one doesn't exist on every
> architecture afaik.
So writel_be is the function I should use for memory mapped io? If it
does not exist for all platforms it's a pitty :-(
> 
> Now, once the mmio problem is out of the way, let's look back at how you
> then use that qpn.
> 
> With the current code, you've generated something in memory which is
> byte reversed, so essentially "LE" on ppc and "BE" on x86.
> 
> Then, this statement:
> 
> *(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
> 
> Will essentially write it out as-is in memory for use by the chip. The chip,
> from what you say, expects BE, so this will be broken on PPC.
I see. So this field is layed in le for ppc and the rest of the
descriptor is be. so I assum that __iowrite64_copy() does not swap
anything but we still have tx_desc->ctrl.vlan_tag in the wrong
endianess.

> 
> Here too, the right solution is to instead not do that swab32 to begin
> with (ring->doorbell_qpn remains a native endian value) and instead do,
> in addition to the above mentioned change to the writel:
> 
> 	*(u32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
> 
> (Also get rid of that cast and define vlan_tag as a __be32 to start
> with).
> 
> Cheers,
> Ben.

Thanks for your review. I will send another patch which should fix the
deficiencies.
