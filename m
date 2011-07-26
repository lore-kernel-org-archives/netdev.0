From: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Subject: Re: [net-next 10/10] ixgbe: convert to ndo_fix_features
Date: Tue, 26 Jul 2011 19:34:19 +0200
Message-ID: <20110726173419.GA21903@rere.qmqm.pl>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1311314951-11142-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110722080255.GA10125@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34506137894@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37697 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377Ab1GZReV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 13:34:21 -0400
Content-Disposition: inline
In-Reply-To: <C0716E470783B24A8178C9E38CD2F34506137894@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 03:42:09PM -0700, Skidmore, Donald C wrote:
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g]
>On Behalf Of Michal Miroslaw
> >On Thu, Jul 21, 2011 at 11:09:11PM -0700, Jeff Kirsher wrote:
> >> From: Don Skidmore <donald.c.skidmore@intel.com>
> >>
> >> Private rx_csum flags are now duplicate of netdev->features &
> >> NETIF_F_RXCSUM.  We remove those duplicates and now use the
> >net_device_ops
> >> ndo_set_features.  This was based on the original patch submitted =
by
> >> Michal Miroslaw <mirq-linux@rere.qmqm.pl>.  I also removed the spe=
cial
> >> case not requiring a reset for X540 hardware.  It is needed just a=
s it
> >is
> >> in 82599 hardware.
> >
> >Looks mostly good now. Minor hints below.
> >
> >[...]
> >> +static u32 ixgbe_fix_features(struct net_device *netdev, u32 data=
)
> >> +{
> >[...]
> >> +	/* Turn off LRO if not RSC capable or invalid ITR settings */
> >> +	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)) {
> >> +		data &=3D ~NETIF_F_LRO;
> >> +	} else if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
> >> +		   (adapter->rx_itr_setting !=3D 1 &&
> >> +		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE)) {
> >> +		data &=3D ~NETIF_F_LRO;
> >> +		e_info(probe, "rx-usecs set too low, not enabling RSC\n");
> >> +	}
> >
> >Better:
> >
> >... else if (data & NETIF_F_LRO && adapter->rx_itr_setting !=3D 1 &&
> >adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
> >	e_info(...)
> >	data &=3D ~NETIF_F_LRO;
> >}
> >
>=20
> I see your point here, the added complexity (checking IXGBE_FLAG2_RSC=
_ENABLED) is there to cover cases that come up in our out of tree drive=
r's kcompat code.  This is why we mirror these feature flags to begin w=
ith.  I would like to modify the driver to use only the feature flags b=
ut that will require some interesting kcompat code as well as touch lar=
ge parts of the driver so I was thinking would probably be best as anot=
her patch. =20
>=20
> My concern in this conditional is when RSC is not just possible but a=
ctually turned on.  Currently the NETIF_F_LRO flag is enabled in probe =
if we are RSC capable.  But it is possible to be RSC capable but not ha=
ve it enabled due to setting interrupts throttling rates too high.

You should base decisions in ndo_fix_features on what will be enabled i=
n
following ndo_set_features call, not what is enabled at the time of
ndo_fix_features, unless the dependency is not controlled in ndo_set_fe=
atures
(e.g. MTU).

Best Regards,
Micha=B3 Miros=B3aw
