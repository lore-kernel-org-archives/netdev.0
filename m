From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 3/3] stmmac: adding new glue driver dwmac-dwc-qos-eth
Date: Wed, 4 Jan 2017 11:49:36 +0000
Message-ID: <7c299cf5-bba6-8fb5-089c-bb584ec52850@synopsys.com>
References: <cover.1483372523.git.jpinto@synopsys.com>
 <b8d09f96a128107ac64f65d1d27b7693e7ddbb3e.1483372523.git.jpinto@synopsys.com>
 <9bd69052-c5bb-731c-c01e-de42d1968718@axis.com>
 <899bbfca-3596-c239-a1e7-baa3e057e8f0@synopsys.com>
 <e7436459-cd90-9fc9-b65e-2c9a2f4d7d37@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <larper@axis.com>, <swarren@nvidia.com>, <treding@nvidia.com>,
        <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:57662 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965875AbdADLtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 06:49:46 -0500
In-Reply-To: <e7436459-cd90-9fc9-b65e-2c9a2f4d7d37@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 11:24 AM de 1/4/2017, Niklas Cassel escreveu:
> 
> 
> On 01/04/2017 12:08 PM, Joao Pinto wrote:
>> Hi Niklas,
>>
>> Às 10:59 AM de 1/4/2017, Niklas Cassel escreveu:
>>> Hello Joao
>>>
>>> I just tested this series using the dwc_eth_qos DT bindings.
>>> Good work!
>>>
>>> Unfortunately I get the following error:
>>>
>>> <3>[   12.032463] dwc-eth-dwmac f8010000.ethernet eth0: stmmac_open: ERROR: allocating the WoL IRQ -1098801248 (-22)
>>>
>>>
>>> This appears to be because of a corner case in stmmac_platform.c
>>> where wol_irq can differ from the normal irq.
>>>
>>> Adding the following one liner fixes the problem:
>>>
>>>
>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>> @@ -125,6 +125,7 @@ static int dwc_eth_dwmac_probe(struct platform_device *pdev)
>>>                 }
>>>                 return stmmac_res.irq;
>>>         }
>>> +       stmmac_res.wol_irq = stmmac_res.irq;
>>>  
>>>         res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>>         stmmac_res.addr = devm_ioremap_resource(&pdev->dev, res);
>>>
>> Ok, I'll add this fix to the patch and give a check to the clks.
>> I already sent a v1 patch set to net-dev, and I am now going to generate v2 so
>> it would be great to have your tested.by tag to push it faster :) Thanks!
> 
> Send your V2, and I will test it, and reply with a Tested-by tag.
> I can't reply with a Tested-by tag on V1, since it gives an
> error during open.
> 
> If I reply with a Tested-by tag, on your V2, patchwork
> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.ozlabs.org_project_netdev_list_&d=DgID-g&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=Ne_JFvbqIwFj_Tokwm6Yv1pv3wETnoD3iG7TjxJqLaQ&s=7hU48UexRw1mb7Y3V4ly3tX0yErTXUW_k4gSZVGe4yE&e= 
> will append it to the patch automatically.
> Since Dave fetches patches from patchwork,
> it will be there when it's time to be applied.

Ok, great! Just sent you v2. Thanks.

> 
>>
>>>
>>>
>>> I have one comment about clocks interleaved as well
>>>
>>>
>>>
>>> On 01/04/2017 10:44 AM, Joao Pinto wrote:
>>>> This patch adds a new glue driver called dwmac-dwc-qos-eth which
>>>> was based in the dwc_eth_qos as is. To assure retro-compatibility a slight
>>>> tweak was also added to stmmac_platform.
>>>>
>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>> Reviewed-by: Lars Persson <larper@axis.com>
>>>> ---
>>>>  .../bindings/net/snps,dwc-qos-ethernet.txt         |   3 +
>>>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 +
>>>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>>>  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 199 +++++++++++++++++++++
>>>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  15 +-
>>>>  5 files changed, 224 insertions(+), 3 deletions(-)
>>>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>> index d93f71c..21d27aa 100644
>>>> --- a/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>> +++ b/Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>> @@ -1,5 +1,8 @@
>>>>  * Synopsys DWC Ethernet QoS IP version 4.10 driver (GMAC)
>>>>  
>>>> +This binding is deprecated, but it continues to be supported, but new
>>>> +features should be preferably added to the stmmac binding document.
>>>> +
>>>>  This binding supports the Synopsys Designware Ethernet QoS (Quality Of Service)
>>>>  IP block. The IP supports multiple options for bus type, clocking and reset
>>>>  structure, and feature list. Consequently, a number of properties and list
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
>>>> index ab66248..99594e3 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
>>>> @@ -29,6 +29,15 @@ config STMMAC_PLATFORM
>>>>  
>>>>  if STMMAC_PLATFORM
>>>>  
>>>> +config DWMAC_DWC_QOS_ETH
>>>> +	tristate "Support for snps,dwc-qos-ethernet.txt DT binding."
>>>> +	select PHYLIB
>>>> +	select CRC32
>>>> +	select MII
>>>> +	depends on OF && HAS_DMA
>>>> +	help
>>>> +	  Support for chips using the snps,dwc-qos-ethernet.txt DT binding.
>>>> +
>>>>  config DWMAC_GENERIC
>>>>  	tristate "Generic driver for DWMAC"
>>>>  	default STMMAC_PLATFORM
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
>>>> index 8f83a86..700c603 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
>>>> @@ -16,6 +16,7 @@ obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
>>>>  obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
>>>>  obj-$(CONFIG_DWMAC_STM32)	+= dwmac-stm32.o
>>>>  obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
>>>> +obj-$(CONFIG_DWMAC_DWC_QOS_ETH)	+= dwmac-dwc-qos-eth.o
>>>>  obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
>>>>  stmmac-platform-objs:= stmmac_platform.o
>>>>  dwmac-altr-socfpga-objs := altr_tse_pcs.o dwmac-socfpga.o
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>>> new file mode 100644
>>>> index 0000000..8a6ac06
>>>> --- /dev/null
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>>>> @@ -0,0 +1,199 @@
>>>> +/*
>>>> + * Synopsys DWC Ethernet Quality-of-Service v4.10a linux driver
>>>> + *
>>>> + * Copyright (C) 2016 Joao Pinto <jpinto@synopsys.com>
>>>> + *
>>>> + * This program is free software; you can redistribute it and/or modify
>>>> + * it under the terms of the GNU General Public License version 2 as
>>>> + * published by the Free Software Foundation.
>>>> + *
>>>> + * You should have received a copy of the GNU General Public License
>>>> + * along with this program. If not, see <https://urldefense.proofpoint.com/v2/url?u=http-3A__www.gnu.org_licenses_&d=DgIC-g&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=DrobFP08nu4hh6e05EgeOl1xD34OacyiZ-be_GG829Q&s=WLSkpBK06KCu-_kvN305yE6YncNYcDG_Bk0pgqSBG1o&e=>.
>>>> + */
>>>> +
>>>> +#include <linux/clk.h>
>>>> +#include <linux/clk-provider.h>
>>>> +#include <linux/device.h>
>>>> +#include <linux/ethtool.h>
>>>> +#include <linux/io.h>
>>>> +#include <linux/ioport.h>
>>>> +#include <linux/module.h>
>>>> +#include <linux/of_net.h>
>>>> +#include <linux/mfd/syscon.h>
>>>> +#include <linux/platform_device.h>
>>>> +#include <linux/stmmac.h>
>>>> +
>>>> +#include "stmmac_platform.h"
>>>> +
>>>> +static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
>>>> +				   struct plat_stmmacenet_data *plat_dat)
>>>> +{
>>>> +	struct device_node *np = pdev->dev.of_node;
>>>> +	u32 burst_map = 0;
>>>> +	u32 bit_index = 0;
>>>> +	u32 a_index = 0;
>>>> +
>>>> +	if (!plat_dat->axi) {
>>>> +		plat_dat->axi = kzalloc(sizeof(struct stmmac_axi), GFP_KERNEL);
>>>> +
>>>> +		if (!plat_dat->axi)
>>>> +			return -ENOMEM;
>>>> +	}
>>>> +
>>>> +	plat_dat->axi->axi_lpi_en = of_property_read_bool(np, "snps,en-lpi");
>>>> +	if (of_property_read_u32(np, "snps,write-requests",
>>>> +				 &plat_dat->axi->axi_wr_osr_lmt)) {
>>>> +		/**
>>>> +		 * Since the register has a reset value of 1, if property
>>>> +		 * is missing, default to 1.
>>>> +		 */
>>>> +		plat_dat->axi->axi_wr_osr_lmt = 1;
>>>> +	} else {
>>>> +		/**
>>>> +		 * If property exists, to keep the behavior from dwc_eth_qos,
>>>> +		 * subtract one after parsing.
>>>> +		 */
>>>> +		plat_dat->axi->axi_wr_osr_lmt--;
>>>> +	}
>>>> +
>>>> +	if (of_property_read_u32(np, "read,read-requests",
>>>> +				 &plat_dat->axi->axi_rd_osr_lmt)) {
>>>> +		/**
>>>> +		 * Since the register has a reset value of 1, if property
>>>> +		 * is missing, default to 1.
>>>> +		 */
>>>> +		plat_dat->axi->axi_rd_osr_lmt = 1;
>>>> +	} else {
>>>> +		/**
>>>> +		 * If property exists, to keep the behavior from dwc_eth_qos,
>>>> +		 * subtract one after parsing.
>>>> +		 */
>>>> +		plat_dat->axi->axi_rd_osr_lmt--;
>>>> +	}
>>>> +	of_property_read_u32(np, "snps,burst-map", &burst_map);
>>>> +
>>>> +	/* converts burst-map bitmask to burst array */
>>>> +	for (bit_index = 0; bit_index < 7; bit_index++) {
>>>> +		if (burst_map & (1 << bit_index)) {
>>>> +			switch (bit_index) {
>>>> +			case 0:
>>>> +			plat_dat->axi->axi_blen[a_index] = 4; break;
>>>> +			case 1:
>>>> +			plat_dat->axi->axi_blen[a_index] = 8; break;
>>>> +			case 2:
>>>> +			plat_dat->axi->axi_blen[a_index] = 16; break;
>>>> +			case 3:
>>>> +			plat_dat->axi->axi_blen[a_index] = 32; break;
>>>> +			case 4:
>>>> +			plat_dat->axi->axi_blen[a_index] = 64; break;
>>>> +			case 5:
>>>> +			plat_dat->axi->axi_blen[a_index] = 128; break;
>>>> +			case 6:
>>>> +			plat_dat->axi->axi_blen[a_index] = 256; break;
>>>> +			default:
>>>> +			break;
>>>> +			}
>>>> +			a_index++;
>>>> +		}
>>>> +	}
>>>> +
>>>> +	/* dwc-qos needs GMAC4, AAL, TSO and PMT */
>>>> +	plat_dat->has_gmac4 = 1;
>>>> +	plat_dat->dma_cfg->aal = 1;
>>>> +	plat_dat->tso_en = 1;
>>>> +	plat_dat->pmt = 1;
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int dwc_eth_dwmac_probe(struct platform_device *pdev)
>>>> +{
>>>> +	struct plat_stmmacenet_data *plat_dat;
>>>> +	struct stmmac_resources stmmac_res;
>>>> +	struct resource *res;
>>>> +	int ret;
>>>> +
>>>> +	/**
>>>> +	 * Since stmmac_platform supports name IRQ only, basic platform
>>>> +	 * resource initialization is done in the glue logic.
>>>> +	 */
>>>> +	stmmac_res.irq = platform_get_irq(pdev, 0);
>>>> +	if (stmmac_res.irq < 0) {
>>>> +		if (stmmac_res.irq != -EPROBE_DEFER) {
>>>> +			dev_err(&pdev->dev,
>>>> +				"IRQ configuration information not found\n");
>>>> +		}
>>>> +		return stmmac_res.irq;
>>>> +	}
>>>> +
>>>> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>>> +	stmmac_res.addr = devm_ioremap_resource(&pdev->dev, res);
>>>> +	if (IS_ERR(stmmac_res.addr))
>>>> +		return PTR_ERR(stmmac_res.addr);
>>>> +
>>>> +	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
>>>> +	if (IS_ERR(plat_dat))
>>>> +		return PTR_ERR(plat_dat);
>>>> +
>>>> +	plat_dat->stmmac_clk = devm_clk_get(&pdev->dev, "phy_ref_clk");
>>>> +	if (IS_ERR(plat_dat->stmmac_clk)) {
>>>> +		dev_err(&pdev->dev, "apb_pclk clock not found.\n");
>>> Error message does not match the devm_clk_get.
>>>
>>> Looking at synopsys/dwc_eth_qos.c
>>> phy_ref_clk is just a dummy, used for verbosity.
>>> apb_pclk is the clock which is actually used for setting csr etc.
>>>
>>> So it should be
>>>
>>> plat_dat->stmmac_clk = devm_clk_get(&pdev->dev, "apb_pclk");
>>>
>>>
>>> So that way the warning is already correct :)
>>>
>>>
>>>
>>>> +		ret = PTR_ERR(plat_dat->stmmac_clk);
>>>> +		plat_dat->stmmac_clk = NULL;
>>>> +		goto err_remove_config_dt;
>>>> +	}
>>>> +	clk_prepare_enable(plat_dat->stmmac_clk);
>>>> +
>>>> +	plat_dat->pclk = devm_clk_get(&pdev->dev, "apb_pclk");
>>>> +	if (IS_ERR(plat_dat->pclk)) {
>>>> +		dev_err(&pdev->dev, "phy_ref_clk clock not found.\n");
>>> Error message does not match the devm_clk_get,
>>> however, since this should be
>>>
>>> plat_dat->pclk = devm_clk_get(&pdev->dev, "phy_ref_clk");
>>>
>>> the warning is correct :)
>>>
>>>> +		ret = PTR_ERR(plat_dat->pclk);
>>>> +		plat_dat->pclk = NULL;
>>>> +		goto err_out_clk_dis_phy;
>>>> +	}
>>>> +	clk_prepare_enable(plat_dat->pclk);
>>>> +
>>>> +	ret = dwc_eth_dwmac_config_dt(pdev, plat_dat);
>>>> +	if (ret)
>>>> +		goto err_out_clk_dis_aper;
>>>> +
>>>> +	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
>>>> +	if (ret)
>>>> +		goto err_out_clk_dis_aper;
>>>> +
>>>> +	return 0;
>>>> +
>>>> +err_out_clk_dis_aper:
>>>> +	clk_disable_unprepare(plat_dat->pclk);
>>>> +err_out_clk_dis_phy:
>>>> +	clk_disable_unprepare(plat_dat->stmmac_clk);
>>>> +err_remove_config_dt:
>>>> +	stmmac_remove_config_dt(pdev, plat_dat);
>>>> +
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +static int dwc_eth_dwmac_remove(struct platform_device *pdev)
>>>> +{
>>>> +	return stmmac_pltfr_remove(pdev);
>>>> +}
>>>> +
>>>> +static const struct of_device_id dwc_eth_dwmac_match[] = {
>>>> +	{ .compatible = "snps,dwc-qos-ethernet-4.10", },
>>>> +	{ }
>>>> +};
>>>> +MODULE_DEVICE_TABLE(of, dwc_eth_dwmac_match);
>>>> +
>>>> +static struct platform_driver dwc_eth_dwmac_driver = {
>>>> +	.probe  = dwc_eth_dwmac_probe,
>>>> +	.remove = dwc_eth_dwmac_remove,
>>>> +	.driver = {
>>>> +		.name           = "dwc-eth-dwmac",
>>>> +		.of_match_table = dwc_eth_dwmac_match,
>>>> +	},
>>>> +};
>>>> +module_platform_driver(dwc_eth_dwmac_driver);
>>>> +
>>>> +MODULE_AUTHOR("Joao Pinto <jpinto@synopsys.com>");
>>>> +MODULE_DESCRIPTION("Synopsys DWC Ethernet Quality-of-Service v4.10a driver");
>>>> +MODULE_LICENSE("GPL v2");
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> index 4e44f9c..00c0f8d 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>>> @@ -181,10 +181,19 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>>>>  		mdio = false;
>>>>  	}
>>>>  
>>>> -	/* If snps,dwmac-mdio is passed from DT, always register the MDIO */
>>>> -	for_each_child_of_node(np, plat->mdio_node) {
>>>> -		if (of_device_is_compatible(plat->mdio_node, "snps,dwmac-mdio"))
>>>> +	/* exception for dwmac-dwc-qos-eth glue logic */
>>>> +	if (of_device_is_compatible(np, "snps,dwc-qos-ethernet-4.10")) {
>>>> +		plat->mdio_node = of_get_child_by_name(np, "mdio");
>>>> +	} else {
>>>> +		/**
>>>> +		 * If snps,dwmac-mdio is passed from DT, always register
>>>> +		 * the MDIO
>>>> +		 */
>>>> +		for_each_child_of_node(np, plat->mdio_node) {
>>>> +			if (of_device_is_compatible(plat->mdio_node,
>>>> +						    "snps,dwmac-mdio"))
>>>>  			break;
>>>> +		}
>>>>  	}
>>>>  
>>>>  	if (plat->mdio_node) {
> 
