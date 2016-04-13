From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/8] DSA refactoring: set 2
Date: Thu, 14 Apr 2016 01:59:50 +0200
Message-ID: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55168 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755053AbcDNAAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More preparatory patches for the DSA probe refactoring.

The first three patches turn the Marvell drivers into individual
modules, and a shared library module. They also become real Linux
devices, with probe functions. However, at the moment, this is just
stub code to be filled out with later patches.

With the drivers becoming real devices, it becomes easier to interact
with device tree properties. One such driver property is a GPIO line
used for resetting the switch. This is only used in Marvell devices,
so move it out of the core code into the Marvell shared code. This
changes the existing binding, but no in tree device tree actually uses
it.

The REG_READ and REG_WRITE macros have caused problems in the past,
since they contain a return statement, messing up locking code. They
also assume a ds variable is available. Kill them off.

With the addition of the drivers becoming devices, the order in which
data structures are created is changing. Previously, the DSA framework
would create the dsa_switch structure and pass it to the setup()
method, which would then allocate the driver private structure. Now
the drivers probe as devices, they allocate there private structure
first, and will only get a dsa_switch structure later. Future changes
to have the device export its own MDIO bus rather than have the
framework do it, requires at some of the driver functions operate
using only the private structure. Perform a mass internal API change
to pass the private structure internally, and only pass the dsa_switch
structure for the public APIs.

Each driver maintains a table of IDs to name strings. Extending this
table with the number of ports a switch has. It is likely this will
get further extended with number of VLANs, address databases etc.

The mv88e6131 driver does something different for a single switch vs a
collection of switches. All other drivers don't special case a single
switch. There is no need to do this, so remove the special case. This
will help later with unifying this code into the shared library.

So nothing too interesting here, that will come later...


Andrew Lunn (8):
  dsa: mv88e6xxx: Prepare for turning this into a library module
  dsa: mv88e6xxx: Add macro for registering the drivers
  dsa: Add mdio device support to Marvell switches
  dsa: Move gpio reset into switch driver
  dsa: mv88e6xxx: Kill the REG_READ and REG_WRITE macros
  dsa: mv88e6xxx: Replace ds with ps where possible
  dsa: mv88e6xxx: Use the name table to determine number of ports
  dsa: mv88e6131: Don't special case a single device

 Documentation/devicetree/bindings/net/dsa/dsa.txt  |    2 -
 .../devicetree/bindings/net/dsa/marvell.txt        |   39 +
 drivers/net/dsa/Makefile                           |   19 +-
 drivers/net/dsa/mv88e6123.c                        |   78 +-
 drivers/net/dsa/mv88e6131.c                        |  112 +-
 drivers/net/dsa/mv88e6171.c                        |   62 +-
 drivers/net/dsa/mv88e6352.c                        |   90 +-
 drivers/net/dsa/mv88e6xxx.c                        | 1240 +++++++++++---------
 drivers/net/dsa/mv88e6xxx.h                        |   66 +-
 include/net/dsa.h                                  |    8 -
 net/dsa/dsa.c                                      |   16 -
 11 files changed, 1000 insertions(+), 732 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.txt

-- 
2.7.0
