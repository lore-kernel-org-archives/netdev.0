From: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Subject: Re: [net-next 5/5] ixgbe: convert to ndo_fix_features
Date: Tue, 12 Jul 2011 12:09:32 +0200
Message-ID: <20110712100932.GA6433@rere.qmqm.pl>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1310212240-24623-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110709121108.GA7720@rere.qmqm.pl>
 <C0716E470783B24A8178C9E38CD2F34505DF1B3F@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43932 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab1GLKJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 06:09:33 -0400
Content-Disposition: inline
In-Reply-To: <C0716E470783B24A8178C9E38CD2F34505DF1B3F@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 04:53:57PM -0700, Skidmore, Donald C wrote:
> >-----Original Message-----
> >From: Michal Miroslaw [mailto:mirq-linux@rere.qmqm.pl]
> >Sent: Saturday, July 09, 2011 5:11 AM
> >To: Kirsher, Jeffrey T
> >Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
> >gospo@redhat.com
> >Subject: Re: [net-next 5/5] ixgbe: convert to ndo_fix_features
> >
> >On Sat, Jul 09, 2011 at 04:50:40AM -0700, Jeff Kirsher wrote:
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
> >[...]
> >> --- a/drivers/net/ixgbe/ixgbe_main.c
> >> +++ b/drivers/net/ixgbe/ixgbe_main.c
> >> @@ -7188,6 +7188,88 @@ int ixgbe_setup_tc(struct net_device *dev, =
u8
> >tc)
> >[...]
> >> +static int ixgbe_set_features(struct net_device *netdev, u32 data=
)
> >> +{
> >> +	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
> >> +	bool need_reset =3D false;
> >> +
> >> +#ifdef CONFIG_DCB
> >> +	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
> >> +	    !(data &  NETIF_F_HW_VLAN_RX))
> >> +		return -EINVAL;
> >> +#endif
> >> +	/* return error if RXHASH is being enabled when RSS is not
> >supported */
> >> +	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
> >> +	     (data &  NETIF_F_RXHASH))
> >> +		return -EINVAL;
> >> +
> >> +	/* If Rx checksum is disabled, then RSC/LRO should also be
> >disabled */
> >> +	if (!(data & NETIF_F_RXCSUM)) {
> >> +		data &=3D ~NETIF_F_LRO;
> >> +		adapter->flags &=3D ~IXGBE_FLAG_RX_CSUM_ENABLED;
> >> +	} else {
> >> +		adapter->flags |=3D IXGBE_FLAG_RX_CSUM_ENABLED;
> >> +	}
> >
> >The checks above should be done in ndo_fix_features callback. The ch=
eck
> >for
> >RSS_ENABLED for RXHASH is redundant, as the feature is removed in
> >probe()
> >in this case (see [MARK] below).
> Thanks for the comments Michal, it clears up a lot in my mind. :)
>=20
> So in ndo_fix_features we would just turn off feature flags rather th=
an return an error?  For example:
>=20
> 	if (!(data & NETIF_F_RXCSUM))=20
> 		data &=3D ~NETIF_F_LRO;

Exactly.

> As for RSS_ENABLED/RXHASH check it was to cover the cases where RSS_E=
NABLED might have changed since probe.  This could happen with a resume=
 were we don't get enough MSI-X vectors.  There are also paths in FCoE =
and DCB that get into code that could clear IXGBE_FLAG_RSS_ENABLED.

That makes sense now. The checks should be in ndo_fix_features and clea=
r
features whenever they are unavailable.

> >> +
> >> +	/* if state changes we need to update adapter->flags and reset *=
/
> >> +	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
> >> +	    (!!(data & NETIF_F_LRO) !=3D
> >> +	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {

ndo_fix_features() should prevent the change if
!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) is true.

> >> +		if ((data &  NETIF_F_LRO) &&
> >> +		    adapter->rx_itr_setting !=3D 1 &&
> >> +		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
> >> +			e_info(probe, "rx-usecs set too low, "
> >> +			       "not enabling RSC\n");

And should clear NETIF_F_LRO when above condition is met.

> >> +		} else {
> >> +			adapter->flags2 ^=3D IXGBE_FLAG2_RSC_ENABLED;
> >> +			switch (adapter->hw.mac.type) {
> >> +			case ixgbe_mac_X540:
> >> +			case ixgbe_mac_82599EB:
> >> +				need_reset =3D true;
> >> +				break;
> >> +			default:
> >> +				break;
> >> +			}
> >> +		}
> >> +	}
> >> +
> >> +	/*
> >> +	 * Check if Flow Director n-tuple support was enabled or disable=
d.
> >If
> >> +	 * the state changed, we need to reset.
> >> +	 */
> >> +	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
> >> +		/* turn off ATR, enable perfect filters and reset */
> >> +		if (data & NETIF_F_NTUPLE) {
> >> +			adapter->flags &=3D ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
> >> +			adapter->flags |=3D IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
> >> +			need_reset =3D true;
> >> +		}
> >> +	} else if (!(data & NETIF_F_NTUPLE)) {
> >> +		/* turn off Flow Director, set ATR and reset */
> >> +		adapter->flags &=3D ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
> >> +		if ((adapter->flags &  IXGBE_FLAG_RSS_ENABLED) &&
> >> +		    !(adapter->flags &  IXGBE_FLAG_DCB_ENABLED))
> >> +			adapter->flags |=3D IXGBE_FLAG_FDIR_HASH_CAPABLE;
> >> +		need_reset =3D true;
> >> +	}
> >
> >Part of the checks above should be in ndo_fix_features, too.
> >ndo_set_features
> >should just enable what it has been passed. What ndo_fix_features
> >callback
> >returns is further limited by generic checks, and then (if the resul=
ting
> >set
> >is different than current dev->features) ndo_set_features is called.
>=20
> I'm a little confused here.  From your comments I get the idea that n=
do_fix_features() just modifies and error checks our feature set.  The =
result of this would then be just a change to the feature set (data var=
iable in my case above).  Is that a correct assumption?  If so I'm conf=
used as none of the two checks above change the feature set.  They do c=
hange driver flags to indicate the new state and mark whether we need a=
 reset.  I don't believe we would want to do the reset until ndo_set_fe=
ature is called and if we broke up the setting of the driver flags into=
 ndo_fix_features we would lose some state (i.e. if the IXGBE_FLAG2_RSC=
_ENABLED changed) that we need to decide if a reset is needed in ndo_se=
t_features. =20
>=20
> Am I just missing something here?

I see that this changes only driver internal state, so your right in pu=
tting
this in ndo_set_features callback.

Can you draw a map of the relevant bits and what state should result fr=
om
them (a truth table if you will)? I have a hard time understanding the =
idea.
This changes _CAPABLE bits depending on _ENABLED which adds to confusio=
n.

I would expect that:
 _CAPABLE are set whenever a config is possible, disregarding dependenc=
ies
 _ENABLED are set whenever a config is requested and possible
But it looks like what I described is reversed or just wrong.

Best Regards,
Micha=B3 Miros=B3aw
