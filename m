From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Wed, 29 Apr 2015 18:57:36 -0700
Message-ID: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
Cc: dave@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36529 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbD3B6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 21:58:00 -0400
Received: by pdea3 with SMTP id a3so45193500pde.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 18:57:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series is the long promised API rework to allow registering DSA
switch as PCI, platform, SPI, or PHY drivers, and this is pretty much the
grand plan described here:
http://permalink.gmane.org/gmane.linux.network/329848

Note that unless appropriate Device Tree or platform_data configuration is
changed, this is not conflicting with the current approach of registering DSA
switches using the special "dsa" platform device/driver. Rather this introduces
a parallel API which allows drivers to be converted and tested one by one.

This has been tested on the following two systems:

- Linksys/Cisco EA4500 which has a MV88E6171 at MDIO address 16
- BCM7445 reference board with the on-chip Starfighter 2 switch (MMIO)

Note that there are currenlty no incompatibles changes made to existing Device
Tree sources, rather, depending on the bus we are probed for, e.g: MDIO
the dsa,mii-bus and dsa,ethernet phandles and first cell of the  "reg" property
will become obsolete, everything else remains entirely compatible. This is all
appearing in patches.

Known issues:

- the new API probably does not work with multiple switches in a tree
  since I don't have such a system, I would welcome testing on these
  particular setups and would help take care of the problems, this is
  currently the biggest limitation I see

- there is a bit of duplication and special casing now, but that is
  mostly due to having to maintain two different ways of registering DSA
  drivers, this will eventually go away

- on my EA4500, doing PHY-driver registration slows things down dramatically
  iperf switches from ~700Mbits/sec to ~200Mbits/sec, not sure what's wrong
  here, could be some sort of RGMII setting going wrong

These changes can be pulled from my tree here:

https://github.com/ffainelli/linux/tree/dsa-model-proposal

Happy testing!

Florian Fainelli (8):
  net: dsa: Move dsa_switch_tree final setup in separate function
  net: phy: Check fixup lists in get_phy_device()
  net: phy: Allow PHY devices to identify themselves as Ethernet
    switches
  net: mv643xx_eth: Handle Ethernet switches as PHY devices
  net: dsa: add new API to register switch devices
  net: dsa: bcm_sf2: make it a real platform driver
  net: dsa: mv88e6060: make it a proper PHY driver
  net: dsa: mv88e6xxx: Allow them to be proper PHY drivers

 drivers/net/dsa/bcm_sf2.c                  | 239 +++++++++++++++--------------
 drivers/net/dsa/mv88e6060.c                | 114 +++++++++++++-
 drivers/net/dsa/mv88e6123_61_65.c          | 116 ++++++++++++++
 drivers/net/dsa/mv88e6131.c                | 107 +++++++++++++
 drivers/net/dsa/mv88e6171.c                |  95 ++++++++++++
 drivers/net/dsa/mv88e6352.c                | 102 ++++++++++++
 drivers/net/dsa/mv88e6xxx.c                |  40 ++++-
 drivers/net/dsa/mv88e6xxx.h                |  12 ++
 drivers/net/ethernet/marvell/mv643xx_eth.c |   4 +-
 drivers/net/phy/phy_device.c               |   9 +-
 include/linux/phy.h                        |  12 ++
 include/net/dsa.h                          |  15 ++
 net/dsa/dsa.c                              | 219 ++++++++++++++++++++------
 13 files changed, 917 insertions(+), 167 deletions(-)

-- 
2.1.0
