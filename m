From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: Add documentation for netdev features handling
Date: Tue, 12 Jul 2011 12:19:02 -0700
Message-ID: <20110712121902.2c8b98cf.rdunlap@xenotime.net>
References: <1310487816.2732.13.camel@bwh-desktop>
	<20110712090000.29c17c20@nehalam.ftrdhcpuser.net>
	<f95d92bfa1d8760db6ae0dbff67bb0e85eb77a2d.1310496866.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Donald Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy12-pub.bluehost.com ([67.222.39.55]:60508 "HELO
	oproxy12-pub.bluehost.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1754441Ab1GLTTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 15:19:06 -0400
In-Reply-To: <f95d92bfa1d8760db6ae0dbff67bb0e85eb77a2d.1310496866.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2011 21:01:30 +0200 (CEST) Micha=C5=82 Miros=C5=82aw wro=
te:

> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
> Please comment if something is unclear!
> Apply otherwise. ;)
>=20
> ---
>  Documentation/networking/netdev-features.txt |  155 ++++++++++++++++=
++++++++++
>  1 files changed, 155 insertions(+), 0 deletions(-)
>=20
> diff --git a/Documentation/networking/netdev-features.txt b/Documenta=
tion/networking/netdev-features.txt
> new file mode 100644
> index 0000000..9c209e6
> --- /dev/null
> +++ b/Documentation/networking/netdev-features.txt
> @@ -0,0 +1,155 @@
> +Netdev features mess and how to get out from it alive
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> +
> +Author:
> +	Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> +
> +
> +
> + Part I: Feature sets
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Long gone are days, when a network card would just take and give pac=
kets

   Long gone are the days when

> +verbatim.  Todays devices add multiple features and bugs (read: offl=
oads)

              Today's

> +that relieves OS of various tasks like generating and checking check=
sums,

        relieve an OS

> +splitting packets, classifying them.  Those capabilities and their s=
tate
> +is commonly referred to as netdev features in Linux kernel world.

   are

> +
> +There are currently three sets of features relevant to the driver, a=
nd
> +one used internally by network core:
> +
> + 1. netdev->hw_features set contains features whose state may possib=
ly
> +    be changed (enabled or disabled) for a particular device by user=
's
> +    request.  This set should be initialized in ndo_init callback an=
d not
> +    changed later.
> +
> + 2. netdev->features set contains features which are currently enabl=
ed
> +    for a device.  This should be changed only by network core or in
> +    error paths of ndo_set_features callback.
> +
> + 3. netdev->vlan_features set contains features whose state is inher=
ited
> +    by child VLAN devices (limits netdev->features set).  This is cu=
rrently
> +    used for all VLAN devices whether tags are stripped or inserted =
in
> +    hardware or software.
> +
> + 4. netdev->wanted_features set contains feature set requested by us=
er.
> +    This set is filtered by ndo_fix_features callback whenever it or
> +    some device-specific conditions change. This set is internal to
> +    networking core and should not be referenced in drivers.
> +
> +
> +
> + Part II: Controlling enabled features
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +When current feature set (netdev->features) is to be changed, new se=
t
> +is calculated and filtered by calling ndo_fix_features callback
> +and netdev_fix_features(). If the resulting set differs from current
> +set, it is passed to ndo_set_features callback and (if the callback
> +returns success) replaces value stored in netdev->features.
> +NETDEV_FEAT_CHANGE notification is issued after that whenever curren=
t
> +set might have changed.
> +
> +Following events trigger recalculation:

   The following events ...

> + 1. device's registration, after ndo_init returned success
> + 2. user requested changes in features state
> + 3. netdev_update_features() is called
> +
> +ndo_*_features callbacks are called with rtnl_lock held. Missing cal=
lbacks
> +are treated as always returning success.
> +
> +Driver wanting to trigger recalculation must do so by calling

   A driver that wants to trigger ...

> +netdev_update_features() while holding rtnl_lock. This should not be=
 done
> +from ndo_*_features callbacks. netdev->features should not be modifi=
ed by
> +driver except by means of ndo_fix_features callback.
> +
> +
> +
> + Part III: Implementation hints
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> + * ndo_fix_features:
> +
> +All dependencies between features should be resolved here. The resul=
ting
> +set can be reduced further by networking core imposed limitations (a=
s coded
> +in netdev_fix_features()). For this reason its safer to disable a fe=
ature

                                              it is

> +when its dependencies are not met instead of forcing the dependency =
on.
> +
> +This callback should not modify hardware nor driver state (should be
> +stateless).  It can be called multiple times between successive
> +ndo_set_features calls.
> +
> +Callback must not alter features contained in NETIF_F_SOFT_FEATURES =
or
> +NETIF_F_NEVER_CHANGE sets. The exception is NETIF_F_VLAN_CHALLENGED =
but
> +care must be taken as the change won't affect already configured VLA=
Ns.
> +
> + * ndo_set_features:
> +
> +Hardware should be reconfigured to match passed feature set. The sho=
uld not

                                                                The <wh=
at> should not

> +be altered unless some error condition happens that can't be reliabl=
y
> +detected in ndo_fix_features. In this case, the callback should upda=
te
> +netdev->features to match resulting hardware state. Errors returned =
are
> +not (and cannot be) propagated anywhere except dmesg. (Note: success=
ful
> +return is zero, >0 is silent error.)=20
> +
> +
> +
> + Part IV: Features
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +For current list of features, see include/linux/netdev_features.h.
> +This section describes semantics of some of them.
> +
> + * Transmit checksumming
> +
> +For complete description, see comments near the top of include/linux=
/skbuff.h.
> +
> +Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV=
6_CSUM.
> +It means that device can fill TCP/UDP-like checksum anywhere in the =
packets
> +whatever headers there might be.
> +
> + * Transmit TCP segmentation offload
> +
> +NETIF_F_TSO_ECN means that hardware can properly split packets with =
CWR bit
> +set, be it TCPv4 (when NETIF_F_TSO is enabled) or TCPv6 (NETIF_F_TSO=
6).
> +
> + * Transmit DMA from high memory
> +
> +On platforms where this is relevant, NETIF_F_HIGHDMA signals that
> +ndo_start_xmit can handle skbs with frags in high memory.
> +
> + * Transmit scatter-gather
> +
> +Those features say that ndo_start_xmit can handle fragmented skbs:
> +NETIF_F_SG --- paged skbs (skb_shinfo()->frags), NETIF_F_FRAGLIST --=
-
> +chained skbs (skb->next/prev list).
> +
> + * Software features
> +
> +Features contained in NETIF_F_SOFT_FEATURES are a features of networ=
king

                                                   ^ drop "a"

> +stack. Driver should not change behaviour based on them.
> +
> + * LLTX driver (deprecated for hardware drivers)
> +
> +NETIF_F_LLTX should be set in drivers that implement their own locki=
ng in
> +transmit path or don't need locking at all (e.g. software tunnels).
> +In ndo_start_xmit, it is recommended to use a try_lock and return
> +NETDEV_TX_LOCKED when the spin lock fails.  The locking should also =
properly
> +protect against other callbacks (the rules you need to find out).
> +
> +Don't use it for new drivers.
> +
> + * netns-local device
> +
> +NETIF_F_NETNS_LOCAL is set for devices that are not allowed to move =
between
> +network namespaces (e.g. loopback).
> +
> +Don't use it in drivers.
> +
> + * VLAN challenged
> +
> +NETIF_F_VLAN_CHALLENGED should be set for devices which can't cope w=
ith VLAN
> +headers. Some drivers set this because the cards can't handle the bi=
gger MTU.
> +[FIXME: Those cases could be fixed in VLAN code by allowing only red=
uced-MTU
> +VLANs. This may be not usefull, though.]

                          useful
> +
> --=20


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
