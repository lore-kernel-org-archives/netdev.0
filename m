From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
 layer
Date: Tue, 24 Feb 2009 18:11:53 -0800
Message-ID: <20090224181153.06aa1fbd@nehalam>
References: <1235525270.2604.483.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jesse.brandeburg@intel.com
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34225 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbZBYCL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:11:57 -0500
In-Reply-To: <1235525270.2604.483.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2009 09:27:49 +0800
"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:

> =EF=BB=BFSubject: hand off skb list to other cpu to submit to upper l=
ayer
> From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
>=20
> Recently, I am investigating an ip_forward performance issue with 10G=
 IXGBE NIC.
> I start the testing on 2 machines. Every machine has 2 10G NICs. The =
1st one seconds
> packets by pktgen. The 2nd receives the packets from one NIC and forw=
ards them out
> from the 2nd NIC. As NICs supports multi-queue, I bind the queues to =
different logical
> cpu of different physical cpu while considering cache sharing careful=
ly.
>=20
> Comparing with sending speed on the 1st machine, the forward speed is=
 not good, only
> about 60% of sending speed. As a matter of fact, IXGBE driver starts =
NAPI when interrupt
> arrives. When ip_forward=3D1, receiver collects a packet and forwards=
 it out immediately.
> So although IXGBE collects packets with NAPI, the forwarding really h=
as much impact on
> collection. As IXGBE runs very fast, it drops packets quickly. The be=
tter way for
> receiving cpu is doing nothing than just collecting packets.
>=20
> Currently kernel has backlog to support a similar capability, but pro=
cess_backlog still
> runs on the receiving cpu. I enhance backlog by adding a new input_pk=
t_alien_queue to
> softnet_data. Receving cpu collects packets and link them into skb li=
st, then delivers
> the list to the =EF=BB=BFinput_pkt_alien_queue of other cpu. process_=
backlog picks up the skb list
> from =EF=BB=BFinput_pkt_alien_queue when =EF=BB=BFinput_pkt_queue is =
empty.
>=20
> NIC driver could use this capability like below step in NAPI RX clean=
up function.
> 1) Initiate a local var struct sk_buff_head skb_head;
> 2) In the packet collection loop, just calls netif_rx_queue or __skb_=
queue_tail(skb_head, skb)
> to add skb to the list;
> 3) Before exiting, calls raise_netif_irq to submit the skb list to sp=
ecific cpu.
>=20
> Enlarge /proc/sys/net/core/netdev_max_backlog and netdev_budget befor=
e testing.
>=20
> I tested my patch on top of 2.6.28.5. The improvement is about 43%.
>=20
> Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
>=20
> ---

You can't safely put packets on another CPU queue without adding a spin=
lock.
And if you add the spinlock, you drop the performance back down for you=
r
device and all the other devices. Also, you will end up reordering
packets which hurts single stream TCP performance.

Is this all because the hardware doesn't do MSI-X or are you testing on=
ly
a single flow.=20
