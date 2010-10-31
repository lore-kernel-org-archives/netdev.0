From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 0/4] Ethtool: cleanup strategy
Date: Sun, 31 Oct 2010 04:40:04 +0100
Message-ID: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49490 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698Ab0JaEAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 00:00:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While writing and debugging driver for StorLink's Gemini ethernet
"card" I couldn't not notice that ethtool support had accumulated a lot
of dust and "aah, let's just copy that from another driver"-generated
code.  There are things that are reimplemented in more-or-less same way
in multiple network drivers, there are logic bugs or unexpected
variations among the implementations, and there is a lot of boilerplate
code needed to be written by a person who wants to support ethtool
in his driver.  I'm concentrating on offload feature setting here as
that's what I needed for my driver.

As I scanned through multiple drivers and ethtool core I noticed that
most (if not all) offload capabilities are determinable at ndo_init()
time.  There are, however, some exceptions as bridge and VLAN drivers,
or chips that have offload capabilities dependent on MTU setting.

Transmit offload features are the simple ones --- almost all drivers
enable support for them at per-packet when-needed basis and so they can
be disabled just by performing the required actions in software before
ndo_start_xmit(). Using a particular offload is mostly a matter of
setting its bit in netdev->features.

Receive offloads are another beast.  They usually need to be enabled
in hardware or ignored/worked-around by the driver for buggy HW.
Changing the offload's state is done in device-specific way.

My proposal is to implement a offload feature setting that needs
(almost) no code in network driver.  The idea is to add two
ethtool-specific fields to struct net_device:

 - hw_features
      offloads supported by the netdev (togglable by user)
 - features_requested
      offloads currently requested by user; this will be superset of
      (features & hw_features) when i.e. current MTU or other external
      conditions disable some offloads

=2E.. and use them to implement changing of offloads in ethtool core.
Since get_*() for TX offloads is just a bit test on netdev->features,
corresponding ethtool entry points could be removed.

This patch series is a beginning proof-of-concept work for this idea.
This is a minimal cleanup and move of TX checksum, scatter-gather and
TSO offloads to the new arrangement.  This is intended to be a mostly
no-op in functionality, so most bugs there are preserved and only
minimal code changes in drivers are made except when driver-local
get/set function code can be removed.

Please apply it if you like it as it is now. Further changes will
depend on those anyway. Later in this mail I attached couple of notes
I've taken during the conversion of some drivers. As the Cc list for
all maintainers would be huge (all network drivers are touched), I kept
only those who's drivers are changed in less obvious or uncertain ways.

Best Regards,
Micha=C5=82 Miros=C5=82aw


  loopback
	missing TSO6 in netdev->features

  bridge
	dynamic hw caps - might need more thought

  8021q/vlan
	uses set_tso, missing TSO6 in tested features
	dynamic hw caps -> might need more thought

  xen-netfront
	optimize offload setting

  ipoib
	uses set_tso - can be moved to netdev_init?

* cxgb2
	assumed: adapter->flags initialized and can't change

* e1000
	removed unused adapter->tso_force
	set_tx_csum side-effect: fix inverted test

  enic
	uses set_tso - can be moved to netdev_init?

* ixgbevf
	set_tso: netif_tx_stop/start_all_queues removed from disable path

  jme
	csum,tso limited to MTU <=3D 1900

  mlx4
	uses set_tso - can be moved to netdev_init?
		errno: EPERM -> EINVAL

  tg3
	uses set_tso - parts can be moved to netdev_init?
		tso MTU 1500 on some boards
	TG3_FLAG_BROKEN_CHECKSUMS - are netdev->features based on this?

* usb/smsc75xx
	set tx_csum,tso features reset() -> init() - ok?

* usb/smsc95xx
	uses set_tx_csum
	move features change from reset()? - ok to set like this if not?

* bna
	set_tx_csum: removed bnad->conf_mutex locking

  dm9000
	removed struct board_info->can_csum

* gianfar
	set_tx_csum: removed netif_tx_lock_bh() locking

* greth
	set_tx_csum: removed netif_tx_lock_bh() locking

  ibmveth
	uses set_tx_csum - can be changed to avoid it?

  pch_gbe
	uses set_tx_csum - remove adapter->tx_csum completely?
		it's redundant (=3D=3D netdev->features & NETIF_F_HW_CSUM)

* qlcnic
	set_tx_csum: is ESWITCH exclusion constant?

* sfc
	assumed: constant efx->type->offload_features

  sky2
	set_tx_csum, set_tso: merge to no_tx_offload()?
		MTU 1500 for CHIP_ID_YUKON_EC_U

  s390/net
	uses set_tso
	uses set_tx_csum - can be moved to netdev_init?



Micha=C5=82 Miros=C5=82aw (4):
  Ethtool: Introduce hw_features field in struct netdevice
  Ethtool: convert get_sg/set_sg calls to hw_features flag
  Ethtool: convert get_tso/set_tso calls to hw_features flags
  Ethtool: convert get_tx_csum/set_tx_csum calls to hw_features flags

 drivers/infiniband/hw/nes/nes_nic.c          |    8 +-
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c |   10 +-
 drivers/net/8139cp.c                         |    5 +-
 drivers/net/atl1c/atl1c_ethtool.c            |    9 +--
 drivers/net/atl1e/atl1e_ethtool.c            |    5 +-
 drivers/net/atlx/atl1.c                      |    6 +-
 drivers/net/atlx/atl2.c                      |   12 +--
 drivers/net/benet/be_ethtool.c               |    6 -
 drivers/net/benet/be_main.c                  |    2 +
 drivers/net/bna/bnad_ethtool.c               |   43 +-------
 drivers/net/bnx2.c                           |   33 +-----
 drivers/net/bnx2x/bnx2x_ethtool.c            |   21 +---
 drivers/net/bonding/bond_main.c              |    3 -
 drivers/net/chelsio/cxgb2.c                  |   15 +--
 drivers/net/cxgb3/cxgb3_main.c               |    5 +-
 drivers/net/cxgb4/cxgb4_main.c               |   14 +--
 drivers/net/cxgb4vf/cxgb4vf_main.c           |   18 +---
 drivers/net/dm9000.c                         |   17 +---
 drivers/net/e1000/e1000.h                    |    1 -
 drivers/net/e1000/e1000_ethtool.c            |   58 ++--------
 drivers/net/e1000e/ethtool.c                 |   32 +-----
 drivers/net/ehea/ehea_ethtool.c              |    2 +-
 drivers/net/enic/enic_main.c                 |   23 +---
 drivers/net/forcedeth.c                      |   35 +-----
 drivers/net/fs_enet/fs_enet-main.c           |    3 +-
 drivers/net/gianfar.c                        |    2 +
 drivers/net/gianfar_ethtool.c                |   32 -----
 drivers/net/greth.c                          |   16 +---
 drivers/net/ibm_newemac/core.c               |    2 -
 drivers/net/ibmveth.c                        |    6 +-
 drivers/net/igb/igb_ethtool.c                |   51 +-------
 drivers/net/igbvf/ethtool.c                  |   40 +------
 drivers/net/ioc3-eth.c                       |    3 +-
 drivers/net/ixgb/ixgb_ethtool.c              |   33 +-----
 drivers/net/ixgbe/ixgbe_ethtool.c            |   48 ++-------
 drivers/net/ixgbevf/ethtool.c                |   23 +---
 drivers/net/jme.c                            |   17 ++--
 drivers/net/ksz884x.c                        |    6 +-
 drivers/net/loopback.c                       |    4 +-
 drivers/net/mlx4/en_ethtool.c                |   23 +---
 drivers/net/mlx4/en_netdev.c                 |    3 +
 drivers/net/mv643xx_eth.c                    |    3 +-
 drivers/net/myri10ge/myri10ge.c              |   17 +---
 drivers/net/netxen/netxen_nic_ethtool.c      |   34 ------
 drivers/net/netxen/netxen_nic_main.c         |    4 +
 drivers/net/pch_gbe/pch_gbe_ethtool.c        |   20 +---
 drivers/net/ps3_gelic_net.c                  |    3 +-
 drivers/net/ps3_gelic_wireless.c             |    3 +-
 drivers/net/qlcnic/qlcnic_ethtool.c          |   42 -------
 drivers/net/qlcnic/qlcnic_main.c             |    4 +
 drivers/net/qlge/qlge_ethtool.c              |   19 ---
 drivers/net/qlge/qlge_main.c                 |    3 +
 drivers/net/r8169.c                          |    5 +-
 drivers/net/s2io.c                           |   31 +-----
 drivers/net/sfc/efx.c                        |    4 +
 drivers/net/sfc/ethtool.c                    |   38 ------
 drivers/net/skge.c                           |   25 +----
 drivers/net/sky2.c                           |   11 +-
 drivers/net/spider_net.c                     |    1 +
 drivers/net/spider_net_ethtool.c             |    1 -
 drivers/net/stmmac/stmmac_ethtool.c          |   18 +---
 drivers/net/tehuti.c                         |   12 --
 drivers/net/tg3.c                            |   66 +++++------
 drivers/net/typhoon.c                        |    5 +-
 drivers/net/ucc_geth_ethtool.c               |    2 +-
 drivers/net/usb/smsc75xx.c                   |   23 +---
 drivers/net/usb/smsc95xx.c                   |   16 +--
 drivers/net/veth.c                           |   19 +---
 drivers/net/via-velocity.c                   |    4 +-
 drivers/net/virtio_net.c                     |   10 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c        |    8 +-
 drivers/net/vxge/vxge-ethtool.c              |   19 +---
 drivers/net/xen-netfront.c                   |   19 ++-
 drivers/s390/net/qeth_l3_main.c              |   21 +---
 drivers/staging/hv/netvsc_drv.c              |    3 +-
 drivers/staging/octeon/ethernet-mdio.c       |    2 -
 include/linux/ethtool.h                      |   26 +---
 include/linux/netdevice.h                    |    4 +
 net/8021q/vlan_dev.c                         |    5 +-
 net/bridge/br_device.c                       |   16 +--
 net/core/ethtool.c                           |  162 +++++++++++-------=
--------
 net/dsa/slave.c                              |    2 +-
 82 files changed, 307 insertions(+), 1118 deletions(-)

