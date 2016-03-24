From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Thu, 24 Mar 2016 23:06:07 +0100
Message-ID: <20160324220607.GE15624@lunn.ch>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com>
 <20160219201415.GA9884@lunn.ch>
 <90A7E81AE28BAE4CBDDB3B35F187D264402F31B5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56442 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbcCXWGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 18:06:14 -0400
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402F31B5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It appears the dsa.c is not able to attach my underlying net
> device. And that seems to be due to it is unable to find the
> mdio_bus.


> So I modified my net device driver so that in probe it calls
> of_mdiobus_register instead of mdiobus_register.

> And of_mdiobus_register seems to be looking for some kind of phy
> definitions in the device tree, which it does not find. And so it
> does not appear to register the bus in such a way that dsa.c can
> connect to it.

Hi Bryan

Are the sources for the ethernet driver available? I don't see them in
net-next.

There are two common ways for this to work, depending on the driver
architecture. Marvell devices have a separate mdio driver. In
kirkwood.dtsi you see:

               mdio: mdio-bus@72004 {
                        compatible = "marvell,orion-mdio";
                        #address-cells = <1>;
                        #size-cells = <0>;
                        reg = <0x72004 0x84>;
                        interrupts = <46>;
                        clocks = <&gate_clk 0>;
                        status = "disabled";

                        /* add phy nodes in board file */
                };

and mvmdio.c calls of_mdiobus_register() passing this device node.

The other way is that the mdio is part of the ethernet
driver. e.g. for the Freescale FEC:

&fec1 {
        phy-mode = "rmii";
        pinctrl-names = "default";
        pinctrl-0 = <&pinctrl_fec1>;
        status = "okay";

        mdio0: mdio {
                #address-cells = <1>;
                #size-cells = <0>;
                status = "okay";
        };
};

In this case, of_mdiobus_register() is passed the mdio0 device node.

> &gpmc {
> 	status = "okay";
> 	ranges = <0 0 0x10000000 0x08000000>;	// CS0: 128M 
> 	pinctrl-names = "default";
> 	pinctrl-0 = <&gpmc_pins>;
> 	lan9352: ethernet@gpmc {
> 		compatible = "microchip,lan9352";
> 		interrupt-parent = <&gpio0>;
> 		interrupts = <7 8>;//7==GPIO bit 7, 8 = Active low level triggered.
> 
> 		bank-width = <2>;
> 
> 		phy-mode = "mii";
> 
> 		reg = <0 0 0x10000>;
> 
> 		reg-io-width = <4>;
> 		microchip,save-mac-address;
> 		microchip,irq-push-pull;

So i expect to see something like this here:

            	mdio0: mdio {
                	#address-cells = <1>;
                	#size-cells = <0>;
                	status = "okay";
        	};
> 	};
> };
> 
> / {
> 	dsa@0 {
> 		compatible = "microchip,dsa";
> 		#address-cells = <2>;
> 		#size-cells = <0>;
> 		dsa,ethernet = <&lan9352>;
> 		dsa,mii-bus = <&lan9352>;

and this would be

		dsa,mii-bus = <&mdio0>;

> 		switch@0 {
> 			#address-cells = <1>;
> 			#size-cells = <0>;
> 			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
> 			port@0 {
> 				reg = <0>;
> 				label = "cpu";
> 			};
> 			port@1 {
> 				reg = <1>;
> 				label = "lan1";
> 			};
> 			port@2 {
> 				reg = <2>;
> 				label = "lan2";
> 			};
> 		};
> 	};
> };

  Andrew
