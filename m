From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH RFC 00/26] Phylink & SFP support
Date: Mon, 7 Dec 2015 17:35:53 +0000
Message-ID: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60245 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932374AbbLGRgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:36:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

SFP modules are hot-pluggable ethernet transceivers; they can be
detected at runtime and accordingly configured.  There are a range of
modules offering many different features.

Some SFP modules have PHYs conventional integrated into them, others
drive a laser diode from the Serdes bus.  Some have monitoring, others
do not.

Some SFP modules want to use SGMII over the Serdes link, others want
to use 1000base-X over the Serdes link.

This makes it non-trivial to support with the existing code structure.
Not wanting to write something specific to the mvneta driver, I decided
to have a go at coming up with something more generic.

My initial attempts were to provide a PHY driver, but I found that
phylib's state machine got in the way, and it was hard to support two
chained PHYs.  Conversely, having a fixed DT specified setup (via
the fixed phy infrastructure) would allow some SFP modules to work, but
not others.  The same is true of the "managed" in-band status (which
is SGMII.)

The result is that I came up with phylink - an infrastructure layer
which sits between the network driver and any attached PHY, and a
SFP module layer detects the SFP module, and configures phylink
accordingly.

Overall, this supports:

* switching the serdes mode at the NIC driver
* controlling autonegotiation and autoneg results
* allowing PHYs to be hotplugged
* allowing SFP modules to be hotplugged with proper link indication
* fixed-mode links without involving phylib
* flow control
* EEE support
* reading SFP module EEPROMs

Overall, phylink supports several link modes, with dynamic switching
possible between these:
* A true fixed link mode, where the parameters are set by DT.
* PHY mode, where we read the negotiation results from the PHY registers
  and pass them to the NIC driver.
* SGMII mode, where the in-band status indicates the speed, duplex and
  flow control settings of the link partner.
* 1000base-X mode, where the in-band status indicates only duplex and
  flow control settings (different, incompatible bit layout from SGMII.)

Ethtool support is included, as well as emulation of the MII registers
for situations where a PHY is not attached, giving compatible emulation
of existing user interfaces where required.

The patches here include modification of mvneta (against 4.4-rc1, so
probably won't apply to current development tips.)  It basically
hooks into the places where the phylib would hook into.

DT wise, the changes needed to support SFP look like this (example
taken from Clearfog):

 			ethernet@34000 {
+				managed = "in-band-status";
 				phy-mode = "sgmii";
 				status = "okay";
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
-				};
 			};
...
+	sfp: sfp {
+		compatible = "sff,sfp";
+		i2c-bus = <&i2c1>;
+		los-gpio = <&expander0 12 GPIO_ACTIVE_HIGH>;
+		moddef0-gpio = <&expander0 15 GPIO_ACTIVE_LOW>;
+		sfp,ethernet = <&eth2>;
+		tx-disable-gpio = <&expander0 14 GPIO_ACTIVE_HIGH>;
+		tx-fault-gpio = <&expander0 13 GPIO_ACTIVE_HIGH>;
+	};

These DT changes are omitted from this patch set as the baseline DT
file is not in mainline yet (has been submitted.)

 drivers/net/ethernet/marvell/Kconfig  |    2 +-
 drivers/net/ethernet/marvell/mvneta.c |  537 +++++++++-----
 drivers/net/phy/Kconfig               |   29 +
 drivers/net/phy/Makefile              |    6 +-
 drivers/net/phy/fixed_phy.c           |  178 +----
 drivers/net/phy/marvell.c             |    2 +-
 drivers/net/phy/mdio-i2c.c            |   90 +++
 drivers/net/phy/mdio-i2c.h            |   19 +
 drivers/net/phy/phy.c                 |   46 +-
 drivers/net/phy/phy_device.c          |   15 +
 drivers/net/phy/phylink.c             | 1138 ++++++++++++++++++++++++++++++
 drivers/net/phy/sfp.c                 | 1235 +++++++++++++++++++++++++++++++++
 drivers/net/phy/swphy.c               |  179 +++++
 drivers/net/phy/swphy.h               |    9 +
 include/linux/phy.h                   |    4 +
 include/linux/phy_fixed.h             |    9 -
 include/linux/phylink.h               |  102 +++
 include/linux/sfp.h                   |  338 +++++++++
 18 files changed, 3577 insertions(+), 361 deletions(-)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
