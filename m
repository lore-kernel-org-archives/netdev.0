From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 3/3] net: fullly using NETIF_F_ALL_TSO
Date: Fri, 22 Apr 2011 08:45:48 -0700
Message-ID: <4DB1A2AC.3010301@chelsio.com>
References: <4DB16187.2030904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, leedom@chelsio.com, benve@cisco.com,
	vkolluri@cisco.com, roprabhu@cisco.com, dwang2@cisco.com,
	ron.mercer@qlogic.com, linux-driver@qlogic.com,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28079 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab1DVPqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 11:46:31 -0400
In-Reply-To: <4DB16187.2030904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2011 04:07 AM, Shan Wei wrote:
>  
> Fullly using NETIF_F_ALL_TSO.
> And some code style tuning. Just compile test.

This would make drivers automatically claim to support any new TSO feature 
the moment the feature is added.  I think drivers should have to explicitly 
opt in if they are capable and ready.

You could use NETIF_F_ALL_TSO for vlan_features, which is a mask, but not 
hw_features.

> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  drivers/net/bnx2x/bnx2x_main.c     |    6 +++---
>  drivers/net/cxgb4/cxgb4_main.c     |    5 ++---
>  drivers/net/cxgb4vf/cxgb4vf_main.c |    9 ++-------
>  drivers/net/enic/enic_main.c       |    3 +--
>  drivers/net/ifb.c                  |    3 +--
>  drivers/net/qlge/qlge_main.c       |    3 +--
>  6 files changed, 10 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index bfd7ac9..1d47b05 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -9425,11 +9425,11 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
>  	bnx2x_set_ethtool_ops(dev);
>  
>  	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> -		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> -		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
> +			   NETIF_F_ALL_TSO | NETIF_F_RXCSUM | NETIF_F_LRO |
> +			   NETIF_F_HW_VLAN_TX;
>  
>  	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> -		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
> +			     NETIF_F_ALL_TSO | NETIF_F_HIGHDMA;
>  
>  	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
>  	if (bp->flags & USING_DAC_FLAG)
> diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
> index bdc868c..916484d 100644
> --- a/drivers/net/cxgb4/cxgb4_main.c
> +++ b/drivers/net/cxgb4/cxgb4_main.c
> @@ -3525,8 +3525,7 @@ static void free_some_resources(struct adapter *adapter)
>  		t4_fw_bye(adapter, adapter->fn);
>  }
>  
> -#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
> -#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
> +#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_ALL_TSO | \
>  		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
>  
>  static int __devinit init_one(struct pci_dev *pdev,
> @@ -3630,7 +3629,7 @@ static int __devinit init_one(struct pci_dev *pdev,
>  		pi->port_id = i;
>  		netdev->irq = pdev->irq;
>  
> -		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
> +		netdev->hw_features = NETIF_F_SG | NETIF_F_ALL_TSO |
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_RXCSUM | NETIF_F_RXHASH |
>  			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
> index 8cf9890..f8fb8e3 100644
> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
> @@ -1540,11 +1540,6 @@ static void cxgb4vf_get_wol(struct net_device *dev,
>  	memset(&wol->sopass, 0, sizeof(wol->sopass));
>  }
>  
> -/*
> - * TCP Segmentation Offload flags which we support.
> - */
> -#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
> -
>  static struct ethtool_ops cxgb4vf_ethtool_ops = {
>  	.get_settings		= cxgb4vf_get_settings,
>  	.get_drvinfo		= cxgb4vf_get_drvinfo,
> @@ -2600,10 +2595,10 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
>  		netif_carrier_off(netdev);
>  		netdev->irq = pdev->irq;
>  
> -		netdev->hw_features = NETIF_F_SG | TSO_FLAGS |
> +		netdev->hw_features = NETIF_F_SG | NETIF_F_ALL_TSO |
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
> -		netdev->vlan_features = NETIF_F_SG | TSO_FLAGS |
> +		netdev->vlan_features = NETIF_F_SG | NETIF_F_ALL_TSO |
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_HIGHDMA;
>  		netdev->features = netdev->hw_features |
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index b224551..1a03a74 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -2381,8 +2381,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
>  	if (ENIC_SETTING(enic, TXCSUM))
>  		netdev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM;
>  	if (ENIC_SETTING(enic, TSO))
> -		netdev->hw_features |= NETIF_F_TSO |
> -			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
> +		netdev->hw_features |= NETIF_F_ALL_TSO;
>  	if (ENIC_SETTING(enic, RXCSUM))
>  		netdev->hw_features |= NETIF_F_RXCSUM;
>  
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index e07d487..c41b822 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -127,8 +127,7 @@ static const struct net_device_ops ifb_netdev_ops = {
>  };
>  
>  #define IFB_FEATURES (NETIF_F_NO_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
> -		      NETIF_F_TSO_ECN | NETIF_F_TSO | NETIF_F_TSO6	| \
> -		      NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX)
> +		      NETIF_F_ALL_TSO | NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_TX)
>  
>  static void ifb_setup(struct net_device *dev)
>  {
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index 6c9d124..709aaa6 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -4695,8 +4695,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
>  	qdev = netdev_priv(ndev);
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
>  	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
> -		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN |
> -		NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
> +		NETIF_F_ALL_TSO | NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
>  	ndev->features = ndev->hw_features |
>  		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
>  

