From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear
 WNR854T
Date: Sat, 16 Jul 2016 18:34:08 +0200
Message-ID: <20160716163408.GG1777@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Imre Kaloz <kaloz-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468679348-10522-7-git-send-email-jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +	chosen {
> +		bootargs = "console=ttyS0,115200n8 earlyprintk";
> +		linux,stdout-path = &uart0;
> +	};

You can put the board rate etc in the stdout-patch. Something like:

                stdout-path = "serial0:115200n8";

> +	gpio-leds {
> +		compatible = "gpio-leds";
> +		pinctrl-0 = <&pmx_power_led &pmx_power_led_blink &pmx_wan_led>;
> +		pinctrl-names = "default";
> +
> +		led@0 {
> +			label = "power:green";

Documentation/leds/leds-class.txt says:

LED Device Naming
=================

Is currently of the form:

"devicename:colour:function"

> +	dsa@0 {
> +		compatible = "marvell,dsa";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		dsa,ethernet = <&ethport>;
> +		dsa,mii-bus = <&mdio>;
> +
> +		switch@0 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
> +
> +			port@0 {
> +				reg = <0>;
> +				label = "lan3";
> +			};
> +
> +			port@1 {
> +				reg = <1>;
> +				label = "lan4";
> +			};
> +
> +			port@2 {
> +				reg = <2>;
> +				label = "wan";
> +			};
> +
> +			port@3 {
> +				reg = <3>;
> +				label = "cpu";
> +			};
> +
> +			port@5 {
> +				reg = <5>;
> +				label = "lan1";
> +			};
> +
> +			port@7 {
> +				reg = <7>;
> +				label = "lan2";
> +			};
> +		};
> +	};
> +};

This all looks sensible, if a bit mixed up. Lets discuss the switch
issue in a different thread.

> +&devbus_bootcs {
> +	status = "okay";
> +
> +	devbus,keep-config;
> +
> +	flash@0 {
> +		compatible = "cfi-flash";
> +		reg = <0 0x800000>;
> +		bank-width = <1>;
> +		#address-cells = <1>;
> +		#size-cells = <1>;

Documentation/devicetree/bindings/mtd/partition.txt says the
partitions should be placed under a partitions node. There are some
conditions when that does not work. So please try it, and if it does
not, ignore my comment...

> +
> +		partition@0 {
> +			label = "kernel";
> +			reg = <0x0 0x100000>;
> +		};
> +
> +		partition@100000 {
> +			label = "rootfs";
> +			reg = <0x100000 0x660000>;
> +		};
> +
> +		partition@760000 {
> +			label = "uboot_env";
> +			reg = <0x760000 0x20000>;
> +		};
> +
> +		partition@780000 {
> +			label = "uboot";
> +			reg = <0x780000 0x80000>;
> +			read-only;
> +		};
> +	};
> +};

> +&pinctrl {
> +	pinctrl-0 = <&pmx_pci_gpios &pmx_ge>;
> +	pinctrl-names = "default";
> +
> +	pmx_power_led: pmx-power-led {
> +		marvell,pins = "mpp0";
> +		marvell,function = "gpio";
> +	};
> +
> +	pmx_reset_switch: pmx-reset-switch {
> +		marvell,pins = "mpp1";
> +		marvell,function = "gpio";
> +	};

Ah, this is missing from your DSA node. You can then add:

reset-gpios = <&gpio0 1 GPIO_ACTIVE_LOW>;

inside the switch@0 node.

> +	pmx_ge: pmx-ge {
> +		marvell,pins = "mpp9", "mpp12",	"mpp13", "mpp14", "mpp15",
> +				"mpp16", "mpp17", "mpp18", "mpp19";
> +		marvell,function = "ge";
> +	};
> +};

This can go into the .dtsi file your previous patch added. 

> +
> +&uart0 {
> +	/* Pin 1: Tx, Pin 7: Rx, Pin 8: Gnd */
> +	status = "okay";

Nice to see the comment.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
