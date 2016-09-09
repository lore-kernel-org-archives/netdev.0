From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Fri, 9 Sep 2016 14:05:55 -0400
Message-ID: <20160909180555.GE20632@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907203112.GA26445@lunn.ch>
 <20160907234306.GY33916@redhat.com>
 <20160908012413.GA12745@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:36831 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbcIISF7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 14:05:59 -0400
Received: by mail-yb0-f182.google.com with SMTP id u125so31252745ybg.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 11:05:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160908012413.GA12745@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 03:24:13AM +0200, Andrew Lunn wrote:
> > This is definitely going to require a few passes... (Working my way
> > through every driver with an ndo_change_mtu wired up right now to
> > see just how crazy this might get).
> 
> It might be something Coccinelle can help you with. Try describing the
> transformation you want to do, to their mailing list, and they might
> come up with a script for you.

>From looking everything over, I'd be very surprised if they could. The
places where things need changing vary quite wildly by driver, but I've
actually got a full set of compiling changes with a cumulative diffstat
of:

 153 files changed, 599 insertions(+), 1002 deletions(-)

Actually breaking this up into easily digestable/mergeable chunks is going
to be kind of entertaining... Suggestions welcomed on that. First up is
obviously the core change, which touches just net/ethernet/eth.c,
net/core/dev.c, include/linux/netdevice.h and
include/uapi/linux/if_ether.h, and should let existing code continue to
Just Work(tm), though devices using ether_setup() that had no MTU range
checking (or one or the other missing) will wind up with new bounds.

For the most part, after the initial patch, very few of the others
would have any direct interaction with any others, so they could all
be singletons, or small batches per-vendor, or whatever.

Full diffstat for the aid of discussion on how to break it up:

 drivers/char/pcmcia/synclink_cs.c                  |  1 -
 drivers/firewire/net.c                             | 14 ++---
 drivers/infiniband/hw/nes/nes.c                    |  1 -
 drivers/infiniband/hw/nes/nes.h                    |  4 +-
 drivers/infiniband/hw/nes/nes_nic.c                |  7 +--
 drivers/misc/sgi-xp/xpnet.c                        | 21 ++------
 drivers/net/ethernet/agere/et131x.c                |  7 +--
 drivers/net/ethernet/altera/altera_tse.h           |  1 -
 drivers/net/ethernet/altera/altera_tse_main.c      | 12 ++---
 drivers/net/ethernet/amd/amd8111e.c                |  5 +-
 drivers/net/ethernet/atheros/alx/hw.h              |  1 -
 drivers/net/ethernet/atheros/alx/main.c            |  9 +---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    | 41 +++++++++-----
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    | 11 ++--
 drivers/net/ethernet/atheros/atlx/atl1.c           | 15 +++---
 drivers/net/ethernet/atheros/atlx/atl2.c           | 14 +++--
 drivers/net/ethernet/broadcom/b44.c                |  5 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       | 30 +++--------
 drivers/net/ethernet/broadcom/bnx2.c               |  8 ++-
 drivers/net/ethernet/broadcom/bnx2.h               |  6 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  8 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   | 22 +++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  4 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  7 +--
 drivers/net/ethernet/broadcom/tg3.c                |  7 +--
 drivers/net/ethernet/brocade/bna/bnad.c            |  7 +--
 drivers/net/ethernet/cadence/macb.c                | 17 +++---
 drivers/net/ethernet/calxeda/xgmac.c               | 18 ++-----
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 15 ++----
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   |  5 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 10 ++--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |  2 -
 drivers/net/ethernet/cisco/enic/enic_main.c        |  7 +--
 drivers/net/ethernet/cisco/enic/enic_res.h         |  2 +-
 drivers/net/ethernet/dlink/dl2k.c                  | 22 ++------
 drivers/net/ethernet/dlink/sundance.c              |  6 ++-
 drivers/net/ethernet/freescale/gianfar.c           |  9 ++--
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  4 --
 drivers/net/ethernet/ibm/ehea/ehea_main.c          | 13 ++---
 drivers/net/ethernet/ibm/emac/core.c               |  7 +--
 drivers/net/ethernet/intel/e100.c                  |  9 ----
 drivers/net/ethernet/intel/e1000/e1000_main.c      | 12 ++---
 drivers/net/ethernet/intel/e1000e/netdev.c         | 14 +++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    | 15 ++----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 10 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  8 +--
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          | 16 ++----
 drivers/net/ethernet/intel/igbvf/defines.h         |  3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          | 14 ++---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        | 16 ++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 11 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 33 ++++++------
 drivers/net/ethernet/marvell/mvneta.c              | 36 ++++---------
 drivers/net/ethernet/marvell/mvpp2.c               | 36 ++++---------
 drivers/net/ethernet/marvell/pxa168_eth.c          |  7 +--
 drivers/net/ethernet/marvell/skge.c                |  7 +--
 drivers/net/ethernet/marvell/sky2.c                | 18 +++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  8 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 23 +++-----
 drivers/net/ethernet/micrel/ksz884x.c              | 33 ++++++------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   | 20 +++----
 drivers/net/ethernet/natsemi/natsemi.c             |  7 +--
 drivers/net/ethernet/neterion/s2io.c               |  9 ++--
 drivers/net/ethernet/neterion/vxge/vxge-config.h   |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |  9 ++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 10 ++--
 drivers/net/ethernet/nvidia/forcedeth.c            |  9 ++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 11 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           | 12 +++--
 drivers/net/ethernet/qlogic/qede/qede.h            |  5 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |  8 ---
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  4 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  6 ---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  4 ++
 drivers/net/ethernet/qualcomm/qca_framing.h        |  6 +--
 drivers/net/ethernet/qualcomm/qca_spi.c            | 16 ++----
 drivers/net/ethernet/realtek/8139cp.c              |  8 +--
 drivers/net/ethernet/realtek/8139too.c             | 13 ++---
 drivers/net/ethernet/realtek/r8169.c               |  8 +--
 drivers/net/ethernet/rocker/rocker_main.c          | 12 ++---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 17 ++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 ++++-----
 drivers/net/ethernet/sun/cassini.c                 |  7 +--
 drivers/net/ethernet/sun/ldmvsw.c                  |  5 +-
 drivers/net/ethernet/sun/niu.c                     |  7 +--
 drivers/net/ethernet/sun/sungem.c                  | 11 ++--
 drivers/net/ethernet/sun/sunvnet.c                 |  4 ++
 drivers/net/ethernet/sun/sunvnet_common.c          | 10 ----
 drivers/net/ethernet/sun/sunvnet_common.h          |  3 +-
 drivers/net/ethernet/tehuti/tehuti.c               | 14 ++---
 drivers/net/ethernet/tehuti/tehuti.h               |  3 ++
 drivers/net/ethernet/ti/netcp_core.c               | 20 ++-----
 drivers/net/ethernet/tile/tilegx.c                 | 21 +++-----
 drivers/net/ethernet/tile/tilepro.c                | 27 ++--------
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       | 23 ++------
 drivers/net/ethernet/toshiba/spider_net.c          | 24 ++-------
 drivers/net/ethernet/via/via-velocity.c            | 11 ++--
 drivers/net/geneve.c                               | 48 +++++++----------
 drivers/net/hippi/rrunner.c                        |  1 -
 drivers/net/hyperv/hyperv_net.h                    |  4 +-
 drivers/net/hyperv/netvsc_drv.c                    | 14 ++---
 drivers/net/macvlan.c                              |  6 ++-
 drivers/net/rionet.c                               | 15 ++----
 drivers/net/slip/slip.c                            | 11 ++--
 drivers/net/tun.c                                  | 20 +++----
 drivers/net/usb/lan78xx.c                          |  8 ++-
 drivers/net/usb/r8152.c                            | 18 +++++--
 drivers/net/usb/usbnet.c                           |  2 -
 drivers/net/virtio_net.c                           | 23 ++++----
 drivers/net/vmxnet3/vmxnet3_drv.c                  |  7 +--
 drivers/net/vxlan.c                                | 62 +++++++++++-----------
 drivers/net/wan/c101.c                             |  1 -
 drivers/net/wan/cosa.c                             |  1 -
 drivers/net/wan/dscc4.c                            |  1 -
 drivers/net/wan/farsync.c                          |  1 -
 drivers/net/wan/fsl_ucc_hdlc.c                     |  1 -
 drivers/net/wan/hdlc.c                             | 11 +---
 drivers/net/wan/hdlc_fr.c                          |  3 +-
 drivers/net/wan/hostess_sv11.c                     |  1 -
 drivers/net/wan/ixp4xx_hss.c                       |  1 -
 drivers/net/wan/lmc/lmc_main.c                     |  1 -
 drivers/net/wan/n2.c                               |  1 -
 drivers/net/wan/pc300too.c                         |  1 -
 drivers/net/wan/pci200syn.c                        |  1 -
 drivers/net/wan/sealevel.c                         |  1 -
 drivers/net/wan/wanxl.c                            |  1 -
 drivers/net/wireless/ath/wil6210/netdev.c          | 17 +-----
 drivers/net/wireless/atmel/atmel.c                 | 13 ++---
 drivers/net/wireless/cisco/airo.c                  | 14 ++---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |  3 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  8 ++-
 drivers/net/wireless/intel/ipw2x00/libipw.h        |  1 -
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |  9 ----
 drivers/staging/octeon/ethernet.c                  | 16 ++----
 drivers/staging/wlan-ng/p80211netdev.c             | 18 ++-----
 drivers/tty/synclink.c                             |  1 -
 drivers/tty/synclink_gt.c                          |  1 -
 drivers/tty/synclinkmp.c                           |  1 -
 include/linux/hdlc.h                               |  2 -
 include/linux/hippidevice.h                        |  1 -
 include/linux/netdevice.h                          |  4 ++
 include/uapi/linux/if_ether.h                      |  2 +
 net/802/hippi.c                                    | 14 +----
 net/atm/lec.c                                      | 11 +---
 net/batman-adv/soft-interface.c                    | 13 +----
 net/bridge/br_device.c                             |  3 +-
 net/core/dev.c                                     | 12 ++++-
 net/ethernet/eth.c                                 |  4 +-
 net/openvswitch/vport-internal_dev.c               | 10 ----
 net/sched/sch_teql.c                               |  5 +-
 153 files changed, 599 insertions(+), 1002 deletions(-)


-- 
Jarod Wilson
jarod@redhat.com
