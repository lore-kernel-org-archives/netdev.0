From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for
 Allwinner sun8i-emac
Date: Mon, 12 Sep 2016 17:01:25 +0200
Message-ID: <20160912150125.GA15570@Red>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
 <20160909140413.GD30871@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37958 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759590AbcILPBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:01:31 -0400
Content-Disposition: inline
In-Reply-To: <20160909140413.GD30871@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2016 at 04:04:13PM +0200, Andrew Lunn wrote:
> > +The device node referenced by "phy" or "phy-handle" should be a child node
> > +of this node. See phy.txt for the generic PHY bindings.
> 
> I've not looked at the code yet, but is this really true? Generally
> there is not this limitation. You can point to any Ethernet phy
> anyway, so long as it is on am MDIO bus.
> 
> > +
> > +Optional properties:
> > +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
> > +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)
> > +
> > +The TX/RX clock delay chain settings are board specific.
> > +
> > +Optional properties for "allwinner,sun8i-h3-emac":
> > +- allwinner,leds-active-low: EPHY LEDs are active low
> > +
> > +Example:
> > +
> > +emac: ethernet@01c0b000 {
> > +	compatible = "allwinner,sun8i-h3-emac";
> > +	syscon = <&syscon>;
> > +	reg = <0x01c0b000 0x104>;
> > +	reg-names = "emac";
> > +	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
> > +	resets = <&ccu RST_BUS_EMAC>, <<&ccu RST_BUS_EPHY>;
> > +	reset-names = "ahb", "ephy";
> > +	clocks = <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
> > +	clock-names = "ahb", "ephy";
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +
> > +	phy = <&phy1>;
> 
> ethernet.txt say:
> 
> - phy: the same as "phy-handle" property, not recommended for new bindings.
> 
> This is a new binding, please don't support it.
> 
> > +	phy-mode = "mii";
> > +	allwinner,leds-active-low;
> > +
> > +	phy1: ethernet-phy@1 {
> > +		reg = <1>;
> > +	};
> 
> It is normal to place these phy nodes inside an container node called
> mdio.
> 

Hello

Since the MDIO bus is a part of the sun8i-emac, does I really need to create such a mdio node ?
All example I found are mdio bus with separate driver. (others driver have the phy directly in [eg]mac node.

Anyway I try the following patch to solve your comments, but it breaks the PHY finding(Could not attach to PHY).

Regards

-->8--
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -166,14 +166,18 @@
        status = "okay";
 };
 
+&mdio {
+       reg = <1>;
+       phy1: ethernet-phy@1 {
+               reg = <1>;
+       };
+};
+
 &emac {
-       phy = <&phy1>;
+       phy-handle = <&phy1>;
        phy-mode = "mii";
        allwinner,leds-active-low;
        status = "okay";
-       phy1: ethernet-phy@1 {
-               reg = <1>;
-       };
 };/arch/arm/boot/dts/sun8i-h3.dtsi
+++ b/arch/arm/boot/dts/sun8i-h3.dtsi
@@ -474,6 +474,11 @@
                        #address-cells = <1>;
                        #size-cells = <0>;
                        status = "disabled";
+
+                       mdio: mdio@0 {
+                               #address-cells = <1>;
+                               #size-cells = <0>;
+                       };
                };
 
                crypto: crypto@1c15000 {
--- a/drivers/net/ethernet/allwinner/sun8i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun8i-emac.c
@@ -2122,7 +2122,7 @@ static int sun8i_emac_probe(struct platform_device *pdev)
                return -EINVAL;
        }
 
-       priv->phy_node = of_parse_phandle(node, "phy", 0);
+       priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
        if (!priv->phy_node) {
                netdev_err(ndev, "No associated PHY\n");
                return -ENODEV;

 
 &crypto {
