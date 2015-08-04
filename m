From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: net: dsa: support switchdev FDB objects
Date: Tue,  4 Aug 2015 01:54:39 -0400
Message-ID: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset refactors the DSA and mv88e6xxx code to use the switchdev FDB
objects.

The first two patches add minor but necessary changes to switchdev, the third
one implements the switchdev glue in DSA for FDB routines, and the forth one
refactors the FDB access functions in the mv88e6xxx code.

Below is an example (ports 0-2 belongs to br0, ports 3-4 belongs to br1):

    # bridge fdb add 3c:97:0e:11:30:6e dev swp2
    # bridge fdb add 3c:97:0e:11:40:78 dev swp3
    # bridge fdb add 3c:97:0e:11:50:86 dev swp4
    # bridge fdb del 3c:97:0e:11:40:78 dev swp3
    # bridge fdb
    01:00:5e:00:00:01 dev eth0 self permanent
    01:00:5e:00:00:01 dev eth1 self permanent
    00:50:d2:10:78:15 dev swp0 master br0 permanent
    3c:97:0e:11:30:6e dev swp2 self static
    00:50:d2:10:78:15 dev swp3 master br1 permanent
    3c:97:0e:11:50:86 dev swp4 self static
    # cat /sys/kernel/debug/dsa0/atu
    # DB   T/P  Vec State Addr
    # 001  Port 004   e   3c:97:0e:11:30:6e
    # 004  Port 010   e   3c:97:0e:11:50:86

For the 88E6xxx switches, FIDs 1 to num_ports will be reserved for non-bridged
ports and bridge groups, and the remaining will be later used by VLANs.

This change is necessary to welcome the support for hardware VLANs (which will
follow soon).

Cheers,
-v

Vivien Didelot (4):
  net: switchdev: change fdb addr for a byte array
  net: switchdev: support static FDB addresses
  net: dsa: add support for switchdev FDB objects
  net: dsa: mv88e6xxx: refactor FDB routines

 drivers/net/dsa/mv88e6171.c          |   6 +-
 drivers/net/dsa/mv88e6352.c          |   6 +-
 drivers/net/dsa/mv88e6xxx.c          | 205 ++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx.h          |  31 +++--
 drivers/net/ethernet/rocker/rocker.c |   2 +-
 include/net/dsa.h                    |  16 ++-
 include/net/switchdev.h              |   3 +-
 net/bridge/br_fdb.c                  |   2 +-
 net/dsa/slave.c                      | 221 +++++++++++++++++++----------------
 net/switchdev/switchdev.c            |   6 +-
 10 files changed, 308 insertions(+), 190 deletions(-)

-- 
2.4.6
