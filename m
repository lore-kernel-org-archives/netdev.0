From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 0/4] Extend Time Stamping
Date: Sat, 17 Jul 2010 20:48:02 +0200
Message-ID: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493Ab0GQSsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 14:48:09 -0400
Received: by bwz1 with SMTP id 1so1698395bwz.19
        for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 11:48:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set extends the packet time stamping capabilites of the
network stack in two ways.

1. The first patch presents a work-around for the TX software time
   stamping fallback problem cited in cd4d8fdad1f1. The idea is to add
   one inline function into each MAC driver. This function will act
   as hooks for current (and possible future) time stamping needs,
   once they are placed correctly within each MAC driver.

2. The other patches prepare the way for PHY drivers to offer time
   stamping.

I am preparing a new round of patches for PTP support, but it will
require the changes in this patch set in order to function. Thus I
would like to have this patch set reviewed (and hopefully merged) in
order to go forward.

Thanks,
Richard

* Patch ChangeLog
** v3
   After having received plenty of criticism on the idea of reading
   from the MDIO bus during the critical paths, this version presents
   a new approach. Now, when the CONFIG option for PHY time stamping
   is enabled, likely packets for time stamping are identified by the
   stack and presented to the PHY driver. The driver may accept the
   packet and defer its deliverly until the time stamp becomes
   available at a later time. This approach brings four main
   advantages.

   1. Now only one MAC driver hook is necessary.

   2. It leaves the option of how to get the time stamps open,
      allowing, for example, a driver to get them either via MDIO or
      PHY status frames.

   3. If reading the MDIO bus is required to get the time stamp, this
      can be done during as a work queue task.

   4. It moves the identification of PTP packets into the stack, so
      that each new PHY driver that comes only will not have to
      duplicate this logic again.

** v2
   Removed the CONFIG option for the driver hooks.


Richard Cochran (4):
  net: add driver hook for tx time stamping.
  net: preserve ifreq parameter when calling generic phy_mii_ioctl().
  net: added a BPF to help drivers detect PTP packets.
  net: support time stamping in phy devices.

 drivers/net/arm/ixp4xx_eth.c           |    3 +-
 drivers/net/au1000_eth.c               |    2 +-
 drivers/net/bcm63xx_enet.c             |    2 +-
 drivers/net/cpmac.c                    |    5 +-
 drivers/net/dnet.c                     |    2 +-
 drivers/net/ethoc.c                    |    2 +-
 drivers/net/fec.c                      |    2 +-
 drivers/net/fec_mpc52xx.c              |    2 +-
 drivers/net/fs_enet/fs_enet-main.c     |    3 +-
 drivers/net/gianfar.c                  |    2 +-
 drivers/net/macb.c                     |    2 +-
 drivers/net/mv643xx_eth.c              |    2 +-
 drivers/net/octeon/octeon_mgmt.c       |    2 +-
 drivers/net/phy/phy.c                  |    8 ++-
 drivers/net/phy/phy_device.c           |    2 +
 drivers/net/sb1250-mac.c               |    2 +-
 drivers/net/sh_eth.c                   |    2 +-
 drivers/net/smsc911x.c                 |    2 +-
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/stmmac/stmmac_main.c       |   22 ++----
 drivers/net/tc35815.c                  |    2 +-
 drivers/net/tg3.c                      |    2 +-
 drivers/net/ucc_geth.c                 |    2 +-
 drivers/staging/octeon/ethernet-mdio.c |    2 +-
 include/linux/netdevice.h              |    4 +
 include/linux/phy.h                    |   24 ++++++-
 include/linux/ptp_classify.h           |  126 ++++++++++++++++++++++++++++++++
 include/linux/skbuff.h                 |   52 +++++++++++++
 net/Kconfig                            |   10 +++
 net/core/Makefile                      |    2 +-
 net/core/dev.c                         |    3 +
 net/core/timestamping.c                |  126 ++++++++++++++++++++++++++++++++
 net/dsa/slave.c                        |    3 +-
 net/socket.c                           |    4 +
 34 files changed, 389 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/ptp_classify.h
 create mode 100644 net/core/timestamping.c

