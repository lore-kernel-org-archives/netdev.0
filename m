From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH] [RFC] vlan: fix updating wanted_features for vlan device
Date: Thu, 5 May 2011 00:49:11 -0700
Message-ID: <7C88852EF6F99F4EB538472FCFEBE222018E6B2599@orsmsx509.amr.corp.intel.com>
References: <20110505004841.26691.74872.stgit@localhost6.localdomain6>
 <20110505065153.GA3288@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26849 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633Ab1EEHtM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 03:49:12 -0400
In-Reply-To: <20110505065153.GA3288@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>=20
> On Wed, May 04, 2011 at 05:48:42PM -0700, Yi Zou wrote:
> > commit 8a0427b "vlan: convert VLAN devices to use ndo_fix_features(=
)"
> converts the
> > vlan to support ndo_fix_features. However, the wanted_features is n=
ot
> updated
> > for the vlan device, causing real_dev->features not be populated to=
 the
> vlan
> > device when real_dev->features are changed by the driver through
> FEAT_CHANGE.
> > This is breaking FCoE related netdev feature flags on vlan devices.=
 Add
> updating
> > wanted_features to vlan_transfer_features() so
> netdev_get_wanted_features() will
> > can get the updated wanted feature flags for vlan device properly.
>=20
> Can you describe the situation further? There might be problems if de=
vice
> changes its vlan_features after creation of VLAN devices on top
> (bonding?).

Not sure for bonding, I noticed this when creating FCoE instance on a v=
lan
Device on top of an Intel 82599 device. The real_dev is created with=20
vlan_features set of related FCoE flags, e.g., NETIF_F_FCOE_MTU, NETIF_=
=46_FCOE_CRC,
etc. However, the real_dev's features are not set w/ these FCoE flags t=
ill=20
the FCoE protocol stack starts using FCoE when ndo_fcoe_enable() is cal=
led,=20
where in the case of 82599's case, these flags are toggled on in netdev=
's=20
features, and netdev_features_change() is called to populate to the upp=
er=20
vlan device since previously we do:

       vlandev->features &=3D ~dev->vlan_features;
       vlandev->features |=3D dev->features & dev->vlan_features;=20

in vlan_transfer_features(). FCoE only checks the corresponding netdev =
features
(vlan or real_dev) passed in from user space as a interface name e.g., =
eth2.100,
to tell if, for example, FCOE_MTU is supported. Particularly for this c=
ase, there
is no change on vlan_features.=20

>=20
> dev->wanted_features is only what user wants to get and should not be
> changed
> by anything else.
Hmm...so my usage for that seems to be wrong if that's what wanted_feat=
ures is
meant to be. Well, wanted_features in vlan is features & hw_features, i=
f it stays,
then, it seems to me will never get changes from real_dev's features si=
nce=20
netdev_get_wanted_features() won't get it to begin w/.

Also, note my RFC isn't complete either, as it only sets not clears pre=
viously
flags in wanted_features.

Thanks,
yi
>=20
> Best Regards,
> Micha=B3 Miros=B3aw
