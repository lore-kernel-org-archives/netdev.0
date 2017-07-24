From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 00/18] net: mvpp2: MAC/GoP configuration and optional PHYs
Date: Mon, 24 Jul 2017 15:48:30 +0200
Message-ID: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47309 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751825AbdGXNuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This series aim two things: making the PPv2 driver less depending on
the firmware/bootloader initialization[1], and making the PPv2 driver
work when no Ethernet PHY is connected between a port and the physical
layer[2]. A few patches cleanup some small parts of the driver, and
newly supported interfaces are described in the device trees[3].

[1] The current implementation of the PPv2 driver relies on the
    firmware/bootloader initialization to configure some parts, as the
    Group of Ports (GoP) and the MACs (GMAC and/or XLG MAC --for 10G--).
    The drawback is the kernel must be configured to match exactly what
    the bootloader configures which is not convenient and is an issue
    when using boards having an Ethernet port and an SFP port wired to
    the same GoP port, as no dynamic configuration can be done.

    This series adds the GoP and GMAC/XLG MAC initializations so that
    the PPV2 does not have to rely on a previous initialization. One
    part is still missing from this series, and that would be the
    'comphy' which provides shared serdes PHYs and which must be
    configured as well for a full kernel initialization to work. This
    comphy support will be part of a following up series. (This
    series was also tested with this 'comphy' support, as it's nearly
    ready).

    Patches 3-7, 11 and 14-15.

[2] While the documentation states the phy property in a port node is
    optional, it is not in the current driver's implementation. This is
    needed when no PHY is connected between a GoP port and the physical
    layer (as for the two SFP ports on the 8040-db). One other feature
    is missing to be able to use such ports: the port link interrupt
    which allows not to rely on the phylib link event callback.

    This series makes the phy optional in the PPv2 driver, and then adds
    the support for the GoP port link interrupt to handle link status
    changes on such ports.

    Patches 8-10, 12-14.

[3] With the port link interrupt and optional PHY support, the two SFP
    ports on the Marvell Armada 8040 DB can be described and used; as
    well as the SFP port on the 7040 DB..

    Cosmetic changes / fixes.

    Patches 1, 2 and 16-18.

I intentionally grouped all these patches into one series, as we would
end up with series depending on each others (and I already did not
include all my patches in this one). If that's an issue for this series
to be reviewed/merged, I can easily split it into two series, with a
dependency of one on the other.

@Dave: Patches 13 to 18 should go through the mvebu tree, thanks :)

Thanks!
Antoine


Antoine Tenart (18):
  net: mvpp2: unify register definitions coding style
  net: mvpp2: fix the synchronization module bypass macro name
  net: mvpp2: set the SMI PHY address when connecting to the PHY
  net: mvpp2: move the mii configuration in the ndo_open path
  net: mvpp2: initialize the GMAC when using a port
  net: mvpp2: initialize the XLG MAC when using a port
  net: mvpp2: initialize the GoP
  net: mvpp2: make the phy optional
  net: mvpp2: use named interrupts
  net: mvpp2: use the GoP interrupt for link status changes
  Documentation/bindings: net: marvell-pp2: add the system controller
  Documentation/bindings: net: marvell-pp2: add the interrupt-names
  arm64: dts: marvell: cp110: use named interrupts for the Ethernet
    ports
  arm64: dts: marvell: cp110: add PPv2 port interrupts
  arm64: dts: marvell: add a reference to the sysctrl syscon in the ppv2
    node
  arm64: dts: marvell: mcbin: enable more networking ports
  arm64: dts: marvell: 7040-db: enable the SFP port
  arm64: dts: marvell: 8040-db: enable the SFP ports

 .../devicetree/bindings/net/marvell-pp2.txt        |   7 +
 arch/arm64/boot/dts/marvell/armada-7040-db.dts     |   5 +
 arch/arm64/boot/dts/marvell/armada-8040-db.dts     |  10 +
 arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts  |  30 ++
 .../boot/dts/marvell/armada-cp110-master.dtsi      |  13 +-
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |  13 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 587 ++++++++++++++++++---
 7 files changed, 575 insertions(+), 90 deletions(-)

-- 
2.13.3
