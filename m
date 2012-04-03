From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 00/28] ethtool: support time stamping and phc clocks
Date: Tue,  3 Apr 2012 19:47:24 +0200
Message-ID: <cover.1333474520.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57377 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644Ab2DCRsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:48:05 -0400
Received: by wibhq7 with SMTP id hq7so3973733wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:48:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in V3:
- works without ethtool_ops
- does not require special privileges
- neated user space tool output

Support for SO_TIMESTAMPING of network packets and PTP Hardware Clocks
has been expanding over the last year or two. In an ideal world, every
host would have exactly one PTP hardware clock, and every Ethernet MAC
would support SO_TIMESTAMPING on both the transmit and receive paths.
However, since we do not yet have full coverage for these features,
user space programs need a way to discover what a given interface
supports in these two areas.

* PTP Hardware Clocks

  The relationship between the network interfaces and the (possibly
  multiple) PHC devices is not discoverable except by knowing what
  hardware you have got and carefully looking into the kernel log.

* SO_TIMESTAMPING

  - Receive software time stamps are implemented in the stack
    and thus work for all MAC hardware.
  - Transmit software time stamps are only supported by a dozen
    drivers or so.
  - Some special devices support Tx/Rx time stamping in hardware.
  - None of this is discoverable except by looking into the kernel
    sources.

This series exposes the hardware and driver capabilities known to user
space via ethtool. 

Since the PHC code was first merged, this has become the number one
requested new feature.

Patch number  3 applies on top of my recent two igb/phc patches.
Patch number 12 applies on top of my recent e100 patch.

The new feature has been tested on the following hardware:

igb       Hardware time stamping in the MAC
dp83640   Hardware time stamping in the PHY
r8169     Software Tx time stamping in the MAC

Thanks,
Richard


Richard Cochran (28):
  phc: Add a method for obtaining the device index.
  ethtool: Introduce a method for getting time stamping capabilities.
  igb: Support the get_ts_info ethtool method.
  dp83640: Support the get_ts_info ethtool method.
  gianfar: Support the get_ts_info ethtool method.
  bfin_mac: Support the get_ts_info ethtool method.
  ixp4xx_eth: Support the get_ts_info ethtool method.
  ethtool: Add a common function for drivers with transmit time
    stamping.
  ax88796: Support the get_ts_info ethtool method.
  davinci_emac: Support the get_ts_info ethtool method.
  dnet: Support the get_ts_info ethtool method.
  e100: Support the get_ts_info ethtool method.
  etherh: Support the get_ts_info ethtool method.
  fec_mpc52xx: Support the get_ts_info ethtool method.
  fec: Support the get_ts_info ethtool method.
  fs_enet: Support the get_ts_info ethtool method.
  ll_temac: Support the get_ts_info ethtool method.
  macb: Support the get_ts_info ethtool method.
  mv643xx_eth: Support the get_ts_info ethtool method.
  pxa168_eth: Support the get_ts_info ethtool method.
  r6040: Support the get_ts_info ethtool method.
  r8169: Support the get_ts_info ethtool method.
  smsc911x: Support the get_ts_info ethtool method.
  smsc9420: Support the get_ts_info ethtool method.
  stmmac: Support the get_ts_info ethtool method.
  tg3: Support the get_ts_info ethtool method.
  ucc_geth: Support the get_ts_info ethtool method.
  usbnet: Support the get_ts_info ethtool method.

 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h      |    3 +
 drivers/net/ethernet/8390/ax88796.c                |    1 +
 drivers/net/ethernet/8390/etherh.c                 |    1 +
 drivers/net/ethernet/adi/bfin_mac.c                |   20 +++++++
 drivers/net/ethernet/broadcom/tg3.c                |    1 +
 drivers/net/ethernet/cadence/macb.c                |    1 +
 drivers/net/ethernet/dnet.c                        |    1 +
 drivers/net/ethernet/freescale/fec.c               |    1 +
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    1 +
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 +
 drivers/net/ethernet/freescale/gianfar.h           |    3 +
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   29 ++++++++++
 drivers/net/ethernet/freescale/gianfar_ptp.c       |    2 +
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c  |    1 +
 drivers/net/ethernet/intel/e100.c                  |    1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |   31 ++++++++++
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    1 +
 drivers/net/ethernet/marvell/pxa168_eth.c          |    1 +
 drivers/net/ethernet/rdc/r6040.c                   |    1 +
 drivers/net/ethernet/realtek/r8169.c               |    1 +
 drivers/net/ethernet/smsc/smsc911x.c               |    1 +
 drivers/net/ethernet/smsc/smsc9420.c               |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    1 +
 drivers/net/ethernet/ti/davinci_emac.c             |    1 +
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    1 +
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |   29 ++++++++++
 drivers/net/phy/dp83640.c                          |   31 ++++++++++
 drivers/net/usb/usbnet.c                           |    1 +
 drivers/ptp/ptp_clock.c                            |    6 ++
 drivers/ptp/ptp_ixp46x.c                           |    3 +
 include/linux/ethtool.h                            |   29 ++++++++++
 include/linux/phy.h                                |    3 +
 include/linux/ptp_clock_kernel.h                   |    8 +++
 net/core/ethtool.c                                 |   59 +++++++++++++++++++-
 34 files changed, 273 insertions(+), 3 deletions(-)

-- 
1.7.2.5
