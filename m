From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v2] net: bnx2x: convert to hw_features
Date: Mon, 11 Apr 2011 17:10:21 +0300
Message-ID: <1302531021.21065.79.camel@lb-tlvb-vladz>
References: <20110410152336.GA14182@rere.qmqm.pl>
 <20110410144746.679DD13A65@rere.qmqm.pl>
 <1302448214.2242.6.camel@lb-tlvb-vladz>
 <20110410153506.86FA613909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3429 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375Ab1DKOKr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 10:10:47 -0400
In-Reply-To: <20110410153506.86FA613909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-10 at 08:35 -0700, Micha=B3 Miros=B3aw wrote:
> Since ndo_fix_features callback is postponing features change when
> bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_features()
> has to be called again when this condition changes.

Unfortunately, NACK again. See below, pls.

>=20
> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> ---
> [changes from v1: comment in ndo_fix_features callback]
>=20
>  drivers/net/bnx2x/bnx2x_cmn.c     |   52 ++++++++++++++++++--
>  drivers/net/bnx2x/bnx2x_cmn.h     |    3 +
>  drivers/net/bnx2x/bnx2x_ethtool.c |   95 ---------------------------=
----------
>  drivers/net/bnx2x/bnx2x_main.c    |   29 +++++++-----
>  4 files changed, 67 insertions(+), 112 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_=
cmn.c
> index e83ac6d..9691b67 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -2443,11 +2443,21 @@ alloc_err:
> =20
>  }
> =20
> +static int bnx2x_reload_if_running(struct net_device *dev)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +
> +	if (unlikely(!netif_running(dev)))
> +		return 0;
> +
> +	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> +	return bnx2x_nic_load(bp, LOAD_NORMAL);
> +}
> +
>  /* called with rtnl_lock */
>  int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
>  {
>  	struct bnx2x *bp =3D netdev_priv(dev);
> -	int rc =3D 0;
> =20
>  	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
>  		printk(KERN_ERR "Handling parity error recovery. Try again later\n=
");
> @@ -2464,12 +2474,44 @@ int bnx2x_change_mtu(struct net_device *dev, =
int new_mtu)
>  	 */
>  	dev->mtu =3D new_mtu;
> =20
> -	if (netif_running(dev)) {
> -		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> -		rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
> +	return bnx2x_reload_if_running(dev);
> +}
> +
> +u32 bnx2x_fix_features(struct net_device *dev, u32 features)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +
> +	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
> +		netdev_err(dev, "Handling parity error recovery. Try again later\n=
");
> +
> +		/* Don't allow bnx2x_set_features() to be called now. */
> +		return dev->features;
> +	}
> +
> +	/* TPA requires Rx CSUM offloading */
> +	if (!(features & NETIF_F_RXCSUM) || bp->disable_tpa)
> +		features &=3D ~NETIF_F_LRO;

Shouldn't it be (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM) and not
NETIF_F_RXCSUM?

> +
> +	return features;
> +}

In addition this function should ensure NETIF_F_IP_CSUM and
NETIF_F_IPV6_CSUM are changed together.

> +
> +int bnx2x_set_features(struct net_device *dev, u32 features)
> +{
> +	struct bnx2x *bp =3D netdev_priv(dev);
> +	u32 flags =3D bp->flags;
> +
> +	if (features & NETIF_F_LRO)
> +		flags |=3D TPA_ENABLE_FLAG;
> +	else
> +		flags &=3D ~TPA_ENABLE_FLAG;
> +
> +	if (flags ^ bp->flags) {
> +		bp->flags =3D flags;
> +
> +		return bnx2x_reload_if_running(dev);
>  	}
> =20
> -	return rc;
> +	return 0;
>  }

Since there is no set_rx_csum() anymore the above function has to handl=
e
bp->rx_csum namely correlate it with (NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM) bits in the 'features'.=20

> =20
>  void bnx2x_tx_timeout(struct net_device *dev)
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_=
cmn.h
> index 775fef0..1cdab69 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/bnx2x/bnx2x_cmn.h
> @@ -431,6 +431,9 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
>   */
>  int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
> =20
> +u32 bnx2x_fix_features(struct net_device *dev, u32 features);
> +int bnx2x_set_features(struct net_device *dev, u32 features);
> +
>  /**
>   * tx timeout netdev callback
>   *
> diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bn=
x2x_ethtool.c
> index 1479994..ad7d91e 100644
> --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> @@ -1299,91 +1299,6 @@ static int bnx2x_set_pauseparam(struct net_dev=
ice *dev,
>  	return 0;
>  }
> =20
> -static int bnx2x_set_flags(struct net_device *dev, u32 data)
> -{
> -	struct bnx2x *bp =3D netdev_priv(dev);
> -	int changed =3D 0;
> -	int rc =3D 0;
> -
> -	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
> -		printk(KERN_ERR "Handling parity error recovery. Try again later\n=
");
> -		return -EAGAIN;
> -	}
> -
> -	if (!(data & ETH_FLAG_RXVLAN))
> -		return -EINVAL;
> -
> -	if ((data & ETH_FLAG_LRO) && bp->rx_csum && bp->disable_tpa)
> -		return -EINVAL;
> -
> -	rc =3D ethtool_op_set_flags(dev, data, ETH_FLAG_LRO | ETH_FLAG_RXVL=
AN |
> -					ETH_FLAG_TXVLAN | ETH_FLAG_RXHASH);
> -	if (rc)
> -		return rc;
> -
> -	/* TPA requires Rx CSUM offloading */
> -	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
> -		if (!(bp->flags & TPA_ENABLE_FLAG)) {
> -			bp->flags |=3D TPA_ENABLE_FLAG;
> -			changed =3D 1;
> -		}
> -	} else if (bp->flags & TPA_ENABLE_FLAG) {
> -		dev->features &=3D ~NETIF_F_LRO;
> -		bp->flags &=3D ~TPA_ENABLE_FLAG;
> -		changed =3D 1;
> -	}
> -
> -	if (changed && netif_running(dev)) {
> -		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> -		rc =3D bnx2x_nic_load(bp, LOAD_NORMAL);
> -	}
> -
> -	return rc;
> -}
> -
> -static u32 bnx2x_get_rx_csum(struct net_device *dev)
> -{
> -	struct bnx2x *bp =3D netdev_priv(dev);
> -
> -	return bp->rx_csum;
> -}
> -
> -static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
> -{
> -	struct bnx2x *bp =3D netdev_priv(dev);
> -	int rc =3D 0;
> -
> -	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
> -		printk(KERN_ERR "Handling parity error recovery. Try again later\n=
");
> -		return -EAGAIN;
> -	}
> -
> -	bp->rx_csum =3D data;
> -
> -	/* Disable TPA, when Rx CSUM is disabled. Otherwise all
> -	   TPA'ed packets will be discarded due to wrong TCP CSUM */
> -	if (!data) {
> -		u32 flags =3D ethtool_op_get_flags(dev);
> -
> -		rc =3D bnx2x_set_flags(dev, (flags & ~ETH_FLAG_LRO));
> -	}
> -
> -	return rc;
> -}
> -
> -static int bnx2x_set_tso(struct net_device *dev, u32 data)
> -{
> -	if (data) {
> -		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -		dev->features |=3D NETIF_F_TSO6;
> -	} else {
> -		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
> -		dev->features &=3D ~NETIF_F_TSO6;
> -	}
> -
> -	return 0;
> -}
> -
>  static const struct {
>  	char string[ETH_GSTRING_LEN];
>  } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] =3D {
> @@ -2207,16 +2122,6 @@ static const struct ethtool_ops bnx2x_ethtool_=
ops =3D {
>  	.set_ringparam		=3D bnx2x_set_ringparam,
>  	.get_pauseparam		=3D bnx2x_get_pauseparam,
>  	.set_pauseparam		=3D bnx2x_set_pauseparam,
> -	.get_rx_csum		=3D bnx2x_get_rx_csum,
> -	.set_rx_csum		=3D bnx2x_set_rx_csum,
> -	.get_tx_csum		=3D ethtool_op_get_tx_csum,
> -	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
> -	.set_flags		=3D bnx2x_set_flags,
> -	.get_flags		=3D ethtool_op_get_flags,
> -	.get_sg			=3D ethtool_op_get_sg,
> -	.set_sg			=3D ethtool_op_set_sg,
> -	.get_tso		=3D ethtool_op_get_tso,
> -	.set_tso		=3D bnx2x_set_tso,
>  	.self_test		=3D bnx2x_self_test,
>  	.get_sset_count		=3D bnx2x_get_sset_count,
>  	.get_strings		=3D bnx2x_get_strings,
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x=
_main.c
> index f3cf889..ffa0611 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -7661,6 +7661,7 @@ exit_leader_reset:
>  	bp->is_leader =3D 0;
>  	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
>  	smp_wmb();
> +	netdev_update_features(bp->dev);
>  	return rc;
>  }

Before I continue I'd like to clarify one thing: there is no sense to
call for netdev_update_features() if bnx2x_nic_load(), called right
before it, has failed as long as the following bnx2x_nic_load() that
will be called from the netdev_update_features() flow will also fail
(for the same reasons as the previous one). If bnx2x_nic_load() fails
for the certain NIC we actually shut this NIC down. So, the following
remarks will be based on the above statement.

netdev_update_features(bp->dev) should be called after a successful
"leader"'s call for a bnx2x_nic_load() and not as above. See the patch
below:

diff --git a/drivers/net/bnx2x/bnx2x_main.c
b/drivers/net/bnx2x/bnx2x_main.c
index f3cf889..71e7818 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7728,6 +7728,8 @@ static void bnx2x_parity_recover(struct bnx2x *bp=
)
 						return;
 					}
=20
+					netdev_update_features(bp->dev);
+
					return;
 				}
=20
> =20
> @@ -7759,6 +7760,7 @@ static void bnx2x_parity_recover(struct bnx2x *=
bp)
>  					bp->recovery_state =3D
>  						BNX2X_RECOVERY_DONE;
>  					smp_wmb();
> +					netdev_update_features(bp->dev);
>  					return;
>  				}
>  			}

Same here: netdev_update_features() should be called only if the
previous bnx2x_nic_load() call has succeeded.

> @@ -8954,6 +8956,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x=
 *bp)
>  static int bnx2x_open(struct net_device *dev)
>  {
>  	struct bnx2x *bp =3D netdev_priv(dev);
> +	int rc;
> =20
>  	netif_carrier_off(dev);
> =20
> @@ -8993,7 +8996,9 @@ static int bnx2x_open(struct net_device *dev)
> =20
>  	bp->recovery_state =3D BNX2X_RECOVERY_DONE;
> =20
> -	return bnx2x_nic_load(bp, LOAD_OPEN);
> +	rc =3D bnx2x_nic_load(bp, LOAD_OPEN);
> +	netdev_update_features(bp->dev);
> +	return rc;
>  }

U shouldn't call for netdev_update_features(bp->dev) if bnx2x_nic_load(=
)
has failed. It would also be nice if netdev_update_features() would
propagate the exit status of ndo_set_features() when ndo_set_features()
fails in the __netdev_update_features(). See the patch for the bnx2x
below:

@@ -8993,7 +8995,14 @@ static int bnx2x_open(struct net_device *dev)
=20
        bp->recovery_state =3D BNX2X_RECOVERY_DONE;
=20
-       return bnx2x_nic_load(bp, LOAD_OPEN);
+       rc =3D bnx2x_nic_load(bp, LOAD_OPEN);
+       if (!rc)
+               netdev_update_features(bp->dev);
+
+       if (bp->state =3D=3D BNX2X_STATE_OPEN)
+               return 0;
+       else
+               return -EBUSY;
 }
=20
 /* called with rtnl_lock */
> =20
>  /* called with rtnl_lock */
> @@ -9304,6 +9309,8 @@ static const struct net_device_ops bnx2x_netdev=
_ops =3D {
>  	.ndo_validate_addr	=3D eth_validate_addr,
>  	.ndo_do_ioctl		=3D bnx2x_ioctl,
>  	.ndo_change_mtu		=3D bnx2x_change_mtu,
> +	.ndo_fix_features	=3D bnx2x_fix_features,
> +	.ndo_set_features	=3D bnx2x_set_features,
>  	.ndo_tx_timeout		=3D bnx2x_tx_timeout,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	=3D poll_bnx2x,
> @@ -9430,20 +9437,18 @@ static int __devinit bnx2x_init_dev(struct pc=
i_dev *pdev,
> =20
>  	dev->netdev_ops =3D &bnx2x_netdev_ops;
>  	bnx2x_set_ethtool_ops(dev);
> -	dev->features |=3D NETIF_F_SG;
> -	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +
>  	if (bp->flags & USING_DAC_FLAG)
>  		dev->features |=3D NETIF_F_HIGHDMA;
> -	dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -	dev->features |=3D NETIF_F_TSO6;
> -	dev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
> =20
> -	dev->vlan_features |=3D NETIF_F_SG;
> -	dev->vlan_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> -	if (bp->flags & USING_DAC_FLAG)
> -		dev->vlan_features |=3D NETIF_F_HIGHDMA;
> -	dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -	dev->vlan_features |=3D NETIF_F_TSO6;
> +	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM |
> +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> +		NETIF_F_HW_VLAN_TX;

hw_features are missing NETIF_F_GRO and NETIF_F_LRO flags that are
currently configured in bnx2x_init_bp().=20

> +
> +	dev->features |=3D dev->hw_features | NETIF_F_HW_VLAN_RX;
> +
> +	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_=
CSUM |
> +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;

I'm not sure if it's safe to set NETIF_F_HIGHDMA unconditionally. I
think it's better to correlate it with the USING_DAC_FLAG which is set
according to what is returned by=20
dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)).

thanks,
vlad

> =20
>  #ifdef BCM_DCBNL
>  	dev->dcbnl_ops =3D &bnx2x_dcbnl_ops;





