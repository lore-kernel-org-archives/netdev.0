From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 08:01:51 +0200
Message-ID: <1271052111.2078.168.camel@edumazet-laptop>
References: <201004112338.47019.nuclearcat@nuclearcat.com>
	 <1271025353.2078.155.camel@edumazet-laptop>
	 <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44946 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab0DLGB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 02:01:58 -0400
Received: by bwz19 with SMTP id 19so155781bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 23:01:56 -0700 (PDT)
In-Reply-To: <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 09:08 +0530, Krishna Kumar2 a =C3=A9crit =
:
> Hi Eric,
>=20
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 04/12/2010 04:05:53 AM=
:
>=20
> > I believe the following lines from dev_pick_tx() are not the proble=
m :
> >
> >    if (sk && sk->sk_dst_cache)
> >       sk_tx_queue_set(sk, queue_index);
> >
> > It is IMHO not safe, because route for this socket might have just
> > changed and we are transmitting an old packet (queued some milli se=
conds
> > before, when route was different).
> >
> > We then memorize a queue_index that might be too big for the new de=
vice
> > of new selected route.
> >
> > Next packet we want to transmit will take the cached value of
> > queue_index, correct for old device, maybe not correct for new devi=
ce.
>=20
> When route changes, I think my patch had reset sk->sk_tx_queue_mappin=
g
> by calling sk_tx_queue_clear. I don't know if I missed any path where
> the route changes and sk_dst_reset() was not called.
>=20

Problem is when you reset sk->sk_tx_queue_mapping at the very moment
route (or destination) changes, we might have old packets queued in tx
queues, of the old ethernet device (eth0 : multi queue compatable)

2) Application does a sendmsg() or connect() call and sk->sk_dst_cache
is rebuild, it points to a dst_entry referring a new device (eth1 : non
multiqueue)

3) When one old packet finally is transmitted, we do :

	queue_index =3D 1; // any value > 0

	if (sk && sk->sk_dst_cache)
		sk_tx_queue_set(sk, queue_index); // remember a >0 value

4) application does a sendmsg(), enqueues a new skb on eth1

5) We re-enter dev_pick_tx(), and consider cached value in 3) is valid.
   we pick a non existent txq for eth1 device.

6) We crash.


> The following might be better to prove the panic is due to this, sinc=
e
> your suggestion will hide a panic that happens somewhat rare (accordi=
ng
> to Denys):
>=20
>       if (sk_tx_queue_recorded(sk)) {
>             queue_index =3D sk_tx_queue_get(sk);
> +           queue_index =3D dev_cap_txqueue(dev, queue_index);
>       } else {
>=20

Sure, but I thought I was clear enough to prove this commit was wrong,
and we have to find a fix.

> Thanks,
>=20
> - KK
>=20
> > You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde1295=
aebe
> >
> > commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
> > Author: Krishna Kumar <krkumar2@in.ibm.com>
> > Date:   Mon Oct 19 23:50:07 2009 +0000
> >
> >     net: Use sk_tx_queue_mapping for connected sockets
> >
> >     For connected sockets, the first run of dev_pick_tx saves the
> >     calculated txq in sk_tx_queue_mapping. This is not saved if
> >     either the device has a queue select or the socket is not
> >     connected. Next iterations of dev_pick_tx uses the cached value
> >     of sk_tx_queue_mapping.
> >
> >     Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 28b0b9e..fa88dcd 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
> >  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
> >                 struct sk_buff *skb)
> >  {
> > -   const struct net_device_ops *ops =3D dev->netdev_ops;
> > -   u16 queue_index =3D 0;
> > +   u16 queue_index;
> > +   struct sock *sk =3D skb->sk;
> > +
> > +   if (sk_tx_queue_recorded(sk)) {
> > +      queue_index =3D sk_tx_queue_get(sk);
> > +   } else {
> > +      const struct net_device_ops *ops =3D dev->netdev_ops;
> >
> > -   if (ops->ndo_select_queue)
> > -      queue_index =3D ops->ndo_select_queue(dev, skb);
> > -   else if (dev->real_num_tx_queues > 1)
> > -      queue_index =3D skb_tx_hash(dev, skb);
> > +      if (ops->ndo_select_queue) {
> > +         queue_index =3D ops->ndo_select_queue(dev, skb);
> > +      } else {
> > +         queue_index =3D 0;
> > +         if (dev->real_num_tx_queues > 1)
> > +            queue_index =3D skb_tx_hash(dev, skb);
> > +
> > +         if (sk && sk->sk_dst_cache)
> > +            sk_tx_queue_set(sk, queue_index);
> > +      }
> > +   }
> >
> >     skb_set_queue_mapping(skb, queue_index);
> >     return netdev_get_tx_queue(dev, queue_index);
> >
> >
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


