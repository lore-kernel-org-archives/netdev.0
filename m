From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 00/24] Support MDIO devices
Date: Mon,  4 Jan 2016 18:36:38 +0100
Message-ID: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34993 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbcADRiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The discussions about changing the way DSA probes switches resulted in
the wish to have switches attached to an MDIO bus to be represented as
an MDIO device. However the current code only supports PHYs on MDIO
busses. This patchset remedies this problem. It consists of a number
of cleanups, abstraction for accessing structure members, and
refactoring, as well as adding the concept of a generic MDIO device
and MDIO driver. The last two patches then make use of this facility
with a simple test driver, which will be discarded once we are past
RFC stage.

Andrew Lunn (24):
  phy: Consistently use addr for address on an MII bus
  mdio: Move mdiobus_read/write operatings into mdio.h
  phy: Use phy_read() instead of mdiobus_read()
  phy: Add phydev_err() and phydev_dbg() macros
  phy: add phydev_name() macro
  net: dnet: Use phy_find_first() helper
  phy: phy_{read|write}_mmd_indirect: get addr from phydev
  phy: Centralise print about attached phy
  phy: mdio-octeon: Use devm_mdiobus_alloc_size()
  mdio: Move allocation of interrupts into core
  phy: Add an mdio_device structure
  of: phy: Only register a phy device for phys
  phy: Add API for {un{registering an mdio device to a bus.
  phy_device: Move phy attributes into phy_device
  dsa: Register netdev before phy
  phy: Move PHY PM operations into phy_device
  phy: Centralize setting driver module owner
  phy: Move phy specific bus match into phy_device
  mdio_bus: Generalise of_mdiobus_link_phydev()
  mdio_bus: Add comment to mdiobus_scan() and __mdiobus_register()
  mdio: Add support for mdio drivers.
  mdio: Abstract device_remove() and device_free()
  mdio: mdio-nop: Dummy driver to testing
  Add linux,mdio-nop support for testing

 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |   5 +
 arch/powerpc/platforms/82xx/ep8248e.c              |  10 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c          |   3 -
 drivers/net/ethernet/8390/ax88796.c                |  17 +-
 drivers/net/ethernet/adi/bfin_mac.c                |  18 +-
 drivers/net/ethernet/aeroflex/greth.c              |   5 -
 drivers/net/ethernet/aeroflex/greth.h              |   1 -
 drivers/net/ethernet/agere/et131x.c                |  49 ++--
 drivers/net/ethernet/altera/altera_tse_main.c      |  15 +-
 drivers/net/ethernet/amd/au1000_eth.c              |  13 +-
 drivers/net/ethernet/broadcom/b44.c                |  21 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  12 -
 drivers/net/ethernet/broadcom/bgmac.c              |  15 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  14 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c         |  12 +-
 drivers/net/ethernet/broadcom/tg3.c                |  44 ++-
 drivers/net/ethernet/broadcom/tg3.h                |   1 -
 drivers/net/ethernet/cadence/macb.c                |  16 +-
 drivers/net/ethernet/dnet.c                        |  27 +-
 drivers/net/ethernet/ethoc.c                       |  18 +-
 drivers/net/ethernet/faraday/ftgmac100.c           |  10 +-
 drivers/net/ethernet/freescale/fec_main.c          |  27 +-
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c   |   4 -
 drivers/net/ethernet/freescale/fman/fman_dtsec.c   |   6 +-
 drivers/net/ethernet/freescale/fman/fman_memac.c   |   6 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |   2 +-
 .../net/ethernet/freescale/fs_enet/mii-bitbang.c   |  10 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c   |  10 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |   2 -
 drivers/net/ethernet/freescale/gianfar.c           |   4 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |   4 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 106 +++----
 drivers/net/ethernet/hisilicon/hns_mdio.c          |   5 -
 drivers/net/ethernet/lantiq_etop.c                 |  19 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |   2 +-
 drivers/net/ethernet/marvell/mvmdio.c              |  10 +-
 drivers/net/ethernet/marvell/mvneta.c              |   2 +-
 drivers/net/ethernet/nxp/lpc_eth.c                 |  18 +-
 drivers/net/ethernet/rdc/r6040.c                   |  20 +-
 drivers/net/ethernet/renesas/ravb_main.c           |   3 -
 drivers/net/ethernet/renesas/sh_eth.c              |  15 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |   4 +-
 drivers/net/ethernet/smsc/smsc911x.c               |  21 +-
 drivers/net/ethernet/smsc/smsc9420.c               |  21 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |  18 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c        |  28 +-
 drivers/net/ethernet/ti/cpsw.c                     |   5 +-
 drivers/net/ethernet/ti/davinci_emac.c             |   5 -
 drivers/net/ethernet/ti/davinci_mdio.c             |   4 +-
 drivers/net/ethernet/ti/netcp_ethss.c              |   4 +-
 drivers/net/ethernet/toshiba/tc35815.c             |  20 +-
 drivers/net/ethernet/xilinx/ll_temac.h             |   1 -
 drivers/net/ethernet/xilinx/ll_temac_mdio.c        |   2 -
 drivers/net/ethernet/xilinx/xilinx_axienet.h       |   2 -
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c  |   2 -
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |   6 +-
 drivers/net/phy/Kconfig                            |   8 +
 drivers/net/phy/Makefile                           |   3 +-
 drivers/net/phy/amd.c                              |   1 -
 drivers/net/phy/aquantia.c                         |   4 -
 drivers/net/phy/at803x.c                           |  15 +-
 drivers/net/phy/bcm-phy-lib.c                      |   8 +-
 drivers/net/phy/bcm63xx.c                          |   2 -
 drivers/net/phy/bcm7xxx.c                          |   8 +-
 drivers/net/phy/bcm87xx.c                          |  11 +-
 drivers/net/phy/broadcom.c                         |  12 -
 drivers/net/phy/cicada.c                           |   2 -
 drivers/net/phy/davicom.c                          |   4 -
 drivers/net/phy/dp83640.c                          |  25 +-
 drivers/net/phy/dp83848.c                          |   2 -
 drivers/net/phy/dp83867.c                          |  12 +-
 drivers/net/phy/et1011c.c                          |   1 -
 drivers/net/phy/fixed_phy.c                        |  14 +-
 drivers/net/phy/icplus.c                           |  21 +-
 drivers/net/phy/lxt.c                              |   4 -
 drivers/net/phy/marvell.c                          |  20 +-
 drivers/net/phy/mdio-bcm-unimac.c                  |  11 +-
 drivers/net/phy/mdio-gpio.c                        |   2 +-
 drivers/net/phy/mdio-moxart.c                      |   7 -
 drivers/net/phy/mdio-mux.c                         |   3 +-
 drivers/net/phy/mdio-nop.c                         |  37 +++
 drivers/net/phy/mdio-octeon.c                      |  14 +-
 drivers/net/phy/mdio-sun4i.c                       |  12 +-
 drivers/net/phy/mdio_bus.c                         | 283 ++++++++-----------
 drivers/net/phy/mdio_device.c                      | 171 +++++++++++
 drivers/net/phy/micrel.c                           |  41 +--
 drivers/net/phy/microchip.c                        |  11 +-
 drivers/net/phy/national.c                         |   1 -
 drivers/net/phy/phy.c                              |  63 ++---
 drivers/net/phy/phy_device.c                       | 311 +++++++++++++++++----
 drivers/net/phy/qsemi.c                            |   1 -
 drivers/net/phy/realtek.c                          |   5 -
 drivers/net/phy/smsc.c                             |  12 +-
 drivers/net/phy/ste10Xp.c                          |   2 -
 drivers/net/phy/teranetics.c                       |   1 -
 drivers/net/phy/vitesse.c                          |   8 -
 drivers/net/usb/ax88172a.c                         |  14 +-
 drivers/net/usb/lan78xx.c                          |  11 +-
 drivers/of/of_mdio.c                               |  78 +++++-
 drivers/staging/netlogic/xlr_net.c                 |   6 +-
 include/linux/mdio.h                               |  78 ++++++
 include/linux/phy.h                                |  69 +++--
 net/dsa/dsa.c                                      |   2 +-
 net/dsa/slave.c                                    |  20 +-
 104 files changed, 1059 insertions(+), 1136 deletions(-)
 create mode 100644 drivers/net/phy/mdio-nop.c
 create mode 100644 drivers/net/phy/mdio_device.c

-- 
2.6.4
