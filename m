From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] NET: IPV4: ARP: allow to invalidate specific ARP
 entries
Date: Sun, 05 Dec 2010 09:19:21 +0100
Message-ID: <1291537161.2806.109.camel@edumazet-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
	 <1291504514.1874.92.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel <linux1394-devel@lists.sourceforge.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65033 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab0LEIT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 03:19:28 -0500
Received: by wwa36 with SMTP id 36so11691573wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 00:19:26 -0800 (PST)
In-Reply-To: <1291504514.1874.92.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 01:15 +0200, Maxim Levitsky a =
=C3=A9crit :
> On Mon, 2010-11-29 at 04:09 +0200, Maxim Levitsky wrote:
> > IPv4 over firewire needs to be able to remove ARP entries
> > from the ARP cache that belong to nodes that are removed, because
> > IPv4 over firewire uses ARP packets for private information
> > about nodes.
> >=20
> > This information becomes invalid as soon as node drops
> > off the bus and when it reconnects, its only possible
> > to start takling to is after it responded to an ARP packet.
> > But ARP cache prevents such packets from being sent.
> >=20
> > CC: netdev@vger.kernel.org
> > CC: "David S. Miller" <davem@davemloft.net>
> > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > CC: James Morris <jmorris@namei.org>
> > CC: Patrick McHardy <kaber@trash.net>
>=20
> Anybody?
>=20
> Best regards,
> 	Maxim Levitsky
> >=20
> >=20
> > Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> > ---
> >  include/net/arp.h |    1 +
> >  net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
> >  2 files changed, 19 insertions(+), 11 deletions(-)
> >=20
> > diff --git a/include/net/arp.h b/include/net/arp.h
> > index f4cf6ce..91f0568 100644
> > --- a/include/net/arp.h
> > +++ b/include/net/arp.h
> > @@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int p=
type, __be32 dest_ip,
> >  				  const unsigned char *src_hw,
> >  				  const unsigned char *target_hw);
> >  extern void arp_xmit(struct sk_buff *skb);
> > +int arp_invalidate(struct net_device *dev, __be32 ip);
> > =20
> >  #endif	/* _ARP_H */
> > diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> > index d8e540c..35b1272 100644
> > --- a/net/ipv4/arp.c
> > +++ b/net/ipv4/arp.c
> > @@ -1142,6 +1142,23 @@ static int arp_req_get(struct arpreq *r, str=
uct net_device *dev)
> >  	return err;
> >  }
> > =20
> > +int arp_invalidate(struct net_device *dev, __be32 ip)
> > +{
> > +	int err =3D -ENXIO;
> > +	struct neighbour *neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
> > +
> > +	if (neigh) {
> > +		if (neigh->nud_state & ~NUD_NOARP)
> > +			err =3D neigh_update(neigh, NULL, NUD_FAILED,
> > +					   NEIGH_UPDATE_F_OVERRIDE|
> > +					   NEIGH_UPDATE_F_ADMIN);
> > +		neigh_release(neigh);
> > +	}
> > +
> > +	return err;
> > +}
> > +EXPORT_SYMBOL(arp_invalidate);
> > +
> >  static int arp_req_delete_public(struct net *net, struct arpreq *r=
,
> >  		struct net_device *dev)
> >  {
> > @@ -1162,7 +1179,6 @@ static int arp_req_delete(struct net *net, st=
ruct arpreq *r,
> >  {
> >  	int err;
> >  	__be32 ip;
> > -	struct neighbour *neigh;
> > =20
> >  	if (r->arp_flags & ATF_PUBL)
> >  		return arp_req_delete_public(net, r, dev);
> > @@ -1180,16 +1196,7 @@ static int arp_req_delete(struct net *net, s=
truct arpreq *r,
> >  		if (!dev)
> >  			return -EINVAL;
> >  	}
> > -	err =3D -ENXIO;
> > -	neigh =3D neigh_lookup(&arp_tbl, &ip, dev);
> > -	if (neigh) {
> > -		if (neigh->nud_state & ~NUD_NOARP)
> > -			err =3D neigh_update(neigh, NULL, NUD_FAILED,
> > -					   NEIGH_UPDATE_F_OVERRIDE|
> > -					   NEIGH_UPDATE_F_ADMIN);
> > -		neigh_release(neigh);
> > -	}
> > -	return err;
> > +	return arp_invalidate(dev, ip);
> >  }
> > =20
> >  /*
>=20

Hmm..

If somebody can explain why RTNL is held in arp_ioctl() (and therefore
in arp_req_delete()), we might first remove RTNL use in arp_ioctl() so
that your patch can be applied.

Right now it is not good, because RTNL wont be necessarly held when you
are going to call arp_invalidate() ?





