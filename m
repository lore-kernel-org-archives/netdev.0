From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
 layer
Date: Tue, 24 Feb 2009 21:18:59 -0800
Message-ID: <20090224211859.0ee8c632@nehalam>
References: <1235525270.2604.483.camel@ymzhang>
	<20090224181153.06aa1fbd@nehalam>
	<1235529343.2604.499.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jesse.brandeburg@intel.com
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41186 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbZBYFTE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 00:19:04 -0500
In-Reply-To: <1235529343.2604.499.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Feb 2009 10:35:43 +0800
"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:

> On Tue, 2009-02-24 at 18:11 -0800, Stephen Hemminger wrote:
> > On Wed, 25 Feb 2009 09:27:49 +0800
> > "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
> >=20
> > > =EF=BB=BFSubject: hand off skb list to other cpu to submit to upp=
er layer
> > > From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
> > >=20
> > > Recently, I am investigating an ip_forward performance issue with=
 10G IXGBE NIC.
> > > I start the testing on 2 machines. Every machine has 2 10G NICs. =
The 1st one seconds
> > > packets by pktgen. The 2nd receives the packets from one NIC and =
forwards them out
> > > from the 2nd NIC. As NICs supports multi-queue, I bind the queues=
 to different logical
> > > cpu of different physical cpu while considering cache sharing car=
efully.
> > >=20
> > > Comparing with sending speed on the 1st machine, the forward spee=
d is not good, only
> > > about 60% of sending speed. As a matter of fact, IXGBE driver sta=
rts NAPI when interrupt
> > > arrives. When ip_forward=3D1, receiver collects a packet and forw=
ards it out immediately.
> > > So although IXGBE collects packets with NAPI, the forwarding real=
ly has much impact on
> > > collection. As IXGBE runs very fast, it drops packets quickly. Th=
e better way for
> > > receiving cpu is doing nothing than just collecting packets.
> > >=20
> > > Currently kernel has backlog to support a similar capability, but=
 process_backlog still
> > > runs on the receiving cpu. I enhance backlog by adding a new inpu=
t_pkt_alien_queue to
> > > softnet_data. Receving cpu collects packets and link them into sk=
b list, then delivers
> > > the list to the =EF=BB=BFinput_pkt_alien_queue of other cpu. proc=
ess_backlog picks up the skb list
> > > from =EF=BB=BFinput_pkt_alien_queue when =EF=BB=BFinput_pkt_queue=
 is empty.
> > >=20
> > > NIC driver could use this capability like below step in NAPI RX c=
leanup function.
> > > 1) Initiate a local var struct sk_buff_head skb_head;
> > > 2) In the packet collection loop, just calls netif_rx_queue or __=
skb_queue_tail(skb_head, skb)
> > > to add skb to the list;
> > > 3) Before exiting, calls raise_netif_irq to submit the skb list t=
o specific cpu.
> > >=20
> > > Enlarge /proc/sys/net/core/netdev_max_backlog and netdev_budget b=
efore testing.
> > >=20
> > > I tested my patch on top of 2.6.28.5. The improvement is about 43=
%.
> > >=20
> > > Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.co=
m>
> > >=20
> > > ---
> Thanks for your comments.
>=20
> >=20
> > You can't safely put packets on another CPU queue without adding a =
spinlock.
> =EF=BB=BFinput_pkt_alien_queue is a struct sk_buff_head which has a s=
pinlock. We use
> that lock to protect the queue.

I was reading netif_rx_queue() and you have it using __skb_queue_tail()=
 which
has no locking.=20

> > And if you add the spinlock, you drop the performance back down for=
 your
> > device and all the other devices.
> My testing shows 43% improvement. As multi-core machines are becoming
> popular, we can allocate some core for packet collection only.
>=20
> I use the spinlock carefully. The deliver cpu locks it only when =EF=BB=
=BFinput_pkt_queue
> is empty, and just merges the list to =EF=BB=BFinput_pkt_queue. Later=
 skb dequeue needn't
> hold the spinlock. In the other hand, the original receving cpu dispa=
tches a batch
> of skb (64 packets with IXGBE default) when holding the lock once.
>=20
> >  Also, you will end up reordering
> > packets which hurts single stream TCP performance.
> Would you like to elaborate the scenario? Does your speaking mean mul=
ti-queue
> also hurts =EF=BB=BFsingle stream TCP performance when we bind multi-=
queue(interrupt) to
> different cpu?
>=20
> >=20
> > Is this all because the hardware doesn't do MSI-X
> IXGBE supports MSI-X and I enables it when testing. =EF=BB=BF The rec=
eiver has 16 multi-queue,
> so 16 irq numbers. I bind 2 irq numbers per logical cpu of one physic=
al cpu.
>=20
> >  or are you testing only
> > a single flow.=20
> What does a single flow mean here? One sender? I do start one sender =
for testing because
> I couldn't get enough hardware.

Multiple receive queues only have an performance gain if the packets ar=
e being
sent with different SRC/DST address pairs. That is how the hardware is =
supposed
to break them into queues.

Reordering is what happens when packts that are sent as [ 0, 1, 2, 3, 4=
 ]
get received as [ 0, 1, 4, 3, 2 ] because your receive processing happe=
ned on different
CPU's. You really need to test this with some program like 'iperf' to s=
ee the effect
it has on TCP. Older Juniper routers used to have hardware that did thi=
s and it
caused it caused performance loss. Do some google searches and you will=
 see
it is a active research topic about whether reordering is okay or not. =
Existing
multiqueue is safe because it doesn't reorder inside a single flow; it =
only
changes order between flows:  [ A1, A2, B1, B2] =3D> [ A1, B1, A2, B2 ]


>=20
> In addition, my patch doesn't change old interface, so there would be=
 no performance
> hurt to old drivers.
>=20
> yanmin
>=20
>=20

Isn't this a problem:
> +int netif_rx_queue(struct sk_buff *skb, struct sk_buff_head *skb_que=
ue)
>  {
>  	struct softnet_data *queue;
>  	unsigned long flags;
> +	int this_cpu;
> =20
>  	/* if netpoll wants it, pretend we never saw it */
>  	if (netpoll_rx(skb))
> @@ -1943,24 +1946,31 @@ int netif_rx(struct sk_buff *skb)
>  	if (!skb->tstamp.tv64)
>  		net_timestamp(skb);
> =20
> +	if (skb_queue)
> +		this_cpu =3D 0;
> +	else
> +		this_cpu =3D 1;

Why bother with a special boolean? and instead just test for skb_queue =
!=3D NULL

> +
>  	/*
>  	 * The code is rearranged so that the path is the most
>  	 * short when CPU is congested, but is still operating.
>  	 */
>  	local_irq_save(flags);
> +
>  	queue =3D &__get_cpu_var(softnet_data);
> +	if (!skb_queue)
> +		skb_queue =3D &queue->input_pkt_queue;

> =20
>  	__get_cpu_var(netdev_rx_stat).total++;
> -	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> -		if (queue->input_pkt_queue.qlen) {
> -enqueue:
> -			__skb_queue_tail(&queue->input_pkt_queue, skb);
> -			local_irq_restore(flags);
> -			return NET_RX_SUCCESS;
> +
> +	if (skb_queue->qlen <=3D netdev_max_backlog) {
> +		if (!skb_queue->qlen && this_cpu) {
> +			napi_schedule(&queue->backlog);
>  		}

Won't this break if skb_queue is NULL (non NAPI case)?
