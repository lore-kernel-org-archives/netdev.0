From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] net: stmac: add gmac autonet set for SGMII, TBI,
 and RTBI
Date: Wed, 09 Jan 2013 09:34:13 +0100
Message-ID: <50ED2B85.5030602@st.com>
References: <000901cdedf8$dfaf4390$9f0dcab0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:33795 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817Ab3AIIez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 03:34:55 -0500
In-Reply-To: <000901cdedf8$dfaf4390$9f0dcab0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Byungho

On 1/9/2013 12:35 AM, Byungho An wrote:
>
> This patch adds gmac autoneg set function for SGMII, TBI,
> and RTBI interface. In case of PHY's autoneg is set, gmac's
> autoneg enable bit should set. After checking phy's autoneg
> if phydev's autoneg is '1' gmac's ANE bit set for those
> interface.
>

I suppose I have to not look at this patch but I have to directly look 
at the series:

[PATCH v2 1/3] net: stmac: add gmac autonet set for SGMII, TBI, and RTBI
[PATCH v2 2/3] net: stmmac: add autoneg complete irq
[PATCH v2 3/3] net: stmmac: add gmac autonego set for ethtool support

At any rate, I'm looking at them and they actually sound better than the 
previous ones.
Pls use stmmac instead of stmac.
Also these patches add a new functionality and, IMO, they should be done 
for net-next. In this case, pls verify if the patches are for this 
branch and add in the subject net-next.

I'll come back with further details asap.

BR
Peppe

> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/common.h         |    1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |   11 +++++++++++
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    9 +++++++++
>   3 files changed, 21 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
> b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 186d148..72ba769 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -344,6 +344,7 @@ struct stmmac_ops {
>   	void (*reset_eee_mode) (void __iomem *ioaddr);
>   	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
>   	void (*set_eee_pls) (void __iomem *ioaddr, int link);
> +	void (*set_autoneg) (void __iomem *ioaddr);
>   };
>
>   struct mac_link {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> index bfe0226..a0737b39 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> @@ -297,6 +297,16 @@ static void  dwmac1000_set_eee_timer(void __iomem
> *ioaddr, int ls, int tw)
>   	writel(value, ioaddr + LPI_TIMER_CTRL);
>   }
>
> +static void dwmac1000_set_autoneg(void __iomem *ioaddr)
> +{
> +	u32 value;
> +
> +	value = readl(ioaddr + GMAC_AN_CTRL);
> +	value |= 0x1000;
> +	writel(value, ioaddr + GMAC_AN_CTRL);
> +}
> +
> +
>   static const struct stmmac_ops dwmac1000_ops = {
>   	.core_init = dwmac1000_core_init,
>   	.rx_ipc = dwmac1000_rx_ipc_enable,
> @@ -311,6 +321,7 @@ static const struct stmmac_ops dwmac1000_ops = {
>   	.reset_eee_mode =  dwmac1000_reset_eee_mode,
>   	.set_eee_timer =  dwmac1000_set_eee_timer,
>   	.set_eee_pls =  dwmac1000_set_eee_pls,
> +	.set_autoneg =  dwmac1000_set_autoneg,
>   };
>
>   struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index f07c061..3e28934 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1007,6 +1007,7 @@ static int stmmac_open(struct net_device *dev)
>   {
>   	struct stmmac_priv *priv = netdev_priv(dev);
>   	int ret;
> +	int interface = priv->plat->interface;
>
>   	clk_prepare_enable(priv->stmmac_clk);
>
> @@ -1041,6 +1042,14 @@ static int stmmac_open(struct net_device *dev)
>   	/* Initialize the MAC Core */
>   	priv->hw->mac->core_init(priv->ioaddr);
>
> +	/* If phy autoneg is on, set gmac autoneg for SGMII, TBI and RTBI*/
> +	if((interface == PHY_INTERFACE_MODE_SGMII) ||
> +		(interface == PHY_INTERFACE_MODE_TBI) ||
> +		(interface == PHY_INTERFACE_MODE_RTBI)) {
> +		if (priv->phydev->autoneg)
> +			priv->hw->mac->set_autoneg(priv->ioaddr);
> +	}
> +
>   	/* Request the IRQ lines */
>   	ret = request_irq(dev->irq, stmmac_interrupt,
>   			 IRQF_SHARED, dev->name, dev);
>
