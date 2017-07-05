From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: Re: [PATCH] net: axienet: add of_phy_connect call for
 XAE_PHY_TYPE_MII case
Date: Wed, 5 Jul 2017 12:13:45 +0200
Message-ID: <20170705101344.jlx5ju2x46szmuu7@collins.gmr.ssr.upm.es>
References: <20170630092541.27234-1-alvaro.gamez@hazent.com>
 <425aed84-a1b6-b8da-5989-3bef5a03ead4@gmail.com>
 <20170702101914.5nk27r2h754qzthe@collins.gmr.ssr.upm.es>
 <6A2BD6D6-9CBB-4BDD-BF28-F0BF10DB454C@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6A2BD6D6-9CBB-4BDD-BF28-F0BF10DB454C@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2017 at 09:24:03AM -0700, Florian Fainelli wrote:
> On July 2, 2017 3:19:14 AM PDT, Alvaro Gamez Machado <alvaro.gamez@hazent.com> wrote:
> >On Fri, Jun 30, 2017 at 10:30:38AM -0700, Florian Fainelli wrote:
> >> On 06/30/2017 02:25 AM, Alvaro Gamez Machado wrote:
> >> >  	if (lp->phy_node) {
> >> > -		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
> >> > +		if (lp->phy_type == XAE_PHY_TYPE_MII) {
> >> > +			phydev = of_phy_connect(lp->ndev, lp->phy_node,
> >> > +						axienet_adjust_link, 0,
> >> > +						PHY_INTERFACE_MODE_MII);
> >> > +		} else if (lp->phy_type == XAE_PHY_TYPE_GMII) {
> >> >  			phydev = of_phy_connect(lp->ndev, lp->phy_node,
> >> >  						axienet_adjust_link, 0,
> >> >  						PHY_INTERFACE_MODE_GMII);
> >> 
> >> Seems like this could be simplified even further if the values of
> >> lp->phy_type directly mapped to those of phy_interface_t.
> >
> >Sadly, that's not the case. PHY_INTERFACE_MODE_* belong to a enum of
> >twenty
> >different values, of which only _MII and _GMII overlap with XAW_PHY_*
> >values, but XAE_PHY_TYPE_RGMII_2_0 doesn't match
> >PHY_INTERFACE_MODE_RGMII_ID.
> 
> There are four different rgmii types to account for rx or tx delay, is not
> there one that really matches?  If the driver is using of_get_phy_mode()
> to retrieve the standard 'phy-mode' / 'phy-connection-type' values then
> this internal representation is not needed anymore.

Instead of the standard 'phy-mode' / 'phy-connection-type' values, the
driver uses of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type).

I think the reason for this is that Xilinx provides a utility to generate
device trees from a Vivado/ISE project, which outputs something similar to:

axi_ethernet_eth: ethernet@40c00000 {
	axistream-connected = <&axi_ethernet_0_dma>;
	axistream-control-connected = <&axi_ethernet_0_dma>;
	clock-frequency = <83250000>;
	clocks = <&clk_bus_0>;
	compatible = "xlnx,axi-ethernet-1.00.a";
	device_type = "network";
	interrupt-parent = <&microblaze_0_axi_intc>;
	interrupts = <2 0>;
	phy-mode = "mii";
	reg = <0x40c00000 0x40000>;
	xlnx = <0x0>;
	xlnx,axiliteclkrate = <0x0>;
	xlnx,axisclkrate = <0x0>;
	xlnx,gt-type = <0x0>;
	xlnx,gtinex = <0x0>;
	xlnx,phy-type = <0x0>;
	xlnx,phyaddr = <0x1>;
	xlnx,rable = <0x0>;
	xlnx,rxcsum = <0x2>;
	xlnx,rxlane0-placement = <0x0>;
	xlnx,rxlane1-placement = <0x0>;
	xlnx,rxmem = <0x800>;
	xlnx,rxnibblebitslice0used = <0x1>;
	xlnx,tx-in-upper-nibble = <0x1>;
	xlnx,txcsum = <0x2>;
	xlnx,txlane0-placement = <0x0>;
	xlnx,txlane1-placement = <0x0>;
	phy-handle = <&phy0>;
	axi_ethernetlite_0_mdio: mdio {
		#address-cells = <1>;
		#size-cells = <0>;
		phy0: phy@0 {
			device_type = "ethernet-phy";
			reg = <1>;
		};
	};
};

Basically, every 'xlnx,' attribute is taken, both name and value, directly
from the IP core configuration, even if they are not needed (or even of
remote interest to any possible driver).

So, migrating this to standard of_get_phy_mode is feasible, but I'd say
it's pretty inconvenient from the point of view of the HDL system
designer, and would break existing DTS files people may be using right
now.



-- 
Alvaro G. M.
