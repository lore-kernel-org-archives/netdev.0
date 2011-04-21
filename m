From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Fri, 22 Apr 2011 01:14:34 +0200
Message-ID: <20110421231434.GD7888@rere.qmqm.pl>
References: <20110411202630.C079D13909@rere.qmqm.pl> <1302610228.32697.298.camel@lb-tlvb-vladz> <20110412140708.GA21835@rere.qmqm.pl> <1302619012.6750.8.camel@lb-tlvb-vladz> <20110412193823.0823213A65@rere.qmqm.pl> <1303397531.3685.16.camel@edumazet-laptop> <1303411750.19212.123.camel@lb-tlvb-vladz> <1303413559.3165.55.camel@bwh-desktop> <20110421221548.GA7888@rere.qmqm.pl> <1303426342.3464.184.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39731 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab1DUXOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 19:14:35 -0400
Content-Disposition: inline
In-Reply-To: <1303426342.3464.184.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2011 at 11:52:22PM +0100, Ben Hutchings wrote:
> On Fri, 2011-04-22 at 00:15 +0200, Micha=B3 Miros=B3aw wrote:
> > On Thu, Apr 21, 2011 at 08:19:19PM +0100, Ben Hutchings wrote:
> > > 	/* Transfer changeable features to wanted_features and enable
> > > 	 * software offloads (GSO and GRO).
> > > 	 */
> > > 	dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
> > > 	dev->features |=3D NETIF_F_SOFT_FEATURES;
> > > 	dev->wanted_features =3D dev->features & dev->hw_features;
> > >=20
> > > This doesn't work correctly for features that are always enabled,=
 like
> > > NETIF_F_HW_VLAN_RX in bnx2x, which are set in dev->features but n=
ot in
> > > dev->hw_features.
> >=20
> > > The name 'hw_features' really wasn't a good choice - the obvious =
meaning
> > > and the meaning assumed by this code is 'hardware-supported featu=
res'
> > > and not 'hardware-supported features that can be toggled'.  And s=
ince we
> > > add NETIF_F_SOFT_FEATURES, it really only means 'features that ca=
n be
> > > toggled'.
> >=20
> > I won't argue about hw_features name - I just couldn't find a bette=
r one.
> > Comment in include/linux/netdevice.h clearly explains the purpose o=
f this
> > field.
> >=20
> > wanted_features is supposed to be limited by hw_features (so that i=
t's always
> > true that (hw_features & wanted_features) =3D=3D wanted_features). =
If you have
> > an idea how to make that more clear, I'd be happy to update descrip=
tions.
>=20
> Then the computation of 'changed' in __ethtool_set_flags() is wrong:
>=20
> 	/* allow changing only bits set in hw_features */
> 	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
> 	if (changed & ~dev->hw_features)
> 		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;

Yes! This doesn't take account of features enabled but not togglable.

> You need to add something like:
>=20
> 	/* Features that are requested to be on, are already on, and cannot
> 	 * be changed, have not changed.
> 	 */
> 	changes &=3D ~(data & dev->features & ~dev->hw_features);
>=20
> It seems like there ought to be a way to simplify that, though!

Maybe something I just sent will do.

Best Regards,
Micha=B3 Miros=B3aw
