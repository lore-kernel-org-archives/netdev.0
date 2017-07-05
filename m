From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: axienet: add of_phy_connect call for
 XAE_PHY_TYPE_MII case
Date: Wed, 5 Jul 2017 16:34:36 +0200
Message-ID: <20170705143436.GD19749@lunn.ch>
References: <20170630092541.27234-1-alvaro.gamez@hazent.com>
 <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com>
 <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
 <6A2BD6D6-9CBB-4BDD-BF28-F0BF10DB454C@gmail.com>
 <20170705101344.jlx5ju2x46szmuu7@collins.gmr.ssr.upm.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170705101344.jlx5ju2x46szmuu7@collins.gmr.ssr.upm.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Instead of the standard 'phy-mode' / 'phy-connection-type' values, the
> driver uses of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type).
> 
> I think the reason for this is that Xilinx provides a utility to generate
> device trees from a Vivado/ISE project, which outputs something similar to:
> 
> axi_ethernet_eth: ethernet@40c00000 {
> 	axistream-connected = <&axi_ethernet_0_dma>;
> 	axistream-control-connected = <&axi_ethernet_0_dma>;
> 	clock-frequency = <83250000>;
> 	clocks = <&clk_bus_0>;
> 	compatible = "xlnx,axi-ethernet-1.00.a";
> 	device_type = "network";
> 	interrupt-parent = <&microblaze_0_axi_intc>;
> 	interrupts = <2 0>;
> 	phy-mode = "mii";
> 	reg = <0x40c00000 0x40000>;
> 	xlnx = <0x0>;
> 	xlnx,axiliteclkrate = <0x0>;
> 	xlnx,axisclkrate = <0x0>;
> 	xlnx,gt-type = <0x0>;
> 	xlnx,gtinex = <0x0>;
> 	xlnx,phy-type = <0x0>;
> 	xlnx,phyaddr = <0x1>;
> 	xlnx,rable = <0x0>;
> 	xlnx,rxcsum = <0x2>;
> 	xlnx,rxlane0-placement = <0x0>;
> 	xlnx,rxlane1-placement = <0x0>;
> 	xlnx,rxmem = <0x800>;
> 	xlnx,rxnibblebitslice0used = <0x1>;
> 	xlnx,tx-in-upper-nibble = <0x1>;
> 	xlnx,txcsum = <0x2>;
> 	xlnx,txlane0-placement = <0x0>;
> 	xlnx,txlane1-placement = <0x0>;
> 	phy-handle = <&phy0>;
> 	axi_ethernetlite_0_mdio: mdio {
> 		#address-cells = <1>;
> 		#size-cells = <0>;
> 		phy0: phy@0 {
> 			device_type = "ethernet-phy";
> 			reg = <1>;
> 		};
> 	};
> };
> 
> Basically, every 'xlnx,' attribute is taken, both name and value, directly
> from the IP core configuration, even if they are not needed (or even of
> remote interest to any possible driver).

And it appears none of these are documented in a binding documentation. 

> So, migrating this to standard of_get_phy_mode is feasible, but I'd say
> it's pretty inconvenient from the point of view of the HDL system
> designer, and would break existing DTS files people may be using right
> now.

There i disagree. Xilinx should make their tools follow the Linux
standards, not do something proprietary. And the driver can be made to
do the right thing. At the moment, it only seems to be using:

ll_temac_main.c:    p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
ll_temac_main.c:    p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
xilinx_axienet_main.c:	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,txcsum", &value);
xilinx_axienet_main.c:	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,rxcsum", &value);
xilinx_axienet_main.c:	of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
xilinx_axienet_main.c:	of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
xilinx_emaclite.c:	lp->tx_ping_pong = get_bool(ofdev, "xlnx,tx-ping-pong");
xilinx_emaclite.c:	lp->rx_ping_pong = get_bool(ofdev, "xlnx,rx-ping-pong");

So the only property which is currently wrong is xlnx,phy-type. As you
said, all the others are garbage. So i would suggest something like:

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 33c595f4691d..34a514d3288a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1539,7 +1539,38 @@ static int axienet_probe(struct platform_device *pdev)
         * the device-tree and accordingly set flags.
         */
        of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
-       of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
+
+       /* Start with the proprietary, and broken phy_type */
+       err = of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &phy_type);
+       if (!err) {
+               netdev_warn(ndev, "Please upgrade your device tree binary blob to use phy-mode");
+               switch (phy_type) {
+               case XAE_PHY_TYPE_MII:
+                       lp->phy_mode = PHY_INTERFACE_MODE_MII;
+                       break;
+               case XAE_PHY_TYPE_GMII:
+                       lp->phy_mode = PHY_INTERFACE_MODE_GMII;
+                       break;
+               case XAE_PHY_TYPE_RGMII_2_0:
+                       lp->phy_mode = PHY_INTERFACE_MODE_RGMII;
+                       break;
+               case XAE_PHY_TYPE_SGMII:
+                       lp->pht_mode = PHY_INTERFACE_MODE_SGMII;
+                       break;
+               case XAE_PHY_TYPE_1000BASE_X:
+                       lp->pht_mode = PHY_INTERFACE_MODE_1000BASEX;
+                       break;
+               default:
+                       ret = -EINVAL;
+                       goto free_netdev;
+               }
+       } else {
+               lp->phy_mode = of_get_phy_mode(pdev->dev.of_node);
+               if (lp->phy_mode < 0) {
+                       ret = -EINVAL;
+                       goto free_netdev;
+               }
+       }
 
        /* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
        np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);

	Andrew
