From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH 07/12] vlan: convert VLAN devices to use
	ndo_fix_features()
Date: Sun, 19 Dec 2010 02:01:51 +0100
Message-ID: <20101219010151.GD12005@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl> <34dbc2d3d83d82f506f0f073dbf00444885e4f81.1292451560.git.mirq-linux@rere.qmqm.pl> <1292542618.18294.29.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34337 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757196Ab0LSBBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Dec 2010 20:01:53 -0500
Content-Disposition: inline
In-Reply-To: <1292542618.18294.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:36:58PM +0000, Ben Hutchings wrote:
> On Wed, 2010-12-15 at 23:24 +0100, Micha=B3 Miros=B3aw wrote:
> > Note: get_flags was actually broken, because it should return the
> > flags capped with vlan_features. This is now done implicitly by
> > limiting netdev->hw_features.
> >=20
> > RX checksumming offload control is (and was) broken, as there was n=
o way
> > before to say whether it's done for tagged packets.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  net/8021q/vlan.c     |    3 +-
> >  net/8021q/vlan_dev.c |   51 ++++++++++++++------------------------=
-----------
> >  2 files changed, 16 insertions(+), 38 deletions(-)
> >=20
> > diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> > index 6e64f7c..583d47b 100644
> > --- a/net/8021q/vlan.c
> > +++ b/net/8021q/vlan.c
> > @@ -329,8 +329,7 @@ static void vlan_transfer_features(struct net_d=
evice *dev,
> >  {
> >  	unsigned long old_features =3D vlandev->features;
> > =20
> > -	vlandev->features &=3D ~dev->vlan_features;
> > -	vlandev->features |=3D dev->features & dev->vlan_features;
> > +	netdev_update_features(vlandev);
> >  	vlandev->gso_max_size =3D dev->gso_max_size;
> > =20
> >  	if (dev->features & NETIF_F_HW_VLAN_TX)
> > diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> > index be73753..468c899 100644
> > --- a/net/8021q/vlan_dev.c
> > +++ b/net/8021q/vlan_dev.c
> > @@ -691,8 +691,8 @@ static int vlan_dev_init(struct net_device *dev=
)
> >  					  (1<<__LINK_STATE_DORMANT))) |
> >  		      (1<<__LINK_STATE_PRESENT);
> > =20
> > -	dev->features |=3D real_dev->features & real_dev->vlan_features;
> > -	dev->features |=3D NETIF_F_LLTX;
> > +	dev->hw_features =3D real_dev->vlan_features;
> [...]
> net_device::hw_features is supposed to represent features that can be
> toggled, but the inclusion of a flag in net_device::vlan_features doe=
s
> not mean the feature can be toggled.

All TX offloads are by definition togglable since it just a matter of n=
ot
issuing skb's that need them. RX offloads on the other hand are control=
led
by underlying device, so probably should be removed from this set and
forced on or left alone in ndo_fix_features().

> If this is to be a straight conversion, that line should be:
> 	dev->hw_features =3D real_dev->vlan_features & NETIF_F_TSO;

I'll mask this with ALL_CSUM+SG+ALL_TSO if you don't mind extending the
possibilities anyway.

Best Regards,
Micha=B3 Miros=B3aw
