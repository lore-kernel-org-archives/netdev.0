From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 18:03:05 +0200
Message-ID: <1278604985.2651.35.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52969 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0GHQDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:03:10 -0400
Received: by wyf23 with SMTP id 23so683894wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 09:03:08 -0700 (PDT)
In-Reply-To: <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 16:43 +0100, Ben Hutchings a =C3=A9crit=
 :
> On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
> > When we need to shape traffic with low speeds, we need to disable t=
so on
> > network interface :
> >=20
> > ethtool -K eth0.2240 tso off
> >=20
> > It seems vlan interfaces miss the set_tso() ethtool method.
> > Propagating tso changes from lower device is not always wanted, som=
e
> > vlans want TSO on, others want TSO off.
> >=20
> > Before enabling TSO, we must check real device supports it.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/8021q/vlan_dev.c |   13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> >=20
> > diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> > index c6456cb..870bc53 100644
> > --- a/net/8021q/vlan_dev.c
> > +++ b/net/8021q/vlan_dev.c
> > @@ -838,12 +838,25 @@ static struct rtnl_link_stats64 *vlan_dev_get=
_stats64(struct net_device *dev)
> >  	return stats;
> >  }
> > =20
> > +static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
> > +{
> > +	if (data) {
> > +		struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
> > +		unsigned long rdev_vfeatures =3D real_dev->features & real_dev->=
vlan_features;
> > +
> > +		dev->features |=3D (NETIF_F_TSO & rdev_vfeatures);
> > +	} else
> > +		dev->features &=3D ~NETIF_F_TSO;
> > +	return 0;
> > +}
> [...]
>=20
> This should not silently ignore attempts to enable TSO.  I think it
> should be something like:
>=20
> static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
> {
> 	if (data) {
> 		struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
>=20
> 		/* Underlying device must support TSO for VLAN-tagged packets
> 		 * and must have TSO enabled now. */
> 		if (!(real_dev->vlan_features & NETIF_F_TSO))
> 			return -EOPNOTSUPP;
> 		if (!(real_dev->features & NETIF_F_TSO))
> 			return -EINVAL;
>=20
> 		dev->features |=3D NETIF_F_TSO;
> 	} else {
> 		dev->features &=3D ~NETIF_F_TSO;
> 	}
>=20
> 	return 0;
> }

I agree.

What about other TSO flags like NETIF_F_TSO6 & NETIF_F_TSO_ECN ?

Not sure if we should manipulate them in set_tso()


