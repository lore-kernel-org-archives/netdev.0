From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Wed, 2 Dec 2009 11:38:15 -0500
Message-ID: <20091202163814.GK1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <4B15F76B.9040203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbZLBQiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 11:38:13 -0500
Content-Disposition: inline
In-Reply-To: <4B15F76B.9040203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 06:13:15AM +0100, Eric Dumazet wrote:
> Andy Gospodarek a =E9crit :
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 5d131c2..eeee269 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
> >  		skb->skb_iif =3D skb->dev->ifindex;
> > =20
> >  	null_or_orig =3D NULL;
> > -	orig_dev =3D skb->dev;
> > -	if (orig_dev->master) {
> > +	orig_dev =3D __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
> > +	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)=
) {
> >  		if (skb_bond_should_drop(skb))
> >  			null_or_orig =3D orig_dev; /* deliver only exact match */
> >  		else
>=20
>=20
> Please dont add a __dev_get_by_index() call in netif_receive_skb()
>=20
> First, this is not safe against writers.
>=20
> Second its very expensive on some setups.
>=20
> Eventually, you could do something like :
>=20
>=20
> Change prototypes of netif_receive_skb() to include the orig_dev in a=
rguments.
> Change vlan code to call __netif_receive_skb(skb, orig_dev)
> instead of netif_received_skb(skb)
>=20
> int __netif_receive_skb(struct sk_buff *skb, struct net_device *orig_=
dev)
> {
> ...
> 	if (!skb->skb_iif) {
> 		skb->skb_iif =3D orig_dev->ifindex;
> 	} else {
> 		if (orig_dev->master &&  ...)=20
> 	}
>=20
> }
>=20
> int netif_receive_skb(struct sk_buff *skb)
> {
> 	return __netif_receive_skb(skb, skb->dev);
> }
>=20

That is an interesting thought.  I'll investigate this as well.

