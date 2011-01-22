From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 00/16] net: Unified offload configuration
Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)
Message-ID: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43049 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580Ab1AVWOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 17:14:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a second version of the ethtool unification patch series.

What's in this set?
 1..3:
	cleanup patches (other patches depend on those)
 4:
	the patch - implement unified ethtool setting ops
 5..6:
	implement interoperation between old and new ethtool ops
 7:
	include RX checksum in features and plug it into new framework
 8..11:
	convert software devices to new framework
 12..16:
	examples of driver conversions to new framework
	(I love removing redundant code ;)

What is it good for?
 - unifies driver behaviour wrt hardware offloads
 - removes a lot of boilerplate code from drivers
 - allows better fine-grained control over used offloads

This is compile tested only (x86 allyesconfig). I'll get to real testin=
g
after I get matching ethtool userspace part written. I would like the c=
ore
code (ie. not necessarily including driver conversions) to be ready bef=
ore
next merge window, so that driver maintainers could have something soli=
d
to work with.

Best Regards,
Micha=C5=82 Miros=C5=82aw

v1: http://marc.info/?l=3Dlinux-netdev&m=3D129245188832643&w=3D3

Changes from v1:
 - split structures for GFEATURES/SFEATURES
 - naming of feature bits using GSTRINGS ETH_SS_FEATURES
 - strict checking of bits used in SFEATURES call
 - more comments and kernel-doc
 - rebased to net-next after 2.6.37

---

Micha=C5=82 Miros=C5=82aw (16):
  net: Move check of checksum features to netdev_fix_features()
  net: change netdev->features to u32
  net: reduce and unify printk level in netdev_fix_features()
  net: Introduce new feature setting ops
  net: ethtool: use ndo_fix_features for offload setting
  net: use ndo_fix_features for ethtool_ops->set_flags
  net: introduce NETIF_F_RXCSUM
  loopback: convert to hw_features
  bridge: convert br_features_recompute() to ndo_fix_features
  vlan: convert VLAN devices to use ndo_fix_features()
  bonding: convert to ndo_fix_features
  jme: convert offload constraints to ndo_fix_features
  virtio_net: convert to ndo_fix_features
  Intel net drivers: convert to ndo_fix_features
  veth: convert to hw_features
  skge: convert to hw_features

 drivers/net/bnx2.c                 |    2 +-
 drivers/net/bonding/bond_main.c    |   45 +++--
 drivers/net/e1000/e1000_ethtool.c  |   69 ------
 drivers/net/e1000/e1000_main.c     |   30 ++-
 drivers/net/e1000e/ethtool.c       |   62 -----
 drivers/net/e1000e/netdev.c        |   30 ++-
 drivers/net/igb/igb_ethtool.c      |   67 -----
 drivers/net/igb/igb_main.c         |   33 ++-
 drivers/net/igbvf/ethtool.c        |   57 -----
 drivers/net/igbvf/netdev.c         |   25 ++-
 drivers/net/ixgb/ixgb.h            |    2 +
 drivers/net/ixgb/ixgb_ethtool.c    |   59 +-----
 drivers/net/ixgb/ixgb_main.c       |   31 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c  |   65 -----
 drivers/net/ixgbe/ixgbe_main.c     |   31 ++-
 drivers/net/ixgbevf/ethtool.c      |   46 ----
 drivers/net/ixgbevf/ixgbevf_main.c |   26 ++-
 drivers/net/jme.c                  |   77 ++-----
 drivers/net/jme.h                  |    2 -
 drivers/net/loopback.c             |    9 +-
 drivers/net/myri10ge/myri10ge.c    |    4 +-
 drivers/net/sfc/ethtool.c          |    4 +-
 drivers/net/sfc/net_driver.h       |    2 +-
 drivers/net/skge.c                 |   53 +----
 drivers/net/skge.h                 |    1 -
 drivers/net/tun.c                  |    2 +-
 drivers/net/veth.c                 |   45 +---
 drivers/net/virtio_net.c           |   46 ++--
 include/linux/ethtool.h            |   87 +++++++-
 include/linux/netdevice.h          |   65 ++++-
 include/linux/skbuff.h             |    2 +-
 include/net/protocol.h             |    4 +-
 include/net/tcp.h                  |    2 +-
 include/net/udp.h                  |    2 +-
 net/8021q/vlan.c                   |    5 +-
 net/8021q/vlan_dev.c               |   50 +---
 net/bridge/br_device.c             |   56 +----
 net/bridge/br_if.c                 |   16 +-
 net/bridge/br_notify.c             |    2 +-
 net/bridge/br_private.h            |    3 +-
 net/core/dev.c                     |  114 ++++++---
 net/core/ethtool.c                 |  474 ++++++++++++++++++++++------=
--------
 net/core/net-sysfs.c               |    2 +-
 net/core/skbuff.c                  |    4 +-
 net/ipv4/af_inet.c                 |    2 +-
 net/ipv4/tcp.c                     |    2 +-
 net/ipv4/udp.c                     |    2 +-
 net/ipv6/af_inet6.c                |    2 +-
 net/ipv6/udp.c                     |    2 +-
 49 files changed, 810 insertions(+), 1013 deletions(-)

--=20
1.7.2.3

