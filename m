From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: ethernet: mediatek: add the dts
 property to set if TRGMII supported on GMAC0
Date: Tue, 20 Sep 2016 21:37:58 +0200
Message-ID: <20160920193758.GA29522@lunn.ch>
References: <1474358360-29901-1-git-send-email-sean.wang@mediatek.com>
 <1474358360-29901-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56618 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751501AbcITTiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 15:38:09 -0400
Content-Disposition: inline
In-Reply-To: <1474358360-29901-4-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 03:59:20PM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> Add the dts property for the capability if TRGMII supported on GAMC0
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index 6103e55..32f79d8 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -31,7 +31,10 @@ Optional properties:
>  Required properties:
>  - compatible: Should be "mediatek,eth-mac"
>  - reg: The number of the MAC
> -- phy-handle: see ethernet.txt file in the same directory.
> +- phy-handle: see ethernet.txt file in the same directory and
> +	the additional phy-mode "tgrmii" is provided in order to connect
> +	with the internal switch MT7530 which is only applicable when reg
> +	is equal to 0.

Humm. How is the switch connected? Is it on the MDIO bus?

If it is on the mdio bus, the binding is going to look something like:

eth: ethernet@1b100000 {
        compatible = "mediatek,mt7623-eth";
        reg = <0 0x1b100000 0 0x20000>;
        clocks = <&topckgen CLK_TOP_ETHIF_SEL>,
                 <&ethsys CLK_ETHSYS_ESW>,
                 <&ethsys CLK_ETHSYS_GP2>,
                 <&ethsys CLK_ETHSYS_GP1>;
        clock-names = "ethif", "esw", "gp2", "gp1";
        interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW
                      GIC_SPI 199 IRQ_TYPE_LEVEL_LOW
                      GIC_SPI 198 IRQ_TYPE_LEVEL_LOW>;
        power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
        resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
        reset-names = "eth";
        mediatek,ethsys = <&ethsys>;
        mediatek,pctl = <&syscfg_pctl_a>;
        #address-cells = <1>;
        #size-cells = <0>;

        gmac1: mac@0 {
                compatible = "mediatek,eth-mac";
                reg = <0>;
        };

        gmac2: mac@1 {
                compatible = "mediatek,eth-mac";
                reg = <1>;
        };

        mdio-bus {
               reg = <1>;
               #address-cells = <1>;
               #size-cells = <0>;

               switch0: switch0@0 {
                       compatible = "marvell,mv88e6085";
                       #address-cells = <1>;
                       #size-cells = <0>;
                       reg = <0>;
                       dsa,member = <0 0>;

                       ports {
                               #address-cells = <1>;
                               #size-cells = <0>;
                               port@0 {
                                       reg = <0>;
                                       label = "lan0";
...
...

In this case the switch is an MDIO device, not an PHY. It will not
have an phy-mode. It cannot have a phy mode, it is not a PHY.

Or am i missing something here?

Thanks
	Andrew
