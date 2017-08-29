From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v4 4/5] net: stmmac: dwmac-sun8i: choose internal PHY via
 phy-is-integrated
Date: Tue, 29 Aug 2017 10:34:32 +0200
Message-ID: <20170829083432.GA28818@Red>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
 <20170826073311.25612-5-clabbe.montjoie@gmail.com>
 <20170826212051.GA10418@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com, icenowy@aosc.io,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170826212051.GA10418@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 26, 2017 at 11:20:51PM +0200, Andrew Lunn wrote:
> Hi Corentin
> 
> I think we have now all agreed this is an mdio-mux, plus it is also an
> MII mux. We should represent that in device tree. This patchset does
> this. However, as it is now, the mux structure in DT is ignored. All
> it does is search for the phy-is-integrated flags and goes on that.
> 
> I made the comment that the device tree representation cannot be
> implemented using an MDIO mux driver, because of driver loading
> issues.  However, the core of the MDIO mux code is just a library,
> symbols exported as GPL, free for anything to use.
> 
> What i think should happen is the mdio-mux is implemented inside the
> MAC driver, using the mux-core as a library. The device tree structure
> of a mix is then reflected within Linux. The mux switch callback is
> implemented within the MAC driver. So it can reset the MAC when the
> mux is switched. The 'phy-is-integrated' property is then no longer
> needed.

It is stilll needed because some settings (allwinner,leds-active-low for example) are only for integrated phy.

> 
> I would suggest a binding something like:
> 
> emac: ethernet@1c0b000 {
>         compatible = "allwinner,sun8i-h3-emac";
>         syscon = <&syscon>;
>         reg = <0x01c0b000 0x104>;
>         interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
>         interrupt-names = "macirq";
>         resets = <&ccu RST_BUS_EMAC>;
>         reset-names = "stmmaceth";
>         clocks = <&ccu CLK_BUS_EMAC>;
>         clock-names = "stmmaceth";
>         #address-cells = <1>;
>         #size-cells = <0>;
> 
>         phy-handle = <&int_mii_phy>;
>         phy-mode = "mii";
>         allwinner,leds-active-low;
> 
>         mdio: mdio {
>                 #address-cells = <1>;
>                 #size-cells = <0>;
> 	}
> 
> 	mdio-mux {
>                 #address-cells = <1>;
>                 #size-cells = <0>;
> 
> 		mdio@0 {
> 			reg = <0>;
>                         #address-cells = <1>;
>                         #size-cells = <0>;
> 
>                         int_mii_phy: ethernet-phy@1 {
>                                 reg = <1>;
>                                 clocks = <&ccu CLK_BUS_EPHY>;
>                                 resets = <&ccu RST_BUS_EPHY>;
>                         };
>                 };
>                 ext_mdio: mdio@0 {
>                         #address-cells = <1>;
>                         #size-cells = <0>;
> 
>                         ext_rgmii_phy: ethernet-phy@1 {
>                                 reg = <1>;
>                         };
>                 };
>        };
> };
> 

I am trying to do that but I get:
dwmac-sun8i 1c30000.ethernet: Error: Failed to find reg for child /soc/ethernet@1c30000/mdio
dwmac-sun8i 1c30000.ethernet: Error: Failed to find reg for child /soc/ethernet@1c30000/mdio-mux
dwmac-sun8i 1c30000.ethernet: Error: No acceptable child buses found

So it seems that mdio_mux_init() must be run on mdio-mux and not on emac node.
But in the current state it cannot be done.

Do you agree that another mdio_mux_init() must be written ? (taking a of_node (in our case: mdio-mux) instead of a device)
Or do I miss something ?

Regards
