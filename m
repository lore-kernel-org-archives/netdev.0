From: Byungho An <bh74.an@samsung.com>
Subject: RE: [net-next.git 4/8] stmmac: initial support to manage pcs modes
Date: Sat, 30 Mar 2013 14:13:40 +0900
Message-ID: <000301ce2d05$57a153c0$06e3fb40$%an@samsung.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
 <1364308992-27929-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:26913 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab3C3FNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 01:13:43 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MKG000KKJUT8SD0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Sat, 30 Mar 2013 14:13:41 +0900 (KST)
In-reply-to: <1364308992-27929-5-git-send-email-peppe.cavallaro@st.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/26/2013 11:46 PM, Giuseppe CAVALLARO wrote:
> This patch adds the minimal support to manage the PCS
> modes (RGMII/SGMII) and restart the ANE.
> Both TBI and RTBI are not yet supported.
> 
[snip]
.
>  /**
>   * stmmac_init_phy - PHY initialization
>   * @dev: net device structure
> @@ -1141,10 +1159,13 @@ static int stmmac_open(struct net_device *dev)
> 
>  	stmmac_check_ether_addr(priv);
> 
> -	ret = stmmac_init_phy(dev);
> -	if (unlikely(ret)) {
> -		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__,
> ret);
> -		goto open_error;
> +	if (!priv->pcs) {
> +		ret = stmmac_init_phy(dev);
> +		if (ret) {
> +			pr_err("%s: Cannot attach to PHY (error: %d)\n",
> +			       __func__, ret);
> +			goto open_error;
> +		}
>  	}
> 
I think, even though SGMII do auto-negotiation with phy, stmmac_init_phy
function is needed. In this condition "if (!priv->pcs)", SGMII platform
can't attach phy.
IMO, it is same in case of stmmac_mdio_register(ndev).
In my platform, I modified this condition for SGMII like below.
	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs STMMAC_PCS_TBI &&
priv->pcs != STMMAC_PCS_RTBI)

>  	/* Create and initialize the TX/RX descriptors chains. */
> @@ -1233,7 +1254,12 @@ static int stmmac_open(struct net_device *dev)
>  		phy_start(priv->phydev);
> 
>  	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
> -	priv->eee_enabled = stmmac_eee_init(priv);
> +
> +	/* Using PCS we cannot dial with the phy registers at this stage
> +	 * so we do not support extra feature like EEE.
> +	 */
> +	if (!priv->pcs)
> +		priv->eee_enabled = stmmac_eee_init(priv);
> 
>  	stmmac_init_tx_coalesce(priv);
> 
> @@ -1242,6 +1268,9 @@ static int stmmac_open(struct net_device *dev)
>  		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
>  	}
> 
> +	if (priv->pcs && priv->hw->mac->ctrl_ane)
> +		priv->hw->mac->ctrl_ane(priv->ioaddr, 0);
> +
>  	napi_enable(&priv->napi);
>  	netif_start_queue(dev);
> 
> @@ -2225,12 +2254,16 @@ struct stmmac_priv *stmmac_dvr_probe(struct device
> *device,
>  	else
>  		priv->clk_csr = priv->plat->clk_csr;
> 
> -	/* MDIO bus Registration */
> -	ret = stmmac_mdio_register(ndev);
> -	if (ret < 0) {
> -		pr_debug("%s: MDIO bus (id: %d) registration failed",
> -			 __func__, priv->plat->bus_id);
> -		goto error_mdio_register;
> +	stmmac_check_pcs_mode(priv);
> +
> +	if (!priv->pcs) {
> +		/* MDIO bus Registration */
> +		ret = stmmac_mdio_register(ndev);
> +		if (ret < 0) {
> +			pr_debug("%s: MDIO bus (id: %d) registration
failed",
> +				 __func__, priv->plat->bus_id);
> +			goto error_mdio_register;
> +		}
>  	}
> 
>  	return priv;
> @@ -2263,7 +2296,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
>  	priv->hw->dma->stop_tx(priv->ioaddr);
> 
>  	stmmac_set_mac(priv->ioaddr, false);
> -	stmmac_mdio_unregister(ndev);
> +	if (!priv->pcs)
> +		stmmac_mdio_unregister(ndev);
>  	netif_carrier_off(ndev);
>  	unregister_netdev(ndev);
>  	free_netdev(ndev);
> --
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
