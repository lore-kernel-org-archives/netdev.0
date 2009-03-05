From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Thu, 05 Mar 2009 17:24:04 +0800
Message-ID: <1236245044.2567.200.camel@ymzhang>
References: <1235546423.2604.556.camel@ymzhang>
	 <20090224.233115.240823417.davem@davemloft.net>
	 <1236158868.2567.93.camel@ymzhang>
	 <20090304.013937.129768263.davem@davemloft.net>
	 <1236215076.2567.105.camel@ymzhang> <1236220827.2567.136.camel@ymzhang>
	 <96ff3930903042332n233ee3ddte23210f988019dec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jens =?ISO-8859-1?Q?L=E5=E5s?= <jelaas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28536 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbZCEJYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2009 04:24:30 -0500
In-Reply-To: <96ff3930903042332n233ee3ddte23210f988019dec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-05 at 08:32 +0100, Jens L=C3=A5=C3=A5s wrote:
> 2009/3/5, Zhang, Yanmin <yanmin_zhang@linux.intel.com>:
> > On Thu, 2009-03-05 at 09:04 +0800, Zhang, Yanmin wrote:
> >  > On Wed, 2009-03-04 at 01:39 -0800, David Miller wrote:
> >  > > From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
> >  > > Date: Wed, 04 Mar 2009 17:27:48 +0800
> >  > >
> >  > > > Both the new skb_record_rx_queue and current kernel have an
> >  > > > assumption on multi-queue. The assumption is it's best to se=
nd out
> >  > > > packets from the TX of the same number of queue like the one=
 of RX
> >  > > > if the receved packets are related to the out packets. Or mo=
re
> >  > > > direct speaking is we need send packets on the same cpu on w=
hich we
> >  > > > receive them. The start point is that could reduce skb and d=
ata
> >  > > > cache miss.
> >  > >
> >  > > We have to use the same TX queue for all packets for the same
> >  > > connection flow (same src/dst IP address and ports) otherwise
> >  > > we introduce reordering.
> >  > > Herbert brought this up, now I have explicitly brought this up=
,
> >  > > and you cannot ignore this issue.
> >  > Thanks. =EF=BB=BFStephen Hemminger brought it up and explained w=
hat reorder
> >  > is. I answered in a reply (sorry for not clear) that mostly we n=
eed spread
> >  > packets among RX/TX in a 1:1 mapping or N:1 mapping. For example=
, all packets
> >  > received from RX 8 will be spreaded to TX 0 always.
> >
> > To make it clearer, I used 1:1 mapping binding when running testing
> >  on bensley (4*2 cores) and Nehalem (2*4*2 logical cpu). So there i=
s no reorder
> >  issue. I also worked out a new patch on the failover path to just =
drop
> >  packets when qlen is bigger than netdev_max_backlog, so the failov=
er path wouldn't
> >  cause reorder.
> >
>=20

> We have not seen this problem in our=20
=EF=BB=BFThanks for your valuable input. We need more data on high-spee=
d NIC.

> We do keep the skb processing with the same CPU from RX to TX.
That's a normal point. I did so when I began to investigate why forward
speed is far slower than sending speed with 10G NIC.

> This is done via setting affinity for queues and using custom select_=
queue.
>=20
> +static u16 select_queue(struct net_device *dev, struct sk_buff *skb)
> +{
> +       if( dev->real_num_tx_queues && skb_rx_queue_recorded(skb) )
> +               return  skb_get_rx_queue(skb) % dev->real_num_tx_queu=
es;
> +
> +       return  smp_processor_id() %  dev->real_num_tx_queues;
> +}
> +
Yes, with the function and every NIC has CPU_NUM queues, skb is process=
ed
with the same cpu from RX to TX.

>=20
> The hash based default for selecting TX-queue generates an uneven
> spread that is hard to follow with correct affinity.
>=20
> We have not been able to generate quite as much traffic from the send=
er.
pktgen of the latest kernel supports multi-thread on the same device. I=
f you
just starts one thread, the speed is limited. Could you try 4 or 8 thre=
ads? Perhaps
speed could double then.

>=20
> Sender: (64 byte pkts)
> eth5            4.5 k bit/s        3   pps   1233.9 M bit/s    2.632 =
M pps
I'm a little confused with the data. Do the first 2 mean IN and last 2 =
mean OUT?

What kind of NIC and machines are they? How big is the last level cache=
 of the cpu?

>=20
> Router:
> eth0         1077.2 M bit/s    2.298 M pps      1.7 k bit/s        1 =
  pps
> eth1            744   bit/s        1   pps   1076.3 M bit/s    2.296 =
M pps
The forward speed is quite close to the sending speed of the Sender. It=
 seems
your machine needn't my patch.

My original case is the sending speed is 1.4M pps with careful cpu bind=
ing considering
cpu cache sharing. With my patch, the result becomes 2M pps and the sen=
ding speed is
2.36M pps. The NICs I am using are not latest.

>=20
> Im not sure I like the proposed concept since it decouples RX
> processing from receiving.
> There is no point collecting lots of packets just to drop them later
> in the qdisc.
> Infact this is bad for performance, we just consume cpu for nothing.
Yes, if the skb processing cpu is very busy, and we choose to drop skb =
there instead of
by driver or NIC hardware, performance might be worse.

A small change on my patch and driver could reduce that possibility. Ch=
ecking qlen before
collecting the 64 packets (assume driver collects 64 packets per NAPI l=
oop). If qlen is
larger than netdev_max_backlog, driver could just return without real c=
ollection.

We need data to distinguish good or bad.

> It is important to have as strong correlation as possible between RX
> and TX so we dont receive more pkts than we can handle. Better to dro=
p
> on the interface.
With my above small change, interface would drop packets.

>=20
> We might start thinking of a way for userland to set the policy for
> multiq mapping.
I also think so.

I did more testing with different slab allocator as slab has big impact=
 on
performance. SLQB has very different behavior from SLUB. It seems SLQB =
(try2) need
improve NUMA allocation/free. At least I use slub_min_objects=3D64 and =
slub_max_order=3D6
to get the best result on my machine.

Thanks for your comments.

> >  > >
> >  > > You must not knowingly reorder packets, and using different TX
> >  > > queues for packets within the same flow does that.
> >  > Thanks for you rexplanation which is really consistent with =EF=BB=
=BFStephen's speaking.
> >


