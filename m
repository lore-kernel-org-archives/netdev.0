From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v4 00/12] ptp: IEEE 1588 clock support
Date: Tue, 15 Jun 2010 18:06:48 +0200
Message-ID: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59298 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab0FOQGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:06:00 -0400
Received: by fxm10 with SMTP id 10so265970fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:05:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now and again there has been talk on the netdev list of adding PTP
support into Linux. One part of the picture is already in place, the
SO_TIMESTAMPING API for hardware time stamping. This patch set offers
the missing second part needed for complete IEEE 1588 support.

The only feature still to be implemented is the hook into the PPS
subsystem, to synchronize the Linux clock to the PTP clock.

The first seven patches concern phylib. A new generation of PHYs with
timestamping capabilities is appearing on the market. In order to
support hardware timestamping on these devices in Linux, a number of
adjustments will have to be made in the PHY subsystem. The reasons for
the changes are explained inline at the top of the patches.

The last five patches provide the PTP subsystem itself.

* Why all the CCs?

  1. The patches probably should go through netdev.
  2. One driver is for PowerPC, and adds device tree stuff.
  3. One driver is for the ARM Xscale IXP465

* Open Issues:

** DP83640
   In order to make this work, three lines must be added into the MAC
   driver. Since this PHY can be connected to almost any MAC, I did
   not do anything about that. If you have the DP83640 and want to try
   the driver, you need to add three lines to your MAC driver.

   1. Before mdio_register, add
		bus->locktype = MDIOBUS_ATOMIC_RW;
   2. In the .ndo_start_xmit function, add
		skb_tx_timestamp()
   3. In the NAPI poll function, add
		skb_rx_timestamp()

** IXP465
   I do not know how to correctly choose the timestamp "channel" based
   on the port identifier:

	#define PORT2CHANNEL(p)		1
	/*
	 * PHYSICAL_ID(p->id) ?
	 * TODO - Figure out correct mapping.
	 */

* Patch ChangeLog

** v4
*** general
   - Added a clock driver for the National Semiconductor PHYTER.
   - Added a clock driver for the Intel IXP465.
   - Made more stylish according to checkstyle.pl.
*** gianfar
   - Replace device_type and model with compatible string ("fsl,etsec-ptp")
   - Register only one interrupt, since others are superfluous.
   - Combine ptp clock instance with private variable structure.
   - ISR now returns NONE or HANDLED properly.
   - Print error message if something is missing from the device nodes.

** v3
*** general
   - Added documentation on writing clock drivers.
   - Added the ioctls for the ancillary clock features.
   - Changed wrong subsys_initcall() to module_init() in clock drivers.
   - Removed the (too coarse) character device mutex.
   - Setting the clock now requires CAP_SYS_TIME.
*** gianfar
   - Added alarm feature.
   - Added device tree node binding description.
   - Added fine grain locking of the clock registers.
   - Added the external time stamp feature.
   - Added white space for better style.
   - Coverted base+offset to structure pointers for register access.
   - When removing the driver, we now disable all PTP functions.

** v2
   - Changed clock list from a static array into a dynamic list. Also,
     use a bitmap to manage the clock's minor numbers.
   - Replaced character device semaphore with a mutex.
   - Drop .ko from module names in Kbuild help.
   - Replace deprecated unifdef-y with header-y for user space header file.
   - Added links to both of the ptpd patches on sourceforge.
   - Gianfar driver now gets parameters from device tree.
   - Added API documentation to Documentation/ptp/ptp.txt

Looking forward to your feedback,
Richard


Richard Cochran (12):
  phylib: preserve ifreq parameter when calling generic phy_mii_ioctl()
  phylib: do not filter phy_mii_ioctl()
  phylib: add a driver method for the SIOCSHWTSTAMP ioctl.
  phylib: add a way to make PHY time stamps possible.
  phylib: Allow reading and writing a mii bus from atomic context.
  ptp: add a BPF to help drivers detect PTP packets.
  phylib: support the National Semiconductor DP83640 PHY.
  ptp: Added a brand new class driver for ptp clocks.
  ptp: Added a clock that uses the Linux system time.
  ptp: Added a clock that uses the eTSEC found on the MPC85xx.
  ptp: Added a clock driver for the IXP46x.
  ptp: Added a clock driver for the National Semiconductor PHYTER.

 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   54 ++
 Documentation/ptp/ptp.txt                       |   95 ++++
 Documentation/ptp/testptp.c                     |  269 ++++++++++
 Documentation/ptp/testptp.mk                    |   33 ++
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h   |   67 +++
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   13 +
 arch/powerpc/boot/dts/p2020ds.dts               |   13 +
 arch/powerpc/boot/dts/p2020rdb.dts              |   13 +
 drivers/Kconfig                                 |    2 +
 drivers/Makefile                                |    1 +
 drivers/net/Makefile                            |    1 +
 drivers/net/arm/ixp4xx_eth.c                    |  197 ++++++++-
 drivers/net/au1000_eth.c                        |    2 +-
 drivers/net/bcm63xx_enet.c                      |    2 +-
 drivers/net/cpmac.c                             |    5 +-
 drivers/net/dnet.c                              |    2 +-
 drivers/net/ethoc.c                             |    2 +-
 drivers/net/fec.c                               |    2 +-
 drivers/net/fec_mpc52xx.c                       |    2 +-
 drivers/net/fs_enet/fs_enet-main.c              |    3 +-
 drivers/net/gianfar.c                           |    2 +-
 drivers/net/gianfar_ptp.c                       |  518 ++++++++++++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++++
 drivers/net/macb.c                              |    2 +-
 drivers/net/mv643xx_eth.c                       |    2 +-
 drivers/net/octeon/octeon_mgmt.c                |    2 +-
 drivers/net/phy/Kconfig                         |   16 +
 drivers/net/phy/Makefile                        |    1 +
 drivers/net/phy/dp83640.c                       |  595 +++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h                   |  237 +++++++++
 drivers/net/phy/mdio_bus.c                      |   35 ++-
 drivers/net/phy/phy.c                           |    8 +-
 drivers/net/sb1250-mac.c                        |    2 +-
 drivers/net/sh_eth.c                            |    2 +-
 drivers/net/smsc911x.c                          |    2 +-
 drivers/net/smsc9420.c                          |    2 +-
 drivers/net/stmmac/stmmac_main.c                |   22 +-
 drivers/net/tc35815.c                           |    2 +-
 drivers/net/tg3.c                               |    2 +-
 drivers/ptp/Kconfig                             |   64 +++
 drivers/ptp/Makefile                            |    7 +
 drivers/ptp/ptp_clock.c                         |  514 ++++++++++++++++++++
 drivers/ptp/ptp_ixp46x.c                        |  231 +++++++++
 drivers/ptp/ptp_linux.c                         |  136 ++++++
 drivers/staging/octeon/ethernet-mdio.c          |    2 +-
 include/linux/Kbuild                            |    1 +
 include/linux/phy.h                             |   22 +-
 include/linux/ptp_classify.h                    |  118 +++++
 include/linux/ptp_clock.h                       |   79 +++
 include/linux/ptp_clock_kernel.h                |  137 ++++++
 include/linux/skbuff.h                          |   32 ++
 kernel/time/ntp.c                               |    2 +
 net/Kconfig                                     |   11 +
 net/dsa/slave.c                                 |    3 +-
 54 files changed, 3651 insertions(+), 51 deletions(-)
 create mode 100644 Documentation/ptp/ptp.txt
 create mode 100644 Documentation/ptp/testptp.c
 create mode 100644 Documentation/ptp/testptp.mk
 create mode 100644 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h
 create mode 100644 drivers/ptp/Kconfig
 create mode 100644 drivers/ptp/Makefile
 create mode 100644 drivers/ptp/ptp_clock.c
 create mode 100644 drivers/ptp/ptp_ixp46x.c
 create mode 100644 drivers/ptp/ptp_linux.c
 create mode 100644 include/linux/ptp_classify.h
 create mode 100644 include/linux/ptp_clock.h
 create mode 100644 include/linux/ptp_clock_kernel.h

