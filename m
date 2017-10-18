From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next] dsa: slave: support phy devices on external MII bus
Date: Wed, 18 Oct 2017 12:18:52 -0700
Message-ID: <2e120f66-eb0b-7bfe-450c-db061defca09@gmail.com>
References: <20171018162138.GA15371@lunn.ch>
 <ad992ed8-37b8-9c52-848c-78fa0368de8f@gmail.com>
 <8994adaa-6223-20f1-9221-49e9b644d03f@prevas.dk>
 <3b972ab8-3d3e-7666-5c26-f111f5cdd61a@gmail.com>
 <20171018190905.GH15371@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:56229 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdJRTS5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 15:18:57 -0400
Received: by mail-qk0-f178.google.com with SMTP id x82so7612270qkb.12
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 12:18:56 -0700 (PDT)
In-Reply-To: <20171018190905.GH15371@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2017 12:09 PM, Andrew Lunn wrote:
>> Yes, but with the caveat already covered today: there is a possible
>> problem with having to divert MDIO accesses of a PHY pointed by
>> phy-handle towards the internal switch bus because of specific problems
>> such as those explained in drivers/net/bcm_sf2.c, I don't mind trying to
>> do things smarter or in a different way, but that needs to be something
>> possible.
> 
> Hi Florian
> 
> Are you referring to:
> 
>         /* Include the pseudo-PHY address to divert reads towards our
>          * workaround. This is only required for 7445D0, since 7445E0
>          * disconnects the internal switch pseudo-PHY such that we can use the
>          * regular SWITCH_MDIO master controller instead.
>          *
>          * Here we flag the pseudo PHY as needing special treatment and would
>          * otherwise make all other PHY read/writes go to the master MDIO bus
>          * controller that comes with this switch backed by the "mdio-unimac"
>          * driver.
>          */
> ?

Yes.

> 
> Do you have an example device tree fragment, just to make it clearer?


Sure:

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

			port@1 {
				label = "rgmii_1";
				reg = <1>;
				/* connects to the external BCM53125 switch below */
				fixed-link {
					speed = <1000>;
					full-duplex;
				}
			};
                };
        };

	mdio@403c0 {
		reg = <0x403c0 0x8 0x40300 0x18>;
		#address-cells = <0x1>;
		#size-cells = <0x0>;
		compatible = "brcm,bcm7445-mdio-v4.0", "brcm,unimac-mdio";
		reg-names = "mdio", "mdio_indir_rw";

		phy5: ethernet-phy@5 {
			reg = <0x5>;
			compatible = "brcm,28nm-gphy", "ethernet-phy-ieee802.3-c22";
		};

		/* External BCM53125 switch that requires the workaround above */
		ethernet-switch@0 {
			reg = <0>;
			compatible = "brcm,bcm53125";

			ports {
				...
			};
	};
};

In fact, this now makes me think that I had to put this workaround in
place solely because at some point I modeled the external BCM53125
switch as a PHY device, and so I had to have phy_connect() work correctly!

Now that we have a proper MDIO device class, this may actually no longer
be necessary at all within net/dsa/slave.c::dsa_slave_phy_setup() since
the probe paths would work completely differently and the offending port
(port 1) would have a fixed-link property. I still need my local
workaround in bcm_sf2.c of course.

I guess, thanks for making me post this example and realize this is
probably no longer necessary :)
-- 
Florian
