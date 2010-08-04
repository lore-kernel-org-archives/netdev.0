From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH v4 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Wed, 4 Aug 2010 18:55:24 +0530
Message-ID: <OF3D82198C.4738EB40-ON65257775.0046DC1D-65257775.004997E7@in.ibm.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com> 	<20100804105525.22212.45090.sendpatchset@krkumar2.in.ibm.com> <AANLkTimgSg+iFouARaFv8X6S8d2e6L+ffkZkoOaja20R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, bhutchings@solarflare.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org, therbert@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:54938 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757820Ab0HDNX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:23:56 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id o74DEYMf016114
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 18:44:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o74DNrkS3813558
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 18:53:53 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o74DNqTo030697
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 23:23:53 +1000
In-Reply-To: <AANLkTimgSg+iFouARaFv8X6S8d2e6L+ffkZkoOaja20R@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> wrote on 08/04/2010 05:07:23 PM:

Thanks for your review and comments!

> > =A0static struct macvtap_queue *macvtap_get_queue(struct net_device=
 *dev,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb)
> > =A0{
> > =A0 =A0 =A0 =A0struct macvlan_dev *vlan =3D netdev_priv(dev);
> > + =A0 =A0 =A0 struct macvtap_queue *tap =3D NULL;
> > + =A0 =A0 =A0 int numvtaps =3D vlan->numvtaps;
> > + =A0 =A0 =A0 __u32 rxq;
> > +
> > + =A0 =A0 =A0 if (!numvtaps)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> > +
> > + =A0 =A0 =A0 if (likely(skb_rx_queue_recorded(skb))) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D skb_get_rx_queue(skb);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (unlikely(rxq >=3D numvtaps))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq -=3D numvtaps;
> >
> > - =A0 =A0 =A0 return rcu_dereference(vlan->tap);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[rx=
q]);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tap)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> > + =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 rxq =3D skb_get_rxhash(skb);
> > + =A0 =A0 =A0 if (!rxq)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D smp_processor_id();
> > +
> > + =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[rxq & (numvtaps - =
1)]);
> > +
>
> numvtaps maybe not power of 2. So some queue maybe can't be used.
> You'd better maintain a online queue map and get the index as
> get_rps_cpu() dones.
>
> ((u64)rxhash * numvtaps) >> 32
>
> for the sbks, we can't get a valid rxhash, we'd better pass them to a
> specified queue, such as queue 0.

macvtap *with* mq support would be used with mq devices - you
open multiple queues on the macvtap device depending on the
number of queues for the physical device. So since this is an
unlikely case (as can be seen in the patch, and I guess I
should add another "likely" to the "if (tap)" check since fd's
should not be closed), I guess a simple % can be used. Does
the following sound reasonable?

1. Use % to find the slot.
2. If slot is null - I don't want to handle this since I think
   it is better to return NULL if some fd's were closed by user.
   Typically this should never happen since fd's are opened and
   passed to vhost for setting up the backend. So if they are
   closed, then I think NULL is OK.

Arnd, please let me know what you would also suggest.

- KK

