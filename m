From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 3/4] Ethtool: convert get_tso/set_tso calls to
	hw_features flags
Date: Tue, 2 Nov 2010 02:14:44 +0100
Message-ID: <20101102011444.GD15848@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl> <1288646754.2231.70.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:54963 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab0KBBOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 21:14:46 -0400
Content-Disposition: inline
In-Reply-To: <1288646754.2231.70.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 09:25:54PM +0000, Ben Hutchings wrote:
> On Sat, 2010-10-30 at 10:44 +0200, Micha=B3 Miros=B3aw wrote:
> [...]
> > @@ -1670,7 +1668,7 @@ struct net_device *nes_netdev_init(struct nes=
_device *nesdev,
> >  	netdev->type =3D ARPHRD_ETHER;
> >  	netdev->features =3D NETIF_F_HIGHDMA;
> >  	netdev->netdev_ops =3D &nes_netdev_ops;
> > -	netdev->hw_features |=3D NETIF_F_SG;
> > +	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
>=20
> There should be spaces on either side of the '|' operator.

The style varies among drivers' sources. I don't have any preference
whatsoever.

> [...]
> > diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> > index 9e27bd6..814a06c 100644
> > --- a/drivers/net/atlx/atl1.c
> > +++ b/drivers/net/atlx/atl1.c
> > @@ -2992,6 +2992,7 @@ static int __devinit atl1_probe(struct pci_de=
v *pdev,
> >  	netdev->watchdog_timeo =3D 5 * HZ;
> > =20
> >  	netdev->hw_features |=3D NETIF_F_SG;
> > +	netdev->hw_features |=3D NETIF_F_TSO;
>=20
> Why not set both flags in the same statement?  You might as well make
> the drivers consistent in this regard.

Will fix. The compiler should combine those anyway.

> [...]
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 017667c..9b0e598 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> [...]
> > @@ -1065,10 +1048,13 @@ static int __ethtool_set_sg(struct net_devi=
ce *dev, u32 data)
> >  {
> >  	int err;
> > =20
> > -	if (!data && dev->ethtool_ops->set_tso) {
> > -		err =3D dev->ethtool_ops->set_tso(dev, 0);
> > -		if (err)
> > -			return err;
> > +	if (!data && (dev->hw_features & NETIF_F_ALL_TSO)) {
> > +		if (dev->ethtool_ops->hw_set_tso) {
> > +			err =3D dev->ethtool_ops->hw_set_tso(dev, 0);
> > +			if (err < 0)
> > +				return err;
> > +		}
> > +		dev->features &=3D dev->hw_features & NETIF_F_ALL_TSO;
>=20
> Surely this should be:
> 		dev->features &=3D ~NETIF_F_ALL_TSO;

I originally thought of hw_features as a bitfield of features changable
by ethtool.  So if driver writer wanted to have TSO permanently on but
allow toggling of TSO6 for debug than that would work.  There is actual=
ly
a bug in original code: it doesn't clear NETIF_F_TSO if there is no set=
_tso
function, but clears NETIF_F_SG anyway (the bug is preserved).  This is
a material for successive patches.

BTW, why is scatter-gather needed for TSO and TX checksumming?  I see
no interdependence on s-g for those offloads.

> [...]
> > @@ -1158,7 +1149,18 @@ static int ethtool_set_tso(struct net_device=
 *dev, char __user *useraddr)
> >  	if (edata.data && !(dev->features & NETIF_F_SG))
> >  		return -EINVAL;
> > =20
> > -	return dev->ethtool_ops->set_tso(dev, edata.data);
> > +	if (dev->ethtool_ops->hw_set_tso) {
> > +		int err =3D dev->ethtool_ops->hw_set_tso(dev, edata.data);
> > +		if (err)
> > +			return min(err, 0);
> [...]
>=20
> Again, the odd semantics of a positive value need to be documented.

Of course.

Best Regards,
Micha=B3 Miros=B3aw
=20
