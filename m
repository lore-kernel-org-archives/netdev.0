From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 00/28] DSA: Restructure probing
Date: Wed, 23 Dec 2015 13:56:14 +0100
Message-ID: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48657 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbbLWM5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted in Documentation/networking/dsa/dsa.txt, the current DSA
architecture has a few architecture problems:

DSA is implemented as a DSA platform device driver which is convenient because
it will register the entire DSA switch tree attached to a master network device
in one-shot, facilitating the device creation and simplifying the device driver
model a bit, this comes however with a number of limitations:

- building DSA and its switch drivers as modules is currently not working
- the device driver parenting does not necessarily reflect the original
  bus/device the switch can be created from
- supporting non-MDIO and non-MMIO (platform) switches is not possible

This RFC patchset attempts to address this. It allows the switch
device to be true Linux devices, and use of the device component
framework to bind the switch devices to the DSA framework, similar to
the way GPU engines are bound to the master GPU driver. The drivers
are now modules, which can be loaded and unloaded. Reloading however
currently causes an Opps, hence RFC.

The code remains backwards compatible with the old binding, and adds a
new property to facilitate the component framework. Switch drivers get
there own binding, allowing them to be probed independent of DSA.

Additionally, at this RFC stage, the DTS files for a development board
with three switches is included, to demonstrate the new binding, and
show that D in DSA is supported. At some point this DTS file will be
submitted to arm-soc.

Andrew Lunn (24):
  dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
  net: dsa: Pass the dsa device to the switch drivers
  net: dsa: Have the switch driver allocate there own private memory
  net: dsa: Remove allocation of driver private memory
  net: dsa: Keep the mii bus and address in the private structure
  net: dsa: Add basic support for component master support
  net: dsa: Keep a reference to the switch device for component matching
  net: dsa: Add slave component matches based on a phandle to the slave.
  net: dsa: Make dsa,mii-bus optional
  net: dsa: Add register/unregister functions for switch drivers
  net: dsa: Rename DSA probe function.
  of_mdio: Add "mii-bus" and address property parser
  dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
  dsa: mv88e6xxx: Add shared code for binding/unbinding a switch driver.
  dsa: Add platform device support to Marvell switches
  vf610: Zii: Convert rev b to switches as individual devices
  net: dsa: Add some debug prints for error cases
  net: dsa: Setup the switches after all have been probed
  net: dsa: Only setup platform switches, not device switches
  net: dsa: If a switch fails to probe, defer probing
  Documentation: DSA: Describe how probe of DSA and switches work.
  dsa: Convert mv88e6xxx into a library allowing driver modules
  dsa: slave: Don't reference NULL pointer during phy_disconnect
  dsa: Destroy fixed link phys after the phy has been disconnected

Cory T. Tusar (1):
  ARM: VF610: Add Zodiac Inflight Innovations development boards.

Florian Fainelli (2):
  net: dsa: Move platform data allocation for OF
  net: dsa: bcm_sf2: make it a real platform driver

Russell King (1):
  component: remove old add_components method

 .../devicetree/bindings/net/dsa/broadcom.txt       |  48 +++
 Documentation/devicetree/bindings/net/dsa/dsa.txt  |   5 +-
 .../devicetree/bindings/net/dsa/marvell.txt        |  17 +
 Documentation/networking/dsa/dsa.txt               |  48 +++
 arch/arm/boot/dts/Makefile                         |   4 +-
 arch/arm/boot/dts/vf610-zii-dev-rev-a.dts          | 409 +++++++++++++++++++
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          | 307 +++++++++++++++
 arch/arm/boot/dts/vf610-zii-dev.dtsi               | 436 +++++++++++++++++++++
 drivers/base/component.c                           |  31 +-
 drivers/net/dsa/Kconfig                            |   2 +-
 drivers/net/dsa/Makefile                           |  19 +-
 drivers/net/dsa/bcm_sf2.c                          | 249 +++++++-----
 drivers/net/dsa/mv88e6060.c                        | 130 +++++-
 drivers/net/dsa/mv88e6060.h                        |  11 +
 drivers/net/dsa/mv88e6123.c                        | 187 +++++++++
 drivers/net/dsa/mv88e6123_61_65.c                  | 124 ------
 drivers/net/dsa/mv88e6131.c                        |  83 +++-
 drivers/net/dsa/mv88e6171.c                        |  83 +++-
 drivers/net/dsa/mv88e6352.c                        |  83 +++-
 drivers/net/dsa/mv88e6xxx.c                        | 159 +++++---
 drivers/net/dsa/mv88e6xxx.h                        |  20 +-
 drivers/of/of_mdio.c                               |  38 ++
 include/linux/component.h                          |   5 -
 include/linux/of_mdio.h                            |  10 +
 include/net/dsa.h                                  |  17 +-
 net/dsa/dsa.c                                      | 262 ++++++++-----
 net/dsa/slave.c                                    |  12 +-
 27 files changed, 2329 insertions(+), 470 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/broadcom.txt
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt
 create mode 100644 arch/arm/boot/dts/vf610-zii-dev-rev-a.dts
 create mode 100644 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
 create mode 100644 arch/arm/boot/dts/vf610-zii-dev.dtsi
 create mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6123_61_65.c

-- 
2.6.3
