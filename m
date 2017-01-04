From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH v3 3/3] stmmac: adding new glue driver dwmac-dwc-qos-eth
Date: Wed, 4 Jan 2017 17:27:12 +0100
Message-ID: <73fee797-7496-08d5-835f-eb0ad3f1c3aa@axis.com>
References: <cover.1483546363.git.jpinto@synopsys.com>
 <f72953efa2d6a42975b553a6b517c63480f4650b.1483546363.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <larper@axis.com>, <swarren@nvidia.com>, <treding@nvidia.com>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:58486 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968643AbdADQ1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 11:27:16 -0500
In-Reply-To: <f72953efa2d6a42975b553a6b517c63480f4650b.1483546363.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested-by: Niklas Cassel <niklas.cassel@axis.com>

On 01/04/2017 05:22 PM, Joao Pinto wrote:
> This patch adds a new glue driver called dwmac-dwc-qos-eth which
> was based in the dwc_eth_qos as is. To assure retro-compatibility a slight
> tweak was also added to stmmac_platform.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v2 -> v3:
> - Nothing changed, just to keep up patch set version
> changes v1 -> v2:
> - WOL was not declared in the new glue driver
> - clocks were switched and now fixed (apb_pclk and phy_ref_clk)
>
>  .../bindings/net/snps,dwc-qos-ethernet.txt         |   3 +
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 +
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 200 +++++++++++++++++++++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  15 +-
>  5 files changed, 225 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>
> diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> index d93f71c..21d27aa 100644
> --- a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> +++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
> @@ -1,5 +1,8 @@
>  * Synopsys DWC Ethernet QoS IP version 4.10 driver (GMAC)
>  
> +This binding is deprecated, but it continues to be supported, but new
> +features should be preferably added to the stmmac binding document.
> +
>  This binding supports the Synopsys Designware Ethernet QoS (Quality Of Service)
>  IP block. The IP supports multiple options for bus type, clocking and reset
>  structure, and feature list. Consequently, a number of properties and list
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index ab66248..99594e3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -29,6 +29,15 @@ config STMMAC_PLATFORM
>  
>  if STMMAC_PLATFORM
>  
> +config DWMAC_DWC_QOS_ETH
> +	tristate "Support for snps,dwc-qos-ethernet.txt DT binding."
> +	select PHYLIB
> +	select CRC32
> +	select MII
> +	depends on OF && HAS_DMA
> +	help
> +	  Support for chips using the snps,dwc-qos-ethernet.txt DT binding.
> +
>  config DWMAC_GENERIC
>  	tristate "Generic driver for DWMAC"
>  	default STMMAC_PLATFORM
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index 8f83a86..700c603 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -16,6 +16,7 @@ obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
>  obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
>  obj-$(CONFIG_DWMAC_STM32)	+= dwmac-stm32.o
>  obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
> +obj-$(CONFIG_DWMAC_DWC_QOS_ETH)	+= dwmac-dwc-qos-eth.o
>  obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
>  stmmac-platform-objs:= stmmac_platform.o
>  dwmac-altr-socfpga-objs := altr_tse_pcs.o dwmac-socfpga.o
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> new file mode 100644
> index 0000000..4532a7c
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> @@ -0,0 +1,200 @@
> +/*
> + * Synopsys DWC Ethernet Quality-of-Service v4.10a linux driver
> + *
> + * Copyright (C) 2016 Joao Pinto <jpinto@synopsys.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program. If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/clk-provider.h>
> +#include <linux/device.h>
> +#include <linux/ethtool.h>
> +#include <linux/io.h>
> +#include <linux/ioport.h>
> +#include <linux/module.h>
> +#include <linux/of_net.h>
> +#include <linux/mfd/syscon.h>
> +#include <linux/platform_device.h>
> +#include <linux/stmmac.h>
> +
> +#include "stmmac_platform.h"
> +
> +static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
> +				   struct plat_stmmacenet_data *plat_dat)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	u32 burst_map = 0;
> +	u32 bit_index = 0;
> +	u32 a_index = 0;
> +
> +	if (!plat_dat->axi) {
> +		plat_dat->axi = kzalloc(sizeof(struct stmmac_axi), GFP_KERNEL);
> +
> +		if (!plat_dat->axi)
> +			return -ENOMEM;
> +	}
> +
> +	plat_dat->axi->axi_lpi_en = of_property_read_bool(np, "snps,en-lpi");
> +	if (of_property_read_u32(np, "snps,write-requests",
> +				 &plat_dat->axi->axi_wr_osr_lmt)) {
> +		/**
> +		 * Since the register has a reset value of 1, if property
> +		 * is missing, default to 1.
> +		 */
> +		plat_dat->axi->axi_wr_osr_lmt = 1;
> +	} else {
> +		/**
> +		 * If property exists, to keep the behavior from dwc_eth_qos,
> +		 * subtract one after parsing.
> +		 */
> +		plat_dat->axi->axi_wr_osr_lmt--;
> +	}
> +
> +	if (of_property_read_u32(np, "read,read-requests",
> +				 &plat_dat->axi->axi_rd_osr_lmt)) {
> +		/**
> +		 * Since the register has a reset value of 1, if property
> +		 * is missing, default to 1.
> +		 */
> +		plat_dat->axi->axi_rd_osr_lmt = 1;
> +	} else {
> +		/**
> +		 * If property exists, to keep the behavior from dwc_eth_qos,
> +		 * subtract one after parsing.
> +		 */
> +		plat_dat->axi->axi_rd_osr_lmt--;
> +	}
> +	of_property_read_u32(np, "snps,burst-map", &burst_map);
> +
> +	/* converts burst-map bitmask to burst array */
> +	for (bit_index = 0; bit_index < 7; bit_index++) {
> +		if (burst_map & (1 << bit_index)) {
> +			switch (bit_index) {
> +			case 0:
> +			plat_dat->axi->axi_blen[a_index] = 4; break;
> +			case 1:
> +			plat_dat->axi->axi_blen[a_index] = 8; break;
> +			case 2:
> +			plat_dat->axi->axi_blen[a_index] = 16; break;
> +			case 3:
> +			plat_dat->axi->axi_blen[a_index] = 32; break;
> +			case 4:
> +			plat_dat->axi->axi_blen[a_index] = 64; break;
> +			case 5:
> +			plat_dat->axi->axi_blen[a_index] = 128; break;
> +			case 6:
> +			plat_dat->axi->axi_blen[a_index] = 256; break;
> +			default:
> +			break;
> +			}
> +			a_index++;
> +		}
> +	}
> +
> +	/* dwc-qos needs GMAC4, AAL, TSO and PMT */
> +	plat_dat->has_gmac4 = 1;
> +	plat_dat->dma_cfg->aal = 1;
> +	plat_dat->tso_en = 1;
> +	plat_dat->pmt = 1;
> +
> +	return 0;
> +}
> +
> +static int dwc_eth_dwmac_probe(struct platform_device *pdev)
> +{
> +	struct plat_stmmacenet_data *plat_dat;
> +	struct stmmac_resources stmmac_res;
> +	struct resource *res;
> +	int ret;
> +
> +	/**
> +	 * Since stmmac_platform supports name IRQ only, basic platform
> +	 * resource initialization is done in the glue logic.
> +	 */
> +	stmmac_res.irq = platform_get_irq(pdev, 0);
> +	if (stmmac_res.irq < 0) {
> +		if (stmmac_res.irq != -EPROBE_DEFER) {
> +			dev_err(&pdev->dev,
> +				"IRQ configuration information not found\n");
> +		}
> +		return stmmac_res.irq;
> +	}
> +	stmmac_res.wol_irq = stmmac_res.irq;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	stmmac_res.addr = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(stmmac_res.addr))
> +		return PTR_ERR(stmmac_res.addr);
> +
> +	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
> +	if (IS_ERR(plat_dat))
> +		return PTR_ERR(plat_dat);
> +
> +	plat_dat->stmmac_clk = devm_clk_get(&pdev->dev, "apb_pclk");
> +	if (IS_ERR(plat_dat->stmmac_clk)) {
> +		dev_err(&pdev->dev, "apb_pclk clock not found.\n");
> +		ret = PTR_ERR(plat_dat->stmmac_clk);
> +		plat_dat->stmmac_clk = NULL;
> +		goto err_remove_config_dt;
> +	}
> +	clk_prepare_enable(plat_dat->stmmac_clk);
> +
> +	plat_dat->pclk = devm_clk_get(&pdev->dev, "phy_ref_clk");
> +	if (IS_ERR(plat_dat->pclk)) {
> +		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
> +		ret = PTR_ERR(plat_dat->pclk);
> +		plat_dat->pclk = NULL;
> +		goto err_out_clk_dis_phy;
> +	}
> +	clk_prepare_enable(plat_dat->pclk);
> +
> +	ret = dwc_eth_dwmac_config_dt(pdev, plat_dat);
> +	if (ret)
> +		goto err_out_clk_dis_aper;
> +
> +	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
> +	if (ret)
> +		goto err_out_clk_dis_aper;
> +
> +	return 0;
> +
> +err_out_clk_dis_aper:
> +	clk_disable_unprepare(plat_dat->pclk);
> +err_out_clk_dis_phy:
> +	clk_disable_unprepare(plat_dat->stmmac_clk);
> +err_remove_config_dt:
> +	stmmac_remove_config_dt(pdev, plat_dat);
> +
> +	return ret;
> +}
> +
> +static int dwc_eth_dwmac_remove(struct platform_device *pdev)
> +{
> +	return stmmac_pltfr_remove(pdev);
> +}
> +
> +static const struct of_device_id dwc_eth_dwmac_match[] = {
> +	{ .compatible = "snps,dwc-qos-ethernet-4.10", },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, dwc_eth_dwmac_match);
> +
> +static struct platform_driver dwc_eth_dwmac_driver = {
> +	.probe  = dwc_eth_dwmac_probe,
> +	.remove = dwc_eth_dwmac_remove,
> +	.driver = {
> +		.name           = "dwc-eth-dwmac",
> +		.of_match_table = dwc_eth_dwmac_match,
> +	},
> +};
> +module_platform_driver(dwc_eth_dwmac_driver);
> +
> +MODULE_AUTHOR("Joao Pinto <jpinto@synopsys.com>");
> +MODULE_DESCRIPTION("Synopsys DWC Ethernet Quality-of-Service v4.10a driver");
> +MODULE_LICENSE("GPL v2");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 4e44f9c..00c0f8d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -181,10 +181,19 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>  		mdio = false;
>  	}
>  
> -	/* If snps,dwmac-mdio is passed from DT, always register the MDIO */
> -	for_each_child_of_node(np, plat->mdio_node) {
> -		if (of_device_is_compatible(plat->mdio_node, "snps,dwmac-mdio"))
> +	/* exception for dwmac-dwc-qos-eth glue logic */
> +	if (of_device_is_compatible(np, "snps,dwc-qos-ethernet-4.10")) {
> +		plat->mdio_node = of_get_child_by_name(np, "mdio");
> +	} else {
> +		/**
> +		 * If snps,dwmac-mdio is passed from DT, always register
> +		 * the MDIO
> +		 */
> +		for_each_child_of_node(np, plat->mdio_node) {
> +			if (of_device_is_compatible(plat->mdio_node,
> +						    "snps,dwmac-mdio"))
>  			break;
> +		}
>  	}
>  
>  	if (plat->mdio_node) {
