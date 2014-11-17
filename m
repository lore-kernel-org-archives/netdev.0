From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Mon, 17 Nov 2014 16:58:57 +0100
Message-ID: <CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
	<5463B2AC.6090904@gmail.com>
	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>
	<54650E9C.7080708@gmail.com>
	<CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>
	<CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>,
	buytenh@wantstofly.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:64282 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaKQP65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 10:58:57 -0500
Received: by mail-ie0-f176.google.com with SMTP id ar1so117805iec.7
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 07:58:57 -0800 (PST)
In-Reply-To: <CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'am still failing to probe the DSA switch via the mii bus. I'am
unsure if i really probe it on the right way (mii bus and mii address)

The  IMX28 CPU board has two connected phys. These are successfully
probed by fec_enet_mii_probe and appear as eth0 and eth1 Interface. So
some mii bus probing is working fine there.

fec 800f0000.ethernet eth0: Freescale FEC PHY driver [Micrel KSZ8041]
(mii_bus:phy_addr=800f0000.etherne:01, irq=-1)
fec 800f4000.ethernet eth1: Freescale FEC PHY driver [Micrel KSZ8041]
(mii_bus:phy_addr=800f0000.etherne:03, irq=-1)

The last phy1 is connected with phy5 of the the switch board . All
phys are connected on the same mii bus of IMX28.
In the DSA part of the Device Tree I use the compatible Flag:
"fsl,gianfar-mdio"; That load the "bus->name=Freescale PowerQUICC MII
Bus"

Is this the right mii bus choice for me here on a imx28 board? or is
that another non existing mii bus?

Then I adapted a bit the 88E6060 driver to a 88e6071 driver. But
currently i only try to readout  the revison number.

Revsion Number:

88E6071 = 0x071

static char *mv88e6071_probe(struct mii_bus *bus, int sw_addr)
{
int ret;

ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
if (ret >= 0) {
ret &= 0xfff0;
if (ret == 0x0710)
return "Marvell 88E6071";
}

return NULL;
}


Part of my Device Tree

ahb@80080000 {

usb0: usb@80080000 {
vbus-supply = <&reg_usb0_vbus>;
status = "okay";
};

usb1: usb@80090000 {
vbus-supply = <&reg_usb1_vbus>;
status = "okay";
};

mac0: ethernet@800f0000 {
phy-mode = "rmii";
pinctrl-names = "default";
pinctrl-0 = <&mac0_pins_a>;
//phy-supply = <&reg_fec_3v3>;
phy-reset-gpios = <&gpio4 13 0>;
phy-reset-duration = <100>;
status = "okay";

       ethernet0-port@0 {
                phy-handle = <&ethphy0>;

                fixed-link {
                    speed = <1000>;
                    full-duplex;
                    };

};
};

mac1: ethernet@800f4000 {
phy-mode = "rmii";
pinctrl-names = "default";
pinctrl-0 = <&mac1_pins_a>;
status = "okay";

            ethernet1-port@1 {
                phy-handle = <&ethphy1>;

                fixed-link {
                    speed = <1000>;
                    full-duplex;
                    };
};
    };

    };

/*
 *   Marvell Distributed Switch Architecture Device Tree Bindings
 *
 *   A DSA node can contain multiple switch chips which are therefore
child nodes of
 *   the parent DSA node. The maximum number of allowed child nodes is 4
 */

dsa@0 {
        compatible = "marvell,dsa";
        #address-cells = <2>;
        #size-cells = <0>;

        interrupts = <10>;
        //dsa,ethernet = <&ethphy1>;
        //dsa,ethernet = <&eth1>;
        dsa,ethernet = <&mac1>;
        //dsa,ethernet = <&mac0>;
        dsa,mii-bus = <&mdio_bus>;

        switch@0 {
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <5 0>;   /* MDIO address 5, switch 0 in tree */

            port@0 {
                reg = <0>;
                label = "lan1";
                phy-handle = <&ethphy1>;
            };

            port@1 {
                reg = <1>;
                label = "lan2";
            };

            port@2 {
                reg = <2>;
                label = "lan3";
            };

            port@3 {
                reg = <3>;
                label = "lan4";
            };

            port@4 {
                reg = <4>;
                label = "lan5";
            };

            port@5 {
                reg = <5>;
                label = "cpu";
            };
        };
    };



eth3: eth3 {
    status = "okay";
    ethernet1-port@1 {
        phy-handle = <&ethphy1>;

        fixed-link {
                speed = <1000>;
                full-duplex;
            };
    };
};

mdio_bus: mdio@800f0040 {
        #address-cells = <1>;
        #size-cells = <0>;
   device_type = "mdio";
        //reg = <24520 20>;
        //reg = <0xd0072004 0x4>;
        compatible = "fsl,gianfar-mdio";
        //compatible = "fsl,mpc875-fec-mdio", "fsl,pq1-fec-mdio";
        //reg = <0xe00 0x188>;
        reg = <0x800f0040 0x188>;
        status = "okay";

         ethphy0: ethernet-phy@0 {

                compatible = "fsl,gianfar-mdio";
                device_type = "network";
                model = "FEC";

                reg = <0>;
         };

         ethphy1: ethernet-phy@1 {

                 compatible = "fsl,gianfar-mdio";
                 device_type = "network";
                 model = "FEC";

                 reg = <1>;
                };
                 //reg = <0xff>; */ /* No PHY attached */
                 //speed = <1000>;
                 //duple = <1>;
       };

dmesg Output

[   19.759175] fep->mii_bus->name=fec_enet_mii_bus
[   19.842656] fec 800f4000.ethernet eth1: Freescale FEC PHY driver
[Micrel KSZ8041] (mii_bus:phy_addr=800f0000.etherne:03, irq=-1)
[   19.887013] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[   20.900994] libphy: 800f0000.etherne:01 - Link is Up - 100/Full
[   20.907002] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>[   21.198275] systemd-journald[161]: Received SIGUSR1
[   23.066029] !!!!!enter dsa_init_module!!!!!
[   23.134637] !!!!Enter dsa Probe!!!!!
[   23.138256] Distributed Switch Architecture driver version 0.1
[   23.214204] !!!!!Enter dsa_of_probe!!!!!
[   23.218323] !!!!!mdio->name=mdio mdio->type=mdio
mdio->full_name=/mdio@800f0040 !!!!!
[   23.330114] !!!!!np->name=dsa np->type=<NULL> np->full_name=/dsa@0 !!!!!
[   23.336859] !!!!before of_mdio_find_bus!!!!!
[   23.433145] !!!!!enter of_mdio_find_bus!!!!!
[   23.437464] !!!!!enter of_mdio_bus_match!!!!!
[   23.590106] !!!!!enter of_mdio_bus_match!!!!!
[   23.594510] !!!!!enter of_mdio_bus_match!!!!!
[   23.598881] !!!!Leave of_mdio_find_bus !!!!!
[   23.855136] !!!!before of_parse_phandle dsa,ethernet!!!!!
[   23.898976] !!!!before of find_device_by_node!!!!!
[   23.948053] !!!!!ethernet->name=ethernet ethernet->type=<NULL>
ethernet->full_name=/ahb@80080000/ethernet@800f4000 !!!!!
[   24.050100] !!!!! enter of_find_device_by_node !!!!!
[   24.055150] !!!!! Leave of_find_device_by_node dev=c790fe10 !!!!!
[   24.189562] !!!!! dev->init_name=(null) !!!!!
[   24.230110]
[   24.230110] before to_platform_device test->name=800f4000.ethernet
[   24.237904] !!!!before of kzalloc!!!!!
[   24.331061] !!!!before pd->netdev!!!!!
[   24.420120] !!!!before dev_to_net_device!!!!!
[   24.424536] !!!!dev_put(dev)!!!!!
[   24.427864] !!!!kzalloc!!!!!
[   24.515908] !!!!platform_set_drv_data!!!!!
[   24.594206] !!!!!enter dev_to_mii_bus!!!!!
[   24.598353] !!!!!enter dsa_switch_setup!!!!!
[   24.667627] !!!!name=!!!!!
[   24.710108] !!!!bus->name=Freescale PowerQUICC MII Bus!!!!!
[   24.715729] !!!!pd->sw_addr=5!!!!!
[   24.719138] !!!!Enter dsa_switch_probe!!!!!
[   24.752377] libphy: 800f0000.etherne:03 - Link is Up - 100/Full
[   24.758382] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   24.920168] !!!!Leave dsa_switch_probe!!!!!
[   24.924406] eth1[0]: could not detect attached switch
[   24.929476] eth1[0]: couldn't create dsa switch instance (error -22)
[   25.090113] !!!!Leave dsa Probe!!!!!
[   25.120641] !!!!!leave dsa_init_module!!!!!

Best regards,

Oliver
