From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Thu, 13 Apr 2017 16:20:56 -0700
Message-ID: <d498c31b-1017-a42f-11cd-54a97814c0a8@gmail.com>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
 <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
 <20170411231424.GA6174@lunn.ch>
 <6de72d4c-5634-f3d6-5bfd-fcc0acda0b83@gmail.com>
 <417fdaa1-7aba-e646-8a50-043322f1410d@gmail.com>
 <20170412221016.GA29708@lunn.ch>
 <6fdcec91-829b-70c9-8780-992b67f6831a@gmail.com>
 <20170413215114.GB29708@lunn.ch>
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
In-Reply-To: <20170413215114.GB29708-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/13/2017 02:51 PM, Andrew Lunn wrote:
>> The DT binding is in tree and provides an example of how the switch
>> looks like, below is the example, but I am also adding the MDIO bus and
>> the PHYs just so you can see how things wind up:
>>
>> switch_top@f0b00000 {
>>         compatible = "simple-bus";
>>         #size-cells = <1>;
>>         #address-cells = <1>;
>>         ranges = <0 0xf0b00000 0x40804>;
>>
>>         ethernet_switch@0 {
>>                 compatible = "brcm,bcm7445-switch-v4.0";
>>                 #size-cells = <0>;
>>                 #address-cells = <1>;
>>                 reg = <0x0 0x40000
>>                         0x40000 0x110
>>                         0x40340 0x30
>>                         0x40380 0x30
>>                         0x40400 0x34
>>                         0x40600 0x208>;
>>                 reg-names = "core", "reg", intrl2_0", "intrl2_1",
>>                             "fcb, "acb";
>>                 interrupts = <0 0x18 0
>>                                 0 0x19 0>;
>>                 brcm,num-gphy = <1>;
>>                 brcm,num-rgmii-ports = <2>;
>>                 brcm,fcb-pause-override;
>>                 brcm,acb-packets-inflight;
>>
>>                 ports {
>>                         #address-cells = <1>;
>>                         #size-cells = <0>;
>>
>>                         port@0 {
>>                                 label = "gphy";
>>                                 reg = <0>;
>> 				phy-handle = <&phy5>;
>>                         };
>>
>> 			sw0port1: port@1 {
>> 				label = "rgmii_1";
>> 				reg = <1>;
>> 				phy-mode = "rgmii";
>> 				fixed-link {
>> 					speed = <1000>;
>> 					full-duplex;
>> 				};
>> 			}
>>                 };
>>         };
>>
>> 	mdio@403c0 {
>> 		reg = <0x403c0 0x8 0x40300 0x18>;
>> 		#address-cells = <0x1>;
>> 		#size-cells = <0x0>;
>> 		compatible = "brcm,unimac-mdio";
>> 		reg-names = "mdio", "mdio_indir_rw";
>>
>> 		switch: switch@0 {
>> 			broken-turn-around;
>> 			reg = <0x0>;
>> 			compatible = "brcm,bcm53125";
>> 			#address-cells = <1>;
>> 			#size-cells = <0>;
>>
>> 			ports {
>> 				..
>> 				port@8 {
>> 					ethernet = <&sw0port1>;
>> 				};
>> 				...
>> 			};
>> 		};
>>
>> 		phy5: ethernet-phy@5 {
>> 			reg = <0x5>;
>> 			compatible = "ethernet-phy-ieee802.3-c22";
>> 		};
>> 	};
>> };
> 
> So phy5 is connected to the internal switch with a phy-handle. But
> because of your double usage of this node, it also can be mapped into
> the external switches port 5?
> 
> Is that your problem?

Kind of, it does translate into an invalid mapping by virtue of the PHY
being in a bad state, see below.

The mapping per-se is not the problem, but the fact that the PHY driver
is probed twice is the original problem that I have. The double probing
comes from the switch driver being probed first (drivers/net/dsa/ comes
before drivers/net/ethernet) and depends on the master netdev to be running.

We need to turn on the Gigabit PHY clock in order to be able to read its
PHY OUI and map it to a driver (yes a workaround could be to put its
exact compatible string in DT, that way, no need for get_phy_id()). We
have a local change in mdio-bcm-unimac.c which does exactly that (using
the clock framework), and then, to avoid artificially bumping the clock
reference count, the BCM7xxx PHY driver in its ->probe() function checks
whether the clock is enabled (yes, using __clk_is_enabled while it
probably should not) and keep the clock turned on for the MDIO layer to
successfully read/write from the PHY. The BCM7xxx PHY driver does
properly manage the clock though, and turns it off upon ->remove(). We
got probed and removed once, no more clock enabled because of the first
probe deferral.

The second time around, when the slave MII bus probes us again, we go
through the BCM7xxx ->probe() and ->remove() callbacks again, but the
clock was already turned off due to first probe that got deferred.

When the bcm_sf2 driver finally gets initialized, we try to attach to
this Gigabit PHY, the driver is there, good, but the clock is turned off
already, so the PHY does not respond correctly at all anymore and we
end-up reading garbage.

> 
> It seems like you should add an mdio node inside your switch node, and
> list your external switch internal/external phys there if needed.

I think I am going to keep this hack local and think about solving this
differently on an upstream kernel, since I am convinced now this is not
necessarily the right approach.

Thanks for your time and consideration!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
