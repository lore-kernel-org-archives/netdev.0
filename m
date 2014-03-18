From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon
 hip04 ethernet
Date: Tue, 18 Mar 2014 10:39:05 -0700
Message-ID: <CAGVrzcZY4Z6kFRUP54PtaZUAX0+cEmYfnunJQFN8TC66xooLeg@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:48700 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaCRRjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:39:46 -0400
In-Reply-To: <1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-18 1:40 GMT-07:00 Zhangfei Gao <zhangfei.gao@linaro.org>:
> This patch adds the Device Tree bindings for the Hisilicon hip04
> Ethernet controller, including 100M / 1000M controller.
>
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>  .../bindings/net/hisilicon-hip04-net.txt           |   74 ++++++++++++++++++++
>  1 file changed, 74 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> new file mode 100644
> index 0000000..c918f08
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> @@ -0,0 +1,74 @@
> +Hisilicon hip04 Ethernet Controller
> +
> +* Ethernet controller node
> +
> +Required properties:
> +- compatible: should be "hisilicon,hip04-mac".
> +- reg: address and length of the register set for the device.
> +- interrupts: interrupt for the device.
> +- port: ppe port number connected to the controller: range from 0 to 31.
> +- speed: 100 (100M) or 1000 (1000M).
> +- id: should be different and fe should be 0.
> +
> +Optional Properties:
> +- phy-handle : the phandle to a PHY node
> +
> +
> +* Ethernet ppe node: control rx & tx fifos of all ethernet controllers
> +
> +Required properties:
> +- compatible: should be "hisilicon,hip04-ppebase".
> +- reg: address and length of the register set for the node.
> +
> +
> +* MDIO bus node:
> +
> +Required properties:
> +
> +- compatible: "hisilicon,hip04-mdio"
> +- Inherets from MDIO bus node binding[1]
> +[1] Documentation/devicetree/bindings/net/phy.txt
> +
> +Example:
> +       mdio {
> +               compatible = "hisilicon,hip04-mdio";
> +               reg = <0x28f1000 0x1000>;
> +               #address-cells = <1>;
> +               #size-cells = <0>;
> +
> +               phy0: ethernet-phy@0 {
> +                       reg = <0>;
> +                       marvell,reg-init = <18 0x14 0 0x8001>;
> +                       device_type = "ethernet-phy";

You are missing a compatible string such as
"ethernet-phy-ieee802.3-c22", please take a look at
Documentation/devicetree/bindings/net/phy.txt for an example.

device_type is deprecated and should be removed.

> +               };
> +
> +               phy1: ethernet-phy@1 {
> +                       reg = <1>;
> +                       marvell,reg-init = <18 0x14 0 0x8001>;
> +                       device_type = "ethernet-phy";
> +               };
> +       };
> +
> +       ppebase: ppebase@28c0000 {
> +               compatible = "hisilicon,hip04-ppebase";
> +               reg = <0x28c0000 0x10000>;

This should probably look like:

                    #address-cells = <0>;
                    #size-cells = <0>;

                    eth0_port: port@0 {
                         reg = <0>;
                    };

                    eth1_port: port@1f {
                         reg = <31>;
                    };

This looks like something similar to mv643xx_eth, you should see
Documentation/devicetree/bindings/marvell.txt for hints on how to
model the representation in a similar fashion.

> +       };
> +
> +       fe: ethernet@28b0000 {
> +               compatible = "hisilicon,hip04-mac";
> +               reg = <0x28b0000 0x10000>;
> +               interrupts = <0 413 4>;
> +               port = <31>;

I do not think this is the right way to expose that, port should be
specialized to e.g: hisilicon,port, or you should use a phandle to the
"ppebase" node which exposes differents ports as subnodes:

                    hisilicon,port-handle = <&eth0_port>;

> +               speed = <100>;

max-speed is the standard property for this

> +               id = <0>;

id here is a software concept, either you create properly numbered
aliases for these nodes, and use of_alias_get_id(), or you do not use
these identifiers at all.

> +       };
> +
> +       ge0: ethernet@2800000 {
> +               compatible = "hisilicon,hip04-mac";
> +               reg = <0x2800000 0x10000>;
> +               interrupts = <0 402 4>;
> +               port = <0>;
> +               speed = <1000>;
> +               id = <1>;
> +               phy-handle = <&phy0>;
> +       };
> --
> 1.7.9.5
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
