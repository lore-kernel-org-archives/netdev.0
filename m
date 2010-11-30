From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 15:51:58 +0000
Message-ID: <1291132318.21077.30.camel@bwh-desktop>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl>
	 <1291130005.21077.18.camel@bwh-desktop>
	 <20101130152838.GA26281@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: =?UTF-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55735 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab0K3PwB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 10:52:01 -0500
In-Reply-To: <20101130152838.GA26281@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 16:28 +0100, Micha=C5=82Miros=C5=82aw wrote:
[...]
> > > -/**
> > >   * pch_gbe_set_tx_csum - Turn transmit checksums on or off
> > >   * @netdev: Network interface device structure
> > >   * @data:   Checksum on[true] or off[false]
> > > @@ -493,11 +481,7 @@ static int pch_gbe_set_tx_csum(struct net_de=
vice *netdev, u32 data)
> > >  	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
> > > =20
> > >  	adapter->tx_csum =3D data;
> > > -	if (data)
> > > -		netdev->features |=3D NETIF_F_HW_CSUM;
> > > -	else
> > > -		netdev->features &=3D ~NETIF_F_HW_CSUM;
> > > -	return 0;
> > > +	return ethtool_op_set_tx_ipv6_csum(netdev, data);
> > >  }
> > > =20
> > >  /**
> > > @@ -572,7 +556,6 @@ static const struct ethtool_ops pch_gbe_ethto=
ol_ops =3D {
> > >  	.set_pauseparam =3D pch_gbe_set_pauseparam,
> > >  	.get_rx_csum =3D pch_gbe_get_rx_csum,
> > >  	.set_rx_csum =3D pch_gbe_set_rx_csum,
> > > -	.get_tx_csum =3D pch_gbe_get_tx_csum,
> > >  	.set_tx_csum =3D pch_gbe_set_tx_csum,
> > >  	.get_strings =3D pch_gbe_get_strings,
> > >  	.get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
> >=20
> > pch_gbe_get_tx_csum can simply be replaced with
> > ethtool_op_set_tx_ipv6_csum.
>=20
> pch_gbe_set_tx_csum() also changes adapter->tx_csum, which I didn't w=
ant
> to touch in this patch. (I'm assuming you mean ...set_tx_csum not ...=
get_tx_csum).

Sorry, I missed that.

[...]
> > Why are you disabling IPv6 checksum offload?  From a quick look at =
the
> > driver, I think the hardware does support it.
>=20
> In vxge_xmit() (at drivers/net/vxge/vxge-main.c:922 in net-next) ther=
e
> is the following code, that suggested otherwise:
>=20
>         if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
>                 vxge_hw_fifo_txdl_cksum_set_bits(dtr,
>                                         VXGE_HW_FIFO_TXD_TX_CKO_IPV4_=
EN |
>                                         VXGE_HW_FIFO_TXD_TX_CKO_TCP_E=
N |
>                                         VXGE_HW_FIFO_TXD_TX_CKO_UDP_E=
N);

I bet IPV4_EN refers to the IPv4 header checksum.  Since IPv6 doesn't
have a header checksum, there won't be a flag for it here.

> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 3259d2c..622f85a 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -5041,10 +5041,13 @@ unsigned long netdev_fix_features(unsigne=
d long features, const char *name)
> > >  	}
> > > =20
> > >  	if (features & NETIF_F_UFO) {
> > > -		if (!(features & NETIF_F_GEN_CSUM)) {
> > > +		/* maybe split UFO into V4 and V6? */
> > > +		if (!((features & NETIF_F_GEN_CSUM) ||
> > > +		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> > > +			    =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
> > >  			if (name)
> > >  				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
> > > -				       "since no NETIF_F_HW_CSUM feature.\n",
> > > +				       "since no checksum offload features.\n",
> > >  				       name);
> > >  			features &=3D ~NETIF_F_UFO;
> > >  		}
> > > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > > index 956a9f4..d5bc2881 100644
> > > --- a/net/core/ethtool.c
> > > +++ b/net/core/ethtool.c
> > > @@ -1171,7 +1171,9 @@ static int ethtool_set_ufo(struct net_devic=
e *dev, char __user *useraddr)
> > >  		return -EFAULT;
> > >  	if (edata.data && !(dev->features & NETIF_F_SG))
> > >  		return -EINVAL;
> > > -	if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
> > > +	if (edata.data && !((dev->features & NETIF_F_GEN_CSUM) ||
> > > +		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> > > +			=3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
> > >  		return -EINVAL;
> > >  	return dev->ethtool_ops->set_ufo(dev, edata.data);
> > >  }
> > I believe UFO is for IPv4 only; IPv6 has an entirely different kind=
 of
> > fragmentation.  So I think the check should be dev->features &
> > NETIF_F_V4_CSUM.
>=20
> net/ipv6/ip6_output.c references NETIF_F_UFO without checking
> IPv6 checksumming features.

Got it.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

