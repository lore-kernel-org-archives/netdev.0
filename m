From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 9 Oct 2011 10:07:47 +0200
Message-ID: <20111009080747.GJ2681@mtldesk30>
References: <20111003143721.GA3596@oc1711230544.ibm.com>
 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
 <20111003205358.GB3596@oc1711230544.ibm.com>
 <1317708132.29415.213.camel@pasglop>
 <20111004202620.GA3455@oc1711230544.ibm.com>
 <20111005081502.GB2681@mtldesk30>
 <20111006135759.GH2681@mtldesk30>
 <1318145118.29415.371.camel@pasglop>
 <20111009073546.GI2681@mtldesk30>
 <1318147254.29415.377.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41975 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab1JIIHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 04:07:55 -0400
Received: by bkbzt4 with SMTP id zt4so6948111bkb.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 01:07:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318147254.29415.377.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 09, 2011 at 10:00:54AM +0200, Benjamin Herrenschmidt wrote:
> On Sun, 2011-10-09 at 09:35 +0200, Eli Cohen wrote:
> > On Sun, Oct 09, 2011 at 09:25:18AM +0200, Benjamin Herrenschmidt wrote:
> > > On Thu, 2011-10-06 at 15:57 +0200, Eli Cohen wrote:
> > > > On Wed, Oct 05, 2011 at 10:15:02AM +0200, Eli Cohen wrote:
> > > > 
> > > > How about this patch - can you give it a try?
> > > > 
> > > > 
> > > > >From dee60547aa9e35a02835451d9e694cd80dd3072f Mon Sep 17 00:00:00 2001
> > > > From: Eli Cohen <eli@mellanox.co.il>
> > > > Date: Thu, 6 Oct 2011 15:50:02 +0200
> > > > Subject: [PATCH] mlx4_en: Fix blue flame on powerpc
> > > > 
> > > > The source buffer used for copying into the blue flame register is already in
> > > > big endian. However, when copying to device on powerpc, the endianess is
> > > > swapped so the data reaches th device in little endian which is wrong. On x86
> > > > based platform no swapping occurs so it reaches the device with the correct
> > > > endianess. Fix this by calling le32_to_cpu() on the buffer. On LE systems there
> > > > is no change; on BE there will be a swap.
> > > 
> > > That looks wrong.
> > Not sure I understand: are you saying that on ppc, when you call
> > __iowrite64_copy, it will not reach the device swapped?
> 
> Well, first, what do you mean by "swapped" ? :-) But no, it won't for
> all intend and purpose, this is a copy routine, copy routines never
> swap, neither do fifo accesses for example.
When I say swapped, I mean not necessairliy by software. I think that
the chipset will swap the the data. The reason I think so is that the
CPU arch is big endian, while PCI bus is defined as little endian.
That's why I think a swap will occur in ppc and not in x86.
> 
> > The point is that we must always have the buffer ready in big endian
> > in memory. In the case of blue flame, we must also copy it to the
> > device registers in pci memory space. So if we use the buffer we
> > already prepared, we must have another swap. I can think of a nicer
> > way to implement this functionality but the question is do you think
> > my observation above is wrong and why.
> 
> No. If it's in memory BE then the copy routine will keep it BE. A copy
> routine doesn't swap and doesn't affect endianness.
> 
> Additionally, a swapping phase like you proposed doing 32-bit swaps
> means that you know for sure that the buffer is made of 32-bit
> quantities, is that the case ?
Yes

> Even if you had needed that swap, if your
> buffer had contained 16-bit or 64-bit quantities, you're toast.
> 
> What is this buffer anyway ? A descriptor or a network packet ?
It's a special descriptor that resides both in memory and also written
to the device's register. An it contains both data and control
informartion.
> 
> If it's a packet, then it's data, endianness has no meaning (or rather
> it has for individual fields of the packets but they are already in the
> right format and a 32-bit swap will never be right).
>  
> It's almost never right to perform swapping when copying data (or
> reading/writing a FIFO).
> 
> Cheers,
> Ben.
