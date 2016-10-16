From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/5] Interrupt support for mv88e6xxx
Date: Sun, 16 Oct 2016 19:56:48 +0200
Message-ID: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46333 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932359AbcJPR6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 13:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset add interrupt controller support to the MV88E6xxx.  This
allows access to the interrupts the internal PHY generate. These
interrupts can then be associated to a PHY device in the device tree
and used by the PHY lib, rather than polling.

Since interrupt handling needs to make MDIO bus accesses, threaded
interrupts are used. The phylib needs to request the PHY interrupt
using the threaded IRQ API. This in term allows some simplification to
the code, in that the phylib interrupt handler can directly call
phy_change(), rather than use a work queue. The work queue is however
retained for the phy_mac_interrupt() call, which can be called in hard
interrupt context.

Since RFC v1:

Keep phy_mac_interrupt() callable in hard IRQ context.

The fix to trigger the phy state machine transitions on interrupts has
already been submitted, so is dropped from here.

Added back shared interrupts support.


Andrew Lunn (5):
  net: dsa: mv88e6xxx: Implement interrupt support.
  net: phy: Use threaded IRQ, to allow IRQ from sleeping devices
  net: phy: Threaded interrupts allow some simplification
  net: phy: Use phy name when requesting the interrupt
  arm: vf610: zii devel b: Add support for switch interrupts

 .../devicetree/bindings/net/dsa/marvell.txt        |  21 +-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |  51 +++++
 drivers/net/dsa/mv88e6xxx/chip.c                   | 248 ++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.c                | 139 +++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h                |  11 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  31 +++
 drivers/net/phy/phy.c                              |  52 +++--
 drivers/net/phy/phy_device.c                       |   2 +-
 include/linux/phy.h                                |   5 +-
 9 files changed, 522 insertions(+), 38 deletions(-)

-- 
2.9.3
