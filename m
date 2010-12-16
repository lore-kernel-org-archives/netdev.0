From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 07/12] vlan: convert VLAN devices to use
 ndo_fix_features()
Date: Thu, 16 Dec 2010 23:36:58 +0000
Message-ID: <1292542618.18294.29.camel@bwh-desktop>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
	 <34dbc2d3d83d82f506f0f073dbf00444885e4f81.1292451560.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38062 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0LPXhB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 18:37:01 -0500
In-Reply-To: <34dbc2d3d83d82f506f0f073dbf00444885e4f81.1292451560.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 23:24 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Note: get_flags was actually broken, because it should return the
> flags capped with vlan_features. This is now done implicitly by
> limiting netdev->hw_features.
>=20
> RX checksumming offload control is (and was) broken, as there was no =
way
> before to say whether it's done for tagged packets.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  net/8021q/vlan.c     |    3 +-
>  net/8021q/vlan_dev.c |   51 ++++++++++++++--------------------------=
---------
>  2 files changed, 16 insertions(+), 38 deletions(-)
>=20
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 6e64f7c..583d47b 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -329,8 +329,7 @@ static void vlan_transfer_features(struct net_dev=
ice *dev,
>  {
>  	unsigned long old_features =3D vlandev->features;
> =20
> -	vlandev->features &=3D ~dev->vlan_features;
> -	vlandev->features |=3D dev->features & dev->vlan_features;
> +	netdev_update_features(vlandev);
>  	vlandev->gso_max_size =3D dev->gso_max_size;
> =20
>  	if (dev->features & NETIF_F_HW_VLAN_TX)
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index be73753..468c899 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -691,8 +691,8 @@ static int vlan_dev_init(struct net_device *dev)
>  					  (1<<__LINK_STATE_DORMANT))) |
>  		      (1<<__LINK_STATE_PRESENT);
> =20
> -	dev->features |=3D real_dev->features & real_dev->vlan_features;
> -	dev->features |=3D NETIF_F_LLTX;
> +	dev->hw_features =3D real_dev->vlan_features;
[...]

net_device::hw_features is supposed to represent features that can be
toggled, but the inclusion of a flag in net_device::vlan_features does
not mean the feature can be toggled.

If this is to be a straight conversion, that line should be:

	dev->hw_features =3D real_dev->vlan_features & NETIF_F_TSO;

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

