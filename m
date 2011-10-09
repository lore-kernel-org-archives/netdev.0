From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 9 Oct 2011 11:21:02 +0200
Message-ID: <20111009092102.GK2681@mtldesk30>
References: <20111003205358.GB3596@oc1711230544.ibm.com>
 <1317708132.29415.213.camel@pasglop>
 <20111004202620.GA3455@oc1711230544.ibm.com>
 <20111005081502.GB2681@mtldesk30>
 <20111006135759.GH2681@mtldesk30>
 <1318145118.29415.371.camel@pasglop>
 <20111009073546.GI2681@mtldesk30>
 <1318147254.29415.377.camel@pasglop>
 <20111009080747.GJ2681@mtldesk30>
 <1318149536.29415.384.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38339 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab1JIJVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 05:21:08 -0400
Received: by bkbzt4 with SMTP id zt4so7006777bkb.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 02:21:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318149536.29415.384.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 09, 2011 at 10:38:56AM +0200, Benjamin Herrenschmidt wrote:
> On Sun, 2011-10-09 at 10:07 +0200, Eli Cohen wrote:
> 
> > > Well, first, what do you mean by "swapped" ? :-) But no, it won't for
> > > all intend and purpose, this is a copy routine, copy routines never
> > > swap, neither do fifo accesses for example.
> > When I say swapped, I mean not necessairliy by software. I think that
> > the chipset will swap the the data. The reason I think so is that the
> > CPU arch is big endian, while PCI bus is defined as little endian.
> > That's why I think a swap will occur in ppc and not in x86.
> 
> No it won't "swap the data". The wiring between PCI and the CPU bus is
> done in a way called "byte address invariant", and there is some kind of
> flip of byte lanes related essentially to ensure that, but for all
> intend and purpose it's transparent.
> 
> > It's a special descriptor that resides both in memory and also written
> > to the device's register. An it contains both data and control
> > informartion.
> 
> Data should not be swapped then. Only individual bits of control
> information. In any case, the buffer should be generated in the right
> format in memory to start with. The copy routine doesn't need to swap.
> 
> To go back to the driver code, the statements that ring a "bell" are:
> 
> 	*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
> 
> This doesn't look right unless "doorbell_qpn" itself is already somewhat
> in the appropriate byte order.
This is something that supports my claim that the chipset swaps
endianess in ppc.
Look at mlx4_en_activate_tx_ring():
ring->doorbell_qpn = swab32(ring->qp.qpn << 8);
so in LE machines it layed as big endian in memory while in BE machines
it is layed as little endian in memory.
Then we write this value to the device registers which must get it in
big endian otherwise it won't work - and we know this works in both
ppc and x86. You can ignore the case of blue flame:

        } else if (nreq) {
                qp->sq.head += nreq;

                /*
                 * Make sure that descriptors are written before
                 * doorbell record.
                 */
                wmb();

                writel(qp->doorbell_qpn, qp->bf.uar->map +
MLX4_SEND_DOORBELL); <==  remember that it is layed in little endian
but the device must get it in big endian.

                /*
                 * Make sure doorbells don't leak out of SQ spinlock
                 * and reach the HCA out of order.
                 */
                mmiowb();

        }




> 
> Is that vlan_tag a big or little endian quantity ? Either way, this
> looks broken in either x86 or ppc unless doorbell_qpn itself is already
> in the right endian.
> 
> But since later I see
> 
> 	writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
> 
> That rings a nasty bell, it looks like doorbell_pqn is in CPU (native)
> endian, so it should have to be swapped before being OR'ed into the
> descriptor, either that or the HW does some black magic I don't
> understand.
> 
> Cheers,
> Ben.
> 
