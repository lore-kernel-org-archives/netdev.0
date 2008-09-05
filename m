From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [V#2 PATCH 0/18] netdevice: Fix directly reference of netdev->priv
Date: Fri, 05 Sep 2008 11:06:01 +0800
Message-ID: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50592 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbYIEDIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:08:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv now, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

- Patch 1-4 are the safe convert which I believe will not make "after converted " worse
  than "before converted".
  Originally, I put this kind of convert in one mail, but it's too big for vger.
  So I split it to 4 parts and make every part smaller than 100,000 bytes,
  which is max size allowed by vger.

- Patches 5-18 need comments. Since the value of netdev->priv is changed in drivers
  and I use netdev->ml_priv to replace netdev->priv.

Below is diffstat:
---
 drivers/net/3c501.c                        |    2
 drivers/net/3c505.c                        |   45 +++----
 drivers/net/3c523.c                        |   29 ++--
 drivers/net/3c59x.c                        |    4
 drivers/net/82596.c                        |   29 ++--
 drivers/net/acenic.c                       |    2
 drivers/net/appletalk/ipddp.c              |    6 -
 drivers/net/appletalk/ltpc.c               |   12 +-
 drivers/net/arcnet/arc-rawmode.c           |    4
 drivers/net/arcnet/arc-rimi.c              |   16 +-
 drivers/net/arcnet/arcnet.c                |   32 ++---
 drivers/net/arcnet/capmode.c               |    6 -
 drivers/net/arcnet/com20020-isa.c          |    4
 drivers/net/arcnet/com20020-pci.c          |    2
 drivers/net/arcnet/com20020.c              |   10 -
 drivers/net/arcnet/com90io.c               |    4
 drivers/net/arcnet/com90xx.c               |   10 -
 drivers/net/arcnet/rfc1051.c               |    8 -
 drivers/net/arcnet/rfc1201.c               |   12 +-
 drivers/net/atarilance.c                   |   34 ++---
 drivers/net/atl1e/atl1e_main.c             |    6 -
 drivers/net/atp.c                          |    3
 drivers/net/au1000_eth.c                   |   48 ++++----
 drivers/net/bonding/bond_3ad.c             |    7 -
 drivers/net/bonding/bond_alb.c             |    6 -
 drivers/net/bonding/bond_main.c            |   58 ++++-----
 drivers/net/bonding/bond_sysfs.c           |    2
 drivers/net/bonding/bonding.h              |    4
 drivers/net/chelsio/cxgb2.c                |   60 +++++-----
 drivers/net/chelsio/sge.c                  |    3
 drivers/net/declance.c                     |    2
 drivers/net/depca.c                        |   40 +++---
 drivers/net/dm9000.c                       |   32 ++---
 drivers/net/e1000/e1000_main.c             |    9 -
 drivers/net/e1000e/netdev.c                |    3
 drivers/net/eepro.c                        |    4
 drivers/net/epic100.c                      |   42 +++----
 drivers/net/eth16i.c                       |    2
 drivers/net/fec.c                          |    2
 drivers/net/hamradio/dmascc.c              |   12 +-
 drivers/net/hamradio/scc.c                 |   13 +-
 drivers/net/ibmveth.c                      |   34 ++---
 drivers/net/igb/igb_ethtool.c              |    4
 drivers/net/irda/ali-ircc.c                |   16 +-
 drivers/net/irda/donauboe.c                |    8 -
 drivers/net/irda/irda-usb.c                |   14 +-
 drivers/net/irda/nsc-ircc.c                |   16 +-
 drivers/net/irda/sa1100_ir.c               |   26 ++--
 drivers/net/irda/sir_dev.c                 |   12 +-
 drivers/net/irda/via-ircc.c                |   16 +-
 drivers/net/irda/vlsi_ir.c                 |   36 +++---
 drivers/net/irda/w83977af_ir.c             |   14 +-
 drivers/net/iseries_veth.c                 |   14 +-
 drivers/net/ixgbe/ixgbe_ethtool.c          |    6 -
 drivers/net/ixgbe/ixgbe_main.c             |    6 -
 drivers/net/lance.c                        |   27 ++--
 drivers/net/lp486e.c                       |   28 ++--
 drivers/net/mace.c                         |   29 ++--
 drivers/net/mv643xx_eth.c                  |    2
 drivers/net/mvme147.c                      |    4
 drivers/net/myri_sbus.c                    |   12 +-
 drivers/net/ne2k-pci.c                     |    2
 drivers/net/netxen/netxen_nic_hw.c         |    2
 drivers/net/netxen/netxen_nic_main.c       |    4
 drivers/net/ni5010.c                       |    2
 drivers/net/ni52.c                         |   36 +++---
 drivers/net/ni65.c                         |   33 ++---
 drivers/net/pasemi_mac_ethtool.c           |    4
 drivers/net/pcmcia/com20020_cs.c           |    6 -
 drivers/net/plip.c                         |    8 -
 drivers/net/ppp_generic.c                  |    7 -
 drivers/net/rionet.c                       |   26 ++--
 drivers/net/s2io.c                         |   79 ++++++-------
 drivers/net/sgiseeq.c                      |    2
 drivers/net/sis900.c                       |   64 +++++-----
 drivers/net/smc9194.c                      |    6 -
 drivers/net/sonic.h                        |   20 +--
 drivers/net/spider_net_ethtool.c           |    8 -
 drivers/net/sun3_82586.c                   |   38 +++---
 drivers/net/sunbmac.c                      |   18 +--
 drivers/net/sungem.c                       |   52 ++++----
 drivers/net/sunhme.c                       |   26 ++--
 drivers/net/sunqe.c                        |   14 +-
 drivers/net/tehuti.c                       |   38 +++---
 drivers/net/tokenring/tms380tr.c           |   14 +-
 drivers/net/tulip/de2104x.c                |   44 +++----
 drivers/net/tulip/eeprom.c                 |    2
 drivers/net/tulip/uli526x.c                |    2
 drivers/net/typhoon.c                      |    2
 drivers/net/usb/mcs7830.c                  |    4
 drivers/net/virtio_net.c                   |    3
 drivers/net/wan/cycx_x25.c                 |   43 +++----
 drivers/net/wan/dlci.c                     |   36 +++---
 drivers/net/wan/hdlc_fr.c                  |   10 -
 drivers/net/wan/pc300_drv.c                |   18 +--
 drivers/net/wan/sbni.c                     |  100 ++++++++--------
 drivers/net/wan/sdla.c                     |   48 ++++----
 drivers/net/wan/x25_asy.c                  |   28 ++--
 drivers/net/wireless/airo.c                |  172 ++++++++++++++---------------
 drivers/net/wireless/libertas/ethtool.c    |   12 +-
 drivers/net/wireless/libertas/main.c       |   37 +++---
 drivers/net/wireless/libertas/persistcfg.c |   16 +-
 drivers/net/wireless/libertas/scan.c       |    4
 drivers/net/wireless/libertas/tx.c         |    3
 drivers/net/wireless/libertas/wext.c       |   72 ++++++------
 drivers/net/wireless/rndis_wlan.c          |   62 +++++-----
 drivers/net/wireless/wavelan.c             |   88 +++++++-------
 drivers/net/wireless/zd1201.c              |   65 +++++-----
 drivers/net/znet.c                         |   22 +--
 include/linux/hdlc.h                       |    3
 net/appletalk/ddp.c                        |    2
 net/atm/br2684.c                           |    2
 net/atm/lec.c                              |   34 +++--
 net/atm/mpc.c                              |   10 -
 net/bluetooth/bnep/core.c                  |    2
 net/bluetooth/bnep/netdev.c                |    6 -
 net/bridge/br_if.c                         |    2
 net/bridge/br_sysfs_br.c                   |    2
 net/irda/irlan/irlan_common.c              |    3
 net/wanrouter/wanmain.c                    |   24 ++--
 120 files changed, 1221 insertions(+), 1224 deletions(-)


