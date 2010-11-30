From: =?iso-8859-2?Q?Micha=B3Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 16:28:38 +0100
Message-ID: <20101130152838.GA26281@rere.qmqm.pl>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl> <1291130005.21077.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42241 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202Ab0K3P2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 10:28:40 -0500
Content-Disposition: inline
In-Reply-To: <1291130005.21077.18.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 03:13:25PM +0000, Ben Hutchings wrote:
> On Tue, 2010-11-30 at 15:23 +0100, Micha=B3Miros=B3aw wrote:
> > NETIF_F_HW_CSUM is superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM, b=
ut
> > some drivers miss the difference. Fix this and also fix UFO depende=
ncy
> > on checksumming offload as it makes the same mistake in assumptions=
=2E
> [...]
> > diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx=
2x_main.c
> > index f53edfd..40ce95a 100644
> > --- a/drivers/net/bnx2x/bnx2x_main.c
> > +++ b/drivers/net/bnx2x/bnx2x_main.c
> > @@ -8761,7 +8761,7 @@ static int __devinit bnx2x_init_dev(struct pc=
i_dev *pdev,
> >  	dev->netdev_ops =3D &bnx2x_netdev_ops;
> >  	bnx2x_set_ethtool_ops(dev);
> >  	dev->features |=3D NETIF_F_SG;
> > -	dev->features |=3D NETIF_F_HW_CSUM;
> > +	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> >  	if (bp->flags & USING_DAC_FLAG)
> >  		dev->features |=3D NETIF_F_HIGHDMA;
> >  	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> > @@ -8769,7 +8769,7 @@ static int __devinit bnx2x_init_dev(struct pc=
i_dev *pdev,
> >  	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
> > =20
> >  	dev->vlan_features |=3D NETIF_F_SG;
> > -	dev->vlan_features |=3D NETIF_F_HW_CSUM;
> > +	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> >  	if (bp->flags & USING_DAC_FLAG)
> >  		dev->vlan_features |=3D NETIF_F_HIGHDMA;
> >  	dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> > diff --git a/drivers/net/jme.c b/drivers/net/jme.c
> > index c57d9a4..ad0935c 100644
> > --- a/drivers/net/jme.c
> > +++ b/drivers/net/jme.c
> > @@ -2076,12 +2076,11 @@ jme_change_mtu(struct net_device *netdev, i=
nt new_mtu)
> >  	}
> > =20
> >  	if (new_mtu > 1900) {
> > -		netdev->features &=3D ~(NETIF_F_HW_CSUM |
> > -				NETIF_F_TSO |
> > -				NETIF_F_TSO6);
> > +		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM |
> > +				NETIF_F_TSO | NETIF_F_TSO6);
> >  	} else {
> >  		if (test_bit(JME_FLAG_TXCSUM, &jme->flags))
> > -			netdev->features |=3D NETIF_F_HW_CSUM;
> > +			netdev->features |=3D NETIF_F_IP_CSUM | NETIFI_F_IPV6_CSUM;
>=20
> In this file you've written 'NETIFI_F_IPV6_CSUM' several times.  Do t=
ry
> compiling your work. :-)

Sorry for that. I compile tested whole series, where another patch I'm =
working on
just removes this part.

> [...]
> > diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pc=
h_gbe/pch_gbe_ethtool.c
> > index c8cc32c..c8c873b 100644
> > --- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
> > +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> > @@ -469,18 +469,6 @@ static int pch_gbe_set_rx_csum(struct net_devi=
ce *netdev, u32 data)
> >  }
> > =20
> >  /**
> > - * pch_gbe_get_tx_csum - Report whether transmit checksums are tur=
ned on or off
> > - * @netdev:  Network interface device structure
> > - * Returns
> > - *	true(1):  Checksum On
> > - *	false(0): Checksum Off
> > - */
> > -static u32 pch_gbe_get_tx_csum(struct net_device *netdev)
> > -{
> > -	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
> > -}
> > -
> > -/**
> >   * pch_gbe_set_tx_csum - Turn transmit checksums on or off
> >   * @netdev: Network interface device structure
> >   * @data:   Checksum on[true] or off[false]
> > @@ -493,11 +481,7 @@ static int pch_gbe_set_tx_csum(struct net_devi=
ce *netdev, u32 data)
> >  	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
> > =20
> >  	adapter->tx_csum =3D data;
> > -	if (data)
> > -		netdev->features |=3D NETIF_F_HW_CSUM;
> > -	else
> > -		netdev->features &=3D ~NETIF_F_HW_CSUM;
> > -	return 0;
> > +	return ethtool_op_set_tx_ipv6_csum(netdev, data);
> >  }
> > =20
> >  /**
> > @@ -572,7 +556,6 @@ static const struct ethtool_ops pch_gbe_ethtool=
_ops =3D {
> >  	.set_pauseparam =3D pch_gbe_set_pauseparam,
> >  	.get_rx_csum =3D pch_gbe_get_rx_csum,
> >  	.set_rx_csum =3D pch_gbe_set_rx_csum,
> > -	.get_tx_csum =3D pch_gbe_get_tx_csum,
> >  	.set_tx_csum =3D pch_gbe_set_tx_csum,
> >  	.get_strings =3D pch_gbe_get_strings,
> >  	.get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
>=20
> pch_gbe_get_tx_csum can simply be replaced with
> ethtool_op_set_tx_ipv6_csum.

pch_gbe_set_tx_csum() also changes adapter->tx_csum, which I didn't wan=
t
to touch in this patch. (I'm assuming you mean ...set_tx_csum not ...ge=
t_tx_csum).

> [...]
> > diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxg=
e-ethtool.c
> > index bc9bd10..5ece50d 100644
> > --- a/drivers/net/vxge/vxge-ethtool.c
> > +++ b/drivers/net/vxge/vxge-ethtool.c
> > @@ -1177,7 +1177,7 @@ static const struct ethtool_ops vxge_ethtool_=
ops =3D {
> >  	.get_rx_csum		=3D vxge_get_rx_csum,
> >  	.set_rx_csum		=3D vxge_set_rx_csum,
> >  	.get_tx_csum		=3D ethtool_op_get_tx_csum,
> > -	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
> > +	.set_tx_csum		=3D ethtool_op_set_tx_csum,
> >  	.get_sg			=3D ethtool_op_get_sg,
> >  	.set_sg			=3D ethtool_op_set_sg,
> >  	.get_tso		=3D ethtool_op_get_tso,
> > diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-m=
ain.c
> > index a21dae1..9f6d379 100644
> > --- a/drivers/net/vxge/vxge-main.c
> > +++ b/drivers/net/vxge/vxge-main.c
> > @@ -3368,7 +3368,7 @@ static int __devinit vxge_device_register(str=
uct __vxge_hw_device *hldev,
> > =20
> >  	ndev->features |=3D NETIF_F_SG;
> > =20
> > -	ndev->features |=3D NETIF_F_HW_CSUM;
> > +	ndev->features |=3D NETIF_F_IP_CSUM;
> >  	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
> >  		"%s : checksuming enabled", __func__);
> > =20
> Why are you disabling IPv6 checksum offload?  From a quick look at th=
e
> driver, I think the hardware does support it.

In vxge_xmit() (at drivers/net/vxge/vxge-main.c:922 in net-next) there
is the following code, that suggested otherwise:

        if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
                vxge_hw_fifo_txdl_cksum_set_bits(dtr,
                                        VXGE_HW_FIFO_TXD_TX_CKO_IPV4_EN=
 |
                                        VXGE_HW_FIFO_TXD_TX_CKO_TCP_EN =
|
                                        VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN)=
;

> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 3259d2c..622f85a 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5041,10 +5041,13 @@ unsigned long netdev_fix_features(unsigned =
long features, const char *name)
> >  	}
> > =20
> >  	if (features & NETIF_F_UFO) {
> > -		if (!(features & NETIF_F_GEN_CSUM)) {
> > +		/* maybe split UFO into V4 and V6? */
> > +		if (!((features & NETIF_F_GEN_CSUM) ||
> > +		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> > +			    =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
> >  			if (name)
> >  				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
> > -				       "since no NETIF_F_HW_CSUM feature.\n",
> > +				       "since no checksum offload features.\n",
> >  				       name);
> >  			features &=3D ~NETIF_F_UFO;
> >  		}
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 956a9f4..d5bc2881 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -1171,7 +1171,9 @@ static int ethtool_set_ufo(struct net_device =
*dev, char __user *useraddr)
> >  		return -EFAULT;
> >  	if (edata.data && !(dev->features & NETIF_F_SG))
> >  		return -EINVAL;
> > -	if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
> > +	if (edata.data && !((dev->features & NETIF_F_GEN_CSUM) ||
> > +		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
> > +			=3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
> >  		return -EINVAL;
> >  	return dev->ethtool_ops->set_ufo(dev, edata.data);
> >  }
> I believe UFO is for IPv4 only; IPv6 has an entirely different kind o=
f
> fragmentation.  So I think the check should be dev->features &
> NETIF_F_V4_CSUM.

net/ipv6/ip6_output.c references NETIF_F_UFO without checking
IPv6 checksumming features.

Best Regards,
Micha=B3 Miros=B3aw
