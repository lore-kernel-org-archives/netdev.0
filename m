From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH RFC 00/13] phylink and sfp support
Date: Tue, 25 Jul 2017 15:01:39 +0100
Message-ID: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50818 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdGYOBs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:01:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series introduces generic support for SFP sockets found on
various Marvell based platforms.  The idea here is to provide common
SFP socket support which can be re-used by network drivers as
appropriate, rather than each network driver having to re-implement
SFP socket support.

SFP sockets typically use other system resources, eg, I2C buses to read
identifying information, and GPIOs to monitor socket state and control
the socket.  Meanwhile, some network drivers drive multiple ethernet
ports from one instantiation of the driver.

It is not desirable to block the initialisation of a network driver
(thus denying other ports from being operational) if the resources
for the SFP socket are not yet available.  This means that an element
of independence between the SFP support code and the driver is
required.

More than that, SFP modules effectively bring hotplug PHYs to
networking - SFP copper modules normally contain a standard PHY
accessed over the I2C bus, and it is desirable to read their state
so network drivers can be appropriately configured.

To add to the complexity, SFP modules can be connected in at least
two places:

1. Directly to the serdes output of a MAC with no intervening PHY.
   For example:

     mvneta ----> SFP socket

2. To a PHY, for example:

     mvpp2 ---> PHY ---> copper
                 |
                 `-----> SFP socket

This code supports both setups, although it's not fully implemented
with scenario (2).

Moreover, the link presented by the SFP module can be one of the
10Gbase-R family (for SFP+ sockets), SGMII or 1000base-X (for SFP
sockets) depending on the module, and network drivers need to
reconfigure themselves accordingly for the link to come up.

For example, if the MAC is configured for SGMII and a fibre module
is plugged in, the link won't come up until the MAC is reconfigured
for 1000base-X mode.

The SFP code manages the SFP socket - detecting the module, reading
the identifying information, and managing the control and status
signals.  Importantly, it disables the SFP module transmitter when
the MAC is down, so that the laser is turned off (but that is not
a guarantee.)

phylink provides the mechanisms necessary to manage the link modes,
based on the SFP module type, and supports hot-plugging of the PHY
without needing the MAC driver to be brought up and down on
transitions.  phylink also supports the classical static PHY and
fixed-link modes.

I currently (but not included in this series) have code to convert
mvneta to use phylink, and the out of tree mvpp2x driver.  I have
nothing for the mvpp2 driver at present as that driver is only
recently becoming functional on 10G hardware, and is missing a lot
of features that are necessary to make things work correctly.

 drivers/net/phy/Kconfig      |   25 +
 drivers/net/phy/Makefile     |    6 +
 drivers/net/phy/mdio-i2c.c   |  109 ++++
 drivers/net/phy/mdio-i2c.h   |   19 +
 drivers/net/phy/phy-core.c   |  180 ++++++
 drivers/net/phy/phy.c        |  217 +------
 drivers/net/phy/phy_device.c |   15 +
 drivers/net/phy/phylink.c    | 1462 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/sfp-bus.c    |  475 ++++++++++++++
 drivers/net/phy/sfp.c        |  915 ++++++++++++++++++++++++++
 drivers/net/phy/sfp.h        |   28 +
 include/linux/phy.h          |   21 +
 include/linux/phylink.h      |  148 +++++
 include/linux/sfp.h          |  434 +++++++++++++
 14 files changed, 3867 insertions(+), 187 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
