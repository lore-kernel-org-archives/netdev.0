From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Thu, 10 Mar 2011 18:33:05 +0100
Message-ID: <AANLkTinHyFLRkeb60x4Q6uUw6p43XBjk5rpqCMo49WKF@mail.gmail.com>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:43187 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab1CJRdG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 12:33:06 -0500
Received: by qwd7 with SMTP id 7so1414107qwd.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 09:33:05 -0800 (PST)
In-Reply-To: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/10 Ian Campbell <Ian.Campbell@citrix.com>:
> The following patch is the fourth iteration of the Xen network backen=
d
> driver for upstream Linux.
>
> This driver ("netback") is the host side counterpart to the frontend
> driver in drivers/net/xen-netfront.c. The PV protocol is also
> implemented by frontend drivers in other OSes too, such as the BSDs a=
nd
> even Windows.
[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/common.h
> @@ -0,0 +1,162 @@
[...]
> +struct xenvif {
[...]
> + =A0 =A0 =A0 /* Flags that must not be set in dev->features */
> + =A0 =A0 =A0 int features_disabled;
> +
> + =A0 =A0 =A0 /* Frontend feature information. */
> + =A0 =A0 =A0 u8 can_sg:1;
> + =A0 =A0 =A0 u8 gso:1;
> + =A0 =A0 =A0 u8 gso_prefix:1;
> + =A0 =A0 =A0 u8 csum:1;
[...]
> --- /dev/null
> +++ b/drivers/net/xen-netback/interface.c
> @@ -0,0 +1,424 @@
[...]
> +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> +{
> + =A0 =A0 =A0 struct xenvif *vif =3D netdev_priv(dev);
> + =A0 =A0 =A0 int max =3D vif->can_sg ? 65535 - VLAN_ETH_HLEN : ETH_D=
ATA_LEN;
> +
> + =A0 =A0 =A0 if (mtu > max)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 dev->mtu =3D mtu;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void xenvif_set_features(struct xenvif *vif)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D vif->dev;
> + =A0 =A0 =A0 int features =3D dev->features;
> +
> + =A0 =A0 =A0 if (vif->can_sg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_SG;
> + =A0 =A0 =A0 if (vif->gso || vif->gso_prefix)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_TSO;
> + =A0 =A0 =A0 if (vif->csum)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 features |=3D NETIF_F_IP_CSUM;
> +
> + =A0 =A0 =A0 features &=3D ~(vif->features_disabled);
> +
> + =A0 =A0 =A0 if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->mtu =3D ETH_DATA_LEN;
> +
> + =A0 =A0 =A0 dev->features =3D features;
> +}
> +
> +static int xenvif_set_tx_csum(struct net_device *dev, u32 data)
> +{
> + =A0 =A0 =A0 struct xenvif *vif =3D netdev_priv(dev);
> + =A0 =A0 =A0 if (data) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vif->csum)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled &=3D ~NETIF_F_IP=
_CSUM;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled |=3D NETIF_F_IP_=
CSUM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 xenvif_set_features(vif);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int xenvif_set_sg(struct net_device *dev, u32 data)
> +{
> + =A0 =A0 =A0 struct xenvif *vif =3D netdev_priv(dev);
> + =A0 =A0 =A0 if (data) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vif->can_sg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled &=3D ~NETIF_F_SG=
;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled |=3D NETIF_F_SG;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 xenvif_set_features(vif);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int xenvif_set_tso(struct net_device *dev, u32 data)
> +{
> + =A0 =A0 =A0 struct xenvif *vif =3D netdev_priv(dev);
> + =A0 =A0 =A0 if (data) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vif->gso && !vif->gso_prefix)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled &=3D ~NETIF_F_TS=
O;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif->features_disabled |=3D NETIF_F_TSO=
;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 xenvif_set_features(vif);
> + =A0 =A0 =A0 return 0;
> +}
[...]

You could make this simpler by using netdev->hw_features and
ndo_fix_features/ndo_set_features calls recently introduced in
net-next. I'll reply with a proof-of-concept patch for xen-netfront.

Best Regards,
Micha=B3 Miros=B3aw
