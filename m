From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v9 02/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Mon, 30 Oct 2017 19:35:35 +0100
Message-ID: <20171030183535.GA16723@Red>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-3-clabbe.montjoie@gmail.com>
 <20171027125621.mlcapjhttyw2j5sy@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, maxime.ripard@free-electrons.com,
        wens@csie.org, linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171027125621.mlcapjhttyw2j5sy@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 09:37:10AM -0500, Rob Herring wrote:
> On Tue, Oct 24, 2017 at 07:57:06PM +0200, Corentin Labbe wrote:
> > This patch add documentation about the MDIO switch used on sun8i-h3-emac
> > for integrated PHY.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  .../devicetree/bindings/net/dwmac-sun8i.txt        | 145 +++++++++++++++++++--
> >  1 file changed, 133 insertions(+), 12 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > index 725f3b187886..2600ce9ad3cc 100644
> > --- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> > @@ -4,18 +4,18 @@ This device is a platform glue layer for stmmac.
> >  Please see stmmac.txt for the other unchanged properties.
> >  
> >  Required properties:
> > -- compatible: should be one of the following string:
> > +- compatible: must be one of the following string:
> >  		"allwinner,sun8i-a83t-emac"
> >  		"allwinner,sun8i-h3-emac"
> >  		"allwinner,sun8i-v3s-emac"
> >  		"allwinner,sun50i-a64-emac"
> >  - reg: address and length of the register for the device.
> >  - interrupts: interrupt for the device
> > -- interrupt-names: should be "macirq"
> > +- interrupt-names: must be "macirq"
> >  - clocks: A phandle to the reference clock for this device
> > -- clock-names: should be "stmmaceth"
> > +- clock-names: must be "stmmaceth"
> >  - resets: A phandle to the reset control for this device
> > -- reset-names: should be "stmmaceth"
> > +- reset-names: must be "stmmaceth"
> >  - phy-mode: See ethernet.txt
> >  - phy-handle: See ethernet.txt
> >  - #address-cells: shall be 1
> > @@ -39,23 +39,42 @@ Optional properties for the following compatibles:
> >  - allwinner,leds-active-low: EPHY LEDs are active low
> >  
> >  Required child node of emac:
> > -- mdio bus node: should be named mdio
> > +- mdio bus node: with compatible "snps,dwmac-mdio"
> 
> It should still be named mdio.
> 
> >  
> >  Required properties of the mdio node:
> >  - #address-cells: shall be 1
> >  - #size-cells: shall be 0
> >  
> > -The device node referenced by "phy" or "phy-handle" should be a child node
> > +The device node referenced by "phy" or "phy-handle" must be a child node
> >  of the mdio node. See phy.txt for the generic PHY bindings.
> >  
> > -Required properties of the phy node with the following compatibles:
> > +The following compatibles require that the emac node have a mdio-mux child
> > +node called "mdio-mux":
> > +  - "allwinner,sun8i-h3-emac"
> > +  - "allwinner,sun8i-v3s-emac":
> > +Required properties for the mdio-mux node:
> > +  - compatible = "allwinner,sun8i-h3-mdio-mux"
> > +  - mdio-parent-bus: a phandle to EMAC mdio
> > +  - one child mdio for the integrated mdio with the compatible
> > +    "allwinner,sun8i-h3-mdio-internal"
> > +  - one child mdio for the external mdio if present (V3s have none)
> > +Required properties for the mdio-mux children node:
> > +  - reg: 1 for internal MDIO bus, 2 for external MDIO bus
> > +
> > +The following compatibles require a PHY node representing the integrated
> > +PHY, under the integrated MDIO bus node if an mdio-mux node is used:
> >    - "allwinner,sun8i-h3-emac",
> >    - "allwinner,sun8i-v3s-emac":
> > +
> > +Additional information regarding generic multiplexer properties can be found
> > +at Documentation/devicetree/bindings/net/mdio-mux.txt
> > +
> > +Required properties of the integrated phy node:
> >  - clocks: a phandle to the reference clock for the EPHY
> >  - resets: a phandle to the reset control for the EPHY
> > +- Must be a child of the integrated mdio
> >  
> > -Example:
> > -
> > +Example with integrated PHY:
> >  emac: ethernet@1c0b000 {
> >  	compatible = "allwinner,sun8i-h3-emac";
> >  	syscon = <&syscon>;
> > @@ -72,13 +91,115 @@ emac: ethernet@1c0b000 {
> >  	phy-handle = <&int_mii_phy>;
> >  	phy-mode = "mii";
> >  	allwinner,leds-active-low;
> > +
> > +	mdio0: mdio {
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		compatible = "snps,dwmac-mdio";
> > +	};
> > +
> > +	mdio-mux {
> > +		compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux";
> 
> Drop mdio-mux.
> 
> With those fixed,
> 
> Acked-by: Rob Herring <robh@kernel.org>

Will change what you ask.

Thanks
Regards
