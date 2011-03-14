From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v4] xen network backend driver
Date: Mon, 14 Mar 2011 13:43:44 +0000
Message-ID: <1300110224.17339.2130.camel@zakaz.uk.xensource.com>
References: <1299776554.17339.824.camel@zakaz.uk.xensource.com>
	 <AANLkTinHyFLRkeb60x4Q6uUw6p43XBjk5rpqCMo49WKF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:13426 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756458Ab1CNNnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 09:43:46 -0400
In-Reply-To: <AANLkTinHyFLRkeb60x4Q6uUw6p43XBjk5rpqCMo49WKF@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 17:33 +0000, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/3/10 Ian Campbell <Ian.Campbell@citrix.com>:
> > The following patch is the fourth iteration of the Xen network back=
end
> > driver for upstream Linux.
> >
> > This driver ("netback") is the host side counterpart to the fronten=
d
> > driver in drivers/net/xen-netfront.c. The PV protocol is also
> > implemented by frontend drivers in other OSes too, such as the BSDs=
 and
> > even Windows.
> [...]
> > --- /dev/null
> > +++ b/drivers/net/xen-netback/common.h
> > @@ -0,0 +1,162 @@
> [...]
> > +struct xenvif {
> [...]
> > +       /* Flags that must not be set in dev->features */
> > +       int features_disabled;
> > +
> > +       /* Frontend feature information. */
> > +       u8 can_sg:1;
> > +       u8 gso:1;
> > +       u8 gso_prefix:1;
> > +       u8 csum:1;
> [...]
> > --- /dev/null
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -0,0 +1,424 @@
> [...]
> > +static int xenvif_change_mtu(struct net_device *dev, int mtu)
> > +{
> > +       struct xenvif *vif =3D netdev_priv(dev);
> > +       int max =3D vif->can_sg ? 65535 - VLAN_ETH_HLEN : ETH_DATA_=
LEN;
> > +
> > +       if (mtu > max)
> > +               return -EINVAL;
> > +       dev->mtu =3D mtu;
> > +       return 0;
> > +}
> > +
> > +static void xenvif_set_features(struct xenvif *vif)
> > +{
> > +       struct net_device *dev =3D vif->dev;
> > +       int features =3D dev->features;
> > +
> > +       if (vif->can_sg)
> > +               features |=3D NETIF_F_SG;
> > +       if (vif->gso || vif->gso_prefix)
> > +               features |=3D NETIF_F_TSO;
> > +       if (vif->csum)
> > +               features |=3D NETIF_F_IP_CSUM;
> > +
> > +       features &=3D ~(vif->features_disabled);
> > +
> > +       if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN)
> > +               dev->mtu =3D ETH_DATA_LEN;
> > +
> > +       dev->features =3D features;
> > +}
> > +
> > +static int xenvif_set_tx_csum(struct net_device *dev, u32 data)
> > +{
> > +       struct xenvif *vif =3D netdev_priv(dev);
> > +       if (data) {
> > +               if (!vif->csum)
> > +                       return -EOPNOTSUPP;
> > +               vif->features_disabled &=3D ~NETIF_F_IP_CSUM;
> > +       } else {
> > +               vif->features_disabled |=3D NETIF_F_IP_CSUM;
> > +       }
> > +
> > +       xenvif_set_features(vif);
> > +       return 0;
> > +}
> > +
> > +static int xenvif_set_sg(struct net_device *dev, u32 data)
> > +{
> > +       struct xenvif *vif =3D netdev_priv(dev);
> > +       if (data) {
> > +               if (!vif->can_sg)
> > +                       return -EOPNOTSUPP;
> > +               vif->features_disabled &=3D ~NETIF_F_SG;
> > +       } else {
> > +               vif->features_disabled |=3D NETIF_F_SG;
> > +       }
> > +
> > +       xenvif_set_features(vif);
> > +       return 0;
> > +}
> > +
> > +static int xenvif_set_tso(struct net_device *dev, u32 data)
> > +{
> > +       struct xenvif *vif =3D netdev_priv(dev);
> > +       if (data) {
> > +               if (!vif->gso && !vif->gso_prefix)
> > +                       return -EOPNOTSUPP;
> > +               vif->features_disabled &=3D ~NETIF_F_TSO;
> > +       } else {
> > +               vif->features_disabled |=3D NETIF_F_TSO;
> > +       }
> > +
> > +       xenvif_set_features(vif);
> > +       return 0;
> > +}
> [...]
>=20
> You could make this simpler by using netdev->hw_features and
> ndo_fix_features/ndo_set_features calls recently introduced in
> net-next.

Thanks, this does look like it could simplify things. Doesn't look like
its use is widespread (even net-next) yet though?

I'll add it to my TODO list for the future.

>  I'll reply with a proof-of-concept patch for xen-netfront.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw


