From: Anup Patel <anup.patel@broadcom.com>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Wed, 27 Apr 2016 10:16:40 +0530
Message-ID: <CAALAos_bPnT96xA883mkkjwUTut=_NJymUZKM=-0ZujdDxNEkA@mail.gmail.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
	<5167289.0a4LBoWhyX@wuerfel>
	<20160426182335.GE30107@lunn.ch>
	<9424602.Vqb0FY56gH@wuerfel>
	<20160426194102.GF30107@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Chen-Yu Tsai <wens@csie.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Device Tree <devicetree@vger.kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Suzuki K Poulose <suzuki.poulose@arm.com>,
	netdev@vger.kernel.org, Punit Agrawal <punit.agrawal@arm.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
	Linux ARM Kernel <linux-arm-kernel@lists.infradead.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160426194102.GF30107@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 1:11 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, Apr 26, 2016 at 09:24:34PM +0200, Arnd Bergmann wrote:
>> On Tuesday 26 April 2016 20:23:35 Andrew Lunn wrote:
>> > > A more complex problem would be having a PHY driver for a device
>> > > that can be either an ethernet phy or some other phy.
>> >
>> > I doubt that ever happens. You can have up to 32 different devices on
>> > an MDIO bus. Since an Ethernet PHY and a "some other sort of PHY" are
>> > completely different things, why would a hardware engineer place them
>> > on the same address? It is like saying your ATA controller and VGA
>> > controller share the same slot on the PCI bus...
>>
>> To clarify: what I meant is a device that is designed as a PHY for
>> similar hardware (e.g. SATA, USB3 and PCIe) and that has a common
>> register set and a single driver, but that driver can operate
>> in multiple modes. You typically have multiple instances of
>> such hardware, with each instance linked to exactly one host
>> device, but one driver for all of them.
>>
>> See Documentation/devicetree/bindings/phy/apm-xgene-phy.txt
>> and drivers/phy/phy-xgene.c for one such example.
>
> Interesting. Also, that this lists SGMII. I assume this is a phy in
> the MAC in order to talk to the Ethernet PHY.
>
> I still don't see it being a big problem if a phy driver implements an
> Ethernet PHY. It just needs to call phy_device_create() and
> phy_device_register().
>
>         Andrew

It is really interesting to see the evolution of MDIO bus:

1. Traditionally, MDIO controller used to be part of each ethernet controller
itself so each ethernet controller used to have it's own 2 wire MDIO bus

2. Next, we saw SoC with multiple ethernet controllers sharing same MDIO
bus. In other words, we saw multiple MDIO bus being muxed over single
MDIO bus with additional bus select lines (I think this is when
drivers/net/phy/mdio-mux.c APIs were implemented but at this point all
PHYs on muxed MDIO bus were ethernet PHYs).

3. Then, we saw SoC with ethernet switch devices also accessible over
shared MDIO bus (or Muxed MDIO bus) along with ethernet PHYs (I guess
this is why we have drivers/net/phy/mdio_device.c which adds
"mdio_device" for non-ethernet-PHY devices on MDIO bus).

4. Now, we have SoC with SATA PHYs, PCIe PHYs, USB PHYs, and Ethernet
PHYs all accessible over same shared MDIO bus (or Muxed MDIO bus). The
SATA PHYs and PCIe PHYs are registered to "Generic PHY framework". For
USB PHYs, we can either register to "Generic PHY framework" or "USB PHY
framework". For Ethernet PHYs, we register MDIO bus instance to "Ethernet
MDIO framework".

The devices on ARM64 SoC has to be within first 4GB and RAM has to start
from first 4GB to be ARM compliant because ARM64 CPUs have 32bit mode and
all devices and RAM should be available to 32bit mode with MMU disabled.
This means that we only have 4GB to fit all devices registers and some
portion of RAM. Some of these non-Ethernet PHYs have tons of registers so
as number of PHYs increase in a SoC they will eat-up lot of first 4GB
address space. Using same MDIO bus for all types of PHYs (SATA, PCIe, USB,
and Ethernet) is actually a good approach because it actually saves lot of
first 4GB address space. In future, more devices will be moved to a shared
MDIO bus which are less frequently accessed.

For Broadcom iProc SoCs, the design choice has already been made to use
shared MDIO bus for all PHYs. In fact, Broadcom iProc NS2 SoC already has
a shared MDIO bus for SATA PHYs, USB PHYs, PCIe PHYs, and Ethernet
PHYs and more Broadcom iProc SoCs are on their way. Of course, there are
few exceptions in iProc SoCs such as SATA PHYs where we also have memory
mapped registers to access PHYs but other PHYs don't have such memory
mapped registers.

Clearly from above, the traditional 2 wire MDIO bus is now a shared MDIO
bus with 2-wire plus additional select lines. Also, now we have SoCs (such
as Broadcom iProc SoCs) which has such shared MDIO bus and I think
in-future we will have SoCs with a shared MDIO bus for variety of devices.

For long term, we really need a clean solution to fit shared MDIO based
PHY drivers in Linux kernel. Also, shared MDIO based PHY drivers should
not be dependent on any particular IO subsystem (such as Linux Ethernet)
because there are lot of use-cases where people want strip down kernel
image by not-compiling IO subsystems which are not required.

IMHO, we have several options in front of us:
1. Use some light-weight framework (such as shared_mdio.c implemented
by this patchset) under drivers/bus
2. Extend "Generic PHY framework" to allow something like shared MDIO
bus (as-per Arnd's suggestion)
3. Move-out "MDIO-mux APIs" from drivers/net/phy to something like
drivers/mdio-mux and make it independent of "Linux Ethernet subsystem".
(... may be more options ...)

Regards,
Anup
