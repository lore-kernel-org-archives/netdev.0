From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Mon, 4 Jul 2016 16:04:58 +0200
Message-ID: <20160704140458.GC3282@lunn.ch>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1467623084-15471-2-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 04, 2016 at 02:34:41PM +0530, Kedareswara rao Appana wrote:
> Device-tree binding documentation for xilinx gmiitorgmii converter.
> 
> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
> Changes for v2:
> --> New patch.
> 
>  .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 31 ++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> new file mode 100644
> index 0000000..d11e259
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> @@ -0,0 +1,31 @@
> +* XILINX GMIITORGMII Converter Driver
> +
> +The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
> +Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
> +Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
> +This core can be used in all three modes of operation(10/100/1000 Mb/s).
> +The Management Data Input/Output (MDIO) interface is used to configure the
> +Speed of operation. This core can switch dynamically between the three
> +Different speed modes by configuring the conveter register through mdio write.
> +
> +The MDIO is a bus to which the PHY devices are connected.  For each
> +device that exists on this bus, a child node should be created.  See
> +the definition of the PHY node in booting-without-of.txt for an example
> +of how to define a PHY.
> +
> +Required properties:
> +  - compatible : Should be "xlnx,gmiitorgmii"
> +  - reg : The ID number for the phy, usually a small integer
> +
> +Example:
> +	mdio {
> +                #address-cells = <1>;
> +                #size-cells = <0>;
> +		ethernet-phy@0 {
> +			......
> +		};
> +                gmii_to_rgmii: gmii_to_rgmii@8 {
> +                        compatible = "xlnx,gmiitorgmii";
> +                        reg = <8>;
> +                };
> +        };

Hi Kedareswara

So looking at the device tree, you have the gmiitorgmii as an mdio
device. It will get probed as an mdio device, and from that you know
the address on the bus. However, your driver does not actually do
this. xilinx_gmii2rgmii.c is just a library of two functions, and does
not use any of this device tree information. You device tree binding
is completely bogus.

What i think is a much more logical structure, and fits the hardware,
which is what DT is all about, is to make your driver an mdio driver.
Also, have a phy-handle pointing to the PHY in the gmii_to_rgmii node.
You then no longer need the exported gmii2rgmii_phyprobe() function.

Next, you want gmiitorgmii driver to register a phy. The MAC driver
can then look this up using phy-handle:

       mdio {
                #address-cells = <1>;
                #size-cells = <0>;

                phy: ethernet-phy@0 {
                        reg = <0>;
                };

                gmii_to_rgmii: gmii-to-rgmii@8 {
                        compatible = "xlnx,gmiitorgmii";
                        reg = <8>;
			phy-handle = <&phy>;
                };
       };

        macb0: ethernet@fffc4000 {
                compatible = "cdns,at32ap7000-macb";
                reg = <0xfffc4000 0x4000>;
                interrupts = <21>;
                phy-mode = "rmii";
		phy-handle = <&gmii_to_rgmii>
                local-mac-address = [3a 0e 03 04 05 06];
                clock-names = "pclk", "hclk", "tx_clk";
                clocks = <&clkc 30>, <&clkc 30>, <&clkc 13>;
                ethernet-phy@1 {
                        reg = <0x1>;
                        reset-gpios = <&pioE 6 1>;
                };
        };

This description is the same as the figure in the data sheet. You have
the gmii_to_rgmii which passes through to the real PHY.

The phy device that gmiitorgmii registers needs to pass through all
its operations to the real PHY. The exception is read_status()
function. You want to wrap this, so that after it completes and you
know the speed the PHY is using, you set the same speed in your
gmiitorgmii device.

Everything then becomes transparent. There is no need to change the
MAC driver, and you have a generic solution which will work with any
MAC and PHY.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
