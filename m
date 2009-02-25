From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Wed, 25 Feb 2009 10:35:43 +0800
Message-ID: <1235529343.2604.499.camel@ymzhang>
References: <1235525270.2604.483.camel@ymzhang>
	 <20090224181153.06aa1fbd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jesse.brandeburg@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:15125 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753060AbZBYCgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:36:06 -0500
In-Reply-To: <20090224181153.06aa1fbd@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-24 at 18:11 -0800, Stephen Hemminger wrote:
> On Wed, 25 Feb 2009 09:27:49 +0800
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
>=20
> > =EF=BB=BFSubject: hand off skb list to other cpu to submit to upper=
 layer
> > From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
> >=20
> > Recently, I am investigating an ip_forward performance issue with 1=
0G IXGBE NIC.
> > I start the testing on 2 machines. Every machine has 2 10G NICs. Th=
e 1st one seconds
> > packets by pktgen. The 2nd receives the packets from one NIC and fo=
rwards them out
> > from the 2nd NIC. As NICs supports multi-queue, I bind the queues t=
o different logical
> > cpu of different physical cpu while considering cache sharing caref=
ully.
> >=20
> > Comparing with sending speed on the 1st machine, the forward speed =
is not good, only
> > about 60% of sending speed. As a matter of fact, IXGBE driver start=
s NAPI when interrupt
> > arrives. When ip_forward=3D1, receiver collects a packet and forwar=
ds it out immediately.
> > So although IXGBE collects packets with NAPI, the forwarding really=
 has much impact on
> > collection. As IXGBE runs very fast, it drops packets quickly. The =
better way for
> > receiving cpu is doing nothing than just collecting packets.
> >=20
> > Currently kernel has backlog to support a similar capability, but p=
rocess_backlog still
> > runs on the receiving cpu. I enhance backlog by adding a new input_=
pkt_alien_queue to
> > softnet_data. Receving cpu collects packets and link them into skb =
list, then delivers
> > the list to the =EF=BB=BFinput_pkt_alien_queue of other cpu. proces=
s_backlog picks up the skb list
> > from =EF=BB=BFinput_pkt_alien_queue when =EF=BB=BFinput_pkt_queue i=
s empty.
> >=20
> > NIC driver could use this capability like below step in NAPI RX cle=
anup function.
> > 1) Initiate a local var struct sk_buff_head skb_head;
> > 2) In the packet collection loop, just calls netif_rx_queue or __sk=
b_queue_tail(skb_head, skb)
> > to add skb to the list;
> > 3) Before exiting, calls raise_netif_irq to submit the skb list to =
specific cpu.
> >=20
> > Enlarge /proc/sys/net/core/netdev_max_backlog and netdev_budget bef=
ore testing.
> >=20
> > I tested my patch on top of 2.6.28.5. The improvement is about 43%.
> >=20
> > Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
> >=20
> > ---
Thanks for your comments.

>=20
> You can't safely put packets on another CPU queue without adding a sp=
inlock.
=EF=BB=BFinput_pkt_alien_queue is a struct sk_buff_head which has a spi=
nlock. We use
that lock to protect the queue.

> And if you add the spinlock, you drop the performance back down for y=
our
> device and all the other devices.
My testing shows 43% improvement. As multi-core machines are becoming
popular, we can allocate some core for packet collection only.

I use the spinlock carefully. The deliver cpu locks it only when =EF=BB=
=BFinput_pkt_queue
is empty, and just merges the list to =EF=BB=BFinput_pkt_queue. Later s=
kb dequeue needn't
hold the spinlock. In the other hand, the original receving cpu dispatc=
hes a batch
of skb (64 packets with IXGBE default) when holding the lock once.

>  Also, you will end up reordering
> packets which hurts single stream TCP performance.
Would you like to elaborate the scenario? Does your speaking mean multi=
-queue
also hurts =EF=BB=BFsingle stream TCP performance when we bind multi-qu=
eue(interrupt) to
different cpu?

>=20
> Is this all because the hardware doesn't do MSI-X
IXGBE supports MSI-X and I enables it when testing. =EF=BB=BF The recei=
ver has 16 multi-queue,
so 16 irq numbers. I bind 2 irq numbers per logical cpu of one physical=
 cpu.

>  or are you testing only
> a single flow.=20
What does a single flow mean here? One sender? I do start one sender fo=
r testing because
I couldn't get enough hardware.

In addition, my patch doesn't change old interface, so there would be n=
o performance
hurt to old drivers.

yanmin


