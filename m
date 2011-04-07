From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] net: tg3: convert to hw_features
Date: Thu, 7 Apr 2011 13:23:28 -0700
Message-ID: <20110407202328.GA18645@mcarlson.broadcom.com>
References: <20110407133507.13FDA13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Micha?? Miros??aw" <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2425 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687Ab1DGUTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 16:19:09 -0400
In-Reply-To: <20110407133507.13FDA13909@rere.qmqm.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice cleanup.  I visually studied it for a bit and didn't find anything
wrong.

Acked-by: Matt Carlson <mcarlson@broadcom.com>

On Thu, Apr 07, 2011 at 06:35:07AM -0700, Micha?? Miros??aw wrote:
> Cleanup hint: Some features are calculated in tg3_get_invariants() and
> the rest in its caller --- tg3_init_one(). This is not changed here.
> 
> Signed-off-by: Micha?? Miros??aw <mirq-linux@rere.qmqm.pl>
> ---
> [build tested only]
> 
>  drivers/net/tg3.c |  135 +++++++++++++----------------------------------------
>  drivers/net/tg3.h |    2 -
>  2 files changed, 32 insertions(+), 105 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index d37ae87..38962af 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -4816,7 +4816,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
>  			skb = copy_skb;
>  		}
>  
> -		if ((tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) &&
> +		if ((tp->dev->features & NETIF_F_RXCSUM) &&
>  		    (desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
>  		    (((desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
>  		      >> RXD_TCPCSUM_SHIFT) == 0xffff))
> @@ -6127,6 +6127,16 @@ dma_error:
>  	return NETDEV_TX_OK;
>  }
>  
> +static u32 tg3_fix_features(struct net_device *dev, u32 features)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +
> +	if (dev->mtu > ETH_DATA_LEN && (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
> +		features &= ~NETIF_F_ALL_TSO;
> +
> +	return features;
> +}
> +
>  static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
>  			       int new_mtu)
>  {
> @@ -6134,14 +6144,16 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
>  
>  	if (new_mtu > ETH_DATA_LEN) {
>  		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
> +			netdev_update_features(dev);
>  			tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
> -			ethtool_op_set_tso(dev, 0);
>  		} else {
>  			tp->tg3_flags |= TG3_FLAG_JUMBO_RING_ENABLE;
>  		}
>  	} else {
> -		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
> +		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
>  			tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
> +			netdev_update_features(dev);
> +		}
>  		tp->tg3_flags &= ~TG3_FLAG_JUMBO_RING_ENABLE;
>  	}
>  }
> @@ -10021,33 +10033,6 @@ static void tg3_set_msglevel(struct net_device *dev, u32 value)
>  	tp->msg_enable = value;
>  }
>  
> -static int tg3_set_tso(struct net_device *dev, u32 value)
> -{
> -	struct tg3 *tp = netdev_priv(dev);
> -
> -	if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
> -		if (value)
> -			return -EINVAL;
> -		return 0;
> -	}
> -	if ((dev->features & NETIF_F_IPV6_CSUM) &&
> -	    ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
> -	     (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3))) {
> -		if (value) {
> -			dev->features |= NETIF_F_TSO6;
> -			if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
> -			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
> -			    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
> -			     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
> -			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
> -			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
> -				dev->features |= NETIF_F_TSO_ECN;
> -		} else
> -			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
> -	}
> -	return ethtool_op_set_tso(dev, value);
> -}
> -
>  static int tg3_nway_reset(struct net_device *dev)
>  {
>  	struct tg3 *tp = netdev_priv(dev);
> @@ -10270,50 +10255,6 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
>  	return err;
>  }
>  
> -static u32 tg3_get_rx_csum(struct net_device *dev)
> -{
> -	struct tg3 *tp = netdev_priv(dev);
> -	return (tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0;
> -}
> -
> -static int tg3_set_rx_csum(struct net_device *dev, u32 data)
> -{
> -	struct tg3 *tp = netdev_priv(dev);
> -
> -	if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
> -		if (data != 0)
> -			return -EINVAL;
> -		return 0;
> -	}
> -
> -	spin_lock_bh(&tp->lock);
> -	if (data)
> -		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
> -	else
> -		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
> -	spin_unlock_bh(&tp->lock);
> -
> -	return 0;
> -}
> -
> -static int tg3_set_tx_csum(struct net_device *dev, u32 data)
> -{
> -	struct tg3 *tp = netdev_priv(dev);
> -
> -	if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
> -		if (data != 0)
> -			return -EINVAL;
> -		return 0;
> -	}
> -
> -	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
> -		ethtool_op_set_tx_ipv6_csum(dev, data);
> -	else
> -		ethtool_op_set_tx_csum(dev, data);
> -
> -	return 0;
> -}
> -
>  static int tg3_get_sset_count(struct net_device *dev, int sset)
>  {
>  	switch (sset) {
> @@ -11390,11 +11331,6 @@ static const struct ethtool_ops tg3_ethtool_ops = {
>  	.set_ringparam		= tg3_set_ringparam,
>  	.get_pauseparam		= tg3_get_pauseparam,
>  	.set_pauseparam		= tg3_set_pauseparam,
> -	.get_rx_csum		= tg3_get_rx_csum,
> -	.set_rx_csum		= tg3_set_rx_csum,
> -	.set_tx_csum		= tg3_set_tx_csum,
> -	.set_sg			= ethtool_op_set_sg,
> -	.set_tso		= tg3_set_tso,
>  	.self_test		= tg3_self_test,
>  	.get_strings		= tg3_get_strings,
>  	.set_phys_id		= tg3_set_phys_id,
> @@ -13262,11 +13198,6 @@ done:
>  
>  static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
>  
> -static inline void vlan_features_add(struct net_device *dev, unsigned long flags)
> -{
> -	dev->vlan_features |= flags;
> -}
> -
>  static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
>  {
>  	if (tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP)
> @@ -13513,16 +13444,14 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  	/* 5700 B0 chips do not support checksumming correctly due
>  	 * to hardware bugs.
>  	 */
> -	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
> -		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
> -	else {
> -		unsigned long features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO;
> +	if (tp->pci_chip_rev_id != CHIPREV_ID_5700_B0) {
> +		u32 features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
>  
> -		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
>  		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
>  			features |= NETIF_F_IPV6_CSUM;
>  		tp->dev->features |= features;
> -		vlan_features_add(tp->dev, features);
> +		tp->dev->hw_features |= features;
> +		tp->dev->vlan_features |= features;
>  	}
>  
>  	/* Determine TSO capabilities */
> @@ -14794,6 +14723,7 @@ static const struct net_device_ops tg3_netdev_ops = {
>  	.ndo_do_ioctl		= tg3_ioctl,
>  	.ndo_tx_timeout		= tg3_tx_timeout,
>  	.ndo_change_mtu		= tg3_change_mtu,
> +	.ndo_fix_features	= tg3_fix_features,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= tg3_poll_controller,
>  #endif
> @@ -14824,6 +14754,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	u32 sndmbx, rcvmbx, intmbx;
>  	char str[40];
>  	u64 dma_mask, persist_dma_mask;
> +	u32 hw_features = 0;
>  
>  	printk_once(KERN_INFO "%s\n", version);
>  
> @@ -14984,27 +14915,25 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	 * is off by default, but can be enabled using ethtool.
>  	 */
>  	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) &&
> -	    (dev->features & NETIF_F_IP_CSUM)) {
> -		dev->features |= NETIF_F_TSO;
> -		vlan_features_add(dev, NETIF_F_TSO);
> -	}
> +	    (dev->features & NETIF_F_IP_CSUM))
> +		hw_features |= NETIF_F_TSO;
>  	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
>  	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3)) {
> -		if (dev->features & NETIF_F_IPV6_CSUM) {
> -			dev->features |= NETIF_F_TSO6;
> -			vlan_features_add(dev, NETIF_F_TSO6);
> -		}
> +		if (dev->features & NETIF_F_IPV6_CSUM)
> +			hw_features |= NETIF_F_TSO6;
>  		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
>  		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
>  		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
>  		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
>  			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
> -		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
> -			dev->features |= NETIF_F_TSO_ECN;
> -			vlan_features_add(dev, NETIF_F_TSO_ECN);
> -		}
> +		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
> +			hw_features |= NETIF_F_TSO_ECN;
>  	}
>  
> +	dev->hw_features |= hw_features;
> +	dev->features |= hw_features;
> +	dev->vlan_features |= hw_features;
> +
>  	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
>  	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
>  	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
> @@ -15133,7 +15062,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	}
>  
>  	netdev_info(dev, "RXcsums[%d] LinkChgREG[%d] MIirq[%d] ASF[%d] TSOcap[%d]\n",
> -		    (tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0,
> +		    (dev->features & NETIF_F_RXCSUM) != 0,
>  		    (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) != 0,
>  		    (tp->phy_flags & TG3_PHYFLG_USE_MI_INTERRUPT) != 0,
>  		    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0,
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index e7880d5..73dda27 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2883,7 +2883,6 @@ struct tg3 {
>  	u32				tg3_flags;
>  #define TG3_FLAG_TAGGED_STATUS		0x00000001
>  #define TG3_FLAG_TXD_MBOX_HWBUG		0x00000002
> -#define TG3_FLAG_RX_CHECKSUMS		0x00000004
>  #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
>  #define TG3_FLAG_ENABLE_ASF		0x00000020
>  #define TG3_FLAG_ASPM_WORKAROUND	0x00000040
> @@ -2909,7 +2908,6 @@ struct tg3 {
>  #define TG3_FLAG_PAUSE_AUTONEG		0x02000000
>  #define TG3_FLAG_CPMU_PRESENT		0x04000000
>  #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
> -#define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
>  #define TG3_FLAG_JUMBO_CAPABLE		0x20000000
>  #define TG3_FLAG_CHIP_RESETTING		0x40000000
>  #define TG3_FLAG_INIT_COMPLETE		0x80000000
> -- 
> 1.7.2.5
> 
> 

