From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v4 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Wed, 4 Aug 2010 21:42:05 +0800
Message-ID: <AANLkTi=aVRk7MOEHPoGAQwtJ8bH9Ovkk_Kx-5DpK9S4f@mail.gmail.com>
References: <20100804105515.22212.41598.sendpatchset@krkumar2.in.ibm.com>
	<20100804105525.22212.45090.sendpatchset@krkumar2.in.ibm.com>
	<AANLkTimgSg+iFouARaFv8X6S8d2e6L+ffkZkoOaja20R@mail.gmail.com>
	<OF3D82198C.4738EB40-ON65257775.0046DC1D-65257775.004997E7@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, bhutchings@solarflare.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org, therbert@google.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36215 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262Ab0HDNm0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 09:42:26 -0400
Received: by wwj40 with SMTP id 40so6455659wwj.1
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 06:42:25 -0700 (PDT)
In-Reply-To: <OF3D82198C.4738EB40-ON65257775.0046DC1D-65257775.004997E7@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 4, 2010 at 9:25 PM, Krishna Kumar2 <krkumar2@in.ibm.com> wr=
ote:
> Changli Gao <xiaosuo@gmail.com> wrote on 08/04/2010 05:07:23 PM:
>
> Thanks for your review and comments!
>
>> > =A0static struct macvtap_queue *macvtap_get_queue(struct net_devic=
e *dev,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb)
>> > =A0{
>> > =A0 =A0 =A0 =A0struct macvlan_dev *vlan =3D netdev_priv(dev);
>> > + =A0 =A0 =A0 struct macvtap_queue *tap =3D NULL;
>> > + =A0 =A0 =A0 int numvtaps =3D vlan->numvtaps;
>> > + =A0 =A0 =A0 __u32 rxq;
>> > +
>> > + =A0 =A0 =A0 if (!numvtaps)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> > +
>> > + =A0 =A0 =A0 if (likely(skb_rx_queue_recorded(skb))) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D skb_get_rx_queue(skb);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (unlikely(rxq >=3D numvtaps))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq -=3D numvtaps;
>> >
>> > - =A0 =A0 =A0 return rcu_dereference(vlan->tap);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[r=
xq]);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tap)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> > + =A0 =A0 =A0 }
>> > +
>> > + =A0 =A0 =A0 rxq =3D skb_get_rxhash(skb);
>> > + =A0 =A0 =A0 if (!rxq)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxq =3D smp_processor_id();
>> > +
>> > + =A0 =A0 =A0 tap =3D rcu_dereference(vlan->taps[rxq & (numvtaps -=
 1)]);
>> > +
>>
>> numvtaps maybe not power of 2. So some queue maybe can't be used.
>> You'd better maintain a online queue map and get the index as
>> get_rps_cpu() dones.
>>
>> ((u64)rxhash * numvtaps) >> 32
>>
>> for the sbks, we can't get a valid rxhash, we'd better pass them to =
a
>> specified queue, such as queue 0.
>
> macvtap *with* mq support would be used with mq devices - you
> open multiple queues on the macvtap device depending on the
> number of queues for the physical device. So since this is an
> unlikely case (as can be seen in the patch, and I guess I
> should add another "likely" to the "if (tap)" check since fd's
> should not be closed), I guess a simple % can be used. Does
> the following sound reasonable?
>
> 1. Use % to find the slot.

It is slower than the method used by get_rps_cpu().

> 2. If slot is null - I don't want to handle this since I think
> =A0 it is better to return NULL if some fd's were closed by user.
> =A0 Typically this should never happen since fd's are opened and
> =A0 passed to vhost for setting up the backend. So if they are
> =A0 closed, then I think NULL is OK.
>
> Arnd, please let me know what you would also suggest.
>
> - KK
>
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
