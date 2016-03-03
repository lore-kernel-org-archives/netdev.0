From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Thu, 3 Mar 2016 21:27:16 +0100
Message-ID: <20160303202716.GQ15541@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <56D88757.7050803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49028 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbcCCU1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 15:27:19 -0500
Content-Disposition: inline
In-Reply-To: <56D88757.7050803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - first of all, the original design around the special platform device
> did not allow multiple switch trees within the same system to coexist
> (dsa platform device were not numbered (id = -1)), but such a thing
> could exist and is desirable, you could have a single switch hanging off
> eth0, and more switches hanging off eth1 for instance, and not be part
> of the same tree

I have hardware i can test such a setup on. 

> 
> - the direction we want to move people to is to make them use DSA for
> their switch needs and get the proven benefits from having a consistent
> per-port slave network device model along with a good binding for
> representing ports within a switch (and all thedetails associated with
> that), the next step is to make this available to not just MDIO drivers,
> which you are addressing here, but then, being able to call
> dsa_switch_register() just becomes a service from the network stack with
> DSA support included, if we need the special dsa platform device again,
> we are not way better than where we were before

We are a bit better. dsa_switch_register() does not care about the
communication channel to the switch. An SPI based switch should now be
possible, as well as a cleaner way to do MMIO switches.

> I still see the need for the dsa platform device more as an artifact
> than something absolutely needed. The way I would see the probing logic
> (simplified) is something along these lines:
> 
> - switch driver gets probed (from a bus subsystem)
> - if it is the first one in the tree (thanks to the chip index telling
> it so), it registers with dsa, locates the master netdev, and creates
> the dst structure for it there in master netdev->dsa_ptr
> - if not, then return EPROBE_DEFER until we get the first switch in tree
> to be probed
> - subsequent switches also locate their chip index, locate the master
> netdev, fetch a valid netdev->dsa_ptr now, and add themselves there
> 
> and do to that, there is just resident code in the kernel, just waiting
> for sucht hings to appear, which is already more or less the case, it
> does not need to be a platform device though.

So lets take an example. I posted a dts file for a board with three
switches:

http://www.spinics.net/lists/arm-kernel/msg484955.html

This board has an MDIO bus per switch, via a mux:

	mdio-mux {
		compatible = "mdio-mux-gpio";
		pinctrl-0 = <&pinctrl_mdio_mux>;
		pinctrl-names = "default";
		gpios = <&gpio0 8  GPIO_ACTIVE_HIGH
			 &gpio0 9  GPIO_ACTIVE_HIGH
			 &gpio0 24 GPIO_ACTIVE_HIGH
			 &gpio0 25 GPIO_ACTIVE_HIGH>;
		mdio-parent-bus = <&mdio1>;
		#address-cells = <1>;
		#size-cells = <0>;

		mdio_mux_1: mdio@1 {
			reg = <1>;
			#address-cells = <1>;
			#size-cells = <0>;
		};

		mdio_mux_2: mdio@2 {
			reg = <2>;
			#address-cells = <1>;
			#size-cells = <0>;
		};

		mdio_mux_4: mdio@4 {
			reg = <4>;
			#address-cells = <1>;
			#size-cells = <0>;
		};

		mdio_mux_8: mdio@8 {
			reg = <8>;
			#address-cells = <1>;
			#size-cells = <0>;
		};
	};

And the current switches are represented thus:

	dsa@0 {
		compatible = "marvell,dsa";
		#address-cells = <2>;
		#size-cells = <0>;

		dsa,ethernet = <&fec1>;
		dsa,mii-bus = <&mdio_mux_1>;

		/* 6352 - Primary - 7 ports */
		switch0: switch@2 {
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <0x00 0>;
			eeprom-length = <512>;

			port@0 {
				reg = <0>;
				label = "lan0";
			};

			port@1 {
				reg = <1>;
				label = "lan1";
			};

			port@2 {
				reg = <2>;
				label = "lan2";
			};

			switch0port5: port@5 {
				reg = <5>;
				label = "dsa";
				phy-mode = "rgmii-txid";
				link = <&switch1port6
					&switch2port9>;
				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			};

			port@6 {
				reg = <6>;
				label = "cpu";
				fixed-link {
					speed = <100>;
					full-duplex;
				};
			};

		};

		/* 6352 - Secondary - 7 ports */
		switch1: switch@0 {
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <0x00 1>;
			eeprom-length = <512>;
			mii-bus = <&mdio_mux_2>;

			port@0 {
				reg = <0>;
				label = "lan3";
			};

			port@1 {
				reg = <1>;
				label = "lan4";
			};

			port@2 {
				reg = <2>;
				label = "lan5";
			};

			switch1port5: port@5 {
				reg = <5>;
				label = "dsa";
				link = <&switch2port9>;
				phy-mode = "rgmii-txid";
				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			};

			switch1port6: port@6 {
				reg = <6>;
				label = "dsa";
				phy-mode = "rgmii-txid";
				link = <&switch0port5>;
				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			};
		};

		/* 6185 - 10 ports */
		switch2: switch@6 {
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <0x00 2>;
			mii-bus = <&mdio_mux_4>;

			port@0 {
				reg = <0>;
				label = "lan6";
			};

			port@1 {
				reg = <1>;
				label = "lan7";
			};

			port@2 {
				reg = <2>;
				label = "lan8";
			};

			port@3 {
				reg = <3>;
				label = "optical3";
				fixed-link {
					speed = <1000>;
					full-duplex;
					link-gpios = <&gpio6 2 GPIO_ACTIVE_HIGH>;
				};
			};

			port@4 {
				reg = <4>;
				label = "optical4";
				fixed-link {
					speed = <1000>;
					full-duplex;
					link-gpios = <&gpio6 3 GPIO_ACTIVE_HIGH>;

				};
			};

			switch2port9: port@9 {
				reg = <9>;
				label = "dsa";
				phy-mode = "rgmii-txid";
				link = <&switch1port5
					&switch0port5>;
				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			};
		};
	};
};

We want to break this up into three switch devices, each hanging off
their mdio bus.

Here is the first switch:

		mdio_mux_1: mdio@1 {
			reg = <1>;
			#address-cells = <1>;
			#size-cells = <0>;
			
			/* 6352 - Primary - 7 ports */
			switch0: switch@2 {
				compatible = "marvell,mv88e6352"; 

compatible string now needed here.

				#address-cells = <1>;
				#size-cells = <0>;
				reg = <0x00>;

reg is now the mdio address, or for an SPI device, the address on the
SPI bus. We need some other identifier for where this switch fits into
the dst.

				dsa,member = <0 0>;

This property is used to associate switches together. The first digit
identifies which switch tree this switch belongs in. The second digit
is the location within that tree.

Does 0 need to be special? I don't think so. See the CPU port below,
and the points at the end.

				eeprom-length = <512>;
	
				port@0 {
					reg = <0>;
					label = "lan0";
				};
				...	
				switch0port5: port@5 {
					reg = <5>;
					label = "dsa";
					phy-mode = "rgmii-txid";
					link = <&switch1port6
						&switch2port9>;

These phandles have to be unique, otherwise the DT compiler will
complain. So this should be enough for us to unique identify the
switch on the other end.

					fixed-link {
						speed = <1000>;
						full-duplex;
					};
				};
	
				port@6 {
					reg = <6>;
					label = "cpu";
					ethernet = <&fec1>;

We put the link to the host here. This makes it easier in the future
to have multiple CPU interfaces.

					fixed-link {
						speed = <100>;
						full-duplex;
					};
				};
			};
			
		};

The second switch on a different mdio bus

		mdio_mux_2: mdio@2 {
			reg = <2>;
			#address-cells = <1>;
			#size-cells = <0>;

			/* 6352 - Secondary - 7 ports */
			switch1: switch@0 {
				compatible = "marvell,mv88e6352"; 
				#address-cells = <1>;
				#size-cells = <0>;
				reg = <0x00>;

				dsa,member = <0 1>;

See switch tree 0, switch 1 on that tree.

				eeprom-length = <512>;
	
				port@0 {
					reg = <0>;
					label = "lan3";
				};
	
				switch1port6: port@6 {
					reg = <6>;
					label = "dsa";
					phy-mode = "rgmii-txid";
					link = <&switch0port5>;
The corresponding links to those in switch 0.

					fixed-link {
						speed = <1000>;
						full-duplex;
					};
				};

			};


The third switch is as you would expect, dsa,member = <0 2>;

The probe order does not actually matter. You allocate the dst when
the first switch arrives, and plug that switch in. You then evaluate
the dst. Are all dsa links fulfilled. If yes, you have the full tree,
and you can set it up and running. If no, wait until more switches are
registered.

This is quite a big change, so why not make it bigger...

One thing i don't like is the complexity we have in matching phys to
ports, and fixed-link phys. Maybe we should consolidate this:

1) The switch device should use mdiobus_alloc()/mdiobus_register() for
its own MDIO bus.
2) ports use phy-handle to point to phys on their own mdio bus.

Ordering should be O.K, the switch needs to instantiate its own mdio
bus before calling dsa_switch_register().

3) We make a fixed-link-mdio device, which also uses
mdiobus_alloc()/mdiobus_register(), giving us fixed-link phys we can
reference in the normal way with phy-handle.

This last change makes MAC drivers simpler, they just need to support
phy-handle and they get fixed-phy for free. It removes the 32
fixed-phy restrictions, since we can have multiple instances of the
fixed-link-mdio device. And it fixes the problems with alloc/free
cycles in the current fixed phy code. And dsa does not need to do
anything special for fixed-phys.

One down side is that it is totally fictitious hardware, so should not
really be in device tree....

       Andrew
