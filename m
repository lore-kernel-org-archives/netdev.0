From: Ian Molton <ian.molton@codethink.co.uk>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Thu, 09 Aug 2012 11:59:33 +0100
Message-ID: <50239815.6020108@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <50223428.6030506@codethink.co.uk> <502252A6.4090409@codethink.co.uk> <201208081239.16778.arnd@arndb.de> <50226779.6060201@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org, dale@farnsworth.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:53205 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757847Ab2HIK7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 06:59:45 -0400
In-Reply-To: <50226779.6060201@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding devicetree-discuss and linuxppc-dev, as well as Dale Farnsworth,
who initially added the bindings for mv643xx.

On 08/08/12 14:19, Ian Molton wrote:
> On 08/08/12 13:39, Arnd Bergmann wrote:
>> On Wednesday 08 August 2012, Ian Molton wrote:
>>> The SMI / PHY stuff should look very similar, so I'm happy with something
>>> like:
>>>
>>> mdio@2000 {
>>>                 #address-cells = <1>;
>>>                 #size-cells = <1>;
>>>                 device_type = "mdio";
>>>                 compatible = "marvell,mv643xx-mdio";
>>>                 phy0: ethernet-phy@0 {
>>>                         device_type = "ethernet-phy";
>>>                         compatible = "marvell,whatever";
>>>                         interrupts = <76>;
>>>                         interrupt-parent = <&mpic>;
>>>                         reg = <0 32>;          // Auto probed phy addr
>>>                 };
>>>
>>>                 phy1: ethernet-phy@3 {
>>>                         device_type = "ethernet-phy";
>>>                         compatible = "marvell,whatever";
>>>                         interrupts = <77>;
>>>                         interrupt-parent = <&mpic>;
>>>                         reg = <3 1>;            // specified phy addr
>>>                 };
>>>
>>>                 ... and so on.
>>> }
>>>
>>> Where we can use the reg parameter to allow auto-probing, by
>>> specifying a size of 32 (32 phy addrs max).
>> I don't understand the auto-probed phy address. What is the purpose of that?
> Personally, I think it should die - but the existing driver and a number
> of its users actually scan the bus for their PHY.
>
> I doubt the PHY really moves about or is hotplugged by any of them,
> and its actually quite a slow process.
>
>> If possible, I think we should keep using #size-cells=<0>, which would
>> make the method you describe impossible. It might still work if you just
>> leave out the "reg" property for that node.
> I can certainly investigate that. I couldn't see any good evidence that
> it was a supported mechanism when I looked.
>
>> I also don't understand how the phy driver would locate ethernet-phy@0
>> on the bus if it does not know the address.
>>
>>> The ethernet driver itself is more complicated:
>>>
>>> We have the following considerations:
>>>
>>> * we have one MDIO bus, typically, shared between all the MACs / PHYs.
>>> * each ethernet device can multiple ports (up to three), each with its
>>>   own MAC/PHY.
>>> * MAC <-> PHY mapping can be specified, probed (ugh!) or a (gah!)
>>>   mix of the two.
>>> * existing D-T users, albeit not well documented / code complete.
>>> * some port address ranges overlap (MIB counters, MCAST / UNICAST
>>>   tables, etc.
>>>
>>> The existing ethernet-group idea only works because the current
>>> platform-device based driver doesnt really do proper resource
>>> management, and thus the MAC registers are actually mapped by
>>> the MDIO driver.
>>>
>>> I don't think that preserving this bad behaviour is a good idea, which
>>> leaves us with two choices:
>>>
>>> 1) My preferred solution - allow each device to specify up to three
>>> interrupts, MACs, and PHYs. This is clean in that it doesnt require
>>> multiply instantiating a driver three times over the same address
>>> space.
>>>
>>> ethernet@2400 {
>>>                 compatible = "marvell,mv643xx-eth";
>>>                 reg = <0x2400 0x1c00>
>>>                 interrupt_parent = <&mpic>;
>>>                 ports = <3>;
>>>                 interrupts = <4>, <5>, <6>;
>>>                 phys = <&phy0>, <&phy1>, <&phy2>;
>>> };
>>>
>>> ethernet@6400 {
>>>                 compatible = "marvell,mv643xx-eth";
>>>                 reg = <0x6400 0x1c00>
>>>                 interrupt_parent = <&mpic>;
>>>                 ports = <1>;
>>>                 interrupts = <4>;
>>>                 phys = <&phy3>;
>>> };
>>>
>>> Note that the address is 2400, not 2000 - since this driver no longer
>>> would share its address range with the MDIO driver.
>>>
>>> This method would require a small amount of rework in the driver to
>>> set up <n> ports, rather than just one.
>> This looks quite nice, but it is still very much incompatible with the
>> existing binding. Obviously we can abandon an existing binding and
>> introduce a second one for the same hardware, but that should not
>> be taken lightly.
> Fair, however the existing users aren't anywhere near as
> numerous as the new ones.
>
>>> 2) Create some kind of pseudo-ethernet group device that manages
>>> all the work for some sort of lightweight ethernet device, one per
>>> port. This can never be done cleanly since the port address ranges
>>> overlap:
>>>
>>> pseudo_eth@2400 {
>>>         #address-cells = <1>;
>>>         #size-cells = <0>;
>>>         compatible = "marvell,mv643xx-shared-eth"
>>>         reg = <0x2400 0x1c00>;
>>>
>>>         ethernet@0 {
>>>                 compatible = "marvell,mv643xx-port";
>>>                 interrupts = <4>;
>>>                 interrupt_parent = <&mpic>;
>>>                 phy = <&phy0>;
>>>         };
>>>
>>>         ethernet@1 {
>>>                 compatible = "marvell,mv643xx-port";
>>>                 interrupts = <5>;
>>>                 interrupt_parent = <&mpic>;
>>>                 phy = <&phy1>;
>>>         };
>>>
>>>         ethernet@2 {
>>>                 compatible = "marvell,mv643xx-port";
>>>                 interrupts = <6>;
>>>                 interrupt_parent = <&mpic>;
>>>                 phy = <&phy2>;
>>>         };
>>> }
>>> pseudo_eth@6400 {
>>>         #address-cells = <1>;
>>>         #size-cells = <0>;
>>>         compatible = "marvell,mv643xx-shared-eth"
>>>         reg = <0x6400 0x1c00>;
>>>
>>>         ethernet@0 {
>>>                 compatible = "marvell,mv643xx-port";
>>>                 interrupts = <4>;
>>>                 interrupt_parent = <&mpic>;
>>>                 phy = <&phy3>;
>>>         };
>>> };
>> This looks almost compatible with the existing binding, which is
>> good.
> Well, I'm not sure about that - if the existing bindings are really
> baked into firmware, then "almost" wont be any use at all.
>
>>  I would in fact recommend to use the actual "compatible"
>> strings from the binding. More generally speaking, you should not
>> use wildcards in those strings anyway, so always use
>> "marvell,mv64360-eth" instead of "marvell,mv64x60-eth" or
>> "marvell,mv643xx-eth". If you have multiple chips that are
>> completely compatible, put use the identifier for the older one.
> Noted.
>
>> I don't fully understand your concern with the overlapping
>> registers, mostly because I still don't know all the combinations
>> that are actually valid here. Let me try to say what I understood
>> so far, and you can correct me if that's wrong:
>>
>> * A system can have multiple instances of an mv64360 ethernet
>> block, with a register area of 0x2000 bytes.
>> * Each such block can have three MACs and three PHYs.
>> * The first 0x400 bytes in the register space control the three
>>   PHYs and the remaining registers control the MACs.
>> * While this is meant to be used in a way that you assign
>>   the each of the three PHYs to one of the MACs, this is not
>>   always done, and sometimes you use a different PHY (?), or
>>   one from a different instance of the mv64360 ethernet block
>>   on the same SoC?.
> Nearly - the whole block is 0x2000 in size, yes. And each one
> can have 3 MACs and PHYs, as you say.
>
> There is SMI @ 0x2000 - just one for all ports, and in many
> (all?) cases, for all all the other controllers on the SoC to
> share. On the armadaXP SoC, for example, each ethernet
> block has its own alias of the same bas SMI reg. (there are
> 4 blocks)
>
> ethernet0@ 0x2400
> ## regs in order: Main regs, MIB counters, Special mcast table, Mcast
> table, Unicast table.
>    port0 has regs at +0x0000 *0x1000 +0x1400 +0x1500 +0x1600
>    port1 has regs at +0x0400 *0x1080 +0x1800 +0x1900 +0x1a00
>    port2 has regs at +0x0800 *0x1100 +0x1c00 +0x1d00 +0x1e00
> ethernet1@ 0x6400
>   port0 has regs at +0x0000 *0x1000 +0x1400 +0x1500 +0x1600
> ...
>
> As you can see, instead of putting port1 at +0x1700 or so,
> marvell have overlapped the register files - in fact, doubly
> so, since port1 + 0x1080 is right in the middle of
> (port0 + 0x1000) -> (port0 + 0x16ff), so one cant simply map two
> sets of regs like 0x0000->0x03ff and 0x1000->0x16ff for port one
> either.
>
> -Ian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
