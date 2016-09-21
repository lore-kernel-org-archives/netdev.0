From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next 3/3] net: ethernet: mediatek: add the dts property to set if TRGMII supported on GMAC0
Date: Wed, 21 Sep 2016 14:16:30 +0800
Message-ID: <1474438590-6855-1-git-send-email-sean.wang@mediatek.com>
References: <1474358360-29901-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
        <keyhaede@gmail.com>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:25776 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752852AbcIUGQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 02:16:36 -0400
In-Reply-To: <1474358360-29901-4-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Tue, 20 Sep 2016 21:37:58 +0200, Andrew Lunn <andrew@lunn.ch> wrote:
>On Tue, Sep 20, 2016 at 03:59:20PM +0800, sean.wang@mediatek.com wrote:
>> From: Sean Wang <sean.wang@mediatek.com>
>>
>> Add the dts property for the capability if TRGMII supported on GAMC0
>>
>> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
>> ---
>>  Documentation/devicetree/bindings/net/mediatek-net.txt | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> index 6103e55..32f79d8 100644
>> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
>> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
>> @@ -31,7 +31,10 @@ Optional properties:
>>  Required properties:
>>  - compatible: Should be "mediatek,eth-mac"
>>  - reg: The number of the MAC
>> -- phy-handle: see ethernet.txt file in the same directory.
>> +- phy-handle: see ethernet.txt file in the same directory and
>> +     the additional phy-mode "tgrmii" is provided in order to connect
>> +     with the internal switch MT7530 which is only applicable when reg
>> +     is equal to 0.
>
>Humm. How is the switch connected? Is it on the MDIO bus?

the switch is connected to MDIO bus

>If it is on the mdio bus, the binding is going to look something like:
>
>eth: ethernet@1b100000 {
>        compatible = "mediatek,mt7623-eth";
>        reg = <0 0x1b100000 0 0x20000>;
>        clocks = <&topckgen CLK_TOP_ETHIF_SEL>,
>                 <&ethsys CLK_ETHSYS_ESW>,
>                 <&ethsys CLK_ETHSYS_GP2>,
>                 <&ethsys CLK_ETHSYS_GP1>;
>        clock-names = "ethif", "esw", "gp2", "gp1";
>        interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW
>                      GIC_SPI 199 IRQ_TYPE_LEVEL_LOW
>                      GIC_SPI 198 IRQ_TYPE_LEVEL_LOW>;
>        power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
>        resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
>        reset-names = "eth";
>        mediatek,ethsys = <&ethsys>;
>        mediatek,pctl = <&syscfg_pctl_a>;
>        #address-cells = <1>;
>        #size-cells = <0>;
>
>        gmac1: mac@0 {
>                compatible = "mediatek,eth-mac";
>                reg = <0>;
>        };
>
>        gmac2: mac@1 {
>                compatible = "mediatek,eth-mac";
>                reg = <1>;
>        };
>
>        mdio-bus {
>               reg = <1>;
>               #address-cells = <1>;
>               #size-cells = <0>;
>
>               switch0: switch0@0 {
>                       compatible = "marvell,mv88e6085";
>                       #address-cells = <1>;
>                       #size-cells = <0>;
>                       reg = <0>;
>                       dsa,member = <0 0>;
>
>                       ports {
>                               #address-cells = <1>;
>                               #size-cells = <0>;
>                               port@0 {
>                                       reg = <0>;
>                                       label = "lan0";
>...
>...
>In this case the switch is an MDIO device, not an PHY. It will not
>have an phy-mode. It cannot have a phy mode, it is not a PHY.
>
>Or am i missing something here?
>
>Thanks
>

1)

The switch driver is not supported for DSA so far yet 
but DSA is good thing and I will try make it happen
in the near future.

And another question about DSA, that is
if I use DSA for switch, how to know the relationship
between MAC and DSA ? such like I could know relationship 
between MAC and PHY by phy-handle.

The cause I ask is becasue I think it's good if the topology
about MAC/PHYs/Switch is known just by dts files.

2)

The phy-mode I mention is for fixed-link. For current MAC driver, 
it just uses fixed phy to adapt into the part of switch, so the 
device tree looks something like the below. 

&eth {
        status = "okay";
        gmac0: mac@0 {
                compatible = "mediatek,eth-mac";
                reg = <0>;
                phy-mode = "trgmii";
                fixed-link {
                        speed = <1000>;
                        full-duplex;
                        pause;
                };
        };

        gmac1: mac@1 {
                compatible = "mediatek,eth-mac";
                reg = <1>;
                phy-handle = <&phy5>;
        };
