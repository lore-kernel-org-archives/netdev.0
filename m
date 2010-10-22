From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 1/3] vmxnet3: remove set_flag_le{16,64} helpers
Date: Fri, 22 Oct 2010 10:29:32 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1010221028080.9726@sbhatewara-dev1.eng.vmware.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:47439 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758097Ab0JVR3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 13:29:32 -0400
In-Reply-To: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Harvey,
Thanks for doing this.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>


On Thu, 21 Oct 2010, Harvey Harrison wrote:

> It's easier to just annotate the constants as little endian types and set/clear
> the flags directly.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/vmxnet3/upt1_defs.h       |    8 ++++----
>  drivers/net/vmxnet3/vmxnet3_defs.h    |    6 +++---
>  drivers/net/vmxnet3/vmxnet3_drv.c     |   20 +++++++++-----------
>  drivers/net/vmxnet3/vmxnet3_ethtool.c |   14 ++++++--------
>  drivers/net/vmxnet3/vmxnet3_int.h     |   15 ---------------
>  5 files changed, 22 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/upt1_defs.h b/drivers/net/vmxnet3/upt1_defs.h
> index 37108fb..969c751 100644
> --- a/drivers/net/vmxnet3/upt1_defs.h
> +++ b/drivers/net/vmxnet3/upt1_defs.h
> @@ -88,9 +88,9 @@ struct UPT1_RSSConf {
>  
>  /* features */
>  enum {
> -	UPT1_F_RXCSUM		= 0x0001,   /* rx csum verification */
> -	UPT1_F_RSS		= 0x0002,
> -	UPT1_F_RXVLAN		= 0x0004,   /* VLAN tag stripping */
> -	UPT1_F_LRO		= 0x0008,
> +	UPT1_F_RXCSUM		= cpu_to_le64(0x0001),   /* rx csum verification */
> +	UPT1_F_RSS		= cpu_to_le64(0x0002),
> +	UPT1_F_RXVLAN		= cpu_to_le64(0x0004),   /* VLAN tag stripping */
> +	UPT1_F_LRO		= cpu_to_le64(0x0008),
>  };
>  #endif
> diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
> index ca7727b..4d84912 100644
> --- a/drivers/net/vmxnet3/vmxnet3_defs.h
> +++ b/drivers/net/vmxnet3/vmxnet3_defs.h
> @@ -523,9 +523,9 @@ struct Vmxnet3_RxFilterConf {
>  #define VMXNET3_PM_MAX_PATTERN_SIZE   128
>  #define VMXNET3_PM_MAX_MASK_SIZE      (VMXNET3_PM_MAX_PATTERN_SIZE / 8)
>  
> -#define VMXNET3_PM_WAKEUP_MAGIC       0x01  /* wake up on magic pkts */
> -#define VMXNET3_PM_WAKEUP_FILTER      0x02  /* wake up on pkts matching
> -					     * filters */
> +#define VMXNET3_PM_WAKEUP_MAGIC       cpu_to_le16(0x01)  /* wake up on magic pkts */
> +#define VMXNET3_PM_WAKEUP_FILTER      cpu_to_le16(0x02)  /* wake up on pkts matching
> +							  * filters */
>  
>  
>  struct Vmxnet3_PM_PktFilter {
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 3f60e0e..2ea4b81 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1563,8 +1563,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
>  			adapter->vlan_grp = grp;
>  
>  			/* update FEATURES to device */
> -			set_flag_le64(&devRead->misc.uptFeatures,
> -				      UPT1_F_RXVLAN);
> +			devRead->misc.uptFeatures |= UPT1_F_RXVLAN;
>  			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>  					       VMXNET3_CMD_UPDATE_FEATURE);
>  			/*
> @@ -1587,7 +1586,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
>  		struct Vmxnet3_DSDevRead *devRead = &shared->devRead;
>  		adapter->vlan_grp = NULL;
>  
> -		if (le64_to_cpu(devRead->misc.uptFeatures) & UPT1_F_RXVLAN) {
> +		if (devRead->misc.uptFeatures & UPT1_F_RXVLAN) {
>  			int i;
>  
>  			for (i = 0; i < VMXNET3_VFT_SIZE; i++) {
> @@ -1600,8 +1599,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
>  					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
>  
>  			/* update FEATURES to device */
> -			reset_flag_le64(&devRead->misc.uptFeatures,
> -					UPT1_F_RXVLAN);
> +			devRead->misc.uptFeatures &= ~UPT1_F_RXVLAN;
>  			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>  					       VMXNET3_CMD_UPDATE_FEATURE);
>  		}
> @@ -1762,15 +1760,15 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
>  
>  	/* set up feature flags */
>  	if (adapter->rxcsum)
> -		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXCSUM);
> +		devRead->misc.uptFeatures |= UPT1_F_RXCSUM;
>  
>  	if (adapter->lro) {
> -		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_LRO);
> +		devRead->misc.uptFeatures |= UPT1_F_LRO;
>  		devRead->misc.maxNumRxSG = cpu_to_le16(1 + MAX_SKB_FRAGS);
>  	}
>  	if ((adapter->netdev->features & NETIF_F_HW_VLAN_RX) &&
>  	    adapter->vlan_grp) {
> -		set_flag_le64(&devRead->misc.uptFeatures, UPT1_F_RXVLAN);
> +		devRead->misc.uptFeatures |= UPT1_F_RXVLAN;
>  	}
>  
>  	devRead->misc.mtu = cpu_to_le32(adapter->netdev->mtu);
> @@ -2577,7 +2575,7 @@ vmxnet3_suspend(struct device *device)
>  		memcpy(pmConf->filters[i].pattern, netdev->dev_addr, ETH_ALEN);
>  		pmConf->filters[i].mask[0] = 0x3F; /* LSB ETH_ALEN bits */
>  
> -		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
> +		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_FILTER;
>  		i++;
>  	}
>  
> @@ -2619,13 +2617,13 @@ vmxnet3_suspend(struct device *device)
>  		pmConf->filters[i].mask[5] = 0x03; /* IPv4 TIP */
>  		in_dev_put(in_dev);
>  
> -		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_FILTER);
> +		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_FILTER;
>  		i++;
>  	}
>  
>  skip_arp:
>  	if (adapter->wol & WAKE_MAGIC)
> -		set_flag_le16(&pmConf->wakeUpEvents, VMXNET3_PM_WAKEUP_MAGIC);
> +		pmConf->wakeUpEvents |= VMXNET3_PM_WAKEUP_MAGIC;
>  
>  	pmConf->numFilters = i;
>  
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index 7e4b5a8..b79070b 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -50,13 +50,11 @@ vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
>  		adapter->rxcsum = val;
>  		if (netif_running(netdev)) {
>  			if (val)
> -				set_flag_le64(
> -				&adapter->shared->devRead.misc.uptFeatures,
> -				UPT1_F_RXCSUM);
> +				adapter->shared->devRead.misc.uptFeatures |=
> +				UPT1_F_RXCSUM;
>  			else
> -				reset_flag_le64(
> -				&adapter->shared->devRead.misc.uptFeatures,
> -				UPT1_F_RXCSUM);
> +				adapter->shared->devRead.misc.uptFeatures &=
> +				~UPT1_F_RXCSUM;
>  
>  			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>  					       VMXNET3_CMD_UPDATE_FEATURE);
> @@ -292,10 +290,10 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
>  		/* update harware LRO capability accordingly */
>  		if (lro_requested)
>  			adapter->shared->devRead.misc.uptFeatures |=
> -						cpu_to_le64(UPT1_F_LRO);
> +							UPT1_F_LRO;
>  		else
>  			adapter->shared->devRead.misc.uptFeatures &=
> -						cpu_to_le64(~UPT1_F_LRO);
> +							~UPT1_F_LRO;
>  		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>  				       VMXNET3_CMD_UPDATE_FEATURE);
>  	}
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
> index c88ea5c..46aee6d 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -353,21 +353,6 @@ struct vmxnet3_adapter {
>  #define VMXNET3_MAX_ETH_HDR_SIZE    22
>  #define VMXNET3_MAX_SKB_BUF_SIZE    (3*1024)
>  
> -static inline void set_flag_le16(__le16 *data, u16 flag)
> -{
> -	*data = cpu_to_le16(le16_to_cpu(*data) | flag);
> -}
> -
> -static inline void set_flag_le64(__le64 *data, u64 flag)
> -{
> -	*data = cpu_to_le64(le64_to_cpu(*data) | flag);
> -}
> -
> -static inline void reset_flag_le64(__le64 *data, u64 flag)
> -{
> -	*data = cpu_to_le64(le64_to_cpu(*data) & ~flag);
> -}
> -
>  int
>  vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
>  
> -- 
> 1.7.1
> 
> 
