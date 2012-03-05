From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH v2 2/2] powerpc/44x: Add more changes for APM821XX EMAC driver
Date: Mon, 5 Mar 2012 08:41:57 +0100
Message-ID: <201203050841.57291.sr@denx.de>
References: <1329466058-15969-1-git-send-email-dhdang@apm.com> <1330920224-3006-1-git-send-email-dhdang@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Duc Dang <dhdang@apm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>,
	Josh Boyer <jwboyer@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330920224-3006-1-git-send-email-dhdang@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 March 2012 05:03:44 Duc Dang wrote:
> This patch includes:
> 
>   Configure EMAC PHY clock source (clock from PHY or internal clock).
> 
>   Do not advertise PHY half duplex capability as APM821XX EMAC does not
> support half duplex mode.
> 
>   Add changes to support configuring jumbo frame for APM821XX EMAC.
> 
> Signed-off-by: Duc Dang <dhdang@apm.com>
> ---
> v2:
>  Fix coding style problems.
> 
>  drivers/net/ethernet/ibm/emac/core.c |   26 +++++++++++++++++++++++++-
>  drivers/net/ethernet/ibm/emac/core.h |   13 +++++++++++--
>  drivers/net/ethernet/ibm/emac/emac.h |    5 ++++-
>  3 files changed, 40 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ibm/emac/core.c
> b/drivers/net/ethernet/ibm/emac/core.c index 2abce96..ad671c5 100644
> --- a/drivers/net/ethernet/ibm/emac/core.c
> +++ b/drivers/net/ethernet/ibm/emac/core.c
> @@ -434,6 +434,11 @@ static inline u32 emac_iff2rmr(struct net_device
> *ndev) else if (!netdev_mc_empty(ndev))
>  		r |= EMAC_RMR_MAE;
> 
> +	if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE)) {
> +		r &= ~EMAC4_RMR_MJS_MASK;
> +		r |= EMAC4_RMR_MJS(ndev->mtu);
> +	}
> +
>  	return r;
>  }
> 
> @@ -965,6 +970,7 @@ static int emac_resize_rx_ring(struct emac_instance
> *dev, int new_mtu) int rx_sync_size = emac_rx_sync_size(new_mtu);
>  	int rx_skb_size = emac_rx_skb_size(new_mtu);
>  	int i, ret = 0;
> +	int mr1_jumbo_bit_change = 0;
> 
>  	mutex_lock(&dev->link_lock);
>  	emac_netif_stop(dev);
> @@ -1013,7 +1019,14 @@ static int emac_resize_rx_ring(struct emac_instance
> *dev, int new_mtu) }
>   skip:
>  	/* Check if we need to change "Jumbo" bit in MR1 */
> -	if ((new_mtu > ETH_DATA_LEN) ^ (dev->ndev->mtu > ETH_DATA_LEN)) {
> +	if (emac_has_feature(dev, EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE))
> +		mr1_jumbo_bit_change = (new_mtu > ETH_DATA_LEN) ||
> +				(dev->ndev->mtu > ETH_DATA_LEN);
> +	else
> +		mr1_jumbo_bit_change = (new_mtu > ETH_DATA_LEN) ^
> +				(dev->ndev->mtu > ETH_DATA_LEN);
> +
> +	if (mr1_jumbo_bit_change) {
>  		/* This is to prevent starting RX channel in emac_rx_enable() 
*/
>  		set_bit(MAL_COMMAC_RX_STOPPED, &dev->commac.flags);
> 
> @@ -2471,6 +2484,7 @@ static int __devinit emac_init_phy(struct
> emac_instance *dev)
> 
>  	/* Disable any PHY features not supported by the platform */
>  	dev->phy.def->features &= ~dev->phy_feat_exc;
> +	dev->phy.features &= ~dev->phy_feat_exc;
> 
>  	/* Setup initial link parameters */
>  	if (dev->phy.features & SUPPORTED_Autoneg) {
> @@ -2568,6 +2582,10 @@ static int __devinit emac_init_config(struct
> emac_instance *dev) if (of_device_is_compatible(np, "ibm,emac-405ex") ||
>  		    of_device_is_compatible(np, "ibm,emac-405exr"))
>  			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
> +		if (of_device_is_compatible(np, "ibm,emac-apm821xx"))
> +			dev->features |= (EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE 
|
> +					EMAC_FTR_APM821XX_NO_HALF_DUPLEX |
> +					EMAC_FTR_460EX_PHY_CLK_FIX);

Nitpick: Parentheses for multi line statement please.

>  	} else if (of_device_is_compatible(np, "ibm,emac4")) {
>  		dev->features |= EMAC_FTR_EMAC4;
>  		if (of_device_is_compatible(np, "ibm,emac-440gx"))
> @@ -2818,6 +2836,12 @@ static int __devinit emac_probe(struct
> platform_device *ofdev) dev->stop_timeout = STOP_TIMEOUT_100;
>  	INIT_DELAYED_WORK(&dev->link_work, emac_link_timer);
> 
> +	/* Some SoCs like APM821xx does not support Half Duplex mode. */
> +	if (emac_has_feature(dev, EMAC_FTR_APM821XX_NO_HALF_DUPLEX))
> +		dev->phy_feat_exc = (SUPPORTED_1000baseT_Half |
> +					SUPPORTED_100baseT_Half |
> +					SUPPORTED_10baseT_Half);
> +

Nitpick: Parentheses for multi line statement please.

>  	/* Find PHY if any */
>  	err = emac_init_phy(dev);
>  	if (err != 0)
> diff --git a/drivers/net/ethernet/ibm/emac/core.h
> b/drivers/net/ethernet/ibm/emac/core.h index fa3ec57..9dea85a 100644
> --- a/drivers/net/ethernet/ibm/emac/core.h
> +++ b/drivers/net/ethernet/ibm/emac/core.h
> @@ -325,7 +325,14 @@ struct emac_instance {
>   * Set if we need phy clock workaround for 460ex or 460gt
>   */
>  #define EMAC_FTR_460EX_PHY_CLK_FIX	0x00000400
> -
> +/*
> + * APM821xx requires Jumbo frame size set explicitly
> + */
> +#define EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE	0x00000800
> +/*
> + * APM821xx does not support Half Duplex mode
> + */
> +#define EMAC_FTR_APM821XX_NO_HALF_DUPLEX	0x00001000
> 
>  /* Right now, we don't quite handle the always/possible masks on the
>   * most optimal way as we don't have a way to say something like
> @@ -353,7 +360,9 @@ enum {
>  	    EMAC_FTR_NO_FLOW_CONTROL_40x |
>  #endif
>  	EMAC_FTR_460EX_PHY_CLK_FIX |
> -	EMAC_FTR_440EP_PHY_CLK_FIX,
> +	EMAC_FTR_440EP_PHY_CLK_FIX |
> +	EMAC_APM821XX_REQ_JUMBO_FRAME_SIZE |
> +	EMAC_FTR_APM821XX_NO_HALF_DUPLEX,
>  };
> 
>  static inline int emac_has_feature(struct emac_instance *dev,
> diff --git a/drivers/net/ethernet/ibm/emac/emac.h
> b/drivers/net/ethernet/ibm/emac/emac.h index 1568278..36bcd69 100644
> --- a/drivers/net/ethernet/ibm/emac/emac.h
> +++ b/drivers/net/ethernet/ibm/emac/emac.h
> @@ -212,7 +212,10 @@ struct emac_regs {
>  #define EMAC4_RMR_RFAF_64_1024		0x00000006
>  #define EMAC4_RMR_RFAF_128_2048		0x00000007
>  #define EMAC4_RMR_BASE			EMAC4_RMR_RFAF_128_2048
> -
> +#if defined(CONFIG_APM821xx)
> +#define EMAC4_RMR_MJS_MASK              0x0001fff8
> +#define EMAC4_RMR_MJS(s)                (((s) << 3) & EMAC4_RMR_MJS_MASK)
> +#endif

Is this "#if defined" really needed? If not, I suggest you drop it.

Thanks,
Stefan
