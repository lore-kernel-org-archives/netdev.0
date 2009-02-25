From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Wed, 25 Feb 2009 13:51:26 +0800
Message-ID: <1235541086.2604.524.camel@ymzhang>
References: <1235525270.2604.483.camel@ymzhang>
	 <20090224181153.06aa1fbd@nehalam> <1235529343.2604.499.camel@ymzhang>
	 <20090224211859.0ee8c632@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jesse.brandeburg@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23702 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbZBYFvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 00:51:48 -0500
In-Reply-To: <20090224211859.0ee8c632@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-02-24 at 21:18 -0800, Stephen Hemminger wrote:
> On Wed, 25 Feb 2009 10:35:43 +0800
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
>=20
> > On Tue, 2009-02-24 at 18:11 -0800, Stephen Hemminger wrote:
> > > On Wed, 25 Feb 2009 09:27:49 +0800
> > > "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
> > >=20
> > > > =EF=BB=BFSubject: hand off skb list to other cpu to submit to u=
pper layer
> > > > From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
> > > >=20
> > > > Recently, I am investigating an ip_forward performance issue wi=
th 10G IXGBE NIC.
> > > > I start the testing on 2 machines. Every machine has 2 10G NICs=
=2E The 1st one seconds
> > > > packets by pktgen. The 2nd receives the packets from one NIC an=
d forwards them out
> > > > from the 2nd NIC. As NICs supports multi-queue, I bind the queu=
es to different logical
> > > > cpu of different physical cpu while considering cache sharing c=
arefully.
> > > >=20
> > > > Comparing with sending speed on the 1st machine, the forward sp=
eed is not good, only
> > > > about 60% of sending speed. As a matter of fact, IXGBE driver s=
tarts NAPI when interrupt
> > > > arrives. When ip_forward=3D1, receiver collects a packet and fo=
rwards it out immediately.
> > > > So although IXGBE collects packets with NAPI, the forwarding re=
ally has much impact on
> > > > collection. As IXGBE runs very fast, it drops packets quickly. =
The better way for
> > > > receiving cpu is doing nothing than just collecting packets.
> > > >=20
> > > > Currently kernel has backlog to support a similar capability, b=
ut process_backlog still
> > > > runs on the receiving cpu. I enhance backlog by adding a new in=
put_pkt_alien_queue to
> > > > softnet_data. Receving cpu collects packets and link them into =
skb list, then delivers
> > > > the list to the =EF=BB=BFinput_pkt_alien_queue of other cpu. pr=
ocess_backlog picks up the skb list
> > > > from =EF=BB=BFinput_pkt_alien_queue when =EF=BB=BFinput_pkt_que=
ue is empty.
> > > >=20
> > > > NIC driver could use this capability like below step in NAPI RX=
 cleanup function.
> > > > 1) Initiate a local var struct sk_buff_head skb_head;
> > > > 2) In the packet collection loop, just calls netif_rx_queue or =
__skb_queue_tail(skb_head, skb)
> > > > to add skb to the list;
> > > > 3) Before exiting, calls raise_netif_irq to submit the skb list=
 to specific cpu.
> > > >=20
> > > > Enlarge /proc/sys/net/core/netdev_max_backlog and netdev_budget=
 before testing.
> > > >=20
> > > > I tested my patch on top of 2.6.28.5. The improvement is about =
43%.
> > > >=20
> > > > Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.=
com>
> > > >=20
> > > You can't safely put packets on another CPU queue without adding =
a spinlock.
> > =EF=BB=BFinput_pkt_alien_queue is a struct sk_buff_head which has a=
 spinlock. We use
> > that lock to protect the queue.
>=20
> I was reading netif_rx_queue() and you have it using __skb_queue_tail=
() which
> has no locking.=20
Sorry, I need add some comments to function netif_rx_queue.

Parameter skb_queue is point to a local var, or NULL. If it points to a=
 local var,
just like =EF=BB=BFfunction ixgbe_clean_rx_irq of IXGBE, so we needn't =
protect it when
=EF=BB=BFusing __skb_queue_tail to add new skb. If =EF=BB=BFskb_queue i=
s point to NULL, below

skb_queue =3D &queue->input_pkt_queue;

make it points to the local input_pkt_queue which is protected by local=
_irq_save.

> > > And if you add the spinlock, you drop the performance back down f=
or your
> > > device and all the other devices.
> > My testing shows 43% improvement. As multi-core machines are becomi=
ng
> > popular, we can allocate some core for packet collection only.
> >=20
> > I use the spinlock carefully. The deliver cpu locks it only when =EF=
=BB=BFinput_pkt_queue
> > is empty, and just merges the list to =EF=BB=BFinput_pkt_queue. Lat=
er skb dequeue needn't
> > hold the spinlock. In the other hand, the original receving cpu dis=
patches a batch
> > of skb (64 packets with IXGBE default) when holding the lock once.
> >=20
> > >  Also, you will end up reordering
> > > packets which hurts single stream TCP performance.
> > Would you like to elaborate the scenario? Does your speaking mean m=
ulti-queue
> > also hurts =EF=BB=BFsingle stream TCP performance when we bind mult=
i-queue(interrupt) to
> > different cpu?
> >=20
> > >=20
> > > Is this all because the hardware doesn't do MSI-X
> > IXGBE supports MSI-X and I enables it when testing. =EF=BB=BF The r=
eceiver has 16 multi-queue,
> > so 16 irq numbers. I bind 2 irq numbers per logical cpu of one phys=
ical cpu.
> >=20
> > >  or are you testing only
> > > a single flow.=20
> > What does a single flow mean here? One sender? I do start one sende=
r for testing because
> > I couldn't get enough hardware.
>=20
> Multiple receive queues only have an performance gain if the packets =
are being
> sent with different SRC/DST address pairs. That is how the hardware i=
s supposed
> to break them into queues.
Thanks for your explanation.

>=20
> Reordering is what happens when packts that are sent as [ 0, 1, 2, 3,=
 4 ]
> get received as [ 0, 1, 4, 3, 2 ] because your receive processing hap=
pened on different
> CPU's. You really need to test this with some program like 'iperf' to=
 see the effect
> it has on TCP. Older Juniper routers used to have hardware that did t=
his and it
> caused it caused performance loss. Do some google searches and you wi=
ll see
> it is a active research topic about whether reordering is okay or not=
=2E Existing
> multiqueue is safe because it doesn't reorder inside a single flow; i=
t only
> changes order between flows:  [ A1, A2, B1, B2] =3D> [ A1, B1, A2, B2=
 ]
Thanks. Your explanation is very clear. My patch might cause reorder, b=
ut very rarely,
because reorder only happens when there is a failover in function raise=
_netif_irq. perhaps
I need replace the failover with just packet dropping?

I will try iperf.

>=20
> Isn't this a problem:
> > +int netif_rx_queue(struct sk_buff *skb, struct sk_buff_head *skb_q=
ueue)
> >  {
> >  	struct softnet_data *queue;
> >  	unsigned long flags;
> > +	int this_cpu;
> > =20
> >  	/* if netpoll wants it, pretend we never saw it */
> >  	if (netpoll_rx(skb))
> > @@ -1943,24 +1946,31 @@ int netif_rx(struct sk_buff *skb)
> >  	if (!skb->tstamp.tv64)
> >  		net_timestamp(skb);
> > =20
> > +	if (skb_queue)
> > +		this_cpu =3D 0;
> > +	else
> > +		this_cpu =3D 1;
>=20
> Why bother with a special boolean? and instead just test for skb_queu=
e !=3D NULL
Var this_cpu is used for =EF=BB=BFnapi_schedule late. Although the logi=
cal has no problem,
this_cpu seems confused. Let me check if there is a better way for late=
 napi_schedule.

>=20
> > +
> >  	/*
> >  	 * The code is rearranged so that the path is the most
> >  	 * short when CPU is congested, but is still operating.
> >  	 */
> >  	local_irq_save(flags);
> > +
> >  	queue =3D &__get_cpu_var(softnet_data);
> > +	if (!skb_queue)
> > +		skb_queue =3D &queue->input_pkt_queue;
=EF=BB=BFWhen =EF=BB=BFskb_queue is NULL, we redirect it to =EF=BB=BFqu=
eue->input_pkt_queue.

>=20
> > =20
> >  	__get_cpu_var(netdev_rx_stat).total++;
> > -	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> > -		if (queue->input_pkt_queue.qlen) {
> > -enqueue:
> > -			__skb_queue_tail(&queue->input_pkt_queue, skb);
> > -			local_irq_restore(flags);
> > -			return NET_RX_SUCCESS;
> > +
> > +	if (skb_queue->qlen <=3D netdev_max_backlog) {
> > +		if (!skb_queue->qlen && this_cpu) {
> > +			napi_schedule(&queue->backlog);
> >  		}
>=20
> Won't this break if skb_queue is NULL (non NAPI case)?
So skb_queue isn't NULL here.

Another idea is just to delete function =EF=BB=BFnetif_rx_queue. Driver=
s could use
=EF=BB=BF__skb_queue_tail directly. The difference =EF=BB=BFnetif_rx_qu=
eue has a queue length
checking while =EF=BB=BF=EF=BB=BF__skb_queue_tail hasn't. But mostly =EF=
=BB=BFskb_queue is far smaller than
=EF=BB=BFqueue->input_pkt_queue.qlen and =EF=BB=BFqueue->input_pkt_alie=
n_queue.qlen.

Yanmin


