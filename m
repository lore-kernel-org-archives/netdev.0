From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
Date: Wed, 24 May 2017 16:25:43 +0200
Message-ID: <20170524142543.GD26577@lunn.ch>
References: <1495617948-13435-1-git-send-email-bogdan.purcareata@nxp.com>
 <20170524125830.GB24341@lunn.ch>
 <DB5PR04MB1240541B2CFB2C99ED519CDFEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DB5PR04MB1240541B2CFB2C99ED519CDFEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, I can do that. However, I don't see a "phy" folder under Documentation/devicetree/bindings/net/.
> Should I change the location to Documentation/devicetree/bindings/net/cortina.txt instead?

Ah, sorry, my error. Yes, Documentation/devicetree/bindings/net/cortina.txt.

> > I think there needs to be some explanation here. What exactly are you
> > using to indicate link up? What does CORTINA_GPIO_GPIO_INTS mean?
> 
> I can only assume it's the location of an interrupt status register. The Cortina PHYs go mostly undocumented, I've found an implementation in an old thread [1], that also did the job of programming the Cortina PHY microcode. I understand that microcode programming is now part of the bootloader.
> 
> The register seems to provide the link status properly, and based on that the phydev is initialized with the only (currently) supported configuration, 10Gbps full duplex.
> 
> I can change the register name to something more meaningful, though - e.g. CORTINA_LINK_STATUS.

No, leave the name as is. The MIPS driver you gave a reference to
seems to be using sensible names. My guess is, the boot loader is
configuring the PHY to generate an interrupt on link up via one of its
GPIO lines. And this code is reading that GPIO status. This is all
very fragile, you are making a lot of assumptions.

Have you tested pulling the cable out? And plugging it back in again?
There is a chance this interrupt is "link change", not "link up".

What i do like in that mips code is the probe function verifies the
product ID.

+       /*
+        * CS4312 keeps its ID values in non-standard registers, make
+        * sure we are talking to what we think we are.
+        */
+       id_lsb = cs4321_phy_read(phydev, CS4321_GLOBAL_CHIP_ID_LSB);
+       if (id_lsb < 0) {
+               ret = id_lsb;
+               goto err;
+       }
+
+       id_msb = cs4321_phy_read(phydev, CS4321_GLOBAL_CHIP_ID_MSB);
+       if (id_msb < 0) {
+               ret = id_msb;
+               goto err;
+       }
+
+       if (id_lsb != 0x23E5 || id_msb != 0x1002) {
+               ret = -ENODEV;
+               goto err;
+       }

You should do that as well.

      Andrew
