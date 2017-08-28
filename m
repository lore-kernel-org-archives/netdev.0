From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Mon, 28 Aug 2017 15:17:38 -0400
Message-ID: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds a generic debugfs interface for the DSA
framework, so that all switch devices benefit from it, e.g. Marvell,
Broadcom, Microchip or any other DSA driver.

This is really convenient for debugging, especially CPU ports and DSA
links which are not exposed to userspace as net device. This interface
is currently the only way to easily inspect the hardware for such ports.

With the patch series, any switch device user is able to query the
hardware for the supported tagging protocol, the ports stats and
registers, as well as their FDB, MDB and VLAN entries.

This support is only compiled if CONFIG_DEBUG_FS is enabled. Below is
and example of usage of this interface on a multi-chip switch fabric:

    # mount -t debugfs none /sys/kernel/debug
    # cd /sys/kernel/debug/dsa/
    # ls
    switch0  switch1 switch2
    # ls -l switch0/
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port0
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port1
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port2
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port5
    drwxr-xr-x 2 root root 0 Jan  1 00:00 port6
    -r--r--r-- 1 root root 0 Jan  1 00:00 tag_protocol
    -r--r--r-- 1 root root 0 Jan  1 00:00 tree
    # ls -l switch0/port6
    -r--r--r-- 1 root root 0 Jan  1 00:00 fdb
    -r--r--r-- 1 root root 0 Jan  1 00:00 mdb
    -r--r--r-- 1 root root 0 Jan  1 00:00 regs
    -r--r--r-- 1 root root 0 Jan  1 00:00 stats
    -r--r--r-- 1 root root 0 Jan  1 00:00 vlan
    # cat switch0/port2/vlan
    vid 42  untagged  pvid
    # cat switch0/port1/fdb
    vid 0  12:34:56:78:90:ab  unicast  static
    # pr -mt switch0/port{5,6}/stats
    in_good_octets      : 0             in_good_octets      : 13824
    in_bad_octets       : 0             in_bad_octets       : 0
    in_unicast          : 0             in_unicast          : 0
    in_broadcasts       : 0             in_broadcasts       : 216
    in_multicasts       : 0             in_multicasts       : 0
    in_pause            : 0             in_pause            : 0
    in_undersize        : 0             in_undersize        : 0
    ...
    # pr -mt switch0/port{5,6}/regs
     0: 4e07			     0: 4d04
     1: 403e			     1: 003d
     2: 0000			     2: 0000
     3: 3521			     3: 3521
     4: 0533			     4: 373f
     5: 8000			     5: 0000
     6: 005f			     6: 003f
     7: 002a			     7: 002a
    ...

where switch0 port5 and port6 are CPU and DSA ports of a ZII Rev B.

Changes in v2:
  - KISS, drop the WARN_ON if !dst->applied
  - use ds->enabled_port_mask instead of OF nodes
  - add a tag protocol to string helper
  - use %pM to print MAC addresses
  - explicit "tagged" VLANs

Vivien Didelot (10):
  net: dsa: add debugfs interface
  net: dsa: debugfs: add tree
  net: dsa: debugfs: add tag_protocol
  net: dsa: debugfs: add port stats
  net: dsa: debugfs: add port regs
  net: dsa: debugfs: add port fdb
  net: dsa: restore mdb dump
  net: dsa: debugfs: add port mdb
  net: dsa: restore VLAN dump
  net: dsa: debugfs: add port vlan

 drivers/net/dsa/b53/b53_common.c       |  41 ++++
 drivers/net/dsa/b53/b53_priv.h         |   2 +
 drivers/net/dsa/bcm_sf2.c              |   1 +
 drivers/net/dsa/dsa_loop.c             |  38 +++
 drivers/net/dsa/microchip/ksz_common.c |  41 ++++
 drivers/net/dsa/mv88e6xxx/chip.c       |  82 ++++++-
 include/net/dsa.h                      |  41 ++++
 net/dsa/Kconfig                        |  14 ++
 net/dsa/Makefile                       |   1 +
 net/dsa/debugfs.c                      | 409 +++++++++++++++++++++++++++++++++
 net/dsa/dsa.c                          |   3 +
 net/dsa/dsa2.c                         |   4 +
 net/dsa/dsa_priv.h                     |  13 ++
 net/dsa/legacy.c                       |   4 +
 14 files changed, 686 insertions(+), 8 deletions(-)
 create mode 100644 net/dsa/debugfs.c

-- 
2.14.1
