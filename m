From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear WNR854T
Date: Tue, 19 Jul 2016 11:46:44 +0200
Message-ID: <4018990.2Ivz6MntMW@wuerfel>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk> <1792384.6N9lHjmBFc@wuerfel> <alpine.DEB.2.11.1607191034240.19980@marmot.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jamie Lentin <jm@lentin.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:57049 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbcGSJrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 05:47:35 -0400
In-Reply-To: <alpine.DEB.2.11.1607191034240.19980@marmot.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, July 19, 2016 10:40:16 AM CEST Jamie Lentin wrote:
> On Mon, 18 Jul 2016, Arnd Bergmann wrote:
> 
> > On Monday, July 18, 2016 11:44:24 AM CEST Thomas Petazzoni wrote:
> >>
> >> On Sun, 17 Jul 2016 22:41:35 +0200, Arnd Bergmann wrote:
> >>
> >>> I would assume that the PCIe port should work out of the box with the driver
> >>
> >> Unfortunately, no. The PCIe on Orion5x requires a workaround for
> >> reading/writing the PCI configuration space. Instead of doing MMIO
> >> accesses to PCIE_CONF_ADDR_OFF / PCIE_CONF_DATA_OFF, you must map a
> >> MBus window, which provides a memory-mapped view of the PCI
> >> configuration space.
> >>
> >> Definitely not impossible to implement, but the driver doesn't work
> >> as-is.
> >
> > Ok.
> 
> Unfortunately this isn't something I can test as the PCIe port on the SoC 
> doesn't go anywhere in my case.

As I said, this wouldn't be a problem: we should consider the PCI and PCIe
ports on this chip as completely separate anyway, so we can work on
the drivers independently.

> >>> We also don't seem to need any MBUS window setup for the I/O and
> >>> memory spaces, which greatly simplifies the driver compared to the
> >>> pci-mvebu one, it would be a fairly straightforward implementation
> >>> based on pci-host-generic.c (which unfortunately just got way
> >>> more complicated and might need to go on a diet).
> >>
> >> MBus windows are needed. See:
> >>
> >>         mvebu_mbus_add_window_remap_by_id(ORION_MBUS_PCI_IO_TARGET,
> >>                                           ORION_MBUS_PCI_IO_ATTR,
> >>                                           ORION5X_PCI_IO_PHYS_BASE,
> >>                                           ORION5X_PCI_IO_SIZE,
> >>                                           ORION5X_PCI_IO_BUS_BASE);
> >>         mvebu_mbus_add_window_by_id(ORION_MBUS_PCI_MEM_TARGET,
> >>                                     ORION_MBUS_PCI_MEM_ATTR,
> >>                                     ORION5X_PCI_MEM_PHYS_BASE,
> >>                                     ORION5X_PCI_MEM_SIZE);
> >>
> >> in orion5x_setup_wins().
> >
> > Ok, I was just looking at the wrong file, as they are set up from
> > common.c, not pci.c.
> >
> >> Note that we already have some Orion5x converted to DT, and that use
> >> PCI: board-rd88f5182.c is an example. So we could very well take Jamie
> >> patches as-is, and move later to a DT-representation for PCI/PCIe.
> >
> > Ah, I thought all the DT users were moved to mach-mvebu. I agree
> > this new patch isn't introducing anything we don't already have then,
> > so we can just take it, but the conversion will not be nice when
> > we do that.
> 
> Yes, board-wnr854t.c is a clone of the existing board-rd88f5182.c. 
> Although I'd presume that it too would need late_initcall() or somesuch 
> mechanism to probe PCI once the GPIO controller is available.

Deferred probing should be fine once the driver is migrated from
pci_common_init() to registering the host bridge directly.

	Arnd
