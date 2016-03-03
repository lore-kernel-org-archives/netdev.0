From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: Fix 'eth0: No PHY found' regression
Date: Thu, 3 Mar 2016 09:02:39 +0100
Message-ID: <56D7EF9F.6070900@st.com>
References: <1456762702-23713-1-git-send-email-gabriel.fernandez@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<alexandre.torgue@st.com>, <maxime.coquelin@st.com>
To: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	Phil Reid <preid@electromag.com.au>, <davem@davemloft.net>,
	Joachim Eastwood <manabian@gmail.com>,
	Vince Bridgers <vbridger@opensource.altera.com>,
	Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456762702-23713-1-git-send-email-gabriel.fernandez@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/29/2016 5:18 PM, Gabriel Fernandez wrote:
> This patch manages the case when you have an Ethernet MAC with
> a "fixed link", and not connected to a normal MDIO-managed PHY device.
>
> The test of phy_bus_name was not helpful because it was never affected
> and replaced by the mdio test node.
>
> Signed-off-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c     | 11 +----------
>   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  9 ++++++++-
>   include/linux/stmmac.h                                |  1 +
>   3 files changed, 10 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 0faf163..efb54f3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -199,21 +199,12 @@ int stmmac_mdio_register(struct net_device *ndev)
>   	struct stmmac_priv *priv = netdev_priv(ndev);
>   	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
>   	int addr, found;
> -	struct device_node *mdio_node = NULL;
> -	struct device_node *child_node = NULL;
> +	struct device_node *mdio_node = priv->plat->mdio_node;
>
>   	if (!mdio_bus_data)
>   		return 0;
>
>   	if (IS_ENABLED(CONFIG_OF)) {
> -		for_each_child_of_node(priv->device->of_node, child_node) {
> -			if (of_device_is_compatible(child_node,
> -						    "snps,dwmac-mdio")) {
> -				mdio_node = child_node;
> -				break;
> -			}
> -		}
> -
>   		if (mdio_node) {
>   			netdev_dbg(ndev, "FOUND MDIO subnode\n");
>   		} else {
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 6a52fa1..4514ba7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -110,6 +110,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>   	struct device_node *np = pdev->dev.of_node;
>   	struct plat_stmmacenet_data *plat;
>   	struct stmmac_dma_cfg *dma_cfg;
> +	struct device_node *child_node = NULL;
>
>   	plat = devm_kzalloc(&pdev->dev, sizeof(*plat), GFP_KERNEL);
>   	if (!plat)
> @@ -140,13 +141,19 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>   		plat->phy_node = of_node_get(np);
>   	}
>
> +	for_each_child_of_node(np, child_node)
> +		if (of_device_is_compatible(child_node,	"snps,dwmac-mdio")) {
> +			plat->mdio_node = child_node;
> +			break;
> +		}
> +
>   	/* "snps,phy-addr" is not a standard property. Mark it as deprecated
>   	 * and warn of its use. Remove this when phy node support is added.
>   	 */
>   	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
>   		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
>
> -	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_name)
> +	if ((plat->phy_node && !of_phy_is_fixed_link(np)) || !plat->mdio_node)
>   		plat->mdio_bus_data = NULL;
>   	else
>   		plat->mdio_bus_data =
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index eead8ab..881a79d 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -100,6 +100,7 @@ struct plat_stmmacenet_data {
>   	int interface;
>   	struct stmmac_mdio_bus_data *mdio_bus_data;
>   	struct device_node *phy_node;
> +	struct device_node *mdio_node;
>   	struct stmmac_dma_cfg *dma_cfg;
>   	int clk_csr;
>   	int has_gmac;
>
