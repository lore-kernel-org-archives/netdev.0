From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 0/8] net: dsa: mv88e6xxx: support switchdev FDB objects
Date: Mon, 10 Aug 2015 09:09:45 -0400
Message-ID: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64289 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbbHJNKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 09:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset refactors the FDB management in the mv88e6xxx code and adds the
glue in DSA to use the switchdev FDB objects.

Below is an usage example (ports 0-2 belongs to br0, ports 3-4 belongs to br1):

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

Changes in v3:

 - reorder commits to improve bisectability and minimize diffs

 - add an ndm_state member in switchdev_fdb_obj instead of an is_static boolean

 - drop the need to convert unsigned char *addr to u8 addr[ETH_ALEN]
   (it is casted to char pointer anyway)

Changes in v2:

 - remove ndo_bridge_{get,set,del}link from switchdev/DSA glue code

 - use ether_addr_copy instead of memcpy for MAC addresses

 - constify MAC address in port_fdb_{add,del}

 - split the mv88e6xxx code refactoring into several patches

Vivien Didelot (8):
  net: dsa: mv88e6xxx: define GLOBAL_ATU_FID
  net: dsa: mv88e6xxx: extend fid mask
  net: dsa: mv88e6xxx: rename ATU MAC accessors
  net: dsa: change FDB routines prototypes
  net: dsa: mv88e6xxx: rework FDB add/del operations
  net: dsa: mv88e6xxx: rework FDB Get Next operation
  net: switchdev: support static FDB addresses
  net: dsa: add support for switchdev FDB objects

 drivers/net/dsa/mv88e6171.c          |   6 +-
 drivers/net/dsa/mv88e6352.c          |   6 +-
 drivers/net/dsa/mv88e6xxx.c          | 185 ++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx.h          |  21 +++-
 drivers/net/ethernet/rocker/rocker.c |   1 +
 include/net/dsa.h                    |  17 ++--
 include/net/switchdev.h              |   1 +
 net/dsa/slave.c                      | 150 ++++++++++++++++------------
 net/switchdev/switchdev.c            |   2 +-
 9 files changed, 260 insertions(+), 129 deletions(-)

-- 
2.5.0
