From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new]
	[Bug 19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at
	full line rate traffic)
Date: Fri, 22 Oct 2010 06:52:31 +0000
Message-ID: <20101022065231.GA7036@ff.dom.local>
References: <20101010103236.GA1919@del.dom.local> <20101015085853.GA8091@ff.dom.local> <AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com> <20101016194815.GA1894@del.dom.local> <AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com> <20101019100636.GA9246@ff.dom.local> <1287727917.9059.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, emin ak <eminak71@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50716 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab0JVGwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 02:52:43 -0400
Received: by bwz11 with SMTP id 11so258514bwz.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 23:52:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1287727917.9059.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 08:11:57AM +0200, Eric Dumazet wrote:
> Le mardi 19 octobre 2010 ?? 10:06 +0000, Jarek Poplawski a =E9crit :
> > On Tue, Oct 19, 2010 at 09:44:33AM +0300, emin ak wrote:
> > > Hi Jarek;
> > > After 5 days and more then 20 billion packets passed without cras=
h, it
> > > seems that this patch is working for me, at least for crash type =
2.
> > > (For type 1, it only occured once and I can never reproduce this
> > > again, but still trying. I think with this patch is also lowers t=
he
> > > risk for type 1.
> >=20
> > It would be interesting to have a look if it's exactly type 1, beca=
use
> > skb_over_panic can happen for different reasons, e.g. like here:
> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dcommitdiff;h=3D63b88b9041ceef8217f34de71a2e96f0c3f0fd3b
> >=20
> > > For adding a new bug entry for skb_over_panic, before that I thin=
k I
> > > must find a reliable way to make this type of crash reproducable,
> > > otherwise I don't know how to test it if it solved or not.
> >=20
> > Maybe for now let's try to get and see this type 1 again? Since the
> > recycle path is suspicious a bit to me, probably limiting memory or
> > slowing tx (maybe different mtus on eth0 and 1) under heavy multi c=
pu
> > load might help.
> >=20
> > > Lastly, thanks a lot for your valuable help to overcome this prob=
lem
> > > and also is there anything that I can do  for testing / commiting=
 this
> > > patch to mainline?
> >=20
> > Here it is for David to handle the rest.
> >=20
> > Thanks a lot for such an intense testing,
> > Jarek P.
> > --------------------------->
> >=20
> > The rx_recycle queue is global per device but can be accesed by man=
y
> > napi handlers at the same time, so it needs full skb_queue primitiv=
es
> > (with locking). Otherwise, various crashes caused by broken skbs ar=
e
> > possible.
> >=20
> > This patch resolves, at least partly, bugzilla bug 19692. (Because =
of
> > some doubts that there could be still something around which is har=
d
> > to reproduce my proposal is to leave this bug opened for a month.)
> >=20
> > Fixes commit: 0fd56bb5be6455d0d42241e65aed057244665e5e
> >=20
> > Reported-by: emin ak <eminak71@gmail.com>
> > Tested-by: emin ak <eminak71@gmail.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > CC: Andy Fleming <afleming@freescale.com>
> > ---
> > diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> > index 4f7c3f3..db47b55 100644
> > --- a/drivers/net/gianfar.c
> > +++ b/drivers/net/gianfar.c
> > @@ -2515,7 +2515,7 @@ static int gfar_clean_tx_ring(struct gfar_pri=
v_tx_q *tx_queue)
> >  				skb_recycle_check(skb, priv->rx_buffer_size +
> >  					RXBUF_ALIGNMENT)) {
> >  			gfar_align_skb(skb);
> > -			__skb_queue_head(&priv->rx_recycle, skb);
> > +			skb_queue_head(&priv->rx_recycle, skb);
> >  		} else
> >  			dev_kfree_skb_any(skb);
> > =20
> > @@ -2598,7 +2598,7 @@ struct sk_buff * gfar_new_skb(struct net_devi=
ce *dev)
> >  	struct gfar_private *priv =3D netdev_priv(dev);
> >  	struct sk_buff *skb =3D NULL;
> > =20
> > -	skb =3D __skb_dequeue(&priv->rx_recycle);
> > +	skb =3D skb_dequeue(&priv->rx_recycle);
> >  	if (!skb)
> >  		skb =3D gfar_alloc_skb(dev);
> > =20
> > @@ -2754,7 +2754,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q =
*rx_queue, int rx_work_limit)
> >  			if (unlikely(!newskb))
> >  				newskb =3D skb;
> >  			else if (skb)
> > -				__skb_queue_head(&priv->rx_recycle, skb);
> > +				skb_queue_head(&priv->rx_recycle, skb);
> >  		} else {
> >  			/* Increment the number of packets */
> >  			rx_queue->stats.rx_packets++;
>=20
> Are you sure its needed at all ?

Yes, after Emin's testing I'm quite sure this fix is needed.

>=20
> Gianfar claims to be multiqueue, but only one cpu can run gfar_poll()
> and call gfar_clean_tx_ring() / gfar_clean_rx_ring()
>=20
> If not, there would be more bugs than only rx_recycle thing

I didn't find what prevents running gfar_poll on many cpus and don't
claim there is no more bugs around.

Jarek P.

>=20
> vi +2822 drivers/net/gianfar.c
>=20
>                 for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_r=
x_queues) {
>                         if (test_bit(i, &serviced_queues))
>                                 continue;
>                         rx_queue =3D priv->rx_queue[i];
>                         tx_queue =3D priv->tx_queue[rx_queue->qindex]=
;
>=20
>                         tx_cleaned +=3D gfar_clean_tx_ring(tx_queue);
>                         rx_cleaned_per_queue =3D gfar_clean_rx_ring(r=
x_queue,
>                                                         budget_per_qu=
eue);
>                         rx_cleaned +=3D rx_cleaned_per_queue;
>                         if(rx_cleaned_per_queue < budget_per_queue) {
>                                 left_over_budget =3D left_over_budget=
 +
>                                         (budget_per_queue - rx_cleane=
d_per_queue);
>                                 set_bit(i, &serviced_queues);
>                                 num_queues--;
>                         }
>                 }
>=20
>=20
