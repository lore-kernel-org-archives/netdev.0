From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2] net/sh-eth: Add support selecting MII function for SH7734 and R8A7740
Date: Tue, 12 Jun 2012 10:40:02 +0200
Message-ID: <2360907.koU5zCUYMQ@flexo>
References: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55603 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552Ab2FLImX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 04:42:23 -0400
Received: by yhmm54 with SMTP id m54so3213674yhm.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 01:42:22 -0700 (PDT)
In-Reply-To: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 June 2012 16:29:02 Nobuhiro Iwamatsu wrote:
> Ethernet IP of SH7734 and R8A7740 has selecting MII register.
> The user needs to change a value according to MII to be used.
> This adds the function to change the value of this register.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
>  V2: Fix the check by select_mii.
>  drivers/net/ethernet/renesas/sh_eth.c |  106 
++++++++++++++++++++-------------
>  drivers/net/ethernet/renesas/sh_eth.h |    1 +
>  2 files changed, 65 insertions(+), 42 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c 
b/drivers/net/ethernet/renesas/sh_eth.c
> index be3c221..5358804 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -49,6 +49,33 @@
>  		NETIF_MSG_RX_ERR| \
>  		NETIF_MSG_TX_ERR)
>  
> +#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) 
|| \
> +	defined(CONFIG_ARCH_R8A7740)
> +static void sh_eth_select_mii(struct net_device *ndev)
> +{
> +	u32 value = 0x0;
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +
> +	switch (mdp->phy_interface) {
> +	case PHY_INTERFACE_MODE_GMII:
> +		value = 0x2;
> +		break;
> +	case PHY_INTERFACE_MODE_MII:
> +		value = 0x1;
> +		break;
> +	case PHY_INTERFACE_MODE_RMII:
> +		value = 0x0;
> +		break;
> +	default:
> +		pr_warn("PHY interface mode was not setup. Set to MII.\n");
> +		value = 0x1;
> +		break;
> +	}
> +
> +	sh_eth_write(ndev, value, RMII_MII);
> +}
> +#endif
> +
>  /* There is CPU dependent code */
>  #if defined(CONFIG_CPU_SUBTYPE_SH7724)
>  #define SH_ETH_RESET_DEFAULT	1
> @@ -283,6 +310,7 @@ static struct sh_eth_cpu_data 
*sh_eth_get_cpu_data(struct sh_eth_private *mdp)
>  #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || 
defined(CONFIG_CPU_SUBTYPE_SH7763)
>  #define SH_ETH_HAS_TSU	1
>  static void sh_eth_reset_hw_crc(struct net_device *ndev);
> +
>  static void sh_eth_chip_reset(struct net_device *ndev)
>  {
>  	struct sh_eth_private *mdp = netdev_priv(ndev);
> @@ -292,35 +320,6 @@ static void sh_eth_chip_reset(struct net_device *ndev)
>  	mdelay(1);
>  }
>  
> -static void sh_eth_reset(struct net_device *ndev)
> -{
> -	int cnt = 100;
> -
> -	sh_eth_write(ndev, EDSR_ENALL, EDSR);
> -	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
> -	while (cnt > 0) {
> -		if (!(sh_eth_read(ndev, EDMR) & 0x3))
> -			break;
> -		mdelay(1);
> -		cnt--;
> -	}
> -	if (cnt == 0)
> -		printk(KERN_ERR "Device reset fail\n");
> -
> -	/* Table Init */
> -	sh_eth_write(ndev, 0x0, TDLAR);
> -	sh_eth_write(ndev, 0x0, TDFAR);
> -	sh_eth_write(ndev, 0x0, TDFXR);
> -	sh_eth_write(ndev, 0x0, TDFFR);
> -	sh_eth_write(ndev, 0x0, RDLAR);
> -	sh_eth_write(ndev, 0x0, RDFAR);
> -	sh_eth_write(ndev, 0x0, RDFXR);
> -	sh_eth_write(ndev, 0x0, RDFFR);
> -
> -	/* Reset HW CRC register */
> -	sh_eth_reset_hw_crc(ndev);
> -}
> -
>  static void sh_eth_set_duplex(struct net_device *ndev)
>  {
>  	struct sh_eth_private *mdp = netdev_priv(ndev);
> @@ -377,9 +376,43 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>  	.tsu		= 1,
>  #if defined(CONFIG_CPU_SUBTYPE_SH7734)
>  	.hw_crc     = 1,
> +	.select_mii = 1,
>  #endif
>  };
>  
> +static void sh_eth_reset(struct net_device *ndev)
> +{
> +	int cnt = 100;
> +
> +	sh_eth_write(ndev, EDSR_ENALL, EDSR);
> +	sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER, EDMR);
> +	while (cnt > 0) {
> +		if (!(sh_eth_read(ndev, EDMR) & 0x3))
> +			break;
> +		mdelay(1);
> +		cnt--;
> +	}
> +	if (cnt == 0)
> +		printk(KERN_ERR "Device reset fail\n");

It looks like this would need a subsequent fix. Failing to reset the adapter 
and just erroring out and not returning an error looks obviously wrong. Since 
sh_eth_reset() is called in sh_eth_dev_init() which does return an int, 
propagate the error back to the caller.

> +
> +	/* Table Init */
> +	sh_eth_write(ndev, 0x0, TDLAR);
> +	sh_eth_write(ndev, 0x0, TDFAR);
> +	sh_eth_write(ndev, 0x0, TDFXR);
> +	sh_eth_write(ndev, 0x0, TDFFR);
> +	sh_eth_write(ndev, 0x0, RDLAR);
> +	sh_eth_write(ndev, 0x0, RDFAR);
> +	sh_eth_write(ndev, 0x0, RDFXR);
> +	sh_eth_write(ndev, 0x0, RDFFR);
> +
> +	/* Reset HW CRC register */
> +	sh_eth_reset_hw_crc(ndev);
> +
> +	/* Select MII mode */
> +	if (sh_eth_my_cpu_data.select_mii)
> +		sh_eth_select_mii(ndev);
> +}
> +
>  static void sh_eth_reset_hw_crc(struct net_device *ndev)
>  {
>  	if (sh_eth_my_cpu_data.hw_crc)
> @@ -397,19 +430,7 @@ static void sh_eth_chip_reset(struct net_device *ndev)
>  	sh_eth_tsu_write(mdp, ARSTR_ARSTR, ARSTR);
>  	mdelay(1);
>  
> -	switch (mdp->phy_interface) {
> -	case PHY_INTERFACE_MODE_GMII:
> -		mii = 2;
> -		break;
> -	case PHY_INTERFACE_MODE_MII:
> -		mii = 1;
> -		break;
> -	case PHY_INTERFACE_MODE_RMII:
> -	default:
> -		mii = 0;
> -		break;
> -	}
> -	sh_eth_write(ndev, mii, RMII_MII);
> +	sh_eth_select_mii(ndev);
>  }
>  
>  static void sh_eth_reset(struct net_device *ndev)
> @@ -492,6 +513,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>  	.no_trimd	= 1,
>  	.no_ade		= 1,
>  	.tsu		= 1,
> +	.select_mii = 1,
>  };
>  
>  #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h 
b/drivers/net/ethernet/renesas/sh_eth.h
> index 57b8e1f..d6763b1392 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -757,6 +757,7 @@ struct sh_eth_cpu_data {
>  	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
>  	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
>  	unsigned hw_crc:1;	/* E-DMAC have CSMR */
> +	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) 
*/
>  };
>  
>  struct sh_eth_private {
> -- 
> 1.7.10
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Florian
