From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Thu, 21 Apr 2011 23:52:22 +0100
Message-ID: <1303426342.3464.184.camel@localhost>
References: <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
	 <1303397531.3685.16.camel@edumazet-laptop>
	 <1303411750.19212.123.camel@lb-tlvb-vladz>
	 <1303413559.3165.55.camel@bwh-desktop> <20110421221548.GA7888@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30632 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab1DUWwZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 18:52:25 -0400
In-Reply-To: <20110421221548.GA7888@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-22 at 00:15 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Apr 21, 2011 at 08:19:19PM +0100, Ben Hutchings wrote:
> > 	/* Transfer changeable features to wanted_features and enable
> > 	 * software offloads (GSO and GRO).
> > 	 */
> > 	dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
> > 	dev->features |=3D NETIF_F_SOFT_FEATURES;
> > 	dev->wanted_features =3D dev->features & dev->hw_features;
> >=20
> > This doesn't work correctly for features that are always enabled, l=
ike
> > NETIF_F_HW_VLAN_RX in bnx2x, which are set in dev->features but not=
 in
> > dev->hw_features.
>=20
> > The name 'hw_features' really wasn't a good choice - the obvious me=
aning
> > and the meaning assumed by this code is 'hardware-supported feature=
s'
> > and not 'hardware-supported features that can be toggled'.  And sin=
ce we
> > add NETIF_F_SOFT_FEATURES, it really only means 'features that can =
be
> > toggled'.
>=20
> I won't argue about hw_features name - I just couldn't find a better =
one.
> Comment in include/linux/netdevice.h clearly explains the purpose of =
this
> field.
>=20
> wanted_features is supposed to be limited by hw_features (so that it'=
s always
> true that (hw_features & wanted_features) =3D=3D wanted_features). If=
 you have
> an idea how to make that more clear, I'd be happy to update descripti=
ons.

Then the computation of 'changed' in __ethtool_set_flags() is wrong:

	/* allow changing only bits set in hw_features */
	changed =3D (data ^ dev->wanted_features) & flags_dup_features;
	if (changed & ~dev->hw_features)
		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;

You need to add something like:

	/* Features that are requested to be on, are already on, and cannot
	 * be changed, have not changed.
	 */
	changes &=3D ~(data & dev->features & ~dev->hw_features);

It seems like there ought to be a way to simplify that, though!

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

