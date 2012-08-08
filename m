From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Wed, 8 Aug 2012 12:39:16 +0000
Message-ID: <201208081239.16778.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <50223428.6030506@codethink.co.uk> <502252A6.4090409@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org
To: Ian Molton <ian.molton@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:58972 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757995Ab2HHMjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 08:39:37 -0400
In-Reply-To: <502252A6.4090409@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 August 2012, Ian Molton wrote:
> The SMI / PHY stuff should look very similar, so I'm happy with something
> like:
> 
> mdio@2000 {
>                 #address-cells = <1>;
>                 #size-cells = <1>;
>                 device_type = "mdio";
>                 compatible = "marvell,mv643xx-mdio";
>                 phy0: ethernet-phy@0 {
>                         device_type = "ethernet-phy";
>                         compatible = "marvell,whatever";
>                         interrupts = <76>;
>                         interrupt-parent = <&mpic>;
>                         reg = <0 32>;          // Auto probed phy addr
>                 };
> 
>                 phy1: ethernet-phy@3 {
>                         device_type = "ethernet-phy";
>                         compatible = "marvell,whatever";
>                         interrupts = <77>;
>                         interrupt-parent = <&mpic>;
>                         reg = <3 1>;            // specified phy addr
>                 };
> 
>                 ... and so on.
> }
> 
> Where we can use the reg parameter to allow auto-probing, by
> specifying a size of 32 (32 phy addrs max).

I don't understand the auto-probed phy address. What is the purpose of that?

If possible, I think we should keep using #size-cells=<0>, which would
make the method you describe impossible. It might still work if you just
leave out the "reg" property for that node.

I also don't understand how the phy driver would locate ethernet-phy@0
on the bus if it does not know the address.

> The ethernet driver itself is more complicated:
> 
> We have the following considerations:
> 
> * we have one MDIO bus, typically, shared between all the MACs / PHYs.
> * each ethernet device can multiple ports (up to three), each with its
>   own MAC/PHY.
> * MAC <-> PHY mapping can be specified, probed (ugh!) or a (gah!)
>   mix of the two.
> * existing D-T users, albeit not well documented / code complete.
> * some port address ranges overlap (MIB counters, MCAST / UNICAST
>   tables, etc.
> 
> The existing ethernet-group idea only works because the current
> platform-device based driver doesnt really do proper resource
> management, and thus the MAC registers are actually mapped by
> the MDIO driver.
> 
> I don't think that preserving this bad behaviour is a good idea, which
> leaves us with two choices:
> 
> 1) My preferred solution - allow each device to specify up to three
> interrupts, MACs, and PHYs. This is clean in that it doesnt require
> multiply instantiating a driver three times over the same address
> space.
> 
> ethernet@2400 {
>                 compatible = "marvell,mv643xx-eth";
>                 reg = <0x2400 0x1c00>
>                 interrupt_parent = <&mpic>;
>                 ports = <3>;
>                 interrupts = <4>, <5>, <6>;
>                 phys = <&phy0>, <&phy1>, <&phy2>;
> };
> 
> ethernet@6400 {
>                 compatible = "marvell,mv643xx-eth";
>                 reg = <0x6400 0x1c00>
>                 interrupt_parent = <&mpic>;
>                 ports = <1>;
>                 interrupts = <4>;
>                 phys = <&phy3>;
> };
> 
> Note that the address is 2400, not 2000 - since this driver no longer
> would share its address range with the MDIO driver.
> 
> This method would require a small amount of rework in the driver to
> set up <n> ports, rather than just one.

This looks quite nice, but it is still very much incompatible with the
existing binding. Obviously we can abandon an existing binding and
introduce a second one for the same hardware, but that should not
be taken lightly.

> 2) Create some kind of pseudo-ethernet group device that manages
> all the work for some sort of lightweight ethernet device, one per
> port. This can never be done cleanly since the port address ranges
> overlap:
> 
> pseudo_eth@2400 {
>         #address-cells = <1>;
>         #size-cells = <0>;
>         compatible = "marvell,mv643xx-shared-eth"
>         reg = <0x2400 0x1c00>;
> 
>         ethernet@0 {
>                 compatible = "marvell,mv643xx-port";
>                 interrupts = <4>;
>                 interrupt_parent = <&mpic>;
>                 phy = <&phy0>;
>         };
> 
>         ethernet@1 {
>                 compatible = "marvell,mv643xx-port";
>                 interrupts = <5>;
>                 interrupt_parent = <&mpic>;
>                 phy = <&phy1>;
>         };
> 
>         ethernet@2 {
>                 compatible = "marvell,mv643xx-port";
>                 interrupts = <6>;
>                 interrupt_parent = <&mpic>;
>                 phy = <&phy2>;
>         };
> }
> pseudo_eth@6400 {
>         #address-cells = <1>;
>         #size-cells = <0>;
>         compatible = "marvell,mv643xx-shared-eth"
>         reg = <0x6400 0x1c00>;
> 
>         ethernet@0 {
>                 compatible = "marvell,mv643xx-port";
>                 interrupts = <4>;
>                 interrupt_parent = <&mpic>;
>                 phy = <&phy3>;
>         };
> };

This looks almost compatible with the existing binding, which is
good. I would in fact recommend to use the actual "compatible"
strings from the binding. More generally speaking, you should not
use wildcards in those strings anyway, so always use
"marvell,mv64360-eth" instead of "marvell,mv64x60-eth" or
"marvell,mv643xx-eth". If you have multiple chips that are
completely compatible, put use the identifier for the older one.

I don't fully understand your concern with the overlapping
registers, mostly because I still don't know all the combinations
that are actually valid here. Let me try to say what I understood
so far, and you can correct me if that's wrong:

* A system can have multiple instances of an mv64360 ethernet
block, with a register area of 0x2000 bytes.
* Each such block can have three MACs and three PHYs.
* The first 0x400 bytes in the register space control the three
  PHYs and the remaining registers control the MACs.
* While this is meant to be used in a way that you assign
  the each of the three PHYs to one of the MACs, this is not
  always done, and sometimes you use a different PHY (?), or
  one from a different instance of the mv64360 ethernet block
  on the same SoC?.

	Arnd
