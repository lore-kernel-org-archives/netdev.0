From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 4/5] net: stmmac: dwmac-sun8i: choose internal PHY via
 phy-is-integrated
Date: Thu, 31 Aug 2017 15:18:03 -0500
Message-ID: <20170831201803.x6vwftfcllrfpk6q@rob-hp-laptop>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
 <20170826073311.25612-5-clabbe.montjoie@gmail.com>
 <20170826212051.GA10418@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>, mark.rutland@arm.com,
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
> 
> I would suggest a binding something like:

This is looks better to me, but...
 
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

Why do you need this node still?

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
> 	Andrew
