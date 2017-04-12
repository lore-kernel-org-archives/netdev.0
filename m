From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Wed, 12 Apr 2017 16:58:26 -0700
Message-ID: <6fdcec91-829b-70c9-8780-992b67f6831a@gmail.com>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
 <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
 <20170411231424.GA6174@lunn.ch>
 <6de72d4c-5634-f3d6-5bfd-fcc0acda0b83@gmail.com>
 <417fdaa1-7aba-e646-8a50-043322f1410d@gmail.com>
 <20170412221016.GA29708@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412221016.GA29708-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/12/2017 03:10 PM, Andrew Lunn wrote:
>>>>> To give some more background and rational for this change.
>>>>>
>>>>> On a platform where we have a parent MDIO bus, backed by the
>>>>> mdio-bcm-unimac.c driver, we also register a slave MII bus (through
>>>>> net/dsa/dsa2.c) which is parented to this UniMAC MDIO bus through an
>>>>> assignment of of_node. This slave MII bus is created in order to
>>>>> intercept reads/writes to problematic addresses (e.g: that clashes with
>>>>> another piece of hardware).
>>>>>
>>>>> This means that the slave DSA MII bus inherits all child nodes from the
>>>>> originating master MII bus. This also means that when the slave MII bus
>>>>> is probed via of_mdiobus_register(), we probe the same devices twice:
>>>>> once through the master, another time through the slave.
>>>>
>>>> Ah, O.K. This makes more sense. On the hardware i have, we get three
>>>> deep in MDIO busses. We have the FEC mdio bus. On top of that we have
>>>> a gpio-mux-mdio, and on top of that we have the mv88e6xxx mdio
>>>> bus. And i've never seen issues.
>>>>
>>>> So your real problem here is you have two mdio busses using the same
>>>> device tree properties. I would actually say that is just plain
>>>> broken.
>>>
>>> From a Device Tree/HW representation perspective, we do have the
>>> external BCM53125 switch physically attached to the 7445/7278
>>> SWITCH_MDIO bus (backed by mdio-bcm-unimac) so in that regard the
>>> representation is correct. There is also an integrated Gigabit PHY
>>> (bcm7xxx) which is attached to that bus.
> 
> This is made harder by you talking about a board which does not appear
> to have its DT file in mainline. So i'm having to guess what it looks
> like.

The DT binding is in tree and provides an example of how the switch
looks like, below is the example, but I am also adding the MDIO bus and
the PHYs just so you can see how things wind up:

switch_top@f0b00000 {
        compatible = "simple-bus";
        #size-cells = <1>;
        #address-cells = <1>;
        ranges = <0 0xf0b00000 0x40804>;

        ethernet_switch@0 {
                compatible = "brcm,bcm7445-switch-v4.0";
                #size-cells = <0>;
                #address-cells = <1>;
                reg = <0x0 0x40000
                        0x40000 0x110
                        0x40340 0x30
                        0x40380 0x30
                        0x40400 0x34
                        0x40600 0x208>;
                reg-names = "core", "reg", intrl2_0", "intrl2_1",
                            "fcb, "acb";
                interrupts = <0 0x18 0
                                0 0x19 0>;
                brcm,num-gphy = <1>;
                brcm,num-rgmii-ports = <2>;
                brcm,fcb-pause-override;
                brcm,acb-packets-inflight;

                ports {
                        #address-cells = <1>;
                        #size-cells = <0>;

                        port@0 {
                                label = "gphy";
                                reg = <0>;
				phy-handle = <&phy5>;
                        };

			sw0port1: port@1 {
				label = "rgmii_1";
				reg = <1>;
				phy-mode = "rgmii";
				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			}
                };
        };

	mdio@403c0 {
		reg = <0x403c0 0x8 0x40300 0x18>;
		#address-cells = <0x1>;
		#size-cells = <0x0>;
		compatible = "brcm,unimac-mdio";
		reg-names = "mdio", "mdio_indir_rw";

		switch: switch@0 {
			broken-turn-around;
			reg = <0x0>;
			compatible = "brcm,bcm53125";
			#address-cells = <1>;
			#size-cells = <0>;

			ports {
				..
				port@8 {
					ethernet = <&sw0port1>;
				};
				...
			};
		};

		phy5: ethernet-phy@5 {
			reg = <0x5>;
			compatible = "ethernet-phy-ieee802.3-c22";
		};
	};
};


> 
> So what i think we are talking about is this bit of code:
> 
> static int bcm_sf2_mdio_register(struct dsa_switch *ds)
> {
>         struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
>         struct device_node *dn;
>         static int index;
>         int err;
> 
>         /* Find our integrated MDIO bus node */
>         dn = of_find_compatible_node(NULL, NULL, "brcm,unimac-mdio");
>         priv->master_mii_bus = of_mdio_find_bus(dn);
>         if (!priv->master_mii_bus)
>                 return -EPROBE_DEFER;
> 
>         get_device(&priv->master_mii_bus->dev);
>         priv->master_mii_dn = dn;
> 
>         priv->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
>         if (!priv->slave_mii_bus)
>                 return -ENOMEM;
> 
>         priv->slave_mii_bus->priv = priv;
>         priv->slave_mii_bus->name = "sf2 slave mii";
>         priv->slave_mii_bus->read = bcm_sf2_sw_mdio_read;
>         priv->slave_mii_bus->write = bcm_sf2_sw_mdio_write;
>         snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "sf2-%d",
>                  index++);
>         priv->slave_mii_bus->dev.of_node = dn;
> 
> If i get you right, your switch is hanging off the MDIO bus
> "brcm,unimac-mdio" you find the dn for. You then register another MDIO
> bus using the exact same node? How does that make any sense? Isn't it
> a physical separate MDIO bus?

First, the main switch is memory mapped into the 7445 SoC's register
space. This switch has an external MDIO bus which connects to an
integrated Gigabit PHY at MDIO address 5, but also to a BCM53125 switch
at address 30.

Because of a bug in the D0 revision of the 7445, programming the
BCM53125 switch through MDIO ends-up programming the 7445 memory mapped
switch as well because the integrated 7445 switch has its pseudo-PHY
snooping accesses to the MDIO bus! What was done to work-around this is
to create a slave MII bus through DSA, and divert the reads/writes
from/to the BCM53125 by instead using internal 7445 switch registers
which isolate its pseudo-PHY from the MDIO bus, thus no double
programming anymore.

Since the BCM53125 switch is a) physically attached to the mdio@403c0
node, and b) needs to have visibility in the OF world for DSA to probe
it, this is what I did here.

The slave MII bus is using the same node here because that's the
simplest way to make this bus inherit the devices of interest from the
parent bus.

> So it should have its own set of nodes
> in the device tree. This is how we do it for the Marvell switches. See
> Documentation/devicetree/binding/net/dsa/marvell.txt and
> arch/arm/boot/dts/vf610-zii-dev-rev-b.dts. That DT blob uses
> phy-handle to link the switch ports to the phys on the mdio bus.

>From a pure HW representation, this is not quite correct, because the
switch is physically attached to mdio@403c0, but since we are
pathologically broken, we need something different here...
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
