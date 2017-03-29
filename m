From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/9] net: dsa: mv88e6xxx: program cross-chip bridging
Date: Wed, 29 Mar 2017 16:30:11 -0400
Message-ID: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose of this patch series is to bring hardware cross-chip
bridging configuration to the DSA layer and the mv88e6xxx DSA driver.

Most recent Marvell switch chips have a Cross-chip Port Based VLAN Table
(PVT) used to restrict to which internal destination port an arbitrary
external source port is allowed to egress frames to.

The current behavior of the mv88e6xxx driver is to program this table
table with all ones, allowing any external ports to egress frames on any
internal ports. This means that carefully crafted Ethernet frames can
potentially bypass the user bridging configuration.

Patches 1 to 7 prepare the setup of this table and factorize the common
bits of both in-chip and cross-chip Marvell bridging code.

Patch 8 adds new optional cross-chip bridging operations to DSA switch.

Patch 9 switches the current behavior to program the table according to
the user bridging configuration when (cross-chip) ports get (un)bridged.

On a ZII Rev B board, bridging together the 3 user ports of both 88E6352
will result in the following PVTs on respectively switch 0 and switch 1:

    External   Internal Ports
    Dev Port   0  1  2  3  4  5  6

     1    0    *  *  *  -  -  *  *
     1    1    *  *  *  -  -  *  *
     1    2    *  *  *  -  -  *  *
     1    3    -  -  -  -  -  *  *
     1    4    -  -  -  -  -  *  *
     1    5    *  *  *  *  *  *  *
     1    6    *  *  *  *  *  *  *

     0    0    *  *  *  -  -  *  *
     0    1    *  *  *  -  -  *  *
     0    2    *  *  *  -  -  *  *
     0    3    -  -  -  -  -  *  *
     0    4    -  -  -  -  -  *  *
     0    5    *  *  *  *  *  *  *
     0    6    *  *  *  *  *  *  *


Vivien Didelot (9):
  net: dsa: mv88e6xxx: move PVT description in info
  net: dsa: mv88e6xxx: use 4-bit port for PVT data
  net: dsa: mv88e6xxx: program the PVT with all ones
  net: dsa: mv88e6xxx: allocate the number of ports
  net: dsa: mv88e6xxx: rework in-chip bridging
  net: dsa: mv88e6xxx: factorize in-chip bridge map
  net: dsa: mv88e6xxx: remap existing bridge members
  net: dsa: add cross-chip bridging operations
  net: dsa: mv88e6xxx: add cross-chip bridging

 drivers/net/dsa/mv88e6xxx/chip.c      | 212 ++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx/global2.c   |  71 ++++++++++--
 drivers/net/dsa/mv88e6xxx/global2.h   |  15 +++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  33 ++----
 include/net/dsa.h                     |   8 ++
 net/dsa/switch.c                      |  12 +-
 6 files changed, 278 insertions(+), 73 deletions(-)

-- 
2.12.1
