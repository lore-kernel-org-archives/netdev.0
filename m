From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: [PATCH v3 1/7] net: mv643xx_eth: add Device Tree bindings
Date: Mon, 20 May 2013 23:19:31 +0200
Message-ID: <20130520211930.GA25725@schnuecks.de>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1367854420-8006-2-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <florian@openwrt.org>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367854420-8006-2-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

On Mon, May 06, 2013 at 05:33:34PM +0200, Sebastian Hesselbarth wrote:
> From: Florian Fainelli <florian@openwrt.org>
> 
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
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Changelog:
> v2->v3:
> - rebase on top of mv643xx_eth clean-ups
> - do not reparse existing platform_data
> - use managed devm_kzalloc for parsed platform_data
> - use of_property_read_u32 where applicable
> - add phy_node to platform_data
> - use of_connect_phy if DT phy node was found
> 
> v1->v2:
> - properly ifdef of_platform_bus_probe with CONFIG_OF
> - handle of_platform_bus_probe errors and cleanup accordingly
> - use of_property_read_u32 where applicable
> - parse "duplex" and "speed" property in PHY-less configuration
> 
> Cc: Grant Likely <grant.likely@linaro.org>
> Cc: Rob Herring <rob.herring@calxeda.com>
> Cc: Rob Landley <rob@landley.net>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <florian@openwrt.org>
> Cc: Arnaud Patard <arnaud.patard@rtp-net.org>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: Jean-Francois Moine <moinejf@free.fr>
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Simon Guinot <simon.guinot@sequanux.org>
> Cc: Jamie Lentin <jm@lentin.co.uk>
> Cc: Michael Walle <michael@walle.cc>
> Cc: Eric Hutter <hutter.eric@gmail.com>
> Cc: Joshua Coombs <josh.coombs@gmail.com>
> Cc: Willy Tarreau <w@1wt.eu>
> Cc: Simon Baatz <gmbnomis@gmail.com>
> Cc: Alan M Butler <alanbutty12@gmail.com>
> Cc: Nigel Roberts <nigel@nobiscuit.com>
> Cc: Valentin Longchamp <valentin.longchamp@keymile.com>
> Cc: Stefan Peter <s.peter@mpl.ch>
> Cc: Arnaud Ebalard <arno@natisbad.org>
> Cc: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
> Cc: netdev@vger.kernel.org
> Cc: devicetree-discuss@lists.ozlabs.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  Documentation/devicetree/bindings/marvell.txt |   22 +++++-
>  drivers/net/ethernet/marvell/mv643xx_eth.c    |  108 ++++++++++++++++++++++++-
>  include/linux/mv643xx_eth.h                   |    3 +
>  3 files changed, 128 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/marvell.txt b/Documentation/devicetree/bindings/marvell.txt
> index f7a0da6..73ea12f 100644
> --- a/Documentation/devicetree/bindings/marvell.txt
> +++ b/Documentation/devicetree/bindings/marvell.txt
> @@ -112,11 +112,13 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
>     Required properties:
>       - #address-cells : <1>
>       - #size-cells : <0>
> -     - compatible : "marvell,mv64360-eth-block"
> +     - compatible : "marvell,mv64360-eth-block", "marvell,mv643xx-eth-block"
>       - reg : Offset and length of the register set for this block
>  
>     Optional properties:
>       - clocks : Phandle to the clock control device and gate bit
> +     - tx-csum-limit : Hardware limit above which transmit checksumming
> +                       is disabled.
>  
>     Example Discovery Ethernet block node:
>       ethernet-block@2000 {
> @@ -133,7 +135,7 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
>  
>     Required properties:
>       - device_type : Should be "network".
> -     - compatible : Should be "marvell,mv64360-eth".
> +     - compatible : Should be "marvell,mv64360-eth", "marvell,mv643xx-eth"
>       - reg : Should be <0>, <1>, or <2>, according to which registers
>         within the silicon block the device uses.
>       - interrupts : <a> where a is the interrupt number for the port.
> @@ -143,6 +145,22 @@ prefixed with the string "marvell,", for Marvell Technology Group Ltd.
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
> index d0afeea..efa5a2f 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -60,6 +60,11 @@
>  #include <linux/types.h>
>  #include <linux/slab.h>
>  #include <linux/clk.h>
> +#include <linux/stringify.h>
> +#include <linux/of.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_mdio.h>
> +#include <linux/of_net.h>
>  
>  static char mv643xx_eth_driver_name[] = "mv643xx_eth";
>  static char mv643xx_eth_driver_version[] = "1.4";
> @@ -2450,13 +2455,22 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
>  	}
>  }
>  
> +static const struct of_device_id mv643xx_eth_match[] = {
> +	{ .compatible = "marvell,mv64360-eth" },
> +	{ .compatible = "marvell,mv643xx-eth" },
> +	{ },
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
> +	int tx_csum_limit = 0;
>  
>  	if (!mv643xx_eth_version_printed++)
>  		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
> @@ -2485,13 +2499,21 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
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
>  
> +#ifdef CONFIG_OF
> +	return of_platform_bus_probe(np, mv643xx_eth_match, &pdev->dev);

I have tested this on Kirkwood (Sheevaplug eSATA). When using
mv643xx_eth as a module with a built-in mvmdio the GbE port works. 
However, when unloading the mv643xx_eth module and loading it again,
the second call to of_platform_bus_probe() results in a warning:

[  190.542992] WARNING: at fs/sysfs/dir.c:530 sysfs_add_one+0x7c/0xa4()         
[  190.549372] sysfs: cannot create duplicate filename '/devices/ocp.0/f1072000.
ethernet-controller/0.ethernet-port'                                            

(Looks more like a problem of of_platform_bus_probe() than a problem
in the driver?)

> +#else
>  	return 0;
> +#endif
>  }
>  
>  static int mv643xx_eth_shared_remove(struct platform_device *pdev)
> @@ -2505,12 +2527,20 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +static const struct of_device_id mv643xx_eth_shared_match[] = {
> +	{ .compatible = "marvell,mv64360-eth-block" },
> +	{ .compatible = "marvell,mv643xx-eth-block" },
> +	{ },
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
> @@ -2669,6 +2699,68 @@ static const struct net_device_ops mv643xx_eth_netdev_ops = {
>  #endif
>  };
>  
> +#ifdef CONFIG_OF
> +static int mv643xx_eth_of_probe(struct platform_device *pdev)
> +{
> +	struct mv643xx_eth_platform_data *pd;
> +	struct device_node *np = pdev->dev.of_node;
> +	struct device_node *shared = of_get_parent(np);
> +	const int *prop;
> +	const char *mac_addr;
> +
> +	if (pdev->dev.platform_data || !pdev->dev.of_node)
> +		return 0;
> +
> +	pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
> +	if (!pd)
> +		return -ENOMEM;
> +
> +	pdev->dev.platform_data = pd;
> +
> +	pd->shared = of_find_device_by_node(shared);
> +	if (!pd->shared)
> +		return -ENODEV;
> +
> +	if (of_property_read_u32(np, "reg", &pd->port_number))
> +		return -EINVAL;
> +
> +	pd->phy_node = of_parse_phandle(np, "phy", 0);
> +	if (!pd->phy_node) {
> +		pd->phy_addr = MV643XX_ETH_PHY_NONE;
> +
> +		of_property_read_u32(np, "speed", &pd->speed);
> +		of_property_read_u32(np, "duplex", &pd->duplex);
> +	}
> +
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		memcpy(pd->mac_addr, mac_addr, ETH_ALEN);
> +
> +#define rx_tx_queue_sram_property(_name)				\
> +	do {								\
> +		prop = of_get_property(np, __stringify(_name), NULL);	\
> +		if (prop)						\
> +			pd->_name = be32_to_cpup(prop);			\
> +	} while (0)
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
> @@ -2677,6 +2769,10 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
>  	struct resource *res;
>  	int err;
>  
> +	err = mv643xx_eth_of_probe(pdev);
> +	if (err)
> +		return err;
> +
>  	pd = pdev->dev.platform_data;
>  	if (pd == NULL) {
>  		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");


If the clock isn't already enabled (mvmdio and mv643xx_eth both built
as modules), a delay seems to be necessary in mv643xx_eth_probe()
after enabling the clock on my hardware.  Otherwise the device hangs. 
Andrew found the same in the past (see [1]).  udelay(50) seems to be
sufficient in my case.

> @@ -2717,7 +2813,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
>  	netif_set_real_num_rx_queues(dev, mp->rxq_count);
>  
>  	if (pd->phy_addr != MV643XX_ETH_PHY_NONE) {
> -		mp->phy = phy_scan(mp, pd->phy_addr);
> +		if (pd->phy_node)
> +			mp->phy = of_phy_connect(mp->dev, pd->phy_node,
> +						mv643xx_eth_adjust_link, 0,
> +						PHY_INTERFACE_MODE_GMII);

of_phy_connect() returns NULL in case of an error and no ERR_PTR.

- Simon

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2012-June/103521.html
