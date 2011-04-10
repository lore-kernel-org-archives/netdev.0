From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] net: bnx2x: convert to hw_features
Date: Sun, 10 Apr 2011 18:10:14 +0300
Message-ID: <1302448214.2242.6.camel@lb-tlvb-vladz>
References: <20110410144746.679DD13A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1320 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754721Ab1DJPKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 11:10:31 -0400
In-Reply-To: <20110410144746.679DD13A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +int bnx2x_set_features(struct net_device *dev, u32 features)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	u32 flags = bp->flags;
> +
> +	if (features & NETIF_F_LRO)
> +		flags |= TPA_ENABLE_FLAG;
> +	else
> +		flags &= ~TPA_ENABLE_FLAG;
> +
> +	if (flags ^ bp->flags) {
> +		bp->flags = flags;
> +
> +		return bnx2x_reload_if_running(dev);
>  	}
>  
> -	return rc;
> +	return 0;
>  }

Thanks a lot, Michal. Looks ok but one remark below.

Every time  bnx2x_reload_if_running(dev) is called one has to check if
there is still a recovery process in progress like u did in the
bnx2x_fix_features(). So this check is missing in the function above.

I'd like to do some unit testing with the new code. I'll let u know
about the results tomorrow.

Thanks again,
vlad 

>  
>  void bnx2x_tx_timeout(struct net_device *dev)
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
> index 775fef0..1cdab69 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/bnx2x/bnx2x_cmn.h
> @@ -431,6 +431,9 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
>   */
>  int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
>  
> +u32 bnx2x_fix_features(struct net_device *dev, u32 features);
> +int bnx2x_set_features(struct net_device *dev, u32 features);
> +
>  /**
>   * tx timeout netdev callback
>   *
> diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
> index 1479994..ad7d91e 100644
> --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> @@ -1299,91 +1299,6 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
>  	return 0;
>  }
>  
> -static int bnx2x_set_flags(struct net_device *dev, u32 data)
> -{
> -	struct bnx2x *bp = netdev_priv(dev);
> -	int changed = 0;
> -	int rc = 0;
> -
> -	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
> -		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
> -		return -EAGAIN;
> -	}
> -
> -	if (!(data & ETH_FLAG_RXVLAN))
> -		return -EINVAL;
> -
> -	if ((data & ETH_FLAG_LRO) && bp->rx_csum && bp->disable_tpa)
> -		return -EINVAL;
> -
> -	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_LRO | ETH_FLAG_RXVLAN |
> -					ETH_FLAG_TXVLAN | ETH_FLAG_RXHASH);
> -	if (rc)
> -		return rc;
> -
> -	/* TPA requires Rx CSUM offloading */
> -	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
> -		if (!(bp->flags & TPA_ENABLE_FLAG)) {
> -			bp->flags |= TPA_ENABLE_FLAG;
> -			changed = 1;
> -		}
> -	} else if (bp->flags & TPA_ENABLE_FLAG) {
> -		dev->features &= ~NETIF_F_LRO;
> -		bp->flags &= ~TPA_ENABLE_FLAG;
> -		changed = 1;
> -	}
> -
> -	if (changed && netif_running(dev)) {
> -		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> -		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
> -	}
> -
> -	return rc;
> -}
> -
> -static u32 bnx2x_get_rx_csum(struct net_device *dev)
> -{
> -	struct bnx2x *bp = netdev_priv(dev);
> -
> -	return bp->rx_csum;
> -}
> -
> -static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
> -{
> -	struct bnx2x *bp = netdev_priv(dev);
> -	int rc = 0;
> -
> -	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
> -		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
> -		return -EAGAIN;
> -	}
> -
> -	bp->rx_csum = data;
> -
> -	/* Disable TPA, when Rx CSUM is disabled. Otherwise all
> -	   TPA'ed packets will be discarded due to wrong TCP CSUM */
> -	if (!data) {
> -		u32 flags = ethtool_op_get_flags(dev);
> -
> -		rc = bnx2x_set_flags(dev, (flags & ~ETH_FLAG_LRO));
> -	}
> -
> -	return rc;
> -}
> -
> -static int bnx2x_set_tso(struct net_device *dev, u32 data)
> -{
> -	if (data) {
> -		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -		dev->features |= NETIF_F_TSO6;
> -	} else {
> -		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
> -		dev->features &= ~NETIF_F_TSO6;
> -	}
> -
> -	return 0;
> -}
> -
>  static const struct {
>  	char string[ETH_GSTRING_LEN];
>  } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] = {
> @@ -2207,16 +2122,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
>  	.set_ringparam		= bnx2x_set_ringparam,
>  	.get_pauseparam		= bnx2x_get_pauseparam,
>  	.set_pauseparam		= bnx2x_set_pauseparam,
> -	.get_rx_csum		= bnx2x_get_rx_csum,
> -	.set_rx_csum		= bnx2x_set_rx_csum,
> -	.get_tx_csum		= ethtool_op_get_tx_csum,
> -	.set_tx_csum		= ethtool_op_set_tx_hw_csum,
> -	.set_flags		= bnx2x_set_flags,
> -	.get_flags		= ethtool_op_get_flags,
> -	.get_sg			= ethtool_op_get_sg,
> -	.set_sg			= ethtool_op_set_sg,
> -	.get_tso		= ethtool_op_get_tso,
> -	.set_tso		= bnx2x_set_tso,
>  	.self_test		= bnx2x_self_test,
>  	.get_sset_count		= bnx2x_get_sset_count,
>  	.get_strings		= bnx2x_get_strings,
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index f3cf889..ffa0611 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -7661,6 +7661,7 @@ exit_leader_reset:
>  	bp->is_leader = 0;
>  	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
>  	smp_wmb();
> +	netdev_update_features(bp->dev);
>  	return rc;
>  }
>  
> @@ -7759,6 +7760,7 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
>  					bp->recovery_state =
>  						BNX2X_RECOVERY_DONE;
>  					smp_wmb();
> +					netdev_update_features(bp->dev);
>  					return;
>  				}
>  			}
> @@ -8954,6 +8956,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
>  static int bnx2x_open(struct net_device *dev)
>  {
>  	struct bnx2x *bp = netdev_priv(dev);
> +	int rc;
>  
>  	netif_carrier_off(dev);
>  
> @@ -8993,7 +8996,9 @@ static int bnx2x_open(struct net_device *dev)
>  
>  	bp->recovery_state = BNX2X_RECOVERY_DONE;
>  
> -	return bnx2x_nic_load(bp, LOAD_OPEN);
> +	rc = bnx2x_nic_load(bp, LOAD_OPEN);
> +	netdev_update_features(bp->dev);
> +	return rc;
>  }
>  
>  /* called with rtnl_lock */
> @@ -9304,6 +9309,8 @@ static const struct net_device_ops bnx2x_netdev_ops = {
>  	.ndo_validate_addr	= eth_validate_addr,
>  	.ndo_do_ioctl		= bnx2x_ioctl,
>  	.ndo_change_mtu		= bnx2x_change_mtu,
> +	.ndo_fix_features	= bnx2x_fix_features,
> +	.ndo_set_features	= bnx2x_set_features,
>  	.ndo_tx_timeout		= bnx2x_tx_timeout,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= poll_bnx2x,
> @@ -9430,20 +9437,18 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
>  
>  	dev->netdev_ops = &bnx2x_netdev_ops;
>  	bnx2x_set_ethtool_ops(dev);
> -	dev->features |= NETIF_F_SG;
> -	dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +
>  	if (bp->flags & USING_DAC_FLAG)
>  		dev->features |= NETIF_F_HIGHDMA;
> -	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -	dev->features |= NETIF_F_TSO6;
> -	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
>  
> -	dev->vlan_features |= NETIF_F_SG;
> -	dev->vlan_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> -	if (bp->flags & USING_DAC_FLAG)
> -		dev->vlan_features |= NETIF_F_HIGHDMA;
> -	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> -	dev->vlan_features |= NETIF_F_TSO6;
> +	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> +		NETIF_F_HW_VLAN_TX;
> +
> +	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
> +
> +	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
>  
>  #ifdef BCM_DCBNL
>  	dev->dcbnl_ops = &bnx2x_dcbnl_ops;



