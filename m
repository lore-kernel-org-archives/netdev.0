From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: [PATCH 1/5 v2] mv643xx_eth: add Device Tree bindings
Date: Thu, 4 Apr 2013 23:29:06 +0200
Message-ID: <20130404212906.GA25904@schnuecks.de>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1365071235-11611-2-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	moinejf@free.fr, jason@lakedaemon.net, andrew@lunn.ch,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	rob.herring@calxeda.com, grant.likely@secretlab.ca,
	jogo@openwrt.org, buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:61697 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764789Ab3DDV3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:29:11 -0400
Received: by mail-bk0-f52.google.com with SMTP id it16so1741120bkc.25
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 14:29:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1365071235-11611-2-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

On Thu, Apr 04, 2013 at 12:27:11PM +0200, Florian Fainelli wrote:
> This patch adds Device Tree bindings following the already defined
> bindings at Documentation/devicetree/bindings/marvell.txt. The binding
> documentation is also enhanced with new optionnal properties required
> for supporting certain devices (RX/TX queue and SRAM). Since we now have
> proper support for the orion MDIO bus driver, there is no need to fiddle
> around with device tree phandles. PHY-less (MAC connected to switch)
> configurations are supported by not specifying any phy phandle for an
> ethernet node.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> - properly ifdef of_platform_bus_probe with CONFIG_OF
> - handle of_platform_bus_probe errors and cleanup accordingly
> - use of_property_read_u32 where applicable
> - parse "duplex" and "speed" property in PHY-less configuration
> 
>  Documentation/devicetree/bindings/marvell.txt |   25 +++++-
>  drivers/net/ethernet/marvell/mv643xx_eth.c    |  120 ++++++++++++++++++++++++-
>  2 files changed, 140 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
> index f1533d9..e70a013 100644
> --- a/Documentation/devicetree/bindings/marvell.txt
> +++ b/Documentation/devicetree/bindings/marvell.txt
> @@ -112,9 +112,14 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
>     Required properties:
>       - #address-cells : <1>
>       - #size-cells : <0>
> -     - compatible : "marvell,mv64360-eth-block"
> +     - compatible : "marvell,mv64360-eth-block", "marvell,mv64360-eth-group",
> +		    "marvell,mv643xx-eth-block"
>       - reg : Offset and length of the register set for this block
>  
> +   Optional properties:
> +     - tx-csum-limit : Hardware limit above which transmit checksumming
> +                       is disabled.
> +
>     Example Discovery Ethernet block node:
>       ethernet-block@2000 {
>  	     #address-cells = <1>;
> @@ -130,7 +135,7 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
>  
>     Required properties:
>       - device_type : Should be "network".
> -     - compatible : Should be "marvell,mv64360-eth".
> +     - compatible : Should be "marvell,mv64360-eth", "marvell,mv643xx-eth".
>       - reg : Should be <0>, <1>, or <2>, according to which registers
>         within the silicon block the device uses.
>       - interrupts : <a> where a is the interrupt number for the port.
> @@ -140,6 +145,22 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
>         controller.
>       - local-mac-address : 6 bytes, MAC address
>  
> +   Optional properties:
> +     - clocks : Phandle to the clock control device and gate bit
> +     - clock-names : String describing the clock gate bit
> +     - speed : Speed to force the link (10, 100, 1000), used when no
> +               phy property is defined
> +     - duplex : Duplex to force the link (0: half, 1: full), used when no
> +               phy property is defined
> +     - rx-queue-count : number of RX queues to use
> +     - tx-queue-count : number of TX queues to use
> +     - rx-queue-size : size of the RX queue (in bytes)
> +     - tx-queue-size : size of the TX queue (in bytes)
> +     - rx-sram-addr : address of the SRAM for RX path (non 0 means used)
> +     - rx-sram-size : size of the SRAM for RX path (non 0 means used)
> +     - tx-sram-addr : address of the SRAM for TX path (non 0 means used)
> +     - tx-sram-size : size of the SRAM for TX path (non 0 means used)
> +
>     Example Discovery Ethernet port node:
>       ethernet@0 {
>  	     device_type = "network";
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index aedbd82..75599a8 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -60,6 +60,10 @@
>  #include <linux/inet_lro.h>
>  #include <linux/slab.h>
>  #include <linux/clk.h>
> +#include <linux/stringify.h>
> +#include <linux/of.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_net.h>
>  
>  static char mv643xx_eth_driver_name[] = "mv643xx_eth";
>  static char mv643xx_eth_driver_version[] = "1.4";
> @@ -2542,14 +2546,23 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
>  	}
>  }
>  
> +static const struct of_device_id mv643xx_eth_match[] = {
> +	{ .compatible = "marvell,mv64360-eth" },
> +	{ .compatible = "marvell,mv643xx-eth" },
> +	{ /* sentinel */ },
> +};
> +MODULE_DEVICE_TABLE(of, mv643xx_eth_match);
> +
>  static int mv643xx_eth_shared_probe(struct platform_device *pdev)
>  {
>  	static int mv643xx_eth_version_printed;
> +	struct device_node *np = pdev->dev.of_node;
>  	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
>  	struct mv643xx_eth_shared_private *msp;
>  	const struct mbus_dram_target_info *dram;
>  	struct resource *res;
>  	int ret;
> +	int tx_csum_limit = 0;
>  
>  	if (!mv643xx_eth_version_printed++)
>  		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",

This is not related to your change, but there is a problem in this
function that has already been discussed in the past if I remember
correctly: The respective clock needs to be enabled here (at least
on Kirkwood), since accesses to the hardware are done below. 
Enabling the clock only in mv643xx_eth_probe() is too late.

As said, this is not a problem introduced by your changes (and which
is currently circumvented by enabling the respective clocks in
kirkwood_legacy_clk_init() and kirkwood_ge0x_init()), but we might
want to fix this now to get rid of unconditionally enabling the GE
clocks in the DT case.


> @@ -2576,13 +2589,23 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
>  	if (dram)
>  		mv643xx_eth_conf_mbus_windows(msp, dram);
>  
> -	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
> -					pd->tx_csum_limit : 9 * 1024;
> +	if (np)
> +		of_property_read_u32(np, "tx-csum-limit", &tx_csum_limit);
> +	else
> +		tx_csum_limit = pd->tx_csum_limit;
> +
> +	msp->tx_csum_limit = tx_csum_limit ? tx_csum_limit : 9 * 1024;
>  	infer_hw_params(msp);
>  
>  	platform_set_drvdata(pdev, msp);
> +	ret = 0;
>  
> -	return 0;
> +#ifdef CONFIG_OF
> +	ret = of_platform_bus_probe(np, mv643xx_eth_match, &pdev->dev);
> +	if (ret)
> +		goto out_free;
> +#endif
> +	return ret;
>  
>  out_free:
>  	kfree(msp);
> @@ -2600,12 +2623,22 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +static const struct of_device_id mv643xx_eth_shared_match[] = {
> +	{ .compatible = "marvell,mv64360-eth-group" },
> +	{ .compatible = "marvell,mv64360-eth-block" },
> +	{ .compatible = "marvell,mv643xx-eth-group" },
> +	{ .compatible = "marvell,mv643xx-eth-block" },
> +	{ /* sentinel */ },
> +};
> +MODULE_DEVICE_TABLE(of, mv643xx_eth_shared_match);
> +
>  static struct platform_driver mv643xx_eth_shared_driver = {
>  	.probe		= mv643xx_eth_shared_probe,
>  	.remove		= mv643xx_eth_shared_remove,
>  	.driver = {
>  		.name	= MV643XX_ETH_SHARED_NAME,
>  		.owner	= THIS_MODULE,
> +		.of_match_table = of_match_ptr(mv643xx_eth_shared_match),
>  	},
>  };
>  
> @@ -2764,6 +2797,74 @@ static const struct net_device_ops mv643xx_eth_netdev_ops = {
>  #endif
>  };
>  
> +#ifdef CONFIG_OF
> +static int mv643xx_eth_of_probe(struct platform_device *pdev)
> +{
> +	struct mv643xx_eth_platform_data *pd;
> +	struct device_node *np = pdev->dev.of_node;
> +	struct device_node *shared = of_get_parent(np);
> +	struct device_node *phy_node;
> +	const int *prop;
> +	const char *mac_addr;
> +
> +	if (!pdev->dev.of_node)
> +		return 0;
> +
> +	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
> +	if (!pd)
> +		return -ENOMEM;
> +
> +	pdev->dev.platform_data = pd;
> +
> +	pd->shared = of_find_device_by_node(shared);
> +	if (!pd->shared)
> +		return -ENODEV;
> +
> +	prop = of_get_property(np, "reg", NULL);
> +	if (!prop)
> +		return -EINVAL;
> +
> +	pd->port_number = be32_to_cpup(prop);
> +
> +	phy_node = of_parse_phandle(np, "phy", 0);
> +	if (!phy_node) {
> +		pd->phy_addr = MV643XX_ETH_PHY_NONE;
> +
> +		of_property_read_u32(np, "speed", &pd->speed);
> +		of_property_read_u32(np, "duplex", &pd->duplex);
> +	} else {
> +		prop = of_get_property(phy_node, "reg", NULL);
> +		if (prop)
> +			pd->phy_addr = be32_to_cpup(prop);
> +	}
> +
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		memcpy(pd->mac_addr, mac_addr, ETH_ALEN);
> +
> +#define rx_tx_queue_sram_property(_name)			\
> +	prop = of_get_property(np, __stringify(_name), NULL);	\
> +	if (prop)						\
> +		pd->_name = be32_to_cpup(prop);
> +
> +	rx_tx_queue_sram_property(rx_queue_count);
> +	rx_tx_queue_sram_property(tx_queue_count);
> +	rx_tx_queue_sram_property(rx_queue_size);
> +	rx_tx_queue_sram_property(tx_queue_size);
> +	rx_tx_queue_sram_property(rx_sram_addr);
> +	rx_tx_queue_sram_property(rx_sram_size);
> +	rx_tx_queue_sram_property(tx_sram_addr);
> +	rx_tx_queue_sram_property(rx_sram_size);
> +
> +	return 0;
> +}
> +#else
> +static inline int mv643xx_eth_of_probe(struct platform_device *dev)
> +{
> +	return 0;
> +}
> +#endif
> +
>  static int mv643xx_eth_probe(struct platform_device *pdev)
>  {
>  	struct mv643xx_eth_platform_data *pd;
> @@ -2772,7 +2873,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
>  	struct resource *res;
>  	int err;
>  
> +	err = mv643xx_eth_of_probe(pdev);
> +	if (err)
> +		return err;
> +
>  	pd = pdev->dev.platform_data;
> +
>  	if (pd == NULL) {
>  		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
>  		return -ENODEV;

You don't change the clk initialization here:

#if defined(CONFIG_HAVE_CLK)
	mp->clk = clk_get(&pdev->dev, (pdev->id ? "1" : "0"));
	if (!IS_ERR(mp->clk)) {
		clk_prepare_enable(mp->clk);
		mp->t_clk = clk_get_rate(mp->clk);
	}
#endif

Which, if I understand correctly, works in the DT case because you
assign "clock-names" to the clocks in the DTS. However, I wonder
whether this works for any but the first Ethernet device.

In the old platform device setup, the pdev->id was set when
initialiazing the platform_device structure in common.c.  Where is
this done in the DT case?


In phy_scan(), the phy is searched like this:

		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
				"orion-mdio-mii", addr);

		phydev = phy_connect(mp->dev, phy_id, mv643xx_eth_adjust_link,
				PHY_INTERFACE_MODE_GMII);

But "orion-mdio-mii:xx" is the name of the PHY if MDIO is setup via a
platform_device. I could not get this to work if the MDIO device is
setup via DT. Am I doing something wrong?


Additionally, in phy_scan() there is this:

	if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
		start = phy_addr_get(mp) & 0x1f;
		num = 32;
	} else {
	...

MV643XX_ETH_PHY_ADDR_DEFAULT is defined as 0. However, many Kirkwood
devices use "MV643XX_ETH_PHY_ADDR(0)".  If the module probe is
deferred in mv643xx_eth because the MDIO driver is not yet loaded,
all 32 PHY addresses are scanned without success.  This is not needed
and clutters the log.


- Simon
