From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 00/12] net: Unified offload configuration
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53547 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683Ab0LOWYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a second attempt at defining a unified offload-setting interfac=
e
for network drivers. The changes are influenced by comments on the orig=
inal
proposal and deeper look into what drivers do.

The idea:

Introduce two new fields to struct net_device to hold toggable and
user-requested feature sets. Offload features can be in:

  hw_features
	features user can toggle (e.g., via ethtool)

  wanted_features
	features requested by user - his/her wish if you prefer
	(subset of .hw_features + software-only features)

  features
	features currently active; if some offloads depend
	on other conditions, the set in .features & .hw_features
	might be not equal to .wanted_features & .hw_features

To check and transfer offload settings from .wanted_features to
=2Efeatures, there are two new hooks in struct net_device_ops:

  features =3D ndo_fix_features(netdev, features);
	modifies passed feature set according to device-specific
	conditions

  err =3D ndo_set_features(netdev, features);
	should reconfigure the hardware for a new feature set

Core code:

  netdev_update_features(netdev);
	should be called after feature conditions changed, i.e.
	after MTU change, or slave device reconfiguration

  features =3D netdev_get_wanted_features(netdev);
	convenience function: replaces bits from .hw_features=20
	(plus software-only features) in .features with .wanted_features

Other things added:
  - a compatibility layer for old ethtool ops for drivers converted
    to new offload setting API
  - transitional calls to old ethtool_ops for not-yet-converted drivers
  - a new flag for RX checksumming to replace driver-private fields/fla=
gs
  - request software offloads (GSO and GRO) by default
  - example conversions of a few drivers

Things to do after:
  - convert all drivers
  - remove redundant offload state in drivers
  - remove old ethtool_ops hooks (set_tso, set_flags, set_hw_csum, etc.=
)

This is only build-tested on x86 allyesconfig, so probably not for gene=
ral
use, yet.

Best Regards,
Micha=C5=82 Miros=C5=82aw

Micha=C5=82 Miros=C5=82aw (12):
  net: Move check of checksum features to netdev_fix_features()
  net: Introduce new feature setting ops
  net: ethtool: use ndo_fix_features for offload setting
  net: introduce NETIF_F_RXCSUM
  net: ethtool: use ndo_fix_features for ethtool_ops->set_flags
  bridge: convert br_features_recompute() to ndo_fix_features
  vlan: convert VLAN devices to use ndo_fix_features()
  jme: convert offload constraints to ndo_fix_features
  virtio_net: convert to ndo_fix_features
  Intel net drivers: convert to ndo_fix_features
  veth: convert to hw_features
  skge: convert to hw_features

 drivers/net/e1000/e1000_ethtool.c  |   69 -------
 drivers/net/e1000/e1000_main.c     |   31 +++-
 drivers/net/e1000e/ethtool.c       |   62 ------
 drivers/net/e1000e/netdev.c        |   31 +++-
 drivers/net/igb/igb_ethtool.c      |   67 -------
 drivers/net/igb/igb_main.c         |   34 +++-
 drivers/net/igbvf/ethtool.c        |   57 ------
 drivers/net/igbvf/netdev.c         |   26 ++-
 drivers/net/ixgb/ixgb.h            |    2 +
 drivers/net/ixgb/ixgb_ethtool.c    |   59 +------
 drivers/net/ixgb/ixgb_main.c       |   31 +++-
 drivers/net/ixgbe/ixgbe_ethtool.c  |   65 -------
 drivers/net/ixgbe/ixgbe_main.c     |   32 +++-
 drivers/net/ixgbevf/ethtool.c      |   46 -----
 drivers/net/ixgbevf/ixgbevf_main.c |   27 +++-
 drivers/net/jme.c                  |   79 ++------
 drivers/net/jme.h                  |    2 -
 drivers/net/skge.c                 |   53 +-----
 drivers/net/skge.h                 |    1 -
 drivers/net/veth.c                 |   45 +----
 drivers/net/virtio_net.c           |   46 ++---
 include/linux/ethtool.h            |   29 +++-
 include/linux/netdevice.h          |   34 ++++
 net/8021q/vlan.c                   |    3 +-
 net/8021q/vlan_dev.c               |   51 ++----
 net/bridge/br_device.c             |   57 +-----
 net/bridge/br_if.c                 |   17 +-
 net/bridge/br_notify.c             |    2 +-
 net/bridge/br_private.h            |    4 +-
 net/core/dev.c                     |   80 ++++++--
 net/core/ethtool.c                 |  364 +++++++++++++++++++---------=
--------
 31 files changed, 579 insertions(+), 927 deletions(-)

--=20
1.7.2.3

