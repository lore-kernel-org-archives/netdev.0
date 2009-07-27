From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] Idea about increasing efficency of skb allocation in
	network devices
Date: Mon, 27 Jul 2009 06:55:54 -0400
Message-ID: <20090727105554.GB15823@hmsreliant.think-freely.org>
References: <20090727003609.GA30438@localhost.localdomain> <20090726.180254.202825489.davem@davemloft.net> <4A6D52FF.2030008@inria.fr> <4A6D5E1E.3090907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51576 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005AbZG0K4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 06:56:05 -0400
Content-Disposition: inline
In-Reply-To: <4A6D5E1E.3090907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2009 at 09:58:22AM +0200, Eric Dumazet wrote:
> Brice Goglin a =E9crit :
> > David Miller wrote:
> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> Date: Sun, 26 Jul 2009 20:36:09 -0400
> >>
> >>  =20
> >>> 	Since Network devices dma their memory into a provided DMA
> >>> buffer (which can usually be at an arbitrary location, as they mu=
st
> >>> cross potentially several pci busses to reach any memory location=
),
> >>> I'm postulating that it would increase our receive path efficienc=
y
> >>> to provide a hint to the driver layer as to which node to allocat=
e
> >>> an skb data buffer on.  This hint would be determined by a feedba=
ck
> >>> mechanism.  I was thinking that we could provide a callback funct=
ion
> >>> via the skb, that accepted the skb and the originating net_device=
=2E
> >>> This callback can track statistics on which numa nodes consume
> >>> (read: copy data from) skbs that were produced by specific net
> >>> devices.  Then, when in the future that netdevice allocates a new
> >>> skb (perhaps via netdev_alloc_skb), we can use that statistical
> >>> profile to determine if the data buffer should be allocated on th=
e
> >>> local node, or on a remote node instead.
> >>>    =20
> >> No matter what, you will do an inter-node memory operation.
> >>
> >> Unless, the consumer NUMA node is the same as the one the
> >> device is on.
> >>
> >> Because since the device is on a NUMA node, if you DMA remotely
> >> you've eaten the NUMA cost already.
> >>
> >> If you always DMA to the device's NUMA node (what we try to do now=
) at
> >> least the is the possibility of eliminating cross-NUMA traffic.
> >>
> >> Better to move the application or stack processing towards the NUM=
A
> >> node the network device is on, I think.
> >>  =20
> >=20
> > Is there an easy way to get this NUMA node from the application soc=
ket
> > descriptor?
>=20
> Thats not easy, this information can change for every packet (think o=
f
> bonding setups, whith aggregation of devices on different NUMA nodes)
>=20
> We could add a getsockopt() call to peek this information from the ne=
xt
> data to be read from socket (returns node id where skb data is sittin=
g,
> hoping that NIC driver hadnt copybreak it (ie : allocate a small skb =
and
> copy the device provided data on it before feeding packet to network =
stack))
>=20
Would a proc or debugfs interface perhaps be helpful here?  Something t=
hat
perhaps showed a statistical distribution of how many packets were rece=
ived by
each process on each irq (operating under the assumption that each rx q=
ueue has
its own msi irq, giving us an easy identifier).

Neil

>=20
> > Also, one question that was raised at the Linux Symposium is: how d=
o you
> > know which processors run the receive queue for a specific connecti=
on ?
> > It would be nice to have a way to retrieve such information in the
> > application to avoid inter-node and inter-core/cache traffic.
>=20
> All this depends on the fact you have multiqueue devices or not, and
> trafic spreads on all queues or not.
>=20
> Assuming you have single queue device, only current way to handle
> this is to do the reverse thinking.
>=20
> Ie, bind NIC interrupts to the appropriate set of cpus, and
> possibly bind user apps threads dealing with network trafic to same s=
et.
>=20
> Only background or cpu hungry threads should be allowed to run
> on foreigns nodes.
>=20
>=20
