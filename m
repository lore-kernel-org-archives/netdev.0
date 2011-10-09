From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 09 Oct 2011 10:38:56 +0200
Message-ID: <1318149536.29415.384.camel@pasglop>
References: <20111003143721.GA3596@oc1711230544.ibm.com>
	 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
	 <20111003205358.GB3596@oc1711230544.ibm.com>
	 <1317708132.29415.213.camel@pasglop>
	 <20111004202620.GA3455@oc1711230544.ibm.com>
	 <20111005081502.GB2681@mtldesk30> <20111006135759.GH2681@mtldesk30>
	 <1318145118.29415.371.camel@pasglop> <20111009073546.GI2681@mtldesk30>
	 <1318147254.29415.377.camel@pasglop>  <20111009080747.GJ2681@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38031 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565Ab1JIIjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 04:39:19 -0400
In-Reply-To: <20111009080747.GJ2681@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-10-09 at 10:07 +0200, Eli Cohen wrote:

> > Well, first, what do you mean by "swapped" ? :-) But no, it won't for
> > all intend and purpose, this is a copy routine, copy routines never
> > swap, neither do fifo accesses for example.
> When I say swapped, I mean not necessairliy by software. I think that
> the chipset will swap the the data. The reason I think so is that the
> CPU arch is big endian, while PCI bus is defined as little endian.
> That's why I think a swap will occur in ppc and not in x86.

No it won't "swap the data". The wiring between PCI and the CPU bus is
done in a way called "byte address invariant", and there is some kind of
flip of byte lanes related essentially to ensure that, but for all
intend and purpose it's transparent.

> It's a special descriptor that resides both in memory and also written
> to the device's register. An it contains both data and control
> informartion.

Data should not be swapped then. Only individual bits of control
information. In any case, the buffer should be generated in the right
format in memory to start with. The copy routine doesn't need to swap.

To go back to the driver code, the statements that ring a "bell" are:

	*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;

This doesn't look right unless "doorbell_qpn" itself is already somewhat
in the appropriate byte order.

Is that vlan_tag a big or little endian quantity ? Either way, this
looks broken in either x86 or ppc unless doorbell_qpn itself is already
in the right endian.

But since later I see

	writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);

That rings a nasty bell, it looks like doorbell_pqn is in CPU (native)
endian, so it should have to be swapped before being OR'ed into the
descriptor, either that or the HW does some black magic I don't
understand.

Cheers,
Ben.
