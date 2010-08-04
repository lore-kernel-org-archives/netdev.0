From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH v4 1/2] core: Factor out flow calculation from get_rps_cpu
Date: Wed, 4 Aug 2010 17:32:44 +0530
Message-ID: <OFE9752776.5432C83A-ON65257775.003F1B51-65257775.00420641@in.ibm.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com> <AANLkTikfW_PfYVfA-9cSx8-j16OuH6mr9K32apPj6nLy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, bhutchings@solarflare.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org, therbert@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:53144 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757476Ab0HDMBP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 08:01:15 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id o74C1BWj014299
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 17:31:11 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o74C1BEg2363634
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 17:31:11 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o74C1Agl011340
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 22:01:11 +1000
In-Reply-To: <AANLkTikfW_PfYVfA-9cSx8-j16OuH6mr9K32apPj6nLy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> wrote on 08/04/2010 04:52:58 PM:

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
> > + =A0 =A0 =A0 skb->rxhash =3D skb_get_rxhash(skb);
>
> the return value of skb_get_rxhash() maybe skb->rxhash, so we don't
> need to assign it to skb->rxhash again. Use a local variable to save
> the value and __skb_get_rxhash() should cache the rxhash into
> skb->rxhash for future use.

I wanted the function to return a rxhash instead of save+return,
since other users, eg macvtap, doesn't need the rxhash beyond
calculating a rxq with that hash. So for those users, we can
avoid updating both skb->rxhash and a local variable (since with
your suggestion, rps will update either one or two variables
depending on whether rxhash is cached or not). I am not sure
which is better.

Thanks,

- KK

