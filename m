From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2] net: bnx2x: convert to hw_features
Date: Mon, 11 Apr 2011 22:12:25 +0200
Message-ID: <20110411201225.GA9249@rere.qmqm.pl>
References: <20110410152336.GA14182@rere.qmqm.pl> <20110410144746.679DD13A65@rere.qmqm.pl> <1302448214.2242.6.camel@lb-tlvb-vladz> <20110410153506.86FA613909@rere.qmqm.pl> <1302531021.21065.79.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59603 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755846Ab1DKUM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 16:12:28 -0400
Content-Disposition: inline
In-Reply-To: <1302531021.21065.79.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The v3 patch fixes missing LRO flag and ensures that netdev_update_feat=
ures()
won't be called after failed bnx2x_nic_load(). More comments below.

On Mon, Apr 11, 2011 at 05:10:21PM +0300, Vladislav Zolotarov wrote:
> On Sun, 2011-04-10 at 08:35 -0700, Micha=B3 Miros=B3aw wrote:
> > Since ndo_fix_features callback is postponing features change when
> > bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_features=
()
> > has to be called again when this condition changes.
> Unfortunately, NACK again. See below, pls.
[...]
> > diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2=
x_cmn.c
> > index e83ac6d..9691b67 100644
> > --- a/drivers/net/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> > @@ -2443,11 +2443,21 @@ alloc_err:
> > =20
> >  }
> > =20
> > +static int bnx2x_reload_if_running(struct net_device *dev)
> > +{
> > +	struct bnx2x *bp =3D netdev_priv(dev);
> > +
> > +	if (unlikely(!netif_running(dev)))
> > +		return 0;
> > +
> > +	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> > +	return bnx2x_nic_load(bp, LOAD_NORMAL);
> > +}
> > +
> >  /* called with rtnl_lock */
> >  int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
> >  {
[...]
> > +u32 bnx2x_fix_features(struct net_device *dev, u32 features)
> > +{
> > +	struct bnx2x *bp =3D netdev_priv(dev);
> > +
> > +	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
> > +		netdev_err(dev, "Handling parity error recovery. Try again later=
\n");
> > +
> > +		/* Don't allow bnx2x_set_features() to be called now. */
> > +		return dev->features;
> > +	}
> > +
> > +	/* TPA requires Rx CSUM offloading */
> > +	if (!(features & NETIF_F_RXCSUM) || bp->disable_tpa)
> > +		features &=3D ~NETIF_F_LRO;
> Shouldn't it be (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM) and not
> NETIF_F_RXCSUM?
[...]
> In addition this function should ensure NETIF_F_IP_CSUM and
> NETIF_F_IPV6_CSUM are changed together.
[...]
> > +int bnx2x_set_features(struct net_device *dev, u32 features)
[...]
> Since there is no set_rx_csum() anymore the above function has to han=
dle
> bp->rx_csum namely correlate it with (NETIF_F_IP_CSUM |
> NETIF_F_IPV6_CSUM) bits in the 'features'.=20

You seem to confuse TX checksum offloads (IP_CSUM,IPV6_CSUM) with
RX checksum offload (RXCSUM).

The driver doesn't touch hardware state on changes to checksum offloads
so they are independent - there's no point in adding artificial
dependencies here.

[...]
> > diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx=
2x_main.c
> > index f3cf889..ffa0611 100644
> > --- a/drivers/net/bnx2x/bnx2x_main.c
> > +++ b/drivers/net/bnx2x/bnx2x_main.c
> > @@ -7661,6 +7661,7 @@ exit_leader_reset:
> >  	bp->is_leader =3D 0;
> >  	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
> >  	smp_wmb();
> > +	netdev_update_features(bp->dev);
> >  	return rc;
> >  }
>=20
> Before I continue I'd like to clarify one thing: there is no sense to
> call for netdev_update_features() if bnx2x_nic_load(), called right
> before it, has failed as long as the following bnx2x_nic_load() that
> will be called from the netdev_update_features() flow will also fail
> (for the same reasons as the previous one). If bnx2x_nic_load() fails
> for the certain NIC we actually shut this NIC down. So, the following
> remarks will be based on the above statement.

In all those cases, bnx2x_reload_if_running() will be called only when
LRO state is changed while there's a recovery in progress.

[...]
> U shouldn't call for netdev_update_features(bp->dev) if bnx2x_nic_loa=
d()
> has failed. It would also be nice if netdev_update_features() would
> propagate the exit status of ndo_set_features() when ndo_set_features=
()
> fails in the __netdev_update_features().

That's fixed in v3.

> See the patch for the bnx2x below:
>=20
> @@ -8993,7 +8995,14 @@ static int bnx2x_open(struct net_device *dev)
> =20
>         bp->recovery_state =3D BNX2X_RECOVERY_DONE;
> =20
> -       return bnx2x_nic_load(bp, LOAD_OPEN);
> +       rc =3D bnx2x_nic_load(bp, LOAD_OPEN);
> +       if (!rc)
> +               netdev_update_features(bp->dev);
> +
> +       if (bp->state =3D=3D BNX2X_STATE_OPEN)
> +               return 0;
> +       else
> +               return -EBUSY;
>  }

Hmm. I missed this part in the v3 patch. This clobbers bnx2x_nic_load()=
's
error return, though.

> >  /* called with rtnl_lock */
> > @@ -9304,6 +9309,8 @@ static const struct net_device_ops bnx2x_netd=
ev_ops =3D {
> >  	.ndo_validate_addr	=3D eth_validate_addr,
> >  	.ndo_do_ioctl		=3D bnx2x_ioctl,
> >  	.ndo_change_mtu		=3D bnx2x_change_mtu,
> > +	.ndo_fix_features	=3D bnx2x_fix_features,
> > +	.ndo_set_features	=3D bnx2x_set_features,
> >  	.ndo_tx_timeout		=3D bnx2x_tx_timeout,
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  	.ndo_poll_controller	=3D poll_bnx2x,
> > @@ -9430,20 +9437,18 @@ static int __devinit bnx2x_init_dev(struct =
pci_dev *pdev,
> > =20
> >  	dev->netdev_ops =3D &bnx2x_netdev_ops;
> >  	bnx2x_set_ethtool_ops(dev);
> > -	dev->features |=3D NETIF_F_SG;
> > -	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> > +
> >  	if (bp->flags & USING_DAC_FLAG)
> >  		dev->features |=3D NETIF_F_HIGHDMA;
> > -	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> > -	dev->features |=3D NETIF_F_TSO6;
> > -	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
> > =20
> > -	dev->vlan_features |=3D NETIF_F_SG;
> > -	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> > -	if (bp->flags & USING_DAC_FLAG)
> > -		dev->vlan_features |=3D NETIF_F_HIGHDMA;
> > -	dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> > -	dev->vlan_features |=3D NETIF_F_TSO6;
> > +	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_=
CSUM |
> > +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> > +		NETIF_F_HW_VLAN_TX;
> hw_features are missing NETIF_F_GRO and NETIF_F_LRO flags that are
> currently configured in bnx2x_init_bp().=20

GRO is enabled by core now. LRO is fixed in v3.

> > +	dev->features |=3D dev->hw_features | NETIF_F_HW_VLAN_RX;
> > +
> > +	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV=
6_CSUM |
> > +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
> I'm not sure if it's safe to set NETIF_F_HIGHDMA unconditionally. I
> think it's better to correlate it with the USING_DAC_FLAG which is se=
t
> according to what is returned by=20
> dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)).

dev->vlan_features get masked with dev->features and only then applied
to VLAN device.

Best Regards,
Micha=B3 Miros=B3aw
