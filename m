From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Tue, 3 Aug 2010 11:27:44 +0530
Message-ID: <OF46AA822C.08F8EAED-ON65257774.001F5AE3-65257774.00209BBF@in.ibm.com>
References: <20100803030256.8486.82622.sendpatchset@krkumar2.in.ibm.com> <AANLkTikNOstJr3qqMUqtUoOm1xHOjw5uM7NpQUNJz4PR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, bhutchings@solarflare.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org, therbert@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:48056 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab0HCF4Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:56:16 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id o735uCIs024626
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 11:26:12 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o735uCVI4358320
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 11:26:12 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o735uBtH022946
	for <netdev@vger.kernel.org>; Tue, 3 Aug 2010 15:56:12 +1000
In-Reply-To: <AANLkTikNOstJr3qqMUqtUoOm1xHOjw5uM7NpQUNJz4PR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Changli,

Good catch.

Instead of adding support for ethernet header or pull/push,
I could defer the skb_push(ETH_HLEN), something like:

static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
{
	struct macvtap_queue *q =3D macvtap_get_queue(dev, skb);
	if (!q)
		goto drop;

	if (skb_queue_len(&q->sk.sk_receive_queue) >=3D dev->tx_queue_len)
		goto drop;

+	skb_push(skb, ETH_HLEN);
	...
}

and remove the same in macvtap_receive. Will this be better?

Your other suggestions also looks good.

Thanks,

- KK

Changli Gao <xiaosuo@gmail.com> wrote on 08/03/2010 09:35:34 AM:

> Changli Gao <xiaosuo@gmail.com>
> 08/03/2010 09:35 AM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> davem@davemloft.net, arnd@arndb.de, bhutchings@solarflare.com,
> netdev@vger.kernel.org, therbert@google.com, mst@redhat.com
>
> Subject
>
> Re: [PATCH v3 1/2] core: Factor out flow calculation from get_rps_cpu
>
> On Tue, Aug 3, 2010 at 11:02 AM, Krishna Kumar <krkumar2@in.ibm.com>
wrote:
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> > Factor out flow calculation code from get_rps_cpu, since macvtap
> > driver can use the same code.
> >
> > Revisions:
> >
> > v2 - Ben: Separate flow calcuation out and use in select queue
> > v3 - Arnd: Don't re-implement MIN
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> > =A0include/linux/netdevice.h | =A0 =A01
> > =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 94 +++++++++++++++++=
+++++--------------
> > =A02 files changed, 59 insertions(+), 36 deletions(-)
> >
> > diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevic=
e.h
> > --- org/include/linux/netdevice.h =A0 =A0 =A0 2010-08-03 08:19:57.0=
00000000
+0530
> > +++ new/include/linux/netdevice.h =A0 =A0 =A0 2010-08-03 08:19:57.0=
00000000
+0530
> > @@ -2253,6 +2253,7 @@ static inline const char *netdev_name(co
> > =A0 =A0 =A0 =A0return dev->name;
> > =A0}
> >
> > +extern int skb_calculate_flow(struct net_device *dev, struct sk_bu=
ff
*skb);
> > =A0extern int netdev_printk(const char *level, const struct net_dev=
ice
*dev,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char *format,=
 ...)
> > =A0 =A0 =A0 =A0__attribute__ ((format (printf, 3, 4)));
> > diff -ruNp org/net/core/dev.c new/net/core/dev.c
> > --- org/net/core/dev.c =A02010-08-03 08:19:57.000000000 +0530
> > +++ new/net/core/dev.c =A02010-08-03 08:19:57.000000000 +0530
> > @@ -2263,51 +2263,24 @@ static inline void ____napi_schedule(str
> > =A0 =A0 =A0 =A0__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> > =A0}
> >
> > -#ifdef CONFIG_RPS
> > -
> > -/* One global table that all flow-based protocols share. */
> > -struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
> > -EXPORT_SYMBOL(rps_sock_flow_table);
> > -
> > =A0/*
> > - * get_rps_cpu is called from netif_receive_skb and returns the ta=
rget
> > - * CPU from the RPS map of the receiving queue for a given skb.
> > - * rcu_read_lock must be held on entry.
> > + * skb_calculate_flow: calculate a flow hash based on src/dst
addresses
> > + * and src/dst port numbers. On success, returns a hash number (> =
0),
> > + * otherwise -1.
> > =A0*/
> > -static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb=
,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rps_dev_flow **=
rflowp)
> > +int skb_calculate_flow(struct net_device *dev, struct sk_buff *skb=
)
> > =A0{
> > + =A0 =A0 =A0 int hash =3D skb->rxhash;
> > =A0 =A0 =A0 =A0struct ipv6hdr *ip6;
> > =A0 =A0 =A0 =A0struct iphdr *ip;
> > - =A0 =A0 =A0 struct netdev_rx_queue *rxqueue;
> > - =A0 =A0 =A0 struct rps_map *map;
> > - =A0 =A0 =A0 struct rps_dev_flow_table *flow_table;
> > - =A0 =A0 =A0 struct rps_sock_flow_table *sock_flow_table;
> > - =A0 =A0 =A0 int cpu =3D -1;
> > =A0 =A0 =A0 =A0u8 ip_proto;
> > - =A0 =A0 =A0 u16 tcpu;
> > =A0 =A0 =A0 =A0u32 addr1, addr2, ihl;
> > =A0 =A0 =A0 =A0union {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 v32;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 v16[2];
> > =A0 =A0 =A0 =A0} ports;
> >
> > - =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 index =3D skb_get_rx_queue(skb);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index >=3D dev->num_rx_q=
ueues)) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(dev->num_rx=
_queues > 1, "%s
> received packet "
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "on q=
ueue %u, but number of RX
> queues is %u\n",
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->=
name, index, dev->num_rx_queues);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx + index;
> > - =A0 =A0 =A0 } else
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx;
> > -
> > - =A0 =A0 =A0 if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > -
> > - =A0 =A0 =A0 if (skb->rxhash)
> > + =A0 =A0 =A0 if (hash)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto got_hash; /* Skip hash computat=
ion on packet header
*/
> >
> > =A0 =A0 =A0 =A0switch (skb->protocol) {
> > @@ -2334,6 +2307,7 @@ static int get_rps_cpu(struct net_device
> > =A0 =A0 =A0 =A0default:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> > =A0 =A0 =A0 =A0}
> > +
> > =A0 =A0 =A0 =A0switch (ip_proto) {
> > =A0 =A0 =A0 =A0case IPPROTO_TCP:
> > =A0 =A0 =A0 =A0case IPPROTO_UDP:
> > @@ -2356,11 +2330,59 @@ static int get_rps_cpu(struct net_device
> > =A0 =A0 =A0 =A0/* get a consistent hash (same value on both flow di=
rections) */
> > =A0 =A0 =A0 =A0if (addr2 < addr1)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swap(addr1, addr2);
> > - =A0 =A0 =A0 skb->rxhash =3D jhash_3words(addr1, addr2, ports.v32,=
 hashrnd);
> > - =A0 =A0 =A0 if (!skb->rxhash)
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->rxhash =3D 1;
> > +
> > + =A0 =A0 =A0 hash =3D jhash_3words(addr1, addr2, ports.v32, hashrn=
d);
> > + =A0 =A0 =A0 if (!hash)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D 1;
> >
> > =A0got_hash:
> > + =A0 =A0 =A0 return hash;
> > +
> > +done:
> > + =A0 =A0 =A0 return -1;
> > +}
> > +EXPORT_SYMBOL(skb_calculate_flow);
>
> I have noticed that you use skb_calculate_flow() in
> macvtap_get_queue() where skb->data doesn't point to the network
> header but the ethernet header. However, skb_calculate_flow() assume
> skb->data points to the network header. There are two choices:
>  * update skb_calculate_flow to support called in ethernet layer.
>  * pull skb before skb_calculate_flow, and push skb after
> skb_calculate_flow() in macvtap_get_queue().
>
> I prefer the former way.
>
> BTW: the function name skb_calculate_flow isn't good. How about
> skb_get_rxhash(). Maybe we can implement two versions: fast path and
> slow path. And implement the fast path version as a inline function i=
n
> skbuff.h.
>
> static inline u32 skb_get_rxhash(struct sk_buff *skb)
> {
>         u32 rxhash;
>
>         rxhash =3D skb->rxhash;
>         if (!rxhash)
>                 return __skb_get_rxhash(skb);
>         return rxhash;
> }
>
>
> > +
> > +#ifdef CONFIG_RPS
> > +
> > +/* One global table that all flow-based protocols share. */
> > +struct rps_sock_flow_table *rps_sock_flow_table __read_mostly;
> > +EXPORT_SYMBOL(rps_sock_flow_table);
> > +
> > +/*
> > + * get_rps_cpu is called from netif_receive_skb and returns the ta=
rget
> > + * CPU from the RPS map of the receiving queue for a given skb.
> > + * rcu_read_lock must be held on entry.
> > + */
> > +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb=
,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rps_dev_flow **=
rflowp)
> > +{
> > + =A0 =A0 =A0 struct netdev_rx_queue *rxqueue;
> > + =A0 =A0 =A0 struct rps_map *map;
> > + =A0 =A0 =A0 struct rps_dev_flow_table *flow_table;
> > + =A0 =A0 =A0 struct rps_sock_flow_table *sock_flow_table;
> > + =A0 =A0 =A0 int cpu =3D -1;
> > + =A0 =A0 =A0 u16 tcpu;
> > +
> > + =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 index =3D skb_get_rx_queue(skb);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(index >=3D dev->num_rx_q=
ueues)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(dev->num_rx=
_queues > 1, "%s
> received packet "
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "on q=
ueue %u, but number of RX
> queues is %u\n",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->=
name, index, dev->num_rx_queues);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx + index;
> > + =A0 =A0 =A0 } else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxqueue =3D dev->_rx;
> > +
> > + =A0 =A0 =A0 if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > +
> > + =A0 =A0 =A0 skb->rxhash =3D skb_calculate_flow(dev, skb);
> > + =A0 =A0 =A0 if (skb->rxhash < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > +
> > =A0 =A0 =A0 =A0flow_table =3D rcu_dereference(rxqueue->rps_flow_tab=
le);
> > =A0 =A0 =A0 =A0sock_flow_table =3D rcu_dereference(rps_sock_flow_ta=
ble);
> > =A0 =A0 =A0 =A0if (flow_table && sock_flow_table) {
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
> >
>
>
>
> --
> Regards,
> Changli Gao(xiaosuo@gmail.com)

